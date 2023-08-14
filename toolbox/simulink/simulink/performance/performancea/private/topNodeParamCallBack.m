
function topNodeParamCallBack(parentGroup,paramTag,handle)

    DAStudio.delayedCallback(@delayedTopNodeParamCallBack,parentGroup,paramTag,handle);
end


function delayedTopNodeParamCallBack(parentGroup,paramTag,handle)





    inputParams=parentGroup.getInputParameters;
    idx=strsplit(paramTag,'_');
    paramIdx=str2double(idx(2));

    param=inputParams{paramIdx};


    actModeV1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActModeV1');

    actModeV2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActModeV2');

    actModeV3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActModeV3');


    validationModeV1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationModeV1');

    validationModeV2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationModeV2');

    validationModeV3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationModeV3');

    paramName1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionMode');
    paramName2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateTime');
    paramName3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateAccuracy');

    subCheckParamName={paramName1,paramName2,paramName3};

    if(paramIdx==1)
        paramVal={actModeV1,actModeV2,actModeV3};
    else
        paramVal={validationModeV1,validationModeV2,validationModeV3};
    end

    groupParamValue={'UseLocal'};

    if strcmp(param.Value,paramVal{2})
        groupParamValue{1}='EnableAll';
    elseif strcmp(param.Value,paramVal{3})
        groupParamValue{1}='DisableAll';
    elseif strcmp(param.Value,paramVal{1})
        groupParamValue{1}='UseLocal';
    end


    subChecks=parentGroup.getChildren;
    for m=1:length(subChecks)
        utilSetSubChecksParam(groupParamValue{1},subChecks(m),subCheckParamName{paramIdx});
    end

end


function utilSetSubChecksParam(groupParamValue,subCheck,subCheckParamName)




    ignoreTop=strcmp(subCheck.getID,'com.mathworks.Simulink.PerformanceAdvisor.FinalValidation');
    if ignoreTop
        return;
    end

    if isa(subCheck,'ModelAdvisor.Group')
        subChecks=subCheck.getChildren;
        for m=1:length(subChecks)
            utilSetSubChecksParam(groupParamValue,subChecks(m),subCheckParamName);
        end
    else
        mdladvObj=subCheck.MAObj;
        checkParams=mdladvObj.getInputParameters(subCheck.getID);
        for i=1:length(checkParams)
            name=checkParams{i}.Name;

            if strcmp(name,subCheckParamName)
                if strcmp(groupParamValue,'UseLocal')
                    checkParams{i}.Enable=true;
                    checkParams{i}.Value=checkParams{i}.Default;
                    return;
                else
                    checkParams{i}.Enable=true;
                    if strcmp(groupParamValue,'EnableAll')
                        if strcmp(subCheckParamName,DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionMode'))
                            checkParams{i}.Value=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeAuto');
                        else
                            checkParams{i}.Value=true;
                        end
                    else
                        if strcmp(subCheckParamName,DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionMode'))
                            checkParams{i}.Value=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeManually');
                        else
                            checkParams{i}.Value=false;
                        end
                    end
                    checkParams{i}.Enable=false;
                    return;
                end
            end
        end

    end
end
