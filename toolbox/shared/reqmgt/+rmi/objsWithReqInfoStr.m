function[objH,reqStrs]=objsWithReqInfoStr(modelH)



    [objH,reqStrs]=sl_req_objs(modelH);
    [sfobjH,sfreqStrs]=sf_req_objs(modelH);

    if~isempty(sfobjH)
        objH=[objH(:)',sfobjH(:)'];
        reqStrs=[reqStrs(:)',sfreqStrs(:)'];
    end

end

function[objH,reqStrs]=sl_req_objs(modelH)


    objH=find_system(modelH,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on',...
    'RegExp','on',...
    'RequirementInfo','^\{');
    if isempty(objH)
        objH=[];
        reqStrs={};
    else
        if nargout>1
            reqStrs=get_param(objH,'RequirementInfo');
            if~iscell(reqStrs)
                reqStrs={reqStrs};
            end
        end
    end
end

function[objH,reqStrs]=sf_req_objs(modelH)


    objH=[];
    reqStrs={};
    rt=sfroot;
    machineObj=rt.find('-isa','Stateflow.Machine','Name',get_param(modelH,'Name'));

    if~isempty(machineObj)
        sfFilter=rmisf.sfisa('isaFilter');
        allObjs=machineObj.find('-regexp','RequirementInfo','^\{',...
        sfFilter(3:end));

        if~isempty(allObjs)
            objCnt=length(allObjs);
            objH=zeros(1,objCnt);
            if nargout>1
                reqStrs=cell(1,objCnt);
            end

            for idx=1:length(allObjs)
                objH(idx)=allObjs(idx).Id;
                if nargout>1
                    reqStrs{idx}=allObjs(idx).RequirementInfo;%#ok<AGROW>
                end
            end
        end
    end
end

