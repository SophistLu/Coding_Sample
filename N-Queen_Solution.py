#!/usr/bin/env python (Work in non-Windows Platform)
#-*- encoding: utf-8 -*- ()
# Copyright (c) 2015 - Zhaoyu Lu <zylu@g.ucla.com>

# N-Queen Solutions

class Solution(object):
    # input: int
    # output: [[]...[]]
    def solveNQueens(self,n):
        if n==1:
            return [["Q"]]
        elif n<=0 or n==2 or n==3: # No solutions
            return []
        
        
        row = 0 # Can be 0...n-1
        col = 0 # Place Queens col by col
        cBoard = [-1]*n
        diagUp = diagLw = [0]*(2*n-1)
        solutions = []
        rowDict = dict()
        
        # Begin to traverse chess board
        # Using symmetry property to reduce time complexity
        while ((n%2==0 and cBoard[0]<n/2) or 
               (n%2==1 and cBoard[0]<=(n-1)/2)):
             
            tempUp = row + col # Upper diagonal index (From the left)
            tempLw = (n-1) - row + col # Lower diagonal index
            
            # Judge if conflict && cope with "col" && print
            if (diagUp[tempUp]==0 and diagLw[tempLw]==0
                                  and row not in rowDict):
                cBoard[col] = row
                
                if col==n-1:
                    if (n%2==1 and cBoard[0]==(n-1)/2):
                        solutions.append(self.getNQS(cBoard,n,0))
                    else:
                        solutions.append(self.getNQS(cBoard,n,0))
                        solutions.append(self.getNQS(cBoard,n,1))
                    
                    # print "Find a solution!"
                    
                    cBoard[col] = -1 # Clean last col
                    col = col - 1 # Clean last 2th col
                    row = cBoard[col] # Recover row
                    diagUp[row+col] = 0 # Clean it
                    diagLw[n-1-row+col] = 0 # Clean it
                    rowDict.pop(cBoard[col]) # Pop the useless row
                    cBoard[col] = -1
                else:
                    diagUp[tempUp] = 1
                    diagLw[tempLw] = 1
                    rowDict[row] = 1 # If not last col, add to dict
                    col = col + 1
                    row = -1 # To unify with other 2 conditions
                            # Three conditions:
                            # 1 valid -> new col: row = 0
                            # 2 valid -> end col -> back: row==i:+1 or row==n-1: while
                            # 3 invalid: row==i:+1 or row==n-1: while
                
            # Cope with overflow "row"
            if row==n-1:
                while row==n-1:
                    col = col - 1 # Go back 1 col
                    row = cBoard[col] # Recover row
                    diagUp[row+col] = 0 # Clean it
                    diagLw[n-1-row+col] = 0 # Clean it
                    rowDict.pop(cBoard[col]) # Pop the useless row
                    cBoard[col] = -1 # Set useless row to -1
                    
                    
            # All the situations: goto next row
            row = row + 1
            
            #print cBoard
            #print self.getNQS(cBoard, n, 0)
            #print "\n"
            
        return solutions

    def getNQS(self,cBoard,n,invBoard):
        tempBoard = [["."]*n for _ in range(n)] # CANNOT BE [["."]*n]*n for it will refer to the same list
        if invBoard==0:
            for j in range(0,n):
                if cBoard[j]!=-1:
                    tempBoard[cBoard[j]][j] = 'Q'
        elif invBoard==1:
            for j in range(0,n):
                if cBoard[j]!=-1:
                    tempBoard[n-1-cBoard[j]][j] = 'Q'
        
        for j in range(0,n):
            tempBoard[j] = "".join(tempBoard[j])
        
        return tempBoard

# Test it
myTest = Solution();
outputTest = myTest.solveNQueens(4)
if outputTest!=-1:
    print len(outputTest)
    print outputTest

                    