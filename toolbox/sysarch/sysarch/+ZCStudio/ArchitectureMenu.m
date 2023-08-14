function schema=ArchitectureMenu(fcnName,cbinfo,varargin)




    fcn=str2func(fcnName);

    if nargout(fcn)
        schema=fcn(cbinfo);
    else
        schema=[];
        if nargin>=3
            eventData=varargin;
            fcn(cbinfo,eventData{:});
        else
            fcn(cbinfo);
        end
    end
end


function schema=ArchitectureMenuImpl(cbinfo)
    if Simulink.internal.isArchitectureModel(cbinfo,'Architecture')||...
        Simulink.internal.isArchitectureModel(cbinfo,'SoftwareArchitecture')
        schema=sl_container_schema;
        schema.tag='SystemComposer:ArchitectureMenu';
        schema.label=DAStudio.message('SystemArchitecture:studio:ArchitectureMenu');
        schema.generateFcn=@generateArchitectureMenuChildren;
        schema.autoDisableWhen='Never';
    else
        schema=[];
    end
end

function children=generateArchitectureMenuChildren(cbinfo)

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');



    showBlockParams=false;


    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidBlock(block)
        if systemcomposer.internal.isReferenceComponent(block.handle)
            showBlockParams=true;
        end
    end

    children={
    im.getSubmenu('SystemComposer:ProfileMenu'),...
    im.getSubmenu('SystemComposer:ComponentMenu')
    };
    children=[children,...
    {'separator',...
    im.getAction('SystemComposer:OpenArchViews')}];
    children=[children,...
    {'separator',...
    im.getAction('SystemComposer:OpenSpotlightMenuItem'),...
    'separator',...
    im.getAction('SystemComposer:InterfaceEditorMenuItem'),...
    'separator',...
    im.getSubmenu('SystemComposer:InstanceMenu'),...
    'separator',...
    im.getAction('Simulink:CreateSubsystemFromSelection'),...
    'separator'}];

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    for i=1:numel(blocks)
        block=blocks(i);
        if((SLStudio.Utils.objectIsValidSubsystemBlock(block)...
            &&~systemcomposer.internal.isAdapter(block.handle))...
            ||SLStudio.Utils.objectIsValidModelReferenceBlock(block))
            children=[children,...
            {im.getSubmenu('Simulink:FormatMenu'),...
            'separator'}];
            break;
        end
    end

    if showBlockParams
        children=[children,...
        {im.getAction('Simulink:BlockParameters')}];
    end
    children=[children,...
    {im.getAction('Simulink:ObjectProperties')}];


    sl_custom_schemas=SLStudio.getCustomSchemas('SystemComposer:ArchitectureMenu');
    children=[children,{'separator'},sl_custom_schemas];
end

function schema=ComponentMenu(cbinfo)%#ok<DEFNU>     
    schema=sl_container_schema;
    schema.tag='SystemComposer:ComponentMenu';
    schema.label=DAStudio.message('SystemArchitecture:studio:ComponentMenu');
    if Simulink.internal.isParentArchitectureDomain(cbinfo,'Architecture')||...
        Simulink.internal.isParentArchitectureDomain(cbinfo,'SoftwareArchitecture')
        block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
        blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
        if~cbinfo.studio.App.hasSpotlightView()&&(((SLStudio.Utils.objectIsValidSubsystemBlock(block)&&...
            ~systemcomposer.internal.isAdapter(block.handle))||...
            SLStudio.Utils.objectIsValidModelReferenceBlock(block)||...
            all(arrayfun(@(x)SLStudio.Utils.isValidBlockHandle(x)&&~systemcomposer.internal.isAdapter(x),blockHandles))))
            schema.state='Enabled';
        else
            hideOrDisableMenuItem(cbinfo,schema);
        end
    else
        schema.state='Hidden';
    end

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={...
    im.getAction('SystemComposer:SaveAsArchitectureModelMenuItem'),...
    im.getAction('SystemComposer:CreateSoftwareArchitectureModelMenuItem'),...
    im.getAction('SystemComposer:CreateSimulinkBehaviorMenuItem'),...
    im.getAction('SystemComposer:LinkToModelMenuItem'),...
    im.getAction('SystemComposer:InlineModelMenuItem'),...
    im.getAction('SystemComposer:ArchAddVariantMenuItem')...
    };
end

function schema=ProfileMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='SystemComposer:ProfileMenu';
    schema.label=DAStudio.message('SystemArchitecture:studio:ProfileMenu');
    schema.state='Enabled';
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('SystemComposer:ProfEditorMenuItem'),...
    im.getAction('SystemComposer:ProfImportMenuItem'),...
    'separator',...
    @ZCStudio.AttachRemoveProfileMenu,...
    'separator',...
    @ZCStudio.AttachPrototypeMenu,...
    'separator',...
    @ZCStudio.ApplyToAllComponentsMenu,...
    @ZCStudio.ApplyToAllPortsMenu,...
    @ZCStudio.ApplyToAllConnectorsMenu...
    };
end

function schema=InstanceMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='SystemComposer:InstanceMenu';
    schema.label=DAStudio.message('SystemArchitecture:studio:InstanceMenu');
    schema.state='Enabled';
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('SystemComposer:InstantiateMenuItem'),...
    im.getAction('SystemComposer:OpenViewerMenuItem')...
    };
end

function schema=OpenProfileEditor(~)%#ok<DEFNU>
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:ProfEditorMenuItem';
    schema.label=DAStudio.message('SystemArchitecture:studio:ProfileEditorMenuItem');
    schema.callback=@OpenProfileEditorCB;
    schema.state='Enabled';
    schema.autoDisableWhen='Locked';
end

function schema=ImportProfile(~)%#ok<DEFNU>
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:ProfImportMenuItem';
    schema.Label=DAStudio.message('SystemArchitecture:studio:ProfileImportMenuItem');
    schema.callback=@ZCStudio.ImportProfileCB;
end

function OpenProfileEditorCB(~)
    if systemcomposer.internal.profile.newEditor
        app=systemcomposer.internal.profile.app.ProfileEditorApp.getInstance();
        app.openStudio(0);
    else
        systemcomposer.internal.profile.Designer.launch
    end
end

function schema=LinkToModel(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:LinkToModelMenuItem';
    schema.Label=DAStudio.message('SystemArchitecture:studio:LinkToModelMenuItem');
    schema.callback=@LinkToModelCB;
    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);

    enableMenu=false;
    if~isempty(blocks)
        enableMenu=true;
        for idx=1:numel(blocks)
            block=blocks(idx);
            if(SLStudio.Utils.objectIsValidBlock(block))
                enableMenu=systemcomposer.internal.validator.ConversionUIValidator.canLinkToModel(block.handle);
            else
                enableMenu=false;
            end
        end
    end
    if enableMenu
        schema.state='Enabled';
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end

    schema.autoDisableWhen='Locked';
end

function LinkToModelCB(cbinfo,~)
    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    hdls={};
    for idx=1:numel(blocks)
        hdls{idx}=blocks(idx).handle;
    end
    systemcomposer.internal.saveAndLink.SaveAndLinkDialog.launch(hdls,3);
end

function schema=InlineModel(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:InlineModelMenuItem';
    schema.Label=DAStudio.message('SystemArchitecture:studio:InlineModelMenuItem');
    schema.callback=@InlineModelCB;
    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);

    enableMenu=false;
    if~isempty(blocks)
        enableMenu=true;
        for idx=1:numel(blocks)
            block=blocks(idx);
            if(SLStudio.Utils.objectIsValidBlock(block))




                enableMenu=systemcomposer.internal.validator.ConversionUIValidator.canInline(block.handle);
            end
        end
    end
    if enableMenu
        schema.state='Enabled';
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end

    schema.autoDisableWhen='Locked';
end

function InlineModelCB(cbinfo,~)


    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    hdls={};
    sfCompHdls={};
    for idx=1:numel(blocks)
        blkHandle=blocks(idx).handle;
        if systemcomposer.internal.isStateflowBehaviorComponent(blkHandle)
            sfCompHdls=[sfCompHdls,{blkHandle}];%#ok<AGROW>
        else
            hdls=[hdls,{blkHandle}];%#ok<AGROW>
        end
    end
    if~isempty(hdls)
        systemcomposer.internal.saveAndLink.SaveAndLinkDialog.launch(hdls,4);
    end
    if~isempty(sfCompHdls)
        systemcomposer.internal.saveAndLink.SaveAndLinkDialog.launch(sfCompHdls,5);
    end
end

function schema=SaveAsArchitectureModel(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:SaveAsArchitectureModelMenuItem';
    schema.Label=DAStudio.message('SystemArchitecture:studio:SaveAsArchitectureModelMenuItem');
    schema.callback=@SaveAsArchitectureModelCB;
    setSchemaSaveAsArchitecture(cbinfo,schema);
end

function SaveAsArchitectureModelCB(cbinfo,~)

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    hdls={};
    for idx=1:numel(blocks)
        hdls{idx}=blocks(idx).handle;
    end
    systemcomposer.internal.saveAndLink.SaveAndLinkDialog.launch(hdls,1);
end

function schema=CreateSoftwareArchitectureModel(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:CreateSoftwareArchitectureModelMenuItem';
    schema.Label=DAStudio.message('SystemArchitecture:studio:CreateSoftwareArchitectureModelMenuItem');
    schema.callback=@CreateSoftwareArchitectureModelCB;
    if Simulink.internal.isArchitectureModel(cbinfo,'Architecture')
        setSchemaSaveAsSoftwareArchitecture(cbinfo,schema);
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end
end

function CreateSoftwareArchitectureModelCB(cbinfo,~)
    import systemcomposer.internal.saveAndLink.SaveAndLinkDialog;



    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    SaveAndLinkDialog.launch({block.handle},SaveAndLinkDialog.CREATE_SOFTWARE_ARCHITECTURE);
end

function schema=CreateSimulinkBehavior(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:CreateSimulinkBehaviorMenuItem';
    schema.Label=DAStudio.message('SystemArchitecture:studio:CreateSimulinkBehaviorMenuItem');
    schema.callback=@CreateSimulinkBehaviorCB;
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);

    if(SLStudio.Utils.objectIsValidBlock(block))
        if systemcomposer.internal.validator.ConversionUIValidator.canCreateSimulinkBehavior(block.handle)
            schema.state='Enabled';
        else
            hideOrDisableMenuItem(cbinfo,schema);
        end
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end

    schema.autoDisableWhen='Locked';
end

function CreateSimulinkBehaviorCB(cbinfo,~)

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    hdls={};
    for idx=1:numel(blocks)
        hdls{idx}=blocks(idx).handle;
    end
    systemcomposer.internal.saveAndLink.SaveAndLinkDialog.launch(hdls,2);
end

function schema=CreateStateflowChartBehavior(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:CreateStateflowChartBehaviorMenuItem';
    schema.Label=DAStudio.message('SystemArchitecture:studio:CreateStateflowChartBehaviorMenuItem');
    schema.callback=@CreateStateflowChartBehaviorCB;
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);






    if Simulink.internal.isArchitectureModel(cbinfo,'Architecture')&&SLStudio.Utils.objectIsValidBlock(block)
        [allowed,~,haveLicense]=systemcomposer.internal.validator.ConversionUIValidator.canCreateStateflowBehavior(block.handle);
        if allowed
            if haveLicense
                schema.state='Enabled';
            else
                schema.state='Disabled';
            end
        else
            hideOrDisableMenuItem(cbinfo,schema);
        end
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end

    schema.autoDisableWhen='Locked';
end

function CreateStateflowChartBehaviorCB(cbinfo,~)



    pb=systemcomposer.internal.ProgressBar(DAStudio.message('SystemArchitecture:studio:PleaseWait'),[]);
    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    for idx=1:numel(blocks)
        compToChartImplConverter=systemcomposer.internal.arch.internal.ComponentToChartImplConverter(blocks(idx).handle);
        chartBlockHandle=compToChartImplConverter.convertComponentToChartImpl();%#ok<NASGU>
    end
    pb.setStatus(DAStudio.message('SystemArchitecture:studio:Complete'));
end

function schema=AddVariant(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:AddVariantMenuItem';
    schema.Label=DAStudio.message('SystemArchitecture:studio:AddVariantMenuItem');
    schema.callback=@AddVariantCB;
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);

    if(SLStudio.Utils.objectIsValidBlock(block))
        if systemcomposer.internal.validator.ConversionUIValidator.canAddVariant(block.handle)
            schema.state='Enabled';
        else
            hideOrDisableMenuItem(cbinfo,schema);
        end
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end

    schema.autoDisableWhen='Locked';
end

function AddVariantCB(cbinfo,~)



    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if systemcomposer.internal.isVariantComponent(block.handle)


        locAddVariantChoiceToVSS(block.handle,cbinfo);
    else

        vssHdl=systemcomposer.internal.arch.internal.convertComponentsToVariants(block.handle);


        locAddVariantChoiceToVSS(vssHdl,cbinfo);
    end
end

function newChoice=locAddVariantChoiceToVSS(vssHdl,cbinfo)

    newChoice=systemcomposer.internal.arch.internal.addChoicesToVariantComponent(vssHdl);
    choiceName=get_param(newChoice,'Name');


    app=cbinfo.studio.App;
    editor=app.getActiveEditor;
    editor.deliverInfoNotification('SystemArchitecture:NewVariantChoice',...
    DAStudio.message('SystemArchitecture:SaveAndLink:AddedVariantChoice',choiceName));


    do=diagram.resolver.resolve(newChoice);
    app.hiliteAndFadeObject(do,1000);
end

function schema=ApplySelectedInterface(cbinfo)

    bdName=get_param(cbinfo.studio.App.blockDiagramHandle,'Name');
    interfaces=systemcomposer.getSelectedInterfaces(bdName);
    archPort=systemcomposer.internal.getArchitecturePortFromCbinfo(cbinfo);
    archPortImpl=archPort.getImpl;

    schema=DAStudio.ActionSchema;

    if length(interfaces)==1
        try
            systemcomposer.architecture.model.design.ArchitecturePort.validateInterfaceCompatibility(...
            archPortImpl,interfaces{1});
            schema.Label=[DAStudio.message('SystemArchitecture:studio:ApplySelectedInterface')...
            ,': ',interfaces{1}.getName];
            if interfaces{1}==archPortImpl.getPortInterface
                schema.state='Hidden';
            else
                if systemcomposer.internal.isPortDeleteable(cbinfo)
                    schema.state='Enabled';
                else
                    schema.state='Disabled';
                end
            end
        catch
            schema.state='Hidden';
        end
    else
        schema.state='Hidden';
    end
    schema.tag='SystemComposer:ApplySelectedInterface';
    schema.callback=@ApplySelectedInterfaceCB;

    schema.autoDisableWhen='Locked';
end

function ApplySelectedInterfaceCB(cbinfo,~)

    bdName=get_param(cbinfo.studio.App.blockDiagramHandle,'Name');
    interfaces=systemcomposer.InterfaceEditor.SelectedInterfaces(bdName);
    archPort=systemcomposer.internal.getArchitecturePortFromCbinfo(cbinfo);


    interface=systemcomposer.internal.getWrapperForImpl(interfaces{1});
    archPort.setInterface(interface);
end

function schema=ApplyOwnedInterface(cbinfo)
    archPort=systemcomposer.internal.getArchitecturePortFromCbinfo(cbinfo);
    schema=DAStudio.ActionSchema;
    isAutosar=Simulink.internal.isArchitectureModel(cbinfo,'AUTOSARArchitecture');

    if cbinfo.selection.size>1||isAutosar
        schema.state='Hidden';
        return;
    end

    if~hasOwnedInterface(archPort)&&~isAdapterPort(archPort)
        if systemcomposer.internal.isPortDeleteable(cbinfo)
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    else
        schema.state='Hidden';
    end

    schema.Label=DAStudio.message('SystemArchitecture:studio:ApplyOwnedInterface');
    schema.tag='SystemComposer:ApplyOwnedInterface';
    schema.callback=@ApplyOwnedInterfaceCB;

    schema.autoDisableWhen='Locked';

    function tf=hasOwnedInterface(archPort)
        if~isempty(archPort.Interface)
            tf=archPort.Interface.Owner==archPort;
        else
            tf=false;
        end
    end
    function tf=isAdapterPort(archPort)
        tf=false;
        if~isempty(archPort.Parent)&&~isempty(archPort.Parent.Parent)...
            &&~systemcomposer.internal.isVariantComponent(archPort.Parent.Parent.SimulinkHandle)...
            &&archPort.Parent.Parent.IsAdapterComponent
            tf=true;
        end
    end
end

function ApplyOwnedInterfaceCB(cbinfo,~)
    archPort=systemcomposer.internal.getArchitecturePortFromCbinfo(cbinfo);

    systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.setOwnedInterface(archPort);
end

function schema=ClearInterface(cbinfo)
    archPort=systemcomposer.internal.getArchitecturePortFromCbinfo(cbinfo);
    schema=DAStudio.ActionSchema;

    if cbinfo.selection.size>1
        schema.state='Hidden';
        return;
    end

    if~isempty(archPort.InterfaceName)
        schema.Label=[DAStudio.message('SystemArchitecture:studio:ClearInterface')...
        ,': ',archPort.InterfaceName];
    else
        schema.Label=DAStudio.message('SystemArchitecture:studio:ClearInterface');
    end


    if isempty(archPort.Interface)
        schema.state='Hidden';
    else
        if systemcomposer.internal.isPortDeleteable(cbinfo)
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    end
    schema.tag='SystemComposer:ClearInterface';
    schema.callback=@ClearInterfaceCB;

    schema.autoDisableWhen='Locked';
end

function ClearInterfaceCB(cbinfo,~)
    archPort=systemcomposer.internal.getArchitecturePortFromCbinfo(cbinfo);

    archPort.setInterface('');
end

function schema=Delete(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:Delete';
    schema.label=DAStudio.message('SystemArchitecture:studio:Delete');
    schema.accelerator='delete';

    if systemcomposer.internal.isPortDeleteable(cbinfo)
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

    schema.callback=@DeleteCB;
end

function DeleteCB(cbinfo)
    if SFStudio.Utils.isTruthTable(cbinfo)
        subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
        Stateflow.TruthTable.TruthTableManager.deleteSelection(subviewerId);
    else
        cbinfo.domain.delete(cbinfo.isContextMenu);
    end
end

function schema=ConjugatePort(cbinfo)
    archPort=systemcomposer.internal.getArchitecturePortFromCbinfo(cbinfo);
    compPort=systemcomposer.internal.getComponentPortFromCbinfo(cbinfo);
    parentHandle=get_param(get_param(archPort.SimulinkHandle(1),'Parent'),'Handle');
    parentBlockType=systemcomposer.internal.validator.getComponentBlockType(parentHandle);
    isPhysicalPort=archPort.Direction==systemcomposer.arch.PortDirection.Physical;

    schema=DAStudio.ActionSchema;
    schema.Label=DAStudio.message('SystemArchitecture:studio:ConjugatePort');

    if cbinfo.selection.size>1
        schema.state='Hidden';
        return;
    end


    if parentBlockType.canConjugatePort&&~isPhysicalPort
        if~isempty(compPort)&&~compPort.Connected&&...
            systemcomposer.internal.isPortDeleteable(cbinfo)
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    else
        schema.state='Hidden';
    end

    schema.tag='SystemComposer:ConjugatePort';
    schema.callback=@ConjugatePortCB;

    schema.autoDisableWhen='Locked';
end

function ConjugatePortCB(cbinfo,~)
    archPort=systemcomposer.internal.getArchitecturePortFromCbinfo(cbinfo);
    systemcomposer.internal.arch.internal.conjugatePort(archPort);
end

function schema=ViewsMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='SystemComposer:ViewsMenu';
    schema.label=DAStudio.message('SystemArchitecture:studio:ViewsMenu');
    if Simulink.internal.isArchitectureModel(cbinfo,'Architecture')||...
        Simulink.internal.isArchitectureModel(cbinfo,'SoftwareArchitecture')
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('SystemComposer:OpenArchViews')...
    };
end

function schema=OpenArchViews(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='SystemComposer:OpenArchViews';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('SystemArchitecture:studio:OpenArchViewsMenuItem');
    end
    schema.callback=@OpenArchViewsCB;
    schema.autoDisableWhen='Locked';


    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='zcOpenArchitectureViews';
    end
end

function OpenArchViewsCB(cbinfo,~)
    bdH=cbinfo.studio.App.blockDiagramHandle;
    zcModel=systemcomposer.arch.Model(bdH);
    zcModel.openViews;
end

function schema=OpenAllocationEditor(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='SystemComposer:OpenAllocationEditor';
    schema.callback=@OpenAllocationEditorCB;
    schema.autoDisableWhen='Locked';


    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='zcOpenAllocationEditor';
    end
end

function OpenAllocationEditorCB(~,~)
    systemcomposer.allocation.editor;
end

function ShowAllocations(cbinfo,action)
    bd=cbinfo.studio.App.blockDiagramHandle;
    action.enabled=true;
    action.selected=strcmpi(get_param(bd,'ShowAllocations'),'on');
    action.setCallbackFromArray({@toggleShowAllocations,bd},dig.model.FunctionType.Action);
end

function toggleShowAllocations(bd,~)
    prevVal=get_param(bd,'ShowAllocations');
    if strcmpi(prevVal,'off')
        newVal='on';
    else
        newVal='off';
    end
    set_param(bd,'ShowAllocations',newVal);
end

function schema=OpenSpotlight(cbinfo)%#ok<DEFNU>   
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    schema=sl_action_schema;
    schema.tag='SystemComposer:OpenSpotlightMenuItem';


    isAUTOSARArchitectureModel=Simulink.internal.isArchitectureModel(cbinfo,'AUTOSARArchitecture');
    isCalledForAutosarCompositionBlock=isAUTOSARArchitectureModel&&...
    ~isempty(block)&&autosar.composition.Utils.isCompositionBlock(block.handle);
    if SLStudio.Utils.showInToolStrip(cbinfo)
        if isCalledForAutosarCompositionBlock
            schema.tooltip=DAStudio.message('SystemArchitecture:Toolstrip:SpotlightActionDescriptionForComposition');
        else
            schema.tooltip=DAStudio.message('SystemArchitecture:Toolstrip:SpotlightActionDescription');
        end
    else
        if isCalledForAutosarCompositionBlock
            schema.label=DAStudio.message('SystemArchitecture:studio:OpenSpotlightMenuItemForComposition');
        else
            schema.label=DAStudio.message('SystemArchitecture:studio:OpenSpotlightMenuItem');
        end
    end
    schema.callback=@OpenSpotlightCB;

    studioApp=cbinfo.studio.App;
    openFromSpotlight=studioApp.hasSpotlightView();



    if(openFromSpotlight)
        appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdroot(bdroot(cbinfo.studio.App.blockDiagramHandle)));
        block=[];
        studioTag=cbinfo.studio.getStudioTag();
        semElem=appMgr.getSelectedComponentInSpolightEditor(studioTag);
        if~isempty(semElem)
            try


                currentSpotlight=appMgr.getActiveSpotlight(studioTag);
                currentSourceBlkH=systemcomposer.utils.getSimulinkPeer(currentSpotlight.getSelectedComponent());
                slBlkH=systemcomposer.utils.getSimulinkPeer(semElem);
                if(slBlkH~=currentSourceBlkH)
                    block=get_param(slBlkH,'object');
                end
            catch
                block=[];
            end
        end
    end




    if dig.isProductInstalled('System Composer')&&...
        ~isempty(block)&&(systemcomposer.internal.isComponent(block.handle)||...
        (systemcomposer.internal.isReferenceComponent(block.handle)&&~systemcomposer.internal.isUnspecifiedReferenceComponent(block.handle)))
        schema.state='Enabled';
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end



    if isAUTOSARArchitectureModel&&~isempty(block)&&...
        ~(autosar.composition.Utils.isComponentBlock(block.handle)||...
        autosar.composition.Utils.isCompositionBlock(block.handle))
        hideOrDisableMenuItem(cbinfo,schema);
    end


    if SLStudio.Utils.showInToolStrip(cbinfo)
        if Simulink.internal.isArchitectureModel(cbinfo,'Architecture')||...
            Simulink.internal.isArchitectureModel(cbinfo,'SoftwareArchitecture')
            schema.icon='zcSpotlight';
        elseif Simulink.internal.isArchitectureModel(cbinfo,'AUTOSARArchitecture')
            schema.icon='autosarSpotlight';
        else
            schema.state='Disabled';
        end
    end

    schema.autoDisableWhen='Busy';
end

function OpenSpotlightCB(cbinfo)

    studioApp=cbinfo.studio.App;
    activeEditor=studioApp.getActiveEditor();
    selectedBlk=activeEditor.getPrimarySelection;

    openFromSpotlight=studioApp.hasSpotlightView();
    studioTag=cbinfo.studio.getStudioTag();
    createSpotlight(selectedBlk,studioTag,openFromSpotlight);
end

function createSpotlight(selectedBlk,studioTag,varargin)
    if~isempty(selectedBlk)
        blkHandle=selectedBlk(1).handle;
        appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdroot(blkHandle));

        if nargin>2
            openFromSpotlight=varargin{1};
        else
            openFromSpotlight=false;
        end

        if openFromSpotlight
            scComp=appMgr.getSelectedComponentInSpolightEditor(studioTag);
        else
            scComp=systemcomposer.utils.getArchitecturePeer(blkHandle);
        end


        if~isempty(scComp)
            systemcomposer.internal.arch.spotlight(appMgr,scComp,true,0,studioTag);
        end
    end
end

function schema=InterfaceEditorComponent(cbinfo)

    schema=sl_toggle_schema;
    schema.tag='SystemComposer:InterfaceEditorMenuItem';
    schema.label=DAStudio.message('SystemArchitecture:studio:InterfaceEditorMenuItem');
    schema.callback=@InterfaceEditorComponentCB;
    schema.state='Enabled';

    st=cbinfo.studio.getComponent('GLUE2:DDG Component','InterfaceEditor');
    if~isempty(st)&&cbinfo.studio.getComponent('GLUE2:DDG Component','InterfaceEditor').isVisible
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

end

function InterfaceEditorComponentCB(cbinfo,~)



    systemcomposer.createInterfaceEditorComponent(cbinfo.studio,true,true);
end

function schema=Instantiate(cbinfo)


    schema=sl_action_schema;
    schema.tag='SystemComposer:InstantiateMenuItem';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('SystemArchitecture:studio:InstantiateMenuItem');
    end
    schema.callback=@InstantiateCB;
    schema.state='Enabled';
    schema.autoDisableWhen='Locked';


    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='zcCreateAnalysisModel';
    end
end

function schema=OpenViewer(cbinfo)


    schema=sl_action_schema;
    schema.tag='SystemComposer:OpenViewerMenuItem';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('SystemArchitecture:studio:OpenViewerMenuItem');
    end
    schema.callback=@OpenViewerCB;
    schema.state='Enabled';
    schema.autoDisableWhen='Locked';


    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='zcOpenAnalysisViewer';
    end
end

function OpenViewerCB(cbinfo,~)

    appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdroot(cbinfo.studio.App.blockDiagramHandle));
    composition=appMgr.getTopLevelCompositionArchitecture;


    a=systemcomposer.arch.Architecture(composition);
    systemcomposer.analysis.openViewer('Source',a);

end

function InstantiateCB(cbinfo,~)

    appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdroot(cbinfo.studio.App.blockDiagramHandle));
    composition=appMgr.getTopLevelCompositionArchitecture;


    a=systemcomposer.arch.Architecture(composition);
    internal.systemcomposer.Instantiator.launch(a);

end

function schema=ConvertToSharedInterface(cbinfo)

    schema=DAStudio.ActionSchema;
    schema.tag='SystemComposer:ConvertToSharedInterfaceMenuItem';
    schema.Label=DAStudio.message('SystemArchitecture:studio:ConvertToSharedInterfaceMenuItem');
    schema.callback=@ConvertToSharedInterfaceCB;
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    selectionHandle=block.handle;
    allowedTypes={'Inport','Outport','In Port','Out Port'};

    if~isempty(selectionHandle)&&selectionHandle~=-1&&any(strcmp(block.type,allowedTypes))
        zcPort=systemcomposer.utils.getArchitecturePeer(selectionHandle);
        if~isempty(zcPort)
            if zcPort.isComponentPort
                zcPort=zcPort.getArchitecturePort();
            end
            archPort=systemcomposer.internal.getWrapperForImpl(zcPort);
            inportOrOutport=(archPort.Direction==systemcomposer.arch.PortDirection.Input||...
            archPort.Direction==systemcomposer.arch.PortDirection.Output);
            if inportOrOutport&&archPort.hasAnonymousInterface()
                schema.state='Enabled';
            else
                hideOrDisableMenuItem(cbinfo,schema);
            end
        end
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end

    schema.autoDisableWhen='Locked';
end

function ConvertToSharedInterfaceCB(cbinfo,~)

    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    selectionHandle=block.handle;
    allowedTypes={'Inport','Outport','In Port','Out Port'};

    if~isempty(selectionHandle)&&selectionHandle~=-1&&any(strcmp(block.type,allowedTypes))
        zcPort=systemcomposer.utils.getArchitecturePeer(selectionHandle);
        if~isempty(zcPort)
            if zcPort.isComponentPort
                zcPort=zcPort.getArchitecturePort();
            end
            archPort=systemcomposer.internal.getWrapperForImpl(zcPort);
            if archPort.hasAnonymousInterface()

                title=DAStudio.message('SystemArchitecture:studio:ConvertToSharedInterfaceDlgTitle');
                prompt=DAStudio.message('SystemArchitecture:studio:ConvertToSharedInterfaceDlgPrompt');
                defaultAnswer={archPort.Name};
                numLines=1;
                answer=inputdlg(prompt,title,numLines,defaultAnswer);
                newInterfaceName=answer{numLines};


                archPort.makeOwnedInterfaceShared(newInterfaceName);
            end
        end
    end
end


function hideOrDisableMenuItem(cbinfo,schema)





    if cbinfo.isContextMenu
        schema.state='Hidden';
    else
        schema.state='Disabled';
    end
end

function setSchemaSaveAsArchitecture(cbinfo,schema)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);

    if(SLStudio.Utils.objectIsValidBlock(block))
        if systemcomposer.internal.validator.ConversionUIValidator.canSaveAsArchitecture(block.handle)
            schema.state='Enabled';
        else
            hideOrDisableMenuItem(cbinfo,schema);
        end
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end
    schema.autoDisableWhen='Locked';
end

function setSchemaSaveAsSoftwareArchitecture(cbinfo,schema)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);

    if(SLStudio.Utils.objectIsValidBlock(block))
        if systemcomposer.internal.validator.ConversionUIValidator.canSaveAsSoftwareArchitecture(block.handle)
            schema.state='Enabled';
        else
            hideOrDisableMenuItem(cbinfo,schema);
        end
    else
        hideOrDisableMenuItem(cbinfo,schema);
    end
    schema.autoDisableWhen='Locked';
end



