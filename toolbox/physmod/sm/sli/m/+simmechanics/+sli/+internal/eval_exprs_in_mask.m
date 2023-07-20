function[paramEvalVals,msgIds,msgs]=eval_exprs_in_mask(hBlock,paramNames,paramExprs)





    if iscellstr(paramNames)
        assert(iscellstr(paramExprs));
        assert(length(paramNames)==length(paramExprs));
    elseif ischar(paramNames)
        assert(ischar(paramExprs));
        paramNames={paramNames};
        paramExprs={paramExprs};
    end

    numParams=length(paramExprs);
    paramEvalVals=cell(numParams,1);
    msgIds=cell(numParams,1);
    msgs=cell(numParams,1);
    for idx=1:numParams
        paramName=paramNames{idx};
        paramExpr=paramExprs{idx};
        try
            paramEvalVal=slResolve(paramExpr,hBlock,'expression');
            if isnumeric(paramEvalVal)
                msgId='';
                msg='';
            else
                if iscell(paramEvalVal)
                    if all(cellfun(@isnumeric,paramEvalVal))
                        msgId='';
                        msg='';
                    else




                        msgId='mech2:sli:gli:translation:InvalidCellArrayType';
                        msg=pm_message(msgId,paramName);
                        paramEvalVal=[];
                    end
                else
                    msgId='mech2:sli:gli:translation:InvalidParameterData';
                    msg=pm_message(msgId,paramName);
                end
            end
        catch evalExcp %#ok<NASGU>
            paramEvalVal=[];
            msgId='sm:sli:internal:FailToEvaluateParam';
            msg=pm_message(msgId,paramExpr,paramName,getfullname(hBlock));
        end
        paramEvalVals{idx}=paramEvalVal;
        msgIds{idx}=msgId;
        msgs{idx}=msg;
    end
