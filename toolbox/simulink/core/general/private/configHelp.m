function configHelp(hDlg,hObj,schemaName,page,varargin)



    subPage=[];

    if strcmp(page,'ConfigSet')&&strcmp(schemaName,'simprm')
        hSrc=hObj.getSourceObject;
        currentPage=hSrc.CurrentDlgPage;
        [page,subPage]=strtok(currentPage,'/');

    elseif strcmp(page,message('RTW:configSet:configSetCodeGen').getString)&&...
        (isempty(schemaName)||strcmp(schemaName,'Code Generation')||strcmp(schemaName,'default'))

        page='Code Generation';
        hSrc=hObj.getSourceObject;
        pageID=hSrc.ActiveTab+1;
        pages=varargin{1};
        pages=pages{1};
        subPage=pages{pageID};


    elseif strcmp(page,message('RTW:configSet:configSetOptimization').getString)&&...
        (isempty(schemaName)||strcmp(schemaName,'Optimization')||strcmp(schemaName,'default'))
        page='Optimization';
        pages={'General','Signals and Parameters','Stateflow'};
        subPage=pages{hObj.ActiveTab+1};

    elseif strcmp(page,message('RTW:configSet:configSetDiagnostics').getString)&&...
        (isempty(schemaName)||strcmp(schemaName,'Diagnostics')||strcmp(schemaName,'default'))
        page='Diagnostics';
        pages={'Solver','Sample Time','Data Validity','Type Conversion',...
        'Connectivity','Compatibility','Model Referencing','Stateflow'};
        subPage=pages{hObj.ActiveTab+1};

    elseif strcmp(page,message('RTW:configSet:configSetSimulation').getString)&&...
        (isempty(schemaName)||strcmp(schemaName,'Simulation Target')||strcmp(schemaName,'default'))
        page='Simulation Target';
        pages={'General'};
        hSrc=hObj.getSourceObject;
        pageID=hSrc.ActiveTab+1;
        subPage=pages{pageID};

    else
        if isa(hObj,'Simulink.ConfigSetDialogController')
            hObj=hObj.getSourceObject;
        end


        if strcmp(page,message('HDLShared:hdldialog:hdlccHDLCodername').getString)&&...
            (isempty(schemaName)||strcmp(schemaName,'HDL Code Generation')||strcmp(schemaName,'default'))
            page='HDL Code Generation';
            pages={'General','Target','Optimization','Floating Point','Global Settings','Report','Test Bench','EDA Tool Scripts'};
            subPage=pages{hObj.HDLCActiveTab+1};

        elseif strcmp(page,'Simscape')&&...
            (isempty(schemaName)||strcmp(schemaName,'Simscape')||strcmp(schemaName,'default'))
            subPage='';

            switch(hObj.getActiveTab)
            case 0
                subPage='General';
            case 1
                page='Simscape Multibody 1G';
            case 2
                page='Simscape Multibody';
            end

        elseif strcmp(page,'Coverage')&&...
            (isempty(schemaName)||strcmp(schemaName,'Coverage')||strcmp(schemaName,'default'))
            page='Coverage';

        elseif strcmp(page,'Design Verifier')&&...
            (isempty(schemaName)||strcmp(schemaName,'Design Verifier')||strcmp(schemaName,'default'))
            pages={'General','Block Replacements','Parameters','Test Generation',...
            'Design Error Detection','Property Proving','Results','Report','S-Functions'};
            subPage=pages{hObj.getActiveTab+1};

        elseif strcmp(page,'PLC Code Generation')
            pages={'Main','Comments','Optimization','Identifiers','Report'};
            subPage=pages{hObj.PLC_ActiveTab+1};
        end
    end

    topic='help_button';

    switch page

    case 'ConfigSet'
        map='mapkey:Simulink.ConfigSet';

    case{'Solver',message('RTW:configSet:configSetSolver').getString}
        map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_Solver_Panel';

    case{'Data Import','Data Import/Export',strtok(message('RTW:configSet:configSetDataIO').getString,'/'),message('RTW:configSet:configSetDataIO').getString}
        map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_DataIO_Panel';

    case{'Optimization',message('RTW:configSet:configSetOptimization').getString}
        if isempty(subPage)
            curPage='General';
        else
            curPage=strtok(subPage,'/');
        end

        switch curPage
        case 'General'
            map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_Optimization_Panel';
        case 'Signals and Parameters'
            map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_Optimization_Signals_Parameters_Panel';
        case 'Stateflow'
            map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_Optimization_Stateflow_Panel';
        end

    case 'Math and Data Types'
        map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_MathAndDataTypes_Panel';

    case 'Diagnostics'
        if isempty(subPage)
            curPage='Solver';
        else
            curPage=strtok(subPage,'/');
        end

        if strcmp(curPage,'Saving')
            curPage='Save';
        end

        curPage=strrep(curPage,' ','_');
        map=['mapkey:Simulink.ConfigSet@Tag_ConfigSet_Debug_'...
        ,curPage,'_Group'];

    case{'Hardware Implementation',message('RTW:configSet:configSetHardware').getString}
        map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_Hardware__Implementation_Panel';

    case{'Model Referencing',message('RTW:configSet:configSetModelRef').getString}
        map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_ModelReferencing_Panel';

    case{'Simulation Target',message('RTW:configSet:configSetSimulation').getString}
        curPage='General';
        map=['mapkey:Simulink.ConfigSet@Tag_ConfigSet_Sim_',curPage];

    case 'Code Generation'

        if isempty(subPage)
            curPage='General';
        else
            curPage=strtok(subPage,'/');
        end

        switch curPage
        case{'General',message('RTW:configSet:RTWGeneralName').getString}
            curPageTag='General_Panel';
        case{'Comments',message('RTW:configSet:comments').getString}
            curPageTag='Comments';
        case{'Report',message('RTW:configSet:RTWReportTabName').getString}
            curPageTag='Report';
        case{'Identifiers',message('RTW:configSet:RTWIdentifiersTabName').getString}
            curPageTag='Symbols';
        case{'Custom Code',message('RTW:configSet:customCodeTabName').getString}
            curPageTag='CustomCode_Panel';
        case{'Debug',message('RTW:configSet:RTWDebugTabName').getString}
            curPageTag='Debug_Panel';
        case{'Interface',message('RTW:configSet:RTWInterfaceTabName').getString}
            curPageTag='Interface';
        case{'Code Style',message('RTW:configSet:RTWCodeStyleTabName').getString}
            curPageTag='Code_Style';
        case{'Templates',message('RTW:configSet:RTWTemplatesTabName').getString}
            curPageTag='Templates';
        case{'Code Placement',message('RTW:configSet:RTWDataPlacementTabName').getString}
            curPageTag='Data_Placement';
        case{'Data Type Replacement',message('RTW:configSet:RTWDataTypeReplacementTabName').getString}
            curPageTag='Data_Type_Replacement';
        case{'Memory Sections',message('RTW:configSet:RTWMemorySectionsTabName').getString}
            curPageTag='Memory_Sections';
        case{'Tornado Target',loc_getPageName('RTW:tornado:tornadoTitle')}
            curPageTag='Tornado_Target';
        case{'xPC Target options',loc_getPageName('slrealtime:obsolete:xpcTargetCC:Dialog:TargetOptions')}
            curPageTag='xPC_Target_options';
        case 'S-Function Target'
            curPageTag='S_Function_Target';
        case{'RSim Target',loc_getPageName('RTW:rsim:RSimTarget')}
            curPageTag='RSim_Target';
        case 'Simulink Desktop Real-Time'
            curPageTag='Real_Time_Windows_Target';
        case 'C166 Options (1)'
            curPageTag='C166_Options__1_';
        case 'ET MPC5xx (algorithm export) options'
            curPageTag='ET_MPC5xx__algorithm_export__options';
        case 'ET MPC5xx (processor-in-the-loop) options'
            curPageTag='ET_MPC5xx__processor_in_the_loop__options';
        case 'ET MPC5xx real-time options (1)'
            curPageTag='ET_MPC5xx_real_time_options__1_';
        case 'ET MPC5xx real-time options (2)'
            curPageTag='ET_MPC5xx_real_time_options__2_';
        case{'Coder Target',message('codertarget:build:CoderTargetName').getString}
            curPageTag='Embedded_IDE_Link';
        case{'AUTOSAR Code Generation Options',message('RTW:autosar:autosarCodeGenOptions').getString}
            curPageTag='AUTOSAR_Code_Generation_Options';
        case{'Verification',message('RTW:configSet:RTWVerificationTabName').getString}
            curPageTag='Verification';
        case 'TLM Generator'
            imd=DAStudio.imDialog.getIMWidgets(hDlg);
            tab=find(imd,'tag','ddgtag_tlmgTLMGeneratorTabs');
            curTab=tab.getCurrentTab;
            switch curTab
            case 0
                curPageTag='TLM_Generation';
            case 1
                curPageTag='TLM_Testbench';
            case 2
                curPageTag='TLM_Compilation';
            otherwise
                curPageTag='TLM_Generation';
            end
        case 'SystemVerilog DPI'
            curPageTag='SystemVerilog_DPI';
        otherwise
            curPageTag='Custom_Target';
        end

        map=['mapkey:Simulink.ConfigSet@Tag_ConfigSet_RTW_',curPageTag];

        if ismember(curPage,{'Optimization',message('RTW:configSet:configSetOptimization').getString})
            map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_Optimization_Panel';
        end

    case{'HDL Code Generation',message('HDLShared:hdldialog:hdlccHDLCodername').getString}
        curPage=hdlcoderui.hdlHelp(subPage);

        map=['mapkey:Simulink.ConfigSet@',curPage];


    case{'Coverage',message('RTW:configSet:configSetSlCov').getString}
        map='mapkey:Simulink.ConfigSet@ConfigSet_SlCov_MainPanel';

    case{'Design Verifier',message('Sldv:dialog:sldvDVOptionsTab').getString}

        if isempty(subPage)
            curPage='General';
        else
            curPage=strtok(subPage,'/');
        end

        switch curPage
        case 'General'
            curPage='ConfigSet_SLDV_MainPanel';
        case{'Block Replacements',message('Sldv:dialog:sldvBlkRepPanelLab').getString}
            curPage='ConfigSet_SLDV_BlockReplacementsPanel';
        case{'Parameters',message('Sldv:dialog:sldvParamPanelLab').getString}
            curPage='ConfigSet_SLDV_ParametersPanel';
        case{'Test Generation',message('Sldv:dialog:sldvTestGenPanelLab').getString}
            curPage='ConfigSet_SLDV_TestGenerationPanel';
        case{'Design Error Detection',message('Sldv:dialog:sldvDesignErrPanelTabLab').getString}
            curPage='ConfigSet_SLDV_ErrorDetectionPanel';
        case{'Property Proving',message('Sldv:dialog:sldvPPPanelTabLab').getString}
            curPage='ConfigSet_SLDV_PropertyProvingPanel';
        case{'Results',message('Sldv:dialog:sldvResPanelLab').getString}
            curPage='ConfigSet_SLDV_ResultsPanel';
        case{'Report',message('Sldv:dialog:sldvMenuReport').getString}
            curPage='ConfigSet_SLDV_ReportPanel';
        case{'S-Functions',message('Sldv:dialog:sldvSFunctionsPanelLab').getString}
            curPage='ConfigSet_SLDV_SFunctionsPanel';
        end

        map=['mapkey:Simulink.ConfigSet@',curPage];

    case 'Simscape'

        curPage='Simscape_Panel';
        map=['mapkey:Simulink.ConfigSet@Tag_ConfigSet_',curPage];

    case 'Simscape Multibody 1G'

        curPage='SimMechanics_Panel';
        map=['mapkey:Simulink.ConfigSet@Tag_ConfigSet_',curPage];

    case 'Simscape Multibody'
        curPage='SimscapeMultibody_Panel';
        map=['mapkey:Simulink.ConfigSet@Tag_SimMechanics_',curPage];

    case 'Embedded IDE Link'
        map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_L4T_Options';

    case 'ConfigSetPref'
        map='mapkey:Simulink.Preferences';

    case 'ConfigSetRef'
        map=[docroot,'/mapfiles/simulink.map'];
        topic='configuration_reference_dialog';

    case 'Stateflow Simulation'
        map=[docroot,'/toolbox/stateflow/stateflow.map'];
        topic='simulation_target_dialog';

    case 'EDA Link'
        map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_FPGA_FPGAWorkflowPanel';

    case 'Concurrent Execution'
        map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_ConcurrentExecutionPanel';
    case 'Run on Target Hardware'
        map='mapkey:Simulink.ConfigSet@Tag_ConfigSet_RTT_Settings_settingsStack';
    case 'Coder Target'
        if isa(hObj,'Simulink.ConfigSetDialogController')
            hCS=hObj.getSourceObject();
        else
            hCS=hObj.getConfigSet();
        end
        str=codertarget.target.getTargetMapFileString(hCS);
        map=['mapkey:Simulink.ConfigSet@',str];

    case 'PLC Code Generation'
        if isempty(subPage)
            curPage='Main';
        else
            curPage=strtok(subPage,'/');
        end
        if strcmp(curPage,'Report')
            curPage='ReportPanel_Report';
        elseif strcmp(curPage,'Identifiers')
            curPage='SymbolsPanel';
        else
            curPage=[curPage,'Panel'];
        end
        map=['mapkey:Simulink.ConfigSet@ConfigSet_PLCCoder_',curPage];

    otherwise
        map=[docroot,'/mapfiles/simulink.map'];
        topic='model_config';
    end

    helpview(map,topic,'CSHelpWindow');
end


function out=loc_getPageName(id)
    try
        out=message(id).getString;
    catch
        out='';
    end
end


