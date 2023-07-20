function rmischemas=menus_rmi_annotation(callbackInfo)




    [rmiInstalled,rmiLicenseAvailable]=rmi.isInstalled();
    licensedAndInstalled=rmiInstalled&&rmiLicenseAvailable;


    objh=callbackInfo.getSelection;

    if rmidata.isExternal(bdroot(objh.Handle))


        rmischemas=create_requirement_links(objh);

        if isempty(rmischemas)
            has_links=false;
        else
            has_links=true;
        end


        if licensedAndInstalled
            sLinkMenus=rmi.menus_selection_links(objh);
            if~isempty(sLinkMenus)
                rmischemas=[rmischemas,sLinkMenus,'separator'];
            end
            if~rmisl.isLibObject(objh)
                rmischemas=[rmischemas,intraLinkMenus(objh),'separator'];
            end
        end



        if has_links&&licensedAndInstalled
            rmischemas=[rmischemas,{@EditAddBlk,@DeleteAllBlk},'separator'];
        elseif has_links||licensedAndInstalled
            rmischemas=[rmischemas,{@EditAddBlk},'separator'];
        end

        if licensedAndInstalled
            rmischemas=[rmischemas,{@CopyUrlToClipboard},'separator'];
        end

    else

        if licensedAndInstalled
            rmischemas={@ExternalStorageRequired};
        else
            rmischemas={};
        end
    end

    if isempty(rmischemas)




        rmischemas={@DisabledSchema};
    end

end


function link_schemas=create_requirement_links(objh,tagPrefix)
    if nargin<2
        tagPrefix='';
    end
    [descriptions,enabled]=rmi.getLinkLabels(objh);
    if isempty(descriptions)
        cnt=0;
    else
        descriptions=create_requirement_labels(descriptions);
        if iscell(descriptions)
            cnt=length(descriptions);
        else
            cnt=1;
        end
    end
    if cnt>0
        link_schemas=cell(1,cnt);
        for i=1:cnt
            [~,objH]=rmi.resolveobj(objh);
            link_schemas{i}={@CreateDynamicReqMenu,[descriptions(i),objH,i,enabled(i),{tagPrefix}]};
        end
        link_schemas{end+1}='separator';
    else
        link_schemas=cell(0);
    end
end

function labels=create_requirement_labels(descriptions)
    reqCnt=length(descriptions);

    if reqCnt==0
        labels={};
        return;
    end

    numbers=cellstr(num2str((1:reqCnt)'))';
    labels=strcat(numbers,'. "',descriptions,'"');
    for i=1:length(labels)
        oneLabel=labels{i};
        if length(oneLabel)>100
            labels{i}=[oneLabel(1:100),'..."'];
        end
    end
end

function schema=EditAddBlk(callbackInfo)%#ok<*INUSD>
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:EditAddLinks'));
    schema.tag='Simulink:EditAddBlkLinks';
    schema.callback=@EditAddBlk_callback;
    schema.autoDisableWhen='Busy';
end

function EditAddBlk_callback(callbackInfo)
    obj=callbackInfo.getSelection;
    rmi('edit',obj);
end

function schema=CreateDynamicReqMenu(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=callbackInfo.userdata{1};
    schema.tag=['Simulink:DynamicReqMenu',callbackInfo.userdata{5},num2str(callbackInfo.userdata{3})];
    schema.userdata=callbackInfo.userdata(2:3);
    if~callbackInfo.userdata{4}
        schema.state='Disabled';
    end
    schema.callback=@CreateDynamicReqMenu_callback;
    schema.autoDisableWhen='Busy';
end

function CreateDynamicReqMenu_callback(callbackInfo)
    rmi('view',callbackInfo.userdata{:});
end

function schema=DeleteAllBlk(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:DeleteAllLinks'));
    schema.tag='Simulink:DeleteBlkLinks';
    schema.callback=@DeleteAllBlk_callback;
    schema.autoDisableWhen='Busy';
end

function DeleteAllBlk_callback(callbackInfo)
    if builtin('_license_checkout','Simulink_Requirements','quiet')
        rmi.licenseErrorDlg();
    else
        obj=callbackInfo.getSelection;
        try
            rmi('clearAll',obj);
        catch Mex
            errordlg(Mex.message,getString(message('Slvnv:rmisl:menus_rmi_deprecated:FailedToDeleteLinks')));
        end
    end
end

function intraLinkSchemas=intraLinkMenus(obj)
    intraLinkSchemas=rmisl.intraLinkMenus(obj);
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
        obj=callbackInfo.getSelection;
        url=rmi.getURL(obj);
        clipboard('copy',url);
    end
end

function schema=ExternalStorageRequired(callbackInfo)
    schema=DAStudio.ActionSchema;
    if isempty(get_param(bdroot(gcs),'FileName'))
        schema.label=getString(message('Slvnv:rmidata:RmiSlData:ExternalStorageRequiredMustSave'));
        schema.tag='Simulink:AnnotationUnsavedMdl';
        schema.state='Disabled';
    else
        schema.label=getString(message('Slvnv:rmidata:RmiSlData:ExternalStorageRequiredForAnnotations'));
        schema.tag='Simulink:AnnotationExternalRmi';
        schema.callback=@ExternalStorageRequired_callback;
    end
    schema.autoDisableWhen='Busy';
end

function ExternalStorageRequired_callback(callbackInfo)
    obj=callbackInfo.getSelection;
    modelH=bdroot(obj.Handle);
    if strcmp(get_param(modelH,'hasReqInfo'),'on')
        msgbox({...
        getString(message('Slvnv:rmidata:RmiSlData:AnnotationsExternalRequired')),...
        getString(message('Slvnv:rmidata:RmiSlData:AnnotationsModelEmbedded')),...
        getString(message('Slvnv:rmidata:RmiSlData:AnnotationsUseMoveToFile'))},...
        getString(message('Slvnv:rmidata:RmiSlData:AnnotationLinkingDisabled')));
    else
        rmi.settings_mgr('set','settingsTab',0);
        rmi_settings_dlg();
    end
end

function schema=DisabledSchema(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:LinkingUnavailable'));
    schema.tag='Simulink:NoRmiLinking';
    schema.state='Disabled';
    schema.autoDisableWhen='Busy';
end


