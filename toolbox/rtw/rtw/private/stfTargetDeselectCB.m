function stfTargetDeselectCB(hTarget,pushnag)



    hConfigSet=hTarget.getConfigSet;
    callback=hTarget.DeselectCallback;
    hDlg=[];
    fileName=get(hTarget,'SystemTargetFile');
    showStackInfo=(feature('RTWTesting')~=0);
    model=hConfigSet.getModel;
    if isempty(model)
        pushnag=false;
    end

    if pushnag
        viewnag=false;
    end

    if~isempty(callback)
        try
            loc_eval(hTarget,hDlg,callback);
        catch recordedErr
            MSLDiagnostic('RTW:configSet:errorInDeselectCallback',fileName,recordedErr.message,...
            stack_info_to_str(recordedErr.stack,showStackInfo),...
            'COMPONENT','RTW','CATEGORY','RTW:configSet:errorInDeselectCallback').reportAsWarning;
        end
    end


    function loc_eval(hSrc,hDlg,evalstr)%#ok<INUSL>
        hConfigSet=hSrc.getConfigSet;%#ok<NASGU>
        eval(evalstr);



        function stackInfoStr=stack_info_to_str(stackinfo,showStackInfo)
            stackInfoStr='';
            for i=1:length(stackinfo)
                if~showStackInfo&&...
                    (~isempty(findstr(stackinfo(i).file,'toolbox/rtw/rtw/private/stfTargetDeselectCB'))||...
                    ~isempty(findstr(stackinfo(i).file,'toolbox\rtw\rtw\private\stfTargetDeselectCB')))
                    break;
                end
                stackInfoStr=sprintf('%s %s:%s:%d \n',stackInfoStr,stackinfo(i).file,...
                stackinfo(i).name,stackinfo(i).line);
            end


