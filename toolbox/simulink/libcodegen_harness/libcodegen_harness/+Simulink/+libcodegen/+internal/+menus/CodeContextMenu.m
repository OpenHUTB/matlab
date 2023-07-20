function schema=CodeContextMenu(fncname,cbinfo)

    fcn=str2func(fncname);
    schema=fcn(cbinfo);
end

function schema=CodeContextMenuImpl(cbinfo)%#ok<*DEFNU> % ( menu, cbinfo )
    schema=sl_container_schema;
    schema.label=DAStudio.message('Simulink:studio:CodeContextMenu');
    schema.tag='Simulink:CodeContextMenu';
    schema.generateFcn=@generateCodeContextMenuChildren;
    isLib=isLibModel(cbinfo.model.Name);
    [~,isCompatSingleSel]=getContextSelectionAndValidate(cbinfo);


    if isCompatSingleSel
        schema.state='Enabled';
    elseif isLib&&~hideMenu()
        schema.state='Disabled';
        return;
    else
        schema.state='Hidden';
    end

    schema.autoDisableWhen='Busy';
end

function children=generateCodeContextMenuChildren(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    children={...
    im.getAction('Simulink:ManageCodeContexts')...
    ,im.getSubmenu('Simulink:ViewCodeContext')...
    ,im.getAction('Simulink:CreateCodeContext')...
    };
end

function schema=CreateCodeContext(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CreateCodeContext';
    schema.label=DAStudio.message('Simulink:studio:CreateCodeContext');
    isLib=isLibModel(cbinfo.model.Name);

    [sel,isCompatSingleSel]=getContextSelectionAndValidate(cbinfo);
    owner=sel;
    instanceInfo='';
    if isLib&&isCompatSingleSel
        schema.state='Enabled';
    elseif isCompatSingleSel
        [refBlock,~,~]=loc_getRefBlockAndLoadLib(sel);
        owner=get_param(refBlock,'Object');
        instanceInfo.instanceModelName=cbinfo.model.name;
        instanceInfo.instanceFileName=get_param(cbinfo.model.name,'FileName');
        instanceInfo.instanceCUTName=sel.Name;
        schema.state='Enabled';

    else
        schema.state='Hidden';
    end

    schema.userdata={owner,instanceInfo};
    schema.autoDisableWhen='Busy';
    schema.callback=@CodeContextCreateCB;
end

function CodeContextCreateCB(cbinfo)
    owner=cbinfo.userdata{1};
    instanceInfo=cbinfo.userdata{2};
    Simulink.libcodegen.dialogs.codeContextCreateDialog.create(owner,instanceInfo);
end

function schema=ManageCodeContexts(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:ManageCodeContexts');
    schema.tag='Simulink:ManageCodeContexts';
    [sel,isCompatSingleSel]=getContextSelectionAndValidate(cbinfo);
    if isCompatSingleSel
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

    schema.userdata={sel};
    schema.callback=@ManageCodeContextsCB;
    schema.autoDisableWhen='Busy';
end

function ManageCodeContextsCB(cbinfo)
    sel=cbinfo.userdata{1};
    Simulink.libcodegen.dialogs.codeContextListDialog.create(cbinfo.model.name,sel.Handle);
end

function schema=ViewCodeContext(cbinfo)
    schema=sl_container_schema;
    schema.label=DAStudio.message('Simulink:studio:ViewCodeContext');
    schema.tag='Simulink:ViewCodeContext';
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:HiddenSchema')};
    schema.autoDisableWhen='Busy';

    isLib=isLibModel(cbinfo.model.Name);
    [sel,isCompatSingleSel]=getContextSelectionAndValidate(cbinfo);

    activeContext='';
    if isCompatSingleSel&&isLib
        ownerHandle=sel.Handle;
        codeContexts=Simulink.libcodegen.internal.getBlockCodeContexts(cbinfo.model.Name,sel.Handle);
    else
        schema.state='Hidden';
        return;
    end

    if~isempty(codeContexts)
        numContexts=length(codeContexts);
        childrenFcns=cell(numContexts,1);
        index=1;
        if~isempty(activeContext)
            childrenFcns{index}={@AddViewCodeContext,...
            {index,activeContext,ownerHandle,true}};
            index=index+1;

        end
        for n=1:length(codeContexts)
            if~strcmp(codeContexts(n).name,activeContext)
                childrenFcns{index}={@AddViewCodeContext,...
                {index,codeContexts(n).name,codeContexts(n).ownerHandle,false}};
                index=index+1;
            end
        end

        if~isempty(childrenFcns)
            schema.childrenFcns=childrenFcns;
        end
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

end

function ViewCodeContextCB(cbinfo)
    ownerH=cbinfo.userdata{1};
    name=cbinfo.userdata{2};
    open_system(bdroot(ownerH));
    Simulink.libcodegen.dialogs.codeContextViewDialog.create(ownerH,name);
end

function schema=AddViewCodeContext(cbinfo)
    mIndex=cbinfo.userdata{1};
    mName=cbinfo.userdata{2};
    ownerH=cbinfo.userdata{3};
    schema=sl_action_schema;
    if cbinfo.userdata{4}
        dispLabel=[mName,' (Active)'];
    else
        dispLabel=mName;
    end
    schema.label=dispLabel;
    schema.tag=['Simulink:ViewCodeContext_',num2str(mIndex)];
    schema.userdata={ownerH,mName};
    schema.autoDisableWhen='Busy';
    schema.callback=@ViewCodeContextCB;
end

function hide=hideMenu()
    hide=false;
    if slfeature('CodeContextHarness')==0||...
        (~loc_TestEmbeddedCoderInstallation&&...
        ~loc_TestCoderLicense)
        hide=true;
    end
end

function[sel,isCompatSingleSel]=getContextSelectionAndValidate(cbinfo)
    sel=cbinfo.getSelection();
    isCompatSingleSel=false;

    if hideMenu()
        return;
    end

    isHarnessBD=Simulink.harness.isHarnessBD(cbinfo.model.name)&&...
    ~Simulink.harness.internal.isCodeContextBD(cbinfo.model.name);
    isLib=isLibModel(cbinfo.model.Name);


    if~isLib&&~Simulink.libcodegen.internal.isInCodePerspective(cbinfo.model.name)
        isCompatSingleSel=false;
        return;
    end

    if isHarnessBD
        isCompatSingleSel=false;
    elseif(numel(sel)==1)&&isa(sel,'Simulink.SubSystem')
        isCompatSingleSel=~isImplicitLink(sel)&&isAtomicReusableSS(sel,isLib);
    elseif isempty(sel)&&isa(get_param(gcs,'Object'),'Simulink.SubSystem')
        sel=get_param(gcs,'Object');
        isCompatSingleSel=~isImplicitLink(sel)&&isAtomicReusableSS(sel,isLib);
    end

    if isCompatSingleSel&&~isLib
        isCompatSingleSel=strcmpi(get_param(sel.Handle,'LinkStatus'),'resolved');
    end

end

function r=isAtomicReusableSS(sel,isLib)
    ownerHandle=sel.Handle;
    r=(strcmp(get_param(ownerHandle,'TreatAsAtomicUnit'),'on')&&...
    strcmp(get_param(ownerHandle,'RTWSystemCode'),'Reusable function'));

    if isLib
        r=r&&strcmp(get_param(ownerHandle,'Parent'),get_param(bdroot(ownerHandle),'Name'))&&...
        isempty(get_param(ownerHandle,'ReferenceBlock'));
    end
end

function r=isImplicitLink(sel)
    ownerHandle=sel.Handle;
    r=Simulink.harness.internal.isImplicitLink(ownerHandle);
end

function r=isLibModel(modelName)
    r=strcmpi(get_param(modelName,'BlockDiagramType'),'library');
end

function res=loc_TestEmbeddedCoderInstallation
    res=dig.isProductInstalled('Embedded Coder');
end

function res=loc_TestCoderLicense
    res=license('test','RTW_Embedded_Coder');
end

function[refBlock,libModel,libLocked]=loc_getRefBlockAndLoadLib(sel)
    refBlock=get_param(sel.Handle,'ReferenceBlock');
    idx=strfind(refBlock,'/');
    idx=idx(1);
    libModel=refBlock(1:idx-1);
    load_system(libModel);
    libLocked=strcmp(get_param(libModel,'Lock'),'on');
end
