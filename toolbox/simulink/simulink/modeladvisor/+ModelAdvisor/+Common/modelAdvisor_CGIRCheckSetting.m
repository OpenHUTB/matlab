








function[result,formattedResult]=modelAdvisor_CGIRCheckSetting(system,varargin)



    result=false;

    model=bdroot(system);
    cs=getActiveConfigSet(model);



    if~Advisor.Utils.license('test','Real-Time_Workshop')||~Advisor.Utils.license('test','MATLAB_Coder')


        if~isempty(setdiff(find_mdlrefs(bdroot(getfullname(system)),'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices),bdroot(getfullname(system))))
            formattedResult=ModelAdvisor.FormatTemplate('ListTemplate');
            formattedResult.setSubResultStatus('Warn');
            warnStr=DAStudio.message('ModelAdvisor:engine:ModelRefWarn');
            formattedResult.setSubResultStatusText(warnStr)
            formattedResult.setSubBar(false);
            return;
        end
        if~strcmp(get_param(model,'SystemTargetFile'),'grt.tlc')
            formattedResult=getGRTmsg(model);
            return;
        end
    end



    if(~Advisor.Utils.license('test','RTW_Embedded_Coder')&&~strcmp(get_param(model,'SystemTargetFile'),'grt.tlc'))
        if~strcmp(get_param(model,'SystemTargetFile'),'grt.tlc')
            formattedResult=getGRTmsg(model);
            return;
        end
    end

    commitChanges=true;



    if isempty(varargin)
        msgOnly=false;
    else
        msgOnly=varargin{1};
    end

    if msgOnly


        hDlg=cs.getDialogHandle;
        if~isempty(hDlg)&&isa(hDlg,'DAStudio.Dialog')
            if hDlg.hasUnappliedChanges
                commitChanges=false;
            end
        end
    else
        commitChanges=slprivate('checkSimPrm',cs);
    end

    if~commitChanges
        formattedResult=ModelAdvisor.FormatTemplate('ListTemplate');
        formattedResult.setSubResultStatus('Warn');
        warnStr=DAStudio.message('ModelAdvisor:engine:UnappliedConfigChanges');
        formattedResult.setSubResultStatusText(warnStr)
        formattedResult.setSubBar(false);
        return;
    end

    formattedResult=[];
    if strcmpi(get_param(model,'GenerateComments'),'on')
        result=true;
        return;
    end
    formattedResult=ModelAdvisor.FormatTemplate('ListTemplate');


    cfgDialogPath='Include Comments';
    paramName='Include Comments';
    hyperlinkStr=getHyperlinkToConfigParam(model,cs,cfgDialogPath,paramName,'GenerateComments');

    formattedResult.setSubResultStatus('Warn');
    warnStr=DAStudio.message('ModelAdvisor:engine:CGIRConfigParamWarn',hyperlinkStr);
    formattedResult.setSubResultStatusText(warnStr)
    formattedResult.setSubBar(false);
end

function hyperlinkStr=getHyperlinkToConfigParam(model,cs,cfgDialogPath,paramName,param)
    hyperlinkStr='';

    if~isempty(cs)
        propcfg=slCfgPrmDlg(model,'Param2UI',param);
        if isfield(propcfg,'Type')&&strcmp(propcfg.Type,'NonUI')
            cfgDialogPath='';
        elseif~isempty(propcfg)&&isfield(propcfg,'Path')
            strPath=strtrim(propcfg.Path);
            if~isempty(strPath)
                cfgDialogPath=strPath;
            end
            paramName=propcfg.Prompt;
        end
    end

    if~isempty(cfgDialogPath)
        hyperlinkStr=Advisor.Utils.getHyperlinkToConfigSetParameter(model,propcfg.Param);
        hyperlinkStr=char(hyperlinkStr.Hyperlink);
        cfgDialogPath=[cfgDialogPath,'/',paramName];
        hyperlinkStr=['<a href = "',hyperlinkStr,'">',cfgDialogPath,'</a>'];
    end
end

function formattedResult=getGRTmsg(model)
    formattedResult=ModelAdvisor.FormatTemplate('ListTemplate');
    formattedResult.setSubResultStatus('Warn');
    hyperlinkStr=Advisor.Utils.getHyperlinkToConfigSetParameter(model,'SystemTargetFile');
    warnStr=DAStudio.message('ModelAdvisor:engine:EmbeddedCoderLicense',hyperlinkStr.emitHTML);
    formattedResult.setSubResultStatusText(warnStr)
    formattedResult.setSubBar(false);
end

