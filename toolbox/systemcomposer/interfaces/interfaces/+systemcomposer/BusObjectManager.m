classdef BusObjectManager<handle







    methods(Static)

        function AddInterface(bdOrDDName,inModelStorage,interfaceName,busObjectToUse)



            if nargin>3
                systemcomposer.BusObjectManager.hAddSLVariable(...
                bdOrDDName,inModelStorage,interfaceName,'Simulink.Bus',busObjectToUse);
            else
                systemcomposer.BusObjectManager.hAddSLVariable(...
                bdOrDDName,inModelStorage,interfaceName,'Simulink.Bus');
            end
        end

        function AddAtomicInterface(bdOrDDName,inModelStorage,interfaceName,attributes)



            systemcomposer.BusObjectManager.hAddSLVariable(...
            bdOrDDName,inModelStorage,interfaceName,'Simulink.ValueType');

            if nargin>3
                propNames=fieldnames(attributes);
                for i=1:numel(propNames)
                    propName=propNames{i};
                    systemcomposer.BusObjectManager.SetAtomicInterfaceProperty(bdOrDDName,inModelStorage,interfaceName,propName,attributes.(propName));
                end
            end
        end

        function AddPhysicalInterface(bdOrDDName,inModelStorage,interfaceName,busObjectToUse)





            if bdIsLoaded(bdOrDDName)
                bdH=get_param(bdOrDDName,'Handle');
                if~Simulink.internal.isArchitectureModel(bdH,'Architecture')
                    error(message('SystemArchitecture:Interfaces:CannotAddPhysicalInterface',interfaceName));
                end
            end

            if nargin>3
                systemcomposer.BusObjectManager.hAddSLVariable(...
                bdOrDDName,inModelStorage,interfaceName,'Simulink.ConnectionBus',busObjectToUse);
            else
                systemcomposer.BusObjectManager.hAddSLVariable(...
                bdOrDDName,inModelStorage,interfaceName,'Simulink.ConnectionBus');
            end
        end

        function AddServiceInterface(bdOrDDName,inModelStorage,interfaceName)

            if bdIsLoaded(bdOrDDName)
                bdH=get_param(bdOrDDName,'Handle');
                if~Simulink.internal.isArchitectureModel(bdH,'SoftwareArchitecture')
                    error(message('SystemArchitecture:Interfaces:CannotAddServiceInterface',interfaceName));
                end
            end

            rejectAdd=false;
            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                if(~mws.hasVariable(interfaceName))
                    mws.evalin([interfaceName,'=Simulink.ServiceBus;']);
                else
                    rejectAdd=true;
                end
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                if(~exist(designSection,interfaceName))
                    designSection.addEntry(interfaceName,Simulink.ServiceBus);
                else
                    rejectAdd=true;
                end
            end
            if(rejectAdd)
                errID='SystemArchitecture:Interfaces:EntryCollision';
                if(inModelStorage)
                    errMsg=message(errID,bdOrDDName,interfaceName);
                else
                    errMsg=message(errID,[bdOrDDName,'.sldd'],interfaceName);
                end
                baseException=MSLException([],errMsg);
                throw(baseException);
            end
        end

        function DeleteInterface(bdOrDDName,inModelStorage,interfaceName)

            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                if mws.hasVariable(interfaceName)
                    mws.clear(interfaceName);
                else
                    error(message('SystemArchitecture:Interfaces:PortInterfaceDoesNotExist',interfaceName));
                end
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                if(exist(designSection,interfaceName))
                    deleteEntry(designSection,interfaceName);
                else
                    error(message('SystemArchitecture:Interfaces:PortInterfaceDoesNotExist',interfaceName));
                end
            end
        end

        function RenameInterface(bdOrDDName,inModelStorage,oldInterfaceName,newInterfaceName)

            if strcmp(oldInterfaceName,newInterfaceName)
                return;
            end

            if~isvarname(newInterfaceName)
                error(message('SystemArchitecture:Interfaces:InvalidName',newInterfaceName));
            end

            rejectRename=false;
            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                if(~mws.hasVariable(newInterfaceName))
                    mws.renameVariable(oldInterfaceName,newInterfaceName);
                else
                    existingEntry=mws.getVariable(newInterfaceName);
                    if isa(existingEntry,'Simulink.Bus')||isa(existingEntry,'Simulink.ValueType')||isa(existingEntry,'Simulink.ConnectionBus')||isa(existingEntry,'Simulink.ServiceBus')
                        error(message('SystemArchitecture:Interfaces:PortInterfaceAlreadyExists',newInterfaceName));
                    end
                    rejectRename=true;
                end
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                if(~exist(designSection,newInterfaceName))
                    oldInterfaceEntry=getEntry(designSection,oldInterfaceName,'DataSource',[bdOrDDName,'.sldd']);
                    oldInterfaceEntry.Name=newInterfaceName;
                else
                    existingEntry=designSection.getEntry(newInterfaceName).getValue;
                    if isa(existingEntry,'Simulink.Bus')||isa(existingEntry,'Simulink.ValueType')||isa(existingEntry,'Simulink.ConnectionBus')||isa(existingEntry,'Simulink.ServiceBus')
                        error(message('SystemArchitecture:Interfaces:PortInterfaceAlreadyExists',newInterfaceName));
                    end
                    rejectRename=true;
                end
            end
            if(rejectRename)
                errID='SystemArchitecture:Interfaces:EntryCollision';
                if(inModelStorage)
                    errMsg=message(errID,bdOrDDName,newInterfaceName);
                else
                    errMsg=message(errID,[bdOrDDName,'.sldd'],newInterfaceName);
                end
                baseException=MSLException([],errMsg);
                throw(baseException);
            end



        end

        function SetInterfaceDescription(bdOrDDName,inModelStorage,interfaceName,description)

            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                interface=mws.getVariable(interfaceName);
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                entry=getEntry(designSection,interfaceName,'DataSource',[bdOrDDName,'.sldd']);
                interface=getValue(entry);
            end


            interface.Description=description;


            if(inModelStorage)
                mws.assignin(interfaceName,interface);
            else
                setValue(entry,interface);
            end
        end

        function AddInterfaceElement(bdOrDDName,inModelStorage,interfaceName,elementName,elemParams)

            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                interface=mws.getVariable(interfaceName);
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                entry=getEntry(designSection,interfaceName,'DataSource',[bdOrDDName,'.sldd']);
                interface=getValue(entry);
            end

            if~isvarname(elementName)
                error(message('SystemArchitecture:Interfaces:InvalidName',elementName));
            end

            if ismember(elementName,{interface.Elements.Name})
                error(message('SystemArchitecture:Interfaces:PortInterfaceElementAlreadyExists',elementName,interfaceName));
            end


            if isa(interface,'Simulink.Bus')
                element=Simulink.BusElement;
                if nargin>4
                    element.DataType=elemParams.Type;
                    element.Dimensions=eval(elemParams.Dimensions);
                    element.Unit=elemParams.Units;
                    element.Complexity=elemParams.Complexity;
                    element.Min=eval(elemParams.Minimum);
                    element.Max=eval(elemParams.Maximum);
                    element.Description=elemParams.Description;
                end
            else
                assert(isa(interface,'Simulink.ConnectionBus'));
                element=Simulink.ConnectionElement;
                if(nargin>4&&isfield(elemParams,'Type'))
                    element=systemcomposer.BusObjectManager.hSetBusElementPropertyUsingPortInterfaceElement(element,'Type',elemParams.Type);
                end
            end
            element.Name=elementName;


            interface.Elements(end+1)=element;


            if(inModelStorage)
                mws.assignin(interfaceName,interface);
            else
                setValue(entry,interface);
            end
        end

        function AddFunctionElement(bdOrDDName,storageContext,interfaceName,elementName,elemParams)
            if(storageContext==systemcomposer.architecture.model.interface.Context.MODEL)
                inModelStorage=true;
            else
                inModelStorage=false;
            end

            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                interface=mws.getVariable(interfaceName);
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                entry=getEntry(designSection,interfaceName,'DataSource',[bdOrDDName,'.sldd']);
                interface=getValue(entry);
            end


            element=Simulink.FunctionElement;
            element.Asynchronous=false;
            if nargin>4


                oldArgs=element.Arguments;
                element.Prototype=elemParams.FunctionPrototype;
                prototypeName=element.getFunctionElementNameFromPrototype(element.Prototype);
                if~strcmp(prototypeName,elementName)
                    error(message('SystemArchitecture:Interfaces:FunctionElementNameDoesNotMatchWithFunctionPrototype',elementName,elemParams.FunctionPrototype));
                end

                newInArgNames=reshape(element.getInputArgumentNames(),1,[]);
                newOutArgNames=reshape(element.getOutputArgumentNames(),1,[]);




                args=systemcomposer.BusObjectManager.hSyncFunctionArgumentsWithNewArgs(oldArgs,[{},{}],[newInArgNames,newOutArgNames],bdOrDDName,inModelStorage);
                element.Arguments=args;


                interface.Elements(end+1)=element;
            else



                element.Prototype="y="+elementName+"(u)";
                element.Arguments(1)=Simulink.BusElement;
                element.Arguments(1).Name="u";
                element.Arguments(2)=Simulink.BusElement;
                element.Arguments(2).Name="y";

                interface.Elements(end+1)=element;
            end


            if(inModelStorage)
                mws.assignin(interfaceName,interface);
            else
                setValue(entry,interface);
            end
        end

        function DeleteInterfaceElement(bdOrDDName,inModelStorage,interfaceName,elementName)

            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                if(mws.hasVariable(interfaceName))
                    interface=mws.getVariable(interfaceName);
                    elemIdx=strcmp({interface.Elements.Name},elementName);
                    if any(elemIdx)
                        interface.Elements(elemIdx)=[];
                    else
                        error(message('SystemArchitecture:Interfaces:PortInterfaceElementDoesNotExist',elementName,interfaceName));
                    end
                    mws.assignin(interfaceName,interface);
                end
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                if(exist(designSection,interfaceName))
                    entry=getEntry(designSection,interfaceName,'DataSource',[bdOrDDName,'.sldd']);
                    interface=getValue(entry);
                    elemIdx=strcmp({interface.Elements.Name},elementName);
                    if any(elemIdx)
                        interface.Elements(elemIdx)=[];
                    else
                        error(message('SystemArchitecture:Interfaces:PortInterfaceElementDoesNotExist',elementName,interfaceName));
                    end
                    setValue(entry,interface);
                end
            end
        end

        function RenameInterfaceElement(bdOrDDName,inModelStorage,interfaceName,oldElementName,newElementName)

            if strcmp(oldElementName,newElementName)
                return;
            end

            if~isvarname(newElementName)
                error(message('SystemArchitecture:Interfaces:InvalidName',newElementName));
            end

            if(inModelStorage)
                bdH=get_param(bdOrDDName,'Handle');
                Simulink.SystemArchitecture.internal.ApplicationManager.clearModelWorkspaceRenameContext(bdH);
                Simulink.SystemArchitecture.internal.ApplicationManager.addModelWorkspaceRenameContext(bdH,oldElementName,newElementName)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                interface=mws.getVariable(interfaceName);
                if ismember(newElementName,{interface.Elements.Name})
                    error(message('SystemArchitecture:Interfaces:PortInterfaceElementAlreadyExists',newElementName,interfaceName));
                end

                elemIdx=strcmp({interface.Elements.Name},oldElementName);
                if any(elemIdx)
                    interface.Elements(elemIdx).Name=newElementName;
                else
                    error(message('SystemArchitecture:Interfaces:PortInterfaceElementDoesNotExist',elementName,interfaceName));
                end

                mws.assignin(interfaceName,interface);
                Simulink.SystemArchitecture.internal.ApplicationManager.clearModelWorkspaceRenameContext(bdH);
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);

                Simulink.SystemArchitecture.internal.DictionaryRegistry.ClearSLDDListenerRenameContext(dd.filepath);
                Simulink.SystemArchitecture.internal.DictionaryRegistry.AddSLDDListenerRenameContext(dd.filepath,oldElementName,newElementName);

                designSection=getSection(dd,'Design Data');
                entry=getEntry(designSection,interfaceName,'DataSource',[bdOrDDName,'.sldd']);

                interface=getValue(entry);
                if ismember(newElementName,{interface.Elements.Name})
                    error(message('SystemArchitecture:Interfaces:PortInterfaceElementAlreadyExists',newElementName,interfaceName));
                end

                elemIdx=strcmp({interface.Elements.Name},oldElementName);
                if any(elemIdx)
                    interface.Elements(elemIdx).Name=newElementName;
                else
                    error(message('SystemArchitecture:Interfaces:PortInterfaceElementDoesNotExist',elementName,interfaceName));
                end

                setValue(entry,interface);

                Simulink.SystemArchitecture.internal.DictionaryRegistry.ClearSLDDListenerRenameContext(dd.filepath);
            end
        end

        function RenameFunctionElement(bdOrDDName,inModelStorage,interfaceName,oldElementName,newElementPrototype)






            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                interface=mws.getVariable(interfaceName);

                elemIndex=systemcomposer.BusObjectManager.hGetFunctionElementIndexFromName(interface,oldElementName);
                bdH=get_param(bdOrDDName,'Handle');
                Simulink.SystemArchitecture.internal.ApplicationManager.addModelWorkspaceRenameContext(bdH,oldElementName,interface.Elements(elemIndex).getFunctionElementNameFromPrototype(newElementPrototype));

                interface=systemcomposer.BusObjectManager.hSyncInterfaceWithRenamedFunctionElement(interface,interfaceName,oldElementName,newElementPrototype,bdOrDDName,inModelStorage);
                mws.assignin(interfaceName,interface);

                Simulink.SystemArchitecture.internal.ApplicationManager.clearModelWorkspaceRenameContext(bdH);
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);

                designSection=getSection(dd,'Design Data');
                entry=getEntry(designSection,interfaceName,'DataSource',[bdOrDDName,'.sldd']);
                interface=getValue(entry);

                elemIndex=systemcomposer.BusObjectManager.hGetFunctionElementIndexFromName(interface,oldElementName);
                Simulink.SystemArchitecture.internal.DictionaryRegistry.AddSLDDListenerRenameContext(dd.filepath,oldElementName,interface.Elements(elemIndex).getFunctionElementNameFromPrototype(newElementPrototype));

                interface=systemcomposer.BusObjectManager.hSyncInterfaceWithRenamedFunctionElement(interface,interfaceName,oldElementName,newElementPrototype,bdOrDDName,inModelStorage);
                setValue(entry,interface);

                Simulink.SystemArchitecture.internal.DictionaryRegistry.ClearSLDDListenerRenameContext(dd.filepath);
            end
        end

        function RenameFunctionArgument(bdOrDDName,inModelStorage,interfaceName,elementName,oldArgumentName,newArgumentName)




            if strcmp(oldArgumentName,newArgumentName)
                return;
            end

            if~isvarname(newArgumentName)
                error(message('SystemArchitecture:Interfaces:InvalidFunctionArgumentName',newArgumentName));
            end

            if(inModelStorage)
                bdH=get_param(bdOrDDName,'Handle');
                Simulink.SystemArchitecture.internal.ApplicationManager.addModelWorkspaceRenameContext(bdH,oldArgumentName,newArgumentName);

                mws=get_param(bdOrDDName,'ModelWorkspace');
                interface=mws.getVariable(interfaceName);
                elementIndex=systemcomposer.BusObjectManager.hGetFunctionElementIndexFromName(interface,elementName);

                if ismember(newArgumentName,{interface.Elements(elementIndex).Arguments.Name})

                    error(message('SystemArchitecture:Interfaces:FunctionArgumentCollision',interface.Elements(elementIndex).Name,newArgumentName));
                end

                for i=1:length(interface.Elements(elementIndex).Arguments)
                    if strcmp(interface.Elements(elementIndex).Arguments(i).Name,oldArgumentName)
                        interface.Elements(elementIndex).Arguments(i).Name=newArgumentName;
                        interface.Elements(elementIndex).Prototype=interface.Elements(elementIndex).getUpdatedPrototype();
                        break;
                    end
                end



                mws.assignin(interfaceName,interface);
                Simulink.SystemArchitecture.internal.ApplicationManager.clearModelWorkspaceRenameContext(bdH);
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);

                Simulink.SystemArchitecture.internal.DictionaryRegistry.AddSLDDListenerRenameContext(dd.filepath,oldArgumentName,newArgumentName);

                designSection=getSection(dd,'Design Data');
                entry=getEntry(designSection,interfaceName,'DataSource',[bdOrDDName,'.sldd']);
                interface=getValue(entry);

                elementIndex=systemcomposer.BusObjectManager.hGetFunctionElementIndexFromName(interface,elementName);

                if ismember(newArgumentName,{interface.Elements(elementIndex).Arguments.Name})

                    error(message('SystemArchitecture:Interfaces:FunctionArgumentCollision',interface.Elements(elementIndex).Name,newArgumentName));
                end

                for i=1:length(interface.Elements(elementIndex).Arguments)
                    if strcmp(interface.Elements(elementIndex).Arguments(i).Name,oldArgumentName)
                        interface.Elements(elementIndex).Arguments(i).Name=newArgumentName;
                        interface.Elements(elementIndex).Prototype=interface.Elements(elementIndex).getUpdatedPrototype();
                        break;
                    end
                end

                setValue(entry,interface);

                Simulink.SystemArchitecture.internal.DictionaryRegistry.ClearSLDDListenerRenameContext(dd.filepath);
            end


        end

        function SetInterfaceElementProperty(bdOrDDName,inModelStorage,iName,ieName,iePropName,iePropValue)

            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');

                bo=mws.getVariable(iName);

                for i=1:length(bo.Elements)
                    if(strcmp(bo.Elements(i).Name,ieName))
                        bo.Elements(i)=systemcomposer.BusObjectManager.hSetBusElementPropertyUsingPortInterfaceElement(bo.Elements(i),iePropName,iePropValue);
                        break;
                    end
                end
                mws.assignin(iName,bo);
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                if~designSection.exist(iName)
                    return;
                end
                entry=getEntry(designSection,iName,'DataSource',[bdOrDDName,'.sldd']);

                bo=getValue(entry);

                for i=1:length(bo.Elements)
                    if(strcmp(bo.Elements(i).Name,ieName))
                        bo.Elements(i)=systemcomposer.BusObjectManager.hSetBusElementPropertyUsingPortInterfaceElement(bo.Elements(i),iePropName,iePropValue);
                        break;
                    end
                end
                setValue(entry,bo);
            end
        end

        function SetAtomicInterfaceProperty(bdOrDDName,inModelStorage,iName,propName,propValue)

            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                sigType=mws.getVariable(iName);
                sigType=systemcomposer.BusObjectManager.hSetValueTypeProperty(sigType,propName,propValue);
                mws.assignin(iName,sigType);
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                entry=getEntry(designSection,iName,'DataSource',[bdOrDDName,'.sldd']);

                sigType=getValue(entry);

                sigType=systemcomposer.BusObjectManager.hSetValueTypeProperty(sigType,propName,propValue);

                setValue(entry,sigType);
            end
        end

        function SetFunctionArgumentProperty(bdOrDDName,inModelStorage,iName,feName,faName,propName,propValue)

            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                bo=mws.getVariable(iName);

                elementIndex=systemcomposer.BusObjectManager.hGetFunctionElementIndexFromName(bo,feName);

                for i=1:length(bo.Elements(elementIndex).Arguments)
                    if strcmp(bo.Elements(elementIndex).Arguments(i).Name,faName)
                        bo.Elements(elementIndex).Arguments(i)=systemcomposer.BusObjectManager.hSetBusElementPropertyUsingPortInterfaceElement(bo.Elements(elementIndex).Arguments(i),propName,propValue);
                        break;
                    end
                end
                mws.assignin(iName,bo);
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                if~designSection.exist(iName)
                    return;
                end

                entry=getEntry(designSection,iName,'DataSource',[bdOrDDName,'.sldd']);
                bo=getValue(entry);

                elementIndex=systemcomposer.BusObjectManager.hGetFunctionElementIndexFromName(bo,feName);

                for i=1:length(bo.Elements(elementIndex).Arguments)
                    if strcmp(bo.Elements(elementIndex).Arguments(i).Name,faName)
                        bo.Elements(elementIndex).Arguments(i)=systemcomposer.BusObjectManager.hSetBusElementPropertyUsingPortInterfaceElement(bo.Elements(elementIndex).Arguments(i),propName,propValue);
                        break;
                    end
                end
                setValue(entry,bo);
            end
        end

        function SetFunctionElementProperty(bdOrDDName,inModelStorage,iName,feName,propName,propValue)

            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                bo=mws.getVariable(iName);

                bdH=get_param(bdOrDDName,'Handle');
                for i=1:length(bo.Elements)
                    if(strcmp(bo.Elements(i).Name,feName))
                        if strcmp(propName,'Asynchronous')
                            bo.Elements(i).Asynchronous=propValue;
                            mws.assignin(iName,bo);
                        else

                            Simulink.SystemArchitecture.internal.ApplicationManager.addModelWorkspaceRenameContext(bdH,feName,bo.Elements(i).getFunctionElementNameFromPrototype(propValue));

                            bo=systemcomposer.BusObjectManager.hSyncInterfaceWithRenamedFunctionElement(bo,iName,feName,propValue,bdOrDDName,inModelStorage);
                            bo.Elements(i).Prototype=propValue;
                            mws.assignin(iName,bo);

                            Simulink.SystemArchitecture.internal.ApplicationManager.clearModelWorkspaceRenameContext(bdH);
                        end
                        break;
                    end
                end

            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');

                entry=getEntry(designSection,iName,'DataSource',[bdOrDDName,'.sldd']);
                bo=getValue(entry);

                for i=1:length(bo.Elements)
                    if(strcmp(bo.Elements(i).Name,feName))
                        if strcmp(propName,'Asynchronous')
                            bo.Elements(i).Asynchronous=propValue;
                            setValue(entry,bo);
                        else
                            Simulink.SystemArchitecture.internal.DictionaryRegistry.AddSLDDListenerRenameContext(dd.filepath,feName,bo.Elements(i).getFunctionElementNameFromPrototype(propValue));

                            bo=systemcomposer.BusObjectManager.hSyncInterfaceWithRenamedFunctionElement(bo,iName,feName,propValue,bdOrDDName,inModelStorage);
                            bo.Elements(i).Prototype=propValue;
                            setValue(entry,bo);
                            Simulink.SystemArchitecture.internal.DictionaryRegistry.ClearSLDDListenerRenameContext(dd.filepath);
                        end
                        break;
                    end
                end

            end
        end

        function SetPortInterface(aPort,propval,intrfTypeOrPropValIncludesPrefix)

            slPortBlock=systemcomposer.utils.getSimulinkPeer(aPort);
            if isempty(slPortBlock)
                return;
            end
            slPortBlock=slPortBlock(1);

            if nargin<3
                if strcmpi(get_param(slPortBlock,'BlockType'),'PMIOPort')
                    intrfTypeOrPropValIncludesPrefix='systemcomposer.interface.PhysicalInterface';
                elseif((slfeature('CompositeFunctionElements')>=1)&&strcmpi(get_param(slPortBlock,'isClientServer'),'on'))
                    intrfTypeOrPropValIncludesPrefix='systemcomposer.interface.ServiceInterface';
                else
                    intrfTypeOrPropValIncludesPrefix='systemcomposer.interface.DataInterface';
                end
            end

            if islogical(intrfTypeOrPropValIncludesPrefix)

                propValWithPrefix=propval;
            else

                prefix=systemcomposer.BusObjectManager.getPrefixFromInterfaceType(intrfTypeOrPropValIncludesPrefix);
                propValWithPrefix=[prefix,propval];
            end

            if strcmpi(get_param(slPortBlock,'BlockType'),'PMIOPort')
                if(isempty(propval))
                    systemcomposer.AnonymousInterfaceManager.ResetInterfaceElementProperties(aPort);
                else
                    set_param(slPortBlock,'ConnectionType',propValWithPrefix);
                    systemcomposer.internal.arch.internal.processBatchedPluginEvents(bdroot(slPortBlock));
                end
            elseif(strcmpi(get_param(slPortBlock,'isBusElementPort'),'on'))
                bepTree=systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort(slPortBlock);
                bepTreeRootNode=Simulink.internal.CompositePorts.TreeNode.findNode(bepTree,'');
                if(isempty(propval))
                    systemcomposer.AnonymousInterfaceManager.ResetInterfaceElementProperties(aPort);
                else
                    Simulink.internal.CompositePorts.TreeNode.setDataTypeCL(bepTreeRootNode,propValWithPrefix);
                end
            else
                if(isempty(propval))
                    systemcomposer.AnonymousInterfaceManager.ResetInterfaceElementProperties(aPort);
                else
                    if~isempty(aPort.getArchitecture)&&isa(aPort.getArchitecture,'systemcomposer.architecture.model.sldomain.StateflowArchitecture')
                        stateflowRoot=sfroot;
                        chartId=sfprivate('block2chart',get_param(get_param(slPortBlock,'Parent'),'Handle'));
                        chartObj=stateflowRoot.find('-isa','Stateflow.Chart','Id',chartId);
                        dataObj=chartObj.find({'-isa','Stateflow.Data','-OR','-isa','Stateflow.Message'},'Name',get_param(slPortBlock,'Name'));
                        dataObj.DataType=propValWithPrefix;
                    else
                        set_param(slPortBlock,'OutDataTypeStr',propValWithPrefix);
                    end
                end
            end
        end

        function prefix=getPrefixFromInterfaceType(intrfType)
            switch intrfType
            case{'systemcomposer.interface.DataInterface',...
                'systemcomposer.interface.PhysicalInterface',...
                'systemcomposer.interface.ServiceInterface'}
                prefix='Bus: ';
            case 'systemcomposer.ValueType'
                prefix='ValueType: ';
            otherwise
                prefix='';
            end
        end

        function pi=getPortInterface(slPortBlock)

            slPortBlock=slPortBlock(1);
            aPort=systemcomposer.utils.getArchitecturePeer(slPortBlock);
            if(strcmpi(get_param(slPortBlock,'isBusElementPort'),'on'))
                bepTree=systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort(slPortBlock);
                bepTreeRootNode=Simulink.internal.CompositePorts.TreeNode.findNode(bepTree,'');
                pi=Simulink.internal.CompositePorts.TreeNode.getDataType(bepTreeRootNode);
            else
                if~isempty(aPort.getArchitecture)&&isa(aPort.getArchitecture,'systemcomposer.architecture.model.sldomain.StateflowArchitecture')
                    stateflowRoot=sfroot;
                    chartId=sfprivate('block2chart',get_param(get_param(slPortBlock,'Parent'),'Handle'));
                    chartObj=stateflowRoot.find('-isa','Stateflow.Chart','Id',chartId);
                    dataObj=chartObj.find({'-isa','Stateflow.Data','-OR','-isa','Stateflow.Message'},'Name',get_param(slPortBlock,'Name'));
                    pi=dataObj.DataType;
                else
                    pi=get_param(slPortBlock,'OutDataTypeStr');
                end
            end
            pi=strrep(pi,' ','');
            if(any(strfind(pi,'Bus:')))
                pi=strrep(pi,'Bus:','');
            elseif(any(strfind(pi,'Inherit:auto')))
                pi='';
            end
        end

        function bepTree=fetchTreeNodeObjectForBusElementPort(bepBlockHandle)

            bepBlock=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(bepBlockHandle);

            bepTree=bepBlock.port.tree;
        end

        function bo=CreateBusObjectFromPortInterface(pi)

            bo=Simulink.Bus;
            piels=pi.getElements();
            for i=1:length(piels)
                piel=piels(i);
                bel=Simulink.BusElement;
                bel.Name=piel.getName();
                bel.DataType=piel.getType();
                bel.Dimensions=eval(piel.getDimensions());
                bel.Unit=piel.getUnits();
                bel.Complexity=piel.getComplexity();
                bel.Min=eval(piel.getMinimum());
                bel.Max=eval(piel.getMaximum());
                bel.Description=piel.getDescription();
                bo.Elements(end+1)=bel;
            end
        end

        function SetupPortInterfaceFromBusObject(mf0Model,pi,bo)

            if isa(bo,'Simulink.ValueType')
                systemcomposer.BusObjectManager.SetupPortInterfaceFromValueType(pi,bo);
                return;
            end

            pielProcessedMap=containers.Map('KeyType','char','ValueType','logical');

            pielNames=pi.getElementNames();
            for i=1:length(pielNames)
                pielProcessedMap(pielNames{i})=false;
            end

            txn=mf0Model.beginTransaction();

            for i=1:length(bo.Elements)
                bel=bo.Elements(i);
                piel=pi.getElement(bel.Name);

                if(isempty(piel))
                    piel=pi.addElement(bel.Name);
                end






                piel.createOwnedType();


                pielProcessedMap(bel.Name)=true;

                systemcomposer.BusObjectManager.hPopulatePortInterfaceElementUsingBusElement(piel,bel);
            end


            pielProcessedMapKeys=keys(pielProcessedMap);
            for i=1:length(pielProcessedMapKeys)
                if(~pielProcessedMap(pielProcessedMapKeys{i}))
                    pi.removeElement(pielProcessedMapKeys{i});
                end
            end

            txn.commit();
        end

        function SetupPortInterfaceFromValueType(pi,valueType)
            txn=mf.zero.getModel(pi).beginTransaction();

            try
                pi.p_Type=valueType.DataType;
                pi.p_Dimensions=mat2str(valueType.Dimensions);
                pi.p_Units=valueType.Unit;
                pi.p_Complexity=valueType.Complexity;
                pi.p_Minimum=mat2str(valueType.Min);
                pi.p_Maximum=mat2str(valueType.Max);
                pi.p_Description=valueType.Description;
            catch
            end

            txn.commit();
        end

    end

    methods(Static,Access=private)
        function hPopulatePortInterfaceElementUsingBusElement(piel,bel)
            piel.setType(bel.DataType);
            if piel.hasOwnedType
                piel.setDimensions(mat2str(bel.Dimensions));
                piel.setUnits(bel.Unit,true);
                piel.setComplexity(bel.Complexity);
                piel.setMinimum(mat2str(bel.Min));
                piel.setMaximum(mat2str(bel.Max));
                piel.setDescription(bel.Description);
            end
        end

        function outbel=hSetBusElementPropertyUsingPortInterfaceElement(inbel,propname,propval)
            outbel=inbel;
            propval=convertStringsToChars(propval);
            switch propname
            case 'Type'
                if isa(outbel,'Simulink.ConnectionElement')
                    if contains(propval,':')


                        outbel.Type=propval;
                    else

                        if strcmp(propval,'')
                            propval='<domain name>';
                        end
                        if any(contains(simscape.internal.availableDomains,propval))||strcmp(propval,'<domain name>')
                            outbel.Type=['Connection: ',propval];
                        else
                            outbel.Type=['Bus: ',propval];
                        end
                    end
                else
                    outbel.DataType=propval;
                end
            case 'Dimensions'
                outbel.Dimensions=eval(propval);
            case 'Units'
                outbel.Unit=propval;
            case 'Complexity'
                outbel.Complexity=propval;
            case 'Minimum'
                outbel.Min=eval(propval);
            case 'Maximum'
                outbel.Max=eval(propval);
            case 'Description'
                outbel.Description=propval;
            end
        end

        function sigType=hSetValueTypeProperty(sigType,propname,propval)
            propval=convertStringsToChars(propval);
            try
                switch propname
                case{'Type','DataType'}
                    sigType.DataType=propval;
                case 'Dimensions'
                    sigType.Dimensions=eval(propval);
                case 'Units'
                    sigType.Unit=propval;
                case 'Complexity'
                    sigType.Complexity=propval;
                case 'Minimum'
                    sigType.Min=eval(propval);
                case 'Maximum'
                    sigType.Max=eval(propval);
                case 'Description'
                    sigType.Description=propval;
                end
            catch

            end
        end

        function hAddSLVariable(bdOrDDName,inModelStorage,interfaceName,objectType,objectToUse)




            if~isvarname(interfaceName)
                error(message('SystemArchitecture:Interfaces:InvalidName',interfaceName));
            end

            interfaceName=convertStringsToChars(interfaceName);
            if(inModelStorage)
                mws=get_param(bdOrDDName,'ModelWorkspace');
                if(~mws.hasVariable(interfaceName))
                    if nargin>4
                        mws.assignin(interfaceName,objectToUse);
                    else
                        mws.evalin([interfaceName,'=',objectType,';']);
                    end
                else
                    existingEntry=mws.getVariable(interfaceName);
                    if isa(existingEntry,'Simulink.Bus')||isa(existingEntry,'Simulink.ValueType')
                        error(message('SystemArchitecture:Interfaces:PortInterfaceAlreadyExists',interfaceName));
                    end
                    source=bdOrDDName;
                    if(~inModelStorage)
                        source=[bdOrDDName,'.sldd'];
                    end
                    error(message('SystemArchitecture:Interfaces:EntryCollision',source,interfaceName));
                end
            else
                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                designSection=getSection(dd,'Design Data');
                if(~exist(designSection,interfaceName))
                    if nargin>4
                        assert(isa(objectToUse,objectType),'Unexpected object type: ',class(objectToUse));
                        designSection.assignin(interfaceName,objectToUse)
                    else
                        designSection.addEntry(interfaceName,eval(objectType));
                    end
                else
                    existingEntry=designSection.getEntry(interfaceName).getValue;
                    if isa(existingEntry,'Simulink.Bus')||isa(existingEntry,'Simulink.ValueType')
                        error(message('SystemArchitecture:Interfaces:PortInterfaceAlreadyExists',interfaceName));
                    end
                    source=bdOrDDName;
                    if(~inModelStorage)
                        source=[bdOrDDName,'.sldd'];
                    end
                    error(message('SystemArchitecture:Interfaces:EntryCollision',source,interfaceName));
                end
            end
        end

        function index=hGetFunctionElementIndexFromName(interface,functionElementName)
            index=1;
            for i=1:length(interface.Elements)
                if(strcmp(interface.Elements(i).Name,functionElementName))
                    index=i;
                    return;
                end
            end
        end

        function interface=hSyncInterfaceWithRenamedFunctionElement(interface,interfaceName,oldElementName,newElementPrototype,bdOrDDName,inModelStorage)



            if ismember(newElementPrototype,{interface.Elements.Prototype})



                error(message('SystemArchitecture:Interfaces:PortInterfaceElementAlreadyExists',newElementPrototype,interfaceName));
            end

            elemIdx=strcmp({interface.Elements.Name},oldElementName);
            if any(elemIdx)
                oldInArgNames=reshape(interface.Elements(elemIdx).getInputArgumentNames(),1,[]);
                oldOutArgNames=reshape(interface.Elements(elemIdx).getOutputArgumentNames(),1,[]);

                interface.Elements(elemIdx).Prototype=newElementPrototype;
                newInArgNames=reshape(interface.Elements(elemIdx).getInputArgumentNames(),1,[]);
                newOutArgNames=reshape(interface.Elements(elemIdx).getOutputArgumentNames(),1,[]);

                inArgs=reshape(interface.Elements(elemIdx).Arguments(1:numel(oldInArgNames)),1,[]);
                outArgs=reshape(interface.Elements(elemIdx).Arguments(numel(oldInArgNames)+1:end),1,[]);
                args=[inArgs,outArgs];




                inOutArgNames=intersect(newInArgNames,newOutArgNames);
                if~isempty(inOutArgNames)
                    newOutArgNames=setxor(newOutArgNames,inOutArgNames);
                end

                args=systemcomposer.BusObjectManager.hSyncFunctionArgumentsWithNewArgs(args,[oldInArgNames,oldOutArgNames],[newInArgNames,newOutArgNames],bdOrDDName,inModelStorage);
                interface.Elements(elemIdx).Arguments=args;
            else
                error(message('SystemArchitecture:Interfaces:PortInterfaceElementDoesNotExist',oldElementName,interface.Name));
            end
        end

        function newArgs=hSyncFunctionArgumentsWithNewArgs(args,oldArgNames,newArgNames,bdOrDDName,inModelStorage)



            oldArgNames=unique(oldArgNames,'stable');

            newArgsSameNameIdxes=1:numel(newArgNames);
            newArgsSameNameIdxes=newArgsSameNameIdxes(ismember(newArgNames,oldArgNames));
            oldArgsSameNameIdxes=1:numel(oldArgNames);
            oldArgsSameNameIdxes=oldArgsSameNameIdxes(ismember(oldArgNames,newArgNames));


            oldArgIdx=1;
            newArgs=args;
            for newArgIdx=1:numel(newArgNames)
                if ismember(newArgIdx,newArgsSameNameIdxes)

                    moveFromIdx=strcmp(oldArgNames,newArgNames{newArgIdx});
                    newArgs(newArgIdx)=args(moveFromIdx);
                else


                    while ismember(oldArgIdx,oldArgsSameNameIdxes)

                        oldArgIdx=oldArgIdx+1;
                    end
                    if newArgIdx<numel(args)


                        if oldArgIdx<numel(args)
                            if(inModelStorage)
                                bdH=get_param(bdOrDDName,'Handle');
                                Simulink.SystemArchitecture.internal.ApplicationManager.addModelWorkspaceRenameContext(bdH,args(oldArgIdx).Name,newArgNames{newArgIdx});
                            else
                                dd=Simulink.data.dictionary.open([bdOrDDName,'.sldd']);
                                Simulink.SystemArchitecture.internal.DictionaryRegistry.AddSLDDListenerRenameContext(dd.filepath,args(oldArgIdx).Name,newArgNames{newArgIdx});
                            end
                            newArgs(newArgIdx)=args(oldArgIdx);
                            newArgs(newArgIdx).Name=newArgNames{newArgIdx};
                            oldArgIdx=oldArgIdx+1;
                        else




                            newArgs(newArgIdx)=Simulink.BusElement;
                            newArgs(newArgIdx).Name=newArgNames{newArgIdx};
                        end

                    else


                        newArgs(newArgIdx)=Simulink.BusElement;
                        newArgs(newArgIdx).Name=newArgNames{newArgIdx};
                    end
                end
            end


            if newArgIdx<numel(args)
                newArgs(newArgIdx+1:numel(args))=[];
            elseif isempty(newArgIdx)

                newArgs(1)=[];
            end
        end


    end
end


