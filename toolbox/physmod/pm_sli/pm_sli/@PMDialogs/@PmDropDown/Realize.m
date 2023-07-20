function retStatus=Realize(hThis)







    retStatus=true;

    try
        origVal=get_param(pmsl_getdoublehandle(hThis.BlockHandle),hThis.ValueBlkParam);
        if(~isempty(hThis.MapVals))

            if(numel(hThis.MapVals)~=numel(hThis.Choices))
                pm_abort('Map value list must be same size as Choices list');
            end





            matchIdx=find(strcmp(hThis.MapVals,origVal));

            if isempty(matchIdx)
                choiceValMatch=hThis.ChoiceVals==str2double(origVal);
                if any(choiceValMatch)
                    matchIdx=find(choiceValMatch,1);
                else
                    matchIdx=1;
                end
            end
            conditionedVal=hThis.Choices{matchIdx(1)};

        else
            conditionedVal=origVal;
        end

        hThis.Value=conditionedVal;
    catch
        retStatus=false;
    end

    hThis.Value=pm.sli.internal.resolveMessageString(hThis.Value);
    hThis.Choices=pm.sli.internal.resolveMessageStrings(hThis.Choices);
end

