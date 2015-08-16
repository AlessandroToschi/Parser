//
//  Stack.swift
//  Parser
//
//  Created by Alessandro on 28/07/15.
//  Copyright (c) 2015 Alessandro. All rights reserved.
//

import Foundation

/// Node element of generic type for stack.
class Node<T>
{
    /// Generic stack's object.
    var object: T?
    
    /// Next stack's object if available.
    var next: Node<T>?
}

/// Generic LIFO stack.
class Stack<T>
{
    /// Last stack's element.
    private var top: Node<T>?
    
    /// Last stack's element.
    var last: T
    {
        //Return last stack's object (forced unwrap).
        return self.top!.object!
    }
    
    /// Return true if the stack is empty.
    var isEmpty: Bool
    {
        //Check if the top element is nil.
        return top == nil
    }
    
    /// Push object into the stack.
    func push(object: T)
    {
        //Create
        let newNode = Node<T>()
        newNode.object = object
        
        if self.top == nil
        {
            self.top = newNode
        }
        else
        {
            newNode.next = self.top
            self.top = newNode
        }
    }
    
    func pop() -> T?
    {
        let lastNode = self.top
        self.top = lastNode?.next
        
        return lastNode?.object
    }
}