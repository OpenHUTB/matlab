function schemas=menus_rmi_vector(callbackInfo)

    licensed=rmiLicenseAvailable();
    installed=rmi.isInstalled();

    schemas=cell(0);

    if licensed&&installed
        modelH=callbackInfo.model.Handle;
        if installed&&licensed&&rmisl.menus_UpdateDataBeforeUse(modelH)
            schemas={@rmisl.menus_UpdateDataBeforeUse};
            return;
        end
        objects=getSelectedObjects(callbackInfo);
        if isempty(objects)
            return;
        end

        if isa(callbackInfo.domain,'SLM3I.SLDomain')&&...
            annotation_present(objects)
            if~rmidata.isExternal(bdroot(objects(1)))

                schemas={@ExternalStorageRequired};
                return;
            else

            end
        end

        if~signalbuilder_present(objects)
            sLinkMenus=rmi.menus_selection_links(objects);
            if~rmiut.isMeOpen()
                sLinkMenus=skipDataLink(sLinkMenus);
            end
            if~isempty(sLinkMenus)
                schemas=[schemas,sLinkMenus,'separator'];
            end
            if~rmisl.isLibObject(objects)
                schemas=[schemas,intraLinkMenus(objects),'separator'];
            end
        end
        schemas=[schemas,{@RequirementVectorAdd}];
        if~library_object_present(objects)
            schemas=[schemas,{@RequirementVectorDelete},'separator'];
        end
        schemas=[schemas,{@CopyUrlToClipboard}];
    end

end


function selectionMenus=skipDataLink(selectionMenus)
    takeIdx=true(size(selectionMenus));
    for i=1:length(takeIdx)
        if~isempty(strfind(selectionMenus{i}{2}{2},'DATA'))
            takeIdx(i)=false;
            break;
        end
    end
    selectionMenus=selectionMenus(takeIdx);
end


function objs=getSelectedObjects(cbInfo)
    if~isempty(cbInfo.userdata)
        objs=cbInfo.userdata;
    else
        selection=cbInfo.getSelection;
        objs=vectorSelection(selection);
    end
end


function result=library_object_present(objs)
    for i=1:length(objs)
        if rmisl.inLibrary(objs(i))||rmisl.inSubsystemReference(objs(i))
            result=true;
            return;
        end
    end
    result=false;
end


function result=signalbuilder_present(objs)
    for i=1:length(objs)
        if is_signalbuilder(objs(i))
            result=true;
            return;
        end
    end
    result=false;
end


function result=annotation_present(objs)
    for i=1:length(objs)
        if strcmp(get_param(objs(i),'type'),'annotation')
            result=true;
            return;
        end
    end
    result=false;
end


function out=is_signalbuilder(obj)
    [isSf,objH]=rmi.resolveobj(obj);
    out=~isempty(objH)&&~isSf&&strcmp(get_param(objH,'Type'),'block')...
    &&strcmp(get_param(objH,'MaskType'),'Sigbuilder block');
end


function schema=RequirementVectorAdd(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:AddLinksToAll'));
    schema.tag='Simulink:editor:ContextMenuItemLabelStr_RequirementVectorAdd';
    schema.callback=@RequirementVectorAdd_callback;
    schema.autoDisableWhen='Busy';
end


function schema=RequirementVectorDelete(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:DeleteAllLinks'));
    schema.tag='Simulink:editor:ContextMenuItemLabelStr_RequirementVectorDelete';
    schema.callback=@RequirementVectorDelete_callback;
    schema.autoDisableWhen='Busy';
end


function RequirementVectorAdd_callback(callbackInfo)
    select=callbackInfo.getSelection;
    rmi('edit',vectorSelection(select));
end


function RequirementVectorDelete_callback(callbackInfo)
    if builtin('_license_checkout','Simulink_Requirements','quiet')
        rmi.licenseErrorDlg();
    else
        select=callbackInfo.getSelection;
        try
            rmi('clearAll',vectorSelection(select));
        catch Mex
            errordlg(Mex.message,getString(message('Slvnv:rmisl:menus_rmi_deprecated:FailedToDeleteLinks')));
        end
    end
end


function obj=vectorSelection(select)
    row=size(select,1);
    obj=[];
    for i=1:row
        [~,objH,errMsg]=rmi.resolveobj(select(i));
        if isempty(errMsg)&&~isempty(objH)
            obj(end+1)=objH;%#ok<AGROW>
        end
    end
end


function intraLinkSchemas=intraLinkMenus(obj)
    intraLinkSchemas=rmisl.intraLinkMenus(obj);
end


function schema=ExternalStorageRequired(callbackInfo)%#ok<*INUSD>
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmidata:RmiSlData:ExternalStorageRequiredForAnnotations'));
    schema.tag='Simulink:AnnotationExternalRmi';
    schema.callback=@ExternalStorageRequired_callback;
    schema.autoDisableWhen='Busy';
end


function ExternalStorageRequired_callback(callbackInfo)
    objs=getSelectedObjects(callbackInfo);
    modelH=bdroot(objs(1));
    if strcmp(get_param(modelH,'hasReqInfo'),'on')
        msgbox({...
        getString(message('Slvnv:rmidata:RmiSlData:AnnotationsExternalRequired')),...
        getString(message('Slvnv:rmidata:RmiSlData:AnnotationsModelEmbedded')),...
        getString(message('Slvnv:rmidata:RmiSlData:AnnotationsUseMoveToFile'))},...
        getString(message('Slvnv:rmidata:RmiSlData:AnnotationLinkingDisabled')));
    else
        rmi.settings_mgr('set','settingsTab',3);
        rmi_settings_dlg();
    end
end


function schema=CopyUrlToClipboard(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:CopyURL'));
    schema.tag='Simulink:CopyUrlToClipboard';
    schema.callback=@CopyUrlToClipboard_callback;
    schema.autoDisableWhen='Busy';
end
function CopyUrlToClipboard_callback(callbackInfo)
    if builtin('_license_checkout','Simulink_Requirements','quiet')
        rmi.licenseErrorDlg();
    else
        objs=vectorSelection(callbackInfo.getSelection);
        url=rmi.getURL(objs);
        clipboard('copy',url);
    end
end


function result=rmiLicenseAvailable()
    result=license('test','Simulink_Requirements');
end

