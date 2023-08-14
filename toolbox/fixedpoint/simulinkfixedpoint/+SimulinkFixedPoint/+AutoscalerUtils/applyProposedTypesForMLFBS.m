function applyProposedTypesForMLFBS(currentResults,runObj,sudID)







    perMLFBResults=Simulink.sdi.Map(char('a'),?handle);
    perMLFBNAResultIndices=Simulink.sdi.Map(char('a'),0);

    perMLFBHasNA=containers.Map();



    emFunctionResults=fxptds.StateflowResult.empty();


    for j=1:length(currentResults)
        curRecord=currentResults{j};
        uniqueID=curRecord.UniqueIdentifier;
        res_daobject=uniqueID.getObject;

        if isa(curRecord,'fxptds.MATLABVariableResult')
            blkObjPath=res_daobject.MATLABFunctionIdentifier.SID;
            if~perMLFBHasNA.isKey(blkObjPath)
                perMLFBHasNA(blkObjPath)=false;
            end
            if isKey(perMLFBResults,blkObjPath)
                existingRes=perMLFBResults.getDataByKey(blkObjPath);
                existingRes{end+1}=curRecord;%#ok
                perMLFBResults.insert(blkObjPath,existingRes);
            else
                existingRes=curRecord;
                perMLFBResults.insert(blkObjPath,{curRecord});
            end


            if~perMLFBHasNA(blkObjPath)&&~isa(curRecord,'fxptds.MATLABCppSystemObjectVariableResult')...
                &&~curRecord.hasFixedDT()...
                &&~strcmp(curRecord.getCompiledDT(),'logical')...
                &&~isIntegerType(curRecord.getCompiledDT())...
                &&~isZeroRange(curRecord)...
                &&strcmp(curRecord.getProposedDT,'n/a')
                perMLFBHasNA(blkObjPath)=true;
                if isKey(perMLFBNAResultIndices,blkObjPath)
                    perMLFBNAResultIndices.insert(blkObjPath,[perMLFBNAResultIndices.getDataByKey(blkObjPath),length(existingRes)]);
                else
                    perMLFBNAResultIndices.insert(blkObjPath,length(existingRes));
                end
            end
        elseif isa(curRecord,'fxptds.StateflowResult')
            t=curRecord.UniqueIdentifier.getObject();
            if~isempty(t)&&isa(t.getParent(),'Stateflow.EMFunction')
                emFunctionResults(end+1)=curRecord;%#ok<AGROW>
            end
        end
    end
    applyProposedTypes(perMLFBResults,runObj,perMLFBHasNA,perMLFBNAResultIndices,emFunctionResults,sudID);


    autoscalerMetaData=runObj.getMetaData;
    if~isempty(autoscalerMetaData)
        autoscalerMetaData.setMLFBResultsMap(perMLFBResults);
    end

end


function r=isZeroRange(curRecord)


    range=[curRecord.SimMin,curRecord.SimMax];
    r=(numel(range)==2)&&all(range==[0,0]);
end


function applyProposedTypes(resMap,runObj,perMLFBHasNA,perMLFBNAResultIndices,emFunctionResults,sudID)

    keyCount=resMap.getCount;
    for idx=1:keyCount
        blkName=resMap.getKeyByIndex(idx);
        results=resMap.getDataByIndex(idx);


        results=[results{:}];

        mlfbHasNA=perMLFBHasNA(blkName);
        if mlfbHasNA
            naResIndices=perMLFBNAResultIndices.getDataByKey(blkName);
        else
            naResIndices=[];
        end
        coder.internal.MLFcnBlock.F2FDriver.addProposedTypesForOneMLFBInBatchMode(results,blkName,runObj,mlfbHasNA,naResIndices,sudID);
    end



    flagSFEMFunctionResutls(emFunctionResults);
end

function res=isIntegerType(typeStr)
    switch(typeStr)
    case{'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
        res=true;
    otherwise
        res=false;
    end
end


function flagSFEMFunctionResutls(emFunctionResults)

    origWarnState=coder.internal.Helper.changeBacktraceWarning('off');
    cleanUp=onCleanup(@()coder.internal.Helper.changeBacktraceWarning('reset',origWarnState));

    mlfbPaths=unique(arrayfun(@(a)[a.UniqueIdentifier.getObject().Path,'.',a.UniqueIdentifier.getObject().Name],emFunctionResults,'UniformOutput',false));
    for ii=1:length(mlfbPaths)
        emPath=mlfbPaths{ii};
        warning(message('Coder:FXPCONV:MLFB_EMFUNCTION',emPath));
    end
    fptAlertLevel=coder.internal.MLFcnBlock.FPTHelperUtils.FPT_ALERT_LVL_RED;
    coder.internal.MLFcnBlock.FPTHelperUtils.SetResultAlertLevel(emFunctionResults,fptAlertLevel);
end


