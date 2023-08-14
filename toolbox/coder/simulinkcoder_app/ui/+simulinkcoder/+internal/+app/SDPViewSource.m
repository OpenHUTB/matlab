



classdef SDPViewSource<handle
    properties
        SubScriptions={};
ClientID
Channel
    end
    properties(Access=protected)
m_source
m_container
m_cdefinition
        m_selectedPlatformType='ServiceInterfaceConfiguration'
        layoutModel=''
        fcNavigationModel=''
        ncNavigationModel=''
        centerModel=''
        propertyInspectorModel=''
        propsRequireRefreshUI={}
pageInfo
rowInfo
numOfPlatforms
        Connector=simulinkcoder.internal.app.Connector
        ErrorHandler=@(e)disp(['Error: ',e.message])
    end
    methods
        function obj=SDPViewSource()

        end
        function receive(obj,msg)
            try
                if~isvalid(obj)
                    return;
                end
                if isfield(msg,'clientID')
                    if(ischar(msg.clientID)&&(~strcmp(msg.clientID,obj.ClientID)&&sscanf(msg.clientID,'%x')~=obj.ClientID)||...
                        (isnumeric(msg.clientID)&&msg.clientID~=obj.ClientID))
                        return;
                    end
                end
                obj.handleMessage(msg);
            catch me
                obj.handleError(me);
            end
        end
        function handleMessage(obj,msg)
            if isfield(msg,'Type')&&strcmp(msg.Type,'command')
                switch(msg.Value)
                case 'SDPUIReady'
                    obj.handleReadyMessage();
                end
            elseif isfield(msg,'messageID')
                switch msg.messageID
                case{'EditCompleted'}
                    obj.transactionify(@()obj.handleEditCompleted(msg));
                case{'CenterTableEditCompleted'}
                    obj.transactionify(@()obj.handleCenterTableEditCompleted(msg));
                case{'ButtonClicked'}
                    obj.transactionify(@()obj.handleButtonClicked(msg));
                case{'loadStorageClass'}
                    pkg=msg.data.pkgs{1};
                    coder.internal.CoderDataStaticAPI.loadStorageClassInPackage(obj.m_source,pkg);
                case{'unloadStorageClass'}
                    pkg=msg.data.pkgs{1};
                    coder.internal.CoderDataStaticAPI.removeLegacyPackage(obj.m_source,pkg);
                case{'requestStorageClassInPackage'}
                    if~isempty(obj.m_source)
                        refreshPkg=msg.refreshPkg;
                        simulinkcoder.internal.app.CoderDataMethods.getStorageClassInNonBuiltinPkg(...
                        obj.m_source,obj.ClientID,...
                        obj.Channel,refreshPkg);
                    end
                end
            else
                data=msg.data;
                switch data.messageID
                case{'selectNavNode'}
                    if isempty(data.data.parent)
                        obj.pageInfo=struct('id',data.data.id,'parent',data.data.id);
                    else
                        obj.pageInfo=struct('id',data.data.id,'parent',data.data.parent);
                    end
                    obj.handleSelectNavNodeMessage();
                case{'TableButtonClicked'}
                    switch data.action
                    case 'new'
                        coderDataType=data.coderDataType;

                        platform=loc_getPlatform(obj,obj.m_selectedPlatformType);
                        coderData=coder.internal.CoderDataStaticAPI.create(platform,coderDataType);
                        obj.pageInfo.id=coderDataType;
                        obj.rowInfo=struct('coderDataType',data.coderDataType,...
                        'coderDataName',coderData.Name,...
                        'coderDataUUID',coderData.UUID);



                        obj.refreshCenterPane(-1);
                    case 'delete'
                        coderDataType=data.coderDataType;
                        obj.pageInfo.id=coderDataType;

                        platform=loc_getPlatform(obj,obj.m_selectedPlatformType);
                        if isfield(msg.data,'deleteConfirmed')&&msg.data.deleteConfirmed
                            canBeDeleted=true;
                        else
                            [canBeDeleted,usageInfo]=loc_canDataBeDeleted(platform,coderDataType,data.value.data);
                        end
                        if canBeDeleted
                            coder.internal.CoderDataStaticAPI.delete(platform,coderDataType,{data.value.data.Name});
                        else


                            loc_requestDeleteConfirmation(obj,data,usageInfo);
                        end
                    case 'openPackage'
                        simulinkcoder.internal.app.CoderDataMethods.getStorageClassInNonBuiltinPkg(...
                        obj.m_source,obj.ClientID,...
                        obj.Channel,false);
                    case 'duplicate'
                        coderDataType=data.coderDataType;
                        obj.pageInfo.id=coderDataType;
                        platform=loc_getPlatform(obj,obj.m_selectedPlatformType);
                        coder.internal.CoderDataStaticAPI.clone(platform,coderDataType,{data.value.data.Name});
                    end
                case{'RadioButtonClicked'}
                    if data.value
                        coderDataType=data.data.coderDataType;
                        rowName=data.data.data.Name;
                        ref=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeForContainer(obj.m_cdefinition.owner,coderDataType,rowName);

                        if~ref.isEmpty&&strcmp(data.data.columnMetaData.prop,'platformDefault')
                            hlp=coder.internal.CoderDataStaticAPI.getHelper();
                            hlp.setPlatformDefault(obj.m_cdefinition,coderDataType,ref.getCoderDataEntry);
                        end
                    end
                case{'SDPViewReady'}
                    if~isempty(obj.m_source)&&~isempty(obj.m_cdefinition)
                        obj.autoSetSelectedPlatform();
                        obj.refreshDesigner();
                    end
                case{'EditCompleted'}
                    obj.transactionify(@()obj.handleSDPViewEditCompleted(data));
                case{'PiEditCompleted'}

                    obj.rowInfo=struct('coderDataType',data.data.parentType,...
                    'coderDataName',data.data.parentName,...
                    'coderDataUUID',data.data.parentUUID,...
                    'data',data.data.parentData);
                    obj.transactionify(@()obj.handlePiEditCompleted(data));
                case{'CenterTableEditCompleted'}
                    obj.transactionify(@()obj.handleCenterTableEditCompleted(msg));
                case{'rowSelected'}

                    obj.pageInfo=struct('id',msg.data.data.coderDataType,'parent',obj.pageInfo.parent);

                    obj.rowInfo=struct('coderDataType',msg.data.data.coderDataType,...
                    'coderDataName',msg.data.data.data.Name,...
                    'coderDataUUID',msg.data.data.data.UUID,...
                    'data',msg.data.data.data);
                    obj.handleRowSelectedMessage();
                case{'resetPI'}

                    obj.resetCodePreview();
                    obj.publish(struct('messageID','resetPI',...
                    'clientID',obj.ClientID));
                case{'save'}
                    obj.saveButtonCallback();
                case{'undo'}
                    coderdictionary.data.api.undo(obj.m_cdefinition.owner);
                case{'redo'}
                    coderdictionary.data.api.redo(obj.m_cdefinition.owner);
                case{'newFunctionComponent'}

                    platforms=obj.m_cdefinition.owner.SoftwarePlatforms;
                    if platforms.Size>0
                        errordlg(['A Function Component platform already exists in ',obj.m_source,'. Each coder dictionary can only have one Function Component platform.']);
                    else


                        obj.m_selectedPlatformType='ServiceInterfaceConfiguration';
                        coder.internal.CoderDataStaticAPI.initializeSDP(obj.m_source);
                    end
                case{'deleteFunctionComponent'}

                    hlp=coder.internal.CoderDataStaticAPI.getHelper();
                    if hlp.exist(obj.m_source,'ServiceInterfaceConfiguration')
                        obj.transactionify(@()loc_deleteFunctionComponent(obj));

                        obj.autoSetSelectedPlatform();
                    else
                        errordlg(['A Function Component platform does not exist in ',obj.m_source,'.']);
                    end
                case{'PlatformEditCompleted'}
                    obj.m_selectedPlatformType=data.data.value;
                    obj.handlePlatformSelected(data.data.value);
                case{'refresh'}
                    obj.refreshDesigner();
                case{'showHelp','showDataInterfaceDoc','showServiceInterfaceDoc'}
                    simulinkcoder.internal.app.CoderDataMethods.showHelp('ecoder_dictionary');
                case{'gotoModel'}
                    coder.internal.CoderDataStaticAPI.gotoModel(obj.ModelHandle);
                case{'requestRefreshCenterPane'}
                    obj.refreshCenterPane(data.requestID);
                case{'changeInterface'}
                    obj.transactionify(@()loc_changeConfiguration(obj,data.configurationType));
                    obj.publish(struct('messageID','changeInterfaceSuccess',...
                    'clientID',obj.ClientID));
                    obj.refreshDesigner();
                case{'browseFile'}
                    if isequal(data.action,'openFile')
                        [files,folder]=uigetfile({'*.sldd'},'MultiSelect','off');
                    else
                        [files,folder]=uiputfile({'*.sldd'});
                    end
                    if~isequal(files,0)&&~isequal(folder,0)
                        obj.handleBrowseFile(data.property,folder,files);
                    end

                    if~isempty(simulinkcoder.internal.app.DictionaryViewManager.instance.getView(-1))
                        simulinkcoder.internal.app.DictionaryViewManager.instance.getView(-1).Dlg.show;
                    end
                case{'browseFileChanged'}
                    obj.handleBrowseFileChanged(data);
                case{'fileSelectionNextClicked'}
                    status=obj.handleBrowseFileChanged(data);
                    if status==0
                        msg.messageID='responseNextButtonClicked';
                        msg.clientID=obj.ClientID;
                        obj.publish(msg);
                    end
                case{'configurationSelectorDialogOnHide'}
                    if isempty(obj.m_source)

                        simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(-1);
                    else

                        if~coder.dictionary.exist(obj.m_source)

                            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.m_source);
                        end
                    end
                case{'setConfiguration'}
                    if isequal(data.dictionarySetupOption,'newDictionary')
                        if~exist(data.fullpath,'file')
                            Simulink.data.dictionary.create(data.fullpath);
                        else

                            coder.dictionary.remove(data.fullpath);
                        end
                        cdict=coder.dictionary.create(data.fullpath,data.configurationType);
                        cdict.view;
                    elseif isequal(data.dictionarySetupOption,'openDictionary')
                        if coder.dictionary.exist(data.fullpath)
                            cdict=coder.dictionary.open(data.fullpath);
                        else
                            cdict=coder.dictionary.create(data.fullpath,data.configurationType);
                        end
                        cdict.view;
                    end
                    assert(isa(obj,'simulinkcoder.internal.app.NewDataDictionaryViewSource'));
                    obj.notifySlddFileSelected(data.fullpath);

                    simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(-1);
                case{'setupInterface'}
                    if~coder.dictionary.exist(obj.m_source)
                        obj.setupInterface(data.configurationType);
                        obj.publish(struct('messageID','setupInterfaceSuccess',...
                        'clientID',obj.ClientID));
                        if isequal(data.configurationType,'ServiceInterface')
                            obj.m_selectedPlatformType='ServiceInterfaceConfiguration';
                        else
                            obj.m_selectedPlatformType='DataInterfaceConfiguration';
                        end
                        obj.refreshDesigner();
                    end
                case{'openDictionary'}
                    cdict=coder.dictionary.open(data.fullpath);
                    cdict.view;
                    assert(isa(obj,'simulinkcoder.internal.app.NewDataDictionaryViewSource'));
                    obj.notifySlddFileSelected(data.fullpath);

                    simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(-1);
                case{'openSharedDictionary'}
                    assert(isa(obj,'simulinkcoder.internal.app.SDPModelDictionaryViewSource'));
                    ecd=get_param(obj.m_source,'EmbeddedCoderDictionary');
                    if isempty(ecd)
                        simulinkcoder.internal.app.ViewSDP('','ModelToLink',get_param(obj.m_source,'Name'));
                    else
                        simulinkcoder.internal.app.ViewSDP(ecd);
                    end
                otherwise
                    error(['unsupported message:',data.messageID]);
                end
            end
        end
        function refreshDesigner(obj)
            loc_loadViewModel(obj);
            obj.handlePlatformSelected(obj.m_selectedPlatformType);
            obj.resetCodePreview();
        end
        function handlePlatformSelected(obj,selectedPlatformType)
            function disableRow=checkFeature(child,disableRow)
                if isfield(child,'enabledIf')
                    conds=child.enabledIf;
                    for ci=1:length(conds)
                        if iscell(conds)
                            cond=conds{ci};
                        else
                            cond=conds(ci);
                        end
                        if strcmp(cond.dataProp,'slfeature')
                            if~isequal(slfeature(cond.slfeature),cond.value)
                                disableRow=true;
                                break;
                            end
                        end
                    end
                end
            end
            loc_loadViewModel(obj);
            switch selectedPlatformType
            case 'DataInterfaceConfiguration'
                navigationModel=obj.ncNavigationModel;
            case 'ServiceInterfaceConfiguration'
                navigationModel=obj.fcNavigationModel;
            otherwise

                navigationModel='';
            end
            if~isempty(navigationModel)
                if iscell(navigationModel.children)

                    for i=1:length(navigationModel.children)
                        child=navigationModel.children{i};
                        if isfield(child,'label')&&~isempty(child.label)
                            navigationModel.children{i}.label=obj.translate(child.label);
                        end
                        disableRow=false;
                        disableRow=checkFeature(child,disableRow);
                        if disableRow
                            navigationModel.children{i}.hidden=true;
                            continue;
                        end
                        for j=1:length(child.children)
                            if iscell(child.children)
                                node=child.children{j};
                            else
                                node=child.children(j);
                            end
                            disableRow=false;
                            disableRow=checkFeature(node,disableRow);
                            if disableRow
                                node.hidden=true;
                            end
                            if isfield(node,'label')&&~isempty(node.label)
                                node.label=obj.translate(node.label);
                            end
                            if iscell(child.children)
                                navigationModel.children{i}.children{j}=node;
                            else
                                navigationModel.children{i}.children(j)=node;
                            end
                        end
                    end
                    firstNavNode=navigationModel.children{1};
                else

                    for i=1:length(navigationModel.children)
                        child=navigationModel.children(i);
                        if isfield(child,'label')&&~isempty(child.label)
                            navigationModel.children(i).label=obj.translate(child.label);
                        end
                    end
                    firstNavNode=navigationModel.children(1);
                end
                obj.pageInfo=struct('id',[],'parent',firstNavNode.id);
            else
                navigationModel=[];
                obj.pageInfo=struct('id',[],'parent','');
            end
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            platforms=hlp.getSoftwarePlatforms(obj.m_cdefinition);
            platformValues={platforms.PlatformType};
            platformLabels={platforms.Name};
            if loc_hasFunctionPlatform(obj)
                if strcmp(obj.m_selectedPlatformType,'ServiceInterfaceConfiguration')
                    obj.publish(struct('messageID','updateToolstripState',...
                    'clientID',obj.ClientID,'data',struct('new',false,'delete',true)));
                else
                    obj.publish(struct('messageID','updateToolstripState',...
                    'clientID',obj.ClientID,'data',struct('new',false,'delete',false)));
                end
            else
                obj.publish(struct('messageID','updateToolstripState',...
                'clientID',obj.ClientID,'data',struct('new',true,'delete',false)));
            end
            obj.publish(struct('messageID','refreshNavPane',...
            'navListData',navigationModel,...
            'platforms',struct('label',platformLabels,'value',platformValues),...
            'selectedPlatform',obj.m_selectedPlatformType,...
            'clientID',obj.ClientID));
            obj.handleSelectNavNodeMessage();
        end

        function handleButtonClicked(obj,msg)
            action=msg.action;
            switch action
            case 'new'
                prop=msg.data.prop;


                tmp=strsplit(prop,'_');
                prop=tmp{2};
                coder.internal.CoderDataStaticAPI.create(obj.m_cdefinition,prop);
                obj.refreshUI;
            case 'delete'
                name=msg.data.value;



                parent=msg.data.parent;
                tmp=strsplit(parent,'_');
                type=tmp{2};
                coder.internal.CoderDataStaticAPI.delete(obj.m_cdefinition,type,{name});
                obj.refreshUI;
            end
        end
        function delete(obj)
            obj.unsubscribe;
        end
        function handleCenterTableEditCompleted(obj,msg)
            data=msg.data;
            objectID=data.objectID;
            if~strcmp(objectID,'SDP')
                return;
            end
            value=data.data.value;
            prop=data.data.prop;

            try
                if strcmp(prop,'SystemTargetFile')
                    loc_checkSTF(value)
                end
                pC=obj.m_cdefinition.owner.SoftwarePlatforms(1);
                pC.(prop)=value;
                if strcmp(prop,'Name')
                    obj.refreshDesigner;
                end
            catch e
                obj.sendUpdateFailureMsg(data.data,e.message)
                return;
            end
            obj.sendUpdateSuccessfulMsg(data.data);
        end
        function handlePiEditCompleted(obj,msg)
            data=msg.data;
            if strcmp(data.parentType,'DataDefaults')
                elemName=data.parentName;
                property=data.id;
                value=data.value;
                scValue=data.parentData.StorageClass;
                isMemorySection=strcmp(property,'MemorySection');
                isStorageClass=strcmp(property,'StorageClass');
                if isMemorySection||isStorageClass
                    coder.internal.CoderDataStaticAPI.setDefaultCoderDataForElement(obj.m_cdefinition,elemName,property,value);
                else

                    instSpValues=data.parentData.instSpValues;
                    for i=1:length(instSpValues)
                        if strcmp(property,instSpValues(i).Name)
                            instSpValues(i).Value=value;
                            break;
                        end
                    end
                    scObj=coder.internal.CoderDataStaticAPI.getByName(obj.m_cdefinition,'StorageClass',scValue);
                    if isa(scObj,'coderdictionary.data.LegacyStorageClass')
                        try
                            coder.internal.CoderDataStaticAPI.validateInstanceSpecificProperty(...
                            obj.m_cdefinition,elemName,scObj.Package,scObj.ClassName,property,value,instSpValues);
                        catch e

                            obj.sendUpdateFailureMsg(data,e.message)
                            return;
                        end
                    end
                    coder.internal.CoderDataStaticAPI.setDataDefaultInstanceSpecificProperties(obj.m_cdefinition,elemName,instSpValues);
                end
            elseif strcmp(data.parentType,'FunctionDefaults')
                elemName=data.parentName;
                property=data.id;
                value=data.value;
                isMemorySection=strcmp(property,'MemorySection');
                isFunctionClass=strcmp(property,'FunctionClass');
                if isMemorySection||isFunctionClass
                    coder.internal.CoderDataStaticAPI.setDefaultCoderDataForElement(obj.m_cdefinition,elemName,property,value);
                end
            else
                coderData=coderdictionary.data.SlCoderDataClient.getElementByUUIDOfCoderDataTypeForContainer(obj.m_cdefinition.owner,data.parentType,data.parentUUID);
                dataProp=coderData.getCoderDataEntry;
                valueObj=data.value;
                switch data.widgetType
                case{'textbox','textWithTextbox','optionList','checkbox','textarea'}
                    value=obj.getValue(dataProp,data.dataProp);
                    switch class(value)
                    case{'coderdictionary.data.StorageClass',...
                        'coderdictionary.data.AbstractStorageClass',...
                        'coderdictionary.data.LegacyStorageClass'}
                        platform=loc_getPlatform(obj,obj.m_selectedPlatformType);
                        if isa(platform,'coderdictionary.softwareplatform.FunctionPlatform')
                            scRef=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeInPlatform(...
                            obj.m_cdefinition.owner,platform.Name,'StorageClass',data.value);
                            if~scRef.isEmpty
                                valueObj=scRef.getCoderDataEntry;
                            end
                        else
                            valueObj=coder.internal.CoderDataStaticAPI.getByName(obj.m_cdefinition,'StorageClass',data.value);
                        end
                    case{'coderdictionary.softwareplatform.FunctionMemorySection'}
                        valueObj=coder.internal.CoderDataStaticAPI.getByName(obj.m_cdefinition,'FunctionMemorySection',data.value);
                    case{'coderdictionary.data.MemorySection'}
                        platform=loc_getPlatform(obj,obj.m_selectedPlatformType);
                        if isa(platform,'coderdictionary.softwareplatform.FunctionPlatform')
                            msRef=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeInPlatform(...
                            obj.m_cdefinition.owner,platform.Name,'MemorySection',data.value);
                            if~msRef.isEmpty
                                valueObj=msRef.getCoderDataEntry;
                            end
                        else
                            valueObj=coder.internal.CoderDataStaticAPI.getByName(obj.m_cdefinition,'MemorySection',data.value);
                        end
                    end
                    try
                        if isa(dataProp,'coderdictionary.data.StorageClass')



                            if isa(valueObj,'coderdictionary.data.MemorySection')
                                hlp=coder.internal.CoderDataStaticAPI.getHelper();
                                hlp.setProp(dataProp,data.dataProp,valueObj);
                            else
                                coderdictionary.data.SlCoderDataClient.setProperty(obj.m_cdefinition.owner,dataProp,data.dataProp,data.value);
                            end
                        else
                            eval(['dataProp.',data.dataProp,'= data.value;']);%#ok<EVLDOT>
                        end
                    catch
                        try
                            hlp=coder.internal.CoderDataStaticAPI.getHelper();
                            hlp.setProp(dataProp,data.dataProp,valueObj);
                        catch e

                            obj.sendUpdateFailureMsg(data,e.message)
                            return;
                        end
                    end


                    obj.sendUpdateSuccessfulMsg(data);
                otherwise
                    error([data.widgetType,' is not supported.'])
                end
                if isfield(data,'refreshUI')&&data.refreshUI
                    obj.refreshCenterPane(-1);
                end
            end
        end
        function handleSDPViewEditCompleted(obj,msg)
            data=msg.data;
            value=data.newValue.value;
            prop=data.newValue.prop;
            dataProp=data.newValue.dataProp;
            switch dataProp
            case{'sdp'}
                try
                    pC=obj.m_cdefinition.owner.SoftwarePlatforms(1);
                    errMsg=setMainTableValue(pC,prop,value);
                catch me
                    errMsg=me.message;
                end
            end

            if isempty(errMsg)
                msg.messageID='updateSuccessful_SDP';


                if strcmp(prop,'Name')||ismember(data.cellInfo.id,obj.propsRequireRefreshUI)
                    obj.refreshDesigner;
                end
            else
                msg.messageID='updateFailure_SDP';
                msg.msg=errMsg;
            end
            msg.clientID=obj.ClientID;
            msg.data=data;
            obj.publish(msg);

            function errMsg=setMainTableValue(rte,prop,value)
                errMsg='';
                if ismember(prop,properties(rte))
                    hlp=coder.internal.CoderDataStaticAPI.getHelper;
                    try
                        txn=hlp.beginTxn(obj.m_cdefinition);
                        rte.(prop)=value;
                        hlp.commitTxn(txn);
                    catch me
                        if~isempty(txn)
                            hlp.rollbackTxn(txn);
                        end
                        throwAsCaller(me);
                    end
                else
                    errMsg=['Software platform does not support to change ',prop,' to ',value,' yet.'];
                end
            end

        end
        function handleEditCompleted(obj,msg)
            objectID=msg.objectID;
            data=msg.data;
            if~strcmp(objectID,'SDP')
                return;
            end




            cellId=data.cellInfo.id;
            tmp=strsplit(cellId,'_');
            tableName=tmp{1};
            value=data.newValue.value;
            prop=data.newValue.prop;
            try
                pC=obj.m_cdefinition.owner.SoftwarePlatforms(1);
                if strcmp(tableName,'SDPTable')
                    errMsg=setMainTableValue(pC,prop,value);
                elseif strcmp(tableName,'SDPService')
                    errMsg=setServiceTableValue(pC,prop,value);
                else

                    serviceData=loc_getDataProp(obj,pC,tmp{2});
                    found=false;
                    for i=1:serviceData.Size
                        item=serviceData(i);
                        if(item.UUID==tableName)
                            found=true;
                            errMsg=setTimerServiceValue(item,prop,value);
                        end
                    end
                    if~found
                        errMsg=['Cannot find item with UUID: ',tableName];
                    end
                end
            catch me
                errMsg=me.message;
            end
            if isempty(errMsg)
                msg.messageID='updateSuccessful_SDP';


                if ismember(data.cellInfo.id,obj.propsRequireRefreshUI)
                    obj.refreshUI;
                end
            else
                msg.messageID='updateFailure_SDP';
                msg.msg=errMsg;
            end
            msg.clientID=obj.ClientID;
            msg.data=data;
            obj.publish(msg);

            function errMsg=setMainTableValue(rte,prop,value)
                errMsg='';
                if ismember(prop,properties(rte))
                    rte.(prop)=value;
                else
                    errMsg=['Software platform does not support to change ',prop,' to ',value,' yet.'];
                end
            end
            function errMsg=setTimerServiceValue(timer,prop,value)
                errMsg='';
                props=properties(timer);
                switch prop
                case props
                    if strcmp(prop,'StorageClass')
                        value=coder.internal.CoderDataStaticAPI.getByName(obj.m_cdefinition,'StorageClass',value);
                    end
                    timer.(prop)=value;
                otherwise
                    errMsg=['Timer service  does not support to change ',prop,' to ',value,' yet.'];
                end
            end
            function errMsg=setServiceTableValue(pC,prop,value)
                errMsg='';
                if isa(pC,'coderdictionary.softwareplatform.FunctionPlatform')
                    sdp=pC.Component;
                else
                    sdp=pC.Application;
                end
                switch prop
                case{'FunctionClockTickFunctionName'}
                    sdp.ComponentSchedulingAndTimingInterface.Timing.(prop)=value;
                case{'ImplicitReadDataSharing','ImplicitWriteDataSharing',...
                    'ExplicitReadDataSharing','ExplicitWriteDataSharing'}
                    sdp.ComponentSchedulingAndTimingInterface.DataSharing.(prop)=value;
                otherwise
                    errMsg=['Software platform does not support to change ',prop,' to ',value,' yet.'];
                end
            end
        end
        function refreshUI(obj)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            dd=obj.m_cdefinition;
            txn=hlp.beginTxn(dd);
            hlp.commitTxn(txn);
            try
                obj.handleReadyMessage;
            catch me
                if~isempty(txn)
                    hlp.rollbackTxn(txn);
                end
                rethrow(me);
            end
        end
        function removeListener(~)

        end
        function addListener(~)

        end
        function handleRowSelectedMessage(obj)
            msg.messageID='refreshPI_SDP';
            msg.clientID=obj.ClientID;
            coderDataType=obj.rowInfo.coderDataType;
            coderDataName=obj.rowInfo.coderDataName;
            coderDataUUID=obj.rowInfo.coderDataUUID;
            loc_loadViewModel(obj);
            viewModel=obj.propertyInspectorModel.(coderDataType);
            if~iscell(viewModel.children)
                viewModel.children=num2cell(viewModel.children);
            end
            if strcmp(coderDataType,'DataDefaults')
                obj.resetCodePreview();

                for i=1:length(viewModel.children)
                    child=viewModel.children{i};
                    child.parentData=obj.rowInfo.data;
                    if isfield(child,'enabledIf')
                        conds=child.enabledIf;
                        disableRow=false;
                        for ci=1:length(conds)
                            if iscell(conds)
                                cond=conds{ci};
                            else
                                cond=conds(ci);
                            end
                            if strcmp(cond.dataProp,'class')
                                if~strcmp(class(obj.rowInfo.data),cond.value)
                                    disableRow=true;
                                    break;
                                end
                            elseif strcmp(cond.dataProp,'slfeature')
                                if~isequal(slfeature(cond.slfeature),cond.value)
                                    disableRow=true;
                                    break;
                                end
                            elseif~isequal(obj.rowInfo.data.(cond.dataProp),cond.value)
                                disableRow=true;
                                break;
                            end
                        end
                        if disableRow
                            child.hidden=true;
                            viewModel.children{i}=child;
                            continue;
                        end
                    end
                    child.parentName=coderDataName;
                    child.parentType=coderDataType;
                    child.parentUUID=coderDataUUID;
                    if strcmp(child.id,'Name')
                        child.value=obj.rowInfo.data.label;
                    else
                        child.value=obj.rowInfo.data.(child.id);
                    end
                    switch child.widgetType
                    case 'optionList'
                        child.allowedValues=obj.rowInfo.data.(['allowed',child.id]);
                    end
                    if isfield(child,'label')&&~isempty(child.label)
                        child.label=obj.translate(child.label);
                    end
                    viewModel.children{i}=child;
                end
                instSpValues=obj.rowInfo.data.instSpValues;
                instSpValuesCell=cell(1,length(instSpValues));
                if~isempty(instSpValues)
                    for i=1:length(instSpValues)
                        if strcmp(instSpValues(i).Type,'string')
                            instSpValues(i).Type='textbox';%#ok<*AGROW>
                        end
                        if strcmp(instSpValues(i).Type,'enum')
                            instSpValues(i).Type='optionList';
                        end
                        instSpValuesCell{i}.widgetType=instSpValues(i).Type;
                        if~isempty(instSpValues(i).AllowedValues)
                            if iscell(instSpValues(i).AllowedValues)
                                allowedValues=cell(1,length(instSpValues(i).AllowedValues));
                                for j=1:length(instSpValues(i).AllowedValues)
                                    allowedValues{j}.id=instSpValues(i).AllowedValues{j};
                                    allowedValues{j}.label=instSpValues(i).AllowedValues{j};
                                end
                                instSpValues(i).AllowedValues=allowedValues;
                            end
                            instSpValues(i).AllowedValues=jsonencode(instSpValues(i).allowedValues);
                        end
                        instSpValuesCell{i}.allowedValues=instSpValues(i).AllowedValues;

                        instSpValuesCell{i}.invalidMessage='';
                        instSpValuesCell{i}.dataProp=instSpValues(i).Name;
                        instSpValuesCell{i}.label=instSpValues(i).Name;
                        instSpValuesCell{i}.id=instSpValues(i).Name;
                        instSpValuesCell{i}.class='pi_enabled';
                        instSpValuesCell{i}.value=instSpValues(i).Value;
                        instSpValuesCell{i}.displayValue=instSpValues(i).DisplayValue;
                        instSpValuesCell{i}.parentName=coderDataName;
                        instSpValuesCell{i}.parentType=coderDataType;
                        instSpValuesCell{i}.parentUUID=coderDataUUID;
                        instSpValuesCell{i}.parentData=obj.rowInfo.data;
                    end
                    viewModel.children=[viewModel.children;instSpValuesCell'];
                end
            elseif strcmp(coderDataType,'FunctionDefaults')
                obj.resetCodePreview();

                for i=1:length(viewModel.children)
                    child=viewModel.children{i};
                    child.parentData=obj.rowInfo.data;
                    if isfield(child,'enabledIf')
                        conds=child.enabledIf;
                        disableRow=false;
                        for ci=1:length(conds)
                            if iscell(conds)
                                cond=conds{ci};
                            else
                                cond=conds(ci);
                            end
                            if strcmp(cond.dataProp,'class')
                                if~strcmp(class(obj.rowInfo.data),cond.value)
                                    disableRow=true;
                                    break;
                                end
                            elseif strcmp(cond.dataProp,'slfeature')
                                if~isequal(slfeature(cond.slfeature),cond.value)
                                    disableRow=true;
                                    break;
                                end
                            elseif~isequal(obj.rowInfo.data.(cond.dataProp),cond.value)
                                disableRow=true;
                                break;
                            end
                        end
                        if disableRow
                            child.hidden=true;
                            viewModel.children{i}=child;
                            continue;
                        end
                    end
                    child.parentName=coderDataName;
                    child.parentType=coderDataType;
                    child.parentUUID=coderDataUUID;
                    if strcmp(child.id,'Name')
                        child.value=obj.rowInfo.data.label;
                    else
                        child.value=obj.rowInfo.data.(child.id);
                    end
                    switch child.widgetType
                    case 'optionList'
                        child.allowedValues=obj.rowInfo.data.(['allowed',child.id]);
                    end
                    if isfield(child,'label')&&~isempty(child.label)
                        child.label=obj.translate(child.label);
                    end
                    viewModel.children{i}=child;
                end
            else

                coderData=coderdictionary.data.SlCoderDataClient.getElementByUUIDOfCoderDataTypeForContainer(obj.m_cdefinition.owner,coderDataType,coderDataUUID);


                if coderData.isEmpty
                    isFound=false;
                    sr=slroot;
                    if isValidSlObject(sr,obj.m_source)
                        coderDataAll=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataType(obj.m_source,coderDataType);
                        for i=1:length(coderDataAll)
                            if strcmp(coderDataAll(i).getProperty('UUID'),coderDataUUID)
                                coderData=coderDataAll(i);
                                isFound=true;
                                break;
                            end
                        end
                    end
                    if~isFound
                        obj.resetCodePreview();
                        return;
                    end
                end
                dataProp=coderData.getCoderDataEntry;

                if isempty(dataProp)
                    error(['Cannot find coder data ',coderDataType,' named ',coderDataName]);
                end
                obj.updateCodePreview(dataProp);

                for i=1:length(viewModel.children)
                    child=viewModel.children{i};
                    if isfield(child,'disabledIf')
                        cond=child.disabledIf;
                        if dataProp.(cond.dataProp)==cond.value
                            child.hidden=true;
                            viewModel.children{i}=child;
                            continue;
                        end
                    end
                    if isfield(child,'enabledIf')
                        conds=child.enabledIf;
                        disableRow=false;
                        for ci=1:length(conds)
                            if iscell(conds)
                                cond=conds{ci};
                            else
                                cond=conds(ci);
                            end
                            if strcmp(cond.dataProp,'class')
                                if~strcmp(class(dataProp),cond.value)
                                    disableRow=true;
                                    break;
                                end
                            elseif strcmp(cond.dataProp,'slfeature')
                                if~isequal(slfeature(cond.slfeature),cond.value)
                                    disableRow=true;
                                    break;
                                end
                            elseif strcmp(cond.dataProp,'function')
                                disableRow=~eval([cond.value,'(dataProp)']);
                            elseif~isequal(dataProp.(cond.dataProp),cond.value)
                                disableRow=true;
                                break;
                            end
                        end
                        if disableRow
                            child.hidden=true;
                            viewModel.children{i}=child;
                            child.parentData=obj.rowInfo.data;
                            continue;
                        end
                    end
                    if isfield(child,'label')&&~isempty(child.label)
                        child.label=obj.translate(child.label);
                        child.value=child.label;
                    end
                    if isfield(child,'tooltip')&&~isempty(child.tooltip)
                        child.tooltip=obj.translate(child.tooltip);
                    end

                    child.errMsg='';
                    if isfield(child,'errorIf')
                        conds=child.errorIf;
                        for ci=1:length(conds)
                            if iscell(conds)
                                cond=conds{ci};
                            else
                                cond=conds(ci);
                            end
                            if isequal(dataProp.(cond.dataProp),cond.value)
                                child.errMsg=obj.translate(cond.message);
                            elseif isempty(cond.value)&&loc_isPropertyEmpty(dataProp.(cond.dataProp))
                                child.errMsg=obj.translate(cond.message);
                            end
                        end
                    end
                    child.parentName=coderDataName;
                    child.parentType=coderDataType;
                    child.parentUUID=coderDataUUID;
                    child.parentData=obj.rowInfo.data;
                    switch child.widgetType
                    case{'textbox','textWithTextbox'}
                        child.value=obj.getValue(dataProp,child.dataProp);
                    case{'optionList'}
                        value=obj.getValue(dataProp,child.dataProp);
                        if isfield(child,'allowedValues')
                            allowedValues=child.allowedValues;
                        else
                            allowedValues={};
                        end
                        switch class(value)
                        case 'coderdictionary.softwareplatform.DataCommunicationMethodEnum'
                            switch value
                            case coderdictionary.softwareplatform.DataCommunicationMethodEnum.DuringExecution
                                value="DuringExecution";
                            case coderdictionary.softwareplatform.DataCommunicationMethodEnum.OutsideExecution
                                value="OutsideExecution";
                            case coderdictionary.softwareplatform.DataCommunicationMethodEnum.DirectAccess
                                value="DirectAccess";
                            end
                        case{'coderdictionary.data.AbstractStorageClass',...
                            'coderdictionary.data.StorageClass',...
                            'coderdictionary.data.LegacyStorageClass'}
                            switch coderDataType
                            case 'MeasurementInterface'
                                modelElement='InternalData';
                            case 'ParameterTuningInterface'
                                modelElement='LocalParameters';
                            case 'ParameterArgumentTuningInterface'
                                modelElement='ParameterArguments';
                            otherwise
                                modelElement='Inports';
                            end
                            platform=loc_getPlatform(obj,obj.m_selectedPlatformType);
                            if isa(platform,'coderdictionary.softwareplatform.FunctionPlatform')
                                scs=coderdictionary.data.SlCoderDataClient.getAllCoderDataForModelElementTypeInPlatform(...
                                obj.m_cdefinition.owner,platform.Name,modelElement,'StorageClass','IndividualLevel');
                            else
                                scs=coderdictionary.data.SlCoderDataClient.getAllCoderDataForModelElementTypeForContainer(obj.m_cdefinition.owner,modelElement,'StorageClass','IndividualLevel');
                            end
                            allowedValues={};
                            for scsIdx=1:length(scs)
                                allowedValues{end+1}=struct('value',scs(scsIdx).getProperty('DisplayName'),'label',scs(scsIdx).getProperty('DisplayName'));
                            end
                            if isempty(value)||isempty(value.UUID)
                                value='';
                            else
                                value=value.DisplayName;
                            end
                        case{'coderdictionary.softwareplatform.FunctionMemorySection'}
                            allowedValues={struct('value','None','label',message("SimulinkCoderApp:core:NoneEnumLabel").getString)};
                            mss=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeForContainer(obj.m_cdefinition.owner,'FunctionMemorySection');
                            for idx=1:length(mss)
                                allowedValues{end+1}=struct('value',mss(idx).getProperty('DisplayName'),'label',mss(idx).getProperty('DisplayName'));
                            end
                            if isempty(value)||isempty(value.UUID)
                                value='None';
                            else
                                value=value.Name;
                            end
                        case{'coderdictionary.data.MemorySection'}
                            platform=loc_getPlatform(obj,obj.m_selectedPlatformType);
                            if isa(platform,'coderdictionary.softwareplatform.FunctionPlatform')
                                mss=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeInPlatform(obj.m_cdefinition.owner,platform.Name,'MemorySection');
                            else
                                mss=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeForContainer(obj.m_cdefinition.owner,'MemorySection');
                            end
                            allowedValues={struct('value','None','label',message("SimulinkCoderApp:core:NoneEnumLabel").getString)};
                            for idx=1:length(mss)

                                if strcmp(mss(idx).getClass,'MemorySection')
                                    allowedValues{end+1}=struct('value',mss(idx).getProperty('DisplayName'),'label',mss(idx).getProperty('DisplayName'));
                                end
                            end
                            if isempty(value)||isempty(value.UUID)
                                value='None';
                            else
                                value=value.DisplayName;
                            end
                        otherwise
                            value=string(value);
                            allowedValues=child.allowedValues;
                        end
                        child.value=value;
                        if~iscell(allowedValues)&&length(allowedValues)==1
                            child.allowedValues={allowedValues};
                        else
                            child.allowedValues=allowedValues;
                        end
                        for ii=1:length(child.allowedValues)
                            if iscell(child.allowedValues)
                                child.allowedValues{ii}.label=obj.translate(child.allowedValues{ii}.label);
                            else
                                child.allowedValues(ii).label=obj.translate(child.allowedValues(ii).label);
                            end
                        end
                    otherwise
                        if isfield(child,'dataProp')
                            child.value=obj.getValue(dataProp,child.dataProp);
                        end
                        if isfield(child,'widgetType')&&strcmp(child.widgetType,'text')
                            child.value=obj.translate(child.value);
                        end
                    end
                    if~isfield(child,'disabled')
                        child.disabled=obj.isDisabled(dataProp);
                    end
                    child.copyable=obj.isCopyable(dataProp,child.disabled);
                    viewModel.children{i}=child;
                end
            end
            msg.data=viewModel;
            obj.publish(msg);
        end
        function msgData=getCenterPaneData(obj)
            msgData='';
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            if hlp.exist(obj.m_source,obj.m_selectedPlatformType)
                switch obj.m_selectedPlatformType
                case 'ServiceInterfaceConfiguration'
                    msgData=obj.getComponentData('ServiceInterfaceConfiguration');
                case 'DataInterfaceConfiguration'
                    msgData=obj.getComponentData('DataInterfaceConfiguration');
                end
            end
        end
        function msgData=getComponentData(obj,platformType)
            if isempty(obj.pageInfo.parent)
                mainNode=obj.pageInfo.id;
                subNode='';
            else
                mainNode=obj.pageInfo.parent;
                subNode=obj.pageInfo.id;
            end
            loc_loadViewModel(obj);
            viewModel=obj.centerModel.(mainNode);
            [pC,pcRef]=loc_getPlatform(obj,platformType);
            msgData=viewModel;
            msgData.activeNode=subNode;
            if~iscell(msgData.children)
                msgData.children=num2cell(msgData.children);
            end
            for i=1:length(msgData.children)
                row=msgData.children{i};
                if isfield(row,'label')
                    row.label=obj.translate(row.label);
                end
                if isfield(row,'tooltip')
                    row.tooltip=obj.translate(row.tooltip);
                end
                if~isfield(row,'children')
                    row.children={};
                end
                for j=1:length(row.children)
                    if iscell(row.children)
                        if isfield(row.children{j},'label')
                            row.children{j}.label=obj.translate(row.children{j}.label);
                        end
                        if isfield(row.children{j},'tooltip')
                            row.children{j}.tooltip=obj.translate(row.children{j}.tooltip);
                        end
                        if isfield(row.children{j},'addButtonTooltip')
                            row.children{j}.addButtonTooltip=obj.translate(row.children{j}.addButtonTooltip);
                        end
                    else
                        if isfield(row.children(j),'label')
                            row.children(j).label=obj.translate(row.children(j).label);
                        end
                        if isfield(row.children(j),'tooltip')
                            row.children(j).tooltip=obj.translate(row.children(j).tooltip);
                        end
                        if isfield(row.children(j),'addButtonTooltip')
                            row.children(j).addButtonTooltip=obj.translate(row.children(j).addButtonTooltip);
                        end
                    end
                end
                if isfield(row,'id')&&...
                    (strcmp(row.id,'DataDefaults')||...
                    strcmp(row.id,'FunctionDefaults'))
                    if~isa(pC,'coderdictionary.data.C_Definitions')
                        row.hidden=true;
                        msgData.children{i}=row;
                        continue;
                    else
                        for j=1:length(row.children)

                            if strcmp(row.children{j}.widgetType,'table')
                                for cc=1:length(row.children{j}.columns)
                                    if iscell(row.children{j}.columns)
                                        if isfield(row.children{j}.columns{cc},'label')
                                            row.children{j}.columns{cc}.label=obj.translate(row.children{j}.columns{cc}.label);
                                        end
                                        if isfield(row.children{j}.columns{cc},'tooltip')
                                            row.children{j}.columns{cc}.tooltip=obj.translate(row.children{j}.columns{cc}.tooltip);
                                        end
                                    else
                                        if isfield(row.children{j}.columns(cc),'label')
                                            row.children{j}.columns(cc).label=obj.translate(row.children{j}.columns(cc).label);
                                        end
                                        if isfield(row.children{j}.columns(cc),'tooltip')
                                            row.children{j}.columns(cc).tooltip=obj.translate(row.children{j}.columns(cc).tooltip);
                                        end
                                    end
                                end
                                break;
                            end
                        end
                        if strcmp(row.id,'FunctionDefaults')
                            defaultsData=loc_getFunctionDefaults(obj);
                        else
                            defaultsData=loc_getDataDefaults(obj);
                        end
                        row.children{j}.data=defaultsData;
                        msgData.children{i}=row;
                        continue;
                    end
                end
                if~isfield(row,'dataProp')
                    dataValue=[];
                else
                    dataValue=loc_getDataProp(obj,pC,row.dataProp);
                end


                if~iscell(row.children)
                    row.children=num2cell(row.children);
                end
                for j=1:length(row.children)
                    if iscell(row.children)
                        subRow=row.children{j};
                    else
                        subRow=row.children(j);
                    end
                    if strcmp(subRow.widgetType,'table')
                        subRow.data='';
                        if isa(dataValue,'mf.zero.Sequence')
                            numOfData=dataValue.Size;
                        else
                            numOfData=length(dataValue);
                        end
                        initialData=[];
                        subRow.data=cell(1,numOfData);

                        for cc=1:length(subRow.columns)
                            if iscell(subRow.columns)
                                if isfield(subRow.columns{cc},'label')
                                    subRow.columns{cc}.label=obj.translate(subRow.columns{cc}.label);
                                end
                                if isfield(subRow.columns{cc},'tooltip')
                                    subRow.columns{cc}.tooltip=obj.translate(subRow.columns{cc}.tooltip);
                                end
                            else
                                if isfield(subRow.columns(cc),'label')
                                    subRow.columns(cc).label=obj.translate(subRow.columns(cc).label);
                                end
                                if isfield(subRow.columns(cc),'tooltip')
                                    subRow.columns(cc).tooltip=obj.translate(subRow.columns(cc).tooltip);
                                end
                            end
                        end
                        for k=1:numOfData
                            if iscell(dataValue)
                                dValue=dataValue{k};
                            else
                                dValue=dataValue(k);
                            end
                            for cc=1:length(subRow.columns)
                                if iscell(subRow.columns)
                                    column=subRow.columns{cc};
                                else
                                    column=subRow.columns(cc);
                                end

                                if strcmp(column.widgetType,'radio')
                                    if strcmp(column.prop,'platformDefault')
                                        if isempty(initialData)
                                            initialData=coderdictionary.data.SlCoderDataClient.getDefaultCoderDataInPlatform(pcRef,subRow.coderDataType);
                                        end
                                        subRow.data{k}.value=false;
                                        if~initialData.isEmpty()&&strcmp(initialData.getProperty('Name'),subRow.data{k}.Name)
                                            subRow.data{k}.value=true;
                                        end
                                    end
                                elseif~strcmp(column.widgetType,'icon')
                                    subRow.data{k}.(column.prop)=obj.getValue(dValue,column.prop);
                                end
                            end
                            subRow.data{k}.UUID=dValue.UUID;
                            subRow.data{k}.disabled=obj.isDisabled(dValue);
                            subRow.data{k}.copyable=obj.isCopyable(dValue,subRow.data{k}.disabled);
                        end
                    elseif strcmp(subRow.widgetType,'PiTreeTable')
                        if~iscell(subRow.children)
                            subRow.children=num2cell(subRow.children);
                        end
                        for ci=1:length(subRow.children)
                            c=subRow.children{ci};
                            subRow.children{ci}.value=dataValue.(c.prop);
                            if isfield(subRow.children{ci},'label')
                                subRow.children{ci}.label=obj.translate(subRow.children{ci}.label);
                            end
                            if isfield(subRow.children{ci},'tooltip')
                                subRow.children{ci}.tooltip=obj.translate(subRow.children{ci}.tooltip);
                            end
                        end
                    else
                        if isfield(subRow,'dataProp')&&isequal(subRow.dataProp,'dictionary')&&isfield(subRow,'prop')
                            if isempty(obj.m_dd)
                                if isequal(subRow.prop,'filespec')
                                    modelFilespec=get_param(obj.ModelHandle,'FileName');
                                    if~isempty(modelFilespec)
                                        [~,fileName,fileExt]=fileparts(modelFilespec);
                                        subRow.value=[fileName,fileExt];
                                    else
                                        subRow.value=get_param(obj.ModelHandle,'Name');
                                    end
                                end
                            else
                                subRow.value=obj.m_dd.(subRow.prop);
                            end
                        else


                            if isfield(subRow,'value')
                                subRow.value=obj.translate(subRow.value);
                            else
                                if isfield(subRow,'prop')
                                    subRow.value=dataValue.(subRow.prop);
                                end
                            end
                        end

                    end
                    if~isempty(row.children)
                        if iscell(row.children)
                            row.children{j}=subRow;
                        else
                            row.children(j)=subRow;
                        end
                    end
                end
                msgData.children{i}=row;
            end
        end
        function refreshCenterPane(obj,requestID)
            msg.messageID='refreshCenterPane';
            msg.requestID=requestID;
            msg.clientID=obj.ClientID;
            msg.data=obj.getCenterPaneData();
            msg.rowInfo=obj.rowInfo;
            msg.pageInfo=obj.pageInfo;
            obj.publish(msg);
        end
        function refreshFromListener(obj,inserted,deleted,modified,modifiedUUIDs)
            try
                isPlatformAddedOrDeleted=false;
                if isempty(obj.m_cdefinition)

                    return;
                end
                if ismember('Coder_Data.Container',inserted)||...
                    ismember('Coder_Data.Container',deleted)||...
                    ismember('Coder_Data.Container',modified)
                    hlp=coder.internal.CoderDataStaticAPI.getHelper();
                    softwarePlatforms=hlp.getSoftwarePlatforms(obj.m_cdefinition);
                    platformTypes={softwarePlatforms.PlatformType};
                    if obj.numOfPlatforms~=length(platformTypes)
                        isPlatformAddedOrDeleted=true;
                    end
                end
                if~isempty(obj.rowInfo)&&ismember(obj.rowInfo.coderDataUUID,modifiedUUIDs)
                    obj.refreshCenterPane(-1);
                elseif isPlatformAddedOrDeleted


                    obj.autoSetSelectedPlatform();
                    obj.refreshDesigner();
                else
                    msg.messageID='mf0ModelChanged';
                    msg.clientID=obj.ClientID;
                    obj.publish(msg);
                end
            catch me

                disp(me.message);
            end
        end
        function handleSelectNavNodeMessage(obj)
            msg.messageID='responseSelectNavNode_SDP';
            msg.clientID=obj.ClientID;
            msg.data=obj.getCenterPaneData();


            rowData={};
            for i=1:length(msg.data.children)
                if isequal(msg.data.children{i}.widgetType,'section')&&...
                    isequal(msg.data.children{i}.id,msg.data.activeNode)
                    for j=1:length(msg.data.children{i}.children)
                        if isequal(msg.data.children{i}.children{j}.widgetType,'table')
                            rowData=msg.data.children{i}.children{j}.data;
                            break;
                        end
                    end
                end
            end
            if~isempty(rowData)
                obj.rowInfo.coderDataType=msg.data.activeNode;
                if iscell(rowData)
                    row=rowData{1};
                else
                    row=rowData(1);
                end
                obj.rowInfo.coderDataName=row.Name;
                obj.rowInfo.coderDataUUID=row.UUID;
                obj.rowInfo.data=row;
            end
            obj.publish(msg);
        end
        function resetCodePreview(obj)
            msg.messageID='resetCodePreviewRequest';
            msg.clientID=obj.ClientID;
            obj.publish(msg);
        end
        function updateCodePreview(obj,coderDataObj)
            msg.messageID='responseCodePreviewRequest';
            msg.clientID=obj.ClientID;
            try
                msg.data=coder.preview.internal.getCodePreview(coderDataObj.getPlatformOwner,obj.rowInfo.coderDataType,obj.rowInfo.coderDataName,obj.rowInfo.coderDataUUID);
                msg.errorMsg='';
            catch
                msg.data=jsonencode(struct('previewStr',message('SimulinkCoderApp:sdp:CodePreviewNotAvailable').getString,...
                'type','info'));
                msg.errorMsg='';
            end
            obj.publish(msg);
        end
        function handleReadyMessage(obj)
            msg.messageID='responseReady_SDP';
            msg.clientID=obj.ClientID;
            pC=loc_getPlatform(obj,obj.m_selectedPlatformType);
            loc_loadViewModel(obj);
            layout=obj.layoutModel;

            for tt=1:length(layout.children)
                table=layout.children(tt);

                [numRow,branches]=loc_getNumOfRows(obj,table,pC,{});


                dataCell=cell(1,numRow);

                nn=1;
                for i=1:length(branches)
                    row=branches{i};
                    dataValue=loc_getDataProp(obj,pC,row.dataProp);

                    if~isempty(row.parent)
                        row.parent=[table.tableName,'_',row.parent];
                    end
                    row.id=[table.tableName,'_',row.id];
                    if isfield(row,'refreshUI')&&row.refreshUI
                        obj.propsRequireRefreshUI{end+1}=row.id;
                    end
                    dataCell{nn}=loc_createRowWidget(obj,row,dataValue);
                    nn=nn+1;


                    if strcmp(row.nodeType,'sequence')
                        if isfield(row,'children')&&~isempty(row.children)
                            subData=dataValue;
                            subTable=row.children;
                            subTable.parent=[table.tableName,'_',subTable.parent];
                            numRow=i;


                            for j=1:subData.Size
                                subRowData=subData(j);

                                subHeaderRowId=[subRowData.(subTable.id),'_',row.dataProp];

                                dataCell{nn}=loc_createRowWidget(obj,subTable,...
                                subRowData);
                                dataCell{nn}.Value.id=subHeaderRowId;
                                nn=nn+1;


                                for jj=1:length(subTable.children)
                                    if iscell(subTable.children(jj))
                                        subRow=subTable.children{jj};
                                    else
                                        subRow=subTable.children(jj);
                                    end

                                    subRow.id=[subHeaderRowId,'_',subRow.id];
                                    if isfield(subRow,'refreshUI')&&subRow.refreshUI
                                        obj.propsRequireRefreshUI{end+1}=subRow.id;
                                    end
                                    subRow.parent=subHeaderRowId;
                                    dataCell{nn}=loc_createRowWidget(obj,subRow,subRowData);
                                    nn=nn+1;
                                end
                                numRow=numRow+1+length(subTable.children);
                            end
                        end
                    end
                end
                msg.data.(table.tableName)=dataCell;
            end
            msg.dialogTitle='';
            obj.publish(msg);
        end

        function sendUpdateFailureMsg(obj,data,errMsg)
            msg=loc_createMessageData(data,obj.ClientID);
            msg.messageID='updateFailure_validation';
            msg.errMsg=errMsg;
            obj.publish(msg);
        end
        function sendUpdateSuccessfulMsg(obj,data)
            msg=loc_createMessageData(data,obj.ClientID);
            msg.messageID='updateSuccess_validation';
            obj.publish(msg);
        end

        function handleError(obj,e)
            msg.clientID=obj.ClientID;
            msg.ErrorMessage=e.message;
            msg.messageID='displayError';
            obj.publish(msg);
        end
        function publish(obj,msg)
            obj.Connector.publish(obj.Channel,msg);
        end
        function subscribe(obj)
            if~isempty(obj.SubScriptions)
                obj.unsubscribe()
            end
            obj.SubScriptions{end+1}=obj.Connector.subscribe(obj.Channel,@obj.receive);
        end
        function unsubscribe(obj)
            try
                for i=1:length(obj.SubScriptions)
                    obj.Connector.unsubscribe(obj.SubScriptions{i});
                end
            catch me
                if~isequal(me.identifier,'MATLAB:class:InvalidHandle')
                    rethrow(me);
                end
            end
        end

        function transactionify(obj,fcnHandle)
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            txn=hlp.beginTxn(obj.m_cdefinition);
            try
                feval(fcnHandle);
                hlp.commitTxn(txn);
            catch me
                if~isempty(txn)
                    hlp.rollbackTxn(txn);
                end
                throwAsCaller(me);
            end
        end
        function value=getValue(obj,data,prop)
            if strcmp(prop,'Name')&&...
                (isa(data,'coderdictionary.data.LegacyStorageClass')||...
                isa(data,'coderdictionary.data.LegacyMemorySection'))

                prop='DisplayName';
            end
            props=strsplit(prop,'.');
            if length(props)>1
                for i=1:length(props)
                    data=obj.getValue(data,props{i});
                end
                value=data;
            else
                try

                    value=data.(prop);
                catch
                    try
                        ref=coderdictionary.data.SlCoderDataClient.getElementByUUIDOfCoderDataTypeForContainer(obj.m_cdefinition.owner,'StorageClass',dataProp.UUID);
                        value=ref.getProperty(prop);
                    catch
                        hlp=coder.internal.CoderDataStaticAPI.getHelper();
                        value=hlp.getProp(data,prop);
                    end
                end
            end
            if strcmp(prop,'DataSource')
                if strcmp(value,obj.m_cdefinition.owner.ID)||~data.isLegacy
                    [~,f,e]=fileparts(value);
                    value=[f,e];
                end
            end
        end
        function ret=isDisabled(obj,dataProp)
            ret=false;
            try
                ret=~strcmp(obj.m_cdefinition.owner.ID,dataProp.DataSource);
            catch me

                if~strcmp(me.identifier,'MATLAB:noSuchMethodOrField')
                    rethrow(me)
                end
            end
        end
        function ret=isCopyable(~,dataProp,disabled)
            ret=false;
            if isa(dataProp,'coderdictionary.data.StorageClass')||...
                isa(dataProp,'coderdictionary.data.MemorySection')||...
                isa(dataProp,'coderdictionary.data.FunctionClass')
                if disabled
                    isBuiltin=false;
                    try
                        isBuiltin=dataProp.isBuiltin;
                    catch
                    end




                    if isBuiltin
                        ret=true;
                    end
                else
                    ret=true;
                end
            elseif isa(dataProp,'coderdicitonary.data.LegacyStorageClass')||...
                isa(dataProp,'coderdictionary.data.LegacyMemorySection')
                ret=false;
            else
                ret=true;
            end
        end
        function autoSetSelectedPlatform(obj)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            softwarePlatforms=hlp.getSoftwarePlatforms(obj.m_cdefinition);
            platformTypes={softwarePlatforms.PlatformType};


            if~ismember(obj.m_selectedPlatformType,platformTypes)
                if isempty(softwarePlatforms)
                    obj.m_selectedPlatformType='';
                else
                    obj.m_selectedPlatformType=softwarePlatforms(1).PlatformType;
                end
            end
            obj.numOfPlatforms=length(platformTypes);
        end
        function status=handleBrowseFileChanged(obj,data)
            status=0;
            errMsg='';
            [folder,file,ext]=fileparts(data.value);
            if~strcmp(ext,'.sldd')
                if~isempty(file)
                    files=[file,'.sldd'];
                else
                    files=file;
                end
            else
                files=[file,ext];
            end
            selectedFullFile=fullfile(folder,files);
            if isempty(file)||~isvarname(file)
                errMsg=message('SimulinkCoderApp:sdp:InvalidFileName',file).getString;
            elseif~isempty(folder)&&~exist(folder,'dir')
                errMsg=message('SimulinkCoderApp:sdp:FolderNotExist',folder).getString;
            elseif strcmp(data.action,'openFile')&&~exist(selectedFullFile,'file')
                errMsg=message('SimulinkCoderApp:sdp:FileNotExist',selectedFullFile).getString;
            else
                try
                    obj.handleBrowseFile(data.property,folder,files);
                catch me
                    errMsg=me.message;
                end
            end
            if~isempty(errMsg)
                msg.messageID='browseFileError';
                msg.errorMsg=errMsg;
                msg.folder=folder;
                msg.clientID=obj.ClientID;
                msg.property=data.property;
                obj.publish(msg);
                status=-1;
            end
        end
        function handleBrowseFile(obj,property,folder,files)
            selectedFullFile=fullfile(folder,files);
            coderDictionaryExist=false;
            if exist(selectedFullFile,'file')
                coderDictionaryExist=coder.dictionary.exist(selectedFullFile);
            end
            msg.messageID='browseFileResult';
            msg.file=files;
            msg.folder=folder;
            msg.fullpath=fullfile(folder,files);
            msg.clientID=obj.ClientID;
            msg.coderDictionaryExist=coderDictionaryExist;
            msg.property=property;
            obj.publish(msg);
        end
    end
    methods(Static=true,Hidden=true)
        function ret=translate(label)
            ret=label;
            if ismember(':',label)
                ret=message(label).getString;
            end
        end
    end
end


function loc_loadViewModel(obj)

    if isempty(obj.layoutModel)
        text=fileread(fullfile(matlabroot,'toolbox','coder',...
        'simulinkcoder_app','ui','+simulinkcoder',...
        '+internal','+app','viewmodel','SDP_layout.json'));
        obj.layoutModel=jsondecode(text);
        text=fileread(fullfile(matlabroot,'toolbox','coder',...
        'simulinkcoder_app','ui','+simulinkcoder',...
        '+internal','+app','viewmodel','SDP_navigation.json'));
        obj.fcNavigationModel=jsondecode(text);
        text=fileread(fullfile(matlabroot,'toolbox','coder',...
        'simulinkcoder_app','ui','+simulinkcoder',...
        '+internal','+app','viewmodel',obj.NativePlatformNavFileName()));
        obj.ncNavigationModel=jsondecode(text);
        text=fileread(fullfile(matlabroot,'toolbox','coder',...
        'simulinkcoder_app','ui','+simulinkcoder',...
        '+internal','+app','viewmodel','SDP_center.json'));
        obj.centerModel=jsondecode(text);
        text=fileread(fullfile(matlabroot,'toolbox','coder',...
        'simulinkcoder_app','ui','+simulinkcoder',...
        '+internal','+app','viewmodel','SDP_pi.json'));
        obj.propertyInspectorModel=jsondecode(text);
    end
end
function msg=loc_getDataDefaults(obj)
    function[scValue,scOptions,msValue,msOptions]=getDataDefaultProperty(obj,elemName)
        sc=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForElement(obj.m_cdefinition,elemName,'StorageClass');
        emptySC=simulinkcoder.internal.app.DefaultMappingViewSource.getUnspecifiedStorageClass;
        emptyMS=simulinkcoder.internal.app.DefaultMappingViewSource.getUnspecifiedMemorySection;
        if isempty(sc)||isempty(sc.getCoderDataEntry.owner)
            scValue=emptySC.Label;
        else
            scName=sc.getProperty('DisplayName');
            scValue=scName;
        end

        scsName=simulinkcoder.internal.app.getAllowedCoderDataForModelElement(obj.ddConn,'StorageClass',elemName);
        scOptions=[emptySC.Label,scsName];


        ms=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForElement(obj.m_cdefinition,elemName,'MemorySection');
        if isempty(ms)||isempty(ms.getCoderDataEntry.owner)
            msValue=emptyMS.Label;
        else
            msName=ms.getProperty('DisplayName');
            msValue=msName;
        end
        mss=coder.internal.CoderDataStaticAPI.getAllowableCoderDataForElement(obj.m_cdefinition,elemName,'MemorySection');
        mssName={};
        if~isempty(mss)
            mssName=coder.internal.CoderDataStaticAPI.getDisplayName(obj.m_cdefinition,mss);
            if~iscell(mssName)
                mssName={mssName};
            end
        end
        msOptions=[emptyMS.Label;mssName];
    end

    modelElements=coder.internal.CoderDataStaticAPI.getDataCategories;
    dataDefaults=struct('Name',modelElements);
    [dataDefaults(:).label]=deal('');
    [dataDefaults(:).StorageClass]=deal('');
    [dataDefaults(:).MemorySection]=deal('');
    for i=1:length(modelElements)
        elemName=dataDefaults(i).Name;
        [scValue,scOptions,msValue,msOptions]=getDataDefaultProperty(obj,elemName);
        dataDefaults(i).label=message(['coderdictionary:mapping:',modelElements{i}]).getString;
        dataDefaults(i).instSpValues=coder.internal.CoderDataStaticAPI.getDataDefaultInstanceSpecificProperties(obj.m_cdefinition,elemName);
        dataDefaults(i).StorageClass=scValue;
        dataDefaults(i).MemorySection=msValue;

        dataDefaults(i).allowedStorageClass=struct('value',scOptions,'label',scOptions);

        dataDefaults(i).allowedMemorySection=struct('value',msOptions,'label',msOptions);
        dataDefaults(i).UUID=elemName;
        dataDefaults(i).disabled=false;
        dataDefaults(i).copyable=false;
        if isfield(dataDefaults(i),'instSpValues')
            instSpValues=dataDefaults(i).instSpValues;
        else
            instSpValues='';
        end
        hasMemorySection=false;
        if~isempty(instSpValues)
            instSpValueNames={instSpValues.Name};
            memorySection=instSpValueNames(contains(instSpValueNames,'MemorySection'));
            if~isempty(memorySection)
                hasMemorySection=true;
            end
        end
        if~hasMemorySection


            emptySC=simulinkcoder.internal.app.DefaultMappingViewSource.getUnspecifiedStorageClass;
            if strcmp(scValue,emptySC.Value)||isempty(scValue)
                hasMemorySection=true;
            end
        end
        dataDefaults(i).hasMemorySection=hasMemorySection;
    end
    msg=dataDefaults;
end

function msg=loc_getFunctionDefaults(obj)
    function[fcValue,fcOptions,msValue,msOptions]=getFunctionDefaultProperty(obj,elemName)
        fc=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForFunction(obj.m_cdefinition,elemName,'FunctionClass');
        emptyFC=simulinkcoder.internal.app.DefaultMappingViewSource.getUnspecifiedFunctionClass;
        emptyMS=simulinkcoder.internal.app.DefaultMappingViewSource.getUnspecifiedMemorySection;
        if isempty(fc)||isempty(fc.getCoderDataEntry.owner)
            fcValue=emptyFC.Label;
        else
            fcName=fc.getProperty('DisplayName');
            fcValue=fcName;
        end
        fcs=coder.internal.CoderDataStaticAPI.get(obj.m_cdefinition,'FunctionClass');
        fcsName={};
        if~isempty(fcs)
            fcsName=coder.internal.CoderDataStaticAPI.getDisplayName(obj.m_cdefinition,fcs);
            if~iscell(fcsName)
                fcsName={fcsName};
            end
        end
        fcOptions=[emptyFC.Label;fcsName];

        ms=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForFunction(obj.m_cdefinition,elemName,'MemorySection');
        if isempty(ms)||isempty(ms.getCoderDataEntry.owner)
            msValue=emptyMS.Label;
        else
            msName=ms.getProperty('DisplayName');
            msValue=msName;
        end
        mss=coder.internal.CoderDataStaticAPI.getAllowableCoderDataForFunction(obj.m_cdefinition,elemName,'MemorySection');
        mssName=coder.internal.CoderDataStaticAPI.getDisplayName(obj.m_cdefinition,mss);
        if~iscell(mssName)
            mssName={mssName};
        end
        msOptions=[emptyMS.Label;mssName];
    end

    functionElements=coder.internal.CoderDataStaticAPI.getFunctionCategories;
    functionDefaults=struct('Name',functionElements);
    [functionDefaults(:).label]=deal('');
    [functionDefaults(:).MemorySection]=deal('');
    emptyFC=simulinkcoder.internal.app.DefaultMappingViewSource.getUnspecifiedFunctionClass;
    for i=1:length(functionElements)
        elemName=functionDefaults(i).Name;
        [fcValue,fcOptions,msValue,msOptions]=getFunctionDefaultProperty(obj,elemName);
        functionDefaults(i).label=message(['coderdictionary:mapping:',functionElements{i}]).getString;
        functionDefaults(i).allowedFunctionClass=struct('value',fcOptions,'label',fcOptions);
        functionDefaults(i).FunctionClass=fcValue;
        functionDefaults(i).allowedMemorySection=struct('value',msOptions,'label',msOptions);
        functionDefaults(i).MemorySection=msValue;
        functionDefaults(i).UUID=elemName;
        functionDefaults(i).disabled=false;
        hasMemorySection=false;
        if strcmp(fcValue,emptyFC.Value)||isempty(fcValue)
            hasMemorySection=true;
        end
        functionDefaults(i).hasMemorySection=hasMemorySection;
    end
    msg=functionDefaults;
end
function[pC,pcRef]=loc_getPlatform(obj,platformType)
    if strcmp(platformType,'ServiceInterfaceConfiguration')
        if obj.m_cdefinition.owner.SoftwarePlatforms.Size==0
            pC=[];
            pcRef=[];
        else
            pC=obj.m_cdefinition.owner.SoftwarePlatforms(1);
            pcRef=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeForContainer(obj.m_cdefinition.owner,'FunctionPlatform');
            pcRef=pcRef(1);
        end
    else
        pC=obj.m_cdefinition;
        pcRef=[];
    end
end
function out=loc_createText(name,value,id,parent)
    if(nargin<4)
        parent='';
    end
    out=struct('Name',name,'Value',struct('value',value,...
    'widgetType','text',...
    'prop',id,...
    'id',id,...
    'parent',parent,...
    'group',''));
end
function out=loc_createTextBox(name,prop,value,id,parent,group)
    if(nargin<6)
        group='';
    end
    if(nargin<5)
        parent='';
    end

    if isempty(group)
        group=parent;
    end

    out=struct('Name',name,'Value',struct('value',value,...
    'widgetType','textbox',...
    'prop',prop,...
    'id',id,...
    'parent',parent,...
    'group',group));
end
function out=loc_createOptionList(name,prop,value,allowedValues,id,parent,group)
    if(nargin<7)
        group='';
    end
    if(nargin<6)
        parent='';
    end

    if isempty(group)
        group=parent;
    end

    out=struct('Name',name,...
    'Value',struct('value',value,...
    'widgetType','optionList','prop',prop,'allowedValues','',...
    'id',id,...
    'parent',parent,...
    'group',group));
    out.Value.allowedValues=allowedValues;
end
function rowWidget=loc_createRowWidget(obj,row,rowData)
    id=row.id;
    if~isfield(row,'parent')
        parent='';
    else
        parent=row.parent;
    end
    switch row.widgetType
    case 'text'
        rowWidget=loc_createText(obj.translate(row.label),'',id,parent);
    case 'textbox'
        rowWidget=loc_createTextBox(obj.translate(row.label),row.prop,rowData.(row.prop),id,parent);
    case 'optionList'
        if strcmp(row.prop,'Language')
            value='C';
        else
            value=rowData.(row.prop);
            switch class(value)
            case 'coderdictionary.softwareplatform.DataCommunicationMethodEnum'
                switch value
                case coderdictionary.softwareplatform.DataCommunicationMethodEnum.DuringExecution
                    value="DuringExecution";
                case coderdictionary.softwareplatform.DataCommunicationMethodEnum.OutsideExecution
                    value="OutsideExecution";
                case coderdictionary.softwareplatform.DataCommunicationMethodEnum.DirectAccess
                    value="DirectAccess";
                end
            case{'coderdictionary.data.AbstractStorageClass',...
                'coderdictionary.data.StorageClass',...
                'coderdictionary.data.LegacyStorageClass'}
                scs=coderdictionary.data.SlCoderDataClient.getAllCoderDataForModelElementTypeForContainer(obj.m_cdefinition.owner,'Inports','StorageClass','IndividualLevel');
                row.allowedValues={};
                for i=1:length(scs)
                    row.allowedValues{end+1}=struct('value',scs(i).getProperty('DisplayName'),'label',scs(i).getProperty('DisplayName'));
                end
                if isempty(value)
                    value='';
                else
                    value=value.DisplayName;
                end
            end
        end
        rowWidget=loc_createOptionList(obj.translate(row.label),row.prop,value,row.allowedValues,id,parent);
    end
    if isfield(row,'action')
        rowWidget.Value.action=row.action;
    end
end
function[numRow,branches]=loc_getNumOfRows(obj,table,pC,branches)
    numRow=length(table.children);
    for i=1:length(table.children)
        if iscell(table.children)
            row=table.children{i};
        else
            row=table.children(i);
        end

        dataValue=loc_getDataProp(obj,pC,row.dataProp);

        if~strcmp(row.nodeType,'sequence_leaf')
            branches{end+1}=row;%#ok<*AGROW>
        end
        if strcmp(row.nodeType,'sequence')
            numOfChildRow=length(row.children)+1;
            if isa(dataValue,'mf.zero.Sequence')
                dataValueSize=dataValue.Size;
            else
                dataValueSize=1;
            end
            numRow=numRow+dataValueSize*numOfChildRow;
        elseif isfield(row,'children')&&~isempty(row.children)
            [n,branches]=loc_getNumOfRows(obj,row,pC,branches);
            numRow=numRow+n;
        end
    end
end
function dataValue=loc_getDataProp(obj,pC,dataProp)
    isNativePlatform=strcmp(obj.m_selectedPlatformType,'DataInterfaceConfiguration');
    if strcmp(dataProp,'sdp')
        dataValue=pC;
    elseif strcmp(dataProp,'Memory.DataMemorySections')



        if isa(obj,'simulinkcoder.internal.app.SDPModelDictionaryViewSource')&&isNativePlatform
            refs=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataType(obj.ModelHandle,'MemorySection');
            dataValue={};
            for i=1:length(refs)
                if~refs(i).isEmpty
                    dataValue{end+1}=refs(i).getCoderDataEntry;
                end
            end
        else
            dataValue=coder.internal.CoderDataStaticAPI.get(obj.m_cdefinition,'MemorySection');
        end
    elseif strcmp(dataProp,'Memory.StorageClasses')
        if isa(obj,'simulinkcoder.internal.app.SDPModelDictionaryViewSource')
            refs=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataType(obj.ModelHandle,'StorageClass');
            dataValue={};
            for i=1:length(refs)
                if~refs(i).isEmpty
                    dataValue{end+1}=refs(i).getCoderDataEntry;
                end
            end
        else
            dataValue=coder.internal.CoderDataStaticAPI.get(obj.m_cdefinition,'StorageClass');
        end
    elseif strcmp(dataProp,'FunctionClass')
        if isa(obj,'simulinkcoder.internal.app.SDPModelDictionaryViewSource')
            refs=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataType(obj.ModelHandle,'FunctionClass');
            dataValue={};
            for i=1:length(refs)
                if~refs(i).isEmpty
                    dataValue{end+1}=refs(i).getCoderDataEntry;
                end
            end
        else
            dataValue=coder.internal.CoderDataStaticAPI.get(obj.m_cdefinition,'FunctionClass');
        end
    else
        sdp=pC;

        if isempty(dataProp)
            dataValue=pC;
        else
            propStr=strsplit(dataProp,'.');
            dataValue=sdp.(propStr{1});
            for dd=2:length(propStr)
                dataValue=dataValue.(propStr{dd});
            end
        end
    end
end
function loc_deleteFunctionComponent(obj)
    obj.m_cdefinition.owner.SoftwarePlatforms.clear;
end
function loc_changeConfiguration(obj,type)


    if~isequal(obj.m_selectedPlatformType,type)
        coder.dictionary.internal.removeCoderDictionary(obj.m_source);
        if isequal(obj.m_selectedPlatformType,'DataInterfaceConfiguration')
            coder.dictionary.create(obj.m_source,'ServiceInterface');
            obj.m_selectedPlatformType='ServiceInterfaceConfiguration';
        else
            coder.dictionary.create(obj.m_source,'DataInterface');
            obj.m_selectedPlatformType='DataInterfaceConfiguration';
        end
    end
end
function ret=loc_hasFunctionPlatform(obj)
    [~,pcRef]=loc_getPlatform(obj,'ServiceInterfaceConfiguration');
    if isempty(pcRef)
        ret=false;
    else
        ret=true;
    end
end
function msg=loc_createMessageData(data,ClientID)
    msg.clientID=ClientID;
    msg.elementId=data.id;
    msg.property=data.dataProp;
    msg.widgetType=data.widgetType;
    msg.value=data.value;
end
function ret=isPlatformOwnerApplicationPlatform(SC)
    ret=false;
    if isa(SC,'coderdictionary.data.StorageClass')
        po=SC.getPlatformOwner;
        if isa(po,'coderdictionary.data.C_Definitions')
            ret=true;
        end
    end
end



function ret=loc_isPropertyEmpty(validateValue)
    ret=false;
    switch class(validateValue)
    case{'coderdictionary.data.AbstractStorageClass',...
        'coderdictionary.data.StorageClass',...
        'coderdictionary.data.LegacyStorageClass',...
        'coderdictionary.data.AbstractMemorySection',...
        'coderdictionary.data.MemorySection',...
'coderdictionary.data.LegacyMemorySection'
        }
        if isempty(validateValue)||isempty(validateValue.UUID)
            ret=true;
        end
    otherwise
        ret=isempty(validateValue);
    end
end


function[canBeDeleted,usageInfo]=loc_canDataBeDeleted(platform,coderDataType,data)
    canBeDeleted=true;
    usageInfo=[];
    if isa(platform,'coderdictionary.softwareplatform.FunctionPlatform')
        if strcmp(coderDataType,'StorageClass')
            relatedServices={'ParameterTuningInterface',...
            'ParameterArgumentTuningInterface',...
            'MeasurementInterface'};
            property='StorageClass';
        elseif strcmp(coderDataType,'MemorySection')
            relatedServices={'StorageClass'};
            property='MemorySection';
        elseif strcmp(coderDataType,'FunctionMemorySection')
            relatedServices={'IRTFunction',...
            'PeriodicAperiodicFunction',...
            'SubcomponentEntryFunction',...
            'SharedUtilityFunction'};
            property='MemorySection';
        else
            return;
        end
        inputUUID=data.UUID;
        for ri=1:length(relatedServices)
            rss=coder.internal.CoderDataStaticAPI.get(platform,relatedServices{ri});
            for rsi=1:length(rss)
                rs=rss(rsi);
                if~isempty(rs.(property))&&strcmp(rs.(property).UUID,inputUUID)
                    canBeDeleted=false;
                    usageInfo=struct('type',relatedServices{ri},'name',rs.Name);
                    break;
                end
            end
            if~canBeDeleted
                break;
            end
        end
    end
end

function loc_requestDeleteConfirmation(obj,data,usageInfo)
    newMsg.origData=data;
    newMsg.clientID=obj.ClientID;
    newMsg.messageID='requestDeleteConfirmation';
    newMsg.titleMessage=message('SimulinkCoderApp:sdp:DeleteCoderDataConfirmationDlgTitle').getString;
    newMsg.message=message('SimulinkCoderApp:sdp:DeleteConfirmation',data.value.data.Name,usageInfo.name).getString;
    obj.publish(newMsg);
end

function loc_checkSTF(value)
    cs=Simulink.ConfigSet;
    cs.set_param('SystemTargetFile',value);
    if~strcmp(cs.get_param('IsERTTarget'),'on')
        DAStudio.error('SimulinkCoderApp:sdp:SystemTargetFileNotERTDerived')
    end
end


