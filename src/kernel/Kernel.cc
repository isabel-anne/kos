/******************************************************************************
    Copyright � 2012-2015 Martin Karsten

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
******************************************************************************/
#include "runtime/Thread.h"
#include "kernel/AddressSpace.h"
#include "kernel/Clock.h"
#include "kernel/Output.h"
#include "world/Access.h"
#include "machine/Machine.h"
#include "devices/Keyboard.h"
#include "devices/RTC.h"
#include <stdlib.h> //added for a2
#include "runtime/Scheduler.h"
#include <string>
#include <ctype.h>

#include "main/UserMain.h"

AddressSpace kernelSpace(true); // AddressSpace.h
volatile mword Clock::tick;     // Clock.h

extern Keyboard keyboard;

#if TESTING_KEYCODE_LOOP
static void keybLoop() {
  for (;;) {
    Keyboard::KeyCode c = keyboard.read();
    StdErr.print(' ', FmtHex(c));
  }
}
#endif

void kosMain() {
  KOUT::outl("Welcome to KOS!", kendl);
  auto iter = kernelFS.find("motb");
  if (iter == kernelFS.end()) {
    KOUT::outl("motb information not found");
  } else {
    FileAccess f(iter->second);
    for (;;) {
      char c;
      if (f.read(&c, 1) == 0) break;
      KOUT::out1(c);
    }
    KOUT::outl();
  }

//added for a2
  string s = "";
  bool x = false;

  iter = kernelFS.find("schedparam");
  if (iter == kernelFS.end()) {
      KOUT::outl("schedparam information not found");
  } else {
      FileAccess f(iter->second);
      for (;;) {
          char c;
          if (f.read(&c, 1) == 0) break;
          if(isdigit(c))// 0-9 ASCII value
          {  //if it is a number add it to the end of string
              KOUT::out1(c);
              s += c;
          }
          else if(!isdigit(c) && !s.empty())//  else if ((c < '0' || c > '9') && !s.empty()) //if the number exists and has been read
          {
               KOUT::out1(c);
              //if x == false parse to int and store defaultEpochLength
              //if x == true parse to int and store in schedMinGranularity
              if(x == false){
            //      KOUT::outl("if(x==false)\ns == ", s);
                  Scheduler::defaultEpochLength = atoi(s.c_str());//20;//(mword)s.c_str();
                  s = "";
                  x = true;
              }
              else
              {
              //  KOUT::outl("if(x==true)\ns == ", s);
                Scheduler::schedMinGranularity = atoi(s.c_str());//4;//(mword)s.c_str();
              }
           }
          else
              KOUT::out1(c);
      }
     }
    //  Scheduler::defaultEpochLength = Scheduler::defaultEpochLength * (Machine::cps/1000);
    //  Scheduler::schedMinGranularity = Scheduler::schedMinGranularity * (Machine::cps/1000);
     KOUT::out1("Schedule Parameters afte Parse\n");
     KOUT::out1("cps = ", Machine::cps, "\n");
     KOUT::out1("defaultEpochLength = ", Scheduler::defaultEpochLength, "\n");
     KOUT::out1("schedMinGranularity = ", Scheduler::schedMinGranularity, "\n");
//end added for a2

#if TESTING_TIMER_TEST
  StdErr.print(" timer test, 3 secs...");
  for (int i = 0; i < 3; i++) {
    Timeout::sleep(Clock::now() + 1000);
    StdErr.print(' ', i+1);
  }
  StdErr.print(" done.", kendl);
#endif
#if TESTING_KEYCODE_LOOP
  Thread* t = Thread::create()->setPriority(topPriority);
  Machine::setAffinity(*t, 0);
  t->start((ptr_t)keybLoop);
#endif
  Thread::create()->start((ptr_t)UserMain);
#if TESTING_PING_LOOP
  // for (;;) {
  //   Timeout::sleep(Clock::now() + 1000);
  //   KOUT::outl("...ping...");
  // }
#endif
}

extern "C" void kmain(mword magic, mword addr, mword idx)         __section(".boot.text");
extern "C" void kmain(mword magic, mword addr, mword idx) {
  if (magic == 0 && addr == 0xE85250D6) {
    // low-level machine-dependent initialization on AP
    Machine::initAP(idx);
  } else {
    // low-level machine-dependent initialization on BSP -> starts kosMain
    Machine::initBSP(magic, addr, idx);
  }
}
