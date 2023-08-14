classdef exportModelClass<handle





    properties(Access=public,Hidden)

        archModel;
        refModel;


        exportErrorsLog=[];


        compTable;
        portTable;
        connxnTable;
        portInterfaceTable;
        RequirementLinksTable;
        functionTable;


        exportedSet={};


        changedSet={};
    end

    properties(Access=private,Hidden=true)

        checkChange=0;


        componentsCount=0;
        portsCount=0;
        connectionCount=0;
        interfacesCount=0;
        reqLinksCount=0;
        functionsCount=0;


        portUUIDMap;
        profilesMap;
compUUIDMap


        componentsUID;
        portsUID;
        connxnUID;
        interfacesUID;


        minCompTableColNames;
        minPortTableColNames;
        minConnectionTableColNames;
        minInterfacesTableColNames;
        minFunctionTableColNames;


        compTableColNames;
        portTableColNames;
        connectionTableColNames;
        interfacesTableColNames;
        reqLinksTableColNames;
        functionTableColNames;
    end

    methods

        function obj=exportModelClass(modelInfo,refModelInfo)


            if(nargin<2)
                refModelInfo={};
            end
            obj.runValidationChecks(modelInfo,refModelInfo);



            obj.portUUIDMap=containers.Map('keytype','char','valuetype','any');


            obj.compUUIDMap=containers.Map('keytype','char','valuetype','any');


            obj.profilesMap=containers.Map('keytype','char','valuetype','any');


            obj.initializeDefaultColumnNames();


            obj.identifyAndAppendColumnNamesFromProfiles();


            try
                [obj.componentsUID,obj.portsUID,obj.connxnUID,obj.interfacesUID]=systemcomposer.internal.getAllExternalUIDs(obj.archModel);
            catch ME
                obj.logErrorwithStack('SystemArchitecture:Export:ErrorReadingExternalUID',ME,obj.archModel);
            end


            obj.createTablesFromColumnNames();


            obj.populateInterfaceTable();


            obj.populateComponentTable();


            obj.populatePortTable();


            obj.populateConnectionTable();



            obj.compareWithRefModel();


            obj.populateRequirementTable();


            if Simulink.internal.isArchitectureModel(obj.archModel.SimulinkHandle,'SoftwareArchitecture')||...
                Simulink.internal.isArchitectureModel(obj.archModel.SimulinkHandle,'AUTOSARArchitecture')
                obj.populateFunctionTable();
            end



            obj.checkForDuplicateUID();


            obj.removeUnusedColumns();
        end
    end

    methods(Access=private)


        function runValidationChecks(obj,modelInfo,refModelInfo)




            if(isa(modelInfo,'char')||isa(modelInfo,'string'))
                if systemcomposer.internal.isSystemComposerModel(modelInfo)
                    try
                        obj.archModel=systemcomposer.loadModel(modelInfo);
                    catch ex
                        ME=MSLException('SystemArchitecture:Export:UnableToLoadModel',modelInfo);
                        ME=ME.addCause(ex);
                        throw(ME);
                    end
                elseif~isempty(get_param(modelInfo,'SystemComposerModel'))
                    obj.archModel=get_param(modelInfo,'SystemComposerModel');
                else
                    ME=MSLException('SystemArchitecture:Export:NonSystemComposerModel',modelInfo);
                    throw(ME);
                end
            elseif(isa(modelInfo,'systemcomposer.arch.Model'))
                obj.archModel=modelInfo;
            else
                ME=MSLException('SystemArchitecture:Export:NonSystemComposerModel',modelInfo);
                throw(ME);
            end




            if~isempty(refModelInfo)

                if(isa(refModelInfo,'char')||isa(refModelInfo,'string'))
                    try
                        obj.refModel=systemcomposer.loadModel(refModelInfo);
                        obj.checkChange=1;
                    catch ex
                        ME=MSLException('SystemArchitecture:Export:ContinueWithoutReference');
                        MECause=MSLException('SystemArchitecture:Export:UnableToLoadModel',refModelInfo);
                        MECause=MECause.addCause(ex);
                        ME=ME.addCause(MECause);
                        ME.reportAsWarning;
                        obj.exportErrorsLog=[obj.exportErrorsLog,ME.getReport()];
                    end
                elseif(isa(refModelInfo,'systemcomposer.arch.Model'))
                    obj.refModel=refModelInfo;
                    obj.checkChange=1;
                else
                    ME=MSLException('SystemArchitecture:Export:ContinueWithoutReference');
                    MECause=MSLException('SystemArchitecture:Import:InvalidModel');
                    ME=ME.addCause(MECause);
                    ME.reportAsWarning;
                    obj.exportErrorsLog=[obj.exportErrorsLog,ME.getReport()];
                end
            else
                obj.checkChange=0;
                obj.refModel={};
            end



            assert(~isempty(obj.archModel));


            if obj.archModel.getImpl.containsReferenceArchitectureCycle
                ME=MSLException('SystemArchitecture:Export:CantExportCycle',obj.archModel.Name);
                throw(ME);
            end
        end


        function initializeDefaultColumnNames(obj)




            obj.minCompTableColNames={'Name','ID','ParentID'};
            obj.minPortTableColNames={'Name','Direction','ID','CompID'};
            obj.minConnectionTableColNames={'Name','ID','SourcePortID','DestPortID'};
            obj.minInterfacesTableColNames={'Name','ID','ParentID','DataType','Dimensions','Units','Complexity','Minimum','Maximum'};
            obj.minFunctionTableColNames={'Name','ExecutionOrder','CompID'};





            obj.compTableColNames=[obj.minCompTableColNames,{'ReferenceModelName','ComponentType','ActiveChoice','VariantControl','VariantCondition','StereotypeNames'}];
            obj.portTableColNames=[obj.minPortTableColNames,{'InterfaceID','StereotypeNames'}];
            obj.connectionTableColNames={'Name','ID','Kind','SourcePortID','DestPortID','PortIDs','SourceElement','DestinationElement','StereotypeNames'};
            obj.interfacesTableColNames=[obj.minInterfacesTableColNames,{'Description','FunctionPrototype','Asynchronous','StereotypeNames'}];
            obj.reqLinksTableColNames={'Label','ID','SourceID','DestinationType','DestinationID','ReferencedReqID','DestinationArtifact','SourceArtifact','Type','Keywords','CreatedOn','CreatedBy','ModifiedOn','ModifiedBy','Revision'};
            obj.functionTableColNames={'Name','ExecutionOrder','CompID','Period','StereotypeNames'};
        end




        function identifyAndAppendColumnNamesFromProfiles(obj)


            import systemcomposer.internal.profile.*;


            protoPropNameMap=containers.Map('keytype','char','valuetype','any');

            compPrototypeNames={};
            portsPrototypeNames={};
            connxnPrototypeNames={};
            interfacePrototypeNames={};


            compPropertyColumnName={};
            portPropertyColumnName={};
            connxnPropertyColumnName={};
            interfacePropertyColumnName={};

            try

                archProfiles=obj.archModel.Profiles;
                interfaceProfiles=obj.archModel.InterfaceDictionary.Profiles;
                profiles=[archProfiles,interfaceProfiles];


                for profItr=1:numel(profiles)
                    profileName=char(profiles(profItr).Name);
                    if(~obj.profilesMap.isKey(profileName)&&~strcmp(profileName,'systemcomposer'))
                        obj.profilesMap(profileName)=profiles(profItr);
                        prototypes=profiles(profItr).Stereotypes;
                        for protItr=1:numel(prototypes)
                            prototype=prototypes(protItr);
                            if(~isempty(prototype))
                                properties=obj.getPrototypePropertyNames(prototype);

                                if(~(prototype.Abstract))





                                    protoPropNameMap(prototype.FullyQualifiedName)=properties;
                                    if(isequal(prototype.getExtendedElement,'Component'))
                                        compPrototypeNames=[compPrototypeNames;prototype.FullyQualifiedName];%#ok<*AGROW>
                                    elseif(isequal(prototype.getExtendedElement,'Port'))
                                        portsPrototypeNames=[portsPrototypeNames;prototype.FullyQualifiedName];
                                    elseif(isequal(prototype.getExtendedElement,'Connector'))
                                        connxnPrototypeNames=[connxnPrototypeNames;prototype.FullyQualifiedName];
                                    elseif(isequal(prototype.getExtendedElement,'Interface'))
                                        interfacePrototypeNames=[interfacePrototypeNames;prototype.FullyQualifiedName];
                                    end
                                end
                            end
                        end
                    end
                end


                nonAbstractPrototypeList=protoPropNameMap.keys;
                for protoMapItr=1:numel(nonAbstractPrototypeList)

                    protoQualName=nonAbstractPrototypeList(protoMapItr);
                    posIdentifier=strfind(protoQualName,'.');
                    protoQualName{:}(cell2mat(posIdentifier))='_';
                    propertylist=protoPropNameMap(nonAbstractPrototypeList{protoMapItr});
                    for propItr=1:numel(propertylist)
                        propName=propertylist(propItr);
                        if(ismember(nonAbstractPrototypeList(protoMapItr),compPrototypeNames))
                            compPropertyColumnName=[compPropertyColumnName,strcat(protoQualName,'_',propName)];
                        elseif(ismember(nonAbstractPrototypeList(protoMapItr),portsPrototypeNames))
                            portPropertyColumnName=[portPropertyColumnName,strcat(protoQualName,'_',propName)];
                        elseif(ismember(nonAbstractPrototypeList(protoMapItr),connxnPrototypeNames))
                            connxnPropertyColumnName=[connxnPropertyColumnName,strcat(protoQualName,'_',propName)];
                        elseif(ismember(nonAbstractPrototypeList(protoMapItr),interfacePrototypeNames))
                            interfacePropertyColumnName=[interfacePropertyColumnName,strcat(protoQualName,'_',propName)];
                        end
                    end
                end
            catch ME


                obj.logErrorwithStack('SystemArchitecture:Export:ErrorReadingProfiles',ME,obj.archModel);
            end


            obj.compTableColNames=[obj.compTableColNames,compPropertyColumnName];
            obj.portTableColNames=[obj.portTableColNames,portPropertyColumnName];
            obj.connectionTableColNames=[obj.connectionTableColNames,connxnPropertyColumnName];
            obj.interfacesTableColNames=[obj.interfacesTableColNames,interfacePropertyColumnName];
        end



        function createTablesFromColumnNames(obj)
            try

                obj.compTable=cell2table(cell(0,numel(obj.compTableColNames)),'VariableNames',obj.compTableColNames);


                obj.portTable=cell2table(cell(0,numel(obj.portTableColNames)),'VariableNames',obj.portTableColNames);


                obj.connxnTable=cell2table(cell(0,numel(obj.connectionTableColNames)),'VariableNames',obj.connectionTableColNames);


                obj.RequirementLinksTable=cell2table(cell(0,numel(obj.reqLinksTableColNames)),'VariableNames',obj.reqLinksTableColNames);


                obj.portInterfaceTable=cell2table(cell(0,numel(obj.interfacesTableColNames)),'VariableNames',obj.interfacesTableColNames);


                if Simulink.internal.isArchitectureModel(obj.archModel.SimulinkHandle,'SoftwareArchitecture')||...
                    Simulink.internal.isArchitectureModel(obj.archModel.SimulinkHandle,'AUTOSARArchitecture')

                    obj.functionTable=cell2table(cell(0,numel(obj.functionTableColNames)),'VariableNames',...
                    obj.functionTableColNames);
                end

            catch ME


                MECombined=obj.logErrorwithStack('SystemArchitecture:Export:ErrorCreatingTables',ME);
                throw(MECombined);
            end
        end


        function populateComponentTable(obj)
            try

                rootArch=get(obj.archModel,'Architecture');


                childComponents=get(rootArch,'Components');



                obj.compTable=[obj.compTable;cell2table(repmat({""},1,numel(obj.compTableColNames)),'VariableName',obj.compTableColNames)];%#ok<STRSCALR>
                obj.compTable.ID(end)="0";
                obj.compTable.Name(end)="root";
                obj.compTable.ParentID(end)="";
                obj.compTable.ComponentType=obj.archModel.Architecture.Definition.string;


                for compItr=1:numel(childComponents)
                    obj=obj.addComp2table(childComponents(compItr),"0");
                end
            catch ME


                obj.logErrorwithStack('SystemArchitecture:Export:ErrorPopulatingCompTable',ME);
            end

            try

                [addedRow,columnAdded]=obj.addPropertyValue(rootArch,obj.compTable(1,:));
                if numel(columnAdded)>0
                    for colItr=1:numel(columnAdded)

                        rowSize=size(obj.compTable,1);
                        appendedTable=table(repmat("",rowSize,1),'VariableNames',columnAdded(colItr));
                        obj.compTable=[obj.compTable,appendedTable];
                        obj.compTableColNames=[obj.compTableColNames,columnAdded(colItr)];
                    end
                end
                obj.compTable(1,:)=addedRow;
            catch ME


                obj.logErrorwithStack('SystemArchitecture:Export:ErrorPopulatingStereotypesToCompTable',ME);
            end
        end


        function populatePortTable(obj)
            try

                rootArch=get(obj.archModel,'Architecture');



                obj.addPort2table(rootArch,"0",strcat(rootArch.Name,':',rootArch.Name));
            catch ME


                obj.logErrorwithStack('SystemArchitecture:Export:ErrorPopulatingPortTable',ME);
            end
        end


        function populateConnectionTable(obj)

            try

                rootArch=get(obj.archModel,'Architecture');


                obj.addConnection2table(rootArch);
            catch ME


                obj.logErrorwithStack('SystemArchitecture:Export:ErrorPopulatingConxTable',ME);
            end
        end


        function compareWithRefModel(obj)

            if(obj.checkChange)

                [refModelSet,~]=systemcomposer.exportModel(obj.refModel);
                if(~isempty(refModelSet))




                    [compAdded,compModified,compDeleted]=systemcomposer.internal.getTableDifferences(obj.compTable,refModelSet.components,'ID');
                    [portAdded,portModified,portDeleted]=systemcomposer.internal.getTableDifferences(obj.portTable,refModelSet.ports,'ID');
                    [interfacesAdded,interfacesModified,interfacesDeleted]=systemcomposer.internal.getTableDifferences(obj.portInterfaceTable,refModelSet.portInterfaces,'ID');
                    [connxnAdded,connxnModified,connxnDeleted]=systemcomposer.internal.getTableDifferences(obj.connxnTable,refModelSet.connections,'ID');


                    obj.changedSet.components.added=compAdded;
                    obj.changedSet.components.modified=compModified;
                    obj.changedSet.components.deleted=compDeleted;

                    obj.changedSet.ports.added=portAdded;
                    obj.changedSet.ports.modified=portModified;
                    obj.changedSet.ports.deleted=portDeleted;

                    obj.changedSet.connections.added=connxnAdded;
                    obj.changedSet.connections.modified=connxnModified;
                    obj.changedSet.connections.deleted=connxnDeleted;

                    obj.changedSet.interfaces.added=interfacesAdded;
                    obj.changedSet.interfaces.modified=interfacesModified;
                    obj.changedSet.interfaces.deleted=interfacesDeleted;

                end
            end
        end



        function populateRequirementTable(obj)
            try
                reqSet=slreq.find('Type','LinkSet','Artifact',get_param(obj.archModel.Name,'FileName'));
                if~isempty(reqSet)
                    reqLinks=reqSet.getLinks();
                    for i=1:numel(reqLinks)
                        obj=obj.addRequirementLinksToTable(reqLinks(i));
                    end
                end
            catch ME


                obj.logErrorwithStack('SystemArchitecture:Export:ErrorPopulatingReqsTable',ME);
            end
        end


        function populateFunctionTable(obj)

            rootArch=get(obj.archModel,'Architecture');
            if isprop(rootArch,'Functions')
                obj.addFunction2table(rootArch);
            end
        end


        function removeUnusedColumns(obj)
            try

                obj.exportedSet.components=obj.convertTableInputs(obj.compTable,obj.minCompTableColNames);
                obj.exportedSet.ports=obj.convertTableInputs(obj.portTable,obj.minPortTableColNames);
                obj.exportedSet.connections=obj.convertTableInputs(obj.connxnTable,obj.minConnectionTableColNames);
                obj.exportedSet.portInterfaces=obj.convertTableInputs(obj.portInterfaceTable,obj.minInterfacesTableColNames);
                obj.exportedSet.requirementLinks=obj.RequirementLinksTable;

                if Simulink.internal.isArchitectureModel(obj.archModel.SimulinkHandle,'SoftwareArchitecture')||...
                    Simulink.internal.isArchitectureModel(obj.archModel.SimulinkHandle,'AUTOSARArchitecture')
                    obj.exportedSet.domain=getString(message('SystemArchitecture:Import:SoftwareDomain'));
                    obj.exportedSet.functions=obj.convertTableInputs(obj.functionTable,...
                    obj.minFunctionTableColNames);
                else
                    obj.exportedSet.domain=getString(message('SystemArchitecture:Import:SystemDomain'));
                end
            catch ME


                obj.logErrorwithStack('SystemArchitecture:Export:ErrorPostProcessingTable',ME);
            end
        end



        function obj=addRequirementLinksToTable(obj,reqLink)
            linkSource=reqLink.source;
            fullSID='';
            blkObj=[];
            if contains(linkSource.id,'ZC:')

                zcElem=sysarch.resolveZCElement(linkSource.id,obj.archModel.Name);
                zcElem=systemcomposer.internal.getWrapperForImpl(zcElem);


                if isa(zcElem,'systemcomposer.arch.BasePort')
                    portName=zcElem.Name;
                    portDir=zcElem.Direction;
                    parentName=zcElem.Parent.Name;

                    if isequal(zcElem.Parent,obj.archModel.Architecture)
                        parentName='root';
                    end
                    idx=find(obj.portTable.Name==portName==1);
                    if numel(idx)>0

                        for m=1:numel(idx)
                            if strcmpi(obj.portTable(idx(m),:).Direction,char(portDir))
                                x=find(obj.compTable.ID==obj.portTable(idx(m),:).CompID==1);
                                if strcmpi(obj.compTable(x,:).Name,parentName)
                                    idx=idx(m);
                                    fullSID=['ports:',obj.portTable(idx,:).ID.char];
                                    break;
                                end
                            end
                        end

                    end
                end
            elseif contains(linkSource.id,':')
                fullSID=[obj.archModel.Name,linkSource.id];
                try
                    blkHndl=Simulink.ID.getHandle(fullSID);
                    blkObj=get_param(blkHndl,'Object');
                catch
                    blkObj=[];
                end
            elseif isempty(linkSource.id)

                [~,mdlName,~]=fileparts(linkSource.artifact);
                fullSID=mdlName;
                blkObj=get_param(mdlName,'Object');
            end
            if~isempty(blkObj)
                switch class(blkObj)
                case{'Simulink.SubSystem','Simulink.ModelReference'}
                    idx=find(obj.compTable.Name==blkObj.Name==1);
                    if numel(idx)>1

                        for m=1:numel(idx)
                            x=find(obj.compTable.ID==obj.compTable(idx(m),:).ParentID==1);
                            if strcmpi(obj.compTable(x,:).Name,blkObj.getParent.Name)
                                fullSID=['components:',obj.compTable(idx(m),:).ID.char];
                                break;
                            end
                        end
                    elseif~isempty(idx)
                        fullSID=['components:',obj.compTable(idx,:).ID.char];
                    end
                case{'Simulink.BlockDiagram'}
                    idx=find(obj.compTable.Name=='root'==1);

                    if~isempty(idx)
                        fullSID=['components:',obj.compTable(idx(1),:).ID.char];
                    end
                otherwise
                end
            end
            lnk=reqLink;
            destination=lnk.destination;
            obj.reqLinksCount=obj.reqLinksCount+1;
            obj.RequirementLinksTable=[obj.RequirementLinksTable;cell2table(repmat({""},1,numel(obj.reqLinksTableColNames)),'VariableName',obj.reqLinksTableColNames)];
            obj.RequirementLinksTable.ID(end)=string(obj.reqLinksCount);
            obj.RequirementLinksTable.SourceArtifact(end)=lnk.source.artifact;
            if~isempty(fullSID)
                obj.RequirementLinksTable.SourceID(end)=fullSID;
            end
            obj.RequirementLinksTable.Label(end)=lnk.Description;
            if~isempty(destination)
                obj.RequirementLinksTable.DestinationType(end)=destination.domain;
                if isfield(destination,'artifact')
                    [~,file,extn]=fileparts(destination.artifact);
                    if strcmp(extn,'.slx')
                        obj.RequirementLinksTable.DestinationID(end)=[file,destination.id];
                    else
                        obj.RequirementLinksTable.DestinationID(end)=[destination.artifact,'#',strrep(destination.id,'#','')];
                    end
                    obj.RequirementLinksTable.DestinationArtifact(end)=destination.artifact;
                else
                    obj.RequirementLinksTable.DestinationID(end)=[destination.reqSet,'#',num2str(destination.sid)];
                    req=slreq.structToObj(destination);
                    obj.RequirementLinksTable.DestinationArtifact(end)=req.parent.Filename;
                end
            end
            refInfo=lnk.getReferenceInfo;
            try
                refObj=slreq.structToObj(refInfo);
                if isa(refObj,'slreq.Reference')
                    reqSet=refObj.reqSet;
                    obj.RequirementLinksTable.ReferencedReqID(end)=[reqSet.Name,'#',refObj.Id];
                end
            catch
            end
            obj.RequirementLinksTable.Type(end)=lnk.Type;
            if~isempty(lnk.Keywords)
                obj.RequirementLinksTable.Keywords(end)=lnk.Keywords;
            end
            obj.RequirementLinksTable.Type(end)=lnk.Type;
            obj.RequirementLinksTable.CreatedOn(end)=lnk.CreatedOn;
            obj.RequirementLinksTable.CreatedBy(end)=lnk.CreatedBy;
            obj.RequirementLinksTable.ModifiedOn(end)=lnk.ModifiedOn;
            obj.RequirementLinksTable.ModifiedBy(end)=lnk.ModifiedBy;
            obj.RequirementLinksTable.Revision(end)=lnk.Revision;
        end


        function[obj,compId]=addComp2table(obj,comp,parentCompID)

            obj.componentsCount=obj.componentsCount+1;
            compName=get(comp,'Name');
            compId=obj.componentsCount;
            externalUID=get(comp,'ExternalUID');
            isVariant=false;
            isLabelMode=false;
            contextName=strcat(comp.Parent.getQualifiedName,':',compName);

            obj.compTable=[obj.compTable;cell2table(repmat({""},1,numel(obj.compTableColNames)),'VariableName',obj.compTableColNames)];

            if~isempty(externalUID)

                obj.compTable.ID(end)=string(externalUID);
                compId=externalUID;
            else


                while ismember(string(compId),obj.componentsUID)
                    compId=compId+numel(obj.componentsUID);
                end
                compId=string(num2str(compId));
                obj.compTable.ID(end)=compId;

                obj.componentsUID=[obj.componentsUID;compId];
            end




            obj.compUUIDMap(comp.UUID)=compId;



            obj.compTable.Name(end)=compName;
            obj.compTable.ParentID(end)=parentCompID;

            if(comp.isReference)
                referenceName=comp.ReferenceName;
                if isequal(exist(char(referenceName),'file'),4)



                    systemcomposer.loadModel(referenceName);


                    definitionType=get(comp.Architecture,'Definition');

                    obj.compTable.ReferenceModelName(end)=referenceName;
                    obj.compTable.ComponentType(end)=definitionType.string;
                else
                    obj.compTable.ReferenceModelName(end)=referenceName;

                    warning(message('SystemArchitecture:Import:ExportReferenceError',referenceName,compName));
                end
            elseif isa(comp,'systemcomposer.arch.VariantComponent')


                choices=comp.getChoices;
                activeChoice=comp.getActiveChoice;
                if~isempty(activeChoice)
                    obj.compTable.ActiveChoice(end)=activeChoice.Name;
                    isLabelMode=true;
                end
                obj.compTable.ComponentType(end)="Variant";
                isVariant=true;
                if(numel(choices)>0)
                    for choiceItr=1:numel(choices)

                        [obj,choiceID]=obj.addComp2table(choices(choiceItr),compId);
                        if isLabelMode
                            obj.compTable.VariantControl(ismember(obj.compTable.ID,string(choiceID)))=comp.getCondition(choices(choiceItr));
                        else
                            obj.compTable.VariantCondition(ismember(obj.compTable.ID,string(choiceID)))=comp.getCondition(choices(choiceItr));
                        end
                    end
                end
            elseif comp.IsAdapterComponent||systemcomposer.internal.isAdapter(comp.SimulinkHandle)

                obj.compTable.ComponentType(end)='Adapter';
            else

                obj.compTable.ComponentType(end)=comp.Architecture.Definition;
            end

            if~comp.isReference

                [addedRow,columnAdded]=obj.addPropertyValue(comp,obj.compTable(end,:));
                if numel(columnAdded)>0
                    for colItr=1:numel(columnAdded)

                        rowSize=size(obj.compTable,1);
                        appendedTable=table(repmat("",rowSize,1),'VariableNames',columnAdded(colItr));
                        obj.compTable=[obj.compTable,appendedTable];
                        obj.compTableColNames=[obj.compTableColNames,columnAdded(colItr)];
                    end
                end
                obj.compTable(end,:)=addedRow;
            end



            if~isVariant&&~comp.isReference

                compArch=get(comp,'Architecture');

                obj.addPort2table(compArch,compId,contextName);

                childComponents=get(compArch,'Components');
                if(numel(childComponents)>0)
                    for childItr=1:numel(childComponents)
                        obj=obj.addComp2table(childComponents(childItr),compId);
                    end
                end
                if~comp.IsAdapterComponent
                    obj.addConnection2table(compArch);
                end
            elseif comp.isReference





                referenceName=comp.ReferenceName;
                if isequal(exist(char(referenceName),'file'),4)
                    obj.addPort2table(comp.Architecture,compId,contextName);
                end
            else
                obj.addPort2table(comp,compId,contextName);
            end
        end

        function addPort2table(obj,compArchHandle,compId,contextName)


            ports=get(compArchHandle,'Ports');
            for portItr=1:numel(ports)
                if isa(compArchHandle,'systemcomposer.arch.VariantComponent')

                    archPort=ports(portItr).ArchitecturePort;
                else
                    archPort=ports(portItr);
                end
                obj.portsCount=obj.portsCount+1;
                portName=get(archPort,'Name');
                portDir=char(get(archPort,'Direction'));
                portUUID=get(archPort,'UUID');
                externalUIDPort=get(archPort,'ExternalUID');
                portId=obj.portsCount;


                obj.portTable=[obj.portTable;cell2table(repmat({""},1,numel(obj.portTableColNames)),'VariableName',obj.portTableColNames)];
                obj.portTable.Name(end)=portName;

                if~isempty(externalUIDPort)
                    obj.portTable.ID(end)=string(externalUIDPort);
                    portId=externalUIDPort;
                else

                    while ismember(string(portId),obj.portsUID)
                        portId=portId+numel(obj.portsUID);
                    end
                    portId=string(num2str(portId));
                    obj.portTable.ID(end)=num2str(portId);
                    obj.portsUID=[obj.portsUID;string(portId)];
                end
                obj.portTable.Direction(end)=portDir;
                obj.portTable.CompID(end)=compId;







                uniqID=strcat(contextName,':',portUUID);
                obj.portUUIDMap(uniqID)=portId;



                if isa(compArchHandle,'systemcomposer.arch.Architecture')&&~strcmp(compArchHandle.Model.Name,obj.archModel.Name)


                else

                    [addedRow,columnAdded]=obj.addPropertyValue(archPort,obj.portTable(end,:));
                    if numel(columnAdded)>0
                        for colItr=1:numel(columnAdded)

                            rowSize=size(obj.portTable,1);
                            appendedTable=table(repmat("",rowSize,1),'VariableNames',columnAdded(colItr));
                            obj.portTable=[obj.portTable,appendedTable];
                            obj.portTableColNames=[obj.portTableColNames,columnAdded(colItr)];
                        end
                    end
                    obj.portTable(end,:)=addedRow;


                    [~,interfaceID,obj]=obj.addInterfaceInfo(archPort);
                    if(~strcmp(interfaceID,''))
                        obj.portTable.InterfaceID(end)=interfaceID;
                    end
                end
            end
        end

        function obj=addConnection2table(obj,archHandle)


            connectors=get(archHandle,'Connectors');
            for connxnItr=1:numel(connectors)
                obj.connectionCount=obj.connectionCount+1;
                connectionName=get(connectors(connxnItr),'Name');
                connectorType="Data";
                if isa(connectors(connxnItr),'systemcomposer.arch.PhysicalConnector')
                    connectorType="Physical";
                end

                ports=get(connectors(connxnItr),'Ports');
                srcPort=ports(1);
                destPort=ports(2:end);


                connxnId=obj.connectionCount;



                connectionExternalUID=get(connectors(connxnItr),'ExternalUID');
                connRow=cell2table(repmat({""},1,numel(obj.connectionTableColNames)),'VariableName',obj.connectionTableColNames);
                connRow.Name=string(connectionName);
                connRow.Kind=connectorType;
                if~isempty(connectionExternalUID)
                    connRow.ID=string(connectionExternalUID);
                else

                    while ismember(string(connxnId),obj.connxnUID)
                        connxnId=connxnId+numel(obj.connxnUID);
                    end
                    connRow.ID=string(num2str(connxnId));
                    obj.connxnUID=[obj.connxnUID;string(connxnId)];
                end

                for i=1:numel(destPort)


                    if(isa(srcPort,'systemcomposer.arch.ArchitecturePort')&&isa(destPort(i),'systemcomposer.arch.ComponentPort'))
                        destPortContextName=strcat(archHandle.getQualifiedName,':',destPort(i).Parent.Name);
                        dstPort=destPort(i).ArchitecturePort;
                        srcPortContextName=strcat(obj.getContextNameForArchPort(srcPort),':',srcPort.Parent.Name);
                    elseif(isa(srcPort,'systemcomposer.arch.ComponentPort')&&isa(destPort(i),'systemcomposer.arch.ArchitecturePort'))
                        srcPortContextName=strcat(archHandle.getQualifiedName,':',srcPort.Parent.Name);
                        srcPort=srcPort.ArchitecturePort;
                        dstPort=destPort(i);
                        destPortContextName=strcat(obj.getContextNameForArchPort(destPort(i)),':',destPort(i).Parent.Name);
                    elseif(isa(srcPort,'systemcomposer.arch.ComponentPort')&&isa(destPort(i),'systemcomposer.arch.ComponentPort'))


                        srcPortContextName=strcat(archHandle.getQualifiedName,':',srcPort.Parent.Name);
                        destPortContextName=strcat(archHandle.getQualifiedName,':',destPort(i).Parent.Name);
                        srcPort=srcPort.ArchitecturePort;
                        dstPort=destPort(i).ArchitecturePort;

                    else
                        srcPortContextName=strcat(obj.getContextNameForArchPort(srcPort),':',srcPort.Parent.Name);
                        destPortContextName=strcat(obj.getContextNameForArchPort(destPort(i)),':',destPort(i).Parent.Name);
                        dstPort=destPort(i);
                    end
                    if~isempty(srcPort)&&~isempty(dstPort)


                        srcPortId=get(srcPort,'UUID');
                        destPortId=get(dstPort,'UUID');
                        uniqSrcPortID=strcat(srcPortContextName,':',srcPortId);
                        uniqDstPortID=strcat(destPortContextName,':',destPortId);
                        srcPID=obj.portUUIDMap(uniqSrcPortID);
                        dstPID=obj.portUUIDMap(uniqDstPortID);

                        if connectorType.matches("Physical")
                            if matches(connRow.PortIDs(end),"")
                                connRow.PortIDs=[num2str(srcPID),',',num2str(dstPID)];
                            else
                                connRow.PortIDs=[connRow.PortIDs,',',num2str(dstPID)];
                            end
                        else
                            connRow.SourcePortID=string(srcPID);
                            srcElem=connectors(connxnItr).getSourceElement;
                            dstElem=connectors(connxnItr).getDestinationElement;
                            if~isempty(srcElem)
                                elems=srcElem{1};
                                for k=2:numel(srcElem)
                                    elems=[elems,',',srcElem{k}];
                                end
                                connRow.SourceElement=string(elems);
                            end
                            if~isempty(dstElem)
                                elems=dstElem{1};
                                for k=2:numel(dstElem)
                                    elems=[elems,',',dstElem{k}];
                                end
                                connRow.DestinationElement=string(elems);
                            end
                            connRow.DestPortID=string(dstPID);
                        end
                    end
                end

                connRow.PortIDs=string(connRow.PortIDs);
                obj.connxnTable=[obj.connxnTable;connRow];

                [addedRow,columnAdded]=obj.addPropertyValue(connectors(connxnItr),obj.connxnTable(end,:));
                if numel(columnAdded)>0
                    for colItr=1:numel(columnAdded)

                        rowSize=size(obj.connxnTable,1);
                        appendedTable=table(repmat("",rowSize,1),'VariableNames',columnAdded(colItr));
                        obj.connxnTable=[obj.connxnTable,appendedTable];
                        obj.connectionTableColNames=[obj.connectionTableColNames,columnAdded(colItr)];
                    end
                end
                obj.connxnTable(end,:)=addedRow;
            end
        end

        function obj=addFunction2table(obj,archHandle)

            if~isempty(find_system(obj.archModel.SimulinkHandle,'BlockType','ModelReference'))
                try
                    set_param(obj.archModel.SimulinkHandle,'SimulationCommand','update');
                catch me
                    obj.logErrorwithStack('SystemArchitecture:Export:ErrorPopulatingFunctionsTable',me);
                end
            end

            functions=get(archHandle,'Functions');
            for i=1:numel(functions)
                obj.functionTable=[obj.functionTable;...
                cell2table(repmat({""},1,numel(obj.functionTableColNames)),...
                'VariableName',obj.functionTableColNames)];
                obj.functionTable.Name(end)=get(functions(i),'Name');
                obj.functionTable.ExecutionOrder(end)=get(functions(i),'ExecutionOrder');
                obj.functionTable.Period(end)=get(functions(i),'Period');

                comp=get(functions(i),'Component');
                compID=obj.compUUIDMap(comp.UUID);
                obj.functionTable.CompID(end)=compID;


                [addedRow,columnAdded]=obj.addPropertyValue(functions(i),obj.functionTable(end,:));
                if numel(columnAdded)>0
                    for colItr=1:numel(columnAdded)

                        rowSize=size(obj.functionTable,1);
                        appendedTable=table(repmat("",rowSize,1),'VariableNames',columnAdded(colItr));
                        obj.functionTable=[obj.functionTable,appendedTable];
                        obj.functionTableColNames=[obj.functionTableColNames,columnAdded(colItr)];
                    end
                end
                obj.functionTable(end,:)=addedRow;
            end
        end

        function contextName=getContextNameForArchPort(~,archPort)




            if isempty(archPort.Parent.Parent)
                contextName=archPort.Parent.getQualifiedName;
            else
                contextName=archPort.Parent.Parent.Parent.getQualifiedName;
            end
        end

        function[tablerow,columnsAdded]=addPropertyValue(obj,objHandle,tablerow)


            prototypeNamesList='';
            columnsAdded=[];
            if~isempty(objHandle)
                stereotypeNames=objHandle.getStereotypes;

                for protoItr=1:length(stereotypeNames)
                    protoQualName=char(stereotypeNames(protoItr));

                    prototype=obj.getPrototype(protoQualName);
                    if isempty(prototype)
                        return;
                    end
                    posIdentifier=strfind(protoQualName,'.');
                    protoQualName(posIdentifier)='_';
                    propValMap=systemcomposer.internal.getPropertyValueMap(objHandle,prototype);
                    properties=propValMap.keys;


                    for propItr=1:numel(properties)
                        propertyName=properties(propItr);
                        propertyField=propValMap(char(propertyName));
                        pos=strfind(propertyName,'.');
                        colName=strcat(protoQualName,'_',propertyName{:}(pos{:}+1:end));
                        if(~ismember(colName,tablerow.Properties.VariableNames))
                            tablerow=[tablerow,array2table(propertyField,'VariableNames',{char(propertyName)})];
                            columnsAdded=[columnsAdded,{char(colName)}];
                        else
                            tablerow.(colName)=propertyField;
                        end
                    end

                    if isempty(prototypeNamesList)
                        prototypeNamesList=prototype.FullyQualifiedName;
                    else
                        prototypeNamesList=strcat(prototypeNamesList,",",prototype.FullyQualifiedName);
                    end
                end
                if(~isempty(prototypeNamesList))
                    tablerow.StereotypeNames(1)=prototypeNamesList;
                end
            end
        end

        function[portInterfaceName,interfaceID,obj]=addInterfaceInfo(obj,portHandle)

            if(~isempty(portHandle))
                portInterface=portHandle.Interface;
                portInterfaceName='';
                interfaceID='';
                if(~isempty(portInterface))
                    portInterfaceName=portInterface.Name;

                    if~isempty(portInterfaceName)&&~isempty(obj.portInterfaceTable)&&ismember(portInterfaceName,obj.portInterfaceTable.Name)
                        rowsWithName=obj.portInterfaceTable(ismember(obj.portInterfaceTable.Name,portInterfaceName),:);


                        interfaceID=rowsWithName(ismember(rowsWithName.ParentID,""),:).ID;
                        if numel(interfaceID)>1
                            error(strcat("More than one interface found with name: ",portInterfaceName));
                        elseif(numel(interfaceID)==0)
                            error(strcat("No interface found with name: ",portInterfaceName));
                        end
                        return;
                    elseif isempty(portInterfaceName)
                        if~isa(portInterface,'systemcomposer.interface.DataInterface')

                            portInterfaceUID=portInterface.ExternalUID;


                            if isempty(portInterfaceUID)
                                interfaceID=0;
                                if~isempty(obj.portInterfaceTable.ID)
                                    while ismember(string(interfaceID),obj.interfacesUID)||ismember(string(interfaceID),obj.portInterfaceTable.ID)
                                        interfaceID=interfaceID+numel(obj.portInterfaceTable.ID);
                                    end
                                end
                                obj.interfacesUID=[obj.interfacesUID;string(interfaceID)];
                            else
                                interfaceID=portInterfaceUID;
                            end


                            obj=obj.addAnonymousInterfaceToTable(portInterface,interfaceID);
                        end
                    end
                end
            end
        end

        function propertyNames=getPrototypePropertyNames(~,prototype)

            propertyNames={};

            if(~isempty(prototype))
                properties=prototype.Properties;
                for propItr=1:numel(properties)

                    propertyNames=[propertyNames,properties(propItr).Name];
                end
            end
        end


        function[profileName,prototypeName]=getProfileName(~,prototypeName)

            if(contains(prototypeName,'.'))
                prototypeName=prototypeName{:};
                posIdentifierInName=strfind(prototypeName,'.');
                if(numel(posIdentifierInName)==1)
                    profileName=prototypeName(1:posIdentifierInName-1);
                    prototypeName=prototypeName(posIdentifierInName+1:end);
                end
            else
                profileName='';
                prototypeName='';
            end
        end

        function prototype=getPrototype(obj,protoQualName)

            prototype={};
            if~isempty(obj.profilesMap)&&~isempty(protoQualName)
                profileName=obj.getProfileName({protoQualName});

                profile=obj.profilesMap(profileName);
                if~isempty(profile)
                    prototype=profile.Stereotypes.find(protoQualName);
                end
            end

        end

        function outTable=convertTableInputs(~,inTable,reqColumnNames)


            colsToDelete={};
            for colItr=1:numel(inTable.Properties.VariableNames)
                colName=inTable.Properties.VariableNames{colItr};
                inTable.(colName)=string(inTable.(colName));

                if all(cellfun(@isempty,inTable.(colName)))&&~ismember(colName,reqColumnNames)
                    colsToDelete=[colsToDelete,colName];
                end
            end
            for colItr=1:numel(colsToDelete)
                inTable.(colsToDelete{colItr})=[];
            end
            outTable=inTable;
        end

        function addFunctionArgumentInfo(obj,fcnElem,fcnElemID)

            assert(isa(fcnElem,'systemcomposer.interface.FunctionElement'));
            interfArgs=fcnElem.FunctionArguments;
            for elemItr=1:numel(interfArgs)
                element=interfArgs(elemItr);

                elementUID=element.ExternalUID;
                if isempty(elementUID)


                    obj.interfacesCount=obj.interfacesCount+1;
                    elemID=obj.interfacesCount;
                else

                    elemID=elementUID;
                end


                elemName=element.Name;
                elemPrototype='';
                if isa(element.Type,'systemcomposer.ValueType')
                    if isempty(element.Type.Name)

                        elemDataType=element.Type.DataType;
                    else

                        elemDataType=element.Type.Name;
                    end
                    elemDimensions=element.Type.Dimensions;
                    elemUnits=element.Type.Units;
                    elemComplexity=element.Type.Complexity;
                    elemMinimum=element.Type.Minimum;
                    elemMaximum=element.Type.Maximum;
                    elemDescr=element.Type.Description;
                else

                    assert(isa(element.Type,'systemcomposer.interface.DataInterface'));
                    elemDataType=element.Type.Name;
                    elemDimensions=element.Dimensions;
                    elemUnits='';
                    elemComplexity='real';
                    elemMinimum='[]';
                    elemMaximum='[]';
                    elemDescr=element.Description;
                end


                obj.portInterfaceTable=[...
                obj.portInterfaceTable;...
                cell2table(repmat({""},1,numel(obj.interfacesTableColNames)),'VariableName',...
                obj.interfacesTableColNames)];%#ok<STRSCALR>


                obj.portInterfaceTable.Name(end)=elemName;
                obj.portInterfaceTable.ParentID(end)=fcnElemID;
                obj.portInterfaceTable.ID(end)=elemID;
                obj.portInterfaceTable.DataType(end)=elemDataType;
                obj.portInterfaceTable.Dimensions(end)=elemDimensions;
                obj.portInterfaceTable.Units(end)=elemUnits;
                obj.portInterfaceTable.Complexity(end)=elemComplexity;
                obj.portInterfaceTable.Minimum(end)=elemMinimum;
                obj.portInterfaceTable.Maximum(end)=elemMaximum;
                obj.portInterfaceTable.Description(end)=elemDescr;
                obj.portInterfaceTable.FunctionPrototype(end)=elemPrototype;

            end
        end

        function populateInterfaceTable(obj)




            try
                interfaceNameIDMap=containers.Map('keytype','char','valuetype','any');

                obj.interfacesCount=0;
                if(~isempty(obj.archModel))

                    interfaces=obj.archModel.InterfaceDictionary.Interfaces;
                    for intItr=1:numel(interfaces)


                        obj.interfacesCount=obj.interfacesCount+1;
                        interface=interfaces(intItr);
                        if(~isempty(interface))
                            interfaceName=interface.Name;
                            interfaceType='DataInterface';
                            if isa(interface,'systemcomposer.interface.PhysicalInterface')
                                interfaceType='PhysicalInterface';
                            elseif isa(interface,'systemcomposer.interface.ServiceInterface')
                                interfaceType='ServiceInterface';
                            elseif isa(interface,'systemcomposer.ValueType')
                                interfaceType=interface.DataType;
                                interfaceDimensions=interface.Dimensions;
                                interfaceUnits=interface.Units;
                                interfaceComplexity=interface.Complexity;
                                interfaceMinimum=interface.Minimum;
                                interfaceMaximum=interface.Maximum;
                                interfaceDescr=interface.Description;
                            end



                            if~isempty(interfaceName)&&~interfaceNameIDMap.isKey(interfaceName)
                                obj.portInterfaceTable=[obj.portInterfaceTable;cell2table(repmat({""},1,numel(obj.interfacesTableColNames)),'VariableName',obj.interfacesTableColNames)];%#ok<STRSCALR>

                                interfaceExternalUID=interface.ExternalUID;
                                if isempty(interfaceExternalUID)

                                    obj.interfacesCount=obj.interfacesCount+1;
                                    interfaceID=obj.interfacesCount;
                                else

                                    interfaceID=interfaceExternalUID;
                                end

                                obj.portInterfaceTable.ID(end)=interfaceID;
                                obj.portInterfaceTable.Name(end)=interfaceName;
                                obj.portInterfaceTable.DataType(end)=interfaceType;
                                if isa(interface,'systemcomposer.ValueType')
                                    obj.portInterfaceTable.Dimensions(end)=interfaceDimensions;
                                    obj.portInterfaceTable.Units(end)=interfaceUnits;
                                    obj.portInterfaceTable.Dimensions(end)=interfaceDimensions;
                                    obj.portInterfaceTable.Complexity(end)=interfaceComplexity;
                                    obj.portInterfaceTable.Minimum(end)=interfaceMinimum;
                                    obj.portInterfaceTable.Maximum(end)=interfaceMaximum;
                                    obj.portInterfaceTable.Description(end)=interfaceDescr;
                                end

                                if~isempty(interfaceName)
                                    interfaceNameIDMap(interfaceName)=interfaceID;
                                end

                                [addedRow,columnAdded]=obj.addPropertyValue(interface,obj.portInterfaceTable(end,:));
                                if numel(columnAdded)>0
                                    for colItr=1:numel(columnAdded)

                                        rowSize=size(obj.portInterfaceTable,1);
                                        appendedTable=table(repmat("",rowSize,1),'VariableNames',columnAdded(colItr));
                                        obj.portInterfaceTable=[obj.portInterfaceTable,appendedTable];
                                        obj.interfacesTableColNames=[obj.interfacesTableColNames,columnAdded(colItr)];
                                    end
                                end
                                obj.portInterfaceTable(end,:)=addedRow;

                                if~isa(interface,'systemcomposer.ValueType')
                                    interfaceElements=interface.Elements;
                                    for elemItr=1:numel(interfaceElements)

                                        element=interfaceElements(elemItr);

                                        elementUID=element.ExternalUID;
                                        if isempty(elementUID)


                                            obj.interfacesCount=obj.interfacesCount+1;
                                            elemID=obj.interfacesCount;
                                        else


                                            elemID=elementUID;
                                        end

                                        elemName=element.Name;
                                        elemPrototype='';
                                        elemAsynchronous='';
                                        if isa(element,'systemcomposer.interface.FunctionElement')
                                            elemDataType='FunctionElement';
                                            elemPrototype=element.FunctionPrototype;
                                            elemDimensions='';
                                            elemUnits='';
                                            elemComplexity='';
                                            elemMinimum='';
                                            elemMaximum='';
                                            elemDescr='';
                                            elemAsynchronous=element.Asynchronous;
                                        elseif isa(element.Type,'systemcomposer.ValueType')&&~isa(element.Type.Owner,'systemcomposer.interface.Dictionary')
                                            elemDataType=element.Type.DataType;
                                            elemDimensions=element.Type.Dimensions;
                                            elemUnits=element.Type.Units;
                                            elemComplexity=element.Type.Complexity;
                                            elemMinimum=element.Type.Minimum;
                                            elemMaximum=element.Type.Maximum;
                                            elemDescr=element.Type.Description;
                                        elseif isa(element,'systemcomposer.interface.PhysicalElement')
                                            if~isempty(element.Type)
                                                elemDataType=element.Type.Domain;
                                            else
                                                elemDataType='';
                                            end
                                            elemDimensions='';
                                            elemUnits='';
                                            elemComplexity='';
                                            elemMinimum='[]';
                                            elemMaximum='[]';
                                            elemDescr='';
                                        else
                                            elemDataType=element.Type.Name;
                                            elemDimensions=element.Dimensions;
                                            elemUnits='';
                                            elemComplexity='real';
                                            elemMinimum='[]';
                                            elemMaximum='[]';
                                            elemDescr=element.Description;
                                        end


                                        if~isempty(interfaceName)&&~isempty(elemName)
                                            obj.portInterfaceTable=[obj.portInterfaceTable;cell2table(repmat({""},1,numel(obj.interfacesTableColNames)),'VariableName',obj.interfacesTableColNames)];%#ok<STRSCALR>
                                        end

                                        obj.portInterfaceTable.Name(end)=elemName;
                                        if~isempty(interfaceName)&&~isempty(elemName)

                                            obj.portInterfaceTable.ParentID(end)=interfaceID;
                                            obj.portInterfaceTable.ID(end)=elemID;
                                        end
                                        obj.portInterfaceTable.DataType(end)=elemDataType;
                                        obj.portInterfaceTable.Units(end)=elemUnits;
                                        obj.portInterfaceTable.Dimensions(end)=elemDimensions;
                                        obj.portInterfaceTable.Complexity(end)=elemComplexity;
                                        obj.portInterfaceTable.Minimum(end)=elemMinimum;
                                        obj.portInterfaceTable.Maximum(end)=elemMaximum;
                                        obj.portInterfaceTable.Description(end)=elemDescr;
                                        obj.portInterfaceTable.FunctionPrototype(end)=elemPrototype;
                                        obj.portInterfaceTable.Asynchronous(end)=elemAsynchronous;

                                        if isa(element,'systemcomposer.interface.FunctionElement')

                                            obj.addFunctionArgumentInfo(element,elemID);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            catch ME


                obj.logErrorwithStack('SystemArchitecture:Export:ErrorPopulatingInterfaceTable',ME);
            end
        end

        function obj=addAnonymousInterfaceToTable(obj,interface,interfaceID)
            if(~isempty(interface))
                interfaceName=interface.Name;

                if isempty(interfaceName)

                    obj.portInterfaceTable=[obj.portInterfaceTable;cell2table(repmat({""},1,numel(obj.interfacesTableColNames)),'VariableName',obj.interfacesTableColNames)];%#ok<STRSCALR>

                    interfaceExternalUID=interface.ExternalUID;
                    if~isempty(interfaceExternalUID)

                        interfaceID=interfaceExternalUID;
                    end

                    obj.portInterfaceTable.ID(end)=interfaceID;

                    obj.portInterfaceTable.Name(end)="";

                    elemDataType=interface.Type;
                    elemDimensions=interface.Dimensions;
                    elemUnits=interface.Units;
                    elemComplexity=interface.Complexity;
                    elemMinimum=interface.Minimum;
                    elemMaximum=interface.Maximum;


                    obj.portInterfaceTable.ParentID(end)="";
                    obj.portInterfaceTable.DataType(end)=elemDataType;
                    obj.portInterfaceTable.Units(end)=elemUnits;
                    obj.portInterfaceTable.Dimensions(end)=elemDimensions;
                    obj.portInterfaceTable.Complexity(end)=elemComplexity;
                    obj.portInterfaceTable.Minimum(end)=elemMinimum;
                    obj.portInterfaceTable.Maximum(end)=elemMaximum;
                    obj.portInterfaceTable.Description(end)=interface.Description;
                end
            end
        end

        function checkForDuplicateUID(obj)


            [~,dupIndices]=unique(obj.compTable.ID(:),'rows','legacy');
            duplicate=setdiff(1:size(obj.compTable.ID,1),dupIndices);
            for dupItr=1:numel(duplicate)
                dupValue=obj.compTable.ID(duplicate(dupItr));
                compNames=obj.compTable(ismember(obj.compTable.ID,dupValue),:).Name;
                duplicateComp='';
                for compItr=1:numel(compNames)
                    duplicateComp=strcat(duplicateComp,"  ",string(compItr),':',compNames(compItr));
                end
                warning(message('SystemArchitecture:Import:DuplicateUID',char(dupValue),'Components',duplicateComp));
            end

            [~,dupIndices]=unique(obj.portTable.ID(:),'rows','legacy');
            duplicate=setdiff(1:size(obj.portTable.ID,1),dupIndices);
            for dupItr=1:numel(duplicate)
                dupValue=obj.portTable.ID(duplicate(dupItr));
                portNames=obj.portTable(ismember(obj.portTable.ID,dupValue),:).Name;
                duplicatePort='';
                for portItr=1:numel(portNames)
                    duplicatePort=strcat(duplicatePort,"  ",string(portItr),':',portNames(portItr));
                end
                warning(message('SystemArchitecture:Import:DuplicateUID',char(dupValue),'Ports',duplicatePort));
            end


            [~,dupIndices]=unique(obj.connxnTable.ID(:),'rows','legacy');
            duplicate=setdiff(1:size(obj.connxnTable.ID,1),dupIndices);
            for dupItr=1:numel(duplicate)
                dupValue=obj.connxnTable.ID(duplicate(dupItr));
                connxnNames=obj.connxnTable(ismember(obj.connxnTable.ID,dupValue),:).Name;
                duplicateConnxn='';
                for connItr=1:numel(connxnNames)
                    duplicateConnxn=strcat(duplicateConnxn,"  ",string(connItr),':',connxnNames(connItr));
                end
                warning(message('SystemArchitecture:Import:DuplicateUID',char(dupValue),'Connections',duplicateConnxn));
            end

            [~,dupIndices]=unique(obj.portInterfaceTable.ID(:),'rows','legacy');
            duplicate=setdiff(1:size(obj.portInterfaceTable.ID,1),dupIndices);
            for dupItr=1:numel(duplicate)
                dupValue=obj.portInterfaceTable.ID(duplicate(dupItr));
                interfaceNames=obj.portInterfaceTable(ismember(obj.portInterfaceTable.ID,dupValue),:).Name;
                duplicateInterface='';
                for Itr=1:numel(interfaceNames)
                    duplicateInterface=strcat(duplicateInterface,"  ",string(Itr),':',interfaceNames(Itr));
                end
                warning(message('SystemArchitecture:Import:DuplicateUID',char(dupValue),'Interfaces',duplicateInterface));
            end

        end


        function MEHeader=logErrorwithStack(obj,headerKey,originalME,varargin)


            if nargin<4
                MEHeader=MSLException(headerKey);
            else
                MEHeader=MSLException(headerKey,varargin);
            end
            MEHeader=MEHeader.addCause(originalME);
            obj.exportErrorsLog=[obj.exportErrorsLog;string(MEHeader.getReport())];
        end
    end
end


