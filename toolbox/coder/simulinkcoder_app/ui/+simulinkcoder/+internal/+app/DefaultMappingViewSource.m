



classdef DefaultMappingViewSource<simulinkcoder.internal.app.DataDictionaryViewSource
    properties
        SubScriptions={};
ClientID
Channel
defaultCache
    end
    properties(Access=private)
        pkgSelectorDlg=[]
m_dd
m_cdefinition
    end
    methods
        function obj=DefaultMappingViewSource(ddName,isAttachedToModel,modelHandle)
            obj=obj@simulinkcoder.internal.app.DataDictionaryViewSource(ddName,isAttachedToModel,modelHandle);
            if~coder.internal.CoderDataStaticAPI.isInitialized(ddName)
                coder.internal.CoderDataStaticAPI.initializeDictionary(ddName);
            end
            obj.m_dd=Simulink.dd.open(obj.DataDictionaryFileName);
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            cdict=hlp.openDD(obj.DataDictionaryFileName);
            obj.m_cdefinition=cdict;
            coderdictionary.data.api.startChangeTracking(cdict.owner);
        end
        function onSourceBeingDestroyed(obj,~,~,~)
            onSourceBeingDestroyed@simulinkcoder.internal.app.ViewSourceBase(obj);
            obj.m_dd.close;
            obj.ddConn.close;
            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.DataDictionaryFileName);
        end
        function receive(obj,msg)
            try
                obj.handleMessage(msg);
            catch me
                obj.handleError(me);
            end
        end
        function handleMessage(obj,msg)
            if~isvalid(obj)
                return;
            end
            if isfield(msg,'clientID')
                if(ischar(msg.clientID)&&~strcmp(msg.clientID,obj.ClientID))||...
                    (isnumeric(msg.clientID)&&msg.clientID~=obj.ClientID)
                    return;
                end
            end
            if isfield(msg,'Type')&&strcmp(msg.Type,'command')
                switch(msg.Value)
                case 'defaultMappingUIReady'
                    obj.handleReadyMessage();
                case{'okDialog','applyDialog'}
                    try
                        hlp=coder.internal.CoderDataStaticAPI.getHelper();
                        dd=obj.m_cdefinition;
                        txn=hlp.beginTxn(dd);
                        obj.handleApplyMessage();
                        hlp.commitTxn(txn);
                    catch me
                        if~isempty(txn)
                            hlp.rollbackTxn(txn);
                        end
                        rethrow(me);
                    end

                    if strcmp(msg.Value,'okDialog')
                        simulinkcoder.internal.app.DefaultMappingViewSource.closeCallBack(obj);
                    end
                case 'cancelDialog'
                    simulinkcoder.internal.app.DefaultMappingViewSource.closeCallBack(obj);
                case 'helpDialog'
                    helpview(fullfile(docroot,'ecoder','helptargets.map'),'ecoder_config_default_mapping');
                end
            else
                switch msg.messageID
                case{'requestRowInfo_dataDefaultMapping',...
                    'requestRowInfo_functionDefaultMapping'}
                    obj.handleRequestRowInfoMessage(msg);
                case 'updateCache_defaultMapping'
                    obj.handleUpdateCacheMessage(msg.rowInfo);
                case{'updatePropertyFromPI_dataDefaultMapping',...
                    'updatePropertyFromPI_functionDefaultMapping'}
                    obj.handleUpdateCacheFromPIMessage(msg);
                case 'launchPkgSelectorDlg_defaultMapping'
                    obj.handleLaunchPkgSelector;
                end
            end
        end
        function refreshUI(obj)
            obj.handleReadyMessage;
        end
        function removeListener(obj)

        end
        function addListener(obj)

        end
        function handleRequestRowInfoMessage(obj,msg)
            msg.clientID=obj.ClientID;
            elemName=msg.data.name;
            if strcmp(msg.data.storeHandler,'dataDefaultsTableStore')
                msg.messageID='responseRowInfo_dataDefaultMapping';
                cache=obj.defaultCache.dataDefaults.(elemName);
                scValue=cache.StorageClass;
                msValue=cache.MemorySection;
                scOptions=cache.allowableStorageClasses;
                msOptions=cache.allowableMemorySections;
                instSpValues=cache.instSpValues;
                scs=struct('id',scOptions,'label',scOptions);
                mss=struct('id',msOptions,'label',msOptions);
                prop=struct('prompt',{DAStudio.message('coderdictionary:mapping:StorageClassColumnName')},...
                'field',{'StorageClass'},...
                'value',{scValue},...
                'renderType',{'optionlist'},...
                'singleline',{true},...
                'invalidMessage',{''},...
                'additionalInfo',{jsonencode(scs)});
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
                if hasMemorySection
                    prop(end+1)=struct('prompt',{'Memory Section'},...
                    'field',{'MemorySection'},...
                    'value',{msValue},...
                    'renderType',{'optionlist'},...
                    'singleline',{true},...
                    'invalidMessage',{''},...
                    'additionalInfo',{jsonencode(mss)});
                end
                if~isempty(instSpValues)
                    for i=1:length(instSpValues)
                        if strcmp(instSpValues(i).Type,'string')
                            instSpValues(i).Type='textbox';%#ok<*AGROW>
                        end
                        if strcmp(instSpValues(i).Type,'enum')
                            instSpValues(i).Type='optionlist';
                        end
                        if~isempty(instSpValues(i).AllowedValues)
                            if iscell(instSpValues(i).AllowedValues)
                                allowedValues=cell(1,length(instSpValues(i).AllowedValues));
                                for j=1:length(instSpValues(i).AllowedValues)
                                    allowedValues{j}.id=instSpValues(i).AllowedValues{j};
                                    allowedValues{j}.label=instSpValues(i).AllowedValues{j};
                                end
                                instSpValues(i).AllowedValues=allowedValues;
                            end
                            instSpValues(i).AllowedValues=jsonencode(instSpValues(i).AllowedValues);
                        end

                        instSpValues(i).singleline=true;

                        instSpValues(i).invalidMessage='';
                    end

                    prop=[prop,struct('prompt',{instSpValues.Name},...
                    'field',{instSpValues.Name},...
                    'value',{instSpValues.Value},...
                    'renderType',{instSpValues.Type},...
                    'singleline',{instSpValues.singleline},...
                    'invalidMessage',{instSpValues.invalidMessage},...
                    'additionalInfo',{instSpValues.AllowedValues})];
                end
            else
                msg.messageID='responseRowInfo_functionDefaultMapping';
                cache=obj.defaultCache.functionDefaults.(elemName);
                fcValue=cache.FunctionClass;
                fcOptions=cache.allowableFunctionClasses;
                msValue=cache.MemorySection;
                msOptions=cache.allowableMemorySections;
                fcs=struct('id',fcOptions,'label',fcOptions);
                mss=struct('id',msOptions,'label',msOptions);
                hasMemorySection=false;


                emptyFC=simulinkcoder.internal.app.DefaultMappingViewSource.getUnspecifiedFunctionClass;
                if strcmp(fcValue,emptyFC.Value)||isempty(fcValue)
                    hasMemorySection=true;
                end
                if hasMemorySection
                    prop=struct('prompt',{DAStudio.message('coderdictionary:mapping:FunctionClassColumnName'),...
                    DAStudio.message('coderdictionary:mapping:MemorySectionColumnName')},...
                    'field',{'FunctionClass','MemorySection'},...
                    'value',{fcValue,msValue},...
                    'renderType',{'optionlist','optionlist'},...
                    'singleline',{true,true},...
                    'invalidMessage',{'',''},...
                    'additionalInfo',{jsonencode(fcs),jsonencode(mss)});
                else
                    prop=struct('prompt',{DAStudio.message('coderdictionary:mapping:FunctionClassColumnName')},...
                    'field',{'FunctionClass'},...
                    'value',{fcValue},...
                    'renderType',{'optionlist'},...
                    'singleline',{true},...
                    'invalidMessage',{''},...
                    'additionalInfo',{jsonencode(fcs)});
                end
            end

            if length(prop)==1
                prop={prop};
            end
            msg.data=prop;
            message.publish(obj.Channel,msg);
        end
        function handleReadyMessage(obj)
            msg.messageID='responseReady_defaultMapping';
            msg.clientID=obj.ClientID;
            data.packages=coder.internal.CoderDataStaticAPI.getPackageList(false);
            data.selectedPackage=coder.internal.CoderDataStaticAPI.getCurrentNonBuiltinPackages(obj.m_cdefinition);

            modelElements=coder.internal.CoderDataStaticAPI.getDataCategories;
            dataDefaults=struct('modelElement',modelElements);
            [dataDefaults(:).Label]=deal('');
            [dataDefaults(:).StorageClass]=deal('');
            [dataDefaults(:).MemorySection]=deal('');
            [dataDefaults(:).FunctionClass]=deal('');
            for i=1:length(modelElements)
                elemName=dataDefaults(i).modelElement;
                [scValue,scOptions,msValue,msOptions]=obj.getDataDefaultProperty(elemName);
                dataDefaults(i).Label=message(['coderdictionary:mapping:',modelElements{i}]).getString;
                dataDefaults(i).instSpValues=coder.internal.CoderDataStaticAPI.getDataDefaultInstanceSpecificProperties(obj.m_cdefinition,elemName);
                dataDefaults(i).StorageClass=scValue;
                dataDefaults(i).MemorySection=msValue;
                dataDefaults(i).allowableStorageClasses=scOptions;
                dataDefaults(i).allowableMemorySections=msOptions;
            end
            data.dataDefaults=dataDefaults;

            functionElements=coder.internal.CoderDataStaticAPI.getFunctionCategories;
            functionDefaults=struct('functionElement',functionElements);
            [functionDefaults(:).Label]=deal('');
            [functionDefaults(:).MemorySection]=deal('');
            for i=1:length(functionElements)
                elemName=functionDefaults(i).functionElement;
                [fcValue,fcOptions,msValue,msOptions]=obj.getFunctionDefaultProperty(elemName);
                functionDefaults(i).Label=message(['coderdictionary:mapping:',functionElements{i}]).getString;
                functionDefaults(i).allowableFunctionClasses=fcOptions;
                functionDefaults(i).FunctionClass=fcValue;
                functionDefaults(i).allowableMemorySections=msOptions;
                functionDefaults(i).MemorySection=msValue;
            end
            data.functionDefaults=functionDefaults;

            msg.data=data;
            msg.dialogTitle=message('SimulinkCoderApp:ui:CoderAppTitle',obj.DataDictionaryFileName).getString;
            message.publish(obj.Channel,msg);
            for i=1:length(dataDefaults)
                obj.defaultCache.dataDefaults.(dataDefaults(i).modelElement)=dataDefaults(i);
            end
            for i=1:length(functionDefaults)
                obj.defaultCache.functionDefaults.(functionDefaults(i).functionElement)=functionDefaults(i);
            end
        end
        function handleUpdateCacheFromPIMessage(obj,msg)
            storeId=msg.data.storeHandler;
            elementId=msg.data.name;
            property=msg.data.property;
            value=msg.data.value;
            if strcmp(storeId,'dataDefaultsTableStore')
                isMemorySection=strcmp(property,'MemorySection');
                isStorageClass=strcmp(property,'StorageClass');
                if isMemorySection||isStorageClass


                    rowInfo=struct('storeId',storeId,...
                    'elementId',elementId,...
                    'field',property,...
                    'newValue',value);
                    obj.handleUpdateCacheMessage(rowInfo);
                else

                    instSpValues=obj.defaultCache.dataDefaults.(elementId).instSpValues;
                    for i=1:length(instSpValues)
                        if strcmp(property,instSpValues(i).Name)
                            instSpValues(i).Value=value;
                            break;
                        end
                    end

                    sc=obj.defaultCache.dataDefaults.(elementId).StorageClass;
                    scObj=coder.internal.CoderDataStaticAPI.getByName(obj.m_cdefinition,'StorageClass',sc);
                    if isa(scObj,'coderdictionary.data.LegacyStorageClass')
                        try
                            coder.internal.CoderDataStaticAPI.validateInstanceSpecificProperty(...
                            obj.m_cdefinition,elementId,scObj.Package,scObj.ClassName,property,value,instSpValues);
                        catch me
                            err=me.message();
                            obj.sendUpdateFailureMsg(storeId,elementId,property,value,err);
                            return;
                        end
                    end
                    obj.defaultCache.dataDefaults.(elementId).instSpValues=instSpValues;
                end
                newRowInfo=obj.defaultCache.dataDefaults.(elementId);
                obj.sendUpdateSuccessfulMsg(storeId,newRowInfo);
            elseif strcmp(storeId,'functionDefaultsTableStore')
                rowInfo=struct('storeId',storeId,...
                'elementId',elementId,...
                'field',property,...
                'newValue',value);
                obj.handleUpdateCacheMessage(rowInfo);
            end
        end

        function handleUpdateCacheMessage(obj,rowInfo)

            field=rowInfo.field;
            newValue=rowInfo.newValue;
            elementId=rowInfo.elementId;
            storeId=rowInfo.storeId;
            emptyMS=simulinkcoder.internal.app.DefaultMappingViewSource.getUnspecifiedMemorySection;

            if strcmp(storeId,'dataDefaultsTableStore')
                if strcmp(field,'StorageClass')
                    msOptions=coder.internal.CoderDataStaticAPI.getAllowableMemorySectionForElementAndStorageClass(...
                    obj.m_cdefinition,elementId,newValue);
                    msOptionsName=coder.internal.CoderDataStaticAPI.getDisplayName(obj.m_cdefinition,msOptions);
                    if~iscell(msOptionsName)
                        msOptionsName={msOptionsName};
                    end
                    obj.defaultCache.dataDefaults.(elementId).allowableMemorySections=[emptyMS.Label;msOptionsName];
                    obj.defaultCache.dataDefaults.(elementId).instSpValues=coder.internal.CoderDataStaticAPI.getStorageClassInstanceSpecificProperties(obj.m_cdefinition,newValue);
                end
                obj.defaultCache.dataDefaults.(elementId).(field)=newValue;


                newRowInfo=obj.defaultCache.dataDefaults.(elementId);
            elseif strcmp(storeId,'functionDefaultsTableStore')
                obj.defaultCache.functionDefaults.(elementId).(field)=newValue;
                newRowInfo=obj.defaultCache.functionDefaults.(elementId);
            end
            obj.sendUpdateSuccessfulMsg(storeId,newRowInfo);
        end
        function sendUpdateFailureMsg(obj,storeId,elementId,property,value,errMsg)
            msg.messageID='updateFailure_defaultMapping';
            msg.clientID=obj.ClientID;
            msg.storeId=storeId;
            msg.elementId=elementId;
            msg.property=property;
            msg.value=value;
            msg.errMsg=errMsg;
            message.publish(obj.Channel,msg);
        end
        function sendUpdateSuccessfulMsg(obj,storeId,newRowInfo)
            msg.messageID='updateSuccessful_defaultMapping';
            msg.clientID=obj.ClientID;
            msg.storeId=storeId;
            msg.rowInfo=newRowInfo;
            message.publish(obj.Channel,msg);
        end
        function handleApplyMessage(obj)

            modelElements=coder.internal.CoderDataStaticAPI.getDataCategories;
            dataDefaults=obj.defaultCache.dataDefaults;
            functionDefaults=obj.defaultCache.functionDefaults;
            for i=1:length(modelElements)
                elemName=modelElements{i};
                item=dataDefaults.(elemName);
                fields={'StorageClass','MemorySection'};
                for j=1:length(fields)
                    field=fields{j};
                    newValueEntry=item.(field);
                    try
                        coder.internal.CoderDataStaticAPI.setDefaultCoderDataForElement(obj.m_cdefinition,elemName,field,newValueEntry);
                    catch me


                        if~strcmp(me.identifier,'coderdictionary:mapping:DataMemorySectionNotConfigurable')
                            rethrow(me);
                        end
                    end
                end
                coder.internal.CoderDataStaticAPI.setDataDefaultInstanceSpecificProperties(obj.m_cdefinition,elemName,item.instSpValues);
            end

            functionElements=coder.internal.CoderDataStaticAPI.getFunctionCategories;
            for i=1:length(functionElements)
                elemName=functionElements{i};
                fields={'FunctionClass','MemorySection'};
                item=functionDefaults.(elemName);
                for j=1:length(fields)
                    field=fields{j};
                    newValueEntry=item.(field);
                    try
                        coder.internal.CoderDataStaticAPI.setDefaultCoderDataForElement(obj.m_cdefinition,elemName,field,newValueEntry);
                    catch me


                        if~strcmp(me.identifier,'coderdictionary:mapping:FunctionMemorySectionNotConfigurable')
                            rethrow(me);
                        end
                    end
                end
            end
        end
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
            msOptions=[{emptyMS.Label};mssName];
        end
        function handleError(~,e)
            disp(['Error of handling message from dictionary default: ',e.message]);
        end
        function delete(obj)
            obj.unsubscribe;
            if isa(obj.m_dd,'Simulink.data.dictionary')
                obj.m_dd.close;
            end
        end
        function subscribe(obj)
            if~isempty(obj.SubScriptions)
                obj.unsubscribe()
            end
            obj.SubScriptions{end+1}=message.subscribe(obj.Channel,@obj.receive);
        end
        function unsubscribe(obj)
            if(obj.isvalid)
                for i=1:length(obj.SubScriptions)
                    message.unsubscribe(obj.SubScriptions{i});
                end
            end
        end
        function out=CoderDataSourceName(~)
            out='UNKNOWN';
        end
        function onBrowserClose(obj,size)
            onBrowserClose@simulinkcoder.internal.app.DataDictionaryViewSource(obj,size);
            obj.unsubscribe();
        end
    end
    methods(Static=true,Hidden=true)
        function closeCallBack(obj)
            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.DataDictionaryFileName);
        end
        function out=getUnspecifiedStorageClass()
            out.Label=message('coderdictionary:mapping:SimulinkGlobal').getString;
            out.Value='Default';
        end
        function out=getUnspecifiedMemorySection()
            out.Label=message('coderdictionary:mapping:MappingNone').getString;
            out.Value='None';
        end
        function out=getUnspecifiedFunctionClass()
            out.Label=message('coderdictionary:mapping:MappingFunctionDefault').getString;
            out.Value='Default';
        end
    end
end



