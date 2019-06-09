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

#include "globalStat.h"

Define_Module(GlobalStat);

void GlobalStat::initialize()
{
    // TODO - Generated method body
    noCarsReached = 0;
}

void GlobalStat::handleMessage(cMessage *msg)
{
    // TODO - Generated method body
}

long GlobalStat::getNoCarsReached(void)
{
    return this->noCarsReached;
}

void GlobalStat::incNoCarsReached(void)
{
    this->noCarsReached++;
}

void GlobalStat::finish()
{
    recordScalar("#carsReached", noCarsReached);
}
