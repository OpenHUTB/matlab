classdef CandidateInterface<systemcomposer.xmi.CandidateElement

    properties
        Name="";
        CreatedFrom;

        Elements=[];

        ReferencingArchPorts=[];

        Direction="unset";

        DerivedInInterface=[]
        DerivedOutInterface=[]

        BuildName;

        Valid=true;
        InvalidReason="";

        ZCHandle=[]
    end

    methods
        function this=CandidateInterface(name,extID,createdFrom)
            this@systemcomposer.xmi.CandidateElement(extID);
            this.Name=name;
            this.CreatedFrom=createdFrom;
        end

        function addElement(this,elemName,extID,elemDir,elemTypeName,elemType,elemDim)
            thisElem.Name=elemName;
            thisElem.ExtElementID=extID;
            thisElem.Direction=elemDir;
            thisElem.TypeName=elemTypeName;
            thisElem.Type=elemType;
            thisElem.Dim=elemDim;
            this.Elements=[this.Elements,thisElem];
        end

        function addReferencingArchPort(this,refPort)
            this.ReferencingArchPorts=[this.ReferencingArchPorts,refPort];
        end

        function b=doBuild(this)
            b=this.Valid&&isempty(this.DerivedInInterface);
        end

        function setDirectionAndSplitBidirectional(this,doSplit)

            intfDirConsistent=true;
            intfDir="unset";
            for k=1:length(this.Elements)
                if intfDir=="unset"
                    intfDir=this.Elements(k).Direction;
                elseif intfDir~=this.Elements(k).Direction
                    intfDirConsistent=false;
                end
            end

            if intfDirConsistent&&intfDir~="inout"
                if intfDir=="unset"

                    intfDir="in";
                end
                this.Direction=intfDir;
            else
                if~doSplit
                    this.Direction="inout";
                    this.setInvalid("Bidirectional interfaces not supported");
                else
                    this.DerivedInInterface=...
                    systemcomposer.xmi.CandidateInterface(...
                    this.Name+"In",this.ExtElementID+"In",...
                    this.CreatedFrom);
                    this.DerivedInInterface.Direction="in";

                    this.DerivedOutInterface=...
                    systemcomposer.xmi.CandidateInterface(...
                    this.Name+"Out",this.ExtElementID+"Out",...
                    this.CreatedFrom);
                    this.DerivedOutInterface.Direction="out";

                    for k=1:length(this.Elements)
                        thisElem=this.Elements(k);
                        if thisElem.Direction=="in"
                            this.DerivedInInterface.addElement(...
                            thisElem.Name,...
                            thisElem.ExtElementID+"In","in",...
                            thisElem.TypeName,thisElem.Type,thisElem.Dim);
                        elseif thisElem.Direction=="out"
                            this.DerivedOutInterface.addElement(...
                            thisElem.Name,...
                            thisElem.ExtElementID+"Out","out",...
                            thisElem.TypeName,thisElem.Type,thisElem.Dim);
                        else
                            assert(thisElem.Direction=="inout");
                            this.DerivedInInterface.addElement(...
                            thisElem.Name,...
                            thisElem.ExtElementID+"In","in",...
                            thisElem.TypeName,thisElem.Type,thisElem.Dim);
                            this.DerivedOutInterface.addElement(...
                            thisElem.Name,...
                            thisElem.ExtElementID+"Out","out",...
                            thisElem.TypeName,thisElem.Type,thisElem.Dim);
                        end
                    end

                end
            end
        end

        function setInvalid(this,invalidReason)
            this.Valid=false;
            this.InvalidReason=invalidReason;
        end

        function buildZCInterface(this,builder)
            if isempty(this.ZCHandle)
                intf=builder.createInterface(this.ExtElementID,...
                this.BuildName);
                this.ZCHandle=intf;
                intf.ExternalUID=this.ExtElementID;
                for k=1:length(this.Elements)
                    thisElem=this.Elements(k);

                    tName='double';
                    isBus=false;
                    if contains(thisElem.TypeName,"Bus:")
                        tName=char("Bus: "+thisElem.Type.BuildName);
                        isBus=true;
                    elseif contains(thisElem.TypeName,"Enumeration")
                        tName=['Enum:',char(thisElem.Type.BuildName)];
                    elseif contains(thisElem.TypeName,"Dtype:")
                        dtypeName=extractAfter(thisElem.TypeName,"Dtype:");
                        if isKey(builder.DatatypeMapping,dtypeName)
                            tName=char(builder.DatatypeMapping(dtypeName));
                        else
                            if contains(dtypeName,'Bool','IgnoreCase',true)
                                tName='boolean';
                            elseif contains(dtypeName,'Int','IgnoreCase',true)||...
                                contains(dtypeName,'Natural','IgnoreCase',true)
                                tName='int32';
                            elseif contains(dtypeName,'Real','IgnoreCase',true)
                                tName='double';
                            elseif contains(dtypeName,'string','IgnoreCase',true)
                                tName='string';
                            end
                        end
                    end
                    if isBus
                        iElem=intf.addElement(...
                        char(builder.makeValidName(thisElem.Name)),...
                        'Type',tName);
                        iElem.ExternalUID=thisElem.ExtElementID;
                    else
                        dVal=1;
                        if~isinf(thisElem.Dim)&&thisElem.Dim>0
                            dVal=thisElem.Dim;
                        end

                        iElem=intf.addElement(...
                        char(builder.makeValidName(thisElem.Name)),...
                        'Type',tName,'Dimensions',int2str(dVal));
                        iElem.ExternalUID=thisElem.ExtElementID;
                    end
                end
            end
        end

        function print(this,printer)
            pStr=this.Name+": ";
            for k=1:length(this.Elements)
                if k>1
                    pStr=pStr+", ";
                end
                pStr=pStr+this.Elements(k).Name+...
                "["+this.Elements(k).Direction+"]"+...
                "["+this.Elements(k).TypeName+"]";
            end
            printer.print("   Interface =  "+pStr);
        end
    end
end
