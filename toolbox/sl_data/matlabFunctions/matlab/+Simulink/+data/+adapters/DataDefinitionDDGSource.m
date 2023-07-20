classdef DataDefinitionDDGSource<handle















    properties
UserData
    end
    properties(SetAccess=private)
m_broker
m_source
m_section
m_varName

m_mdl

m_upToDate

m_dataDefinition

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
        'Section'}
    end

    methods
        function thisObj=DataDefinitionDDGSource(broker,source,section,name)
            thisObj.m_broker=broker;
            thisObj.m_source=source;
            thisObj.m_section=section;
            thisObj.m_varName=name;

            thisObj.m_upToDate=false;
            thisObj.UserData.isUpToDate=false;
            thisObj.m_mdl=mf.zero.Model;



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
            used=slid.broker.BrokerV2.isSourceWritable(thisObj.m_source);
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
            displayLabel=[thisObj.m_source,' ',thisObj.m_section];
        end

        function dataDefinitionValue=getForwardedObject(thisObj)
            dataDefinitionValue=[];
            thisObj.validate;
            if thisObj.m_upToDate
                dataDefinitionValue=thisObj.m_resolved_mxEntry;
            end
        end

        function isValid=isValidProperty(thisObj,propName)
            isValid=false;
            thisObj.validate;
            if thisObj.m_upToDate
                if any(strcmp(propName,Simulink.data.adapters.DataDefinitionDDGSource.m_metaDataProperties))

                    isValid=true;
                else
                    if thisObj.m_entryValueIsMxArray
                        isValid=strcmp(propName,'Value')||strcmp(propName,'Dimensions')||strcmp(propName,'Complexity');
                    else
                        try
                            isValid=thisObj.m_resolved_mxEntry.isValidProperty(propName);
                        catch
                            isValid=strcmp(propName,'Value')||strcmp(propName,'Dimensions')||strcmp(propName,'Complexity');
                        end
                    end
                end
            end
        end

        function isReadonly=isReadonlyProperty(thisObj,propName)
            isReadonly=true;
            if slid.broker.BrokerV2.isSourceWritable(thisObj.m_source)
                thisObj.validate;
                if thisObj.m_upToDate
                    if strcmp(propName,'Name')
                        if thisObj.m_resolved_mxEntry.isValidProperty(propName)
                            isReadonly=thisObj.m_resolved_mxEntry.isReadonlyProperty(propName);
                        else
                            isReadonly=true;
                        end
                    elseif any(strcmp(propName,Simulink.data.adapters.DataDefinitionDDGSource.m_metaDataProperties))

                        isReadonly=true;
                    else
                        if thisObj.m_entryValueIsMxArray
                            isReadonly=strcmp(propName,'DataType')||strcmp(propName,'Dimensions')||strcmp(propName,'Complexity');
                        else
                            isReadonly=thisObj.m_resolved_mxEntry.isReadonlyProperty(propName);
                        end
                    end
                end
            end
        end

        function propDataType=getPropDataType(thisObj,propName)
            propDataType='';
            thisObj.validate;
            if thisObj.m_upToDate
                if any(strcmp(propName,Simulink.data.adapters.DataDefinitionDDGSource.m_metaDataProperties))

                    propDataType='string';
                else
                    if thisObj.m_entryValueIsMxArray
                        propDataType='string';
                    else
                        try
                            propDataType=getPropDataType(thisObj.m_resolved_mxEntry,propName);
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
                allowedValues=getPropAllowedValues(thisObj.m_resolved_mxEntry,propName);
            end
        end

        function setPropValue(thisObj,propName,propValue,context)

            thisObj.validate;
            if thisObj.m_upToDate
                if isa(thisObj.m_resolved_mxEntry,'Simulink.VariantControl')



                    vCtrl=thisObj.m_resolved_mxEntry;
                    setPropValue(vCtrl,propName,propValue,context);
                    thisObj.m_resolved_mxEntry=vCtrl;
                else



                    propType=thisObj.getPropDataType(propName);
                    if strcmp(propType,'bool')
                        propValue=strcmp(propValue,'1');
                    end




                    if thisObj.m_entryValueIsMxArray
                        assert(strcmp(propName,'Value'));
                        if isempty(context)
                            valueAssignExpr='thisObj.m_resolved_mxEntry = eval(propValue);';
                        else
                            valueAssignExpr='thisObj.m_resolved_mxEntry = evalin(context, propValue);';
                        end
                    elseif strcmp(propType,'double')


                        valueAssignExpr=['thisObj.m_resolved_mxEntry.',propName,' = ',propValue,';'];
                    else
                        valueAssignExpr=['thisObj.m_resolved_mxEntry.',propName,' = propValue;'];
                    end
                    eval(valueAssignExpr);
                end
            end
        end

        function propValue=getPropValue(thisObj,propName)
            propValue=[];
            thisObj.validate;
            if thisObj.m_upToDate
                switch propName
                case 'Name'
                    if thisObj.m_resolved_mxEntry.isValidProperty(propName)
                        propValue=thisObj.m_resolved_mxEntry.getPropValue(propName);
                    else
                        propValue=thisObj.m_dataDefinition.name;
                    end
                case 'DataSource'
                    propValue=thisObj.m_source;
                case 'Section'
                    propValue=thisObj.m_section;
                otherwise
                    if thisObj.m_entryValueIsMxArray
                        switch(propName)
                        case 'DataType'
                            propValue=class(thisObj.m_resolved_mxEntry);
                        case 'Value'
                            propValue=DAStudio.MxStringConversion.convertToString(...
                            thisObj.m_resolved_mxEntry);
                        case 'Dimensions'
                            tempVal=size(thisObj.m_resolved_mxEntry);
                            propValue=strcat('[',strcat(num2str(tempVal),']'));
                        case 'Complexity'
                            if(isnumeric(thisObj.m_resolved_mxEntry))
                                if(isreal(thisObj.m_resolved_mxEntry))
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
                            propValue=thisObj.m_resolved_mxEntry.getPropValue(propName);
                        catch
                            switch(propName)
                            case 'DataType'
                                propValue=class(thisObj.m_resolved_mxEntry);
                            case 'Value'
                                propValue=DAStudio.MxStringConversion.convertToString(...
                                thisObj.m_resolved_mxEntry);
                            case 'Dimensions'
                                tempVal=size(thisObj.m_resolved_mxEntry);
                                propValue=strcat('[',strcat(num2str(tempVal),']'));
                            case 'Complexity'
                                if(isnumeric(thisObj.m_resolved_mxEntry))
                                    if(isreal(thisObj.m_resolved_mxEntry))
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

        function childRowChanged(thisObj,rowObj,propName)
            dlgs=DAStudio.ToolRoot.getOpenDialogs(thisObj);
            for i=1:length(dlgs)
                dlg=dlgs(i);
                dlg.refresh;
                dlg.enableApplyButton(true);
            end
        end

        function children=getChildren(~)
            children={};
        end

        function dlgstruct=getDialogSchema(thisObj,~)
            thisObj.validate;
            if thisObj.m_upToDate
                if thisObj.m_entryValueIsMxArray
                    [dlgstruct,thisObj.m_clientCallbacks,thisObj.m_resolved_mxEntry]=...
                    dataDefinitionEntryDDG(thisObj,thisObj.m_dataDefinition.name,...
                    thisObj.m_resolved_mxEntry,thisObj.m_entryValueIsMxArray,...
                    thisObj.m_source,thisObj.m_section);
                else
                    [dlgstruct,thisObj.m_clientCallbacks,thisObj.m_resolved_mxEntry]=...
                    dataDefinitionEntryDDG(thisObj,thisObj.m_dataDefinition.name,...
                    thisObj.m_resolved_mxEntry,thisObj.m_entryValueIsMxArray,...
                    thisObj.m_source,thisObj.m_section);
                end

                if~slid.broker.BrokerV2.isSourceWritable(thisObj.m_source)
                    dlgstruct.DisableDialog=true;
                end
            else
                name=thisObj.m_dataDefinition.name;
                messageText.Name=DAStudio.message('Simulink:dialog:DataDictEntryNotFound',name);
                messageText.Type='text';
                messageText.WordWrap=true;
                messageText.Alignment=6;

                dlgstruct.DialogTitle=name;
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


            [successful,errmsg]=Simulink.data.adapters.DataDefinitionDDGSource.callClientCallback(...
            thisObj.m_clientCallbacks,...
            'PreApplyCallback','PreApplyArgs',dialog,source);
        end

        function close(thisObj,dialog,source)
            if thisObj.m_modifiedInDialog


                [successful,errmsg]=saveEntry(thisObj,dialog,source);
            end

            [~,~]=Simulink.data.adapters.DataDefinitionDDGSource.callClientCallback(...
            thisObj.m_clientCallbacks,...
            'CloseCallback','CloseArgs',dialog,source);

            delete(thisObj);
        end
        function[successful,errmsg]=postApply(thisObj,dialog,source)
            successful=true;
            errmsg='';



            [successful,errmsg]=Simulink.data.adapters.DataDefinitionDDGSource.callClientCallback(...
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


            if isa(thisObj.m_resolved_mxEntry,'Simulink.dd.DAObjectWrapper')

                thisObj.m_broker.updateVariable(thisObj.m_source,thisObj.m_section,thisObj.m_dataDefinition.name,...
                thisObj.m_resolved_mxEntry.m_objectToWrap);
            else
                thisObj.m_broker.updateVariable(thisObj.m_source,thisObj.m_section,thisObj.m_dataDefinition.name,...
                thisObj.m_resolved_mxEntry);
            end

            thisObj.m_modifiedInDialog=~successful;
            dialog.enableApplyButton(false);
            needRefresh=thisObj.saveVariants();
            if needRefresh
                thisObj.m_children={};
                dialog.refreshWidget('v_spreadsheet');
            end
            daevents.broadcastEvent('ListChangedEvent');
        end

        function[successful,errmsg]=postRevert(thisObj,dialog,source)
            successful=true;
            errmsg='';


            [successful,errmsg]=Simulink.data.adapters.DataDefinitionDDGSource.callClientCallback(...
            thisObj.m_clientCallbacks,...
            'PostRevertCallback','PostRevertArgs',dialog,source);

            thisObj.m_children={};
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
            obj.m_resolved_mxEntry=newValue;

        end

        function valid=isValidSourceForEnum(obj)
            valid=true;
        end

    end

    methods(Access=private)
        function validate(thisObj)
            if~thisObj.m_upToDate

                try

                    thisObj.m_dataDefinition=thisObj.m_broker.lookupSymbolByNameInSource(thisObj.m_varName,thisObj.m_source,thisObj.m_section,thisObj.m_mdl);

                    entryValue=thisObj.m_dataDefinition.getMatValue;

                    if Simulink.data.isSupportedEnumObject(entryValue)||...
                        (isa(entryValue,'table'))
                        objectLevel=0;
                    elseif(isa(entryValue,'half'))
                        objectLevel=0;
                    else
                        if isobject(entryValue)&&Simulink.data.adapters.DataDefinitionDDGSource.hasMethod(entryValue,'numel')




                            objectLevel=2;
                        else
                            objectLevel=Simulink.data.getScalarObjectLevel(entryValue);
                        end
                    end



                    if(objectLevel>0)&&...
                        (~Simulink.data.isHandleObject(entryValue))&&...
                        (~Simulink.data.adapters.DataDefinitionDDGSource.hasMethod(entryValue,'getDialogSchema'))&&...
                        (~isa(entryValue,'Simulink.Bus'))&&...
                        (~isa(entryValue,'Simulink.ConnectionBus'))&&...
                        (~isa(entryValue,'Simulink.ServiceBus'))&&...
                        (~isa(entryValue,'Simulink.NumericType'))&&...
                        (~isa(entryValue,'Simulink.AliasType'))



                        entryValue=Simulink.dd.DAObjectWrapper(entryValue);
                    end
                    thisObj.m_resolved_mxEntry=entryValue;
                    thisObj.m_entryValueIsMxArray=objectLevel==0;

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
                thisObj.m_resolved_mxEntry=[];
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



