function schema=mdlslicermenus(fncname,cbinfo)




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

function res=loc_TestLicense
    res=SliceUtils.isSlicerAvailable();
end

function schema=ModelSlicerDiagramContextMenu(callbackInfo)









    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:ModelSlicerDiagramContextMenu';
    schema.label=getString(message('Simulink:utility:slicerCascadeMenu'));
    if~SliceUtils.isSlicerAvailable()||~isequal(callbackInfo.model.LibraryType,'None')...
        ||modelslicerprivate('isModelOpenForInspect',callbackInfo.Context.StudioApp.blockDiagramHandle)
        schema.state='Hidden';
    elseif slslicer.internal.MenuUtils.checkSlicerUI(callbackInfo)
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end
    subMenus={@DVsliceShowConfig,@DVsliceToggleEditing,'SEPARATOR',@DVsliceClose};

    schema.childrenFcns=subMenus;
    schema.autoDisableWhen='Never';
end


function schema=ModelSlicerSignalContextMenu(callbackInfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:ModelSlicerSignalContextMenu';
    schema.label=getString(message('Simulink:utility:slicerCascadeMenu'));
    schema.state='Hidden';
    if~SliceUtils.isSlicerAvailable()||~isequal(callbackInfo.model.LibraryType,'None')...
        ||modelslicerprivate('isModelOpenForInspect',callbackInfo.Context.StudioApp.blockDiagramHandle)
        schema.state='Hidden';
    elseif slslicer.internal.MenuUtils.checkSlicerUI(callbackInfo)
        schema.state='Enabled';
        subMenus={};
        if slslicer.internal.MenuSlicerUtils.checkHasStart(callbackInfo)
            subMenus={@DVsliceRemoveTarget};
        elseif slslicer.internal.MenuSlicerUtils.checkIsBusSignal(callbackInfo)
            subMenus={@DVsliceAddSignalTarget,@DVsliceAddBusElementTarget};
        elseif slslicer.internal.MenuSlicerUtils.checkHasNonStart(callbackInfo)
            subMenus={@DVsliceAddSignalTarget};
        end


        if slslicer.internal.MenuSlicerUtils.checkHasBusElementStart(callbackInfo)
            subMenus{end+1}=@DVsliceRemoveBusElementTarget;
        end

        if isempty(subMenus)




            schema.state='Hidden';
            return;
        end

        schema.childrenFcns=subMenus;
    end
    schema.autoDisableWhen='Never';
end


function schema=ModelSlicerContextMenu(callbackInfo)%#ok<*DEFNU>
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:ModelSlicerContextMenu';
    schema.label=getString(message('Simulink:utility:slicerCascadeMenu'));

    if~SliceUtils.isSlicerAvailable()||~isequal(callbackInfo.model.LibraryType,'None')...
        ||modelslicerprivate('isModelOpenForInspect',callbackInfo.Context.StudioApp.blockDiagramHandle)
        schema.state='Hidden';
        return;
    end





























    subMenus={};

    if slslicer.internal.MenuSlicerUtils.checkUIOpen(callbackInfo)
        IsMultiSelect=(numel(callbackInfo.getSelection)>1);

        if(IsMultiSelect)

            if~isSFDomain(callbackInfo)
                if(~slslicer.internal.MenuSlicerUtils.checkHasBlockOrLine(callbackInfo))
                    schema.state='Hidden';
                    return;
                end

                HasExclussion=slslicer.internal.MenuSlicerUtils.checkHasExcl(callbackInfo);
                HasNonExclussion=slslicer.internal.MenuSlicerUtils.checkHasNonExcl(callbackInfo);
                HasStart=slslicer.internal.MenuSlicerUtils.checkHasStart(callbackInfo);
                HasNonStart=slslicer.internal.MenuSlicerUtils.checkHasNonStart(callbackInfo);
                HasConstraint=slslicer.internal.MenuSlicerUtils.checkHasConstr(callbackInfo);

                if(HasNonStart)
                    subMenus{end+1}=@DVsliceAddAllTarget;
                end
                if(HasStart)
                    subMenus{end+1}=@DVsliceRemoveAllTarget;
                end
                subMenus{end+1}='SEPARATOR';

                if(HasNonExclussion&&~HasStart)
                    subMenus{end+1}=@DVsliceAddAllTerminal;
                end
                if(HasExclussion)
                    subMenus{end+1}=@DVsliceRemoveAllTerminal;
                end

                if(HasConstraint)
                    subMenus{end+1}='SEPARATOR';
                    subMenus{end+1}=@DVsliceRemoveAllConstraint;
                end
            end
        else
            if~isSFDomain(callbackInfo)
                HasStart=slslicer.internal.MenuSlicerUtils.checkHasStart(callbackInfo);
                HasExclussion=slslicer.internal.MenuSlicerUtils.checkHasExcl(callbackInfo);
                HasConstraint=slslicer.internal.MenuSlicerUtils.checkHasConstr(callbackInfo);
                CanHaveConstraint=slslicer.internal.MenuSlicerUtils.checkSupportsConstr(callbackInfo);

                if slslicer.internal.MenuSlicerUtils.checkSubsystemApplicable(callbackInfo)
                    subMenus{end+1}=@DVsliceSetSubsystem;
                    subMenus{end+1}='SEPARATOR';
                end
                if slslicer.internal.MenuSlicerUtils.checkDeadlogicApplicable(callbackInfo)
                    subMenus{end+1}=@DVRefineDeadLogic;
                    subMenus{end+1}='SEPARATOR';
                end
                if(HasStart)
                    subMenus{end+1}=@DVsliceRemoveTarget;
                elseif(HasExclussion)
                    subMenus{end+1}=@DVsliceRemoveTerminal;
                else
                    subMenus{end+1}=@DVsliceAddTarget;
                    if~HasConstraint
                        subMenus{end+1}=@DVsliceAddTerminal;
                    end
                end

                if(~HasExclussion&&(HasConstraint||CanHaveConstraint))
                    subMenus{end+1}='SEPARATOR';
                    if(HasConstraint)
                        subMenus{end+1}=@DVsliceEditConstraint;
                        subMenus{end+1}=@DVsliceRemoveConstraint;
                    else
                        subMenus{end+1}=@DVsliceAddContraint;
                    end
                end
            else
                CanHaveCovConstraint=slslicer.internal.MenuSlicerUtils.checkSupportsCovConstr(callbackInfo);
                HasCovConstraint=slslicer.internal.MenuSlicerUtils.checkHasCovConstr(callbackInfo);
                if(HasCovConstraint||CanHaveCovConstraint)
                    subMenus{end+1}='SEPARATOR';
                    if(HasCovConstraint)
                        subMenus{end+1}=@DVsliceRemoveCovConstraint;
                    else
                        subMenus{end+1}=@DVsliceAddCovConstraint;
                    end
                end
            end
        end
    else
        if slslicer.internal.MenuSlicerUtils.checkSubsystemApplicable(callbackInfo,false)
            subMenus{end+1}='separator';
            subMenus{end+1}=@DVsliceSubsystem;
        end
    end

    if slslicer.internal.MenuSlicerUtils.checkHasSlice(callbackInfo)
        if isempty(subMenus)
            subMenus={@DVshowInSlice};
        else
            subMenus=[subMenus,{'SEPARATOR',@DVshowInSlice}];
        end
    end

    if slslicer.internal.MenuSlicerUtils.checkIsASlice(callbackInfo)
        if isempty(subMenus)
            subMenus={@DVshowInOriginal};
        else
            subMenus=[subMenus,{'SEPARATOR',@DVshowInOriginal}];
        end
    end

    if isempty(subMenus)
        schema.state='Hidden';
    else
        schema.state='Enabled';
        schema.childrenFcns=subMenus;
        schema.autoDisableWhen='Never';
    end
end

function schema=DVsliceShowConfig(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:openDialog'));
    schema.tag='Simulink:DVsliceShowConfig';
    schema.callback=@DVsliceShowConfig_callback;
    schema.autoDisableWhen='Never';
end

function schema=DVsliceToggleEditing(callbackInfo)
    schema=sl_action_schema;

    inEditMode=slslicer.internal.MenuSlicerUtils.checkIsEditable(callbackInfo);

    if(inEditMode)
        schema.label=getString(message('Sldv:MdlSlicer:resumeAnalysis'));
    else
        schema.label=getString(message('Sldv:MdlSlicer:enableEdit'));
    end

    schema.tag='Simulink:DVsliceToggleEditing';
    schema.callback=@DVsliceToggleEditing_callback;
    schema.autoDisableWhen='Never';

    if slslicer.internal.MenuSlicerUtils.checkIsSimDlgOpen(callbackInfo)
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
end

function schema=DVsliceClose(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:close'));
    schema.tag='Simulink:DVsliceClose';
    schema.callback=@DVsliceClose_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceAddTarget(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:sliceAddTarget'));
    schema.tag='Simulink:DVsliceAddTarget';
    schema.callback=@DVsliceAddTarget_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceAddTerminal(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:sliceAddTerminal'));
    schema.tag='Simulink:DVsliceAddTerminal';
    schema.callback=@DVsliceAddTerminal_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVshowInSlice(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:showInSlice'));
    schema.tag='Simulink:DVshowInSlice';
    schema.callback=@DVshowInSlice_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVshowInOriginal(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:showInOriginal'));
    schema.tag='Simulink:DVshowInOriginal';
    schema.callback=@DVshowInOriginal_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceAddSignalTarget(callbackInfo)
    schema=sl_action_schema;
    if slslicer.internal.MenuSlicerUtils.checkIsBusSignal(callbackInfo)
        schema.label=getString(message('Sldv:MdlSlicer:sliceAddBusTarget'));
    else
        schema.label=getString(message('Sldv:MdlSlicer:sliceAddTarget'));
    end
    schema.tag='Simulink:DVsliceAddSignalTarget';
    schema.callback=@DVsliceAddSignalTarget_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceAddBusElementTarget(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:sliceAddBusElementTarget'));
    schema.tag='Simulink:DVsliceAddBusElementTarget';
    schema.callback=@DVsliceAddBusElementTarget_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceAddAllTarget(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:sliceAddAllTarget'));
    schema.tag='Simulink:DVsliceAddAllTarget';
    schema.callback=@DVsliceAddAllTarget_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end


function schema=DVsliceAddAllTerminal(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:sliceAddAllTerminal'));
    schema.tag='Simulink:DVsliceAddAllTerminal';
    schema.callback=@DVsliceAddAllTerminal_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end


function schema=DVsliceAddContraint(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerAddContraint'));
    schema.tag='Simulink:DVsliceAddContraint';
    schema.callback=@DVsliceAddContraint_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end


function schema=DVsliceEditConstraint(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerEditConstraint'));
    schema.tag='Simulink:DVsliceEditConstraint';
    schema.callback=@DVsliceEditConstraint_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceRemoveConstraint(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerRemoveConstraint'));
    schema.tag='Simulink:DVsliceRemoveConstraint';
    schema.callback=@DVsliceRemoveConstraint_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceAddCovConstraint(callbackInfo)
    schema=sl_action_schema;
    if isa(callbackInfo.domain,'SLM3I.SLDomain')
        schema.label=getString(message('Sldv:MdlSlicer:slicerAddCovContraint'));
    else
        objs=SFStudio.Utils.getSelectedStatesAndTransitionIds(callbackInfo);
        objs=arrayfun(@(o)idToHandle(sfroot,o),objs,'uni',false);
        objs=[objs{:}];
        if isa(objs,'Stateflow.Transition')
            schema.label=getString(message('Sldv:MdlSlicer:slicerStateConstraint',objs.LabelString));
        else
            schema.label=getString(message('Sldv:MdlSlicer:slicerStateConstraint',objs.Name));
        end
    end
    schema.tag='Simulink:DVsliceAddCovConstraint';
    schema.callback=@DVsliceAddCovConstraint_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceRemoveCovConstraint(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerRemoveCovConstraint'));
    schema.tag='Simulink:DVsliceRemoveCovConstraint';
    schema.callback=@DVsliceRemoveCovConstraint_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end


function schema=DVsliceRemoveTarget(callbackInfo)
    schema=sl_action_schema;


    if slslicer.internal.MenuSlicerUtils.checkIsBusSignal(callbackInfo)
        schema.label=getString(message('Sldv:MdlSlicer:slicerRemoveBusTarget'));
    else
        schema.label=getString(message('Sldv:MdlSlicer:slicerRemoveTarget'));
    end

    schema.tag='Simulink:DVsliceRemoveTarget';
    schema.callback=@DVsliceRemoveTarget_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceRemoveBusElementTarget(callbackInfo)
    schema=sl_action_schema;
    schema.label=...
    getString(message('Sldv:MdlSlicer:slicerRemoveBusElementTarget'));
    schema.tag='Simulink:DVsliceRemoveBusElementTarget';
    schema.callback=@DVsliceRemoveBusElementTarget_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceRemoveTerminal(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerRemoveTerminal'));
    schema.tag='Simulink:DVsliceslicerRemoveTerminal';
    schema.callback=@DVsliceRemoveTerminal_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceRemoveAllConstraint(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerRemoveAllConstraint'));
    schema.tag='Simulink:DVsliceRemoveAllConstraint';
    schema.callback=@DVsliceRemoveAllConstraint_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end


function schema=DVsliceRemoveAllTarget(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerRemoveAllTarget'));
    schema.tag='Simulink:DVsliceRemoveAllTarget';
    schema.callback=@DVsliceRemoveAllTarget_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end


function schema=DVsliceRemoveAllTerminal(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerRemoveAllTerminal'));
    schema.tag='Simulink:DVsliceRemoveAllTerminal';
    schema.callback=@DVsliceRemoveAllTerminal_callback;
    schema.autoDisableWhen='Never';
    schema.state=stateEnableOrDisable(callbackInfo);
end

function schema=DVsliceSubsystem(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerSetSubsystem'));
    schema.tag='Simulink:DVsliceSetSubsystem';
    schema.callback=@DVsliceSetSubsystem_callback;
    schema.autoDisableWhen='Never';
    schema.state=getComponentValidity(callbackInfo);
end

function DVsliceSetSubsystem_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbSetSubsystem(callbackInfo);
end

function DVsliceSelectSubsystem_callback(callbackInfo)
    slslicer.internal.MenuCallbackUtils.slicerSelectSubsystem(callbackInfo);
end

function schema=DVRefineDeadLogic(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerRefineComponent'));
    schema.tag='Simulink:DVRefineComponent';
    schema.callback=@DVsliceRefineDeadlogic_callback;
    schema.autoDisableWhen='Never';
    if license('test','Simulink_Design_Verifier')
        schema.state=getComponentValidity(callbackInfo);
    else
        schema.state='Disabled';
    end
end

function DVsliceRefineDeadlogic_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbRefineDeadlogic(callbackInfo);
end

function schema=DVsliceSetSubsystem(callbackInfo)
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:slicerSetSubsystem'));
    schema.tag='Simulink:DVsliceSelectSubsystem';
    schema.state=getComponentValidity(callbackInfo);
    schema.callback=@DVsliceSelectSubsystem_callback;
    schema.autoDisableWhen='Never';
end

function state=getComponentValidity(callbackInfo)
    state='Hidden';
    obj=SLStudio.Utils.getOneMenuTarget(callbackInfo);
    if SLStudio.Utils.objectIsValidSubsystemBlock(obj)
        if slslicer.internal.MenuSlicerUtils.checkSubsystemInHarness(callbackInfo)
            state='Disabled';
        elseif sldvprivate('util_menu','check_atomic_subsys',callbackInfo)
            state=stateEnableOrDisable(callbackInfo);
        end
    elseif SLStudio.Utils.objectIsValidModelReferenceBlock(obj)
        if~slslicer.internal.MenuSlicerUtils.checkSubsystemInHarness(callbackInfo)
            state=stateEnableOrDisable(callbackInfo);
        else
            state='Disabled';
        end
    end
end

function DVsliceAddSignalTarget_callback(callbackInfo)
    segments=SLStudio.Utils.getSelectedSegments(callbackInfo);
    callbackInfo.userdata=[segments.handle];
    slslicer.internal.MenuSlicerUtils.cbAddTarget(callbackInfo);
end

function DVsliceAddBusElementTarget_callback(callbackInfo)
    show(Simulink.BusHierarchyViewerWindowMgr.getDialog(callbackInfo.editorModel.Name));
end

function DVmodelslice_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbOpen(callbackInfo);
end

function DVsliceShowConfig_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbShowDialog(callbackInfo);
end
function DVsliceToggleEditing_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbToggleEdit(callbackInfo);
end
function DVsliceClose_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbClose(callbackInfo);
end

function DVsliceAddTarget_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbAddTarget(callbackInfo);
end

function DVsliceAddTerminal_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbAddTerminal(callbackInfo);
end

function DVshowInSlice_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbShowInSlice(callbackInfo);
end

function DVshowInOriginal_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbShowInOrig(callbackInfo);
end

function DVsliceAddAllTarget_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbAddTarget(callbackInfo);
end

function DVsliceAddAllTerminal_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbAddTerminal(callbackInfo);
end

function DVsliceAddContraint_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbAddConstraint(callbackInfo);
end

function DVsliceRemoveConstraint_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbRemoveConstraint(callbackInfo);
end

function DVsliceEditConstraint_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbEditConstraint(callbackInfo);
end

function DVsliceAddCovConstraint_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbAddCovConstraint(callbackInfo);
end

function DVsliceRemoveCovConstraint_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbRemoveCovConstraint(callbackInfo);
end

function DVsliceRemoveTarget_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbRemoveTarget(callbackInfo);
end

function DVsliceRemoveBusElementTarget_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbRemoveBusElementTarget(callbackInfo);
end

function DVsliceRemoveTerminal_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbRemoveTerminal(callbackInfo);
end

function DVsliceRemoveAllConstraint_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbRemoveConstraint(callbackInfo);
end

function DVsliceRemoveAllTarget_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbRemoveTarget(callbackInfo);
end

function DVsliceRemoveAllTerminal_callback(callbackInfo)
    slslicer.internal.MenuSlicerUtils.cbRemoveTerminal(callbackInfo);
end

function state=stateEnableOrDisable(callbackInfo)
    if~slslicer.internal.MenuSlicerUtils.checkIsEditable(callbackInfo)...
        &&~slslicer.internal.MenuSlicerUtils.checkIsDialogBusy(callbackInfo)
        state='Enabled';
    else
        state='Disabled';
    end
end


function schema=DVmodelslice(callbackInfo)%#ok<REDEF,*INUSD>
    schema=sl_action_schema;
    schema.label=getString(message('Sldv:MdlSlicer:modelSliceLabel'));
    schema.tag='Simulink:ModelSlicerMenu';
    schema.callback=@DVmodelslice_callback;
    schema.state='Enabled';
    schema.autoDisableWhen='Busy';
end

function yesno=isSFDomain(callbackInfo)
    yesno=isa(callbackInfo.domain,'StateflowDI.SFDomain');
end


