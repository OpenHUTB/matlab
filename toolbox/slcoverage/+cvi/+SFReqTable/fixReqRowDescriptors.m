function fixReqRowDescriptors(chartSfId,reqCvId)








    [metrics,codeCvId]=cv('get',reqCvId,'.metrics','.code');
    if isempty(metrics)
        return;
    end


    codeStr=cv('get',codeCvId,'.code');
    if~usesInternalVar(codeStr)
        return;
    end


    codeStr_new=codeStr;

    dcEnum=cvi.MetricRegistry.getEnum('decision');
    decision=cv('MetricGet',reqCvId,dcEnum,'.baseObjs');
    assert(numel(decision)==1);

    decDescId=cv('get',decision,'.descriptor');
    [decTxtStartIdx,decTxtLength]=cv('get',decDescId,'.startChar','.length');

    ccEnum=cvi.MetricRegistry.getEnum('condition');
    conditions=cv('MetricGet',reqCvId,ccEnum,'.baseObjs');

    if isempty(conditions)



        decStr_Old=codeStr(decTxtStartIdx+1:decTxtStartIdx+decTxtLength-1);
        decStr_New=cvi.SFReqTable.getSFInternalVarReplacementText(chartSfId,decStr_Old);


        codeStr_new=replaceBetween(codeStr,decTxtStartIdx+1,decTxtStartIdx+decTxtLength-1,decStr_New);
        cv('set',codeCvId,'.code',codeStr_new);


        txtLength_New=length(decStr_New)+1;
        cv('set',decDescId,'.length',txtLength_New);
    else






        condDescIds=cv('get',conditions,'.descriptor');
        [condTxtStartIdxs,condTxtLengths]=cv('get',condDescIds,'.startChar','.length');
        startIdxOffsets=zeros(size(conditions));
        decTxtLengthOffset=0;
        for i=1:length(conditions)
            curCondDescId=condDescIds(i);
            condStr_Old_Start=condTxtStartIdxs(i)+1;
            condStr_Old_End=condTxtStartIdxs(i)+condTxtLengths(i)-1;
            condStr_Old=codeStr(condStr_Old_Start:condStr_Old_End);
            condStr_New=cvi.SFReqTable.getSFInternalVarReplacementText(chartSfId,condStr_Old);


            condStr_Old_Start_Adjusted=condStr_Old_Start-startIdxOffsets(i);
            condStr_Old_End_Adjusted=condStr_Old_End-startIdxOffsets(i);
            codeStr_new=replaceBetween(codeStr_new,condStr_Old_Start_Adjusted,condStr_Old_End_Adjusted,condStr_New);


            txtLength_New=length(condStr_New)+1;
            cv('set',curCondDescId,'.length',txtLength_New);



            condTxtLengthOffset=condTxtLengths(i)-txtLength_New;
            startIdxOffsets(i+1:end)=startIdxOffsets(i+1:end)+condTxtLengthOffset;
            decTxtLengthOffset=decTxtLengthOffset+condTxtLengthOffset;
        end


        cv('set',codeCvId,'.code',codeStr_new);


        txtStartIdxs_new=condTxtStartIdxs-startIdxOffsets';
        cv('set',condDescIds,'.startChar',txtStartIdxs_new);


        cv('set',decDescId,'.length',decTxtLength-decTxtLengthOffset);


        mcdcEnum=cvi.MetricRegistry.getEnum('mcdc');
        mcdc=cv('MetricGet',reqCvId,mcdcEnum,'.baseObjs');
        mcdcDescIds=cv('get',mcdc,'.descriptor');
        mcdcTxtLength=cv('get',mcdcDescIds,'.length');
        cv('set',mcdcDescIds,'.length',mcdcTxtLength-decTxtLengthOffset);
    end
end

function tf=usesInternalVar(codeStr)
    tf=contains(codeStr,'sf_internal_execute');
end
