#! /usr/bin/python

import random
import sys

CLASSES =  {
  6: ['Ayman', 'Shaeq', 'Patrick', 'Yvonne', 'Wilson', 'Brian', 'Farhan',
      'Janet', 'Harry', 'Kevin', 'Nicholas', 'Jason', 'Yikai', 'Emma',
      'Kenneth', 'Nala', 'Karol', 'Elias', 'Ely', 'Reo', 'Dhriaj', 'Amy',
      'Arvind', 'Nobel', 'Angela', 'Edward', 'Jonathan', 'Celine', 'Daniel',
      'Lindsey', 'Ziyan', 'Elina'],
  8: ['Julian', 'Sebastian', 'Jordan', 'Alan', 'Yuki', 'Chloe', 'Noah', 'Edvic',
      'Jia Qi', 'Shan', 'Rodda', 'Anya', 'Edmond', 'Asher', 'Kathy', 'Sharon',
      'Vncent', 'Lawrence', 'Sachal', 'Gabriel', 'Jason', 'Daniel', 'Felix',
      'Jacob', 'Bayle', 'Fortune', 'Gio', 'Kelly', 'William', 'Jordan', 'Haley',
      'Henry'],
  9: ['James', 'Vanna', 'Zicheng', 'Quinn', 'Anthony C', 'Joel', 'Steph',
      'Xinhui', 'Richard', 'Misha', 'Maddie', 'Winston', 'Shariar', 'Nancy',
      'Jerry', 'Michael', 'Stiven', 'Will',  'Olivia', 'Constantine', 'Jessica',
      'Kate', 'Shamaul', 'Max', 'Sarah', 'Anthony L', 'Brandon', 'Nicole',
      'Brian', 'Issac', 'Seiji', 'Lorenz']
}

if len(sys.argv) != 2 or int(sys.argv[1]) not in CLASSES:
  print 'Available periods: ' + str(sorted(CLASSES.keys()))
else:
  print random.choice(CLASSES[int(sys.argv[1])])