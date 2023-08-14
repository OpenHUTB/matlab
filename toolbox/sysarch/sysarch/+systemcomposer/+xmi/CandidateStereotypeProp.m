classdef CandidateStereotypeProp<systemcomposer.xmi.CandidateElement

    properties
Name
Datatype
        FinalName=""

        Owner=[]

        ZCHandle=[];
    end

    methods
        function this=CandidateStereotypeProp(extElemID,pName,pDtype,owner)
            this@systemcomposer.xmi.CandidateElement(extElemID);

            this.Name=pName;
            this.Datatype=pDtype;
            this.Owner=owner;
        end

        function trackAppliedElement(this,elem)
            this.AppliedElements=[this.AppliedElements,elem];
        end

        function print(this,printer)
            printer.print("Prop: "+this.Name+...
            "<"+this.Datatype+"> ["+this.FinalName+"]");
        end
    end
end
