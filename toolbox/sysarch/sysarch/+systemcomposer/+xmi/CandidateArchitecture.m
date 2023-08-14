classdef CandidateArchitecture<systemcomposer.xmi.CandidateElement

    properties
        Name="";

        ParentPackageExtElementID;
        GeneralizationExtElementIDs;

        CompMapFromExtElementID;
        PortMapFromExtElementID;

        ReferencingComps=[];
        ChildComponents=[];
        ChildConnectors=[];

        Parameters=[];

        ParentPackage=[];

        GenMerged=false;
        Build=true;

        Generalizations=[]
        Specializations=[]

        ZCHandle=[]

        IsInlined=false;
        Visited=false;
        Derived=false;
        BuildAsSimulink=false;
        SimulinkModelName="";

        NonSiblingDelegatesAdded=[];

        PortNameGeneratedIdx=1;

        DerivedConnectorIdx=1;
        DerivedPortIdx=1;
        DerivedArchIdx=1;
        DerivedCompIdx=1;

        DefaultWidthOfReferencingComp=-1;
    end

    methods(Static,Access=private)

        function[reached,pArchs1,pComps1]=recMarkHier(arch,endArch,pArchs,pComps)
            pArchs1=pArchs;
            pComps1=pComps;
            reached=false;
            if arch==endArch
                reached=true;
            else
                rComps=arch.ReferencingComps;
                for k=1:length(rComps)
                    [reached,pArchs1,pComps1]=...
                    systemcomposer.xmi.CandidateArchitecture.recMarkHier(...
                    rComps(k).ParentArchitecture,endArch,pArchs,pComps);
                    if reached
                        pArchs1=[pArchs1,arch];%#ok
                        pComps1=[pComps1,rComps(k)];%#ok
                        break;
                    end
                end
            end
        end

        function[pArchs,pComps]=findArchHierPath(comp,endArch)

            [~,pArchs,pComps]=systemcomposer.xmi.CandidateArchitecture.recMarkHier(...
            comp.ParentArchitecture,endArch,[],[]);
        end


        function[pArchs,notUnique]=findUniqueParentArchHier(comp,endArch)
            notUnique=false;
            pArchs=[];
            pArch=comp.ParentArchitecture;
            while pArch~=endArch
                pArchs=[pArchs,pArch];%#ok
                rComps=pArch.ReferencingComps;
                if length(rComps)>1
                    notUnique=true;
                    pArchs=[];
                    return;
                elseif isempty(rComps)
                    break;
                else
                    pArch=rComps.ParentArchitecture;
                end
            end
            if pArch~=endArch
                notUnique=true;
                pArchs=[];
            end
        end

        function newConn=addDerivedConnector(thisArch,comp1,aPort1,...
            comp2,aPort2)

            comp1ID="";
            if~isempty(comp1)
                comp1ID=comp1.ExtElementID;
            end

            comp2ID="";
            if~isempty(comp2)
                comp2ID=comp2.ExtElementID;
            end

            newConn=thisArch.addChildConnector(...
            thisArch.ExtElementID+"DerivedConn"+thisArch.DerivedConnectorIdx,...
            comp1ID,aPort1.ExtElementID,...
            aPort1.ParentArch.ExtElementID,...
            comp2ID,aPort2.ExtElementID,...
            aPort2.ParentArch.ExtElementID,true);
            thisArch.DerivedConnectorIdx=thisArch.DerivedConnectorIdx+1;

            if isempty(comp1)
                aPort1.addConnector(newConn);
            else
                comp1.addConnector(aPort1,newConn);
            end
            if isempty(comp2)
                aPort2.addConnector(newConn);
            else
                comp2.addConnector(aPort2,newConn);
            end

            newConn.setEndComps(aPort1,comp1,aPort1.ParentArch,...
            aPort2,comp2,aPort2.ParentArch);


            newConn.EndsChecked=true;
        end

    end

    methods(Access=private)

        function mergeInGeneralization(this,otherArch)


            otherArchComps=otherArch.CompMapFromExtElementID.values;
            for k=1:length(otherArchComps)
                this.addChildComponent(...
                otherArchComps{k}.Name,...
                otherArchComps{k}.ExtElementID,...
                otherArchComps{k}.ReferenceArchExtElementID);
            end

            otherArchPorts=otherArch.PortMapFromExtElementID.values;
            for k=1:length(otherArchPorts)
                otherPort=otherArchPorts{k};
                this.addPort(...
                otherPort.Name,otherPort.IsConjugated,...
                otherPort.ExtElementID,otherPort.InterfaceExtElementID,...
                otherPort.Interface,true);
            end

            otherArchConns=otherArch.ChildConnectors;
            for k=1:length(otherArchConns)
                otherConn=otherArchConns(k);
                this.addChildConnector(...
                otherConn.ExtElementID,...
                otherConn.End1CompExtElementID,...
                otherConn.End1RefPortExtElementID,...
                otherConn.End1RefPortArchExtElementID,...
                otherConn.End2CompExtElementID,...
                otherConn.End2RefPortExtElementID,...
                otherConn.End2RefPortArchExtElementID,true);
            end

            this.Generalizations=[this.Generalizations,otherArch];
            otherArch.Specializations=...
            [otherArch.Specializations,this];
        end


        function[endComp,endAPort,nonSibling]=...
            checkConnectorEnd(this,thisConn,endCompID,endPortID)

            endComp=[];
            nonSibling=false;
            if endCompID==""

                archPort=this.PortMapFromExtElementID(endPortID);
                archPort.addConnector(thisConn);
                endAPort=archPort;
            else
                endComp=this.findChildComponent(endCompID);
                endAPort=...
                endComp.ReferenceArch.PortMapFromExtElementID(endPortID);
                if endComp.ParentArchitecture~=this

                    nonSibling=true;
                else
                    endComp.addConnector(endAPort,thisConn);
                end
            end
        end

        function handleNonSiblingConnector(this,thisConn)

            end1APort=thisConn.End1APort;
            end1Comp=thisConn.End1Comp;
            end2APort=thisConn.End2APort;
            end2Comp=thisConn.End2Comp;

            end1Archs=[];
            end1Comps=[];
            if~isempty(end1Comp)
                [end1Archs,end1Comps]=this.findArchHierPath(end1Comp,this);
            end
            end2Archs=[];
            end2Comps=[];
            if~isempty(end2Comp)
                [end2Archs,end2Comps]=this.findArchHierPath(end2Comp,this);
            end

            repConns=[];

            thisComp=end1Comp;
            thisAPort=end1APort;
            for k=1:length(end1Archs)
                thisArch=end1Archs(k);

                pInfo=this.isPortAddedForNonSibling(thisComp,thisAPort);

                if isempty(pInfo)

                    newPort=thisArch.addPort(...
                    thisAPort.Name,...
                    thisAPort.IsConjugated,...
                    thisArch.ExtElementID+"NestedConnPort"+thisArch.DerivedPortIdx,...
                    "",thisAPort.Interface,true);
                    newPort.setComputedDir();
                    thisArch.DerivedPortIdx=thisArch.DerivedPortIdx+1;


                    repConn=this.addDerivedConnector(...
                    thisArch,thisComp,thisAPort,...
                    [],newPort);
                    repConns=[repConns,repConn];%#ok

                    this.trackPortAddedForNonSibling(thisComp,thisAPort,newPort);
                else
                    newPort=pInfo.AddedPort;
                end


                thisComp=end1Comps(k);
                thisAPort=newPort;
            end
            finalEnd1Comp=thisComp;
            finalEnd1APort=thisAPort;

            thisComp=end2Comp;
            thisAPort=end2APort;
            for k=1:length(end2Archs)
                thisArch=end2Archs(k);

                pInfo=this.isPortAddedForNonSibling(thisComp,thisAPort);

                if isempty(pInfo)

                    newPort=thisArch.addPort(...
                    thisAPort.Name,...
                    thisAPort.IsConjugated,...
                    thisArch.ExtElementID+"NestedConnPort"+thisArch.DerivedPortIdx,...
                    "",thisAPort.Interface,true);
                    thisArch.DerivedPortIdx=thisArch.DerivedPortIdx+1;
                    newPort.setComputedDir();


                    repConn=this.addDerivedConnector(...
                    thisArch,thisComp,thisAPort,...
                    [],newPort);
                    repConns=[repConns,repConn];%#ok

                    this.trackPortAddedForNonSibling(thisComp,thisAPort,newPort);
                else
                    newPort=pInfo.AddedPort;
                end


                thisComp=end2Comps(k);
                thisAPort=newPort;
            end
            finalEnd2Comp=thisComp;
            finalEnd2APort=thisAPort;


            repConn=this.addDerivedConnector(...
            this,finalEnd1Comp,finalEnd1APort,...
            finalEnd2Comp,finalEnd2APort);
            repConns=[repConns,repConn];

            thisConn.setReplacements(repConns);
        end

        function cComp=findChildComponent(this,cID)
            if isKey(this.CompMapFromExtElementID,cID)
                cComp=this.CompMapFromExtElementID(cID);
            else
                for k=1:length(this.ChildComponents)
                    gcComp=this.ChildComponents(k);
                    if gcComp.Valid
                        cComp=gcComp.ReferenceArch.findChildComponent(cID);
                        if~isempty(cComp)
                            return;
                        end
                    end
                end
                cComp=[];
            end
        end

        function dWidth=getDefaultCompWidth(this)
            if this.DefaultWidthOfReferencingComp==-1
                if this.BuildAsSimulink

                    set_param(this.SimulinkModelName,'HasSystemComposerArchInfo','on');
                    this.ZCHandle=get_param(this.SimulinkModelName,...
                    'SystemComposerArchitecture');
                    set_param(this.SimulinkModelName,'HasSystemComposerArchInfo','off');
                end
                allPorts=this.ZCHandle.Ports;
                maxPortNameLenIn=0;
                maxPortNameLenOut=0;

                for k=1:length(allPorts)
                    thisPort=allPorts(k);
                    pNameLen=strlength(string(thisPort.Name));
                    if thisPort.Direction==systemcomposer.arch.PortDirection.Input
                        if pNameLen>maxPortNameLenIn
                            maxPortNameLenIn=pNameLen;
                        end
                    end
                    if thisPort.Direction==systemcomposer.arch.PortDirection.Output
                        if pNameLen>maxPortNameLenOut
                            maxPortNameLenOut=pNameLen;
                        end
                    end
                end
                this.DefaultWidthOfReferencingComp=...
                (maxPortNameLenIn+maxPortNameLenOut)*10+20;
            end

            dWidth=this.DefaultWidthOfReferencingComp;
        end

        function trackPortAddedForNonSibling(this,comp,aPort,newPort)
            pInfo.Component=comp;
            pInfo.ArchPort=aPort;
            pInfo.AddedPort=newPort;
            this.NonSiblingDelegatesAdded=[this.NonSiblingDelegatesAdded,pInfo];
        end

        function fnd=isPortAddedForNonSibling(this,comp,aPort)
            fnd=[];
            pInfos=this.NonSiblingDelegatesAdded;

            for k=1:length(pInfos)
                pInfo=pInfos(k);
                if isempty(comp)
                    if isempty(pInfo.Component)
                        if pInfo.ArchPort==aPort
                            fnd=pInfo;
                            break;
                        end
                    end
                elseif~isempty(pInfo.Component)
                    if comp==pInfo.Component&&aPort==pInfo.ArchPort
                        fnd=pInfo;
                        break;
                    end
                end
            end
        end

    end

    methods
        function this=CandidateArchitecture(name,extID,...
            parPackageExtID,genIDs)
            this@systemcomposer.xmi.CandidateElement(extID);

            this.Name=name;
            this.ParentPackageExtElementID=parPackageExtID;
            this.GeneralizationExtElementIDs=genIDs;

            this.PortMapFromExtElementID=containers.Map;
            this.CompMapFromExtElementID=containers.Map;

        end

        function newPort=addPort(this,portName,isConjugated,extID,...
            intfID,intf,isDerived)
            if portName==""
                portName="APort"+this.PortNameGeneratedIdx;
                this.PortNameGeneratedIdx=this.PortNameGeneratedIdx+1;
            end

            if~isempty(intf)
                intfID=intf.ExtElementID;
            end

            newPort=systemcomposer.xmi.CandidatePort(...
            this,portName,extID,isConjugated,intfID,intf,isDerived);

            if~isempty(intf)
                intf.addReferencingArchPort(newPort);
            end

            this.PortMapFromExtElementID(extID)=newPort;
        end

        function pDir=getComputedPortDir(this,portID)
            pDir=this.PortMapFromExtElementID(portID).ComputedDir;
        end

        function pName=getPortName(this,portID)
            pName=this.PortMapFromExtElementID(portID).Name;
        end

        function cComp=addChildComponent(this,compName,extID,refCompID)
            cComp=systemcomposer.xmi.CandidateComponent(...
            compName,this,extID,refCompID);
            this.ChildComponents=[this.ChildComponents,cComp];

            assert(~isKey(this.CompMapFromExtElementID,extID));
            this.CompMapFromExtElementID(extID)=cComp;
        end

        function cConn=addChildConnector(...
            this,extID,end1CompID,...
            end1RefPortID,end1RefPortCompID,...
            end2CompID,end2RefPortID,end2RefPortCompID,isDerived)
            cConn=systemcomposer.xmi.CandidateConnector(...
            this,extID,end1CompID,end1RefPortID,end1RefPortCompID,...
            end2CompID,end2RefPortID,end2RefPortCompID,isDerived);
            this.ChildConnectors=[this.ChildConnectors,cConn];
        end

        function addReferencingComp(this,refComp)
            this.ReferencingComps=[this.ReferencingComps,refComp];
        end

        function addParameter(this,paramName,paramType,paramTypeName,paramDim,paramDefValue)
            newPrm.Name=string(paramName);
            newPrm.Type=paramType;
            newPrm.TypeName=paramTypeName;
            newPrm.Dim=string(paramDim);
            newPrm.DefaultValue=string(paramDefValue);
            this.Parameters=[this.Parameters,newPrm];
        end

        function mergeGeneralizations(this)
            if~this.GenMerged
                genIDs=this.GeneralizationExtElementIDs;
                for k=1:length(genIDs)
                    genArch=systemcomposer.xmi.CandidateElement.idMap(...
                    "lookup",genIDs(k));

                    if isa(genArch,'systemcomposer.xmi.CandidateArchitecture')
                        if~genArch.GenMerged
                            genArch.mergeGeneralizations();
                        end
                        this.mergeInGeneralization(genArch);
                    end
                end

                this.GenMerged=true;
            end
        end

        function linkComponentsPortsPackage(this)
            cComps=this.ChildComponents;
            for k=1:length(cComps)
                thisComp=cComps(k);
                thisCompRefArch=...
                systemcomposer.xmi.CandidateElement.idMap(...
                "lookup",thisComp.ReferenceArchExtElementID);
                thisComp.ReferenceArch=thisCompRefArch;
                thisCompRefArch.addReferencingComp(thisComp);
            end

            cPorts=this.PortMapFromExtElementID.values;
            for k=1:length(cPorts)
                thisPort=cPorts{k};
                if thisPort.InterfaceExtElementID~=""
                    thisPortIntf=...
                    systemcomposer.xmi.CandidateElement.idMap(...
                    "lookup",thisPort.InterfaceExtElementID);
                    thisPortIntf.addReferencingArchPort(thisPort);
                    thisPort.Interface=thisPortIntf;
                end
            end

            compPkg=systemcomposer.xmi.CandidateElement.idMap(...
            "lookup",this.ParentPackageExtElementID);
            compPkg.addArchitecture(this);
            this.ParentPackage=compPkg;
        end

        function setPortDirection(this,splitBidirectional)
            allPorts=this.PortMapFromExtElementID.values;

            if splitBidirectional
                for k=1:length(allPorts)
                    thisPort=allPorts{k};
                    if~isempty(thisPort.Interface)&&...
                        ~isempty(thisPort.Interface.DerivedInInterface)

                        if thisPort.IsConjugated
                            iStr="Out";
                            oStr="In";
                        else
                            iStr="In";
                            oStr="Out";
                        end

                        newPortI=this.addPort(...
                        thisPort.Name+iStr,...
                        thisPort.IsConjugated,...
                        this.ExtElementID+"BidirConnPort"+this.DerivedPortIdx,...
                        "",thisPort.Interface.DerivedInInterface,true);
                        this.DerivedPortIdx=this.DerivedPortIdx+1;

                        newPortO=this.addPort(...
                        thisPort.Name+oStr,...
                        thisPort.IsConjugated,...
                        this.ExtElementID+"BidirConnPort"+this.DerivedPortIdx,...
                        "",thisPort.Interface.DerivedOutInterface,true);
                        this.DerivedPortIdx=this.DerivedPortIdx+1;

                        thisPort.setReplacements([newPortI,newPortO]);
                    end
                end
            end


            allPorts=this.PortMapFromExtElementID.values;
            for k=1:length(allPorts)
                thisPort=allPorts{k};
                thisPort.setComputedDir();
            end
        end

        function linkAndExpandConnectors(this)

            cConns=this.ChildConnectors;
            for c=1:length(cConns)
                thisConn=cConns(c);

                if~thisConn.EndsChecked
                    [end1Comp,end1APort,nonSibling1]=...
                    this.checkConnectorEnd(...
                    thisConn,...
                    thisConn.End1CompExtElementID,...
                    thisConn.End1RefPortExtElementID);
                    [end2Comp,end2APort,nonSibling2]=...
                    this.checkConnectorEnd(...
                    thisConn,...
                    thisConn.End2CompExtElementID,...
                    thisConn.End2RefPortExtElementID);
                    thisConn.setEndComps(...
                    end1APort,end1Comp,end1APort.ParentArch,...
                    end2APort,end2Comp,end2APort.ParentArch);
                else
                    nonSibling1=false;
                    if~isempty(thisConn.End1Comp)
                        nonSibling1=thisConn.End1Comp.ParentArchitecture~=this;
                    end
                    nonSibling2=false;
                    if~isempty(thisConn.End2Comp)
                        nonSibling2=thisConn.End2Comp.ParentArchitecture~=this;
                    end
                end

                if thisConn.Valid

                    if thisConn.End1APort.Replaced||thisConn.End2APort.Replaced
                        if thisConn.End1APort.Replaced&&thisConn.End2APort.Replaced
                            newConn1=this.addDerivedConnector(...
                            this,thisConn.End1Comp,...
                            thisConn.End1APort.Replacements(1),...
                            thisConn.End2Comp,...
                            thisConn.End2APort.Replacements(1));
                            newConn2=this.addDerivedConnector(...
                            this,thisConn.End1Comp,...
                            thisConn.End1APort.Replacements(2),...
                            thisConn.End2Comp,...
                            thisConn.End2APort.Replacements(2));
                            thisConn.setReplacements([newConn1,newConn2]);

                            if newConn1.Valid&&(nonSibling1||nonSibling2)
                                this.handleNonSiblingConnector(newConn1);
                                this.handleNonSiblingConnector(newConn2);
                            end
                        else
                            thisConn.setInvalid("Only one conn port was expanded to two for bidirectional interfaces");
                        end

                    elseif(nonSibling1||nonSibling2)

                        this.handleNonSiblingConnector(thisConn);
                    end
                end
            end


            cConns=this.ChildConnectors;
            for c=1:length(cConns)
                cConns(c).validate();
            end
        end

        function fixFanInConnectors(this)


            ports=this.PortMapFromExtElementID.values;
            for k=1:length(ports)
                thisPort=ports{k};
                thisPort.fixFanInConnectors();
            end

            cComps=this.ChildComponents;
            for p=1:length(cComps)
                thisComp=cComps(p);
                thisComp.fixFanInConnectors();
            end
        end

        function checkArchReferenceCycles(this)

            cComps=this.ChildComponents;
            for p=1:length(cComps)
                thisComp=cComps(p);
                compArch=thisComp.ReferenceArch;

                archsToCheck=thisComp.ParentArchitecture;
                allArchsToCheck=archsToCheck;
                hasCycle=false;
                while~isempty(archsToCheck)
                    archCheck=archsToCheck(1);
                    archCheck.Visited=true;
                    archsToCheck=archsToCheck(2:end);

                    if archCheck==compArch
                        hasCycle=true;
                        break;
                    end

                    for n=1:length(archCheck.ReferencingComps)
                        parArch=archCheck.ReferencingComps(n).ParentArchitecture;
                        if~parArch.Visited
                            archsToCheck=[archsToCheck,parArch];%#ok
                            allArchsToCheck=[allArchsToCheck,parArch];%#ok
                        end
                    end
                end
                if hasCycle
                    thisComp.setInvalid("Reference cycle");
                end
                for n=1:length(allArchsToCheck)
                    allArchsToCheck(n).Visited=false;
                end
            end
        end

        function fPath=getPostLinkFullPath(this)
            fPath=this.Name;
            pOwn=this.ParentPackage;
            while~isempty(pOwn)
                fPath=pOwn.Name+"/"+fPath;
                pOwn=pOwn.ParentPackage;
            end

        end

        function emp=isEmptyAndUnlinked(this)
            emp=false;
            if isempty(this.ChildComponents)&&isempty(this.ReferencingComps)&&...
                isempty(this.PortMapFromExtElementID.values)
                emp=true;
            end
        end

        function adComp=addAdapter(this,conns,dstComp,dstCompArchPort)
            adArch=systemcomposer.xmi.CandidateArchitecture(...
            "Adapter"+this.DerivedArchIdx,...
            this.ExtElementID+"AdapterArch"+this.DerivedArchIdx,...
            this.ParentPackageExtElementID,[]);
            adArch.Derived=true;
            this.DerivedArchIdx=this.DerivedArchIdx+1;

            othComps=cell(1,length(conns));
            othAPorts=[];
            for k=1:length(conns)
                thisConn=conns(k);
                if thisConn.End1APort==dstCompArchPort
                    othComp=thisConn.End2Comp;
                    othAPort=thisConn.End2APort;
                else
                    othComp=thisConn.End1Comp;
                    othAPort=thisConn.End1APort;
                end
                othComps{k}=othComp;
                othAPorts=[othAPorts,othAPort];%#ok
            end

            adArchInports=[];
            for k=1:length(conns)
                newPort=adArch.addPort(...
                othAPorts(k).Name,~othAPorts(k).IsConjugated,...
                adArch.ExtElementID+"AdapterPort"+adArch.DerivedPortIdx,...
                "",othAPorts(k).Interface,true);
                adArch.DerivedPortIdx=adArch.DerivedPortIdx+1;
                newPort.ComputedDir="in";
                adArchInports=[adArchInports,newPort];%#ok
            end

            adArchOutport=adArch.addPort(...
            dstCompArchPort.Name,~dstCompArchPort.IsConjugated,...
            adArch.ExtElementID+"AdapterPort"+adArch.DerivedPortIdx,...
            "",dstCompArchPort.Interface,true);
            adArch.DerivedPortIdx=adArch.DerivedPortIdx+1;
            adArchOutport.ComputedDir="out";

            adComp=this.addChildComponent(...
            "Adapter"+this.DerivedCompIdx,...
            this.ExtElementID+"AdapterComp"+this.DerivedCompIdx,...
            adArch.ExtElementID);
            this.DerivedCompIdx=this.DerivedCompIdx+1;

            adArch.linkComponentsPortsPackage();
            adComp.ReferenceArch=adArch;
            adArch.addReferencingComp(adComp);

            for k=1:length(conns)
                thisConn=conns(k);
                othComp=[];
                if~isempty(othComps{k})
                    othComp=othComps{k};
                end
                repConn=this.addDerivedConnector(...
                this,othComp,othAPorts(k),...
                adComp,adArchInports(k));
                thisConn.setReplacements(repConn);
            end
            this.addDerivedConnector(...
            this,dstComp,dstCompArchPort,...
            adComp,adArchOutport);
        end

        function build=buildCheck(this,inlineSingleUseArchsAcrossPackages,...
            pruneArchsWithNoRefAndNoChildren,...
            simulinkLeaf)
            build=true;
            if this.isEmptyAndUnlinked()

                build=~pruneArchsWithNoRefAndNoChildren;
            elseif isempty(this.ChildComponents)&&simulinkLeaf

                this.BuildAsSimulink=true;
            elseif length(this.ReferencingComps)==1


                aPrj=this.ParentPackage;
                rcPrj=this.ReferencingComps.ParentArchitecture.ParentPackage;
                if aPrj.ExtElementID==rcPrj.ExtElementID||...
                    inlineSingleUseArchsAcrossPackages||...
                    this.Derived
                    this.IsInlined=true;
                    this.ReferencingComps.IsInliningItsArch=true;
                    this.ParentPackage=rcPrj;
                    build=false;
                end
            end
            this.Build=build;
        end

        function print(this,printer)
            if~this.IsInlined
                printer.openScope("Arch: "+this.Name);
            end
            allPorts=this.PortMapFromExtElementID.values;
            for k=1:length(allPorts)
                allPorts{k}.print(printer);
                if~isempty(allPorts{k}.Interface)
                    allPorts{k}.Interface.print(printer);
                end
            end
            for k=1:length(this.ChildComponents)
                this.ChildComponents(k).print(printer);
            end
            for k=1:length(this.ChildConnectors)
                this.ChildConnectors(k).print(printer);
            end
            for k=1:length(this.Parameters)
                printer.print("Prm: ["+this.Parameters(k).Name+",t:"+...
                this.Parameters(k).TypeName+",d:"+...
                this.Parameters(k).Dim+",v:"+this.Parameters(k).DefaultValue+"]");
            end
            if~this.IsInlined
                printer.closeScope("Arch: "+this.Name);
            end
        end

        function prelimBuildArchBody(this,thisArch,builder)
            this.ZCHandle=thisArch;
            thisArch.ExternalUID=this.ExtElementID;


            builder.applyStereotypes(this);
            builder.createParameters(this);

            cComps=this.ChildComponents;

            for p=1:length(cComps)
                thisComp=cComps(p);
                if thisComp.Valid
                    c=builder.createComponent(thisArch,thisComp);
                    thisComp.ZCHandle=c;
                    c.ExternalUID=thisComp.ExtElementID;
                end
            end


            prelimBuildPorts(this,thisArch,builder);


            for p=1:length(cComps)
                thisComp=cComps(p);
                if thisComp.Valid&&thisComp.IsInliningItsArch
                    thisComp.ReferenceArch.prelimBuildArchBody(...
                    thisComp.ZCHandle.Architecture,builder);
                end
            end

        end

        function prelimBuildPorts(this,thisArch,builder)
            allPorts=this.PortMapFromExtElementID.values;
            for k=1:length(allPorts)
                thisPort=allPorts{k};
                if thisPort.Valid&&~thisPort.Replaced
                    aP=builder.createPort(thisArch,thisPort.Name,...
                    thisPort.ComputedDir);
                    thisPort.ZCHandle=aP;
                    thisPort.BuildName=aP.Name;
                    aP.ExternalUID=thisPort.ExtElementID;
                    if~isempty(thisPort.Interface)
                        intf=thisPort.Interface.ZCHandle;
                        aP.setInterface(intf);
                    end
                end
            end
        end

        function prelimBuild(this,builder)
            if this.BuildAsSimulink
                builder.createSimulinkModel(this);
            else
                aMdl=builder.createArchitectureModel(this);
                this.prelimBuildArchBody(aMdl.Architecture,builder);
            end
        end

        function finishBuildLinkComps(this,builder)
            cComps=this.ChildComponents;
            cIdx=1;
            for p=1:length(cComps)
                thisComp=cComps(p);
                if thisComp.Valid
                    if~thisComp.IsInliningItsArch

                        refMdlName=builder.lookupModelNameFromExtID(...
                        thisComp.ReferenceArchExtElementID);
                        thisComp.ZCHandle.linkToModel(refMdlName);
                    else
                        thisComp.ReferenceArch.finishBuildLinkComps(builder);
                    end

                    defWidth=thisComp.ReferenceArch.getDefaultCompWidth();
                    compPos=get_param(thisComp.ZCHandle.SimulinkHandle,'Position');
                    offsetPos=10*(cIdx-1);
                    set_param(thisComp.ZCHandle.SimulinkHandle,'Position',...
                    [compPos(1),compPos(2),...
                    compPos(1)+defWidth,...
                    compPos(4)]+offsetPos);
                    cIdx=cIdx+1;
                end
            end
        end

        function finishBuildConnect(this,builder)
            cConns=this.ChildConnectors;
            for c=1:length(cConns)
                thisConn=cConns(c);

                if thisConn.Valid&&~thisConn.Replaced
                    if isempty(thisConn.End1Comp)

                        port1=this.PortMapFromExtElementID(thisConn.End1RefPortExtElementID);
                        port1Dir=port1.ComputedDir;
                        zcPort1=port1.ZCHandle;
                        port1Arch=true;
                    else

                        port1=thisConn.End1RefArch.PortMapFromExtElementID(thisConn.End1RefPortExtElementID);
                        port1Name=port1.BuildName;
                        port1Dir=port1.ComputedDir;
                        zcPort1=thisConn.End1Comp.ZCHandle.getPort(char(port1Name));
                        port1Arch=false;
                    end
                    if isempty(thisConn.End2Comp)

                        port2=this.PortMapFromExtElementID(thisConn.End2RefPortExtElementID);
                        zcPort2=port2.ZCHandle;
                    else

                        port2=thisConn.End2RefArch.PortMapFromExtElementID(thisConn.End2RefPortExtElementID);
                        port2Name=port2.BuildName;
                        zcPort2=thisConn.End2Comp.ZCHandle.getPort(char(port2Name));
                    end

                    if(port1Arch&&port1Dir=="in")||(~port1Arch&&port1Dir=="out")
                        connZC=builder.createConnector(zcPort1,zcPort2);
                    else
                        connZC=builder.createConnector(zcPort2,zcPort1);
                    end
                    connZC.ExternalUID=thisConn.ExtElementID;
                end
            end


            this.ZCHandle.layout;
            set_param(this.ZCHandle.SimulinkHandle,'SystemRect',[0,0,0,0]);

            cComps=this.ChildComponents;
            for p=1:length(cComps)
                thisComp=cComps(p);
                if thisComp.Valid&&thisComp.IsInliningItsArch
                    thisComp.ReferenceArch.finishBuildConnect(builder);
                end
            end


        end

        function finishBuild(this,builder)
            if~this.BuildAsSimulink
                this.finishBuildLinkComps(builder);
                this.finishBuildConnect(builder);
            end
        end

    end

end
