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
#ifndef _Scheduler_h_
#define _Scheduler_h_ 1

#include "generic/EmbeddedContainers.h"
#include "runtime/Runtime.h"
#include "generic/AVL_Tree.h"//added for a2

class Thread;
class ThreadNode; //added for a2

class Scheduler {
  friend void Runtime::idleLoop(Scheduler*);
  bufptr_t idleStack[minimumStack];

  Tree<ThreadNode> *readyTree; //added for a2

  // very simple N-class prio scheduling
  BasicLock readyLock;
  volatile mword readyCount;
  EmbeddedList<Thread> readyQueue[maxPriority];
  volatile mword preemption;
  volatile mword resumption;

  Scheduler* partner;

  template<typename... Args>
  inline void switchThread(Scheduler* target, Args&... a);

  inline void enqueue(Thread& t);

  Scheduler(const Scheduler&) = delete;                  // no copy
  const Scheduler& operator=(const Scheduler&) = delete; // no assignment

public:
  static mword defaultEpochLength; //added for a2
  static mword schedMinGranularity; //added for a2
  Scheduler();
  void setPartner(Scheduler& s) { partner = &s; }
  static void resume(Thread& t);
  void preempt();
  void suspend(BasicLock& lk);
  void suspend(BasicLock& lk1, BasicLock& lk2);
  void terminate() __noreturn;
};

#endif /* _Scheduler_h_ */
