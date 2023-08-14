function schema=sldvmenus(fncname,cbinfo,eventData)



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
    res=license('test','Simulink_Design_Verifier');
end

function schema=DesignVerifierMenuBase(~)
    schema=sl_container_schema;
    schema.tag='Simulink:DesignVerifierMenu';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierMenu');
    schema.state='Disabled';
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function res=IsValidSubsystemBlock(block)
    res=SLStudio.Utils.objectIsValidSubsystemBlock(block);


    if res==true&&...
        strcmp(get_param(bdroot(block.handle),'isHarness'),'on')&&...
        ~Simulink.harness.internal.isHarnessCUT(block.handle)
        res=false;
    end
end

function state=loc_getDesignVerifierContextMenuState(cbinfo)
    assert(cbinfo.isContextMenu);
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    state='Hidden';
    if IsValidSubsystemBlock(block)
        if sldvprivate('util_menu','check_subsys',cbinfo)
            state=loc_getDesignVerifierMenuState(cbinfo);
        else
            state='Disabled';
        end
    elseif(slavteng('feature','ExtractModelReference')>0)&&...
        SLStudio.Utils.objectIsValidModelReferenceBlock(block)
        state=loc_getDesignVerifierMenuState(cbinfo);
    end
end

function schema=DesignVerifierContextMenu(cbinfo)
    schema=DesignVerifierMenuBase(cbinfo);

    schema.state=loc_getDesignVerifierContextMenuState(cbinfo);

    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if IsValidSubsystemBlock(obj)
        if sldvprivate('util_menu','check_atomic_subsys',cbinfo)
            schema.childrenFcns={@DVcompatibilitySubsys,...
            'separator',...
            @DVtestgenSubsys,...
            @DVdetectsubsys,...
            @DVproveSubsys,...
            'separator',...
            @DVsettingsSubsys
            };
        else
            schema.childrenFcns={@DVMakeSubsystemAtomic
            };
        end
    elseif SLStudio.Utils.objectIsValidModelReferenceBlock(obj)
        schema.childrenFcns={@DVcompatibilityModelRef,...
        'separator',...
        @DVdetectModelRef,...
        @DVtestgenModelRef,...
        @DVSimNTestgenModelRef,...
        @DVproveModelRef,...
        'separator',...
        @DVsettingsModelRef
        };
    end
end

function state=loc_getDVMakeSubsystemAtomicState(cbinfo)
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if IsValidSubsystemBlock(obj)
        if~sldvprivate('util_menu','check_atomic_subsys',cbinfo)
            state=loc_getDesignVerifierMenuState(cbinfo);
        else
            state='Disabled';
        end
    else
        state='Disabled';
    end
end

function schema=DVMakeSubsystemAtomic(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVMakeSubsystemAtomic';
    schema.label=DAStudio.message('Simulink:studio:DVMakeSubsystemAtomic');
    schema.userdata='show_subsystem_params';

    schema.state=loc_getDVMakeSubsystemAtomicState(cbinfo);

    schema.callback=@DesignVerifierMenuCB;
end

function state=loc_getDesignVerifierSubsystemState(cbinfo)
    state='Enabled';
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~IsValidSubsystemBlock(obj)||...
        ~sldvprivate('util_menu','check_atomic_subsys',cbinfo)
        if cbinfo.isContextMenu
            state='Hidden';
        else
            state='Disabled';
        end
    end
end

function schema=DVcompatibility(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVcompatibility';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierModel');
    schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);
    schema.userdata='compat';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVcompatibilityCode(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVcompatibilityCode';
    schema.label=DAStudio.message('Sldv:dialog:sldvTestGenForCodeGen');
    schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);
    schema.userdata='compat_code';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVcompatibilityCodeModelRef(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVcompatibilityCodeModelRef';
    schema.label=DAStudio.message('Sldv:dialog:sldvTestGenForCodeGenModelRef');
    schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);
    schema.userdata='compat_code_modelref';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVcompatibilitySubsys(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVcompatibilitySubsys';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:DVcompatibilitySubsys');
    else
        schema.label=DAStudio.message('Simulink:studio:DesignVerifierSubsystem');
    end
    schema.state=loc_getDesignVerifierSubsystemState(cbinfo);
    schema.userdata='subsys_compat';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVdetect(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVdetect';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierModel');
    schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);
    schema.userdata='detectErrors';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVcompatibilityModelRef(~)
    schema=sl_action_schema;
    schema.tag='Simulink:DVcompatibilityModelRef';
    schema.label=DAStudio.message('Simulink:studio:DVcompatibilityModelRef');
    schema.state='Enabled';
    schema.userdata='subsys_compat';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVdetectModelRef(~)
    schema=sl_action_schema;
    schema.tag='Simulink:DVdetectModelRef';
    schema.label=DAStudio.message('Simulink:studio:DVdetectModelRef');
    schema.state='Enabled';
    schema.userdata='subsys_detectErrors';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVtestgenModelRef(~)
    schema=sl_action_schema;
    schema.tag='Simulink:DVtestgenModelRef';
    schema.label=DAStudio.message('Simulink:studio:DVtestgenModelRef');
    schema.state='Enabled';
    schema.userdata='subsys_testgen';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVSimNTestgenModelRef(~)
    schema=sl_action_schema;
    schema.tag='Simulink:DVSimNTestgenModelRef';
    schema.label=DAStudio.message('Simulink:studio:DVSimNTestgenModelRef');
    schema.state='Enabled';
    schema.userdata='sim_testgen';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVproveModelRef(~)
    schema=sl_action_schema;
    schema.tag='Simulink:DVproveModelRef';
    schema.label=DAStudio.message('Simulink:studio:DVproveModelRef');
    schema.state='Enabled';
    schema.userdata='subsys_prove';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVsettingsModelRef(~)
    schema=sl_action_schema;
    schema.tag='Simulink:DVsettingsModelRef';
    schema.label=DAStudio.message('Simulink:studio:DVsettings');
    schema.state='Enabled';
    schema.userdata='subsys_options';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVdetectsubsys(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVdetectsubsys';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:DVdetectsubsys');
    else
        schema.label=DAStudio.message('Simulink:studio:DesignVerifierSubsystem');
    end
    schema.state=loc_getDesignVerifierSubsystemState(cbinfo);
    schema.userdata='subsys_detectErrors';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVtestgen(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVtestgen';
    schema.state=loc_getDesignVerifierMenuState(cbinfo);

    if slavteng('feature','TopItOff')&&Sldv.HarnessUtils.isSldvGenHarness(cbinfo.model.Handle)
        schema.userdata='testgen_missing_coverage';
        schema.label=DAStudio.message('Sldv:TopItOff:MissingCoverage');
        if isempty(getSldvRefHarnessName(cbinfo.model.Handle))
            schema.state='Disabled';
        end
    else
        schema.userdata='testgen';
        schema.label=DAStudio.message('Simulink:studio:DesignVerifierModel');
    end

    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVtestgenSubsys(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVtestgenSubsys';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:DVtestgenSubsys');
    else
        schema.label=DAStudio.message('Simulink:studio:DesignVerifierSubsystem');
    end
    schema.state=loc_getDesignVerifierSubsystemState(cbinfo);
    schema.userdata='subsys_testgen';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVtestgenCode(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVtestgenCode';
    schema.state=loc_getDesignVerifierMenuState(cbinfo);
    schema.userdata='testgen_code';
    schema.label=DAStudio.message('Sldv:dialog:sldvTestGenForCodeGen');
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVtestgenCodeModelRef(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVtestgenCodeModelRef';
    schema.state=loc_getDesignVerifierMenuState(cbinfo);
    schema.userdata='testgen_code_modelref';
    schema.label=DAStudio.message('Sldv:dialog:sldvTestGenForCodeGenModelRef');
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVprove(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVprove';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierModel');
    schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);
    schema.userdata='prove';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVproveSubsys(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVproveSubsys';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:DVproveSubsys');
    else
        schema.label=DAStudio.message('Simulink:studio:DesignVerifierSubsystem');
    end
    schema.state=loc_getDesignVerifierSubsystemState(cbinfo);
    schema.userdata='subsys_prove';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVloadResultsFile(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVloadResultsFile';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierLoadResultsFile');
    schema.state=loc_getDesignVerifierMenuState(cbinfo);
    schema.userdata='load_results_file';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVtestgenAdvisor(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVtestgenAdvisor';
    schema.label=DAStudio.message('Sldv:ComponentAdvisor:DesignVerifierComponentAdvisorMenu');
    schema.state=loc_getDVtestgenAdvisorMenuState(cbinfo);
    schema.userdata='component_advisor';
    schema.callback=@DesignVerifierMenuCB;
end

function state=loc_getDVtestgenAdvisorMenuState(cbinfo)
    if slavteng('feature','Component_Advisor')
        state=loc_getDesignVerifierMenuState(cbinfo);
        if sldv.code.internal.isXilFeatureEnabled()

            modelName=SLStudio.Utils.getModelName(cbinfo);
            if~isempty(modelName)
                try


                    dvOpts=sldvoptions(modelName);
                    if dvOpts.TestgenTarget~="Model"
                        state='Disabled';
                    end
                catch
                end
            end
        end
    else
        state='Hidden';
    end
end

function state=loc_getDVactiveResultsState(cbinfo)


    state=loc_getDesignVerifierMenuState(cbinfo);
    if~strcmpi(state,'Disabled')
        modelH=cbinfo.model.Handle;

        resultFiles=sldvprivate('mdl_current_results',modelH);
        if~isempty(resultFiles.DataFile)&&(2==exist(resultFiles.DataFile,'file'))
            state='Enabled';
        else

            state='Disabled';
        end
    end
end

function schema=DVloadActiveResults(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVloadActiveResults';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierLoadActiveResults');
    schema.state=loc_getDVactiveResultsState(cbinfo);
    schema.userdata='load_active_results';
    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVsettings(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVsettings';

    if slavteng('feature','TopItOff')&&Sldv.HarnessUtils.isSldvGenHarness(cbinfo.model.Handle)&&...
        ~isempty(getSldvRefHarnessName(cbinfo.model.Handle))
        schema.label=DAStudio.message('Sldv:TopItOff:SettingsRefModel',getSldvRefHarnessName(cbinfo.model.Handle));
        schema.userdata='optionsReferencedModel';
        schema.state=loc_getDesignVerifierMenuState(cbinfo);
    else
        schema.label=DAStudio.message('Simulink:studio:DVsettings');
        schema.userdata='options';
        schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);
    end

    schema.callback=@DesignVerifierMenuCB;
end

function schema=DVsettingsSubsys(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DVsettingsSubsys';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:DVsettingsSubsys');
    else
        schema.label=DAStudio.message('Simulink:studio:DesignVerifierSubsystem');
    end
    schema.state=loc_getDesignVerifierSubsystemState(cbinfo);
    schema.userdata='subsys_options';
    schema.callback=@DesignVerifierMenuCB;
end

function DesignVerifierMenuCB(cbinfo)
    type=cbinfo.userdata;
    sldvprivate('util_menu_callback',type,cbinfo);
end




function referencedModel=getSldvRefHarnessName(harnessH)
    referencedModel='';
    block=find_system(harnessH,'SearchDepth',1,'BlockType','ModelReference');
    if isempty(block)||length(block)>1||strcmp(get_param(block,'ProtectedModel'),'on')
        return;
    else
        referencedModel=get_param(block,'ModelName');
    end
end

function state=DVmenuStateDisableHarnessMdl(cbinfo)
    state='Enabled';

    if slavteng('feature','TopItOff')&&Sldv.HarnessUtils.isSldvGenHarness(cbinfo.model.Handle)
        state='Disabled';
    end
end


function state=loc_getDesignVerifierMenuState(cbinfo,state_upd_fn)
    if nargin<2
        state_upd_fn=[];
    end
    if loc_TestLicense
        state='Enabled';
        if isa(state_upd_fn,'function_handle')
            state=state_upd_fn(cbinfo);
        end
    else
        state='Disabled';
    end
end

function schema=DesignVerifierMenu(cbinfo)
    schema=DesignVerifierMenuBase(cbinfo);

    schema.state=loc_getDesignVerifierMenuState(cbinfo);

    schema.childrenFcns={@DesignVerifierCompatibilityMenu,...
    'separator',...
    @DesignVerifierDetectErrorsMenu,...
    @DesignVerifierGenerateTestsMenu,...
    @DesignVerifierProvePropertiesMenu,...
    @DesignVerifierResultsMenu,...
    'separator',...
    @DVsettings
    };

end

function schema=DesignVerifierCompatibilityMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:DesignVerifierCompatibilityMenu';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierCompatibilityMenu');
    schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:DVcompatibility'),...
    'separator',...
    im.getAction('Simulink:DVMakeSubsystemAtomic'),...
    im.getAction('Stateflow:DVMakeAtomicSubchart'),...
    im.getAction('Simulink:DVcompatibilitySubsys'),...
    im.getAction('Stateflow:DVcompatibilityAtomicSubchart')
    };
    if sldv.code.internal.isXilFeatureEnabled()
        schema.childrenFcns=[...
        schema.childrenFcns,...
        {'separator',...
        im.getAction('Simulink:DVcompatibilityCode'),...
        im.getAction('Simulink:DVcompatibilityCodeModelRef')...
        }];
    end
end

function schema=DesignVerifierDetectErrorsMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:DesignVerifierDetectErrorsMenu';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierDetectErrorsMenu');
    schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:DVdetect'),...
    im.getAction('Simulink:DVdetectsubsys'),...
    im.getAction('Stateflow:DVdetecterrorsSubchart')
    };
end

function schema=DesignVerifierGenerateTestsMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:DesignVerifierGenerateTestsMenu';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierGenerateTestsMenu');
    schema.state=loc_getDesignVerifierMenuState(cbinfo);
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:DVtestgen'),...
    im.getAction('Simulink:DVtestgenSubsys'),...
    im.getAction('Stateflow:DVtestgenSubchart'),...
    'separator',...
    im.getAction('Simulink:DVtestgenAdvisor')
    };
    if sldv.code.internal.isXilFeatureEnabled()


        if~(slavteng('feature','TopItOff')&&Sldv.HarnessUtils.isSldvGenHarness(cbinfo.model.Handle))
            schema.childrenFcns=[...
            schema.childrenFcns(1:3),...
            {'separator',...
            im.getAction('Simulink:DVtestgenCode'),...
            im.getAction('Simulink:DVtestgenCodeModelRef')...
            },...
            schema.childrenFcns(4:end)];
        end
    end
end

function schema=DesignVerifierProvePropertiesMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:DesignVerifierProvePropertiesMenu';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierProvePropertiesMenu');
    schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:DVprove'),...
    im.getAction('Simulink:DVproveSubsys'),...
    im.getAction('Stateflow:DVproveSubchart')
    };
end


function schema=DesignVerifierResultsMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:DesignVerifierResultsMenu';
    schema.label=DAStudio.message('Simulink:studio:DesignVerifierResultsMenu');
    schema.state=loc_getDesignVerifierMenuState(cbinfo,@DVmenuStateDisableHarnessMdl);



    token=Sldv.Token.get;
    if token.isInUse
        schema.state='Disabled';
    end
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:DVloadActiveResults'),...
    im.getAction('Simulink:DVloadResultsFile')
    };
end


function schema=DesignVerifierContextMenuSF(cbinfo)
    schema=DesignVerifierMenuBase(cbinfo);

    schema.state=loc_getDesignVerifierContextMenuSFState(cbinfo);

    if isa(cbinfo.getSelection,'Stateflow.AtomicSubchart')
        schema.childrenFcns={@DVcompatibilityAtomicSubchart,...
        'separator',...
        @DVdetecterrorsSubchart,...
        @DVtestgenSubchart,...
        @DVproveSubchart,...
        'separator',...
        @DVsettingsSubchart
        };
    else
        schema.childrenFcns={@DVMakeAtomicSubchart
        };
    end
end

function state=loc_getDesignVerifierContextMenuSFState(cbinfo)
    sfstate=SFStudio.Utils.getStateflowState(cbinfo);
    if isempty(sfstate)||(~sfstate.isSubchart&&~sfstate.isAtomicSubchart)...
        ||sfprivate('is_state_transition_table_chart',double(sfstate.subviewerId))
        if cbinfo.isContextMenu
            state='Hidden';
        else
            state='Disabled';
        end
    else
        try
            isAllowed=sldvprivate('util_menu','sldv_menu_allowed',cbinfo);
        catch Mex %#ok<NASGU>
            isAllowed=false;
        end
        if isAllowed
            state='Enabled';
        else
            state='Disabled';
        end
    end
end

function schema=DVMakeAtomicSubchart(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Stateflow:studio:DVMakeSubchartAtomic');
    schema.tag='Stateflow:DVMakeAtomicSubchart';
    if slreq.utils.selectionHasMarkup(cbinfo)
        schema.state='Disabled';
    elseif isa(cbinfo.getSelection,'Stateflow.State')
        schema.state='Enabled';
    else
        if cbinfo.isContextMenu
            schema.state='Hidden';
        else
            schema.state='Disabled';
        end
    end
    schema.callback=@DVMakeAtomicSubchartCB;
end

function DVMakeAtomicSubchartCB(cbinfo)
    [state,~]=SFStudio.Utils.getRootStateAndModel(cbinfo);
    sfprivate('toggleIsAtomicSubchart',cbinfo.studio.App.getActiveEditor,state);
end

function schema=DVcompatibilityAtomicSubchart(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Stateflow:studio:DVcompatibilitySubchart');
    schema.tag='Stateflow:DVcompatibilityAtomicSubchart';
    schema.state=loc_getDesignVerifierContextMenuSFState(cbinfo);
    schema.userdata='sf_atomicsubchart_compat';
    schema.callback=@DesignVerifierMenuSFCB;
end

function schema=DVdetecterrorsSubchart(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Stateflow:studio:DVdetectsubchart');
    schema.tag='Stateflow:DVdetecterrorsSubchart';
    schema.state=loc_getDesignVerifierContextMenuSFState(cbinfo);
    schema.userdata='sf_atomicsubchart_detecterrors';
    schema.callback=@DesignVerifierMenuSFCB;
end

function schema=DVtestgenSubchart(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Stateflow:studio:DVtestgenSubchart');
    schema.tag='Stateflow:DVtestgenSubchart';
    schema.state=loc_getDesignVerifierContextMenuSFState(cbinfo);
    schema.userdata='sf_atomicsubchart_testgen';
    schema.callback=@DesignVerifierMenuSFCB;
end

function schema=DVproveSubchart(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Stateflow:studio:DVproveSubchart');
    schema.tag='Stateflow:DVproveSubchart';
    schema.state=loc_getDesignVerifierContextMenuSFState(cbinfo);
    schema.userdata='sf_atomicsubchart_prove';
    schema.callback=@DesignVerifierMenuSFCB;
end

function schema=DVsettingsSubchart(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Stateflow:studio:DVsettingsSubchart');
    schema.tag='Stateflow:DVsettingsSubchart';
    schema.state=loc_getDesignVerifierContextMenuSFState(cbinfo);
    schema.userdata='sf_atomicsubchart_options';
    schema.callback=@DesignVerifierMenuSFCB;
end

function DesignVerifierMenuSFCB(cbinfo)

    sldvprivate('util_menu_callback',cbinfo.userdata,cbinfo);
end







