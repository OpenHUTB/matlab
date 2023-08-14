

function restoreDefaults(hObj,hDlg)

    if nargin<2
        hDlg=[];
    end


    baseResultsDir='';
    if ispref('PolySpace','results_dir')&&~isempty(getpref('PolySpace','results_dir'))
        baseResultsDir=getpref('PolySpace','results_dir');
        if strcmpi(baseResultsDir,'pwd')
            baseResultsDir=pwd;
        end
        baseResultsDir=[baseResultsDir,filesep];
    end

    availableProver=pslink.util.Helper.isProverAvailable();

    if~isempty(hDlg)
        TagMain='ConfigSet_PsLink_MainPanel_';

        hDlg.setWidgetValue([TagMain,'PSResultDir'],[baseResultsDir,'results_$ModelName$']);
        hDlg.setWidgetValue([TagMain,'PSVerificationSettings'],pslinkprivate('pslinkMessage','get','pslink:VerificationSettingsInheritDlg'));
        hDlg.setWidgetValue([TagMain,'PSCxxVerificationSettings'],pslinkprivate('pslinkMessage','get','pslink:VerificationSettingsInheritDlg'));
        hDlg.setWidgetValue([TagMain,'PSEnableAdditionalFileList'],0);
        hDlg.setWidgetValue([TagMain,'PSModelRefByModelRefVerif'],0);
        hDlg.setWidgetValue([TagMain,'PSModelRefVerifDepth'],'Current model only');
        hDlg.setWidgetValue([TagMain,'PSInputRangeMode'],pslinkprivate('pslinkMessage','get','pslink:InRangeModeMinMaxDlg'));
        hDlg.setWidgetValue([TagMain,'PSParamRangeMode'],pslinkprivate('pslinkMessage','get','pslink:ParamRangeModeCalibrateDlg'));
        hDlg.setWidgetValue([TagMain,'PSOutputRangeMode'],pslinkprivate('pslinkMessage','get','pslink:OutRangeModeNoAssertDlg'));
        hDlg.setWidgetValue([TagMain,'PSAutoStubLUT'],1);
        hDlg.setWidgetValue([TagMain,'PSAddSuffixToResultDir'],0);
        hDlg.setWidgetValue([TagMain,'PSOpenProjectManager'],0);
        if availableProver
            hDlg.setWidgetValue([TagMain,'PSVerificationMode'],pslinkprivate('pslinkMessage','get','pslink:VerificationModeCodeProver'));
        else
            hDlg.setWidgetValue([TagMain,'PSVerificationMode'],pslinkprivate('pslinkMessage','get','pslink:VerificationModeBugFinder'));
        end
        hDlg.setWidgetValue([TagMain,'PSCheckConfigBeforeAnalysis'],DAStudio.message('polyspace:gui:pslink:onWarnCheckConfDlg'));
        hDlg.setWidgetValue([TagMain,'PSEnablePrjConfigFile'],0);
        hDlg.setWidgetValue([TagMain,'PSPrjConfigFile'],'');
        hDlg.setWidgetValue([TagMain,'PSAddToSimulinkProject'],0);
    else
        hObj.PSResultDir=[baseResultsDir,'results_$ModelName$'];
        hObj.PSVerificationSettings='PrjConfig';
        hObj.PSCxxVerificationSettings='PrjConfig';
        hObj.PSOpenProjectManager=0;
        hObj.PSEnableAdditionalFileList=0;
        hObj.PSAdditionalFileList={};
        hObj.PSInputRangeMode='DesignMinMax';
        hObj.PSParamRangeMode='None';
        hObj.PSOutputRangeMode='None';
        hObj.PSModelRefVerifDepth='Current model only';
        hObj.PSModelRefByModelRefVerif=0;
        hObj.PSAutoStubLUT=1;
        hObj.PSAddSuffixToResultDir=0;
        if availableProver
            hObj.PSVerificationMode='CodeProver';
        else
            hObj.PSVerificationMode='BugFinder';
        end
        hObj.PSCheckConfigBeforeAnalysis='OnWarn';
        hObj.PSEnablePrjConfigFile=0;
        hObj.PSPrjConfigFile='';
        hObj.PSAddToSimulinkProject=0;
    end


