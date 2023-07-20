function schema=LibraryLinkMenu(fncname,cbinfo,eventData)



    fnc=str2func(fncname);
    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function[handle,isGraphH]=loc_getGraphOrBlockHandle(cbinfo)
    handle=[];
    isGraphH=true;

    selection=cbinfo.selection;
    if selection.size<=1
        if selection.size==1
            target=selection.at(1);
            if~isempty(target)&&isvalid(target)
                if isa(target,'SLM3I.Block')
                    handle=target.handle;
                    isGraphH=false;
                elseif isa(target,'StateflowDI.State')
                    if target.isExternalComponent
                        handle=SFStudio.Utils.getSLHandleForObjectInEditor(target,cbinfo.studio.App.getActiveEditor);
                        isGraphH=false;
                    end
                end
            end
        else

            targetObj=cbinfo.uiObject;
            if isa(targetObj,'Simulink.BlockDiagram')||isa(targetObj,'Simulink.SubSystem')
                handle=targetObj.handle;
            elseif isa(targetObj,'Stateflow.Chart')||isa(targetObj,'Stateflow.StateTransitionTableChart')
                editor=cbinfo.studio.App.getActiveEditor;
                handle=SLM3I.SLCommonDomain.getSLHandleForHID(editor.getHierarchyId());
                isGraphH=true;
            end
        end
    end
end

function[enabled,fromLockedLibrary]=loc_isGotoLibraryLinkEnabled(cbinfo)
    [handle,isGraphH]=loc_getGraphOrBlockHandle(cbinfo);

    if~isempty(handle)&&ishandle(handle)&&handle>0
        [enabled,fromLockedLibrary]=slInternal('isGotoLibraryLinkEnabled',handle,isGraphH);
    else
        enabled=false;
        fromLockedLibrary=false;
    end
end

function schema=LibraryLinkMenuImpl(cbinfo)%#ok<*DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:LibraryLinkMenu';


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:GoToLibraryBlock'),...
    im.getAction('Simulink:PushLibraryLink'),...
    im.getAction('Simulink:RestoreLibraryLink'),...
    im.getAction('Simulink:DisableLibraryLink'),...
    'separator',...
    im.getAction('Simulink:LibraryLinkManager')
    };

    schema.autoDisableWhen='Busy';


    schema.state='Disabled';

    [enabled,fromLockedLibrary]=loc_isGotoLibraryLinkEnabled(cbinfo);

    if enabled
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    if fromLockedLibrary
        schema.label=DAStudio.message('Simulink:studio:LockedLibraryLinkMenu');
    else
        schema.label=DAStudio.message('Simulink:studio:LibraryLinkMenu');
    end

end

function schema=GoToLibraryBlock(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:GoToLibraryBlock';
    schema.accelerator='Ctrl+L';
    schema.obsoleteTags={'Simulink:GoToLibraryLink'};
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:goToLibraryBlockActionLabel';
        schema.icon='libraryOpen';
    else
        schema.label=DAStudio.message('Simulink:studio:GoToLibraryBlock');
    end
    schema.autoDisableWhen='Busy';

    [enabled,~]=loc_isGotoLibraryLinkEnabled(cbinfo);
    if enabled
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    schema.callback=@GoToLibraryBlockCB;
end

function GoToLibraryBlockCB(cbinfo)
    [handle,isGraphH]=loc_getGraphOrBlockHandle(cbinfo);
    if~isempty(handle)&&ishandle(handle)&&handle>0
        slInternal('gotoLibraryLink',handle,isGraphH);
    end
end


function[enabled,inactiveLink,fromLockedLibrary]=loc_isDisableOrBlreakLibraryLinkEnabled(cbinfo)
    [handle,isGraphH]=loc_getGraphOrBlockHandle(cbinfo);

    if~isempty(handle)&&ishandle(handle)&&handle>0
        [~,fromLockedLibrary]=slInternal('isGotoLibraryLinkEnabled',handle,isGraphH);
        [enabled,inactiveLink]=slInternal('isDisableOrBreakLibraryLinkEnabled',handle,isGraphH);
    else
        enabled=false;
        inactiveLink=false;
        fromLockedLibrary=false;
    end
end

function schema=DisableOrBreakLibraryLink(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DisableLibraryLink';
    schema.obsoleteTags={'Simulink:BreakLibraryLink'};
    tooltipResourcePath='simulink_ui:studio:resources:disableLibraryLinkActionDescription';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:disableLibraryLinkActionLabel';
        schema.icon='libraryDisableLink';
        schema.tooltip=tooltipResourcePath;
    else
        schema.label=DAStudio.message('Simulink:studio:DisableLibraryLink');
        schema.tooltip=DAStudio.message(tooltipResourcePath);
    end
    schema.autoDisableWhen='Busy';

    [enabled,inactiveLink,fromLockedLibrary]=loc_isDisableOrBlreakLibraryLinkEnabled(cbinfo);

    if enabled
        schema.state='Enabled';
        tooltipResourcePath='simulink_ui:studio:resources:breakLibraryLinkActionDescription';
        if inactiveLink
            if SLStudio.Utils.showInToolStrip(cbinfo)
                schema.label='simulink_ui:studio:resources:breakLibraryLinkActionLabel';
                schema.tooltip=tooltipResourcePath;
            else
                schema.label=DAStudio.message('Simulink:studio:BreakLibraryLink');
                schema.tooltip=DAStudio.message(tooltipResourcePath);
            end
        end
    else
        schema.state='Disabled';
        if fromLockedLibrary
            if SLStudio.Utils.showInToolStrip(cbinfo)
                schema.label='simulink_ui:studio:resources:disableLockedLibraryLinkActionLabel';
            else
                schema.label=DAStudio.message('Simulink:studio:DisableLockedLibraryLink');
            end
        end
    end
    schema.callback=@DisableOrBreakLibraryLinkItemCB;
end

function schema=DisableOrRestoreLibraryLink(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DisableorRestoreLibraryLink';
    schema.obsoleteTags={'Simulink:RestoreLibraryLink'};

    schema.autoDisableWhen='Busy';

    [enabled,inactiveLink,fromLockedLibrary]=loc_isDisableOrBlreakLibraryLinkEnabled(cbinfo);

    if inactiveLink
        schema.state='Enabled';
        schema.icon='restoreLibraryLink';
        schema.callback=@RestoreLibraryLinkItemCB;
        tooltipResourcePath='simulink_ui:studio:resources:restoreLinksActionDescription';

        if SLStudio.Utils.showInToolStrip(cbinfo)
            schema.label='simulink_ui:studio:resources:restoreLinksActionLabel';
            schema.tooltip=tooltipResourcePath;
        else
            schema.label=DAStudio.message('Simulink:studio:RestoreLibraryLink');
            schema.tooltip=DAStudio.message(tooltipResourcePath);
        end
    else
        schema.icon='libraryDisableLink';
        schema.callback=@DisableOrBreakLibraryLinkItemCB;
        if enabled
            schema.state='Enabled';
            tooltipResourcePath='simulink_ui:studio:resources:disableLibraryLinkActionDescription';
            if SLStudio.Utils.showInToolStrip(cbinfo)
                schema.label='simulink_ui:studio:resources:disableLibraryLinkActionLabel';
                schema.tooltip=tooltipResourcePath;
            else
                schema.label=DAStudio.message('Simulink:studio:DisableLibraryLink');
                schema.tooltip=DAStudio.message(tooltipResourcePath);

            end
        else
            schema.state='Disabled';
            tooltipResourcePath='simulink_ui:studio:resources:disableLibraryLinkActionDescription';
            schema.tooltip=tooltipResourcePath;
            if fromLockedLibrary
                if SLStudio.Utils.showInToolStrip(cbinfo)
                    schema.label='simulink_ui:studio:resources:disableLockedLibraryLinkActionLabel';
                else
                    schema.label=DAStudio.message('Simulink:studio:DisableLockedLibraryLink');
                end
            end
        end
    end

end

function schema=BreakLibraryLink(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:BreakLibraryLink';
    schema.obsoleteTags={'Simulink:BreakLibraryLink'};
    schema.callback=@DisableOrBreakLibraryLinkItemCB;
    tooltipResourcePath='simulink_ui:studio:resources:breakLibraryLinkActionDescription';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:breakLibraryLinkActionLabel';
        schema.icon='libraryDisableLink';
        schema.tooltip=tooltipResourcePath;
    else
        schema.label=DAStudio.message('Simulink:studio:BreakLibraryLink');
        schema.tooltip=DAStudio.message(tooltipResourcePath);
    end
    schema.autoDisableWhen='Busy';

    [enabled,inactiveLink,~]=loc_isDisableOrBlreakLibraryLinkEnabled(cbinfo);

    if enabled
        tooltipResourcePath='simulink_ui:studio:resources:breakLibraryLinkActionDescription';
        if inactiveLink
            schema.state='Enabled';
            if SLStudio.Utils.showInToolStrip(cbinfo)
                schema.label='simulink_ui:studio:resources:breakLibraryLinkActionLabel';
                schema.tooltip=tooltipResourcePath;
            else
                schema.label=DAStudio.message('Simulink:studio:BreakLibraryLink');
                schema.tooltip=DAStudio.message(tooltipResourcePath);
            end
        else
            schema.state='Disabled';
        end
    end

end


function DisableOrBreakLibraryLinkItemCB(cbinfo)
    [handle,isGraphH]=loc_getGraphOrBlockHandle(cbinfo);
    if~isempty(handle)&&ishandle(handle)&&handle>0
        slInternal('disableOrBreakLibraryLink',handle,isGraphH);
    end
end

function enabled=loc_isRestoreLibraryLinkEnabled(cbinfo)
    enabled=false;
    [handle,isGraphH]=loc_getGraphOrBlockHandle(cbinfo);
    if~isempty(handle)&&ishandle(handle)&&handle>0

        enabled=slInternal('isRestoreLibraryLinkEnabled',handle,isGraphH);
    end
end

function schema=RestoreLibraryLink(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:RestoreLibraryLink';
    tooltipResourcePath='simulink_ui:studio:resources:restoreLinksActionDescription';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:RestoreLibraryLink');
        schema.tooltip=DAStudio.message(tooltipResourcePath);
    else
        schema.icon='restoreLibraryLink';
        schema.tooltip=tooltipResourcePath;
    end
    schema.obsoleteTags={'Simulink:RestoreLibraryLink'};
    schema.autoDisableWhen='Busy';


    enabled=loc_isRestoreLibraryLinkEnabled(cbinfo);

    if enabled
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.callback=@RestoreLibraryLinkItemCB;
end

function schema=PushLibraryLink(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:PushLibraryLink';
    tooltipResourcePath='simulink_ui:studio:resources:pushLinksActionDescription';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:PushLibraryLink');
        schema.tooltip=DAStudio.message(tooltipResourcePath);
    else
        schema.icon='pushLibraryLink';
        schema.tooltip=tooltipResourcePath;
    end
    schema.obsoleteTags={'Simulink:RestoreLibraryLink'};
    schema.autoDisableWhen='Busy';


    enabled=loc_isRestoreLibraryLinkEnabled(cbinfo);

    if enabled
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.callback=@PushLibraryLinkItemCB;
end

function RestoreLibraryLinkItemCB(cbinfo)
    [handle,isGraphH]=loc_getGraphOrBlockHandle(cbinfo);
    if~isempty(handle)&&ishandle(handle)&&handle>0
        set_param(handle,'LinkStatus','restore');
    end
end

function PushLibraryLinkItemCB(cbinfo)
    [handle,isGraphH]=loc_getGraphOrBlockHandle(cbinfo);
    if~isempty(handle)&&ishandle(handle)&&handle>0
        set_param(handle,'LinkStatus','propagate');
    end
end

function schema=openLibraryLinkManager(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:LibraryLinkManager';
    tooltipResourcePath='simulink_ui:studio:resources:libraryLinkManagerActionDescription';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibraryLinkManagerTool');
        schema.tooltip=DAStudio.message(tooltipResourcePath);
    else
        schema.icon='libraryLinkManagerTool';
        schema.tooltip=tooltipResourcePath;
    end

    schema.obsoleteTags={'Simulink:RestoreLibraryLink'};
    schema.autoDisableWhen='Busy';
    schema.state='Enabled';
    schema.callback=@OpenLibraryLinkManagerCB;
end

function OpenLibraryLinkManagerCB(cbinfo)
    [handle,isGraphH]=loc_getGraphOrBlockHandle(cbinfo);
    if~isempty(handle)&&ishandle(handle)&&handle>0
        blockFullName=getfullname(handle);
        splitContents=strsplit(blockFullName,'/');
        editedlinkstool('Create',splitContents{1});
    end
end


