classdef CandidatePort<systemcomposer.xmi.CandidateElement

    properties
ParentArch

Name
        BuildName=""
IsConjugated

InterfaceExtElementID
Interface
        Connectors=[];

        ComputedDir="unset";

        Valid=true;
        InvalidReason="";

        Replaced=false;
        Replacements=[];
        Derived=false;

        ZCHandle=[];
    end

    methods
        function this=CandidatePort(parArch,portName,extID,...
            isConj,intfID,intf,isDerived)
            this@systemcomposer.xmi.CandidateElement(extID);
            this.ParentArch=parArch;
            this.Name=portName;

            this.IsConjugated=isConj;
            this.InterfaceExtElementID=intfID;
            this.Interface=intf;
            this.Derived=isDerived;
        end

        function addConnector(this,conn)
            this.Connectors=[this.Connectors,conn];
        end

        function setInvalid(this,invalidReason)
            this.Valid=false;
            this.InvalidReason=invalidReason;
        end

        function setReplacements(this,replacements)
            this.Replaced=true;
            this.Replacements=replacements;
        end

        function setComputedDir(this)
            if~isempty(this.Interface)
                intfDir=this.Interface.Direction;
                compDir=intfDir;
                if this.IsConjugated
                    if intfDir=="in"
                        compDir="out";
                    elseif intfDir=="out"
                        compDir="in";
                    end
                end
                if this.Valid&&~this.Interface.Valid
                    this.setInvalid("Interface not valid");
                end
            else
                if this.IsConjugated
                    compDir="out";
                else
                    compDir="in";
                end
            end
            this.ComputedDir=compDir;
            assert(~this.Valid||this.Replaced||compDir=="in"||compDir=="out");
        end

        function fixFanInConnectors(this)
            if this.ComputedDir=="out"&&length(this.Connectors)>1
                validConns=[];
                for k=1:length(this.Connectors)
                    if this.Connectors(k).Valid&&~this.Connectors(k).Replaced
                        validConns=[validConns,this.Connectors(k)];%#ok
                    end
                end
                if length(validConns)>1
                    this.ParentArch.addAdapter(validConns,[],this);
                end
            end
        end

        function print(this,printer)
            printer.print("Port: [Valid="+this.Valid+" "+...
            this.InvalidReason+"] "+...
            "[Replaced="+this.Replaced+"]"+...
            "[Derived="+this.Derived+"]"+...
            this.Name+"[Conj: "+...
            this.IsConjugated+"]"+...
            "[ComputedDir: "+this.ComputedDir+"]");
        end
    end
end
