classdef importModelClass





    properties(Access=public)
        compTable;
        portTable;
        connxTable;
        portInterfaceTable;
        functionTable;
        archModelName;
        archModel;
        compIDTable;
        portIDTable;
        connxnIDTable;
        custIDUUIDContainer;
        importErrorsLog;
        importLogger;
        requirementLinksTable;
    end

    properties(Access=private,Hidden=true)
        profileNames;
        prototypeList;
        compIdMap;
        portIdMap;
        connxnIdMap;
        profilesMap;
        portInterfaceAdded;
        referencedModelNames;
        validDatatypes;
        isBehaviorModel=false;
    end
    methods
        function obj=importModelClass(mdlInfo,compTable,portTable,connxTable,portInterfaceTable,requirementLinksTable,functionTable,domain)





            obj.importErrorsLog={};

            obj.importLogger={};


            obj.validDatatypes=["double","single","int8","uint8","int16","uint16","int32","uint32","int64","uint64","boolean","fixdt(1,16)","fixdt(1,16,0)","fixdt(1,16,2^0,0)"];


            compTableColNames={'Name','ID','ParentID'};

            portTableColNames={'Name','Direction','ID','CompID'};

            connectionTableColNames={'Name','ID','SourcePortID','DestPortID'};

            interfacesTableColNames={'Name','ID','ParentID','DataType','Dimensions','Units','Complexity','Minimum','Maximum'};

            functionTableColNames={'Name','CompID'};

            if~istable(compTable)||~istable(portTable)||~istable(connxTable)||~istable(portInterfaceTable)
                error('Expected tables as input parameters');
            end

            if isempty(compTable)
                error(message('SystemArchitecture:Import:EmptyComponentTable'));
            end

            if~all(ismember(compTableColNames,compTable.Properties.VariableNames))
                error(message('SystemArchitecture:Import:InvalidComponentTableStructure'));
            end
            if~isempty(portTable)&&~all(ismember(portTableColNames,portTable.Properties.VariableNames))
                error(message('SystemArchitecture:Import:InvalidPortsTableStructure'));
            end
            if~isempty(connxTable)&&~all(ismember(connectionTableColNames,connxTable.Properties.VariableNames))
                error(message('SystemArchitecture:Import:InvalidConnectionsTableStructure'));
            end
            if~isempty(portInterfaceTable)&&~all(ismember(interfacesTableColNames,portInterfaceTable.Properties.VariableNames))
                error(message('SystemArchitecture:Import:InvalidInterfacesTableStructure'));
            end

            if~isempty(functionTable)&&~all(ismember(functionTableColNames,...
                functionTable.Properties.VariableNames))
                error(message('SystemArchitecture:Import:InvalidFunctionTableStructure'));
            end



            if(isa(mdlInfo,'systemcomposer.arch.Model'))
                obj.archModel=mdlInfo;
                obj.archModelName=mdlInfo.Name;

                mssg=message('SystemArchitecture:Import:ImportInModel',mdlInfo.Name).getString;
                obj.importLogger=[obj.importLogger,mssg];

                if Simulink.internal.isArchitectureModel(obj.archModel.SimulinkHandle,'SoftwareArchitecture')&&...
                    strcmpi(domain,getString(message('SystemArchitecture:Import:SystemDomain')))
                    errorMessage=message('SystemArchitecture:Import:ImportingSystemInSoftware',obj.archModelName);
                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                elseif Simulink.internal.isArchitectureModel(obj.archModel.SimulinkHandle,'Architecture')&&...
                    strcmpi(domain,getString(message('SystemArchitecture:Import:SoftwareDomain')))
                    errorMessage=message('SystemArchitecture:Import:ImportingSoftwareInSystem',obj.archModelName);
                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                end
            else

                if isempty(mdlInfo)
                    obj.archModelName=['Import_',regexprep(datestr(now),'[^A-Za-z0-9]','_')];
                else
                    obj.archModelName=mdlInfo;
                end


                if(which(obj.archModelName))
                    errorMessage=message('SystemArchitecture:Import:DuplicateName',obj.archModelName);
                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];


                    obj.archModelName=strcat(obj.archModelName,regexprep(datestr(now),'[^A-Za-z0-9]','_'));
                end

                compIDs=compTable.ID;
                if~isstring(compTable.ID)
                    compIDs=string(compTable.ID);
                end
                rootIdx=find(compIDs=="0");
                domainType="Composition";
                if~isempty(rootIdx)&&any(contains(compTable.Properties.VariableNames,'ComponentType'))
                    domainType=compTable(rootIdx(1),:).ComponentType;
                end
                if strcmpi(domainType,"Behavior")
                    hdl=new_system(obj.archModelName,'Model');
                    obj.isBehaviorModel=true;
                    prevHasInfo=get_param(hdl,'HasSystemComposerArchInfo');
                    refArch=get_param(hdl,'SystemComposerArchitecture');
                    if isempty(refArch)
                        dFlag=get_param(hdl,'Dirty');
                        set_param(hdl,'HasSystemComposerArchInfo','on');
                        set_param(hdl,'HasSystemComposerArchInfo',prevHasInfo);
                        set_param(hdl,'Dirty',dFlag);
                    end
                    obj.archModel=get_param(hdl,'SystemComposerModel');

                else
                    if strcmpi(domain,getString(message('SystemArchitecture:Import:SystemDomain')))
                        obj.archModel=systemcomposer.createModel(obj.archModelName);
                    elseif strcmpi(domain,getString(message('SystemArchitecture:Import:SoftwareDomain')))
                        obj.archModel=systemcomposer.createModel(obj.archModelName,'SoftwareArchitecture');
                    else

                        errorMessage=message('SystemArchitecture:Import:ImportingUnknownDomainInSystem',obj.archModelName);
                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                        obj.archModel=systemcomposer.createModel(obj.archModelName);
                    end
                end


                mssg=message('SystemArchitecture:Import:ModelCreated',obj.archModelName).getString;
                obj.importLogger=[obj.importLogger,mssg];
            end



            if(nargin>4)
                try

                    if(~cellfun('isclass',table2cell(portInterfaceTable),'string'))
                        portInterfaceTable=cell2table((cellfun(@string,table2cell(portInterfaceTable),'UniformOutput',false)),'VariableNames',portInterfaceTable.Properties.VariableNames);
                    end
                catch exception
                    combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                    errorMessage=message('SystemArchitecture:Import:InvalidTableValues','Interfaces',combinedExceptionMessage);
                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                end
            end



            try
                if(~cellfun('isclass',table2cell(compTable),'string'))
                    compTable=cell2table((cellfun(@string,table2cell(compTable),'UniformOutput',false)),...
                    'VariableNames',compTable.Properties.VariableNames);
                end
                if(~cellfun('isclass',table2cell(portTable),'string'))
                    portTable=cell2table((cellfun(@string,table2cell(portTable),'UniformOutput',false)),...
                    'VariableNames',portTable.Properties.VariableNames);
                end
                if(~cellfun('isclass',table2cell(connxTable),'string'))
                    connxTable=cell2table((cellfun(@string,table2cell(connxTable),'UniformOutput',false)),...
                    'VariableNames',connxTable.Properties.VariableNames);
                end

                if(~cellfun('isclass',table2cell(functionTable),'string'))
                    functionTable=cell2table((cellfun(@string,table2cell(functionTable),'UniformOutput',false)),...
                    'VariableNames',functionTable.Properties.VariableNames);
                end

            catch exception

                combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                errorMessage=message('SystemArchitecture:Import:InvalidTableValues','Components, Ports and Connections',combinedExceptionMessage);
                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
            end


            obj.compTable=compTable;
            obj.portTable=portTable;
            obj.connxTable=connxTable;
            obj.portInterfaceTable=portInterfaceTable;
            obj.requirementLinksTable=requirementLinksTable;
            obj.functionTable=functionTable;


            obj.checkForDuplicateID();

            obj.checkForMissingValues();

            obj.checkForEmptyID();


            obj.compIdMap=containers.Map('keytype','char','valuetype','any');


            obj.portIdMap=containers.Map('keytype','char','valuetype','any');


            obj.connxnIdMap=containers.Map('keytype','char','valuetype','any');


            obj.profilesMap=containers.Map('keytype','char','valuetype','any');

            obj.profileNames={};
            obj.prototypeList={};
            obj.referencedModelNames=cellstr(obj.archModelName);


            prototypeColNames=unique([
            readPrototypeNamesFromTable(compTable)
            readPrototypeNamesFromTable(portTable)
            readPrototypeNamesFromTable(connxTable)
            readPrototypeNamesFromTable(portInterfaceTable)
            readPrototypeNamesFromTable(functionTable)
            ]);



            for protoItr=1:numel(prototypeColNames)
                prototypeNames=prototypeColNames{protoItr};
                stereotypeNameList=obj.getStereotypeName(prototypeNames);
                for itr=1:numel(stereotypeNameList)
                    prototypeName=char(stereotypeNameList(itr));
                    if(~isempty(prototypeName))
                        profName=obj.getProfileName(prototypeName);
                        if(~any(strcmp(obj.profileNames,profName)))
                            obj.profileNames=[obj.profileNames;profName];
                        end
                    end
                end
            end


            if(~isempty(obj.profileNames))
                [profiles,obj]=obj.loadProfiles(obj.profileNames);

                if(~isempty(profiles))
                    for profItr=1:numel(obj.profileNames)
                        try
                            profName=obj.profileNames(profItr);
                            obj.archModel.applyProfile(profName{:});

                            mssg=message('SystemArchitecture:Import:ProfileApplied',profName{:}).getString;
                            obj.importLogger=[obj.importLogger,mssg];
                        catch exception
                            combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                            errorMessage=message('SystemArchitecture:Import:ErrorProfileApplied',profName{:},combinedExceptionMessage);
                            obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                        end
                    end
                end
            end


            [I]=find(cellfun('isclass',obj.compTable.ParentID,'char'));
            listParentId=unique(obj.compTable.ParentID(I),'legacy');


            rootId=listParentId(~ismember(listParentId,obj.compTable.ID));

            if numel(rootId)>1
                errorMessage=message('SystemArchitecture:Import:MultipleRootFound');
                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
            end

            if ismember('0',obj.compTable.ID)
                rootId='0';
            end


            if(any(ismember(obj.compTable.ID,rootId)))
                obj.compTable(ismember(obj.compTable.ID,rootId),:).ParentID="";
            end
            try


                obj=obj.addInterfaceTableToModel(obj.archModel);

                if(ismember('InterfaceID',portTable.Properties.VariableNames)&&~all(cellfun(@isempty,portTable.InterfaceID)))
                    if~isempty(portInterfaceTable)
                        obj.portInterfaceAdded=1;
                    else
                        errorMessage=message('SystemArchitecture:Import:PortInterfaceTableNotPassed');
                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                    end
                end
            catch exception


                combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                errorMessage=message('SystemArchitecture:Import:InterfaceAdditionFailed',combinedExceptionMessage);
                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
            end



            obj=obj.addPort2Arch(obj.archModel.Architecture,rootId);


            [obj.archModel,obj]=obj.applyPrototypeProperties(obj.archModel.Architecture,obj.compTable(1,:));


            obj=obj.buildModel(obj.archModel,rootId);



            if(~isempty(obj.portIdMap)&&~isempty(connxTable)&&numel(connxTable(:,1))>0)

                hasKindColumn=any(ismember(obj.connxTable.Properties.VariableNames,'Kind'));
                for c=1:size(obj.connxTable,1)
                    try
                        connections=obj.connxTable(c,:);
                        if(hasKindColumn)
                            connType=connections.Kind;
                        else
                            connType="Data";
                        end

                        connxHandle={};
                        if(connType.matches("Physical"))

                            portEnds=systemcomposer.arch.ArchitecturePort.empty;
                            portString=connections.PortIDs;
                            portIDs=portString.split(',');
                            for i=1:numel(portIDs)
                                portEnds(i)=obj.portIdMap(char(portIDs(i)));
                            end

                            for pIdx=2:numel(portEnds)
                                if(portEnds(1).Direction~=systemcomposer.arch.PortDirection.Physical)&&(portEnds(pIdx).Direction~=systemcomposer.arch.PortDirection.Physical)
                                    mssg=message('SystemArchitecture:Import:NonPhysicalPorts','Connection',connID);
                                    obj.importErrorsLog=[obj.importErrorsLog,mssg];

                                    continue;
                                end
                                if~isequal(portEnds(1).Parent,obj.archModel.Architecture)&&~isequal(portEnds(pIdx).Parent,obj.archModel.Architecture)...
                                    &&obj.isComponentUnderSameArchitecture(portEnds(1).Parent,portEnds(pIdx).Parent)
                                    compPort(1)=obj.getComponentPort(portEnds(1));
                                    compPort(2)=obj.getComponentPort(portEnds(pIdx));
                                    if numel(compPort)==2
                                        connxHandle=compPort(1).connect(compPort(2));
                                    end
                                elseif(contains(portEnds(1).Parent.getQualifiedName,portEnds(pIdx).Parent.getQualifiedName)&&...
                                    ~isequal(portEnds(1).Parent,portEnds(pIdx).Parent)&&~isequal(portEnds(pIdx).Parent,obj.archModel.Architecture))

                                    compPort=obj.getComponentPort(portEnds(1));
                                    connxHandle=compPort.connect(portEnds(pIdx));
                                elseif(contains(portEnds(pIdx).Parent.getQualifiedName,portEnds(1).Parent.getQualifiedName)&&...
                                    ~isequal(portEnds(1).Parent,portEnds(pIdx).Parent)&&~isequal(portEnds(1).Parent,obj.archModel.Architecture))

                                    compPort=obj.getComponentPort(portEnds(pIdx));
                                    connxHandle=portEnds(1).connect(compPort);
                                end
                            end
                        else

                            if~(obj.portIdMap.isKey(char(connections.SourcePortID))&&obj.portIdMap.isKey(char(connections.DestPortID)))
                                continue;
                            end
                            srcPort=obj.portIdMap(char(connections.SourcePortID));
                            destPort=obj.portIdMap(char(connections.DestPortID));
                            portIDs=[connections.SourcePortID,connections.DestPortID];
                            portEnds=[srcPort,destPort];
                            srcElementSelection="";
                            dstElementSelection="";
                            if any(contains(connections.Properties.VariableNames,'SourceElement'))
                                srcElementSelection=connections.SourceElement;
                            end
                            if any(contains(connections.Properties.VariableNames,'DestinationElement'))
                                dstElementSelection=connections.DestinationElement;
                            end








                            if(ismember(srcPort.Parent.Name,obj.referencedModelNames)||ismember(destPort.Parent.Name,obj.referencedModelNames))


                                if~ismember(srcPort.Parent.Name,obj.referencedModelNames)
                                    srcPortHndl=obj.getComponentPort(srcPort);
                                    dstElementSelection=strsplit(dstElementSelection,',');
                                    for m=1:numel(dstElementSelection)
                                        connxHandle=connect(srcPortHndl,destPort,'DestinationElement',dstElementSelection{m},'Routing','off');
                                    end


                                elseif~ismember(destPort.Parent.Name,obj.referencedModelNames)
                                    dstPortHndl=obj.getComponentPort(destPort);
                                    srcElementSelection=strsplit(srcElementSelection,',');
                                    connxHandle=connect(srcPort,dstPortHndl,'SourceElement',srcElementSelection{1});

                                else
                                    srcElementSelection=strsplit(srcElementSelection,',');
                                    dstElementSelection=strsplit(dstElementSelection,',');
                                    assert(numel(srcElementSelection)==numel(dstElementSelection));
                                    for k=1:numel(srcElementSelection)
                                        connxHandle=connect(srcPort,destPort,'SourceElement',srcElementSelection{k},'DestinationElement',dstElementSelection{k},'Routing','off');
                                    end
                                end


                            else
                                [srcPortHndl,dstPortHndl]=obj.getPortsToConnect(srcPort,destPort);
                                if isa(srcPortHndl,'systemcomposer.arch.ComponentPort')&&isa(dstPortHndl,'systemcomposer.arch.ComponentPort')
                                    connxHandle=connect(srcPortHndl,dstPortHndl,'Routing','off');
                                elseif isa(srcPortHndl,'systemcomposer.arch.ComponentPort')&&isa(dstPortHndl,'systemcomposer.arch.ArchitecturePort')

                                    dstElementSelection=strsplit(dstElementSelection,',');
                                    for m=1:numel(dstElementSelection)
                                        connxHandle=connect(srcPortHndl,dstPortHndl,'DestinationElement',dstElementSelection{m},'Routing','off');
                                    end
                                elseif isa(srcPortHndl,'systemcomposer.arch.ArchitecturePort')&&isa(dstPortHndl,'systemcomposer.arch.ComponentPort')

                                    srcElementSelection=strsplit(srcElementSelection,',');
                                    connxHandle=connect(srcPortHndl,dstPortHndl,'SourceElement',srcElementSelection{1},'Routing','off');
                                end
                            end
                        end
                        if~isempty(connxHandle)
                            connName=connections.Name;
                            connID=connections.ID;
                            if(strcmp(connName,""))
                                mssg=message('SystemArchitecture:Import:EmptyName','Connection',connID);
                                obj.importErrorsLog=[obj.importErrorsLog,mssg];

                                continue;
                            end

                            connxHandle.set('ExternalUID',connID);

                            connxHandle.set('Name',connName);

                            [connxHandle,obj]=obj.applyPrototypeProperties(connxHandle,connections);
                            if(obj.portInterfaceAdded)



                                srcPortInterfaceID=obj.portTable(ismember(portTable.ID,char(portIDs(1))),:).InterfaceID;

                                if~(isa(portEnds(1),'systemcomposer.arch.ComponentPort')&&portEnds(1).Parent.isReference)

                                    srcArchPortHndl=obj.getArchitecturePort(portEnds(1));
                                    srcPortIntIndex=find(strcmp(obj.portInterfaceTable.ID,char(srcPortInterfaceID)));
                                    for m=2:numel(portIDs)
                                        destPortInterfaceID=obj.portTable(ismember(portTable.ID,portIDs(m)),:).InterfaceID;
                                        dstArchPortHndl=obj.getArchitecturePort(portEnds(m));
                                        destPortIntIndex=find(strcmp(obj.portInterfaceTable.ID,char(destPortInterfaceID)));

                                        if isequal(srcPortInterfaceID,destPortInterfaceID)&&~strcmp(srcPortInterfaceID,"")


                                            if~(isempty(srcPortIntIndex))
                                                interfaceName=obj.portInterfaceTable(srcPortIntIndex,:).Name;
                                                try
                                                    obj.setPortInterface(srcArchPortHndl,interfaceName);
                                                catch exception
                                                    combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                                                    errorMessage=message('SystemArchitecture:Import:InterfaceError',char(interfaceName),srcArchPortHndl.Name,combinedExceptionMessage);
                                                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                                end
                                            else
                                                errorMessage=message('SystemArchitecture:Import:InvalidInterfaceID',srcPortInterfaceID,srcArchPortHndl.Name);
                                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                            end
                                        elseif~strcmp(srcPortInterfaceID,"")||~strcmp(destPortInterfaceID,"")


                                            srcPortInterfaceName="";
                                            destPortInterfaceName="";
                                            if~strcmp(srcPortInterfaceID,"")
                                                if~(isempty(srcPortIntIndex))
                                                    srcPortInterfaceName=obj.portInterfaceTable(srcPortIntIndex,:).Name;
                                                else
                                                    errorMessage=message('SystemArchitecture:Import:InvalidInterfaceID',srcPortInterfaceID,srcArchPortHndl.Name);
                                                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                                end
                                            end
                                            if~strcmp(destPortInterfaceID,"")
                                                if~(isempty(destPortIntIndex))
                                                    destPortInterfaceName=obj.portInterfaceTable(destPortIntIndex,:).Name;
                                                else
                                                    errorMessage=message('SystemArchitecture:Import:InvalidInterfaceID',destPortInterfaceID,dstArchPortHndl.Name);
                                                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                                end
                                            end


                                            try
                                                if strcmp(srcPortInterfaceName,"")&&~strcmp(destPortInterfaceName,"")


                                                    obj.setPortInterface(dstArchPortHndl,destPortInterfaceName);


                                                    srcArchPortHndl.setInterface('');
                                                elseif strcmp(destPortInterfaceName,"")&&~strcmp(srcPortInterfaceName,"")


                                                    obj.setPortInterface(srcArchPortHndl,srcPortInterfaceName);


                                                    dstArchPortHndl.setInterface('');
                                                elseif~strcmp(srcPortInterfaceName,"")&&~strcmp(destPortInterfaceName,"")



                                                    obj.setPortInterface(srcArchPortHndl,srcPortInterfaceName);
                                                    obj.setPortInterface(dstArchPortHndl,destPortInterfaceName);
                                                end
                                            catch exception
                                                combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                                                if~strcmp(srcPortInterfaceName,"")&&~strcmp(srcArchPortHndl.Interface.Name,srcPortInterfaceName)
                                                    errorMessage=message('SystemArchitecture:Import:InterfaceError',char(srcPortInterfaceName),srcArchPortHndl.Name,combinedExceptionMessage);
                                                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                                end
                                                if~strcmp(destPortInterfaceName,"")&&~strcmp(dstArchPortHndl.Interface.Name,destPortInterfaceName)
                                                    errorMessage=message('SystemArchitecture:Import:InterfaceError',char(destPortInterfaceName),dstArchPortHndl.Name,combinedExceptionMessage);
                                                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                            obj.connxnIdMap(char(connID))=connxHandle;

                            mssg=message('SystemArchitecture:Import:ConnectionCreated',portEnds(1).Parent.Name,portEnds(2).Parent.Name).getString;
                            obj.importLogger=[obj.importLogger,mssg];
                        else
                            errorMessage=message('SystemArchitecture:Import:ConnectionAcrossHierarchy',portEnds(1).Parent.Name,portEnds(2).Parent.Name,portEnds(1).Name,portEnds(2).Name);
                            obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                        end
                    catch exception
                        combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                        errorMessage=message('SystemArchitecture:Import:ConnectionFailure',portEnds(1).Parent.Name,portEnds(2).Parent.Name,portEnds(1).Name,portEnds(2).Name,combinedExceptionMessage);
                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                    end
                end
            end



            if(obj.portInterfaceAdded)
                portInterfaces=obj.portTable(~ismember(portTable.InterfaceID,""),:);
                for intrItr=1:numel(portInterfaces(:,1))
                    portId=portInterfaces.ID(intrItr);
                    if ismember(portId,obj.portIdMap.keys)
                        portHandle=obj.portIdMap(char(portId));
                        if~(isa(portHandle.Parent,'systemcomposer.arch.Component')&&portHandle.Parent.isReference)
                            interfaceID=portInterfaces.InterfaceID(intrItr);
                            if(ismember(interfaceID,obj.portInterfaceTable.ID))
                                interfaceName=obj.portInterfaceTable(ismember(obj.portInterfaceTable.ID,interfaceID),:).Name;

                                if strcmp(interfaceName,"")
                                    try
                                        anonymousInt=obj.portInterfaceTable(ismember(obj.portInterfaceTable.ID,interfaceID),:);
                                        datatype=char(anonymousInt.DataType);
                                        dimensions=char(anonymousInt.Dimensions);
                                        units=char(anonymousInt.Units);
                                        complexity=char(anonymousInt.Complexity);
                                        min=char(anonymousInt.Minimum);
                                        max=char(anonymousInt.Maximum);
                                        descr='';
                                        if any(ismember(anonymousInt.Properties.VariableNames,'Description'))
                                            descr=char(anonymousInt.Description);
                                        end


                                        interface=portHandle.createInterface('ValueType');






                                        if~isempty(datatype)
                                            if ismember(datatype,obj.validDatatypes)
                                                interface.setTypeFromString(datatype);
                                            elseif contains(datatype,'Inherit:')
                                                interface.setTypeFromString(datatype);
                                            elseif contains(datatype,'Bus:')





                                                errorMessage=message('SystemArchitecture:Import:SetAnonymousTypeInterfaceError',datatype);
                                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                                continue;
                                            else
                                                errorMessage=message('SystemArchitecture:Import:SetAnonymousDataTypeError',datatype,portHandle.Name);
                                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                                continue;
                                            end
                                        end
                                        if~isempty(dimensions)
                                            interface.setDimensions(dimensions);
                                        end
                                        if~isempty(units)
                                            interface.setUnits(units);
                                        end
                                        validComplexities={'real','complex','auto'};
                                        if ismember(complexity,validComplexities)
                                            interface.setComplexity(complexity);
                                        end
                                        if~isempty(min)
                                            interface.setMinimum(min);
                                        end
                                        if~isempty(max)
                                            interface.setMaximum(max);
                                        end
                                        if~isempty(descr)
                                            interface.setDescription(descr);
                                        end
                                        interface.ExternalUID=interfaceID;
                                    catch exception
                                        combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                                        errorMessage=message('SystemArchitecture:Import:SetAnonymousInterfaceError',portHandle.Name,combinedExceptionMessage);
                                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                    end
                                end
                            end
                        end
                    end
                end
            end


            systemcomposer.utils.arrangeZCModel(obj.archModel);


            try
                if(~cellfun('isclass',table2cell(requirementLinksTable),'string'))
                    requirementLinksTable=cell2table((cellfun(@string,table2cell(requirementLinksTable),'UniformOutput',false)),'VariableNames',requirementLinksTable.Properties.VariableNames);
                end
            catch exception

                combinedExceptionMessage=getCombinedExceptionMessage(exception);
                errorMessage=message('SystemArchitecture:Import:InvalidTableValues','Requirement Links',combinedExceptionMessage);
                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
            end
            obj.requirementLinksTable=requirementLinksTable;


            save_system(obj.archModelName,'','SaveDirtyReferencedModels','on')



            obj.custIDUUIDContainer={};
            obj=obj.generateCustIdUUIDMap();

            if~isempty(obj.requirementLinksTable)
                refSets=string.empty(1,0);
                hasRefReqID=any(ismember(obj.requirementLinksTable.Properties.VariableNames,'ReferencedReqID'));
                hasKeyword=any(ismember(obj.requirementLinksTable.Properties.VariableNames,'Keywords'));
                for i=1:numel(obj.requirementLinksTable(:,1))
                    row=obj.requirementLinksTable(i,:);
                    if hasRefReqID
                        refReqId=row.ReferencedReqID;
                        if refReqId~=""
                            refReqInfo=strsplit(refReqId,'#');
                            refSets=[refSets,refReqInfo(1)];%#ok<AGROW>
                        end
                    end
                    lnkSrc=row.SourceID;
                    srcInfo=strsplit(lnkSrc,':');
                    srcElem=[];
                    switch(srcInfo(1))
                    case 'components'
                        if isequal(srcInfo(2),"0")

                            srcElem=obj.archModel.Architecture;
                            srcInfo="components";
                        else
                            q=systemcomposer.query.PropertyValue('ExternalUID');
                            constraint=(q==srcInfo(2));
                            elemPath=obj.archModel.find(constraint);
                            if isempty(elemPath)
                                errorMessage=message('SystemArchitecture:Import:InvalidRequirementLinkTableValues','SourceID',lnkSrc);
                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                continue;
                            end
                            assert(numel(elemPath)==1,'Found more than one element with the same external UID');
                            srcElem=obj.archModel.lookup('Path',elemPath{1});
                        end
                    case 'ports'

                        idx=find((obj.portIDTable.ExternalID==srcInfo(2))==1);
                        elemUUID=obj.portIDTable(idx(1),:).UUID;
                        srcElem=obj.archModel.lookup('UUID',elemUUID{1});
                    otherwise


                        try
                            srcHdl=Simulink.ID.getHandle(lnkSrc);
                            archElem=systemcomposer.utils.getArchitecturePeer(srcHdl);


                            if~isempty(archElem)
                                if isa(archElem,'systemcomposer.architecture.model.design.ArchitecturePort')
                                    portName=archElem.getName;
                                    parent=archElem.getArchitecture;
                                    slParent=systemcomposer.utils.getSimulinkPeer(parent.getParentComponent);
                                    oldSrcPath=Simulink.ID.getFullName(slParent);
                                    idx=strfind(oldSrcPath,'/');


                                    newPath=[obj.archModelName,oldSrcPath(idx:end)];
                                    parentElem=obj.archModel.lookup('Path',newPath);
                                    srcElem=findobj(parentElem.Architecture.Ports,'Name',portName);
                                end
                            end
                        catch

                            errorMessage=message('SystemArchitecture:Import:InvalidRequirementLinkTableValues','SourceID',lnkSrc);
                            obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                        end
                    end

                    targetData=rmi('createempty');
                    destInfo=strsplit(row.DestinationID,'#');
                    if numel(destInfo)<2
                        dInfo=strsplit(row.DestinationID,':');
                        targetData.doc=dInfo(1).char;
                        if numel(dInfo)>1
                            targetData.id=[':',dInfo(2).char];
                        end
                    else
                        targetData.doc=destInfo(1).char;
                        targetData.id=destInfo(2).char;
                    end
                    targetData.reqsys=row.DestinationType;
                    targetData.description=row.Label;
                    lnk=[];
                    try
                        switch srcInfo(1)
                        case 'components'
                            lnk=slreq.createLink(srcElem.SimulinkHandle,targetData);
                            if hasKeyword
                                lnk.Keywords=row.Keywords;
                            end
                        case 'ports'
                            lnk=slreq.createLink(srcElem,targetData);
                            if hasKeyword
                                lnk.Keywords=row.Keywords;
                            end
                        otherwise
                            if~isempty(srcElem)
                                lnk=slreq.createLink(srcElem,targetData);
                                if hasKeyword
                                    lnk.Keywords=row.Keywords;
                                end
                            end
                        end
                        if~isempty(lnk)
                            lnk.Type=row.Type;
                        end
                    catch ex

                        errorMessage=message('SystemArchitecture:Import:RequirementLinkCreationError',row.SourceID,row.DestinationID,ex.message);
                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                    end
                end
                lnkSet=slreq.find('Type','LinkSet','Artifact',which(obj.archModel.Name));
                for i=1:numel(refSets)
                    rs=slreq.load(refSets(i));
                    lnkSet.redirectLinksToImportedReqs(rs);
                end


                save_system(obj.archModelName,'','SaveDirtyReferencedModels','on');
            end


            if~isempty(functionTable)&&...
                Simulink.internal.isArchitectureModel(obj.archModel.SimulinkHandle,'SoftwareArchitecture')&&...
                strcmpi(domain,getString(message('SystemArchitecture:Import:SoftwareDomain')))
                obj=obj.addFunctions();
            end


            if obj.isBehaviorModel
                open_system(obj.archModelName);
            else

                systemcomposer.openModel(obj.archModelName);
            end

        end

        function[port1,port2]=getPortsToConnect(obj,port1,port2)
            if obj.isComponentUnderSameArchitecture(port1.Parent,port2.Parent)

                port1=obj.getComponentPort(port1);
                port2=obj.getComponentPort(port2);
            elseif(contains(port1.Parent.getQualifiedName,port2.Parent.getQualifiedName))

                port1=obj.getComponentPort(port1);
            elseif(contains(port2.Parent.getQualifiedName,port1.Parent.getQualifiedName))

                port2=obj.getComponentPort(port2);
            end
        end


        function obj=buildModel(obj,parentCompHndl,parentId)

            components=obj.compTable(ismember(obj.compTable.ParentID,parentId),:);



            for compItr=1:numel(components(:,1))
                try
                    compId=components.ID(compItr);
                    compName=components.Name(compItr);
                    compRefName="";
                    if ismember('ReferenceModelName',components.Properties.VariableNames)
                        compRefName=components.ReferenceModelName(compItr);
                    end
                    if(strcmp(compName,""))
                        errMssg=message('SystemArchitecture:Import:EmptyName','Component',compId);
                        obj.importErrorsLog=[obj.importErrorsLog,errMssg];


                        continue;
                    end
                    if ismember('ComponentType',components.Properties.VariableNames)&&strcmp(components.ComponentType(compItr),"Variant")
                        if~ismember(char(compId),obj.compIdMap.keys)
                            try



                                compHndl=parentCompHndl.Architecture.addVariantComponent(char(compName));
                            catch exception

                                combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                                errorMessage=message('SystemArchitecture:Import:VariantError',compHndl.Name,combinedExceptionMessage);
                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                            end
                        else
                            compHndl=obj.compIdMap(char(compId));
                            compHndl=compHndl.makeVariant();
                            obj.compIdMap(compId)=compHndl;
                        end
                        activeChoice=components.ActiveChoice(compItr);

                        varcompHndl=obj.removeDefaultChoices(compHndl);




                        obj=obj.addPort2Arch(varcompHndl.OwnedArchitecture,compId);

                        choices=obj.compTable(ismember(obj.compTable.ParentID,compId),:);
                        expressionMode=false;
                        if~isempty(varcompHndl)
                            mssg=message('SystemArchitecture:Import:VariantComponentCreated',varcompHndl.Name).getString;
                            for choiceItr=1:numel(choices(:,1))
                                choiceName=choices.Name{choiceItr};
                                choiceId=choices.ID(choiceItr);



                                if ismember('VariantCondition',components.Properties.VariableNames)&&~strcmp(choices.VariantCondition(choiceItr),"")
                                    choiceLabel=choices.VariantCondition{choiceItr};




                                    expressionMode=true;
                                elseif ismember('VariantControl',components.Properties.VariableNames)&&~strcmp(choices.VariantControl(choiceItr),"")
                                    if~strcmp(choices.VariantControl(choiceItr),"")
                                        choiceLabel=choices.VariantControl{choiceItr};
                                    end
                                else
                                    errorMessage=message('SystemArchitecture:Import:ChoiceLabelError',choiceName);
                                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                end

                                choiceHandle=varcompHndl.addChoice({choiceName},{choiceLabel});

                                if~isempty(choiceHandle)


                                    obj.compIdMap(choiceId)=choiceHandle;


                                    choiceMssg=message('SystemArchitecture:Import:ChoiceAdded',char(choiceName),compHndl.Name,char(choiceLabel)).getString;
                                    obj.importLogger=[obj.importLogger,choiceMssg];
                                end
                                if strcmp(choiceName,activeChoice)&&~expressionMode
                                    varcompHndl.setActiveChoice(choiceHandle);
                                end
                            end
                            if(expressionMode)&&~strcmp(activeChoice,"")



                                errorMessage=message('SystemArchitecture:Import:ActiveChoiceError',activeChoice,compHndl.Name);
                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                            end
                        end
                    else


                        if~ismember(char(compId),obj.compIdMap.keys)


                            compName=strrep(compName,'/','//');
                            if compRefName.matches("")
                                compHndl=addComponent(get(parentCompHndl,'Architecture'),compName{:});
                            else
                                compHndl=addReferenceComponent(get(parentCompHndl,'Architecture'),compName{:});
                            end

                            mssg=message('SystemArchitecture:Import:ComponentCreated',compName,compId).getString;
                            obj.importLogger=[obj.importLogger,mssg];
                        else
                            compHndl=obj.compIdMap(char(compId));
                            mssg='';
                        end
                    end


                    if ismember('ReferenceModelName',components.Properties.VariableNames)&&~strcmp(components.ReferenceModelName(compItr),"")

                        referenceName=components.ReferenceModelName(compItr);


                        if~isempty(referenceName{:})&&~isempty(compHndl)

                            loadFileName=strcat(referenceName,'.slx');
                            if(isequal(exist(char(loadFileName),'file'),4))
                                compHndl.linkToModel(referenceName);
                                obj.referencedModelNames=[obj.referencedModelNames,referenceName];














                                ports=obj.portTable(ismember(obj.portTable.CompID,char(compId)),:);
                                if(size(ports,1)>0)
                                    for portItr=1:size(ports,1)

                                        if~isa(compHndl,'systemcomposer.arch.Model')&&~isempty(compHndl.getPort(ports.Name(portItr)))
                                            portHndl=compHndl.getPort(ports.Name(portItr));















                                            obj.portIdMap(char(ports.ID(portItr)))=portHndl;

                                            mssg=message('SystemArchitecture:Import:PortCreated',char(ports.Name(portItr)),compHndl.Name,char(ports.Direction(portItr))).getString;
                                            obj.importLogger=[obj.importLogger,mssg];
                                        else
                                            errorMessage=message('SystemArchitecture:Import:PortOnReferenceError',char(ports.Name(portItr)),compHndl.Name);
                                            obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                        end
                                    end
                                end

                                compHndl.set('ExternalUID',compId);






                                obj.compIdMap(char(compId))=compHndl;

                                if~isempty(mssg)
                                    obj.importLogger=[obj.importLogger,mssg];
                                end
                                linkmessage=message('SystemArchitecture:Import:ReferenceAdded',referenceName,compHndl.Name).getString;
                                obj.importLogger=[obj.importLogger,linkmessage];

                                compHndl={};

                            else

                                compHndl.set('ExternalUID',compId);
                                obj.compIdMap(char(compId))=compHndl;
                                set_param(compHndl.SimulinkHandle,'ModelName',referenceName);
                                errorMessage=message('SystemArchitecture:Import:ReferenceError',referenceName,compHndl.Name);
                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                            end
                        end
                    elseif ismember('ComponentType',components.Properties.VariableNames)&&strcmp(components.ComponentType(compItr),"Adapter")

                        compHndl.set('ExternalUID',compId);


                        obj=obj.addPort2Arch(compHndl.Architecture,compId);

                        adapterHndl=systemcomposer.utils.makeAdapter(compHndl);
                        if~isempty(adapterHndl)

                            obj.compIdMap(compId)=adapterHndl;



                            mssg=message('SystemArchitecture:Import:AdapterCreated',adapterHndl.Name,compHndl.Name).getString;
                            obj.importLogger=[obj.importLogger,mssg];
                        end
                        compHndl={};

                    elseif ismember('ComponentType',components.Properties.VariableNames)&&strcmp(components.ComponentType(compItr),"Behavior")
                        compHndl.set('ExternalUID',compId);

                        obj=obj.addPort2Arch(compHndl.Architecture,compId);

                        compToImplSSConverter=systemcomposer.internal.arch.internal.ComponentToImplSubsystemConverter(compHndl.SimulinkHandle);
                        compToImplSSConverter.convert();
                        if systemcomposer.internal.isInlinedSubsystemBehavior(compHndl.SimulinkHandle)
                            [compHndl,obj]=obj.applyPrototypeProperties(compHndl,components(compItr,:));
                        end
                        obj.compIdMap(compId)=compHndl;
                        compHndl={};
                    elseif ismember('ComponentType',components.Properties.VariableNames)&&strcmp(components.ComponentType(compItr),"StateflowBehavior")

                        compHndl.set('ExternalUID',compId);


                        obj=obj.addPort2Arch(compHndl.Architecture,compId);

                        if dig.isProductInstalled('Stateflow')
                            compToChartImplConverter=systemcomposer.internal.arch.internal.ComponentToChartImplConverter(compHndl.SimulinkHandle);
                            mbh=compToChartImplConverter.convertComponentToChartImpl();
                            [compHndl,obj]=obj.applyPrototypeProperties(compHndl,components(compItr,:));
                            mbh=get_param(getfullname(mbh),'Handle');
                            chartHndl=systemcomposer.internal.getWrapperForImpl(systemcomposer.utils.getArchitecturePeer(mbh),'systemcomposer.arch.Component');

                            if~isempty(chartHndl)

                                obj.compIdMap(compId)=chartHndl;


                                mssg=message('SystemArchitecture:Import:StateflowComponentCreated',chartHndl.Name).getString;
                                obj.importLogger=[obj.importLogger,mssg];
                            end
                        else

                            obj.compIdMap(compId)=compHndl;


                            mssg=message('SystemArchitecture:Import:StateflowComponentCreationAborted',compHndl.Name).getString;
                            obj.importLogger=[obj.importLogger,mssg];
                        end
                        compHndl={};

                    else
                        if~isempty(compHndl)

                            obj=obj.buildModel(compHndl,compId);


                            compHndl.set('ExternalUID',compId);



                            if~isa(compHndl,'systemcomposer.arch.VariantComponent')

                                obj=obj.addPort2Arch(compHndl.Architecture,compId);
                            end


                            [compHndl,obj]=obj.applyPrototypeProperties(compHndl,components(compItr,:));

                            obj.compIdMap(char(compId))=compHndl;




                            if~isempty(mssg)
                                obj.importLogger=[obj.importLogger,mssg];
                            end
                        end
                    end
                catch exception
                    combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                    errorMessage=message('SystemArchitecture:Import:ComponentCreationError',char(components.Name(compItr)),combinedExceptionMessage);
                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                end
            end
        end


        function[profileName,prototypeName]=getProfileName(~,prototypeQualName)
            if(contains(prototypeQualName,'.'))
                posIdentifierInName=strfind(prototypeQualName,'.');
                if(numel(posIdentifierInName)==1)
                    profileName=prototypeQualName(1:posIdentifierInName(1)-1);
                    prototypeName=prototypeQualName(posIdentifierInName(1)+1:end);
                end
            else
                profileName='';
                prototypeName='';
            end
        end

        function obj=addPort2Arch(obj,compArch,compId)


            if isempty(obj.portTable)||numel(obj.portTable(:,1))<1
                return;
            end
            ports=obj.portTable(ismember(obj.portTable.CompID,char(compId)),:);

            valid_port_directions={'Input','Output','Physical','Client','Server'};
            if(size(ports,1)>0)
                for portItr=1:size(ports,1)
                    try
                        portRow=ports(portItr,:);
                        portName=portRow.Name;
                        portID=portRow.ID;
                        portDir=portRow.Direction;
                        if(strcmp(portName,""))
                            mssg=message('SystemArchitecture:Import:EmptyName','Port',portID);
                            obj.importErrorsLog=[obj.importErrorsLog,mssg];

                            continue;
                        end

                        if~isempty(compArch.getPort(portName))
                            portHndl=compArch.getPort(portName);

                            obj.portIdMap(char(portID))=portHndl;


                            errorMessage=message('SystemArchitecture:Import:PortDuplicationError',char(portName));
                            obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                        else
                            if(~ismember(char(portDir),valid_port_directions))
                                errorMessage=message('SystemArchitecture:Import:InvalidPortDirection',char(portID));
                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                            elseif strcmpi(char(portDir),'Input')

                                portHndl=addPort(compArch,portName,'in');
                            elseif strcmpi(char(portDir),'Output')

                                portHndl=addPort(compArch,portName,'out');
                            elseif strcmpi(char(portDir),'Physical')

                                portHndl=addPort(compArch,portName,'physical');
                            elseif strcmpi(char(portDir),'Client')

                                portHndl=addPort(compArch,portName,'client');
                            elseif strcmpi(char(portDir),'Server')

                                portHndl=addPort(compArch,portName,'server');
                            end
                            if~isempty(portHndl)

                                mssg=message('SystemArchitecture:Import:PortCreated',char(portName),compArch.Name,char(portDir)).getString;
                                obj.importLogger=[obj.importLogger,mssg];
                                if isa(portHndl,'systemcomposer.arch.ArchitecturePort')
                                    archPortHndl=portHndl;
                                else
                                    archPortHndl=portHndl.ArchitecturePort;
                                end
                                portIntIndex=[];
                                if any(ismember(portRow.Properties.VariableNames,'InterfaceID'))
                                    portIntIndex=find(strcmp(obj.portInterfaceTable.ID,portRow.InterfaceID));
                                end
                                if~isempty(portIntIndex)
                                    interfaceName=obj.portInterfaceTable(portIntIndex,:).Name;
                                    try
                                        obj.setPortInterface(archPortHndl,interfaceName);
                                    catch exception
                                        combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                                        errorMessage=message('SystemArchitecture:Import:InterfaceError',char(interfaceName),archPortHndl.Name,combinedExceptionMessage);
                                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                    end
                                end

                                archPortHndl.set('ExternalUID',portID);


                                [~,obj]=obj.applyPrototypeProperties(archPortHndl,portRow);

                                obj.portIdMap(portID)=archPortHndl;
                            end
                        end
                    catch exception
                        combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                        errorMessage=message('SystemArchitecture:Import:PortCreationError',char(ports.Name(portItr)),combinedExceptionMessage);
                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                    end

                end
            end
        end


        function obj=addFunctions(obj)
            tableHasPeriod=ismember('Period',obj.functionTable.Properties.VariableNames);
            tableHasExecOrder=ismember('ExecutionOrder',obj.functionTable.Properties.VariableNames);


            containRefComps=false;
            for rowIdx=1:height(obj.functionTable)
                compId=obj.functionTable(rowIdx,:).CompID;
                if isKey(obj.compIdMap,char(compId))
                    parentCompH=obj.compIdMap(char(compId));

                    if parentCompH.isReference
                        containRefComps=true;
                    else

                        try
                            fcn=addFunction(parentCompH.Architecture,obj.functionTable(rowIdx,:).Name);

                            if tableHasPeriod
                                fcn.Period=obj.functionTable(rowIdx,:).Period;
                            end
                        catch exception
                            combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                            errorMessage=message('SystemArchitecture:Import:FunctionCreationError',...
                            char(obj.functionTable(rowIdx,:).Name),combinedExceptionMessage);
                            obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                        end
                    end
                end
            end


            if~tableHasExecOrder
                return;
            end


            if containRefComps
                try
                    set_param(obj.archModelName,'SimulationCommand','Update');
                catch me
                    combinedExceptionMessage=obj.getCombinedExceptionMessage(me);
                    errorMessage=message('SystemArchitecture:Import:FunctionsCreationError',...
                    combinedExceptionMessage);
                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                end
            end


            arch=get(obj.archModel,'Architecture');
            fcns=get(arch,'Functions');




            if~isempty(fcns)
                [~,idxs]=sort([fcns.ExecutionOrder]);
                fcns=fcns(idxs);
            end


            for i=1:numel(fcns)

                fcnRow=find(obj.functionTable.Name==get(fcns(i),'Name'));
                parentCompRow=find(obj.compTable.ID==obj.functionTable(fcnRow,:).CompID);
                if(obj.functionTable(fcnRow,:).Period==get(fcns(i),'Period'))&&...
                    (obj.compTable(parentCompRow,:).Name==get(get(fcns(i),'Component'),'Name'))

                    execOrder=str2double(obj.functionTable(fcnRow,:).ExecutionOrder);
                    try
                        while get(fcns(i),'ExecutionOrder')>execOrder
                            fcns(i).decreaseExecutionOrder();
                        end
                        while get(fcns(i),'ExecutionOrder')<execOrder
                            fcns(i).increaseExecutionOrder();
                        end
                        assert(isequal(get(fcns(i),'ExecutionOrder'),execOrder));
                    catch exception
                        combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                        errorMessage=message('SystemArchitecture:Import:FunctionCreationError',...
                        char(get(fcns(i),'Name')),combinedExceptionMessage);
                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                    end
                end

                if~fcns(i).Component.isReference

                    obj.applyPrototypeProperties(fcns(i),obj.functionTable(fcnRow,:));
                end
            end
        end


        function[profiles,obj]=loadProfiles(obj,profileNames)


            import systemcomposer.internal.profile.*;

            profiles={};



            for profItr=1:numel(profileNames)
                try
                    profileName=profileNames(profItr);

                    loadFileName=strcat(profileName,'.xml');
                    if(isequal(exist(char(loadFileName),'file'),2))
                        profModel=Profile.loadFromFile(profileName{:});
                        if(~obj.profilesMap.isKey(profileName))
                            obj.profilesMap(profileName{:})=Profile.getProfile(profModel);
                        end
                    else
                        errorMessage=message('SystemArchitecture:Import:ProfileNotFound',char(loadFileName));
                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                    end
                catch exception
                    combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                    errorMessage=message('SystemArchitecture:Import:ProfileLoadError',profileName{:},combinedExceptionMessage);
                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                end
            end
            if(~isempty(obj.profilesMap))
                profiles=obj.profilesMap.values;
            end
        end


        function[objHandle,obj]=applyPrototypeProperties(obj,objHandle,refTableRow)
            if(ismember('StereotypeNames',refTableRow.Properties.VariableNames))

                if(~strcmp(refTableRow.StereotypeNames,""))


                    protoQualNames=obj.getStereotypeName(refTableRow.StereotypeNames);




                    appliedStereotypes=objHandle.getStereotypes;
                    for itr=1:numel(appliedStereotypes)
                        if isempty(find(strcmp(protoQualNames,appliedStereotypes{itr}),1))
                            objHandle.removeStereotype(appliedStereotypes{itr});
                        end
                    end

                    for itr=1:numel(protoQualNames)
                        protoQualName=char(protoQualNames(itr));
                        if~strcmp(protoQualName,"")
                            try

                                objHandle.applyStereotype(protoQualName);


                                [objHandle,obj]=obj.applyProperties(objHandle,refTableRow,protoQualName);


                                mssg=message('SystemArchitecture:Import:StereotypeApplied',protoQualName,objHandle.Name).getString;
                                obj.importLogger=[obj.importLogger,mssg];
                            catch exception
                                combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                                errorMessage=message('SystemArchitecture:Import:StereotypeError',protoQualName,combinedExceptionMessage);
                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                            end
                        end
                    end
                end
            end
        end


        function[objHandle,obj]=applyProperties(obj,objHandle,refTableRow,protoQualName)






            prototype=obj.getPrototype(protoQualName);
            propertyNames=obj.getPrototypePropertyNames(prototype);
            pos=strfind(protoQualName,'.');
            protoQualName(pos)='_';
            for propItr=1:numel(propertyNames)
                propertyName=propertyNames{propItr};
                propColName=strcat(protoQualName,'_',propertyName);
                propertyQualName=strcat(prototype.fullyQualifiedName,'.',propertyName);
                if(ismember(propColName,refTableRow.Properties.VariableNames))
                    propertyFieldValue=refTableRow.(propColName);
                    if(~strcmp(propertyFieldValue,""))
                        try
                            propertyType=obj.getPropertyType(prototype,propertyName);

                            if~isempty(propertyType)
                                if~(strcmp(propertyType,'enum'))&&~(strcmp(propertyType,'string'))

                                    if(propertyFieldValue.contains('{'))
                                        propertyVal=propertyFieldValue.extractBefore("{");
                                        propUnits=propertyFieldValue.extractAfter("{");
                                        propUnits=propUnits.extractBefore("}");
                                        objHandle.setProperty(propertyQualName,propertyVal,propUnits);
                                    else
                                        propertyVal=propertyFieldValue;
                                        objHandle.setProperty(propertyQualName,propertyVal);
                                    end
                                else


                                    if~(propertyFieldValue.startsWith("'")&&propertyFieldValue.endsWith("'"))

                                        propertyVal=char(propertyFieldValue);
                                    else
                                        propertyVal=propertyFieldValue;
                                    end
                                    objHandle.setProperty(propertyQualName,propertyVal);
                                end
                            end


                            mssg=message('SystemArchitecture:Import:PropertyAdded',char(propertyQualName),char(propertyFieldValue),objHandle.Name).getString;
                            obj.importLogger=[obj.importLogger,mssg];
                        catch exception




                            combinedExceptionMessage=obj.getCombinedExceptionMessage(exception);
                            errorMessage=message('SystemArchitecture:Import:PropertySetError',char(propertyQualName),char(propertyFieldValue),objHandle.Name,protoQualName,combinedExceptionMessage);
                            obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                        end
                    end
                end
            end
        end


        function obj=generateCustIdUUIDMap(obj)

            obj.compIDTable=cell2table(cell(0,2),'VariableNames',{'ExternalID','UUID'});
            if(~isempty(obj.compIdMap))
                custIdList=obj.compIdMap.keys;
                for idItr=1:numel(custIdList)
                    custId=custIdList(idItr);
                    objHandle=obj.compIdMap(char(custId));
                    if isvalid(objHandle)
                        externalID=get(objHandle,'ExternalUID');
                        uuid=get(objHandle,'UUID');
                        obj.compIDTable=[obj.compIDTable;cell2table({externalID,uuid},'VariableNames',{'ExternalID','UUID'})];
                    end
                end
            end
            obj.portIDTable=cell2table(cell(0,2),'VariableNames',{'ExternalID','UUID'});
            if(~isempty(obj.portIdMap))
                custIdList=obj.portIdMap.keys;
                for idItr=1:numel(custIdList)
                    custId=custIdList(idItr);
                    objHandle=obj.portIdMap(char(custId));
                    if isa(objHandle,'systemcomposer.arch.ComponentPort')
                        archPortHndl=objHandle.ArchitecturePort;



                        if~isequal(objHandle.SimulinkModelHandle,archPortHndl.SimulinkModelHandle)
                            archPortHndl=objHandle;
                        end
                    else
                        archPortHndl=objHandle;
                    end
                    if isvalid(objHandle)
                        externalID=get(archPortHndl,'ExternalUID');
                        if isempty(externalID)
                            externalID=custId;
                        end
                        uuid=get(archPortHndl,'UUID');
                        obj.portIDTable=[obj.portIDTable;cell2table({externalID,uuid},'VariableNames',{'ExternalID','UUID'})];
                    end
                end
            end
            obj.connxnIDTable=cell2table(cell(0,2),'VariableNames',{'ExternalID','UUID'});
            if(~isempty(obj.connxnIdMap))
                custIdList=obj.connxnIdMap.keys;
                for idItr=1:numel(custIdList)
                    custId=custIdList(idItr);
                    objHandle=obj.connxnIdMap(char(custId));
                    if isvalid(objHandle)
                        externalID=get(objHandle,'ExternalUID');
                        uuid=get(objHandle,'UUID');
                        obj.connxnIDTable=[obj.connxnIDTable;cell2table({externalID,uuid},'VariableNames',{'ExternalID','UUID'})];
                    end
                end
            end
        end


        function compPortHandle=getComponentPort(~,archPortHandle)
            if~(isa(archPortHandle,'systemcomposer.arch.ComponentPort'))

                arch=get(archPortHandle,'Parent');

                comp=get(arch,'Parent');

                portName=get(archPortHandle,'Name');
                compPortHandle=comp.getPort(char(portName));
            else
                compPortHandle=archPortHandle;
            end
        end


        function archPortHandle=getArchitecturePort(~,compPortHandle)
            if~(isa(compPortHandle,'systemcomposer.arch.ArchitecturePort'))

                archPortHandle=compPortHandle.ArchitecturePort;
            else
                archPortHandle=compPortHandle;
            end
        end


        function stereotypeNames=getStereotypeName(~,listOfNames)
            stereotypeNames={};
            if~isempty(listOfNames)
                pos=strfind(listOfNames,',');
                listOfNames=char(listOfNames);
                start=1;
                for posItr=1:numel(pos)
                    name=listOfNames(start:pos(posItr)-1);
                    stereotypeNames=[stereotypeNames;name];%#ok<AGROW>
                    start=pos(posItr)+1;
                end
                name=listOfNames(start:length(listOfNames));
                stereotypeNames=[stereotypeNames;name];
            end

        end


        function showAllImportErrors(obj)
            obj.importErrorsLog;
        end


        function getImportLogs(obj)
            obj.importLogger;
        end


        function prototype=getPrototype(obj,protoQualName)
            prototype={};
            if~isempty(obj.profilesMap)&&~isempty(protoQualName)
                [profileName,prototypeName]=obj.getProfileName(protoQualName);
                profile=obj.profilesMap(profileName);
                if~isempty(profile)
                    prototype=profile.prototypes.getByKey(prototypeName);
                end
            end
        end


        function setPortInterface(obj,portHandle,portInterfaceName)
            mdlH=obj.archModel.SimulinkHandle;
            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(mdlH);
            mf0Model=app.getCompositionArchitectureModel;
            modelCatalog=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mf0Model);
            piCatalog=modelCatalog.getPortInterfaceCatalog();
            if(ismember(portInterfaceName,piCatalog.getPortInterfaceNames))
                interface=systemcomposer.internal.getWrapperForImpl(piCatalog.getPortInterface(portInterfaceName));
                portHandle.setInterface(interface);
            end
        end



        function isEqual=isComponentUnderSameArchitecture(~,comp1,comp2)
            if isa(comp1,'systemcomposer.arch.Architecture')
                comp1=comp1.Parent;
            end
            if isa(comp2,'systemcomposer.arch.Architecture')
                comp2=comp2.Parent;
            end
            comp1ParentName=comp1.Parent.getQualifiedName;
            comp2ParentName=comp2.Parent.getQualifiedName;
            isEqual=strcmp(comp1ParentName,comp2ParentName);
        end


        function varCompHndl=removeDefaultChoices(~,varCompHndl)
            choices=varCompHndl.getChoices;
            for choiceItr=1:numel(choices)
                choices(choiceItr).destroy;
            end
        end

        function propertyNames=getPrototypePropertyNames(obj,prototype)

            propertyNames={};

            if(~isempty(prototype))
                propertyNames=prototype.propertySet.getAllPropertyNames;
                if~isempty(prototype.parent)

                    propertyNames=[propertyNames,obj.getPrototypePropertyNames(prototype.parent)];
                end
            end
        end

        function combinedExceptionMessage=getCombinedExceptionMessage(~,exception)


            combinedExceptionMessage=[newline,exception.message];
            for exceptionCause=exception.cause
                if iscell(exceptionCause)
                    exceptionCause=exceptionCause{1};
                end
                combinedExceptionMessage=[combinedExceptionMessage,newline,exceptionCause.message];%#ok<AGROW>
            end
        end


        function checkForDuplicateID(obj)


            errorMessage='';
            [~,dupIndices]=unique(obj.compTable.ID(:),'rows');
            duplicate=setdiff(1:size(obj.compTable.ID,1),dupIndices);
            for dupItr=1:numel(duplicate)
                dupValue=obj.compTable.ID(duplicate(dupItr));
                dupCompName=obj.compTable.Name(duplicate(dupItr));
                errorMessage=errorMessage+message('SystemArchitecture:Import:DuplicateID',dupCompName,char(dupValue),'Component',dupCompName).string;
            end

            if~isempty(obj.portTable)
                [~,dupIndices]=unique(obj.portTable.ID(:),'rows');
                duplicate=setdiff(1:size(obj.portTable.ID,1),dupIndices);

                for dupItr=1:numel(duplicate)
                    dupValue=obj.portTable.ID(duplicate(dupItr));
                    dupPortName=obj.portTable.Name(duplicate(dupItr));
                    errorMessage=strcat(errorMessage,message('SystemArchitecture:Import:DuplicateID',dupPortName,char(dupValue),'Port',dupPortName).string);
                end
            end

            if~isempty(obj.connxTable)
                [~,dupIndices]=unique(obj.connxTable.ID(:),'rows');
                duplicate=setdiff(1:size(obj.connxTable.ID,1),dupIndices);
                for dupItr=1:numel(duplicate)
                    dupValue=obj.connxTable.ID(duplicate(dupItr));
                    dupConnName=obj.connxTable.Name(duplicate(dupItr));
                    errorMessage=strcat(errorMessage,message('SystemArchitecture:Import:DuplicateID',dupConnName,char(dupValue),'Connection',dupConnName).string);
                end
            end













            if(~isempty(errorMessage))
                error(message('SystemArchitecture:Import:ImportError',errorMessage));
            end
        end


        function checkForMissingValues(obj)


            missing=any(any(ismember(ismissing(obj.compTable),1,'legacy')));
            if missing
                error(message('SystemArchitecture:Import:MissingValues','Components'));
            end

            if~isempty(obj.portTable)
                missing=any(any(ismember(ismissing(obj.portTable),1,'legacy')));
                if missing
                    error(message('SystemArchitecture:Import:MissingValues','Ports'));
                end
            end
            if~isempty(obj.connxTable)
                missing=any(any(ismember(ismissing(obj.connxTable),1,'legacy')));
                if missing
                    error(message('SystemArchitecture:Import:MissingValues','Connections'));
                end
            end
            if~isempty(obj.portInterfaceTable)
                missing=any(any(ismember(ismissing(obj.portInterfaceTable),1,'legacy')));
                if missing
                    error(message('SystemArchitecture:Import:MissingValues','Interfaces'));
                end
            end
        end

        function checkForEmptyID(obj)

            empty=any(ismember(obj.compTable.ID,""));
            if empty
                error(message('SystemArchitecture:Import:EmptyCompIDValues'));
            end

            if~isempty(obj.portTable)
                empty=any(ismember(obj.portTable.ID,""));
                if empty
                    error(message('SystemArchitecture:Import:EmptyPortIDValues'));
                end
            end
            if~isempty(obj.connxTable)
                empty=any(ismember(obj.connxTable.ID,""));
                if empty
                    error(message('SystemArchitecture:Import:EmptyConnIDValues'));
                end
            end
            if~isempty(obj.portInterfaceTable)
                empty=any(ismember(obj.portInterfaceTable.ID,""));
                if empty
                    error(message('SystemArchitecture:Import:EmptyInterfaceIDValues'));
                end
            end
        end

        function propertyType=getPropertyType(obj,prototype,propertyName)

            propertyType={};

            if(~isempty(prototype))
                propDef=prototype.propertySet.getPropertyByName(propertyName);
                if~isempty(propDef)


                    if isa(propDef.ownedType,'systemcomposer.property.Enumeration')
                        propertyType='enum';
                    else
                        propertyType=propDef.ownedType.baseType.getName;
                    end
                else
                    propertyType=obj.getPropertyType(prototype.parent,propertyName);
                end
            end
        end

        function addFunctionArguments(obj,elem,elemID)

            elementsInRow=obj.portInterfaceTable(ismember(obj.portInterfaceTable.ParentID,elemID),:);


            for elemItr=1:numel(elementsInRow(:,1))

                argName=char(elementsInRow.Name(elemItr));

                arg=elem.getFunctionArgument(argName);


                argType=elementsInRow(elemItr,:).DataType;
                argDims=elementsInRow(elemItr,:).Dimensions;
                argUnits=elementsInRow(elemItr,:).Units;
                argComplexity=elementsInRow(elemItr,:).Complexity;
                argMinimum=elementsInRow(elemItr,:).Minimum;
                argMaximum=elementsInRow(elemItr,:).Maximum;

                typeIntrf=elem.Interface.Dictionary.getInterface(argType);
                if~isempty(typeIntrf)

                    arg.setType(typeIntrf);
                else
                    arg.createOwnedType('DataType',argType,'Dimensions',argDims,...
                    'Units',argUnits,'Complexity',argComplexity,...
                    'Minimum',argMinimum,'Maximum',argMaximum);
                end
            end

        end

        function obj=addInterfaceTableToModel(obj,model)



            if(~isempty(model)&&isa(model,'systemcomposer.arch.Model'))
                expectedColNames={'Name','ID','ParentID','DataType','Dimensions','Units','Complexity','Minimum','Maximum'};

                if(~isempty(obj.portInterfaceTable)&&all(ismember(expectedColNames,obj.portInterfaceTable.Properties.VariableNames)))


                    interfaces=obj.portInterfaceTable(ismember(obj.portInterfaceTable.ParentID,""),:);


                    interfacesToSkip=[];
                    for interItr=1:numel(interfaces(:,1))

                        interfaceName=interfaces(interItr,:).Name;
                        interfaceType=interfaces(interItr,:).DataType;



                        if(~isempty(interfaceName)&&~strcmp(interfaceName,""))

                            interface=obj.addInterfacebyName(interfaceName,interfaceType);
                            if isa(interface,'systemcomposer.ValueType')
                                interface.DataType=interfaces(interItr,:).DataType;
                                interface.Dimensions=interfaces(interItr,:).Dimensions;
                                interface.setUnits(interfaces(interItr,:).Units);
                                interface.Complexity=interfaces(interItr,:).Complexity;
                                interface.Minimum=interfaces(interItr,:).Minimum;
                                interface.Maximum=interfaces(interItr,:).Maximum;
                                if any(ismember(interfaces.Properties.VariableNames,'Description'))
                                    interface.Description=interfaces(interItr,:).Description;
                                end
                            end
                            if(isempty(interface))
                                interfacesToSkip=[interfacesToSkip,interItr];
                                errorMessage=message('SystemArchitecture:Import:DuplicateInterfaceNameFound',interfaceName);
                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                            end
                        end
                    end


                    for interItr=1:numel(interfaces(:,1))

                        if any(ismember(interfacesToSkip,interItr))
                            continue;
                        end


                        interfaceName=interfaces(interItr,:).Name;
                        interfaceID=interfaces(interItr,:).ID;



                        if(~isempty(interfaceName)&&~strcmp(interfaceName,""))

                            interface=obj.getInterfacebyName(interfaceName);


                            if(~isempty(interface))

                                interface.set('ExternalUID',interfaceID);

                                [interface,obj]=obj.applyPrototypeProperties(interface,interfaces(interItr,:));

                                elementsRow=obj.portInterfaceTable(ismember(obj.portInterfaceTable.ParentID,interfaceID),:);

                                for elemItr=1:numel(elementsRow(:,1))

                                    elemName=char(elementsRow.Name(elemItr));
                                    elemID=elementsRow.ID(elemItr);
                                    try

                                        interface.addElement(elemName);


                                        elemType=char(elementsRow.DataType(elemItr));
                                        elemDimension=char(elementsRow.Dimensions(elemItr));
                                        elemUnits=char(elementsRow.Units(elemItr));
                                        elemComplexity=char(elementsRow.Complexity(elemItr));
                                        elemMin=char(elementsRow.Minimum(elemItr));
                                        elemMax=char(elementsRow.Maximum(elemItr));
                                        elemDescr='';
                                        if any(ismember(elementsRow.Properties.VariableNames,'Description'))
                                            elemDescr=char(elementsRow.Description(elemItr));
                                        end
                                        elemPrototype='';
                                        elemAsynchronous=false;
                                        if any(ismember(elementsRow.Properties.VariableNames,'FunctionPrototype'))
                                            elemPrototype=char(elementsRow.FunctionPrototype(elemItr));
                                        end
                                        if any(ismember(elementsRow.Properties.VariableNames,'Asynchronous'))







                                            elemAsynchronous=strcmp(elementsRow.Asynchronous(elemItr),"true");
                                        end
                                        element=interface.getElement(elemName);
                                        isTypeReferenced=false;

                                        if(~isempty(element))

                                            if isa(element,'systemcomposer.interface.FunctionElement')
                                                if~isempty(elemPrototype)
                                                    if~strcmpi(elemPrototype,element.FunctionPrototype)
                                                        element.setFunctionPrototype(elemPrototype);
                                                    end

                                                    obj.addFunctionArguments(element,elemID);
                                                    isTypeReferenced=true;
                                                end
                                                if~isempty(elemAsynchronous)
                                                    if elemAsynchronous~=element.Asynchronous
                                                        element.setAsynchronous(elemAsynchronous);
                                                    end
                                                end
                                            else
                                                try
                                                    typeIntrf=interface.Owner.getInterface(elemType);
                                                    if~isempty(typeIntrf)
                                                        isTypeReferenced=true;
                                                        element.setType(typeIntrf);
                                                    else
                                                        element.setTypeFromString(string(elemType));
                                                    end
                                                catch

                                                    errorMessage=message('SystemArchitecture:Import:ElementDataTypeError',elemName,interfaceName,elemType);
                                                    obj.importErrorsLog=[obj.importErrorsLog,errorMessage];

                                                    interface.removeElement(elemName);
                                                    continue;
                                                end
                                            end

                                            if~isa(element,'systemcomposer.interface.PhysicalElement')
                                                if(~isempty(elemDimension)&&~isTypeReferenced)
                                                    element.setDimensions(elemDimension);
                                                end
                                                if(~isempty(elemUnits)&&~isTypeReferenced)
                                                    element.setUnits(elemUnits);
                                                end
                                                if(~isempty(elemComplexity)&&~isTypeReferenced)
                                                    element.setComplexity(elemComplexity);
                                                end
                                                if(~isempty(elemMin)&&~isTypeReferenced)
                                                    element.setMinimum(elemMin);
                                                end
                                                if(~isempty(elemMax)&&~isTypeReferenced)
                                                    element.setMaximum(elemMax);
                                                end
                                                if(~isempty(elemDescr)&&~isTypeReferenced)
                                                    element.setDescription(elemDescr);
                                                end
                                            end
                                            element.set('ExternalUID',elemID);

                                            mssg=message('SystemArchitecture:Import:ElementAdded',elemName,interfaceName).getString;
                                            obj.importLogger=[obj.importLogger,mssg];
                                        end
                                    catch exception
                                        combinedExceptionMessage=exception.message;
                                        for exceptionCause=exception.cause
                                            combinedExceptionMessage=[combinedExceptionMessage,newline,exceptionCause.message];
                                        end
                                        errorMessage=message('SystemArchitecture:Import:ElementAdditionFailed',elemName,interfaceName,combinedExceptionMessage);
                                        obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                                    end
                                end
                                mssg=message('SystemArchitecture:Import:InterfaceAdded',interfaceName).getString;
                                obj.importLogger=[obj.importLogger,mssg];
                            else
                                errorMessage=message('SystemArchitecture:Import:DuplicateInterfaceNameFound',interfaceName);
                                obj.importErrorsLog=[obj.importErrorsLog,errorMessage];
                            end
                        end
                    end
                end
            end
        end


        function intrf=addInterfacebyName(obj,portInterfaceName,interfaceType)
            portInterfaceNames=obj.archModel.InterfaceDictionary.getInterfaceNames;
            intrf='';

            if(~ismember(portInterfaceName,portInterfaceNames))
                if strcmpi(interfaceType,"DataInterface")||interfaceType.matches("")
                    intrf=obj.archModel.InterfaceDictionary.addInterface(char(portInterfaceName));
                elseif strcmpi(interfaceType,"PhysicalInterface")
                    intrf=obj.archModel.InterfaceDictionary.addPhysicalInterface(char(portInterfaceName));
                elseif strcmpi(interfaceType,"ServiceInterface")
                    intrf=obj.archModel.InterfaceDictionary.addServiceInterface(char(portInterfaceName));
                else
                    intrf=obj.archModel.InterfaceDictionary.addValueType(char(portInterfaceName));
                end
            end
        end


        function intrf=getInterfacebyName(obj,portInterfaceName)
            intrf=obj.archModel.InterfaceDictionary.getInterface(portInterfaceName);
        end
    end
end

function prototypeColNames=readPrototypeNamesFromTable(metaclassTable)


    prototypeColNames=[];
    if ismember('StereotypeNames',metaclassTable.Properties.VariableNames)
        prototypeColNames=metaclassTable.StereotypeNames;
    end
end



