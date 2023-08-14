classdef wsDDGSource<handle






    properties
UserData
    end
    properties(SetAccess=private)
m_name
m_value
m_ws
m_entryValueIsMxArray

m_clientCallbacks
m_modifiedInDialog
m_errorsInDialog
mDialogTag
m_proplistener
m_hierlistener
    end
    properties(Access=public)
        m_modelCloseListener=[];
    end

    methods
        function thisObj=wsDDGSource(entryName,wsName)
            thisObj.m_name=entryName;
            thisObj.m_ws=wsName;
            if isempty(thisObj.m_ws)||isequal(thisObj.m_ws,'Base')
                thisObj.m_ws='base';
            end
            ws=thisObj.m_ws;
            if~isequal(ws,'base')
                oModel=get_param(thisObj.m_ws,'Object');
                thisObj.m_modelCloseListener=Simulink.listener(oModel,'CloseEvent',...
                @(src,eventData)thisObj.modelCloseListener(src,eventData,thisObj));
            end
            objectLevel=thisObj.initValue();
            thisObj.m_entryValueIsMxArray=(objectLevel==0);

            thisObj.m_clientCallbacks=[];
            thisObj.m_modifiedInDialog=false;
            thisObj.m_errorsInDialog=false;
            thisObj.mDialogTag=[];

            ed=DAStudio.EventDispatcher;
            thisObj.m_proplistener=...
            handle.listener(ed,'PropertyChangedEvent',...
            @(src,eventData)thisObj.onChangeEvent(src,eventData,thisObj));
            thisObj.m_hierlistener=...
            handle.listener(ed,'HierarchyChangedEvent',...
            @(src,eventData)thisObj.onChangeEvent(src,eventData,thisObj));
        end

        function objectLevel=initValue(thisObj)
            if~isequal(thisObj.m_ws,'base')
                mws=get_param(thisObj.m_ws,'ModelWorkspace');
                thisObj.m_value=mws.getVariableContext(thisObj.m_name);
                objectLevel=Simulink.data.getScalarObjectLevel(thisObj.m_value);
                if wrapObjectInSlidDAProxy(thisObj)


                    objectLevel=0;
                end

                oModel=get_param(thisObj.m_ws,'Object');
                thisObj.m_modelCloseListener=Simulink.listener(oModel,'CloseEvent',...
                @(src,eventData)thisObj.modelCloseListener(src,eventData,thisObj));
            else
                thisObj.m_value=evalin(thisObj.m_ws,thisObj.m_name);
                objectLevel=Simulink.data.getScalarObjectLevel(thisObj.m_value);
            end
        end

        function displayLabel=getDisplayLabel(thisObj)
            displayLabel=thisObj.m_name;
        end

        function entryValue=getForwardedObject(thisObj)
            entryValue=unWrapObjectFromSlidDAProxy(thisObj);
        end

        function isValid=isValidProperty(thisObj,propName)
            isValid=false;
            if thisObj.m_entryValueIsMxArray&&~(isa(thisObj.m_value,'Simulink.SlidDAProxy'))
                isValid=ismember(propName,{'Name','Value','Dimensions','Complexity'});
            else
                try
                    isValid=thisObj.m_value.isValidProperty(propName);
                catch
                    isValid=ismember(propName,{'Value','Dimensions','Complexity'});
                end
            end
        end

        function isReadonly=isReadonlyProperty(thisObj,propName)
            isReadonly=true;
            if strcmp(propName,'Name')
                if thisObj.m_value.isValidProperty(propName)
                    isReadonly=thisObj.m_value.isReadonlyProperty(propName);
                else
                    isReadonly=true;
                end
            else
                if thisObj.m_entryValueIsMxArray&&~(isa(thisObj.m_value,'Simulink.SlidDAProxy'))
                    isReadonly=ismember(propName,{'DataType','Dimensions','Complexity'});
                else
                    try
                        isReadonly=thisObj.m_value.isReadonlyProperty(propName);
                    catch
                        isReadonly=true;
                    end
                end
            end
        end

        function getPropertyStyle(thisObj,propName,objStyle)
            if isequal(slfeature('MWSValueSource'),2)&&...
                isequal(propName,'Value')&&...
                isa(thisObj.m_value,'Simulink.SlidDAProxy')

                effectiveValue=thisObj.getPropValue(propName);

                try
                    if isequal(get_param(thisObj.m_ws,'HasValueManager'),'on')
                        valSrcMgr=get_param(thisObj.m_ws,'ValueManager');
                        if~isempty(valSrcMgr)
                            slidObj=thisObj.m_value.getObject;
                            effValue=valSrcMgr.getActiveValueThrowError(slidObj.UUID);
                            if~isempty(effValue)
                                defaultValue=DAStudio.MxStringConversion.convertToString(slidObj.Value);
                                overlay=valSrcMgr.getEffectiveOverlayThrowError(slidObj.UUID);
                                effectiveOverlay=overlay.getName;

                                objStyle.Tooltip=[effectiveValue,newline...
                                ,DAStudio.message('Simulink:dialog:OverriddenValue',...
                                defaultValue,...
                                effectiveOverlay)];
                            end
                        end
                    end
                catch
                end
            end
        end

        function propDataType=getPropDataType(thisObj,propName)
            propDataType='';
            if thisObj.m_entryValueIsMxArray&&~(isa(thisObj.m_value,'Simulink.SlidDAProxy'))
                propDataType='string';
            else
                try
                    propDataType=getPropDataType(thisObj.m_value,propName);
                catch
                    propDataType='mxArray';
                end
            end
        end

        function allowedValues=getPropAllowedValues(thisObj,propName)
            allowedValues=[];
            if~thisObj.m_entryValueIsMxArray||isa(thisObj.m_value,'Simulink.SlidDAProxy')
                allowedValues=getPropAllowedValues(thisObj.m_value,propName);
            end
        end

        function proxy=getSlidViewProxy(thisObj)
            proxy=thisObj.m_value;
        end

        function setPropValue(thisObj,propName,propValue)
            propType=thisObj.getPropDataType(propName);
            if strcmp(propType,'bool')
                propValue=strcmp(propValue,'1');
            end




            plainMatlabVar=thisObj.m_entryValueIsMxArray&&~(isa(thisObj.m_value,'Simulink.SlidDAProxy'));
            try
                if plainMatlabVar||...
                    (strcmp(propName,'Value')&&...
                    ~isprop(thisObj.m_value,'Value'))
                    assert(strcmp(propName,'Value'));
                    ws=thisObj.m_ws;
                    if~isequal(ws,'base')
                        ws=get_param(thisObj.m_ws,'ModelWorkspace');
                        ws.assignin(thisObj.m_name,evalin(ws,propValue));
                        thisObj.initValue();
                    else
                        thisObj.m_value=evalin(ws,propValue);
                    end
                else
                    valueAssignExpr=['thisObj.m_value.',propName,' = propValue;'];
                    eval(valueAssignExpr);
                end
            catch E
                thisObj.m_errorsInDialog=true;
                rethrow(E);
            end
        end

        function propValue=getPropValue(thisObj,propName)
            propValue=[];
            switch propName
            case 'Name'
                if thisObj.m_value.isValidProperty(propName)
                    if(isa(thisObj.m_value,'Simulink.Parameter'))
                        propValue=thisObj.m_value.getPropValue(propName,false);
                    else
                        propValue=thisObj.m_value.getPropValue(propName);
                    end
                else
                    propValue=thisObj.m_name;
                end
            otherwise
                if thisObj.m_entryValueIsMxArray
                    realValue=thisObj.unWrapObjectFromSlidDAProxy();
                    switch(propName)
                    case 'DataType'
                        propValue=class(realValue);
                    case 'Value'
                        if isequal(slfeature('MWSValueSource'),2)
                            propValue=thisObj.m_value.getPropValue(propName);
                        else
                            propValue=DAStudio.MxStringConversion.convertToString(...
                            realValue);
                        end
                    case 'Dimensions'
                        tempVal=size(realValue);
                        propValue=strcat('[',strcat(num2str(tempVal),']'));
                    case 'Complexity'
                        if(isnumeric(realValue))
                            if(isreal(realValue))
                                propValue='real';
                            else
                                propValue='complex';
                            end
                        else
                            propValue='N/A';
                        end
                    case 'Argument'
                        if isa(thisObj.m_value,'Simulink.SlidDAProxy')
                            propValue=thisObj.m_value.getPropValue(propName);
                        end
                    otherwise
                        assert(false);
                    end
                else
                    try
                        if(isa(thisObj.m_value,'Simulink.Parameter'))
                            propValue=thisObj.m_value.getPropValue(propName,false);
                        else
                            propValue=thisObj.m_value.getPropValue(propName);
                        end
                    catch
                        switch(propName)
                        case 'DataType'
                            propValue=class(thisObj.m_value);
                        case 'Value'
                            propValue=DAStudio.MxStringConversion.convertToString(...
                            thisObj.m_value);
                        case 'Dimensions'
                            tempVal=size(thisObj.m_value);
                            propValue=strcat('[',strcat(num2str(tempVal),']'));
                        case 'Complexity'
                            if(isnumeric(thisObj.m_value))
                                if(isreal(thisObj.m_value))
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

        function dlgstruct=getDialogSchema(thisObj,~)
            if thisObj.m_entryValueIsMxArray

                dlgstruct=da_mxarray_get_schema(thisObj);
            else
                try
                    dlgstruct=thisObj.m_value.getDialogSchema(thisObj.m_name);
                catch

                    dlgstruct=da_mxarray_get_schema(thisObj);
                end
            end

            thisObj.m_clientCallbacks=[];
            [dlgstruct,thisObj.m_clientCallbacks]=...
            thisObj.loc_captureCallbackField('PreApplyCallback',dlgstruct,thisObj.m_clientCallbacks);
            [dlgstruct,thisObj.m_clientCallbacks]=...
            thisObj.loc_captureCallbackField('PreApplyArgs',dlgstruct,thisObj.m_clientCallbacks);
            [dlgstruct,thisObj.m_clientCallbacks]=...
            thisObj.loc_captureCallbackField('PostApplyCallback',dlgstruct,thisObj.m_clientCallbacks);
            [dlgstruct,thisObj.m_clientCallbacks]=...
            thisObj.loc_captureCallbackField('PostApplyArgs',dlgstruct,thisObj.m_clientCallbacks);
            [dlgstruct,thisObj.m_clientCallbacks]=...
            thisObj.loc_captureCallbackField('CloseCallback',dlgstruct,thisObj.m_clientCallbacks);
            [dlgstruct,thisObj.m_clientCallbacks]=...
            thisObj.loc_captureCallbackField('CloseArgs',dlgstruct,thisObj.m_clientCallbacks);

            dlgstruct.PreApplyMethod='preApply';
            dlgstruct.PreApplyArgs={'%dialog','%source'};
            dlgstruct.PreApplyArgsDT={'handle','handle'};

            dlgstruct.PostApplyMethod='postApply';
            dlgstruct.PostApplyArgs={'%dialog','%source'};
            dlgstruct.PostApplyArgsDT={'handle','handle'};

            dlgstruct.CloseMethod='close';
            dlgstruct.CloseMethodArgs={'%dialog','%source'};
            dlgstruct.CloseMethodArgsDT={'handle','handle'};

            if~isfield(dlgstruct,'DialogTag')
                dlgstruct.DialogTag=['wsDDGSource_',thisObj.m_ws,'_',thisObj.m_name];
            end
            thisObj.mDialogTag=dlgstruct.DialogTag;
        end

        function[successful,errmsg]=preApply(thisObj,dialog,source)
            errmsg='';
            if thisObj.m_errorsInDialog
                successful=false;
                thisObj.m_errorsInDialog=false;
            else

                if dialog.hasUnappliedChanges
                    thisObj.m_modifiedInDialog=true;
                end


                [successful,errmsg]=wsDDGSource.callClientCallback(...
                thisObj.m_clientCallbacks,...
                'PreApplyCallback','PreApplyArgs',dialog,source);
            end
        end

        function close(thisObj,dialog,source)

            [~,~]=wsDDGSource.callClientCallback(...
            thisObj.m_clientCallbacks,...
            'CloseCallback','CloseArgs',dialog,source);

            delete(thisObj);
        end

        function[successful,errmsg]=postApply(thisObj,dialog,source)


            [successful,errmsg]=wsDDGSource.callClientCallback(...
            thisObj.m_clientCallbacks,...
            'PostApplyCallback','PostApplyArgs',dialog,source);

            if thisObj.m_modifiedInDialog
                try
                    ws=thisObj.m_ws;
                    if~isequal(ws,'base')
                        ws=get_param(thisObj.m_ws,'ModelWorkspace');
                        val=ws.getVariableContext(thisObj.m_name);
                    else
                        val=evalin(ws,thisObj.m_name);
                    end

                    if thisObj.m_entryValueIsMxArray||~isequal(val,thisObj.m_value)
                        assignin(ws,thisObj.m_name,unWrapObjectFromSlidDAProxy(thisObj));
                        ed=DAStudio.EventDispatcher;
                        ed.broadcastEvent('PropertyChangedEvent',unWrapObjectFromSlidDAProxy(thisObj));
                    elseif~isequal(ws,'base')
                        ws.setDirty();
                    end
                catch me
                    successful=false;
                    errmsg=me.message;
                end
                thisObj.m_modifiedInDialog=~successful;
            end
        end

        function setEntryValue(obj,newValue)
            obj.m_modifiedInDialog=true;
            obj.m_value=newValue;
        end


    end

    methods(Static,Access=public)
        function modelCloseListener(a,b,obj)
            dialogs=DAStudio.ToolRoot.getOpenDialogs.find(...
            'dialogTag',obj.mDialogTag);
            dialogs=dialogs';
            for dialog=dialogs
                if isequal(obj,dialog.getSource)
                    dialog.delete;
                end
            end
        end
        function onChangeEvent(src,eventData,obj)
            dialogs=DAStudio.ToolRoot.getOpenDialogs.find(...
            'dialogTag',obj.mDialogTag);
            dialogs=dialogs';
            for dialog=dialogs
                if isequal(obj,dialog.getSource)
                    try
                        if~isequal(obj.m_ws,'base')
                            ws=get_param(obj.m_ws,'ModelWorkspace');
                            newObj=ws.getVariableContext(obj.m_name);
                            oldObj=getForwardedObject(obj.m_value);
                            if~isequal(oldObj,newObj)
                                obj.m_value=newObj;
                                wrapObjectInSlidDAProxy(obj);
                            end
                        else
                            obj.m_value=evalin(obj.m_ws,obj.m_name);
                        end
                    catch

                    end
                    dialog.refresh;
                end
            end
        end

    end

    methods(Access=private)
        function[dlgstruct,clientCallbacks]=loc_captureCallbackField(thisObj,...
            callbackFieldName,dlgstruct,clientCallbacks)
            if isfield(dlgstruct,callbackFieldName)
                clientCallbacks.(callbackFieldName)=dlgstruct.(callbackFieldName);
                dlgstruct=rmfield(dlgstruct,callbackFieldName);
            end
        end

        function wrapped=wrapObjectInSlidDAProxy(thisObj)
            wrapped=false;
            if(isa(thisObj.m_value,'Simulink.Parameter')...
                ||isa(thisObj.m_value,'Simulink.LookupTable')...
                ||isa(thisObj.m_value,'Simulink.Breakpoint'))
                dictSys=get_param(thisObj.m_ws,'DictionarySystem');
                dictParam=dictSys.Parameter.getByKey(thisObj.m_name);
                if~isempty(dictParam)
                    thisObj.m_value=Simulink.SlidDAProxy(dictParam);
                    wrapped=true;
                end
            elseif(isa(thisObj.m_value,'Simulink.Signal'))
                dictSys=get_param(thisObj.m_ws,'DictionarySystem');
                dictVariable=dictSys.Variable.getByKey(thisObj.m_name);
                if~isempty(dictVariable)
                    thisObj.m_value=Simulink.SlidDAProxy(dictVariable);
                    wrapped=true;
                end
            elseif~(isa(thisObj.m_value,'Simulink.SlidDAProxy'))
                dictSys=get_param(thisObj.m_ws,'DictionarySystem');
                dictVariable=dictSys.Parameter.getByKey(thisObj.m_name);
                if~isempty(dictVariable)
                    thisObj.m_value=Simulink.SlidDAProxy(dictVariable);
                    wrapped=true;
                end
            end
        end

        function underneathDataObj=unWrapObjectFromSlidDAProxy(thisObj)
            if(isa(thisObj.m_value,'Simulink.SlidDAProxy'))
                underneathDataObj=thisObj.m_value.getForwardedObject();
            else
                underneathDataObj=thisObj.m_value;
            end
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
                if isequal(clientCallbacks,'CloseCallback')
                    feval(clientCallbacks.(callbackFieldName),fevalArgs{:});
                else
                    [successful,errmsg]=feval(clientCallbacks.(callbackFieldName),fevalArgs{:});
                end
            end
        end
    end
end
