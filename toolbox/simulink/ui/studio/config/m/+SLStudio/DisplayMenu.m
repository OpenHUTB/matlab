function schema=DisplayMenu(fncname,cbinfo,eventData)




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

function schema=LibraryLinkDisplayMenuDisabled(~)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:LibraryLinkDisplayMenu';
    schema.state='Disabled';
    schema.label=DAStudio.message('Simulink:studio:LibraryLinkDisplayMenu');
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=LibraryLinkDisplayMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:LibraryLinkDisplayMenu';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:LibraryLinkDisplayMenuContext');
    else
        schema.label=DAStudio.message('Simulink:studio:LibraryLinkDisplayMenu');
    end


    children={@LibraryLinksNone,...
    @LibraryLinksDisabled,...
    @LibraryLinksUser,...
    @LibraryLinksAll
    };

    schema.childrenFcns=children;

    schema.autoDisableWhen='Never';
end

function schema=DisplayModelInterfaceMenu(cbinfo)%#ok<DEFNU>

    schema=sl_toggle_schema;
    schema.tag='Simulink:DisplayModelInterfaceMenu';
    isInterfaceDomain=isa(cbinfo.domain,'InterfaceEditor.InterfaceEditorDomain');

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='interface';
    else
        schema.label=DAStudio.message('Simulink:InterfaceEditor:DisplayMenu');
    end

    canView=false;
    if isa(cbinfo.uiObject,'Simulink.BlockDiagram')||isa(cbinfo.uiObject,'Simulink.SubSystem')
        handle=cbinfo.uiObject.handle;

        if isnumeric(handle)
            canView=SLM3I.SLDomain.canInterfaceBeViewed(handle);
        end
    end
    if(~canView||SLStudio.Utils.isSimulationRunning(cbinfo))
        schema.state='Disabled';
    end

    if isInterfaceDomain
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.refreshCategories={'GenericEvent:Never'};
    schema.callback=@DisplayModelInterfaceMenuCB;
    schema.autoDisableWhen='Busy';
    if(slfeature('SlInterfaceViewMenu')<1)
        schema.state='Hidden';
    end
end

function DisplayModelInterfaceMenuCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    isInterfaceDomain=isa(cbinfo.domain,'InterfaceEditor.InterfaceEditorDomain');
    SLM3I.SLDomain.toggleInterfaceView(isInterfaceDomain,editor,cbinfo.uiObject.handle);
end


function schema=DisplaySimulinkFunctionConnectors(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:DisplaySimulinkFunctionConnectors';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:FunctionConnectors');
    else
        schema.icon='functionConnectors';
    end
    schema.callback=@DisplaySimulinkFunctionConnectorsCB;
    schema.autoDisableWhen='Busy';

    if(slfeature('VisualizeFunctionConnectors')<1)
        schema.state='Hidden';
    else
        schema.state='Enabled';
    end

    if(strcmp(get_param(cbinfo.editorModel.Name,'FunctionConnectors'),'on'))
        schema.userdata='On';
        schema.check='Checked';
    else
        schema.userdata='Off';
        schema.check='Unchecked';
    end
end

function DisplaySimulinkFunctionConnectorsCB(cbinfo,eventData)%#ok<INUSD>
    if(strcmp(cbinfo.userdata,'On'))

        set_param(cbinfo.editorModel.Name,'FunctionConnectors',0);
        Simulink.functionConnectorMenu(cbinfo.editorModel.handle,false);
    else

        set_param(cbinfo.editorModel.Name,'FunctionConnectors',1);
        Simulink.functionConnectorMenu(cbinfo.editorModel.handle,true);
    end
end


function schema=DisplayScheduleConnectors(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:DisplayScheduleConnectors';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ScheduleConnectors');
    else
        schema.icon='scheduleConnectors';
    end
    schema.callback=@DisplayScheduleConnectorsCB;
    schema.autoDisableWhen='Busy';

    schema.state='Enabled';

    if(strcmp(get_param(cbinfo.editorModel.Name,'ScheduleConnectors'),'on'))
        schema.userdata='On';
        schema.check='Checked';
    else
        schema.userdata='Off';
        schema.check='Unchecked';
    end
end

function DisplayScheduleConnectorsCB(cbinfo,eventData)%#ok<INUSD>
    if(strcmp(cbinfo.userdata,'On'))

        set_param(cbinfo.editorModel.Name,'ScheduleConnectors',0);

    else

        set_param(cbinfo.editorModel.Name,'ScheduleConnectors',1);

    end
end

function schema=DisplayGeneralConnectors(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:DisplayGeneralConnectors';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:GeneralConnectors');
    else
        schema.icon='dataStoreConnectors';
    end
    schema.callback=@GeneralConnectorsCB;
    schema.autoDisableWhen='Busy';

    if(slfeature('GeneralConnector')<1)
        schema.state='Hidden';
    else
        schema.state='Enabled';
    end


    if(strcmp(get_param(cbinfo.editorModel.Name,'GeneralConnectorDisplay'),'on'))
        schema.userdata='On';
        schema.check='Checked';
    else
        schema.userdata='Off';
        schema.check='Unchecked';
    end
end


function GeneralConnectorsCB(cbinfo,eventData)%#ok<INUSD>
    st=cbinfo.studio;
    if(strcmp(cbinfo.userdata,'On'))

        set_param(cbinfo.editorModel.Name,'GeneralConnectorDisplay',0);
    else

        set_param(cbinfo.editorModel.Name,'GeneralConnectorDisplay',1);
        Simulink.STOSpreadSheet.Connectors.launchConnectorsViewer(st);
    end
end


function schema=LibraryLinksNone(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:LibraryLinksNone';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibraryLinksNone');
    else
        schema.icon='libraryLinkHidden';
    end
    schema.userdata='none';
    schema.callback=@SetLibraryLinksDisplayCB;
    schema.checked=loc_LibraryLinksDisplayCheck(cbinfo,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=LibraryLinksDisabled(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:LibraryLinksDisabled';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibraryLinksDisabled');
    else
        schema.icon='libraryLinkDisabled';
    end
    schema.userdata='disabled';
    schema.callback=@SetLibraryLinksDisplayCB;
    schema.checked=loc_LibraryLinksDisplayCheck(cbinfo,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=LibraryLinksUser(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:LibraryLinksUser';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibraryLinksUser');
    else
        schema.icon='libraryLinkCustom';
    end
    schema.userdata='user';
    schema.callback=@SetLibraryLinksDisplayCB;
    schema.checked=loc_LibraryLinksDisplayCheck(cbinfo,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=LibraryLinksAll(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:LibraryLinksAll';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibraryLinksAll');
    else
        schema.icon='libraryLinkRegular';
    end
    schema.userdata='all';
    schema.callback=@SetLibraryLinksDisplayCB;
    schema.checked=loc_LibraryLinksDisplayCheck(cbinfo,schema.userdata);

    schema.autoDisableWhen='Never';
end

function val=loc_LibraryLinksDisplayCheck(cbinfo,state)
    val='Unchecked';
    oldstate=get_param(cbinfo.editorModel.handle,'LibraryLinkDisplay');
    if strcmpi(oldstate,state)
        val='Checked';
    end
end

function SetLibraryLinksDisplayCB(cbinfo,eventData)
    mode=0;
    switch cbinfo.userdata
    case 'all'
        mode=3;
    case 'user'
        mode=2;
    case 'disabled'
        mode=1;
    case 'none'
        mode=0;
    end
    if~SLStudio.Utils.showInToolStrip(cbinfo)||nargin<2||eventData
        slInternal('setLibraryLinksDisplayMode',cbinfo.editorModel.handle,mode);
    end
end

function schema=SampleTimeMenuDisabled(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:SampleTimeDisplayMenu';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:SampleTimeDisplayMenuContext');
    else
        schema.label=DAStudio.message('Simulink:studio:SampleTimeDisplayMenu');
    end
    schema.state='Disabled';
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=SampleTimeMenu(cbinfo)%#ok<DEFNU> 
    schema=SampleTimeMenuDisabled(cbinfo);

    stateFcns={@loc_getSampleTimeMenuItemState,@loc_getSampleTimeLegendState};
    schema.state=SLStudio.Utils.checkChildrenState(cbinfo,stateFcns);


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:SampleTimeDisplayAll'),...
    im.getAction('Simulink:SampleTimeDisplayAnnotations'),...
    im.getAction('Simulink:SampleTimeDisplayColor'),...
    im.getAction('Simulink:SampleTimeDisplayNone'),...
    'separator',...
    im.getAction('Simulink:SampleTimeLegend')
    };

    schema.autoDisableWhen='Never';
end

function schema=SampleTimeDisplayAll(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:SampleTimeDisplayAll';
    schema.label=DAStudio.message('Simulink:studio:SampleTimeDisplayAll');
    schema.userdata='all';
    schema.callback=@SetSampleTimeDisplayCB;
    if loc_isTsDisplayChecked(cbinfo,'all')
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.state=loc_getSampleTimeMenuItemState(cbinfo);
    schema.autoDisableWhen='Never';
end

function schema=SampleTimeDisplayAnnotations(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='sampleTimeText';
    else
        schema.tag='Simulink:SampleTimeDisplayAnnotations';
        schema.label=DAStudio.message('Simulink:studio:SampleTimeDisplayAnnotations');
    end

    schema.userdata='annotations';
    schema.callback=@SetSampleTimeDisplayCB;

    if loc_isTsDisplayChecked(cbinfo,'annotations')
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.state=loc_getSampleTimeMenuItemState(cbinfo);
    schema.autoDisableWhen='Never';
end

function schema=SampleTimeDisplayColor(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='sampleTimeColors';
    else
        schema.tag='Simulink:SampleTimeDisplayColor';
        schema.label=DAStudio.message('Simulink:studio:SampleTimeDisplayColor');
    end

    schema.userdata='colors';
    schema.callback=@SetSampleTimeDisplayCB;

    if loc_isTsDisplayChecked(cbinfo,'colors')
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.state=loc_getSampleTimeMenuItemState(cbinfo);
    schema.autoDisableWhen='Never';
end

function schema=SampleTimeDisplayNone(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:SampleTimeDisplayNone';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SampleTimeDisplayNone');
    schema.userdata='none';
    schema.callback=@SetSampleTimeDisplayCB;
    if loc_isTsDisplayChecked(cbinfo,'none')
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.state=loc_getSampleTimeMenuItemState(cbinfo);
    schema.autoDisableWhen='Never';
end

function state=loc_getSampleTimeLegendState(cbinfo)
    if strcmp(get_param(cbinfo.editorModel.Name,'SampleTimesAreReady'),'on')
        state='Enabled';
    else
        state='Disabled';
    end
end

function schema=SampleTimeLegend(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='sampleTimeLegend';
    else
        schema.tag='Simulink:SampleTimeLegend';
        schema.label=DAStudio.message('Simulink:studio:TimingLegend');
    end

    schema.accelerator='Ctrl+J';
    schema.callback=@OpenSampleTimeLegendCB;

    schema.state=loc_getSampleTimeLegendState(cbinfo);

    schema.autoDisableWhen='Never';
end

function state=loc_getSampleTimeMenuItemState(cbinfo)
    state='Disabled';
    if~cbinfo.editorModel.isLibrary&&~Simulink.harness.internal.hasActiveHarness(cbinfo.editorModel.Name)
        state='Enabled';
    end
end

function checkedVal=loc_isTsDisplayChecked(cbinfo,choice)
    sampleTimeStylingFeatureValue=slfeature('SampleTimeStyling');
    topModelName=cbinfo.model.Name;

    modelName=cbinfo.editorModel.Name;
    if sampleTimeStylingFeatureValue==1
        colorsOn=strcmp(get_param(topModelName,'SampleTimeColors'),'on');
    else
        colorsOn=strcmp(get_param(modelName,'SampleTimeColors'),'on');
    end

    if sampleTimeStylingFeatureValue==1
        annotationsOn=strcmp(get_param(topModelName,'SampleTimeAnnotations'),'on');
    else
        annotationsOn=strcmp(get_param(modelName,'SampleTimeAnnotations'),'on');
    end

    if~SLStudio.Utils.showInToolStrip(cbinfo)
        if(colorsOn)
            if(annotationsOn)
                if(strcmp(choice,'all'))
                    checkedVal=true;
                else
                    checkedVal=false;
                end
            else
                if(strcmp(choice,'colors'))
                    checkedVal=true;
                else
                    checkedVal=false;
                end
            end
        else
            if(annotationsOn)
                if(strcmp(choice,'annotations'))
                    checkedVal=true;
                else
                    checkedVal=false;
                end
            else
                if(strcmp(choice,'none'))
                    checkedVal=true;
                else
                    checkedVal=false;
                end
            end
        end
    else
        if strcmp(choice,'colors')
            checkedVal=colorsOn;
        elseif strcmpi(choice,'annotations')
            checkedVal=annotationsOn;
        elseif strcmpi(choice,'all')
            checkedVal=colorsOn&&annotationsOn;
        else
            checkedVal=~colorsOn&&~annotationsOn;
        end
    end
end

function SetSampleTimeDisplayCB(cbinfo,eventData)%#ok<INUSD>
    value=cbinfo.userdata;
    colorsOn=false;
    annotationsOn=false;

    sampleTimeStylingFeatureValue=slfeature('SampleTimeStyling');
    topModelName=cbinfo.model.Name;
    modelName=cbinfo.editorModel.Name;

    if SLStudio.Utils.showInToolStrip(cbinfo)


        if strcmp(value,'colors')
            if sampleTimeStylingFeatureValue==1&&strcmp(get_param(topModelName,'SampleTimeColors'),'on')
                colorsOn=false;
            elseif sampleTimeStylingFeatureValue==0&&strcmp(get_param(modelName,'SampleTimeColors'),'on')
                colorsOn=false;
            else
                colorsOn=true;
            end
            if sampleTimeStylingFeatureValue==1&&strcmp(get_param(topModelName,'SampleTimeAnnotations'),'on')
                annotationsOn=true;
            elseif sampleTimeStylingFeatureValue==0&&strcmp(get_param(modelName,'SampleTimeAnnotations'),'on')
                annotationsOn=true;
            else
                annotationsOn=false;
            end
        elseif strcmp(value,'annotations')
            if sampleTimeStylingFeatureValue==1&&strcmp(get_param(topModelName,'SampleTimeColors'),'on')
                colorsOn=true;
            elseif sampleTimeStylingFeatureValue==0&&strcmp(get_param(modelName,'SampleTimeColors'),'on')
                colorsOn=true;
            else
                colorsOn=false;
            end
            if sampleTimeStylingFeatureValue==1&&strcmp(get_param(topModelName,'SampleTimeAnnotations'),'on')
                annotationsOn=false;
            elseif sampleTimeStylingFeatureValue==0&&strcmp(get_param(modelName,'SampleTimeAnnotations'),'on')
                annotationsOn=false;
            else
                annotationsOn=true;
            end
        elseif strcmp(value,'all')
            colorsOn=true;
            annotationsOn=true;
        end
    end

    if strcmp(value,'none')
        if sampleTimeStylingFeatureValue==1
            set_param(topModelName,'SampleTimeColors','off');
        else
            set_param(modelName,'SampleTimeColors','off');
        end

        if sampleTimeStylingFeatureValue==1
            set_param(topModelName,'SampleTimeAnnotations','off');
        else
            set_param(modelName,'SampleTimeAnnotations','off');
        end

        if sampleTimeStylingFeatureValue==1
            set_param(topModelName,'UpdateForSampleTimeDisplayChange','on');
        else
            set_param(modelName,'UpdateForSampleTimeDisplayChange','on');
        end

        obj=Simulink.SampleTimeLegend;
        obj.removeColorAnnotation(modelName);
        simulink.timinglegend.internal.TimingLegendManager.removeLegend(...
        get_param(modelName,'handle'));
    else
        if~SLStudio.Utils.showInToolStrip(cbinfo)
            if strcmp(value,'colors')
                colorsOn=true;
            elseif strcmp(value,'annotations')
                annotationsOn=true;
            elseif strcmp(value,'all')
                colorsOn=true;
                annotationsOn=true;
            end
        end

        if colorsOn
            if sampleTimeStylingFeatureValue==1
                set_param(topModelName,'SampleTimeColors','on');
            else
                set_param(modelName,'SampleTimeColors','on');
            end
        else
            if sampleTimeStylingFeatureValue==1
                set_param(topModelName,'SampleTimeColors','off');
            else
                set_param(modelName,'SampleTimeColors','off');
            end
        end

        if annotationsOn
            if sampleTimeStylingFeatureValue==1
                set_param(topModelName,'SampleTimeAnnotations','on');
            else
                set_param(modelName,'SampleTimeAnnotations','on');
            end
        else
            if sampleTimeStylingFeatureValue==1
                set_param(topModelName,'SampleTimeAnnotations','off');
            else
                set_param(modelName,'SampleTimeAnnotations','off');
            end
        end

        if sampleTimeStylingFeatureValue==1
            set_param(topModelName,'UpdateForSampleTimeDisplayChange','on');
        else
            set_param(modelName,'UpdateForSampleTimeDisplayChange','on');
        end


        if(strcmp(get_param(0,'OpenLegendWhenChangingSampleTimeDisplay'),'on'))


            if SLStudio.Utils.showInToolStrip(cbinfo)&&...
                strcmp(value,'colors')&&~colorsOn||...
                strcmp(value,'annotations')&&~annotationsOn
                return;
            end
            OpenSampleTimeLegendCB(cbinfo);
        end
    end
end

function OpenSampleTimeLegendCB(cbinfo)
    topModelName=cbinfo.model.Name;
    currentModelName=cbinfo.editorModel.Name;

    if(slfeature('RefactorTimingVisualization')>0)
        legend=simulink.timinglegend.internal.TimingLegendManager.getLegend(...
        get_param(topModelName,'handle'));
        legend.show();
    else
        if(strcmp(get_param(currentModelName,'SampleTimesAreReady'),'on'))
            obj=Simulink.SampleTimeLegend;
            tab_cont=strmatch(topModelName,obj.modelList,'exact');
            if(isempty(tab_cont))
                obj.addModel(topModelName);
                tab_cont=strmatch(topModelName,obj.modelList,'exact');
                tab_cont=tab_cont(1);
            end
            obj.studio{tab_cont(1)}=cbinfo.studio;
            obj.showLegend(topModelName);
        end
    end
end

function schema=BlocksDisplayMenuDisabled(~)
    schema=sl_container_schema;
    schema.tag='Simulink:BlockDisplayMenu';
    schema.label=DAStudio.message('Simulink:studio:BlockDisplayMenu');
    schema.state='Disabled';
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};

    schema.autoDisableWhen='Never';
end

function schema=BlocksDisplayMenu(cbinfo)%#ok<DEFNU>
    schema=BlocksDisplayMenuDisabled(cbinfo);

    schema.state=loc_getBlocksDisplayMenuState(cbinfo);


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    children={im.getAction('Simulink:ModelRefShowIO'),...
    im.getAction('Simulink:ModelRefShowVersion'),...
    'separator',...
    im.getAction('Simulink:SortedOrder'),...
    im.getAction('Simulink:ReducedNVBlk'),...
    im.getAction('Simulink:VariantCondition'),...
    im.getAction('Simulink:VarCondLegend')...
    };


    children=[children,'separator',...
    {@ToolTipOptionsMenu}];
    schema.childrenFcns=children;
end

function state=loc_getBlocksDisplayMenuState(cbinfo)
    state='Enabled';
    if Simulink.harness.internal.hasActiveHarness(cbinfo.editorModel.Name)
        state='Disabled';
    end
end

function checked=loc_getCheckForModelParam(modelH,param)
    if strcmpi(get_param(modelH,param),'on')
        checked='Checked';
    else
        checked='Unchecked';
    end
end

function OpenVariantConditionLegendCB(cbinfo)
    modelName=cbinfo.editorModel.Name;
    if(strcmp(get_param(modelName,'VariantAnnotationsAreReady'),'on'))
        obj=Simulink.EnhancedVariantConditionLegend.getInstance();
        obj.showLegend(modelName);
    end
end

function CloseVariantConditionLegendCB(cbinfo)
    modelName=cbinfo.editorModel.Name;
    obj=Simulink.EnhancedVariantConditionLegend.getInstance();
    obj.removeModel(modelName);
end

function toggleCallbackTracingReport(cbinfo)
    if exist('cbinfo','var')
        if strcmpi(get_param(0,'CallbackTracer'),'off')
            set_param(0,'CallbackTracer','on');
        else
            set_param(0,'CallbackTracer','off');
        end
    end
end

function toggleDVPreference(cbinfo)
    if exist('cbinfo','var')
        slmsgviewer.handleToolstripPreferenceToggle();
        return;
    end
end

function toggleEditTimeCheckingPreference(cbinfo)
    if exist('cbinfo','var')&&SFStudio.Utils.isStateflowApp(cbinfo)
        if strcmpi(get_param(0,'ShowEditTimeIssues'),'off')
            sf('SetLintStatus',true);
            set_param(0,'ShowEditTimeIssues','on');
        else
            sf('SetLintStatus',false);
            set_param(0,'ShowEditTimeIssues','off');
        end
        return;
    end
    edittime.setDisplayIssues();
end

function ToggleModelParamCB(cbinfo,eventData)%#ok<INUSD>
    param=cbinfo.userdata;
    modelH=cbinfo.editorModel.handle;
    val=get_param(modelH,param);
    if strcmpi(val,'on')
        set_param(modelH,param,'off');
    else
        set_param(modelH,param,'on');
    end
end

function ToggleModelParamAndUpdateCB(cbinfo,eventData)%#ok<INUSD>
    ToggleModelParamCB(cbinfo);

    if strcmpi(get_param(cbinfo.editorModel.handle,cbinfo.userdata),'on')
        cbinfo.studio.getToolStrip.ActiveContext.updateDiagram(cbinfo.editorModel.handle);
    end
end


function showSortedOrderDisplayWithoutUpdatingModel(topLevelModel,mdlHandle,studio)
    warningStruct=warning('off','Simulink:Engine:CompileNeededForSampleTimes');
    LegendData=get_param(mdlHandle,'SampleTimes');
    warning(warningStruct.state,'Simulink:Engine:CompileNeededForSampleTimes');

    if(~isempty(LegendData))
        hlocal=Simulink.SampleTimeLegend;
        hlocal.clearHilite(getfullname(mdlHandle),'task');
        Simulink.STOSpreadSheet.SortedOrder.launchExecutionOrderViewer(studio);
    else
        set_param(topLevelModel,'ExecutionOrderLegendDisplay','off');
    end
end

function ActionModelParamAndUpdateSortedOrderCB(cbinfo,arg)%#ok<INUSD>

    st=cbinfo.studio;
    stApp=st.App;
    if(slfeature('TaskBasedSorting')>0)
        if strcmpi(get_param(stApp.topLevelDiagram.handle,'ExecutionOrderLegendDisplay'),'off')

            set_param(stApp.topLevelDiagram.handle,'ExecutionOrderLegendDisplay','on');
            activeEditor=stApp.getActiveEditor;
            blockDiagramHandle=activeEditor.blockDiagramHandle;
            set_param(blockDiagramHandle,'ExecutionOrderLegendDisplay','on');

            if(slfeature('cacheExecOrderInfoDefault')>0&&...
                (isequal(get_param(blockDiagramHandle,'SimulationStatus'),'paused')||...
                isequal(get_param(blockDiagramHandle,'SimulationStatus'),'running')))
                showSortedOrderDisplayWithoutUpdatingModel(stApp.topLevelDiagram.handle,blockDiagramHandle,st);
            else
                SLM3I.SLDomain.updateDiagram(cbinfo.editorModel.handle);
            end
        else
            compName=char(st.getStudioTag+"ssTaskLegend");
            ssComp=st.getComponent('GLUE2:SpreadSheet',compName);

            set_param(stApp.topLevelDiagram.handle,'ExecutionOrderLegendDisplay','off');
            activeEditor=stApp.getActiveEditor;
            blockDiagramHandle=activeEditor.blockDiagramHandle;
            set_param(blockDiagramHandle,'ExecutionOrderLegendDisplay','off');

            if(~isempty(ssComp)&&ssComp.isvalid)
                ssSource=ssComp.getSource;
                ssSource.onCloseClicked(ssComp);
            end
            if(~isempty(ssComp))
                st.hideComponent(ssComp);
            end
        end
    end
end

function ActionNVBlockReductionCB(cbinfo,arg)%#ok<INUSD>

    st=cbinfo.studio;
    stApp=st.App;
    activeEditor=stApp.getActiveEditor;
    blockDiagramHandle=activeEditor.blockDiagramHandle;
    topModelHandle=stApp.topLevelDiagram.handle;

    if strcmpi(get_param(stApp.topLevelDiagram.handle,'NVBlockReducedDisplay'),'off')
        set_param(stApp.topLevelDiagram.handle,'NVBlockReducedDisplay','on');
        blks=get_param(blockDiagramHandle,'ReducedNonVirtualBlockList');
        Simulink.STOSpreadSheet.SortedOrder.NVBlockReducedDisplaySource.HighlightElements(cbinfo,topModelHandle,blockDiagramHandle,blks);
    else
        set_param(stApp.topLevelDiagram.handle,'NVBlockReducedDisplay','off');
        Simulink.STOSpreadSheet.SortedOrder.NVBlockReducedDisplaySource.RemoveHighlight(topModelHandle);
    end

end

function ToggleModelParamAndUpdateVariantConditionCB(cbinfo,arg)%#ok<INUSD>
    ToggleModelParamCB(cbinfo);
    param=cbinfo.userdata;

    if strcmpi(get_param(cbinfo.editorModel.handle,cbinfo.userdata),'on')
        SLM3I.SLDomain.updateDiagram(cbinfo.editorModel.handle);
        if strcmpi(param,'VariantCondition')
            OpenVariantConditionLegendCB(cbinfo);
            set_param(cbinfo.editorModel.handle,'BlockVariantConditionDataTip','on');
        end
    else
        if strcmpi(param,'VariantCondition')
            CloseVariantConditionLegendCB(cbinfo);
            set_param(cbinfo.editorModel.handle,'BlockVariantConditionDataTip','off');
        end
    end
end


function schema=SortedOrder(cbinfo,eventData)%#ok<DEFNU,INUSD>
    schema=sl_toggle_schema;
    schema.tag='Simulink:SortedOrder';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:SortedOrder');
    else
        schema.icon='blockExecutionOrder';
    end
    schema.userdata='SortedOrder';
    schema.callback=@ActionModelParamAndUpdateSortedOrderCB;

    st=cbinfo.studio;
    stApp=st.App;
    isSortedOrderOn=strcmpi(get_param(stApp.topLevelDiagram.handle,'ExecutionOrderLegendDisplay'),'on');
    if isSortedOrderOn
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.state=loc_getBlocksDisplayMenuState(cbinfo);

    if(slfeature('cacheExecOrderInfoDefault')>0)
        schema.autoDisableWhen='Never';
    else
        schema.autoDisableWhen='Busy';
    end
end

function schema=ReducedNVBlk(cbinfo,eventData)%#ok<DEFNU,INUSD>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ReducedNVBlk';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ReducedNVBlk');
    else
        schema.icon='nvBlockReduction';
    end
    schema.userdata='ReducedNVBlk';
    schema.callback=@ActionNVBlockReductionCB;

    st=cbinfo.studio;
    stApp=st.App;
    isShowReductionOn=strcmpi(get_param(stApp.topLevelDiagram.handle,'NVBlockReducedDisplay'),'on');
    if isShowReductionOn
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.autoDisableWhen='Never';

    if(isempty(get_param(gcs,'ReducedNonVirtualBlockList')))
        schema.state='Hidden';
        schema.checked='Unchecked';
    else
        schema.state=loc_getBlocksDisplayMenuState(cbinfo);
    end
end


function schema=VariantCondition(cbinfo,eventData)%#ok<DEFNU,INUSD>
    schema=sl_toggle_schema;
    schema.tag='Simulink:VariantCondition';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:VariantCondition');
    else
        schema.icon='variantConditions';
    end
    schema.userdata='VariantCondition';
    schema.callback=@ToggleModelParamAndUpdateVariantConditionCB;
    isVarCondOn=strcmpi(get_param(cbinfo.editorModel.handle,'VariantCondition'),'on');
    if isVarCondOn
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.state=loc_getBlocksDisplayMenuState(cbinfo);
    schema.autoDisableWhen='Never';
end

function schema=VarCondLegend(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:VarCondLegend';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:VarCondLegend');
    else
        schema.icon='variantLegend';
    end
    schema.userdata='VarCondLegend';
    schema.accelerator='Ctrl+Shift+J';
    schema.callback=@OpenVariantConditionLegendCB;
    isVarCondOn=strcmpi(get_param(cbinfo.editorModel.handle,'VariantCondition'),'on')&&...
    strcmpi(get_param(cbinfo.editorModel.handle,'VariantAnnotationsAreReady'),'on');

    if isVarCondOn
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Never';
end

function state=loc_getModelReferenceBlockVersionState(cbinfo)
    state=loc_getBlocksDisplayMenuState(cbinfo);
end

function schema=ModelRefShowVersion(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ModelRefShowVersion';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ModelRefShowVersion');
    else
        schema.icon='modelRefVersion';
    end
    schema.userdata='ShowModelReferenceBlockVersion';
    schema.callback=@ToggleModelParamCB;

    schema.state=loc_getModelReferenceBlockVersionState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=SubsystemDomainSpec(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:SubsystemDomainSpec';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SubsystemDomainSpec');
    schema.userdata='ShowSubsystemDomainSpec';
    schema.callback=@ToggleModelParamCB;
    schema.state='Hidden';
    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);
    schema.autoDisableWhen='Never';
end

function schema=ToolTipOptionsMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:BlockDataTipsMenu';
    schema.label=DAStudio.message('Simulink:studio:BlockDataTipsMenu');

    schema.state=loc_getBlocksDisplayMenuState(cbinfo);


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:BlockDataTipsBlockName'),...
    im.getAction('Simulink:BlockDataTipsParamNamesAndValues'),...
    im.getAction('Simulink:BlockDataTipsDescriptionString'),...
    im.getAction('Simulink:BlockDataTipsVariantConditions')
    };

    schema.autoDisableWhen='Never';
end

function schema=BlockDataTipsBlockName(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:BlockDataTipsBlockName';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:BlockDataTipsBlockName');
    else
        schema.icon='blockTooltip';
    end
    schema.userdata='BlockNameDataTip';
    schema.callback=@ToggleModelParamCB;
    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.state=loc_getBlocksDisplayMenuState(cbinfo);

    schema.autoDisableWhen='Never';
end

function schema=BlockDataTipsParamNamesAndValues(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:BlockDataTipsParamNamesAndValues';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:BlockDataTipsParamNamesAndValues');
    else
        schema.icon='blockTooltip';
    end
    schema.userdata='BlockParametersDataTip';
    schema.callback=@ToggleModelParamCB;
    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.state=loc_getBlocksDisplayMenuState(cbinfo);

    schema.autoDisableWhen='Never';
end

function schema=BlockDataTipsDescriptionString(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:BlockDataTipsDescriptionString';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:BlockDataTipsDescriptionString');
    else
        schema.icon='blockTooltip';
    end
    schema.userdata='BlockDescriptionStringDataTip';
    schema.callback=@ToggleModelParamCB;
    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.state=loc_getBlocksDisplayMenuState(cbinfo);

    schema.autoDisableWhen='Never';
end

function schema=BlockDataTipsVariantConditions(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:BlockDataTipsVariantConditions';
    schema.label=DAStudio.message('Simulink:studio:BlockDataTipsVariantConditions');
    schema.userdata='BlockVariantConditionDataTip';
    schema.callback=@ToggleModelParamCB;
    isVarCondOn=strcmpi(get_param(cbinfo.editorModel.handle,'VariantCondition'),'on')&&...
    strcmpi(get_param(cbinfo.editorModel.handle,'VariantAnnotationsAreReady'),'on');
    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);
    if isVarCondOn
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Never';
end



function schema=PortSignalDisplayMenuDisabled(~)
    schema=sl_container_schema;
    schema.tag='Simulink:PortSignalDisplayMenu';
    schema.label=DAStudio.message('Simulink:studio:PortSignalDisplayMenu');
    schema.state='Disabled';
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};

    schema.autoDisableWhen='Never';
end

function out=getDVPreferenceDisplayInfo(~)
    out.name='Simulink:DVPreferenceDisplayMenu';
    out.enabled=1;
    out.optOutLocked=1;
    out.optOutBusy=1;
    out.selected=strcmpi(get_param(0,'DiagnosticViewerPreference'),'on');
    out.callback=@toggleDVPreference;
    out.userdata='ToggleDVPreference';

    out.label=DAStudio.message('Simulink:studio:EditTimeCheckingPreference');
end

function DVPreferenceDisplayMenuRF(cbinfo,action)%#ok<DEFNU>
    info=getDVPreferenceDisplayInfo(cbinfo);

    action.enabled=info.enabled;
    action.optOutLocked=info.optOutLocked;
    action.optOutBusy=info.optOutBusy;
    action.selected=info.selected;

    if isempty(action.callback)
        action.setCallbackFromArray(info.callback,dig.model.FunctionType.Action);
    end
end

function schema=DVPreferenceDisplayMenu(cbinfo)%#ok<DEFNU>        
    schema=sl_toggle_schema;
    info=getDVPreferenceDisplayInfo(cbinfo);

    schema.tag=info.name;

    if info.enabled
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    if info.selected
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    if info.optOutLocked&&info.optOutBusy
        schema.autoDisableWhen='Never';
    elseif info.optOutLocked
        schema.autoDisableWhen='Busy';
    elseif info.optOutBusy
        schema.autoDisableWhen='Locked';
    end

    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=info.label;
    end

    if isempty(schema.callback)
        schema.callback=info.callback;
    end

    schema.userdata=info.userdata;
end

function out=getEditTimeDisplayInfo(~)
    out.name='Simulink:EditTimeNotificationsDisplayMenu';
    out.enabled=1;
    out.optOutLocked=1;
    out.optOutBusy=1;
    out.selected=strcmpi(get_param(0,'ShowEditTimeIssues'),'on');
    out.callback=@toggleEditTimeCheckingPreference;
    out.userdata='ToggleEditTimeCheckingPreference';
    out.label=DAStudio.message('Simulink:studio:EditTimeCheckingPreference');
end

function EditTimeNotificationsDisplayMenuRF(cbinfo,action)%#ok<DEFNU>
    info=getEditTimeDisplayInfo(cbinfo);

    action.enabled=info.enabled;
    action.optOutLocked=info.optOutLocked;
    action.optOutBusy=info.optOutBusy;
    action.selected=info.selected;

    if isempty(action.callback)
        action.setCallbackFromArray(info.callback,dig.model.FunctionType.Action);
    end
end

function schema=EditTimeNotificationsDisplayMenu(cbinfo)%#ok<DEFNU>        
    schema=sl_toggle_schema;
    info=getEditTimeDisplayInfo(cbinfo);

    schema.tag=info.name;

    if info.enabled
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    if info.selected
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    if info.optOutLocked&&info.optOutBusy
        schema.autoDisableWhen='Never';
    elseif info.optOutLocked
        schema.autoDisableWhen='Busy';
    elseif info.optOutBusy
        schema.autoDisableWhen='Locked';
    end

    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=info.label;
    end

    if isempty(schema.callback)
        schema.callback=info.callback;
    end

    schema.userdata=info.userdata;
end

function LogCallbackTracingReportActionRF(cbinfo,action)
    isSelected=false;
    if strcmpi(get_param(0,'CallbackTracer'),'on')
        isSelected=true;
    end
    action.selected=isSelected;
    if isempty(action.callback)
        action.setCallbackFromArray(@toggleCallbackTracingReport,dig.model.FunctionType.Action);
    end
end

function schema=PortSignalDisplayMenu(cbinfo)%#ok<DEFNU>
    schema=PortSignalDisplayMenuDisabled(cbinfo);

    schema.state=loc_getPortSignalDisplayMenuState(cbinfo);


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    children={im.getAction('Simulink:LineDimensions'),...
    im.getAction('Simulink:WideLines'),...
    'separator',...
    im.getAction('Simulink:PortDataTypes'),...
    im.getAction('Simulink:PortDataTypeDisplayFormat'),...
    im.getAction('Simulink:PortUnits'),...
    im.getAction('Simulink:PortIndexPanel'),...
    im.getAction('Simulink:PropagatedSignalLabels'),...
    im.getAction('Simulink:DesignRanges'),...
    im.getAction('Simulink:SignalResolutionIcons'),...
    im.getAction('Simulink:StorageClass'),...
    'separator',...
    im.getAction('Simulink:TestpointIcons'),...
    im.getAction('Simulink:ViewerIcons'),...
    'separator',...
    im.getAction('Simulink:LinearizationAnnotations'),...
    im.getAction('Simulink:VisualizeInsertedRTB'),...
    };
    schema.childrenFcns=children;
end

function schema=PortDataTypeDisplayFormat(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:PortDataTypeDisplayFormat';
    schema.label=DAStudio.message('Simulink:studio:PortDataTypeDisplayFormat');

    schema.state=loc_getBlocksDisplayMenuState(cbinfo);


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    schema.childrenFcns={im.getAction('Simulink:PortDataTypeDisplayFormatAlias'),...
    im.getAction('Simulink:PortDataTypeDisplayFormatBase'),...
    im.getAction('Simulink:PortDataTypeDisplayFormatBaseAndAlias')...
    };
    schema.autoDisableWhen='Never';
end

function schema=PortDataTypeDisplayFormatAlias(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:PortDataTypeDisplayFormatAlias';
    schema.label=DAStudio.message('Simulink:studio:PortDataTypeDisplayFormatAlias');
    schema.userdata='PortDataTypeDisplayFormat';

    if(strcmpi(get_param(cbinfo.editorModel.handle,'PortDataTypeDisplayFormat'),'AliasTypeOnly'))
        schema.checked='checked';
    else
        schema.checked='unchecked';
    end
    schema.state='Enabled';
    schema.callback=@PortDataTypesTypeDisplayFormatAliasChecked;
    schema.autoDisableWhen='Never';
end

function[]=PortDataTypesTypeDisplayFormatAliasChecked(cbinfo,~)
    set_param(cbinfo.editorModel.handle,'PortDataTypeDisplayFormat','AliasTypeOnly');
end

function schema=PortDataTypeDisplayFormatBase(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:PortDataTypeDisplayFormatBase';
    schema.label=DAStudio.message('Simulink:studio:PortDataTypeDisplayFormatBase');
    schema.userdata='PortDataTypeDisplayFormat';

    if(strcmpi(get_param(cbinfo.editorModel.handle,'PortDataTypeDisplayFormat'),'BaseTypeOnly'))
        schema.checked='checked';
    else
        schema.checked='unchecked';
    end
    schema.state='Enabled';
    schema.callback=@PortDataTypeDisplayBaseChecked;
    schema.autoDisableWhen='Never';
end

function[]=PortDataTypeDisplayBaseChecked(cbinfo,~)
    set_param(cbinfo.editorModel.handle,'PortDataTypeDisplayFormat','BaseTypeOnly');
end

function schema=PortDataTypeDisplayFormatBaseAndAlias(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:PortDataTypeDisplayFormatBaseAndAlias';
    schema.label=DAStudio.message('Simulink:studio:PortDataTypeDisplayFormatBaseAndAlias');
    schema.userdata='PortDataTypeDisplayFormat';

    if(strcmpi(get_param(cbinfo.editorModel.handle,'PortDataTypeDisplayFormat'),'BaseAndAliasTypes'))
        schema.checked='checked';
    else
        schema.checked='unchecked';
    end
    schema.state='Enabled';
    schema.callback=@PortDataTypeDisplayFormatBaseAndAliasChecked;
    schema.autoDisableWhen='Never';
end

function[]=PortDataTypeDisplayFormatBaseAndAliasChecked(cbinfo)
    set_param(cbinfo.editorModel.handle,'PortDataTypeDisplayFormat','BaseAndAliasTypes');
end


function schema=PortUnits(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:PortUnits';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:PortUnits');
    else
        schema.icon='portPhysicalUnits';
    end
    schema.userdata='ShowPortUnits';
    schema.callback=@ToggleModelParamAndUpdateCB;
    schema.state=loc_getPortSignalDisplayMenuState(cbinfo);
    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=PortDataTypes(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:PortDataTypes';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:PortDataTypes');
    else
        schema.icon='portDataTypes';
    end
    schema.userdata='ShowPortDataTypes';
    schema.callback=@ToggleModelParamAndUpdateCB;

    schema.state=loc_getPortSignalDisplayMenuState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=PortIndexPanel(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:PortIndexPanel';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('simulink_ui:studio:resources:portIndexPanelText');
    else
        schema.icon='portIndexPanel';
    end

    schema.callback=@loc_PortIndexPanelCB;

    if loc_getPortIndexPanelChecked(cbinfo)
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.autoDisableWhen='Never';

    if slfeature('SLEditorPortIndexPanelTool')<=0
        schema.state='Hidden';
    else
        schema.state='Enabled';
    end
end

function loc_PortIndexPanelCB(cbinfo,eventData)%#ok<INUSD>
    editor=cbinfo.studio.App.getActiveEditor;
    oldChecked=SLM3I.Util.isPortIndexPanelToolEnabled(editor);
    newChecked=~oldChecked;
    if newChecked
        SLM3I.Util.enablePortIndexPanelTool(editor);
    else
        SLM3I.Util.disablePortIndexPanelTool(editor);
    end
end

function isChecked=loc_getPortIndexPanelChecked(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    isChecked=SLM3I.Util.isPortIndexPanelToolEnabled(editor);
end

function schema=PropagatedSignalLabels(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:PropagatedSignalLabels';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:PropagatedSignalLabels');
    else
        schema.icon='propagatedSignalLabels';
    end
    schema.userdata='ShowAllPropagatedSignalLabels';
    schema.callback=@ToggleModelParamCB;

    schema.state=loc_getPortSignalDisplayMenuState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=DesignRanges(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:DesignRanges';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:DesignRanges');
    else
        schema.icon='signalDesignRanges';
    end
    schema.userdata='ShowDesignRanges';
    schema.callback=@ToggleModelParamAndUpdateCB;

    schema.state=loc_getPortSignalDisplayMenuState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function state=loc_getModelRefShowIOState(cbinfo)
    state=loc_getPortSignalDisplayMenuState(cbinfo);
end

function schema=ModelRefShowIO(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ModelRefShowIO';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ModelRefShowIO');
    else
        schema.icon='modelReferenceIoMismatch';
    end
    schema.userdata='ShowModelReferenceBlockIO';
    schema.callback=@ToggleModelParamCB;

    schema.state=loc_getModelRefShowIOState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function state=loc_getPortSignalDisplayMenuState(cbinfo)
    state='Enabled';
    if Simulink.harness.internal.hasActiveHarness(cbinfo.editorModel.Name)
        state='Disabled';
    end
end

function state=loc_getLinearizationAnnotationsState(cbinfo)
    state=loc_getPortSignalDisplayMenuState(cbinfo);
    if~license('test','Simulink_Control_Design')
        state='Disabled';
    end
end

function schema=LinearizationAnnotations(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:LinearizationAnnotations';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LinearizationAnnotations');
    else
        schema.icon='linearizationIndicatorsVisibility';
    end
    schema.userdata='ShowLinearizationAnnotations';
    schema.callback=@ToggleModelParamCB;

    schema.state=loc_getLinearizationAnnotationsState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=LineDimensions(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:LineDimensions';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LineDimensions');
    else
        schema.icon='signalDimensions';
    end
    schema.userdata='ShowLineDimensions';
    schema.callback=@ToggleModelParamAndUpdateCB;

    schema.state=loc_getPortSignalDisplayMenuState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=StorageClass(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:StorageClass';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:StorageClass');
    else
        schema.icon='storageClass';
    end
    schema.userdata='ShowStorageClass';
    schema.callback=@ToggleModelParamAndUpdateCB;

    schema.state=loc_getPortSignalDisplayMenuState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
    type=coder.dictionary.internal.getPlatformType(cbinfo.model.handle);
    if strcmp(type,'FunctionPlatform')
        schema.state='Disabled';
    end
end

function state=loc_getTestpointIconsState(cbinfo)
    state=loc_getPortSignalDisplayMenuState(cbinfo);
end

function schema=TestpointIcons(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:TestpointIcons';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:TestpointIcons');
    else
        schema.icon='testpointVisibility';
    end
    schema.userdata='ShowTestPointIcons';
    schema.callback=@ToggleModelParamCB;

    schema.state=loc_getTestpointIconsState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function state=loc_getSignalResolutionIconsState(cbinfo)
    state=loc_getPortSignalDisplayMenuState(cbinfo);
end

function schema=SignalResolutionIcons(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:SignalResolutionIcons';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:SignalResolutionIcons');
    else
        schema.icon='signalResolvesToObject';
    end
    schema.userdata='ShowSignalResolutionIcons';
    schema.callback=@ToggleModelParamCB;

    schema.state=loc_getSignalResolutionIconsState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function state=loc_getViewerIconsState(cbinfo)
    state=loc_getPortSignalDisplayMenuState(cbinfo);
end

function schema=ViewerIcons(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:ViewerIcons';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ViewerIcons');
    else
        schema.icon='viewerLogVisibility';
    end
    schema.userdata='ShowViewerIcons';
    schema.callback=@ToggleModelParamCB;

    schema.state=loc_getViewerIconsState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=WideLines(cbinfo,eventData)%#ok<INUSD,DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:WideLines';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:WideLines');
    else
        schema.icon='nonscalarSignals';
    end
    schema.userdata='WideLines';

    schema.state=loc_getPortSignalDisplayMenuState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);




    schema.callback=@ToggleModelParamAndUpdateCB;

    schema.autoDisableWhen='Never';
end

function schema=AdvisorEditTimeCheckingForAnalysisMenu(cbinfo)
















    schema=sl_action_schema;
    schema.tag='Simulink:AdvisorEditTimeCheckingForAnalysisMenu';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:AdvisorEditTimeCheckingForAnalysisMenu');
    end
    schema.icon='modelAdvisorEdittime';
    schema.callback=@openConfigParam_ShowAdvisorChecksEditTime;
    if~Advisor.Utils.license('test','SL_Verification_Validation')
        schema.state='hidden';
    else
        schema.state='Enabled';
    end
    schema.autoDisableWhen='Never';
end

function openConfigParam_ShowAdvisorChecksEditTime(cbinfo)
    cs=getActiveConfigSet(cbinfo.model.Name);
    if isa(cs,'Simulink.ConfigSetRef')
        csRef=cs.getRefConfigSet;
    else
        csRef=cs;
    end
    if~csRef.isValidParam('ShowAdvisorChecksEditTime')
        maconfigset=ModelAdvisor.ConfigsetCC;
        csRef.attachComponent(maconfigset);


        configsetVal=get_param(cbinfo.model.Name,'ShowAdvisorChecksEditTime');
        expectedVal=edittime.getAdvisorChecking(cbinfo.model.Name);
        if~strcmp(configsetVal,expectedVal)
            set_param(cbinfo.model.Name,'ShowAdvisorChecksEditTime',expectedVal);
        end

    end

    configset.highlightParameter(cs,'ShowAdvisorChecksEditTime');
    configset.addParamListener(cbinfo.model.Handle,'ShowAdvisorChecksEditTime',@localCBtest);
end

function localCBtest(model,~,paramValue)
    edittime.setAdvisorChecking(model,paramValue);
end

function schema=HighlightSignalToSourceSF(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:HighlightSignalToSource';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:HighlightSignalToSource');
    end
    schema.obsoleteTags={'Simulink:TraceLineSource'};
    schema.state='Disabled';

    schema.autoDisableWhen='Never';
end

function schema=HighlightSignalToSource(cbinfo)%#ok<DEFNU>
    schema=HighlightSignalToSourceSF(cbinfo);
    segments=SLStudio.Utils.getSelectedSegmentsAsSequence(cbinfo);
    schema.state='hidden';

    if(segments.size>0&&loc_AreSegmentsFromSameLine(segments)...
        &&~SLStudio.Utils.isConnectionLineSelectedGivenSequenceOfSegments(cbinfo,segments))
        schema.state='enabled';
        schema.userdata=segments.at(1);
    end

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='signalTraceToSource';
    end

    schema.callback=@HighlightSignalToSourceCB;
end

function retVal=loc_AreSegmentsFromSameLine(segments)
    retVal=true;
    container=segments.at(1).container;
    for i=2:segments.size
        if(container~=segments.at(i).container)
            retVal=false;
            break;
        end
    end
end

function HighlightSignalToSourceCB(cbinfo)



    segment=cbinfo.userdata;
    Simulink.Structure.HiliteTool.AppManager.HighlightSignalToSource(segment.handle);
    cbinfo.studio.App.getActiveEditor.getCanvas.setFocus;
end

function schema=HighlightSignalToDestinationSF(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:HighlightSignalToDestination';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:HighlightSignalToDestination');
    end
    schema.obsoleteTags={'Simulink:TraceLineDestination'};
    schema.state='Disabled';

    schema.autoDisableWhen='Never';
end

function schema=HighlightSignalToDestination(cbinfo)%#ok<DEFNU>
    schema=HighlightSignalToDestinationSF(cbinfo);
    segments=SLStudio.Utils.getSelectedSegmentsAsSequence(cbinfo);
    schema.state='hidden';

    if(segments.size>0&&loc_AreSegmentsFromSameLine(segments)...
        &&~SLStudio.Utils.isConnectionLineSelectedGivenSequenceOfSegments(cbinfo,segments))
        schema.state='enabled';
        schema.userdata=segments.at(1);
    end

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='signalTraceToDestination';
    end

    schema.callback=@HighlightSignalToDestinationCB;
end

function HighlightSignalToDestinationCB(cbinfo)



    segment=cbinfo.userdata;
    Simulink.Structure.HiliteTool.AppManager.HighlightSignalToDestination(segment.handle);
    cbinfo.studio.App.getActiveEditor.getCanvas.setFocus;
end

function ret=loc_ShowGraphContents(graphHandle)
    ret=true;


    if(~strcmpi(get(graphHandle,'Type'),'block'))
        return;
    end



    if(strcmpi(get(graphHandle,'MaskHideContents'),'on'))
        ret=false;
    end

end

function ret=loc_CanInstallStylingOnTransparency(transparencyRenderer,styleTag)%#ok<DEFNU>
    ret=true;
    transEditor=transparencyRenderer.getEditor;
    if(isempty(transEditor))
        ret=false;
    else
        if(isa(transEditor.getDiagram,'InterfaceEditor.Diagram')&&...
            strcmp(styleTag,'HilightToSrcOrDest'))
            ret=false;
        end

    end
end

function DoHighlightsCB(studio,hiliteInfo,bdHandle)
    hiliteMap=hiliteInfo.graphHighlightMap;
    participatingGraphHandles=[hiliteMap{:,1}];
    termGraphHandle=hiliteInfo.termGraphHandle;

    allElements=[];

    for i=1:length(participatingGraphHandles)
        uddObj=get(participatingGraphHandles(i),'Object');
        sysName=uddObj.getFullName;
        editors=GLUE2.Util.findAllEditors(sysName);

        if(participatingGraphHandles(i)==termGraphHandle)
            if(loc_ShowGraphContents(participatingGraphHandles(i)))
                if(isempty(editors))
                    studio.App.setEditorOpenType('NEW_TAB');
                    load_system(sysName);
                    diagramInfo=SLM3I.Util.getDiagram(sysName);
                    studio.App.openEditor(diagramInfo.diagram);
                    studio.App.restoreEditorOpenType;
                    editors=GLUE2.Util.findEditor(sysName,studio);
                    assert(~isempty(editors));
                else
                    diffStudio=[];
                    for j=1:length(editors)
                        e=editors(j);
                        s=e.getStudio;
                        if(s.isComponentVisible(e)&&(s~=studio))
                            diffStudio=s;
                        end
                    end
                    if(~isempty(diffStudio))
                        diffStudio.App.openEditor(editors(1).getDiagram);
                    else
                        studio.App.setEditorOpenType('NEW_TAB');
                        studio.App.openEditor(editors(1).getDiagram);
                        studio.App.restoreEditorOpenType;
                    end
                end
            end
        end



        if(loc_ShowGraphContents(participatingGraphHandles(i)))
            allElements=[allElements,hiliteMap{i,2}];%#ok<AGROW>
        end
    end

    SLStudio.EmphasisStyleSheet.applyStyler(bdHandle,allElements);
end

function schema=HighlightConnections(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:HighlightConnections';

    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:HighlightConnections');
    else
        schema.icon='traceConnections';
    end

    schema.autoDisableWhen='Never';

    line=SLStudio.Utils.getSingleSelectedLine(cbinfo);

    if isempty(line)
        schema.state='Hidden';
    else
        segment=line.segment.at(1);

        if isempty(segment)||~segment.isvalid
            schema.state='Hidden';
        else
            lineType='';

            try
                lineType=get_param(segment.handle,'LineType');
            catch
            end

            if~strcmpi(lineType,'connection')
                schema.state='Hidden';
            else
                schema.state='Enabled';

                schema.userdata=[segment.handle];
                schema.callback=@HighlightConnectionsCB;
            end
        end
    end
end

function HighlightConnectionsCB(cbinfo)



    bdHandle=cbinfo.editorModel.handle;
    SLStudio.Utils.RemoveHighlighting(bdHandle);

    elements=builtin('_connection_line_tracing',cbinfo.userdata);

    SLStudio.EmphasisStyleSheet.applyStyler(bdHandle,elements);
end

function schema=RemoveHighlightingBase(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:RemoveHighlighting';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:RemoveHighlighting');
    end
    schema.accelerator='Ctrl+Shift+H';
    schema.autoDisableWhen='Never';
end

function schema=RemoveHighlighting(cbinfo)%#ok<DEFNU>
    schema=RemoveHighlightingBase(cbinfo);
    schema.state='Enabled';
    schema.callback=@RemoveHighlightingCB;
end

function schema=RemoveHighlightingSF(cbinfo)%#ok<DEFNU>
    schema=RemoveHighlightingBase(cbinfo);
    schema.state='Enabled';
    schema.callback=@RemoveHighlightingSFCB;
end

function RemoveHighlightingCB(cbinfo)
    SLStudio.Utils.RemoveHighlighting(cbinfo.editorModel.handle);
end

function RemoveHighlightingSFCB(cbinfo)

    machineId=sfprivate('actual_machine_referred_by',SFStudio.Utils.getChartId(cbinfo));
    modelName=sf('get',machineId,'machine.name');
    slprivate('remove_hilite',modelName);
    if SFStudio.Utils.isStateflowApp(cbinfo)
        Stateflow.App.Cdr.Runtime.InstanceIndRuntime.deleteAllDebugHighlights();
    end
end


function visible=loc_markupVisible(cbinfo)
    blockDiagram=cbinfo.editorModel.handle;

    visible=SLStudio.MarkupStyleSheet.isMarkupVisible(blockDiagram);
end

function ToggleMarkupCB(cbinfo)
    blockDiagram=cbinfo.editorModel.handle;

    visible=true;
    if(loc_markupVisible(cbinfo))
        visible=false;
    end

    if(visible)
        set_param(blockDiagram,'ShowMarkup','on');
    else
        set_param(blockDiagram,'ShowMarkup','off');
    end
end

function HideAutomaticNamesCB(cbinfo)
    blockDiagram=cbinfo.editorModel.handle;

    if(strcmp(get_param(blockDiagram,'HideAutomaticNames'),'off'))
        set_param(blockDiagram,'HideAutomaticNames','on');
    else
        set_param(blockDiagram,'HideAutomaticNames','off');
    end
end


function schema=HideShowMarkup(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:HideShowMarkup';
    schema.label=DAStudio.message('Simulink:studio:HideMarkup');
    if(loc_markupVisible(cbinfo)==false)
        schema.label=DAStudio.message('Simulink:studio:ShowMarkup');
    end

    schema.callback=@ToggleMarkupCB;
end

function schema=HideAutomaticNames(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:HideAutomaticNames';
    schema.label=DAStudio.message('Simulink:studio:HideAutomaticNames');
    schema.callback=@HideAutomaticNamesCB;
    schema.autoDisableWhen='Locked';

    if(strcmp(get_param(cbinfo.editorModel.Name,'HideAutomaticNames'),'on'))
        schema.userdata='On';
        schema.check='Checked';
    else
        schema.userdata='Off';
        schema.check='Unchecked';
    end
end

function state=loc_getHighlightOptionsMenuState(cbinfo)
    state='Disabled';
    if strcmp(cbinfo.editorModel.Name,'simulink')
        state='Enabled';
    end
end

function schema=HiliteOptionsMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:HiliteOptionsMenu';
    schema.label=DAStudio.message('Simulink:studio:HiliteOptionsMenu');

    schema.state=loc_getHighlightOptionsMenuState(cbinfo);

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:LibViewFixedPoint'),...
    im.getAction('Simulink:LibViewBaseInt'),...
    im.getAction('Simulink:LibViewBoolean'),...
    im.getAction('Simulink:LibViewSingle'),...
    im.getAction('Simulink:LibViewProduction')
    };

    schema.autoDisableWhen='Busy';
end

function schema=LibViewFixedPoint(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:LibViewFixedPoint';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibViewFixedPoint');
    else
        schema.icon='fixedPoint';
    end
    schema.state=loc_getHighlightOptionsMenuState(cbinfo);
    schema.userdata='fixedpt';
    schema.checked=loc_getHighlightOptionsItemChecked(schema.userdata);
    schema.callback=@SetHighlightOptionsCB;

    schema.autoDisableWhen='Busy';
end

function schema=LibViewBaseInt(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:LibViewBaseInt';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibViewBaseInt');
    else
        schema.icon='var_baseInteger';
    end
    schema.state=loc_getHighlightOptionsMenuState(cbinfo);
    schema.userdata='integer';
    schema.checked=loc_getHighlightOptionsItemChecked(schema.userdata);
    schema.callback=@SetHighlightOptionsCB;

    schema.autoDisableWhen='Busy';
end

function schema=LibViewBoolean(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:LibViewBoolean';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibViewBoolean');
    else
        schema.icon='var_logical';
    end
    schema.state=loc_getHighlightOptionsMenuState(cbinfo);
    schema.userdata='boolean';
    schema.checked=loc_getHighlightOptionsItemChecked(schema.userdata);
    schema.callback=@SetHighlightOptionsCB;

    schema.autoDisableWhen='Busy';
end

function schema=LibViewSingle(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:LibViewSingle';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibViewSingle');
    else
        schema.icon='var_double';
    end
    schema.state=loc_getHighlightOptionsMenuState(cbinfo);
    schema.userdata='single';
    schema.checked=loc_getHighlightOptionsItemChecked(schema.userdata);
    schema.callback=@SetHighlightOptionsCB;

    schema.autoDisableWhen='Busy';
end

function schema=LibViewProduction(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:LibViewProduction';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:LibViewProduction');
    else
        schema.icon='productionCode';
    end
    schema.state=loc_getHighlightOptionsMenuState(cbinfo);
    schema.userdata='production';
    schema.checked=loc_getHighlightOptionsItemChecked(schema.userdata);
    schema.callback=@SetHighlightOptionsCB;

    schema.autoDisableWhen='Busy';
end

function checked=loc_getHighlightOptionsItemChecked(item)
    if strcmpi(slprivate('hilite_option'),item)
        checked='Checked';
    else
        checked='Unchecked';
    end
end

function SetHighlightOptionsCB(cbinfo)

    slprivate('remove_hilite',cbinfo.editorModel.handle);
    option=cbinfo.userdata;
    children=cbinfo.editorModel.getHierarchicalChildren;
    for index=1:length(children)
        graph_children=children(index).getChildren;
        for c=1:length(graph_children)
            obj=graph_children(c);
            if isa(obj,'Simulink.Reference')
                h=obj.Handle;
                obj=get_param(h,'object');
            end
            if isa(obj,'Simulink.Block')&&...
                SLStudio.Utils.BlockSupportsCap(obj,option)
                set_param(obj.handle,'HiliteAncestors','orangeWhite');
            end
        end
    end
    slprivate('hilite_option',option);
end

function state=loc_getVisualizeInsertedRTBState(cbinfo)
    state=loc_getPortSignalDisplayMenuState(cbinfo);
end

function schema=VisualizeInsertedRTB(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='hiddenRateTransitionBlock';
    else
        schema.tag='Simulink:VisualizeInsertedRTB';
        schema.label=DAStudio.message('Simulink:studio:VisualizeInsertedRTB');
    end

    schema.userdata='ShowVisualizeInsertedRTB';
    schema.callback=@ToggleModelParamCB;

    schema.state=loc_getVisualizeInsertedRTBState(cbinfo);

    schema.checked=loc_getCheckForModelParam(cbinfo.editorModel.handle,schema.userdata);

    schema.autoDisableWhen='Never';
end

function schema=MessageAnimationDisplayMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:MessageAnimationDisplayMenu';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:MessageAnimationDisplayMenuContext');
    else
        schema.label=DAStudio.message('Simulink:studio:MessageAnimationDisplayMenu');
    end


    children={@MessageAnimationFast,...
    @MessageAnimationMedium,...
    @MessageAnimationSlow,...
    @MessageAnimationNone
    };

    schema.childrenFcns=children;

    schema.autoDisableWhen='Never';

    if(slfeature('NewDESShowAnimMenu')<1)
        schema.state='Hidden';
    end
end

function schema=MessageAnimationFast(cbinfo)%#ok<INUSD>
    schema=sl_toggle_schema;
    schema.tag='Simulink:MessageAnimationFast';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:MessageAnimationFast');
    schema.userdata='fast';
    if cbinfo.isContextMenu
        schema.callback=@SetAnimationSpeedInContextMenuCB;
        if(strcmp(get_param(cbinfo.model.Handle,'AnimationSpeed'),'fast'))
            schema.checked='Checked';
        end
    else
        schema.callback=@SetMessageAnimationDisplayCB;
        if((slfeature('NewDESAnimation')==1))
            schema.checked='Checked';
        end
    end
    schema.autoDisableWhen='Never';
end

function schema=MessageAnimationMedium(cbinfo)%#ok<INUSD>
    schema=sl_toggle_schema;
    schema.tag='Simulink:MessageAnimationMedium';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:MessageAnimationMedium');
    schema.userdata='medium';
    if cbinfo.isContextMenu
        schema.callback=@SetAnimationSpeedInContextMenuCB;
        if(strcmp(get_param(cbinfo.model.Handle,'AnimationSpeed'),'medium'))
            schema.checked='Checked';
        end
    else
        schema.callback=@SetMessageAnimationDisplayCB;
        if((slfeature('NewDESAnimation')==2))
            schema.checked='Checked';
        end
    end
    schema.autoDisableWhen='Never';
end

function schema=MessageAnimationSlow(cbinfo)%#ok<INUSD>
    schema=sl_toggle_schema;
    schema.tag='Simulink:MessageAnimationSlow';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:MessageAnimationSlow');
    schema.userdata='slow';
    if cbinfo.isContextMenu
        schema.callback=@SetAnimationSpeedInContextMenuCB;
        if(strcmp(get_param(cbinfo.model.Handle,'AnimationSpeed'),'slow'))
            schema.checked='Checked';
        end
    else
        schema.callback=@SetMessageAnimationDisplayCB;
        if((slfeature('NewDESAnimation')==3))
            schema.checked='Checked';
        end
    end
    schema.autoDisableWhen='Never';
end

function schema=MessageAnimationNone(cbinfo)%#ok<INUSD>
    schema=sl_toggle_schema;
    schema.tag='Simulink:MessageAnimationNone';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:MessageAnimationNone');
    schema.userdata='none';
    if cbinfo.isContextMenu
        schema.callback=@SetAnimationSpeedInContextMenuCB;
        if(strcmp(get_param(cbinfo.model.Handle,'AnimationSpeed'),'none'))
            schema.checked='Checked';
        end
    else
        schema.callback=@SetMessageAnimationDisplayCB;
        if((slfeature('NewDESAnimation')==0))
            schema.checked='Checked';
        end
    end
    schema.autoDisableWhen='Never';
end

function SetAnimationSpeedInContextMenuCB(cbinfo)
    set_param(cbinfo.model.Handle,'AnimationSpeed',cbinfo.UserData);
end

function SetMessageAnimationDisplayCB(cbinfo)
    delay=0;
    switch cbinfo.userdata
    case 'fast'
        delay=1;
    case 'medium'
        delay=2;
    case 'slow'
        delay=3;
    case 'none'
        delay=0;
    end
    slfeature('NewDESAnimation',delay);
end

function ToolStripAnimationSpeed(cbinfo,action)
    if isempty(action.callback)
        action.setCallbackFromArray(@SetAnimationSpeedCB,dig.model.FunctionType.Action);
    end
    if SLStudio.Utils.showInToolStrip(cbinfo)
        action.selectedItem=getAnimationSpeedStringFromParamValue(cbinfo.model.Handle);
    end
end

function speedString=getAnimationSpeedStringFromParamValue(bdHandle)
    speedString='';
    switch get_param(bdHandle,'AnimationSpeed')
    case 'lightningfast'
        speedString='simulink_ui:studio:resources:animationLightningFast';
    case 'fast'
        speedString='simulink_ui:studio:resources:animationFast';
    case 'medium'
        speedString='simulink_ui:studio:resources:animationMedium';
    case 'slow'
        speedString='simulink_ui:studio:resources:animationSlow';
    case 'none'
        speedString='simulink_ui:studio:resources:animationNone';
    otherwise
        speedString='simulink_ui:studio:resources:animationNone';
    end
end

function SetAnimationSpeedCB(cbinfo)
    if SLStudio.Utils.showInToolStrip(cbinfo)
        SLStudio.Utils.SetParamValueFromAnimationSpeed(cbinfo.model.Handle,cbinfo.EventData);


        if slfeature('InModelAnimation')==2&&SLStudio.Utils.ModelHasMachine(cbinfo.model)
            machine=cbinfo.model.find('-isa','Stateflow.Machine');
            delaySecs=SFStudio.Utils.getAnimationDelaySecFromSpeedString(replace(cbinfo.EventData,'simulink_ui','stateflow_ui'));
            if~isempty(delaySecs)
                machine.Debug.Animation.Delay=delaySecs;
                machine.Debug.Animation.Enabled=1;
            else
                machine.Debug.Animation.Enabled=0;
            end
        end
    end
end





