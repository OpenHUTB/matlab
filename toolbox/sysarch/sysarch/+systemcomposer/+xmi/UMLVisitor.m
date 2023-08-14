classdef UMLVisitor<m3i.Visitor
















    properties
        PackagesToIgnore=[];

        ProfilesFound=[];
        ArchNameGeneratedIdx=1;
        NotImported=[];
    end

    methods(Static)

        function path=getFullPath(part)
            path=part.name;
            owner=part.owner;
            while~isempty(owner)
                path=owner.name+"/"+path;
                owner=owner.owner;
            end
        end

        function[className,stypeInst]=getSysMLStereotype(element)
            className="";
            stypeInst=[];
            stypes=element.appliedStereotypeInstance;
            for k=1:stypes.size
                stypeIn=stypes.at(k);
                st=stypeIn.getMetaStereotype;
                while~isempty(st)
                    if strncmp(st.qualifiedName,'SysML.',length('SysML.'))
                        className=string(st.qualifiedName);
                        stypeInst=stypeIn;
                        break;
                    end

                    if st.superClass.size==0
                        st=[];
                    else
                        st=st.superClass.at(1);
                    end
                end
            end
        end

        function extID=getExtID(element)
            extIDInfo=element.getExternalToolInfo("MagicDraw");
            extID="";
            if~isempty(extIDInfo)
                extID=string(extIDInfo.externalId);
            end
            if extID==""
                extID=string(element.toString());
            end
        end

    end

    methods(Access=private)

        function addStereotypes(this,element,candElem)
            stypes=element.appliedStereotypeInstance;
            for k=1:stypes.size
                stypeIn=stypes.at(k);
                st=stypeIn.getMetaStereotype;
                stExtID=systemcomposer.xmi.UMLVisitor.getExtID(st);
                leafClass=true;
                while 1
                    if isempty(st)||strncmp(st.qualifiedName,'SysML.',length('SysML.'))
                        break;
                    else
                        if leafClass
                            candElem.addStereotype(stExtID);
                            leafClass=false;
                        end


                        thisProf=st.package;
                        pFound=false;
                        for pIdx=1:length(this.ProfilesFound)
                            if this.ProfilesFound(pIdx)==thisProf
                                pFound=true;
                                break;
                            end
                        end
                        if~pFound
                            this.ProfilesFound=[this.ProfilesFound,thisProf];
                        end


                        for p=1:st.ownedAttribute.size
                            pElem=st.ownedAttribute.at(p);
                            if~strncmp(pElem.name,'base_',5)
                                tName="";
                                if~isempty(pElem.type)
                                    tName=string(pElem.type.name);
                                end
                                try %#ok (getOne may error)
                                    pVal=stypeIn.getOne(pElem.name);
                                    if~isempty(pVal)
                                        candElem.addStereotypePropVal(...
                                        stExtID,string(pElem.name),tName,pVal.toString());
                                    end
                                end
                            end
                        end

                    end
                    if st.superClass.size>0
                        st=st.superClass.at(1);
                    else
                        st=[];
                    end
                end





            end
        end

        function addNotImported(this,element,type,reason)
            notImp.Type=type;
            notImp.Element=this.getFullPath(element);
            notImp.Reason=reason;
            scName=this.getSysMLStereotype(element);
            notImp.Stereotype=scName;

            this.NotImported=[this.NotImported,notImp];
        end

        function visitBlock(this,element)

            ppID="";
            owner=element.owner;
            while ppID==""
                if isa(owner,'umlmm.Package')
                    ppID=this.getExtID(owner);
                end
                owner=owner.owner;
            end
            assert(ppID~="");

            cID=this.getExtID(element);
            aName=string(element.name);
            if aName==""

                aName="Architecture"+this.ArchNameGeneratedIdx;
                this.ArchNameGeneratedIdx=this.ArchNameGeneratedIdx+1;
            end

            genIDs=[];
            for g=1:element.generalization.size()
                gen=element.generalization.at(g);
                if~isempty(gen)&&~isempty(gen.general)
                    genID=this.getExtID(gen.general);
                    genIDs=[genIDs,genID];%#ok
                end
            end

            thisArch=systemcomposer.xmi.CandidateArchitecture(...
            aName,cID,ppID,genIDs);
            this.addStereotypes(element,thisArch);


            for p=1:element.ownedPort.size
                this.apply1(element.ownedPort.at(p),thisArch);
            end


            for p=1:element.ownedAttribute.size
                property=element.ownedAttribute.at(p);
                if~isa(property,'umlmm.Port')&&...
                    ~isempty(property.type)&&...
                    this.getSysMLStereotype(property.type)=="SysML.Block"
                    cID=this.getExtID(property);
                    thisArch.addChildComponent(...
                    string(property.name),...
                    cID,this.getExtID(property.type));
                elseif~isa(property,'umlmm.Port')
                    elTypeName="";
                    elType="";
                    if~isempty(property.type)
                        if isa(property.type,'umlmm.Enumeration')
                            elType=this.visitEnumeration(property.type);
                            elTypeName="Enumeration";
                        elseif isa(property.type,'umlmm.DataType')
                            elTypeName="Dtype:"+string(property.type.name);
                        end
                    end
                    elDim=inf;
                    if~isempty(property.upperValue)
                        [pD,isOk]=str2num(property.upperValue.value);
                        if isOk
                            elDim=floor(pD);
                        end
                    end
                    if isinf(elDim),elDim=1;end

                    elValue='';
                    if~isempty(property.defaultValue)
                        elValue=property.defaultValue.value;
                    end

                    thisArch.addParameter(property.name,elType,elTypeName,elDim,elValue);
                end
            end


            for p=1:element.ownedConnector.size
                this.apply1(element.ownedConnector.at(p),thisArch);
            end


            for i=1:element.nestedClassifier.size
                this.apply(element.nestedClassifier.at(i));
            end
        end

        function visitRequirement(this,element)

            elemOwner=element.owner;
            reqOwner="";

            if isa(elemOwner,'umlmm.Class')
                oStypeStr=this.getSysMLStereotype(elemOwner);
                if oStypeStr=="SysML.Requirement"
                    reqOwner=this.getExtID(elemOwner);
                end
            end

            [~,cStype]=this.getSysMLStereotype(element);
            reqID=this.getExtID(element);
            systemcomposer.xmi.CandidateRequirement(...
            reqID,string(element.name),string(cStype.Id),...
            string(cStype.Text),reqOwner);


            for i=1:element.nestedClassifier.size
                this.apply(element.nestedClassifier.at(i));
            end
        end

        function debugPrintSignal(this,prop,idt,dispStr)
            idt=idt+"  ";
            fprintf('%s %s: %s\n',idt,dispStr,prop.name);
            for oa=1:prop.ownedAttribute.size
                attr=prop.ownedAttribute.at(oa);
                attrType="";
                if~isempty(attr.type)
                    if isa(attr.type,'umlmm.Enumeration')
                        attrType="Enum: <"+attr.type.name+">";
                    elseif isa(attr.type,'umlmm.DataType')
                        attrType=attr.type.name;
                    end
                end

                attName="<noName>";
                if~isempty(attr.name)
                    attName=string(attr.name);
                end

                if attr.redefinedProperty.size>0
                    rp=attr.redefinedProperty.at(1);
                    rpO=rp.owner;
                    fprintf('%s     .%s [%s] REDEFINES: %s.%s\n',...
                    idt,attName,attrType,rpO.name,rp.name);
                else
                    fprintf('%s     .%s [%s]\n',idt,attName,attrType);
                end
            end
            if prop.generalization.size>0
                this.debugPrintSignal(prop.generalization.at(1).general,...
                idt,"INH-FROM-SIGNAL");
            end
        end


        function debugPrintInterface(this,element)
            fprintf('INTERFACE: %s -----------------------------------\n',element.name);
            for p=1:element.ownedAttribute.size
                prop=element.ownedAttribute.at(p);
                fpn=this.getSysMLStereotype(prop);
                if fpn=="SysML.FlowProperty"
                    fprintf('->FLOWPROP: %s\n',prop.name);
                    if~isempty(prop.type)
                        if isa(prop.type,'umlmm.Signal')
                            this.debugPrintSignal(prop.type,"","SIGNAL");
                        elseif isa(prop.type,'umlmm.Enumeration')
                            fprintf(' ENUM: %s\n',prop.type.name);
                        elseif isa(prop.type,'umlmm.DataType')
                            fprintf(' DATA-TYPE: %s\n',prop.type.name);
                        else
                            fprintf(' TYPE: %s\n',class(prop.type));
                        end
                    end
                end
            end
        end

        function recVisitSignalSuperClass(this,element,intf,redefProps)
            for oa=1:element.ownedAttribute.size
                pA=element.ownedAttribute.at(oa);

                if~any(redefProps==this.getExtID(pA))
                    elTypeName="";
                    elType=[];
                    if~isempty(pA.type)
                        if isa(pA.type,'umlmm.Enumeration')
                            elType=this.visitEnumeration(pA.type);
                            elTypeName="Enumeration";
                        elseif isa(pA.type,'umlmm.DataType')
                            elTypeName="Dtype:"+string(pA.type.name);
                        end
                    end
                    if pA.redefinedProperty.size>0
                        rdP=pA.redefinedProperty.at(1);
                        redefProps=[redefProps,this.getExtID(rdP)];%#ok
                    end
                    elDim=inf;
                    if~isempty(pA.upperValue)
                        [pD,isOk]=str2num(pA.upperValue.value);
                        if isOk
                            elDim=floor(pD);
                        end
                    end

                    intf.addElement(string(pA.name),this.getExtID(pA),...
                    "unset",elTypeName,elType,elDim);
                end
            end

            if element.generalization.size>0
                gen=element.generalization.at(1);
                if~isempty(gen)&&~isempty(gen.general)
                    recVisitSignalSuperClass(this,gen.general,intf,redefProps);
                end
            end
        end

        function[propType,propTypeName]=visitSignal(this,element)

            sigID=this.getExtID(element);
            propType=systemcomposer.xmi.CandidateElement.idMap(...
            "lookup",sigID);
            if isempty(propType)
                propType=systemcomposer.xmi.CandidateInterface(...
                string(element.name),sigID,"SIGNAL");
                recVisitSignalSuperClass(this,element,propType,strings(0));
            end
            propTypeName="Bus:"+propType.Name;
        end

        function newEnum=visitEnumeration(this,element)
            enumID=this.getExtID(element);
            newEnum=systemcomposer.xmi.CandidateElement.idMap(...
            "lookup",enumID);
            if isempty(newEnum)
                enumStrs=[];
                for ol=1:element.ownedLiteral.size
                    enumStrs=[enumStrs,string(element.ownedLiteral.at(ol).name)];%#ok
                end
                newEnum=systemcomposer.xmi.CandidateEnum(...
                enumID,string(element.name),...
                enumStrs);
            end
        end

        function recVisitInterfaceSuperClass(this,element,intf,redefProps)
            for p=1:element.ownedAttribute.size
                prop=element.ownedAttribute.at(p);
                if~any(redefProps==this.getExtID(prop))
                    [fpn,fp]=this.getSysMLStereotype(prop);
                    if fpn=="SysML.FlowProperty"
                        propType=[];
                        propTypeName="";
                        if~isempty(prop.type)
                            if isa(prop.type,'umlmm.Signal')




                                [propType,propTypeName]=this.visitSignal(prop.type);
                            elseif isa(prop.type,'umlmm.Enumeration')
                                propType=this.visitEnumeration(prop.type);
                                propTypeName="Enumeration";
                            elseif isa(prop.type,'umlmm.DataType')
                                propTypeName="Dtype:"+string(prop.type.name);
                            else
                                addNotImported(this,prop.type,"UnsupportedFlowType",...
                                "Interface flow property is not a primitive type or signal");
                            end
                        end




                        portDir=fp.getOne('direction');
                        portDir=string(portDir.toString);

                        assert(strcmp(portDir,"in")||strcmp(portDir,"out")||...
                        strcmp(portDir,"inout"));

                        if prop.redefinedProperty.size>0
                            rdP=prop.redefinedProperty.at(1);
                            redefProps=[redefProps,this.getExtID(rdP)];%#ok
                        end
                        propDim=inf;
                        if~isempty(prop.upperValue)
                            [pD,isOk]=str2num(prop.upperValue.value);
                            if isOk
                                propDim=floor(pD);
                            end
                        end

                        intf.addElement(string(prop.name),this.getExtID(prop),...
                        portDir,propTypeName,propType,propDim);
                    else


                        addNotImported(this,prop,"NestedPortType",...
                        "Nested ports not supported");
                    end
                end
            end
            if element.generalization.size>0
                gen=element.generalization.at(1);
                if~isempty(gen)&&~isempty(gen.general)
                    recVisitInterfaceSuperClass(this,gen.general,intf,redefProps);
                end
            end

        end

        function visitInterface(this,element)
            intf=systemcomposer.xmi.CandidateInterface(...
            string(element.name),this.getExtID(element),...
            "INTERFACEBLOCK");

            recVisitInterfaceSuperClass(this,element,intf,strings(0));
        end
    end

    methods(Access=public)

        function ret=visitumlmmModel(this,element)


            ret=visitumlmmPackage(this,element);
        end

        function ret=visitumlmmPackage(this,package)

            ret=[];
            if any(this.PackagesToIgnore==string(package.name))
                return;
            end

            pID=this.getExtID(package);


            oID="";
            if~isempty(package.owner)
                oID=this.getExtID(package.owner);
            end
            systemcomposer.xmi.CandidatePackage(...
            string(package.name),pID,oID);


            for i=1:package.ownedMember.size
                mem=package.ownedMember.at(i);
                this.apply(mem);
            end

        end

        function ret=visitumlmmSignal(this,element)
            this.visitSignal(element);
            ret=[];
        end

        function ret=visitumlmmAbstraction(this,element)
            className=this.getSysMLStereotype(element);
            if className=="SysML.DeriveReqt"||...
                className=="SysML.Trace"||...
                className=="SysML.Allocate"||...
                className=="SysML.Satisfy"
                supplierID="";
                clientID="";
                supplierStype="";
                clientStype="";
                supplierMclass="";
                clientMclass="";
                if element.supplier.size~=0
                    supp=element.supplier.at(1);
                    supplierID=this.getExtID(supp);
                    supplierMclass=supp.MetaClass.qualifiedName;
                    supplierStype=this.getSysMLStereotype(supp);
                end
                if element.client.size~=0
                    client=element.client.at(1);
                    clientID=this.getExtID(client);
                    clientMclass=client.MetaClass.qualifiedName;
                    clientStype=this.getSysMLStereotype(client);
                end

                rLinkID=this.getExtID(element);
                systemcomposer.xmi.CandidateReqLink(...
                rLinkID,className,supplierID,clientID,...
                supplierMclass,clientMclass,...
                supplierStype,clientStype);
            end

            ret=[];
        end

        function ret=visitumlmmClass(this,element)
            cStypeStr=this.getSysMLStereotype(element);
            if cStypeStr=="SysML.InterfaceBlock"
                this.visitInterface(element);
            elseif cStypeStr=="SysML.Requirement"
                this.visitRequirement(element);
            elseif cStypeStr=="SysML.Block"
                this.visitBlock(element);
            else
                addNotImported(this,element,"Class",...
                "Not a Block, InterfaceBlock, or Requirement");
            end
            ret=[];
        end

        function ret=visitumlmmPort(this,element,thisArch)

            ret=[];

            pStrName=this.getSysMLStereotype(element);
            if pStrName~="SysML.ProxyPort"&&pStrName~="SysML.FullPort"...
                &&pStrName~="SysML.FlowPort"
                addNotImported(this,element,"Port","Not a proxy port or full port");
                return;
            end

            if pStrName=="SysML.FullPort"

                cID=this.getExtID(element);
                thisArch.addChildComponent(...
                string(element.name),...
                cID,this.getExtID(element.type));
            else
                isConj=false;
                if pStrName=="SysML.FlowPort"
                    [~,sType]=this.getSysMLStereotype(element);
                    sDir=sType.getOne('direction');
                    sDir=string(sDir.toString);
                    if strcmp(sDir,"out")
                        isConj=true;
                    end
                else
                    isConj=element.isConjugated;
                end


                pType=element.type;
                pTypeID="";
                if~isempty(pType)
                    pTypeStype=this.getSysMLStereotype(pType);

                    if pTypeStype=="SysML.InterfaceBlock"
                        pTypeID=this.getExtID(pType);
                    end
                end

                thisArch.addPort(string(element.name),isConj,...
                this.getExtID(element),pTypeID,[],false);

            end
        end

        function ret=visitumlmmConnector(this,element,thisArch)

            cEnd1=element.end.at(1);
            cEnd2=element.end.at(2);

            cEnd1PID="";
            cEnd2PID="";
            if~isempty(cEnd1.partWithPort)
                cEnd1PID=this.getExtID(cEnd1.partWithPort);
            end
            if~isempty(cEnd2.partWithPort)
                cEnd2PID=this.getExtID(cEnd2.partWithPort);
            end

            p1Valid=true;
            if isa(cEnd1.role,'umlmm.Port')
                pStrName=this.getSysMLStereotype(cEnd1.role);
                if pStrName~="SysML.ProxyPort"&&pStrName~="SysML.FlowPort"
                    p1Valid=false;
                end
            else
                p1Valid=false;
            end
            p2Valid=true;
            if isa(cEnd2.role,'umlmm.Port')
                pStrName=this.getSysMLStereotype(cEnd2.role);
                if pStrName~="SysML.ProxyPort"&&pStrName~="SysML.FlowPort"
                    p2Valid=false;
                end
            else
                p2Valid=false;
            end

            if p1Valid&&p2Valid&&...
                this.getSysMLStereotype(cEnd1.role.owner)=="SysML.Block"&&...
                this.getSysMLStereotype(cEnd2.role.owner)=="SysML.Block"
                thisArch.addChildConnector(this.getExtID(element),...
                cEnd1PID,this.getExtID(cEnd1.role),...
                this.getExtID(cEnd1.role.owner),...
                cEnd2PID,this.getExtID(cEnd2.role),...
                this.getExtID(cEnd2.role.owner),false);

            else
                addNotImported(this,element,"Connector",...
                "Not connecting flow ports");
            end
            ret=[];
        end
    end

end



