classdef CandidateStereotype<systemcomposer.xmi.CandidateElement

    properties
Name
PackagePath

        SuperClassExtElementID=""

        Profile=[];
        SuperClass=[];

        Properties=[];
        NumProps=0;
        Uniqued=false;
        PropNamesInScope=[];

        AppliedElements=[];

        ZCHandle=[];
    end

    methods
        function this=CandidateStereotype(extElemID,sName,prof,pPath,scExtID)
            this@systemcomposer.xmi.CandidateElement(extElemID);

            this.Name=sName;
            this.PackagePath=pPath;
            this.Profile=prof;
            this.SuperClassExtElementID=scExtID;
        end

        function addProperty(this,pName,pDtype)
            this.NumProps=this.NumProps+1;
            newProp=systemcomposer.xmi.CandidateStereotypeProp(...
            this.ExtElementID+"Prop"+this.NumProps,...
            pName,pDtype,this);
            this.Properties=[this.Properties,newProp];
        end

        function prop=findProperty(this,pName)
            prop=[];
            for k=1:length(this.Properties)
                if strcmp(this.Properties(k).Name,pName)
                    prop=this.Properties(k);
                    break;
                end
            end
            if isempty(prop)&&~isempty(this.SuperClass)
                prop=findProperty(this.SuperClass,pName);
            end
        end

        function link(this)
            if this.SuperClassExtElementID~=""
                sClass=systemcomposer.xmi.CandidateElement.idMap(...
                "lookup",this.SuperClassExtElementID);
                this.SuperClass=sClass;
            end
        end

        function trackAppliedElement(this,elem)
            this.AppliedElements=[this.AppliedElements,elem];
        end

        function uniquePropNames(this,builder)
            if~isempty(this.SuperClass)
                if~this.SuperClass.Uniqued
                    this.SuperClass.uniquePropNames(builder);
                end
                sClassPropNames=this.SuperClass.PropNamesInScope;
            else
                sClassPropNames=[];
            end
            propNames=[];
            for k=1:length(this.Properties)
                thisName=builder.makeValidName(this.Properties(k).Name);
                thisName=matlab.lang.makeUniqueStrings(...
                [sClassPropNames,thisName],...
                [false(1,length(sClassPropNames)),true]);
                thisName=thisName(end);
                this.Properties(k).FinalName=thisName;
                propNames=[propNames,thisName];%#ok
            end

            this.PropNamesInScope=[sClassPropNames,propNames];
            this.Uniqued=true;
        end

        function print(this,printer)
            printer.openScope("Stereotype: "+this.Name);

            for k=1:length(this.Properties)
                this.Properties(k).print(printer);
            end

            printer.closeScope("Stereotype: "+this.Name);
        end
    end
end
