//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

#include "MySimpleFlooding.h"

#define REBROADCAST_TIME 1
#define REPEAT_TX_TIME  2

Define_Module(MySimpleFlooding);

MySimpleFlooding::~MySimpleFlooding()
{
    cancelEvent(txEvent);

    delete(msgCopy);
    delete(txEvent);
}

void MySimpleFlooding::initialize(int stage) {
    DemoBaseApplLayer::initialize(stage);
    if (stage == 0) {
        //Initializing members and pointers of your application goes here

        duplicates.setName("duplicates");
        sentMessages.setName("sent_messages");
        reachedNodes.setName("reached_nodes");

        getParentModule()->getDisplayString().setTagArg("i",1,"red");
        sig_hopcount = registerSignal("sig_hopcount");
        sig_delay = registerSignal("sig_delay");
        numDuplicates = 0;
        numSent = 0;
        pktDelay = 0;
        msgCopy = nullptr;
        txEvent = new cMessage("txEvent");
    } else if (stage == 1) {
        //Initializing members that require initialized other modules goes here
         globalStats = Veins::FindModule<GlobalStat*>::findSubModule(getParentModule()->getParentModule());
    }
}

void MySimpleFlooding::finish() {
    DemoBaseApplLayer::finish();

    //maybe you want to record some scalars?
    recordScalar("#duplicates", numDuplicates);
    recordScalar("#numSent", numSent);
    recordScalar("#pktDelay",pktDelay);
}
void MySimpleFlooding::handleFloodingMsg(FloodingMessage* msg) {
    bool isDuplicate = false;

    getParentModule()->getDisplayString().setTagArg("i",1,"green");
    annotations->scheduleErase(0.25, annotations->drawLine(curPosition, msg->getOriginPosition(), "red"));
    getParentModule()->getParentModule()->getDisplayString().setTagArg("i", 1, "yellow");

    traciVehicle->setColor(Veins::TraCIColor(255, 0, 0, 255));
    findHost()->getDisplayString().updateWith("g=16,green"); // If a car received the message, the car will appear with green color in the UI

    // if there is no message copy
    if(!msgCopy)
    {
        msgCopy = msg->dup();
        pktDelay = simTime() - msg->getCreationTime();
        globalStats->incNoCarsReached();

        // Schedule the txEvent event for "txEvent" duration
        scheduleAt(simTime()+uniform(0,REBROADCAST_TIME), txEvent);
    }
    else // there is a copy already
    {
            isDuplicate = true;
            // cancel the existing tx event, if any
            cancelEvent(txEvent);

            // Schedule the timeout event for "timeout" duration
            scheduleAt(simTime()+ REPEAT_TX_TIME, txEvent);
    }

    msg->setHopCount(msg->getHopCount() + 1);
    if (isDuplicate) { //TODO: Check for duplicates here
        numDuplicates++;
        duplicates.record(numDuplicates);
    } else {
        //TODO: The following code block might help you - the statistics are wrong at the moment
    }
}

void MySimpleFlooding::handleMessage(cMessage *msg) {
    if (FloodingMessage* fm = dynamic_cast<FloodingMessage*>(msg)) {
        handleFloodingMsg(fm);
    } else if (msg->isSelfMessage()) {
        handleSelfMsg(msg);
    }
}

void MySimpleFlooding::handleSelfMsg(cMessage* msg) {
    //DemoBaseApplLayer::handleSelfMsg(msg);
    //this method is for self messages (mostly timers)
    //it is important to call the DemoBaseApplLayer function for BSM and WSM transmission
    if(msg == txEvent)
    {
        if(msgCopy)
        {
            sendFloodingMessage(msgCopy);

            cancelEvent(txEvent);
            // Schedule the txEvent event for "txEvent" duration
            scheduleAt(simTime()+ REPEAT_TX_TIME, txEvent);
        }
    }
}

void MySimpleFlooding::handlePositionUpdate(cObject* obj) {
    DemoBaseApplLayer::handlePositionUpdate(obj);
    curPosition = mobility->getPositionAt(simTime());
    //the vehicle has moved. Code that reacts to new positions goes here.
    //member variables such as currentPosition and currentSpeed are updated in the parent class

}

void MySimpleFlooding::sendFloodingMessage(FloodingMessage* msg)
{
    sentMessages.record(1);
    numSent++;

    simtime_t delay = uniform(0, 0.1);
    sendDelayedDown(msg->dup(), delay);
    getParentModule()->getDisplayString().setTagArg("i2",0,"status/busy");
}
