classdef ModelBuilder<dynamicprops







    properties(Access=public)
        Components;
        Ports;
        Connections;
        Interfaces;
    end
    properties(SetAccess=private,Hidden=true)


        compIdMap=containers.Map('keytype','double','valuetype','any');
        portIdMap=containers.Map('keytype','double','valuetype','any');
        conxnIdMap=containers.Map('keytype','double','valuetype','any');


        profilesMap;

        prototypeNameMap;

        protoPropNameMap;


        ComponentsColNames;
        PortsColNames;
        connectionTableColNames;
        interfaceTableColNames;

        compPropertyColumnName={};
        portPropertyColumnName={};
        connxnPropertyColumnName={};


        compPropertyNames={};
        portPropertyNames={};
        connxnPropertyNames={};


        errorList={};


        importLogs={};


        importErrorLogs={};
    end

    methods
        function obj=ModelBuilder(profileNames)





            obj.profilesMap=containers.Map('keytype','char','valuetype','any');


            obj.prototypeNameMap=containers.Map('keytype','char','valuetype','any');


            obj.protoPropNameMap=containers.Map('keytype','char','valuetype','any');

            if(nargin>0)

                obj=obj.readProfiles(profileNames);
            end

            obj=obj.generateEmptyTables();



            obj.errorList={};
        end
    end

    methods(Access=private)
        function obj=generateEmptyTables(obj)
            obj.ComponentsColNames=[{'Name','ID','ParentID','ReferenceModelName','ComponentType','ActiveChoice','VariantControl','VariantCondition','StereotypeNames'},obj.compPropertyColumnName];

            obj.PortsColNames=[{'Name','Direction','ID','CompID','InterfaceID','StereotypeNames'},obj.portPropertyColumnName];

            obj.connectionTableColNames=[{'Name','ID','SourcePortID','DestPortID','StereotypeNames'},obj.connxnPropertyColumnName];

            obj.interfaceTableColNames={'Name','ID','ParentID','DataType','Dimensions','Units','Complexity','Minimum','Maximum'};


            obj.Components=cell2table(cell(0,numel(obj.ComponentsColNames)),'VariableNames',obj.ComponentsColNames);

            obj.Ports=cell2table(cell(0,numel(obj.PortsColNames)),'VariableNames',obj.PortsColNames);

            obj.Connections=cell2table(cell(0,numel(obj.connectionTableColNames)),'VariableNames',obj.connectionTableColNames);

            obj.Interfaces=cell2table(cell(0,numel(obj.interfaceTableColNames)),'VariableNames',obj.interfaceTableColNames);


            obj=obj.addRootComponent();
        end


        function obj=readProfiles(obj,profileNames)
            if~iscell(profileNames)
                profileNames={profileNames};
            end


            if(~isempty(profileNames))
                compPrototypeNames={};
                portsPrototypeNames={};
                connxnPrototypeNames={};

                obj.loadProfiles(profileNames);
                for profItr=1:numel(profileNames)
                    profileName=profileNames(profItr);
                    profile=obj.profilesMap(profileName{:});
                    prototypes=profile.Stereotypes;
                    for protItr=1:numel(prototypes)
                        prototype=prototypes(protItr);
                        if(~isempty(prototype))
                            obj.prototypeNameMap(prototype.FullyQualifiedName)=prototype;
                            properties=obj.getPrototypePropertyNames(prototype);
                            if(~(prototype.Abstract))
                                obj.protoPropNameMap(prototype.FullyQualifiedName)=properties;
                                if(isequal(prototype.getExtendedElement,'Component'))
                                    compPrototypeNames=[compPrototypeNames;prototype.FullyQualifiedName];%#ok<*AGROW>
                                elseif(isequal(prototype.getExtendedElement,'Port'))
                                    portsPrototypeNames=[portsPrototypeNames;prototype.FullyQualifiedName];
                                elseif(isequal(prototype.getExtendedElement,'Connnector'))
                                    connxnPrototypeNames=[connxnPrototypeNames;prototype.FullyQualifiedName];
                                end
                            end
                        end
                    end
                end


                obj.compPropertyColumnName={};
                obj.portPropertyColumnName={};
                obj.connxnPropertyColumnName={};

                nonAbstractPrototypeList=obj.protoPropNameMap.keys;
                for protoMapItr=1:numel(nonAbstractPrototypeList)
                    protoQualName=nonAbstractPrototypeList(protoMapItr);
                    posIdentifier=strfind(protoQualName,'.');
                    protoQualName{:}(cell2mat(posIdentifier))='_';
                    propertylist=obj.protoPropNameMap(nonAbstractPrototypeList{protoMapItr});
                    for propItr=1:numel(propertylist)
                        propName=propertylist(propItr);
                        if(ismember(nonAbstractPrototypeList(protoMapItr),compPrototypeNames))
                            obj.compPropertyColumnName=[obj.compPropertyColumnName,strcat(protoQualName,'_',propName)];
                            obj.compPropertyNames=[obj.compPropertyNames,propName];
                        elseif(ismember(nonAbstractPrototypeList(protoMapItr),portsPrototypeNames))
                            obj.portPropertyColumnName=[obj.portPropertyColumnName,strcat(protoQualName,'_',propName)];
                            obj.portPropertyNames=[obj.portPropertyNames,propName];
                        else
                            obj.connxnPropertyColumnName=[obj.connxnPropertyColumnName,strcat(protoQualName,'_',propName)];
                            obj.connxnPropertyNames=[obj.connxnPropertyNames,propName];
                        end
                    end
                end
            end
        end


        function obj=loadProfiles(obj,profileNames)
            if~iscell(profileNames)
                profileNames={profileNames};
            end



            for profItr=1:numel(profileNames)
                profileName=profileNames(profItr);
                try
                    loadFileName=strcat(profileName,'.xml');
                    if(isequal(exist(char(loadFileName),'file'),2))
                        profile=systemcomposer.loadProfile(profileName{:});
                        if(~obj.profilesMap.isKey(profileName))
                            obj.profilesMap(profileName{:})=profile;
                        end
                    end
                catch exception
                    combinedExceptionMessage=[newline,exception.message];
                    for exceptionCause=exception.cause
                        combinedExceptionMessage=[combinedExceptionMessage,newline,exceptionCause.message];
                    end
                    errorMessage=message('SystemArchitecture:Import:LoadProfileError',profileName{:},combinedExceptionMessage);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            end
        end

        function obj=addRootComponent(obj)
            obj.Components=[obj.Components;cell2table(repmat({""},1,numel(obj.ComponentsColNames)),'VariableNames',obj.ComponentsColNames)];%#ok<*STRSCALR>
            obj.Components.ID(end)="0";
            obj.Components.Name(end)="root";
        end

        function isValid=validateInputs(~,varargin)
            isValid=true;
            for k=1:numel(varargin)
                if~ischar(varargin{k})&&~isstring(varargin{k})
                    if iscell(varargin{k})
                        arg=varargin{k};
                        if ischar(arg{:})
                            return;
                        end
                    end
                    isValid=false;
                    return;
                end
            end
        end


        function[isValid,obj]=isValidStereotypeName(obj,stereotypeName)
            isValid=false;
            if obj.validateInputs(stereotypeName)

                splits=split(stereotypeName,'.');
                if isequal(numel(splits),2)
                    if ismember(stereotypeName,obj.protoPropNameMap.keys)
                        isValid=true;
                    else
                        profileName=splits{1};
                        errorMessage=message('SystemArchitecture:Import:StereotypeNotFound',stereotypeName,profileName);
                        obj.errorList=[obj.errorList,errorMessage];
                    end
                else
                    errorMessage=message('SystemArchitecture:Import:StereotypeNameInvalidFormat',stereotypeName);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            end
        end
        function[isTrue,obj]=isPropertyUnderStereotype(obj,propertyName,stereotypeName)
            isTrue=false;
            if obj.isValidStereotypeName(stereotypeName)
                propertyList=obj.protoPropNameMap(stereotypeName);
                if ismember(propertyName,propertyList)
                    isTrue=true;
                    return;
                else
                    errorMessage=message('SystemArchitecture:Import:PropertyNameNotFoundUnderStereotype',propertyName,stereotypeName);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            end
        end



        function isTrue=isVariant(obj,ID)
            isTrue=false;
            if obj.hasComponent(ID)
                component=obj.getComponent(ID);
                if strcmpi(component.ComponentType,'Variant')
                    isTrue=true;
                end
            end


        end

        function isTrue=isChoice(obj,ID)
            isTrue=false;
            if obj.hasComponent(ID)
                component=obj.getComponent(ID);
                parentID=char(component.ParentID);
                isTrue=obj.isVariant(parentID);
            end
        end

        function isTrue=isAdapter(obj,ID)
            isTrue=false;
            if obj.hasComponent(ID)
                component=obj.getComponent(ID);
                type=component.ComponentType;
                isTrue=strcmpi(type,'Adapter');
            end
        end


        function isTrue=isChoiceInLabelMode(obj,ID)
            isTrue=false;
            if obj.isChoice(ID)
                parentID=obj.getParentComponent(ID);
                component=obj.getComponent(parentID);
                if~strcmp(component.ActiveChoice,"")
                    isTrue=true;
                end
            end
        end


        function isTrue=isVariantInExpressionMode(obj,ID)
            isTrue=false;

            components=obj.Components(ismember(obj.Components.ParentID,ID),:);
            for itr=1:numel(components(:,1))
                if~strcmp(components(itr,:).VariantCondition,"")
                    isTrue=true;
                    return;
                else
                    isTrue=false;
                end
            end
        end


        function isTrue=hasPortOnComponent(obj,ID)
            isTrue=false;
            if obj.hasComponent(ID)
                parentID=obj.getParentComponent(ID);
                if obj.isVariant(parentID)
                    component=obj.getComponent(parentID);
                    if~strcmp(component.ActiveChoice,"")
                        isTrue=true;
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

        function propertyType=getPropertyType(obj,prototype,propertyName)

            propertyType={};

            if(~isempty(prototype))
                property=prototype.findProperty(propertyName);
                if~isempty(property)
                    propertyType=property.Type;
                else
                    propertyType=obj.getPropertyType(prototype.parent,propertyName);
                end
            end
        end

    end



    methods(Access=public)





        function status=addComponent(obj,compName,ID,ParentID)
            status=false;

            isValid=obj.validateInputs(compName,ID,ParentID);
            if isValid

                if~obj.hasComponent(ParentID)
                    errorMessage=message('SystemArchitecture:Import:InvalidParent',ParentID,compName,ID);
                    obj.errorList=[obj.errorList,errorMessage];
                elseif obj.isAdapter(ParentID)
                    parentName=obj.getComponentName(ParentID);
                    errorMessage=message('SystemArchitecture:Import:ComponentInAdapterError',parentName,ParentID);
                    obj.errorList=[obj.errorList,errorMessage];
                    return;
                end

                if obj.hasComponent(ID)
                    addedCompName=obj.getComponentName(ID);
                    errorMessage=message('SystemArchitecture:Import:DuplicateID',compName,ID,'Component',addedCompName);
                    obj.errorList=[obj.errorList,errorMessage];
                    return;
                end
                obj.Components=[obj.Components;cell2table(repmat({""},1,numel(obj.ComponentsColNames)),'VariableNames',obj.ComponentsColNames)];%#ok<*STRSCALR>
                obj.Components.ID(end)=ID;
                obj.Components.ParentID(end)=ParentID;
                obj.Components.Name(end)=compName;
                status=true;
            else
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
            end
        end


        function found=hasComponent(obj,ID)
            found=false;
            if obj.validateInputs(ID)
                found=ismember(ID,obj.Components.ID);
            end
        end


        function components=getComponent(obj,IDs)
            components={};
            if~iscell(IDs)
                IDs={IDs};
            end
            for idItr=1:numel(IDs)
                ID=IDs{idItr};
                if ischar(ID)||isstring(ID)
                    components=[components;obj.Components(ismember(obj.Components.ID,ID),:)];
                end
            end
        end


        function componentNames=getComponentName(obj,IDs)
            componentNames={};
            if~iscell(IDs)
                IDs={IDs};
            end
            for idItr=1:numel(IDs)
                ID=IDs{idItr};
                if ischar(ID)||isstring(ID)
                    componentNames=[componentNames;obj.Components(ismember(obj.Components.ID,ID),:).Name];
                end
            end
        end

        function[parentID,parentName]=getParentComponent(obj,ID)
            component=obj.getComponent(ID);
            if~isempty(component)
                parentID=char(component.ParentID);
                parentName=obj.getComponentName(parentID);
            end
        end







        function status=setComponentProperty(obj,ID,varargin)
            stereotypeName='';
            status=false;
            for k=1:2:numel(varargin)
                if strcmpi(varargin{k},"StereotypeName")
                    stereotypeName=varargin{k+1};
                    if obj.isValidStereotypeName(stereotypeName)&&obj.hasComponent(ID)
                        if strcmp(obj.Components(ismember(obj.Components.ID,ID),:).StereotypeNames,"")&&~strcmp(obj.Components(ismember(obj.Components.ID,ID),:).StereotypeNames,stereotypeName)
                            obj.Components(ismember(obj.Components.ID,ID),:).StereotypeNames=stereotypeName;
                        else
                            stereotypeNames=strcat(obj.Components(ismember(obj.Components.ID,ID),:).StereotypeNames,',',stereotypeName);
                            obj.Components(ismember(obj.Components.ID,ID),:).StereotypeNames=stereotypeNames;
                        end
                    end
                elseif~isempty(stereotypeName)
                    propertyName=varargin{k};
                    if~ismember(propertyName,obj.compPropertyNames)
                        errorMessage=message('SystemArchitecture:Import:PropertyNotFound',propertyName,stereotypeName);
                        obj.errorList=[obj.errorList,errorMessage];
                    end
                    if obj.isPropertyUnderStereotype(propertyName,stereotypeName)
                        stereotypeQualName=stereotypeName;
                        posIdentifier=strfind(stereotypeQualName,'.');
                        stereotypeQualName(posIdentifier)='_';
                        propertyColName=strcat(stereotypeQualName,'_',propertyName);
                        if ismember(propertyColName,obj.compPropertyColumnName)
                            propertyValue=varargin{k+1};
                            stereotype=obj.prototypeNameMap(stereotypeName);
                            propertyType=obj.getPropertyType(stereotype,propertyName);
                            if ischar(propertyValue)||isstring(propertyValue)&&~isempty(propertyType)
                                if(strcmp(propertyType,'enum'))||(strcmp(propertyType,'string'))
                                    propertyValue=append('''',propertyValue,'''');
                                end
                                obj.Components(ismember(obj.Components.ID,ID),:).(propertyColName)=propertyValue;
                            else
                                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                                obj.errorList=[obj.errorList,errorMessage];
                                status=false;
                            end
                        end
                    end
                end
            end
        end



        function status=addVariant(obj,variantName,ID,ParentID)
            status=obj.addComponent(variantName,ID,ParentID);
            if status
                obj.Components(ismember(obj.Components.ID,ID),:).ComponentType="Variant";
            else
                errorMessage=message('SystemArchitecture:Import:VariantAdditionFailed',variantName,ID,ParentID);
                obj.errorList=[obj.errorList,errorMessage];
            end
        end

        function status=addChoice(obj,choiceName,ID,ParentID)
            status=false;

            if obj.isVariant(ParentID)
                status=obj.addComponent(choiceName,ID,ParentID);
                if~status
                    errorMessage=message('SystemArchitecture:Import:ChoiceAdditionFailed',choiceName,ID,ParentID);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            else
                compName=obj.getComponentName(ParentID);
                errorMessage=message('SystemArchitecture:Import:ChoiceInVariant',choiceName,ID,compName);
                obj.errorList=[obj.errorList,errorMessage];
            end
        end

        function status=setVariantControl(obj,ID,label)
            status=false;
            if~obj.validateInputs(ID,label)
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
                return;
            end
            if obj.isChoice(ID)
                obj.Components(ismember(obj.Components.ID,ID),:).VariantControl=label;
                status=true;
            else
                if obj.hasComponent(ID)
                    compName=obj.getComponentName(ID);
                    errorMessage=message('SystemArchitecture:Import:ChoiceInvalid',compName,ID);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            end
        end

        function status=setCondition(obj,ID,expression)
            status=false;
            if~obj.validateInputs(ID,expression)
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
                return;
            end
            if obj.isChoice(ID)
                if~obj.isChoiceInLabelMode(ID)
                    status=true;
                    obj.Components(ismember(obj.Components.ID,ID),:).VariantCondition=expression;
                else
                    choiceName=obj.getComponentName(ID);
                    errorMessage=message('SystemArchitecture:Import:UnabletoSetCondition',choiceName);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            else
                if obj.hasComponent(ID)
                    compName=obj.getComponentName(ID);
                    errorMessage=message('SystemArchitecture:Import:ChoiceInvalid',compName,ID);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            end
        end


        function status=setActiveChoice(obj,ID,choiceName)
            status=false;
            if~obj.validateInputs(ID,choiceName)
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
                return;
            end
            if obj.isVariant(ID)
                if~obj.isVariantInExpressionMode(ID)
                    status=true;
                    obj.Components(ismember(obj.Components.ID,ID),:).ActiveChoice=choiceName;
                else
                    variantName=obj.getComponentName(ID);
                    errorMessage=message('SystemArchitecture:Import:UnabletoSetActiveChoice',choiceName,variantName,ID);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            else
                if obj.hasComponent(ID)
                    compName=obj.getComponentName(ID);
                    errorMessage=message('SystemArchitecture:Import:NotAVariant',compName,ID);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            end
        end


        function status=setReferenceModel(obj,ID,referenceName)
            status=false;
            if~obj.validateInputs(ID,referenceName)
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
                return;
            end
            if obj.hasComponent(ID)
                status=true;
                obj.Components(ismember(obj.Components.ID,ID),:).ReferenceModelName=referenceName;
                obj.Components(ismember(obj.Components.ID,ID),:).ComponentType="Composition";
            end
        end


        function status=setImplementationModel(obj,ID,modelName)
            status=false;
            if~obj.validateInputs(ID,modelName)
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
                return;
            end
            if obj.hasComponent(ID)
                status=true;
                obj.Components(ismember(obj.Components.ID,ID),:).ReferenceModelName=modelName;
                obj.Components(ismember(obj.Components.ID,ID),:).ComponentType="Behavior";
            end
        end

        function addAdapter(obj,adapterName,ID,ParentID)
            if obj.addComponent(adapterName,ID,ParentID)
                obj.Components(ismember(obj.Components.ID,ID),:).ComponentType="Adapter";
            end
        end

        function status=addPort(obj,portName,direction,ID,compID)
            status=false;

            isValid=obj.validateInputs(portName,ID,direction,compID);
            if isValid

                if~obj.hasComponent(compID)
                    warningMessage=message('SystemArchitecture:Import:ComponentNotPresent',ID,compID);
                    obj.errorList=[obj.errorList,warningMessage];
                end

                if obj.hasPort(ID)
                    addedPortName=obj.getPortName(ID);
                    errorMessage=message('SystemArchitecture:Import:DuplicateID',portName,ID,'Port',addedPortName);
                    obj.errorList=[obj.errorList,errorMessage];
                    return;
                end
                obj.Ports=[obj.Ports;cell2table(repmat({""},1,numel(obj.PortsColNames)),'VariableNames',obj.PortsColNames)];%#ok<*STRSCALR>
                obj.Ports.ID(end)=ID;
                obj.Ports.Name(end)=portName;
                if strcmpi(direction,'Input')||contains(direction,'in')
                    direction='Input';
                elseif strcmpi(direction,'Output')||contains(direction,'out')
                    direction='Output';
                else
                    errorMessage=message('SystemArchitecture:Import:InvalidPortDirection',ID);
                    obj.errorList=[obj.errorList,errorMessage];
                end
                obj.Ports.Direction(end)=direction;
                obj.Ports.CompID(end)=compID;
                status=true;
            else
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
            end
        end


        function found=hasPort(obj,ID)
            if obj.validateInputs(ID)
                found=ismember(ID,obj.Ports.ID);
            end
        end


        function ports=getPort(obj,IDs)
            ports={};
            if~iscell(IDs)
                IDs={IDs};
            end
            for idItr=1:numel(IDs)
                ID=IDs{idItr};
                ports=[ports;obj.Ports(ismember(obj.Ports.ID,ID),:)];
            end
        end


        function portNames=getPortName(obj,IDs)
            portNames={};
            if~iscell(IDs)
                IDs={IDs};
            end
            for idItr=1:numel(IDs)
                ID=IDs{idItr};
                portNames=[portNames;obj.Ports(ismember(obj.Ports.ID,ID),:).Name];
            end
        end







        function setPropertyOnPort(obj,ID,varargin)
            stereotypeName='';
            for k=1:2:numel(varargin)
                if strcmpi(varargin{k},"StereotypeName")
                    stereotypeName=varargin{k+1};
                    if obj.isValidStereotypeName(stereotypeName)&&obj.hasPort(ID)
                        if strcmp(obj.Ports(ismember(obj.Ports.ID,ID),:).StereotypeNames,"")&&~strcmp(obj.Ports(ismember(obj.Ports.ID,ID),:).StereotypeNames,stereotypeName)
                            obj.Ports(ismember(obj.Ports.ID,ID),:).StereotypeNames=stereotypeName;
                        else
                            stereotypeNames=strcat(obj.Ports(ismember(obj.Ports.ID,ID),:).StereotypeNames,',',stereotypeName);
                            obj.Ports(ismember(obj.Ports.ID,ID),:).StereotypeNames=stereotypeNames;
                        end
                    end
                elseif~isempty(stereotypeName)
                    propertyName=varargin{k};
                    if~ismember(propertyName,obj.portPropertyNames)
                        errorMessage=message('SystemArchitecture:Import:PropertyNotFound',propertyName,stereotypeName);
                        obj.errorList=[obj.errorList,errorMessage];
                    end
                    if obj.isPropertyUnderStereotype(propertyName,stereotypeName)
                        stereotypeQualName=stereotypeName;
                        posIdentifier=strfind(stereotypeQualName,'.');
                        stereotypeQualName(posIdentifier)='_';
                        propertyColName=strcat(stereotypeQualName,'_',propertyName);
                        if ismember(propertyColName,obj.portPropertyColumnName)
                            propertyValue=varargin{k+1};
                            stereotype=obj.prototypeNameMap(stereotypeName);
                            propertyType=obj.getPropertyType(stereotype,propertyName);
                            if ischar(propertyValue)||isstring(propertyValue)&&~isempty(propertyType)
                                if(strcmp(propertyType,'enum'))||(strcmp(propertyType,'string'))
                                    propertyValue=append('''',propertyValue,'''');
                                end
                                obj.Ports(ismember(obj.Ports.ID,ID),:).(propertyColName)=propertyValue;
                            else
                                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                                obj.errorList=[obj.errorList,errorMessage];
                            end
                        end
                    end
                end
            end
        end



        function status=addConnection(obj,connName,ID,sourcePortID,destPortID)
            status=false;

            isValid=obj.validateInputs(connName,ID,sourcePortID,destPortID);
            if isValid

                if~obj.hasPort(sourcePortID)||~obj.hasPort(destPortID)
                    warningMessage=message('SystemArchitecture:Import:PortsNotPresent',ID);
                    obj.errorList=[obj.errorList,warningMessage];
                end

                if obj.arePortsConnected(sourcePortID,destPortID)
                    sourcePortName=obj.getPortName(sourcePortID);
                    destPortName=obj.getPortName(destPortID);
                    errorMessage=message('SystemArchitecture:Import:PortsConnected',sourcePortName,destPortName);
                    obj.errorList=[obj.errorList,errorMessage];
                    return;
                end
                obj.Connections=[obj.Connections;cell2table(repmat({""},1,numel(obj.connectionTableColNames)),'VariableNames',obj.connectionTableColNames)];%#ok<*STRSCALR>
                obj.Connections.ID(end)=ID;
                obj.Connections.SourcePortID(end)=sourcePortID;
                obj.Connections.DestPortID(end)=destPortID;
                obj.Connections.Name(end)=connName;
                status=true;
            else
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
            end

        end

        function isTrue=arePortsConnected(obj,sourcePortID,destPortID)
            isTrue=false;
            if obj.hasPort(sourcePortID)&&obj.hasPort(destPortID)
                connxn=obj.Connections(ismember(obj.Connections.SourcePortID,sourcePortID),:);
                if strcmp(connxn.DestPortID,destPortID)
                    isTrue=true;
                end
            end
        end







        function setPropertyOnConnection(obj,ID,varargin)
            stereotypeName='';
            for k=1:2:numel(varargin)
                if strcmpi(varargin{k},"StereotypeName")
                    stereotypeName=varargin{k+1};
                    if obj.isValidStereotypeName(stereotypeName)
                        if strcmp(obj.Connections(ismember(obj.Connections.ID,ID),:).StereotypeNames,"")&&~strcmp(obj.Connections(ismember(obj.Connections.ID,ID),:).StereotypeNames,stereotypeName)
                            obj.Connections(ismember(obj.Connections.ID,ID),:).StereotypeNames=stereotypeName;
                        else
                            stereotypeNames=strcat(obj.Connections(ismember(obj.Connections.ID,ID),:).StereotypeNames,',',stereotypeName);
                            obj.Connections(ismember(obj.Connections.ID,ID),:).StereotypeNames=stereotypeNames;
                        end
                    end
                elseif~isempty(stereotypeName)
                    propertyName=varargin{k};
                    if~ismember(propertyName,obj.connxnPropertyNames)
                        errorMessage=message('SystemArchitecture:Import:PropertyNotFound',propertyName,stereotypeName);
                        obj.errorList=[obj.errorList,errorMessage];
                    end
                    if obj.isPropertyUnderStereotype(propertyName,stereotypeName)
                        stereotypeQualName=stereotypeName;
                        posIdentifier=strfind(stereotypeQualName,'.');
                        stereotypeQualName(posIdentifier)='_';
                        propertyColName=strcat(stereotypeQualName,'_',propertyName);
                        if ismember(propertyColName,obj.connxnPropertyColumnName)
                            stereotype=obj.prototypeNameMap(stereotypeName);
                            propertyType=obj.getPropertyType(stereotype,propertyName);
                            if ischar(propertyValue)||isstring(propertyValue)&&~isempty(propertyType)
                                if(strcmp(propertyType,'enum'))||(strcmp(propertyType,'string'))
                                    propertyValue=append('''',propertyValue,'''');
                                end
                                obj.Connections(ismember(obj.Connections.ID,ID),:).(propertyColName)=propertyValue;
                            else
                                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                                obj.errorList=[obj.errorList,errorMessage];
                            end
                        end
                    end
                end
            end
        end


        function status=addInterface(obj,interfaceName,ID)
            status=false;

            isValid=obj.validateInputs(interfaceName,ID);
            if isValid

                if~obj.hasInterface(interfaceName)&&isempty(obj.getInterfaceName(ID))
                    obj.Interfaces=[obj.Interfaces;cell2table(repmat({""},1,numel(obj.interfaceTableColNames)),'VariableNames',obj.interfaceTableColNames)];%#ok<*STRSCALR>
                    obj.Interfaces.Name(end)=interfaceName;
                    obj.Interfaces.ID(end)=ID;
                    status=true;
                else
                    errorMessage=message('SystemArchitecture:Import:DuplicateInterfaceName',interfaceName);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            else
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
            end

        end



        function status=addElementInInterface(obj,elementName,ID,interfaceID,datatype,dimensions,units,complexity,Maximum,Minimum)
            status=false;

            isValid=obj.validateInputs(elementName,ID,interfaceID,datatype,dimensions,units,complexity,Maximum,Minimum);
            if isValid

                if isempty(obj.getInterfaceName(interfaceID))
                    errorMessage=message('SystemArchitecture:Import:InterfaceNotFound',interfaceID);
                    obj.errorList=[obj.errorList,errorMessage];
                elseif obj.isAnonymousInterface(interfaceID)
                    errorMessage=message('SystemArchitecture:Import:AnonymousInterfaceError',elementName,obj.getInterfaceName(interfaceID));
                    obj.errorList=[obj.errorList,errorMessage];
                end
                obj.Interfaces=[obj.Interfaces;cell2table(repmat({""},1,numel(obj.interfaceTableColNames)),'VariableNames',obj.interfaceTableColNames)];%#ok<*STRSCALR>
                obj.Interfaces.Name(end)=elementName;
                obj.Interfaces.ID(end)=ID;
                obj.Interfaces.ParentID(end)=interfaceID;
                obj.Interfaces.DataType(end)=datatype;
                obj.Interfaces.Dimensions(end)=dimensions;
                obj.Interfaces.Units(end)=units;
                obj.Interfaces.Complexity(end)=complexity;
                obj.Interfaces.Minimum(end)=Maximum;
                obj.Interfaces.Maximum(end)=Minimum;
                status=true;
            else
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
            end

        end


        function isTrue=isAnonymousInterface(obj,interfaceID)
            isTrue=false;
            if isempty(obj.getInterfaceName(interfaceID))&&ismember(interfaceID,obj.Interfaces.ID)
                isTrue=true;
            end
        end


        function status=addAnonymousInterface(obj,ID,datatype,dimensions,units,complexity,Maximum,Minimum)
            status=false;

            isValid=obj.validateInputs(ID,datatype,dimensions,units,complexity,Maximum,Minimum);
            if isValid

                if~isempty(obj.getInterfaceName(ID))
                    errorMessage=message('SystemArchitecture:Import:DuplicateInterfaceName',obj.getInterfaceName(ID));
                    obj.errorList=[obj.errorList,errorMessage];
                elseif obj.hasInterface(datatype)
                    errorMessage=message('SystemArchitecture:Import:AnonymousInterfaceDatatypeError',ID);
                    obj.errorList=[obj.errorList,errorMessage];
                end
                obj.Interfaces=[obj.Interfaces;cell2table(repmat({""},1,numel(obj.interfaceTableColNames)),'VariableNames',obj.interfaceTableColNames)];%#ok<*STRSCALR>
                obj.Interfaces.ID(end)=ID;
                obj.Interfaces.DataType(end)=datatype;
                obj.Interfaces.Dimensions(end)=dimensions;
                obj.Interfaces.Units(end)=units;
                obj.Interfaces.Complexity(end)=complexity;
                obj.Interfaces.Minimum(end)=Maximum;
                obj.Interfaces.Maximum(end)=Minimum;
                status=true;
            else
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
            end

        end


        function isTrue=hasInterface(obj,interfaceName)
            if isempty(obj.Interfaces.Name)
                isTrue=false;
            else
                isTrue=ismember(interfaceName,obj.Interfaces.Name);
            end
        end

        function interfaceName=getInterfaceName(obj,ID)

            isValid=obj.validateInputs(ID);
            interfaceName='';
            if isValid
                interfaceName=obj.Interfaces(ismember(obj.Interfaces.ID,ID),:).Name;
            end
        end



        function status=addInterfaceToPort(obj,interfaceID,portID)
            status=false;

            isValid=obj.validateInputs(portID,interfaceID);
            if isValid
                if obj.hasPort(portID)
                    obj.Ports(ismember(obj.Ports.ID,portID),:).InterfaceID=interfaceID;
                    status=true;
                else
                    errorMessage=message('SystemArchitecture:Import:PortNotFound',portID,interfaceID);
                    obj.errorList=[obj.errorList,errorMessage];
                end
            else
                errorMessage=message('SystemArchitecture:Import:InvalidInputFormat');
                obj.errorList=[obj.errorList,errorMessage];
            end
        end


        function[status,errors]=check(obj)
            status=true;
            errors={};
            if~isempty(obj.errorList)
                status=false;
                errors=obj.errorList;
            end

        end


        function[model,log]=build(obj,importModelName)
            [model,~,log,errorLog]=systemcomposer.importModel(importModelName,obj.Components,obj.Ports,obj.Connections,obj.Interfaces);
            obj.importLogs=log;
            obj.importErrorLogs=errorLog;
        end



        function log=getDataBuildLog(obj)
            log=obj.errorList;
        end



        function importLog=getImportLog(obj)
            importLog=obj.importLogs;
        end



        function importErrorLog=getImportErrorLog(obj)
            importErrorLog=obj.importErrorLogs;
        end
    end
end

