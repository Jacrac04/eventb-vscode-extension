// Event-B Machine file grammar
// ==========================

Machine 
	= _ "machine" __ name:Name _ content:MachineContent _ "end" _ {
    	return {name:name, content: content};
    }
    
MachineContent
	= refines:Refines? _ sees:Sees? _ 
	variables:Variables? _
	invariants:Invariants? _ events:Events?
    {
    	return {refines: refines, sees: sees, variables: variables, invariants: invariants, events: events};
    }

Variables
	= "variables"  name:(_ Name)* "\n" {
    	return name.map(elem => elem[1]);
    }
    
Refines
	= "refines" _ target:Name {
    	return {target: target}
    }
    
Sees
	= "sees" _ target:Name {
    	return {target: target}
    }
    
Invariants
	= "invariants" "\n" _ line:Predicate+ {
    	return line;
    }


Events
	= "events" "\n" _ events:(Event*) { return events; }
    
Event
	= convergence:("anticipated" / "convergent")? __ "event" __ name:Name __ refine:(("extends" / "refines") __ Name)?  "\n" _ 
    	any:Any? _
        where:Where? _ 
		withValue:With? _
        then:Then _
      "end" "\n" _ {
      	let target, extended;
        if (refine) {
        	target = refine[2];
            extended = refine[0] === "extends"
        }
    	return {name:name, target: target, convergence: convergence, extended: !!extended, any: any, where: where, with:withValue, then:then }
    }

// event blocks

Any
	= "any" name:(_ Name)+ "\n" _ {
    	return name.map(elem => elem[1]);
    }
    
Where
	= "where" _ predicate:Predicate+ {
    	return predicate;
    }

With
	= "with" _ line:Line+ {
    	return line;
    }
    
Then
	= "then" _ line:Line+ {
    	return line;
   	}
    
// Base block
    
Predicate
	= theorem:"theorem"? __ line:Line {
    	return { label: line.label, predicate: line.assignment, theorem: !!theorem}
    }

Line
	=  "@" label:Name __ assignment:Expression _ {
    	return { label: label, assignment: assignment }
    }
    
Comment
	= $("//" [^\n]*)
    
Expression
    = value:$([^\n]+) [\n] { return value; }

Name //avoid reserved keywords
  = !"end" !"invariants" !"events" !"where" !"then" !"with" !"event" name:$([a-zA-Z_] [a-zA-Z_0-9]*) {
  	return name;
  }
  
__ "strict whitespace"
	= [ \t]*
  
_ "whitespace"
  = [ \t\n\r]*