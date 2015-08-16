//
//  Parser.swift
//  Parser
//
//  Created by Alessandro on 31/07/15.
//  Copyright (c) 2015 Alessandro. All rights reserved.

//((?<![(][+-])([0-9]{1,}[.,]?(?<=[.,])[0-9]*)) numeri non unari
//(?<![(])([\+\-\*\/\^]) operatori non unari
// [(]([+-][0-9]{1,}[.,]?(?<=[.,])[0-9]*) numeri unari

import Foundation
import Cocoa

/// Identifica il tipo di token all'interno di una stringa.
enum TokenType: String
{
    /// Token relativo ad un numero.
    case Number = "Number"
    
    /// Token relativo ad una costante matematica.
    case Constant = "Constant"
    
    /// Token relativo ad un operatore matematico.
    case Operator = "Operator"
    
    /// Token relativo alla parentesi di apertura.
    case LeftBracket = "("
    
    /// Token relativo alla parentesi di chiusura.
    case RightBracket = ")"
    
    /// Token relativo ad una incognita.
    case Unknown = "Unknown"
}

/// Rappresenta un token all'interno di una stringa.
class Token: Printable
{
    /// Tipo di token.
    var type: TokenType
    
    /// Posizione del token all'interno della stringa.
    var range: NSRange
    
    /// Token in formato stringa.
    var string: String
    
    /// Valore del token, il quale è usato solo per costanti, numeri e incognite.
    var value: Double?
    
    /// Restituisce una descrizione del token in formato stringa "human-readable".
    var description: String
    {
        return "Type: \(self.type.rawValue), Range: \(NSStringFromRange(self.range)), String: \(self.string), Value: \(self.value)"
    }
    
    /// Crea il token con i parametri necessari.
    init(type: TokenType, range: NSRange, string: String, value: Double?)
    {
        // Assegno i vari parametri ai campi di classe.
        self.type = type
        self.range = range
        self.string = string
        self.value = value
    }
}

struct ParserError
{
    static let parserDomain = "ParserDomain"

    static let unbalancedBracketsErrorCode = 1
}

/// Parser di stringa che si occupa di individuare i vari token all'interno della stringa e di costruire l'espressione
/// sottoforma di insieme di token.
class Parser
{
    private var error: NSErrorPointer // Errore in caso di eccezioni.
    private var expression: String // Espressione da convertire in token.
    
    /// Pattern per l'espressioni regolari.
    private var numberPattern: String // Pattern che identifica un numero, eventualmente con virgola.
    private var unaryNumberPattern: String
    private var operatorPattern: String // Pattern che identifica gli operatori +, -, *, /, ^.
    private var leftBracketPattern: String // Pattern che indentifica la parentesi di apertura (.
    private var rightBracketPattern: String // Pattern che identifica la parentesi di chiusura ).
    private var constantPattern: String // Pattern che identifica le costanti pi greco ed e di nepero.
    private var functionPattern: String // Pattern che identifica una funzione matematica.
    private var unknownPattern: String // Pattern che identifica una incognita matematica.
    
    private var functionsNames: [String] // Array contenente i nomi delle funzioni matematiche.
    
    /// Crea il parser assegnando l'espressione e l'errore per eventuali eccezioni.
    ///
    /// expression: espressione da convertire.
    ///
    /// error: puntatore all'errore.
    init(expression: String, error: NSErrorPointer)
    {
        // Assegno l'espressione e il puntatore all'errore.
        self.expression = expression
        self.error = error
        
        // Istanzio i vari pattern per le espressioni regolari.
        self.numberPattern = "(?<![(][+-])(?<![.])([0-9]{1,}[.,]?[0-9]*)" //"([0-9]{1,}[.,]?[0-9]*)"
        self.unaryNumberPattern = "(?<=[(])([+-][0-9]{1,}[.,]?[0-9]*)"
        self.operatorPattern = "(?<![(])([\\+\\-\\*\\/\\^])" //([\\+\\-\\*\\/\\^])"
        self.leftBracketPattern = "(\\()"
        self.rightBracketPattern = "(\\))"
        self.constantPattern = "(pi|e)"
        self.functionPattern = "($$)"
        self.unknownPattern = "x"
        
        // Istanzio l'array con i nomi delle funzioni matematiche.
        self.functionsNames = ["sin", "cos", "tan", "abs", "exp", "ln", "log", "sqrt"]
    }

    /// Eseguo il parsing e costruisco l'array di token relativo all'espressione.
    func parse() -> [Token]
    {
        //Elimino gli spazi e converto l'espressione in minuscola.
        self.expression = self.expression.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        
        //Controllo se le parentesi sono bilanciate.
        if self.balancedBrackets()
        {
            //Nel caso non vi siano parentesi le aggiungo all'inizio e alla fine.
            if !(self.expression.hasPrefix("(") && self.expression.hasSuffix(")"))
            {
                self.expression.splice("(", atIndex: self.expression.startIndex)
                self.expression.splice(")", atIndex: self.expression.endIndex)
            }
        }
        else
        {
            //Qualora non vi siano le parentesi bilanciate lancio l'errore.
            self.error.memory = NSError(domain: ParserError.parserDomain, code: ParserError.unbalancedBracketsErrorCode, userInfo: self.userInfoErrorDictionary("Unbalanced brackets in the expression.", failureReason: "Missing some opening or closing brackets.", recoverySuggestion: "Please check if the expression is correct and contains all the brackets."))
        }
        
        var tokens = [Token]() // Array contenente i token.
        
        // Cerco ed inserisco i vari token nell'array.
        tokens += self.find(self.expression, pattern: self.leftBracketPattern, type: .LeftBracket)
        tokens += self.find(self.expression, pattern: self.rightBracketPattern, type: .RightBracket)
        tokens += self.find(self.expression, pattern: self.numberPattern, type: .Number)
        tokens += self.find(self.expression, pattern: self.unaryNumberPattern, type: .Number)
        tokens += self.find(self.expression, pattern: self.operatorPattern, type: .Operator)
        tokens += self.find(self.expression, pattern: self.constantPattern, type: .Constant)
        tokens += self.find(self.expression, pattern: self.unknownPattern, type: .Unknown)
        
        // Scorro tra le varie funzioni matematiche:
        for functionName in self.functionsNames
        {
            // Inserisco nell'array dei token la presenza delle varie funzioni matematiche.
            tokens += self.find(self.expression, pattern: self.functionPattern.stringByReplacingOccurrencesOfString("$$", withString: functionName, options: .LiteralSearch, range: nil), type: .Operator)
        }
        
        //Ordino i token in base alla loro posizione nella stringa.
        tokens.sort{$0.range.location < $1.range.location}

        return tokens
    }
    
    private func userInfoErrorDictionary(errorDescription: String, failureReason: String, recoverySuggestion: String) -> [NSObject : AnyObject]
    {
        //Creo il dizionario contenete le descrizioni dell'errore.
        var userInfo = [NSObject : AnyObject]()
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
        userInfo[NSLocalizedRecoveryOptionsErrorKey] = nil
        
        return userInfo
    }
    
    /// Controlla se le parentesi all'interno dell'espressione siano bilanciate.
    private func balancedBrackets() -> Bool
    {
        var regexError: NSError? // Errore relativo all'espressione regolare.
        // Espressione regolare relativa alla ricerca della parentesi di apertura.
        let leftBracketRegex = NSRegularExpression(pattern: self.leftBracketPattern, options: .allZeros, error: &regexError)
        
        // Se non ci sono errori:
        if regexError == nil
        {
            // Espressione regolare relativa alla ricerca della parentesi di chiusura.
            let rightBracketRegex = NSRegularExpression(pattern: self.rightBracketPattern, options: .allZeros, error: &regexError)
            
            // Se non ci sono errori:
            if regexError == nil
            {
                // Range contenente la posizione di ricerca, che corrisponde all'intera stringa.
                let range = NSMakeRange(0, count(expression))
                
                // Controllo se il numero di parentesi di apertura equivale al numero di parentesi di chiusura.
                return leftBracketRegex!.numberOfMatchesInString(self.expression, options: .allZeros, range: range) == rightBracketRegex!.numberOfMatchesInString(expression, options: .allZeros, range: range)
            }
        }
        
        self.error.memory = regexError
        return false
    }
    
    /// Restituisce il valore di una costante matematica.
    ///
    /// constant: costante da valorizzare.
    private func valueForCostant(constant: String) -> Double
    {
        // Costante da valorizzare:
        switch constant
        {
        case "pi": // Pi greco.
            return M_PI
        case "e": // E di nepero.
            return M_E
        default: // Restituisco un numero non esistente in caso di non riscontro.
            return Double.NaN
        }
    }

    /// Ricerca il pattern all'interno dell'espressione e assegna i relativi token.
    ///
    /// expression: espressione in cui ricercare il pattern attraverso l'espressioni regolari.
    ///
    /// pattern: pattern da applicare all'espressione.
    ///
    /// type: tipo di token da associare al pattern cercato.
    private func find(expression: String, pattern: String, type: TokenType) -> [Token]
    {
        var regexError: NSError? // Errore relativo all'espressione regolare.
        // Espressione regolare relativa alla ricerca del pattern generico.
        let regex = NSRegularExpression(pattern: pattern, options: .allZeros, error: &regexError)
        
        // Se non ci sono errori:
        if regexError == nil
        {
            // Ottengo i riscontri trovati nell'espressione.
            let matches = regex!.matchesInString(expression, options: .allZeros, range: NSMakeRange(0, count(expression)))
            
            // Istanzio l'array che conterrà i token relativi a questo pattern.
            var tokens = [Token]()
            
            // Scorro ogni riscontro:
            for match in matches
            {
                let matchRange = match.range! // Range del riscontro all'interno dell'espressione.
                
                // Valore in formato stringa del riscontro.
                let matchString = self.expression.substringWithRange(advance(self.expression.startIndex, matchRange.location) ..< advance(self.expression.startIndex, matchRange.location + matchRange.length))
                
                // Se i token cercati sono dei numeri assegno converto la stringa in numero.
                var matchValue: Double? = type == .Number ? atof(matchString) : nil

                // Se i token cercati sono delle costanti, cerco il valore relativo alle costanti.
                if type == .Constant
                {
                    matchValue = self.valueForCostant(matchString)
                }
                
                // Aggiungo il token trovato.
                tokens.append(Token(type: type, range: matchRange, string: matchString, value: matchValue))
            }
            
            // Restituisco i token trovati.
            return tokens
        }
        
        self.error.memory = regexError
        return []
    }
}