//
//  RPN.swift
//  Parser
//
//  Created by Alessandro on 31/07/15.
//  Copyright (c) 2015 Alessandro. All rights reserved.
//

import Foundation
import Cocoa

/// Enumeratore contenente i diversi tipi di operatori: binari e unari.
///
/// Operatore binario: accetta due operandi ed esegue l'operazione. Es: 2 + 4
///
/// Operatore unario: accetta un solo operando su cui esegue l'operazione. Es: ln(e)
enum OperatorType
{
    /// Operatore unario: accetta un solo operando su cui esegue l'operazione. Es: ln(e)
    case Unary
    /// Operatore binario: accetta due operandi ed esegue l'operazione. Es: 2 + 4
    case Binary
}

/// Valutatore matematico che converte i token di una funzione matematica in notazione infissa in una postfissa.
///
/// Successivamente permette di valutare l'espressione matematica sia con incognita che senza.
class RPN
{
    private var operators: Stack<Token> // Stack che conterrà gli operatori durante la conversione, successivamente sarà vuoto.
    private var RPNTokens: [Token] // Array contenente i token convertiti in notazione postfissa pronti per essere valutati.
    private var binaryOperatorsString: [String] // Array contenente gli operatori matematici binari in formato stringa.
    
    /// Inizializza la classe con i token di una funzione matematica in notazione infissa.
    ///
    /// tokens: array di token di una espressione matematica infissa.
    init(tokens: [Token])
    {
        // Inizializzo e assegno le variabili di classe.
        self.operators = Stack<Token>()
        self.RPNTokens = [Token]()
        self.binaryOperatorsString = ["+", "-", "*", "/", "^"]
        self.convertToRPN(tokens)
    }
    
    /// Restituisce la precendeza dell'operatore.
    ///
    /// op: token dell'operatore di cui restituire la precedenza.
    private func operatorPrecedence(op: Token) -> Int
    {
        // Valuto l'operatore:
        switch op.string
        {
        case "*", "/", "^": // Operatore con precedenza maggiore.
            return 100
        case "+", "-": // Operatore con precedenza minore.
            return 1
        default:
            return 10 // Operatore con precedenza media.
        }
    }
    
    /// Restituisce l'espressione convertita in notazione postfissa in una stringa "human-readable".
    private func postfixNotation() -> String
    {
        // Stringa che conterrà l'espressione postfissa.
        var postfixNotationExpression = ""
        
        // Scorro tutti i token.
        for token in self.RPNTokens
        {
            // Aggiungo ogni token alla stringa.
            postfixNotationExpression += token.string + " "
        }
        
        //Rimuovo lo spazio bianco finale.
        postfixNotationExpression.removeAtIndex(advance(postfixNotationExpression.startIndex, count(postfixNotationExpression) - 1))
        return postfixNotationExpression
    }
    
    /// Converte i token della funzione matematica in notazione infissa in token relativi alla funzione matematica postfissa.
    ///
    /// tokens: array di token di una espressione matematica infissa.
    private func convertToRPN(tokens: [Token])
    {
        // Scorro i token infissi.
        for token in tokens
        {
            // Identifico il tipo di token.
            switch token.type
            {
            case .LeftBracket: // Parentesi di apertura.
                operators.push(token) // Inserisco la parentesi di apertura nello stack degli operatori.
            case .RightBracket: // Parentesi di chiusura.
                while self.operators.last.type != .LeftBracket // Finchè l'ultimo operatore non è una parentesi di apertura.
                {
                    // Rimuovo l'operatore dallo stack e lo inserisco nell'array contenente i token postfissi.
                    self.RPNTokens.append(self.operators.pop()!)
                }
                //Elimino la parentesi di apertura.
                self.operators.pop()
            case .Number, .Constant, .Unknown: // Numero, costante, variabile.
                RPNTokens.append(token) // Inserisco il numero, costante, variabile nell'array contenente i token postfissi.
            case .Operator: // Operatore.
                // Se lo stack degli operatori è vuoto, oppure se l'ultimo operatore è una parentesi di apertura, o se la precedenza dell'ultimo operatore è minore
                // di quello corrente, inserisco l'operatore corrente nello stack degli operatori.
                if self.operators.isEmpty || self.operators.last.type != .Operator || self.operatorPrecedence(self.operators.last) < self.operatorPrecedence(token)
                {
                    self.operators.push(token)
                }
                // Se l'ultimo operatore dello stack ha una precedenza uguale o maggiore all'operatore corrente:
                else if !self.operators.isEmpty && self.operatorPrecedence(self.operators.last) >= self.operatorPrecedence(token)
                {
                    // Rimuovo l'operatore dallo stack e lo inserisco nell'array contenente i token postfissi.
                    self.RPNTokens.append(self.operators.pop()!)
                    
                    // Controllo se sia necessario riefettuare l'estrazione dell'operatore con precedenza maggiore:
                    while !self.operators.isEmpty && self.operators.last.type == .Operator && self.operatorPrecedence(self.operators.last) >= self.operatorPrecedence(token)
                    {
                        // Rimuovo l'operatore dallo stack e lo inserisco nell'array contenente i token postfissi.
                        self.RPNTokens.append(self.operators.pop()!)
                    }
                    
                    // Inserisco l'operatore nello stack degli operatori.
                    self.operators.push(token)
                }
            default:
                println(token)
            }
        }
        
        // Nel caso siano rimasti operatori nello stack.
        if !self.operators.isEmpty
        {
            // Finchè sono presenti operatori:
            while let lastOperator = self.operators.pop()
            {
                // Inserisco l'operatore nello stack degli operatori.
                self.RPNTokens.append(lastOperator)
            }
        }

        println(self.postfixNotation())
    }
    
    /// Applica l'operatore sugli operandi restituendo il risultato dell'operazione.
    ///
    /// op: token relativo all'operatore da applicare.
    ///
    /// first: primo operando.
    ///
    /// second: secondo operando, può essere nil se l'operatore è unario.
    private func applyOperator(op: Token, first: Double, second: Double?) -> Double
    {
        // Valuto l'operatore:
        switch op.string
        {
        case "+": // Somma.
            if let second = second
            {
                return first + second
            }
        case "-": // Sottrazione.
            if let second = second
            {
                return first - second
            }
        case "*": // Moltiplicazione.
            if let second = second
            {
                return first * second
            }
        case "/": // Divisione.
            if let second = second where second != 0.0
            {
                return first / second
            }
        case "^": // Potenza.
            if let second = second
            {
                return pow(first, second)
            }
        case "cos": // Coseno.
            return cos(first)
        case "sin": // Seno.
            return sin(first)
        case "tan": // Tangente.
            return tan(first)
        case "abs": // Valore assoluto.
            return abs(first)
        case "exp": // Esponenziale.
            return exp(first)
        case "ln": // Logaritmo naturale.
            return log(first)
        case "log10": // Logaritmo a base 10.
            return log10(first)
        case "sqrt": // Radice quadrata.
            return sqrt(first)
        default:
            return Double.NaN
        }
        return Double.NaN
    }
    
    /// Valuta la funzione finchè non incontra una incognita.
    private func preEvaluate()
    {
        // Scorro i token.
        for var i = 0; i < self.RPNTokens.count; i++
        {
            // Se il token corrente è un operatore:
            if self.RPNTokens[i].type == .Operator
            {
                // Se l'operatore è binario:
                if self.typeOfOperator(self.RPNTokens[i]) == .Binary
                {
                    // Controllo se nelle due posizioni precedenti all'operatore non sono presenti incognite in quanto posso calcolare già una operazione:
                    if self.RPNTokens[i - 2].type != .Unknown && self.RPNTokens[i - 1].type != .Unknown
                    {
                        // Applico l'operatore tra i due operandi.
                        let operationResult = self.applyOperator(self.RPNTokens[i], first: self.RPNTokens[i - 2].value!, second: self.RPNTokens[i - 1].value!)
                        
                        // Rimuovo l'operatore e i due operandi.
                        self.RPNTokens.removeRange((i - 2)...i)
                        // Inserisco nella posizione del primo operando il risultato dell'operazione.
                        self.RPNTokens.insert(Token(type: .Number, range: NSMakeRange(0, 0), string: "\(operationResult)", value: operationResult), atIndex: i - 2)
                        // Imposto l'indice in modo da ripartire dall'inizio.
                        i = -1
                    }
                    // Se sono presenti incognite nei precedenti due operandi esco semplicemente dal ciclo.
                    else
                    {
                        // Esco dal ciclo.
                        i = self.RPNTokens.count
                    }
                }
                // Se l'operatore è unario:
                else
                {
                    // Controllo se nella posizione precedente all'operatore non è presente un'incognita in quanto posso calcolare già una operazione:
                    if self.RPNTokens[i - 1].type != .Unknown
                    {
                        // Applico l'operatore all'operando.
                        let operationResult = self.applyOperator(self.RPNTokens[i], first: self.RPNTokens[i - 1].value!, second: nil)
                        
                        // Rimuovo l'operatore e l'operando.
                        self.RPNTokens.removeRange((i - 1)...i)
                        // Inserisco nella posizione dell' operando il risultato dell'operazione.
                        self.RPNTokens.insert(Token(type: .Number, range: NSMakeRange(0, 0), string: "\(operationResult)", value: operationResult), atIndex: i - 1)
                        // Imposto l'indice in modo da ripartire dall'inizio.
                        i = -1
                    }
                    // Se sono presenti incognite nei precedenti due operandi esco semplicemente dal ciclo.
                    else
                    {
                        // Esco dal ciclo.
                        i = self.RPNTokens.count
                    }
                }
            }
        }
    }
    
    /// Restituisce se l'operatore è binario oppure unario.
    ///
    /// op: operatore da valutare.
    private func typeOfOperator(op: Token) -> OperatorType
    {
        // Confronto se l'operatore è nella lista di quelli binari altrimenti è unario.
        return contains(self.binaryOperatorsString, op.string) ? .Binary : .Unary
    }
    
    /// Cerca gli indici dei token relative alle incognite all'interno dell'espressione postfissa.
    private func findUnknownTokenIndexes() -> [Int]
    {
        // Array contenente gli indici dei token relativi alle incognite.
        var unknownTokenIndexes = [Int]()
        
        // Scorro i token.
        for var i = 0; i < self.RPNTokens.count; i++
        {
            // Se il token corrente è un'incognita.
            if self.RPNTokens[i].type == .Unknown
            {
                // Aggiungo l'indice all'array.
                unknownTokenIndexes.append(i)
            }
        }
        
        // Restituisco l'array.
        return unknownTokenIndexes
    }
    
    /// Imposta un valore alle incognite presenti nell'espressione postfissa.
    ///
    /// value: valore da impostare alle incognite.
    ///
    /// unknownTokenIndexes: array contenente gli indici dei token relativi alle incognite.
    private func setValueForUnknowns(value: Double, unknownTokenIndexes: [Int])
    {
        // Scorro ogni indice:
        for unknownTokenIndex in unknownTokenIndexes
        {
            // Assegno il valore all'incognita all'indice corrente.
            self.RPNTokens[unknownTokenIndex].value = value
        }
    }
    
    /// Valuta l'espressione e restituisce il risultato.
    func evaluate() -> Double
    {
        // Copia dell'array contenente i token postfissi. Serve per non distruggere l'array originale e per non rieffettuare la conversione in RPN.
        var output = self.RPNTokens
        
        // Scorro i token:
        for var i = 0; i < output.count; i++
        {
            // Se il token corrente è un operatore:
            if output[i].type == .Operator
            {
                // Se l'operatore è binario:
                if self.typeOfOperator(output[i]) == .Binary
                {
                    // Applico l'operatore tra i due operandi.
                    let operationResult = self.applyOperator(output[i], first: output[i - 2].value!, second: output[i - 1].value!)

                    // Rimuovo l'operatore e i due operandi.
                    output.removeRange((i - 2)...i)
                    // Inserisco nella posizione del primo operando il risultato dell'operazione.
                    output.insert(Token(type: .Number, range: NSMakeRange(0, 0), string: "\(operationResult)", value: operationResult), atIndex: i - 2)
                    // Imposto l'indice in modo da ripartire dall'inizio.
                    i = -1
                }
                // Se l'operatore è unario:
                else
                {
                    // Applico l'operatore all'operando.
                    let operationResult = self.applyOperator(output[i], first: output[i - 1].value!, second: nil)
                    
                    // Rimuovo l'operatore e l'operando.
                    output.removeRange((i - 1)...i)
                    // Inserisco nella posizione dell' operando il risultato dell'operazione.
                    output.insert(Token(type: .Number, range: NSMakeRange(0, 0), string: "\(operationResult)", value: operationResult), atIndex: i - 1)
                    // Imposto l'indice in modo da ripartire dall'inizio.
                    i = -1
                }
            }
        }
        
        // Ritorno il valore calcolato dell'espressione.
        return output.last!.value!
    }
    
    /// Valuta l'espressione, assegnando alle incognite il valore passato, e restituisce il risultato.
    ///
    /// x: valore da assegnare alle incognite.
    func evaluate(#x: Double) -> Double
    {
        // Cerco gli indici delle incognite e successivamente imposto loro il valore passato.
        self.setValueForUnknowns(x, unknownTokenIndexes: self.findUnknownTokenIndexes())
        
        // Calcolo l'espressione.
        return self.evaluate()
    }
    
    /// Valuta l'espressione, assegnando alle incognite i valori all'interno del range, e restituisce i risultati.
    ///
    /// range: valori da assegnare alle incognite.
    func evaluate(#range: Range<Int>) -> [Double]
    {
        // Valuto l'espressione nel range in single-thread e restituisco i risultati.
        return self.evaluate(range: range, async: false)
    }
    
    /// Valuta l'espressione, assegnando alle incognite i valori all'interno del range, e restituisce i risultati.
    ///
    /// range: valori da assegnare alle incognite.
    ///
    /// async: se "true" esegue la valutazione in multi-thread.
    func evaluate(#range: Range<Int>, async: Bool) -> [Double]
    {
        // Pre-valuto la funzione finchè possibile.
        self.preEvaluate()
        
        // Individuo gli indici delle incognite nell'array di token postfissi.
        var unknownTokenIndexes = self.findUnknownTokenIndexes()
        var values: [Double] // Array contenente i valori dell'espressione calcolata nel range.
        
        // Se il calcolo è in multi-thread:
        if async
        {
            // Numero di operazioni totali.
            let rangeLength = (range.endIndex - range.startIndex)
            // Numero di processori disponibili.
            let processorCount = NSProcessInfo.processInfo().processorCount
            // Numero intero di operazioni per processore.
            let step = rangeLength / processorCount
            // Eventuale resto intero da aggiungere al thread finale.
            let reminder = rangeLength % processorCount
            
            // Creo la coda che eseguirà le operazioni in multi-thread.
            let operationQueue = NSOperationQueue()
            // Imposto il numero massimo di operazioni concorrenti, tante quante il numero di processori.
            operationQueue.maxConcurrentOperationCount = processorCount
            
            // Istanzio l'array con il numero specificato di valori.
            values = [Double](count: rangeLength, repeatedValue: 0.0)
            
            // Lancio tanti processi quanti i processori:
            for i in 0 ..< processorCount
            {
                var valueRange: Range<Int> // Range dei valori da calcolare per thread.
                var arrayRange: Range<Int> // Range degli indici in cui inserire i valori calcolati per thread.
                
                // Se il thread è l'ultimo:
                if i == processorCount - 1
                {
                    // Aggiungo eventuale resto.
                    valueRange = Range<Int>(start: step * i + range.startIndex, end: step * (i + 1) + reminder + range.startIndex)
                    arrayRange = Range<Int>(start: step * i, end: step * (i + 1) + reminder)
                    
                }
                else
                {
                    // Creo i range per il calcolo di ogni singolo thread.
                    valueRange = Range<Int>(start: step * i + range.startIndex, end: step * (i + 1) + range.startIndex)
                    arrayRange = Range<Int>(start: step * i, end: step * (i + 1))
                }
                
                // Aggiungo l'operazione alla coda:
                operationQueue.addOperationWithBlock
                {
                    // Valori calcolati parziali di lunghezza spefica.
                    var partialValues = [Double](count: valueRange.endIndex - valueRange.startIndex, repeatedValue: 0.0)
                    var partialValueIndex = 0 // Indice dell'array dei valori calcolati parziali.
                    
                    // Scorro ogni valore nel range:
                    for j in valueRange
                    {
                        // Imposto il valore corrente alle incognite.
                        self.setValueForUnknowns(Double(j), unknownTokenIndexes: unknownTokenIndexes)
                        // Salvo il risultato nell'array, dopo averlo calcolato.
                        partialValues[partialValueIndex++] = self.evaluate()
                    }

                    // Sincronizzo l'inserimento dei valori.
                    objc_sync_enter(self)
                    // Inserisco i valori nell'array.
                    values.replaceRange(arrayRange, with: partialValues)
                    objc_sync_exit(self)
                }
            }
            
            // Aspetto che tutte le operazioni siano terminate.
            operationQueue.waitUntilAllOperationsAreFinished()
        }
        // Se il calcolo è in single-thread:
        else
        {
            // Istanzio l'array di valori.
            values = [Double]()
            
            // Scorro ogni valore nel range:
            for i in range
            {
                // Imposto il valore corrente alle incognite.
                self.setValueForUnknowns(Double(i), unknownTokenIndexes: unknownTokenIndexes)
                // Aggiungo all'array contenente i valori l'espressione calcolata.
                values.append(self.evaluate())
            }
        }
        
        // Ritorno i valori calcolati.
        return values
    }
    
    /// Valuta l'espressione, assegnando alle incognite i valori all'interno del range, e restituisce i risultati uno alla volta nel blocco di codice.
    ///
    /// range: valori da assegnare alle incognite.
    ///
    /// closure: blocco di codice che viene richiamato ogni qualvolta viene calcolato un nuovo valore.
    func evaluateWithClosure(range: Range<Int>, closure: ((x: Double, y: Double) -> Void))
    {
        // Valuto l'espressione in single-thread.
        self.evaluateWithClosure(range: range, async: false, closure: closure)
    }
    
    /// Valuta l'espressione, assegnando alle incognite i valori all'interno del range, e restituisce i risultati uno alla volta nel blocco di codice.
    ///
    /// range: valori da assegnare alle incognite.
    ///
    /// async: se "true" esegue la valutazione in multi-thread.
    ///
    /// closure: blocco di codice che viene richiamato ogni qualvolta viene calcolato un nuovo valore.
    func evaluateWithClosure(#range: Range<Int>, async: Bool, closure: ((x: Double, y: Double) -> Void))
    {
        // Pre-valuto la funzione finchè possibile.
        self.preEvaluate()
        
        // Se il calcolo è in multi-thread:
        if async
        {
            // Calcolo i valori nel range in multi-thread.
            let values = self.evaluate(range: range, async: true)
            var valuesIndex = 0 // Indice dell'array dei risultati.
            
            // Scorro tutti i valori:
            for x in range
            {
                // Invoco il blocco di codice con i valori calcolati.
                closure(x: Double(x), y: values[valuesIndex++])
            }
        }
        // Se il calcolo è in single-thread:
        else
        {
            // Individuo gli indici delle incognite nell'array di token postfissi.
            let unknownTokenIndexes = self.findUnknownTokenIndexes()
            
            // Scorro ogni valore nel range:
            for x in range
            {
                // Imposto il valore corrente alle incognite.
                self.setValueForUnknowns(Double(x), unknownTokenIndexes: unknownTokenIndexes)
                // Invoco il blocco di codice con i valori calcolati.
                closure(x: Double(x), y: self.evaluate())
            }
        }
    }
    
    /// Valuta l'espressione, assegnando alle incognite i valori all'interno del range, e restituisce i risultati.
    ///
    /// start: inizio del range.
    ///
    /// end: fine del range.
    ///
    /// step: incremento del range.
    ///
    /// inclusive: se 'true' la fine del range è inclusa nel range stesso.
    func evaluate(#start: Double, end: Double, step: Double, inclusive: Bool) -> [Double]
    {
        return self.evaluate(start: start, end: end, step: step, inclusive: inclusive, async: false)
    }
    
    func evaluate(#start: Double, end: Double, step: Double, inclusive: Bool, async: Bool) -> [Double]
    {
        self.preEvaluate()
        
        var unknownTokenIndexes = self.findUnknownTokenIndexes()
        var values: [Double]
        
        if async
        {
            var xValues = [Double]()
            
            for var x = start; inclusive ? x <= end : x < end; x += step
            {
                xValues.append(x)
            }
            
            let processorCount = NSProcessInfo.processInfo().processorCount
            let valueStep = xValues.count / processorCount
            let valueReminder = xValues.count % processorCount
            
            let operationQueue = NSOperationQueue()
            operationQueue.maxConcurrentOperationCount = processorCount
            
            values = [Double](count: xValues.count, repeatedValue: 0.0)
            
            for i in 0 ..< processorCount
            {
                var arrayRange: Range<Int>
                
                if i == processorCount - 1
                {
                    arrayRange = Range<Int>(start: valueStep * i, end: valueStep * (i + 1) + valueReminder)
                }
                else
                {
                    arrayRange = Range<Int>(start: valueStep * i, end: valueStep * (i + 1))
                }
                
                operationQueue.addOperationWithBlock
                {
                    var partialValues = [Double](count: arrayRange.endIndex - arrayRange.startIndex, repeatedValue: 0.0)
                    var partialValueIndex = 0
                    let xRange = xValues[arrayRange]
                    
                    for x in xRange
                    {
                        self.setValueForUnknowns(x, unknownTokenIndexes: unknownTokenIndexes)
                        partialValues[partialValueIndex++] = self.evaluate()
                    }
                    
                    
                    objc_sync_enter(self)
                    values.replaceRange(arrayRange, with: partialValues)
                    objc_sync_exit(self)
                }
            }
            
            operationQueue.waitUntilAllOperationsAreFinished()
        }
        else
        {
            values = [Double]()
            
            for var x = start; inclusive ? x <= end : x < end; x += step
            {
                self.setValueForUnknowns(x, unknownTokenIndexes: unknownTokenIndexes)
                values.append(self.evaluate())
            }
        }
        
        return values
    }
    
    func evaluateWithClosure(#start: Double, end: Double, step: Double, inclusive: Bool, closure: ((x: Double, y: Double) -> Void))
    {
        self.evaluateWithClosure(start: start, end: end, step: step, inclusive: inclusive, async: false, closure: closure)
    }
    
    func evaluateWithClosure(#start: Double, end: Double, step: Double, inclusive: Bool, async: Bool, closure: ((x: Double, y: Double) -> Void))
    {
        self.preEvaluate()
        
        if async
        {
            let values = self.evaluate(start: start, end: end, step: step, inclusive: inclusive, async: true)
            var valueIndex = 0
            
            for var x = start; inclusive ? x <= end : x < end; x += step
            {
                closure(x: x, y: values[valueIndex++])
            }
        }
        else
        {
            let unknownTokenIndexes = self.findUnknownTokenIndexes()
            
            for var x = start; inclusive ? x <= end : x < end; x += step
            {
                self.setValueForUnknowns(x, unknownTokenIndexes: unknownTokenIndexes)
                closure(x: x, y: self.evaluate())
            }
        }
    }
}