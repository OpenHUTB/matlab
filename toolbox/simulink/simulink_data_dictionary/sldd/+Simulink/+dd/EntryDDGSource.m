classdef EntryDDGSource<handle















    properties
UserData
    end
    properties(SetAccess=private)
m_ddConn
m_entryID
m_scope
m_upToDate

m_entryInfo
        m_resolvedEntryInfo;
        m_resolved_mxEntry;
m_entryValueIsMxArray
m_originalDataSource

m_clientCallbacks
m_modifiedInDialog
m_ddModificationListener
        m_children;
        m_conditionCount;
        m_originalVariant;
        m_resolvedView;
        m_hasVariants;
    end
    properties(Constant)
        m_metaDataProperties=...
        {'Name',...
        'DataSource',...
        'Status',...
        'LastModified',...
        'LastModifiedBy',...
        'Variant'}
    end
    methods
        function thisObj=EntryDDGSource(ddConn,entryNameOrID,resolvedView)
            thisObj.UserData.isUpToDate=false;
            thisObj.m_ddConn=ddConn;

            if ischar(entryNameOrID)

                thisObj.m_entryID=thisObj.m_ddConn.getEntryID(entryNameOrID);



                thisObj.m_entryInfo.Name=entryNameOrID;
            else
                thisObj.m_entryID=entryNameOrID;
                thisObj.m_entryInfo.Name='';
            end
            assert(isnumeric(thisObj.m_entryID));
            thisObj.m_scope=thisObj.m_ddConn.getEntryParentName(thisObj.m_entryID);
            thisObj.m_upToDate=false;
            thisObj.m_originalDataSource='';
            thisObj.m_originalVariant='';
            thisObj.m_clientCallbacks=[];
            thisObj.m_modifiedInDialog=false;
            thisObj.m_children={};
            thisObj.m_conditionCount=1;
            thisObj.m_resolvedView=resolvedView;
            thisObj.m_hasVariants=false;
            thisObj.m_ddConn.enablePromptBeforeClose;
            thisObj.m_ddModificationListener=event.listener(thisObj.m_ddConn,...
            'DataDictionaryModified',@thisObj.notifyOfDDModification);


        end


        function notifyOfDDModification(thisObj,~,evtData)






            dlgs=DAStudio.ToolRoot.getOpenDialogs(thisObj);
            for i=1:length(dlgs)
                dlg=dlgs(i);
                if~dlg.hasUnappliedChanges
                    if~thisObj.m_modifiedInDialog
                        thisObj.invalidate();
                    end
                    dlg.refresh;
                end
            end

        end

        function used=useCodeGen(thisObj)
            if thisObj.m_ddConn.getIsEntryDerived(thisObj.m_entryID)
                used=false;
            else
                used=true;
            end
        end

        function userData=getUserData(thisObj)
            userData=thisObj.UserData;
        end
        function setUserData(thisObj,userData)
            thisObj.UserData=userData;
        end
        function delete(thisObj)

        end
        function displayLabel=getDisplayLabel(thisObj)
            displayLabel=thisObj.m_entryInfo.Name;
        end
        function entryValue=getForwardedObject(thisObj)
            entryValue=[];
            thisObj.validate;
            if thisObj.m_upToDate
                entryValue=thisObj.m_entryInfo.Value;
            end
        end
        function isValid=isValidProperty(thisObj,propName)
            isValid=false;
            thisObj.validate;
            if thisObj.m_upToDate
                if any(strcmp(propName,Simulink.dd.EntryDDGSource.m_metaDataProperties))

                    isValid=true;
                else
                    if thisObj.m_entryValueIsMxArray
                        isValid=strcmp(propName,'Value')||strcmp(propName,'Dimensions')||strcmp(propName,'Complexity');
                    else
                        try
                            isValid=thisObj.m_entryInfo.Value.isValidProperty(propName);
                        catch
                            isValid=strcmp(propName,'Value')||strcmp(propName,'Dimensions')||strcmp(propName,'Complexity');
                        end
                    end
                end
            end
        end
        function isReadonly=isReadonlyProperty(thisObj,propName)
            isReadonly=true;
            thisObj.validate;
            if thisObj.m_upToDate
                if strcmp(propName,'DataSource')||strcmp(propName,'Variant')
                    isReadonly=false;
                elseif strcmp(propName,'Name')
                    if thisObj.m_entryInfo.Value.isValidProperty(propName)
                        isReadonly=thisObj.m_entryInfo.Value.isReadonlyProperty(propName);
                    else
                        isReadonly=true;
                    end
                elseif any(strcmp(propName,Simulink.dd.EntryDDGSource.m_metaDataProperties))

                    isReadonly=true;
                else
                    if thisObj.m_entryValueIsMxArray
                        isReadonly=strcmp(propName,'DataType')||strcmp(propName,'Dimensions')||strcmp(propName,'Complexity');
                    else
                        isReadonly=thisObj.m_entryInfo.Value.isReadonlyProperty(propName);
                    end
                end
            end
        end
        function propDataType=getPropDataType(thisObj,propName)
            propDataType='';
            thisObj.validate;
            if thisObj.m_upToDate
                if any(strcmp(propName,Simulink.dd.EntryDDGSource.m_metaDataProperties))

                    propDataType='string';
                else
                    if thisObj.m_entryValueIsMxArray
                        propDataType='string';
                    else
                        try
                            propDataType=getPropDataType(thisObj.m_entryInfo.Value,propName);
                        catch
                            propDataType='mxArray';
                        end
                    end
                end
            end
        end
        function allowedValues=getPropAllowedValues(thisObj,propName)
            allowedValues=[];
            if thisObj.m_upToDate&&~thisObj.m_entryValueIsMxArray
                allowedValues=getPropAllowedValues(thisObj.m_entryInfo.Value,propName);
            end
        end
        function setPropValue(thisObj,propName,propValue,context)

            thisObj.validate;
            if thisObj.m_upToDate
                if strcmp(propName,'DataSource')
                    thisObj.m_entryInfo.DataSource=propValue;
                elseif strcmp(propName,'Variant')
                    thisObj.m_entryInfo.Variant=propValue;
                else
                    if slfeature('SLDataDictionaryVariants')>0&&...
                        isa(thisObj.m_entryInfo.Value,'Simulink.dd.DataVariant')
                        thisObj.m_entryInfo.Value.setPropValue(propName,propValue);
                    elseif isa(thisObj.m_entryInfo.Value,'Simulink.VariantControl')



                        vCtrl=thisObj.m_entryInfo.Value;
                        setPropValue(vCtrl,propName,propValue,context);
                        thisObj.m_entryInfo.Value=vCtrl;
                    else



                        propType=thisObj.getPropDataType(propName);
                        if strcmp(propType,'bool')
                            propValue=strcmp(propValue,'1');
                        end




                        if thisObj.m_entryValueIsMxArray
                            assert(strcmp(propName,'Value'));
                            if isempty(context)
                                valueAssignExpr='thisObj.m_entryInfo.Value = eval(propValue);';
                            else
                                valueAssignExpr='thisObj.m_entryInfo.Value = evalin(context, propValue);';
                            end
                        elseif strcmp(propType,'double')


                            valueAssignExpr=['thisObj.m_entryInfo.Value.',propName,' = ',propValue,';'];
                        else
                            valueAssignExpr=['thisObj.m_entryInfo.Value.',propName,' = propValue;'];
                        end
                        eval(valueAssignExpr);
                    end
                end
            end
        end
        function propValue=getPropValue(thisObj,propName)
            propValue=[];
            thisObj.validate;
            if thisObj.m_upToDate
                switch propName
                case 'Name'
                    if thisObj.m_entryInfo.Value.isValidProperty(propName)
                        propValue=thisObj.m_entryInfo.Value.getPropValue(propName);
                    else
                        propValue=thisObj.m_entryInfo.Name;
                    end
                case 'DataSource'
                    propValue=thisObj.m_entryInfo.DataSource;
                case 'Variant'
                    propValue=thisObj.m_entryInfo.Variant;
                case{'Status','LastModified','LastModifiedBy'}

                    assert(false);
                otherwise
                    if thisObj.m_entryValueIsMxArray
                        switch(propName)
                        case 'DataType'
                            propValue=class(thisObj.m_entryInfo.Value);
                        case 'Value'
                            propValue=DAStudio.MxStringConversion.convertToString(...
                            thisObj.m_entryInfo.Value);
                        case 'Dimensions'
                            tempVal=size(thisObj.m_entryInfo.Value);
                            propValue=strcat('[',strcat(num2str(tempVal),']'));
                        case 'Complexity'
                            if(isnumeric(thisObj.m_entryInfo.Value))
                                if(isreal(thisObj.m_entryInfo.Value))
                                    propValue='real';
                                else
                                    propValue='complex';
                                end
                            else
                                propValue='N/A';
                            end
                        otherwise
                            assert(false);
                        end
                    else
                        try
                            propValue=thisObj.m_entryInfo.Value.getPropValue(propName);
                        catch
                            switch(propName)
                            case 'DataType'
                                propValue=class(thisObj.m_entryInfo.Value);
                            case 'Value'
                                propValue=DAStudio.MxStringConversion.convertToString(...
                                thisObj.m_entryInfo.Value);
                            case 'Dimensions'
                                tempVal=size(thisObj.m_entryInfo.Value);
                                propValue=strcat('[',strcat(num2str(tempVal),']'));
                            case 'Complexity'
                                if(isnumeric(thisObj.m_entryInfo.Value))
                                    if(isreal(thisObj.m_entryInfo.Value))
                                        propValue='real';
                                    else
                                        propValue='complex';
                                    end
                                else
                                    propValue='N/A';
                                end
                            otherwise
                                assert(false);
                            end
                        end
                        if islogical(propValue)
                            if propValue
                                propValue='on';
                            else
                                propValue='off';
                            end
                        end
                    end
                end
            end
        end

        function AddVariant(thisObj,dlg)
            newVariant=Simulink.dd.DataVariant(thisObj.m_ddConn.filespec,thisObj.m_entryID,'');
            row=Simulink.DDSpreadsheetRow;

            row.DataSource=thisObj.m_entryInfo.DataSource;
            row.ddEntry=newVariant;

            row.entryID=0;
            row.variantCondition=GetNewCondition(thisObj);
            row.isDirty=true;
            row.entryDDG=thisObj;

            thisObj.m_children{end+1}=row;
            dlg.refreshWidget('v_spreadsheet');
            dlg.enableApplyButton(true);
        end

        function variantCondition=GetNewCondition(thisObj)

            list=thisObj.m_ddConn.getVariants(thisObj.m_entryInfo.Name)';
            variantCondition=['condition==',num2str(thisObj.m_conditionCount)];
            while ismember(variantCondition,list)
                thisObj.m_conditionCount=thisObj.m_conditionCount+1;
                variantCondition=['condition==',num2str(thisObj.m_conditionCount)];
            end
            thisObj.m_conditionCount=thisObj.m_conditionCount+1;
        end

        function childRowChanged(thisObj,rowObj,propName)
            dlgs=DAStudio.ToolRoot.getOpenDialogs(thisObj);
            for i=1:length(dlgs)
                dlg=dlgs(i);
                dlg.refresh;
                dlg.enableApplyButton(true);
            end
        end

        function children=getChildren(thisObj)

            if isa(thisObj.m_entryInfo.Value,'Simulink.dd.DataVariant')
                thisObj.m_children={};
                if~isempty(thisObj.m_entryInfo.Value.m_variantProps)
                    props=fieldnames(thisObj.m_entryInfo.Value.m_variantProps)';
                    for name=props

                        row=Simulink.DDSpreadsheetRow;
                        row.DataSource=thisObj.m_ddConn.filespec;
                        row.entryID=thisObj.m_entryID;
                        row.propertyName=name{1};
                        row.baseEntryID=thisObj.m_entryInfo.Value.m_baseEntryID;
                        row.Variant=thisObj.m_entryInfo.Variant;
                        row.ddEntry=thisObj;
                        row.entryDDG=thisObj;

                        thisObj.m_children{end+1}=row;
                    end
                end
            elseif isempty(thisObj.m_children)

                dd=Simulink.data.dictionary.open(thisObj.m_originalDataSource);
                scope=dd.getSection(thisObj.m_scope);
                entryIDs=scope.getEntryID(thisObj.m_entryInfo.Name);

                ddConn=Simulink.dd.open(thisObj.m_originalDataSource);
                allVariants={};
                for i=1:length(entryIDs)
                    variant=ddConn.getEntryInfo(entryIDs(i));

                    entry=variant.Value;
                    row='';
                    if isa(entry,'Simulink.dd.DataVariant')
                        row=Simulink.DDSpreadsheetRow;
                        row.DataSource=variant.DataSource;
                        row.LastModified=Simulink.dd.private.convertISOTimeToLocal(variant.LastModified);
                        row.LastModifiedBy=variant.LastModifiedBy;
                        row.Status=variant.Status;
                        row.ddEntry=entry;
                        row.entryName=thisObj.m_entryInfo.Name;
                        row.entryScope=thisObj.m_scope;
                        row.variantCondition=variant.Variant;
                        row.entryDDG=thisObj;
                        row.entryID=entryIDs(i);
                    end
                    if~isempty(row)
                        thisObj.m_children{end+1}=row;
                    end
                end
            end
            children=thisObj.m_children;
        end

        function dlgstruct=getDialogSchema(thisObj,~)
            thisObj.validate;
            if thisObj.m_upToDate
                if thisObj.m_entryValueIsMxArray
                    [dlgstruct,thisObj.m_clientCallbacks,thisObj.m_entryInfo.Value]=...
                    slddEntryDDG(thisObj,thisObj.m_entryInfo.Name,...
                    thisObj.m_entryInfo.Value,thisObj.m_entryValueIsMxArray,...
                    thisObj.m_resolved_mxEntry);
                else
                    [dlgstruct,thisObj.m_clientCallbacks,thisObj.m_entryInfo.Value]=...
                    slddEntryDDG(thisObj,thisObj.m_entryInfo.Name,...
                    thisObj.m_entryInfo.Value,thisObj.m_entryValueIsMxArray,...
                    thisObj.m_resolvedEntryInfo.Value);
                end

                if thisObj.m_ddConn.getIsEntryDerived(thisObj.m_entryID)||...
                    thisObj.isOwnedByInterfaceDictionary()
                    dlgstruct.DisableDialog=true;
                end
            else
                messageText.Name='';
                name=thisObj.m_entryInfo.Name;
                if isempty(name)
                    try
                        thisObj.m_entryInfo=thisObj.m_ddConn.getEntryInfo(...
                        thisObj.m_entryID);
                        if isempty(thisObj.m_entryInfo.Name)
                            name=num2str(thisObj.m_entryID);
                        else
                            name=thisObj.m_entryInfo.Name;
                        end
                    catch E
                        messageText.Name=E.message;
                    end
                end
                if isempty(messageText.Name)
                    messageText.Name=DAStudio.message(...
                    'Simulink:dialog:DataDictEntryNotFound',name);
                end
                messageText.Type='text';
                messageText.WordWrap=true;
                messageText.Alignment=6;

                dlgstruct.DialogTitle=thisObj.m_entryInfo.Name;
                dlgstruct.Items={messageText};
                dlgstruct.HelpMethod='helpview';
                dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};
            end
        end

        function[successful,errmsg]=preApply(thisObj,dialog,source)
            successful=true;
            errmsg='';

            if dialog.hasUnappliedChanges
                thisObj.m_modifiedInDialog=true;
            end


            [successful,errmsg]=Simulink.dd.EntryDDGSource.callClientCallback(...
            thisObj.m_clientCallbacks,...
            'PreApplyCallback','PreApplyArgs',dialog,source);
        end
        function close(thisObj,dialog,source)
            if thisObj.m_modifiedInDialog


                [successful,errmsg]=saveEntry(thisObj,dialog,source);
            end

            [~,~]=Simulink.dd.EntryDDGSource.callClientCallback(...
            thisObj.m_clientCallbacks,...
            'CloseCallback','CloseArgs',dialog,source);

            delete(thisObj);
        end
        function[successful,errmsg]=postApply(thisObj,dialog,source)
            successful=true;
            errmsg='';



            [successful,errmsg]=Simulink.dd.EntryDDGSource.callClientCallback(...
            thisObj.m_clientCallbacks,...
            'PostApplyCallback','PostApplyArgs',dialog,source);

            if isvalid(thisObj)
                if thisObj.m_modifiedInDialog
                    [successful,errmsg]=saveEntry(thisObj,dialog,source);
                end
            else
                successful=false;
            end
        end

        function[successful,errmsg]=saveEntry(thisObj,dialog,source)
            successful=true;
            errmsg='';


            thisObj.m_modifiedInDialog=false;

            if slfeature('SLDataDictionaryVariants')>0&&...
                isa(thisObj.m_entryInfo.Value,'Simulink.dd.DataVariant')...
                &&~thisObj.m_entryInfo.Value.m_entryValueIsMxArray
                ddConn=Simulink.dd.open(thisObj.m_entryInfo.Value.m_ddFilespec);
                baseEntryInfo=ddConn.getEntryInfo(...
                thisObj.m_entryInfo.Value.m_baseEntryID);
                thisObj.m_entryInfo.Value.updateVariantProps(baseEntryInfo.Value,...
                thisObj.m_entryInfo.Value.m_baseEntryInfo.Value);
                thisObj.m_entryInfo.Value.m_modifyingInDialog=false;
            end

            try

                if isa(thisObj.m_entryInfo.Value,'Simulink.dd.DAObjectWrapper')

                    thisObj.m_ddConn.setEntry(thisObj.m_entryID,...
                    thisObj.m_entryInfo.Value.m_objectToWrap);
                else
                    thisObj.m_ddConn.setEntry(thisObj.m_entryID,...
                    thisObj.m_entryInfo.Value);
                end


                if~strcmp(thisObj.m_entryInfo.DataSource,...
                    thisObj.m_originalDataSource)
                    thisObj.m_ddConn.setEntryDataSource(...
                    thisObj.m_entryID,thisObj.m_entryInfo.DataSource);
                end









            catch me
                successful=false;
                errmsg=me.message;
            end
            thisObj.m_modifiedInDialog=~successful;
            dialog.enableApplyButton(false);
            needRefresh=thisObj.saveVariants();
            if needRefresh
                thisObj.m_children={};
                dialog.refreshWidget('v_spreadsheet');
            end
        end

        function[successful,errmsg]=postRevert(thisObj,dialog,source)
            successful=true;
            errmsg='';


            [successful,errmsg]=Simulink.dd.EntryDDGSource.callClientCallback(...
            thisObj.m_clientCallbacks,...
            'PostRevertCallback','PostRevertArgs',dialog,source);

            thisObj.m_children={};
            if slfeature('SLDataDictionaryVariants')
                dialog.refreshWidget('v_spreadsheet');
            end
        end

        function retVal=hasPropertyActions(obj,propName,contextObj)

            retVal=false;
            if obj.m_entryValueIsMxArray
                if strcmp(propName,'Value')
                    retVal=true;
                end
            end
        end

        function retVal=getPropertyActions(obj,propName,propValue)

            if obj.m_entryValueIsMxArray
                if strcmp(propName,'Value')
                    retVal.enabled=true;
                    retVal.label=DAStudio.message('modelexplorer:DAS:LaunchVariableEditorToolTip');
                    retVal.visible=true;
                    retVal.command='openEditor';
                end
            end
        end

        function retVal=getPossibleProperties(obj)
            retVal=[];
            fwdObj=obj.getForwardedObject();
            if isobject(fwdObj)&&...
                ~isa(fwdObj,'string')&&...
                ~isa(fwdObj,'half')
                retVal=fwdObj.getPossibleProperties();
            end
        end

        function setEntryValue(obj,newValue)
            obj.m_upToDate=true;
            obj.m_entryInfo.Value=newValue;
        end

        function valid=isValidSourceForEnum(obj)
            valid=true;
        end

    end

    methods(Access=private)
        function validate(thisObj)
            if~thisObj.m_upToDate

                try
                    thisObj.m_entryInfo=thisObj.m_ddConn.getEntryInfo(...
                    thisObj.m_entryID);

                    entryValue=thisObj.m_entryInfo.Value;

                    if Simulink.data.isSupportedEnumObject(entryValue)||...
                        (isa(entryValue,'table'))
                        objectLevel=0;
                    elseif(isa(entryValue,'half'))
                        objectLevel=0;
                    else
                        if isobject(entryValue)&&Simulink.dd.EntryDDGSource.hasMethod(entryValue,'numel')




                            objectLevel=2;
                        else
                            objectLevel=Simulink.data.getScalarObjectLevel(entryValue);
                        end
                    end



                    if(objectLevel>0)&&...
                        (~Simulink.data.isHandleObject(entryValue))&&...
                        (~Simulink.dd.EntryDDGSource.hasMethod(entryValue,'getDialogSchema'))&&...
                        (~isa(entryValue,'Simulink.Bus'))&&...
                        (~isa(entryValue,'Simulink.ConnectionBus'))&&...
                        (~isa(entryValue,'Simulink.ServiceBus'))&&...
                        (~isa(entryValue,'Simulink.NumericType'))&&...
                        (~isa(entryValue,'Simulink.AliasType'))



                        entryValue=Simulink.dd.DAObjectWrapper(entryValue);
                    end
                    thisObj.m_entryInfo.Value=entryValue;
                    thisObj.m_entryValueIsMxArray=objectLevel==0;
                    thisObj.m_originalDataSource=thisObj.m_entryInfo.DataSource;
                    thisObj.m_originalVariant=thisObj.m_entryInfo.Variant;

                    thisObj.m_resolvedEntryInfo=[];
                    thisObj.m_resolvedEntryInfo.Value=[];
                    thisObj.m_resolved_mxEntry=[];

                    if slfeature('SLDataDictionaryVariants')
                        thisObj.m_hasVariants=~isempty(thisObj.m_ddConn.getVariants(thisObj.m_entryInfo.Name));

                        if thisObj.m_hasVariants&&~isa(thisObj.m_entryInfo.Value,'Simulink.dd.DataVariant')
                            if~thisObj.m_entryValueIsMxArray
                                thisObj.m_resolvedEntryInfo=thisObj.m_ddConn.getEntryBoundInfo(...
                                thisObj.m_entryID);
                            else
                                thisObj.m_resolved_mxEntry=Simulink.dd.ResolvedDDGSource(thisObj.m_ddConn,thisObj.m_entryID);
                            end
                        end
                    end


                    thisObj.m_upToDate=true;
                catch me
                    thisObj.m_entryValueIsMxArray=false;
                    thisObj.m_originalDataSource='';
                    thisObj.m_originalVariant='';
                end

                thisObj.m_modifiedInDialog=false;
            end
        end
        function invalidate(thisObj)
            if thisObj.m_upToDate
                thisObj.m_entryInfo.Value=[];
                if~isempty(thisObj.m_resolvedEntryInfo)
                    thisObj.m_resolvedEntryInfo.Value=[];
                end
                if~isempty(thisObj.m_resolved_mxEntry)
                    thisObj.m_resolved_mxEntry=[];
                end
                thisObj.m_upToDate=false;
                thisObj.UserData.isUpToDate=false;
            end
        end
        function needRefresh=saveVariants(thisObj)
            needRefresh=false;
            if slfeature('SLDataDictionaryVariants')
                max=length(thisObj.m_children);

                sleep=false;
                for idx=1:max
                    if thisObj.m_children{idx}.isDirty
                        variantCondition=thisObj.m_children{idx}.VariantCondition;
                        if isequal(thisObj.m_children{idx}.entryID,0)
                            if~sleep
                                sleep=true;
                                ed=DAStudio.EventDispatcher;
                                broadcastEvent(ed,'MESleepEvent');
                                cleanupWake=onCleanup(@()broadcastEvent(ed,'MEWakeEvent'));
                            end
                            dd=Simulink.dd.open(thisObj.m_children{idx}.DataSource);
                            dd.insertEntry(thisObj.m_scope,thisObj.m_entryInfo.Name,thisObj.m_children{idx}.ddEntry,variantCondition);
                        else
                            thisObj.m_ddConn.setEntry(thisObj.m_children{idx}.entryID,thisObj.m_children{idx}.ddEntry);
                            info=thisObj.m_ddConn.getEntryInfo(thisObj.m_children{idx}.entryID);
                            if~isequal(info.Variant,variantCondition)
                                thisObj.m_ddConn.setEntryVariant(thisObj.m_children{idx}.entryID,variantCondition);
                            end
                        end
                    end
                end
                needRefresh=~sleep;
            end
        end

        function tf=isOwnedByInterfaceDictionary(thisObj)
            dd=Simulink.dd.open(thisObj.m_entryInfo.DataSource);
            tf=sl.interface.dict.api.isInterfaceDictionary(dd.filespec);
        end

    end

    methods(Access=private,Static)
        function[successful,errmsg]=callClientCallback(...
            clientCallbacks,callbackFieldName,callbackArgsFieldName,...
            dialog,source)
            successful=true;
            errmsg='';
            if isfield(clientCallbacks,callbackFieldName)
                if isfield(clientCallbacks,callbackArgsFieldName)
                    clientArgs=clientCallbacks.(callbackArgsFieldName);
                    fevalArgs=cell(1,length(clientArgs));

                    for argnum=1:length(clientArgs)
                        if ischar(clientArgs{argnum})
                            if strcmp(clientArgs{argnum},'%dialog')
                                fevalArgs{argnum}=dialog;
                            elseif strcmp(clientArgs{argnum},'%source')
                                fevalArgs{argnum}=source;
                            else
                                fevalArgs{argnum}=clientArgs{argnum};
                            end
                        else
                            fevalArgs{argnum}=clientArgs{argnum};
                        end
                    end
                else
                    fevalArgs={};
                end
                if isequal(callbackFieldName,'CloseCallback')
                    feval(clientCallbacks.(callbackFieldName),fevalArgs{:});
                else
                    [successful,errmsg]=feval(clientCallbacks.(callbackFieldName),fevalArgs{:});
                end
            end
        end

        function retVal=hasMethod(value,methodName)



            assert(ischar(methodName));
            if isa(value,'Simulink.VariantControl')&&strcmp(methodName,'getDialogSchema')



                retVal=true;
            elseif isa(value,'Simulink.VariantVariable')&&strcmp(methodName,'getDialogSchema')
                retVal=true;
            else
                retVal=any(strcmp(methods(class(value)),methodName));
            end
        end

    end
end



