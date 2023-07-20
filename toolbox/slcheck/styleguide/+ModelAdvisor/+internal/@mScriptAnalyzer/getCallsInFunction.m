function result=getCallsInFunction(this,functionName,visitedFiles)







    if isempty(this.visitedFcns)||~ismember({functionName},this.visitedFcns)
        this.visitedFcns=[this.visitedFcns,{functionName}];
    else

        result=ModelAdvisor.internal.mFunctionDetails(...
        [functionName,'(',DAStudio.message('ModelAdvisor:engine:PossibleRecursion'),')']);
        return;
    end


    result=ModelAdvisor.internal.mFunctionDetails(functionName);


    subTree=this.mtreeObject.mtfind('Kind','FUNCTION','Fname.Fun',functionName).Body;



    [allCalls,~,beginIndices,endIndices]=...
    Advisor.Utils.getMtreeNodeInfo(this.object,subTree.Full.mtfind('Kind','CALL').Left,false);



    [builtinFcns,externalFiles,filepaths]=...
    cellfun(@(x)Advisor.Utils.isaKeyword(x),allCalls,'UniformOutput',false);


    builtinFcns=cell2mat(builtinFcns);
    externalFiles=cell2mat(externalFiles);

    if isempty(allCalls);return;end

    details(numel(allCalls)).call='';

    for idx=1:numel(allCalls)
        details(idx).call=allCalls{idx};
        details(idx).begin=beginIndices(idx);
        details(idx).end=endIndices(idx);
        details(idx).filepath=filepaths{idx};
    end

    if isempty(details);return;end

    details=details(~builtinFcns);
    externalFiles=externalFiles(~builtinFcns);
    filterLocalCalls=ismember({details.call},this.fdefs);

    result=processLocalCalls(this,details(filterLocalCalls),visitedFiles,result);
    result=processExternalCalls(this,details(externalFiles),visitedFiles,result);
    result=processOtherCalls(this,details(~or(filterLocalCalls,externalFiles)),visitedFiles,result);

end


function result=processLocalCalls(this,localFcnCalls,visitedFiles,result)



    for idx=1:numel(localFcnCalls)
        subResult=this.getCallsInFunction(localFcnCalls(idx).call,visitedFiles);
        subResult.location=getLink(this,localFcnCalls(idx));
        result.localCalls=[result.localCalls,subResult];
    end
end

function result=processExternalCalls(this,externalCalls,visitedFiles,result)

    for idx=1:numel(externalCalls)
        try

            exFile=ModelAdvisor.internal.mScriptAnalyzer([externalCalls(idx).call,'.m']);
            exFile.location=externalCalls(idx).filepath;
        catch
            continue;
        end

        subResult=exFile.getFunctionDetails(visitedFiles);
        subResult.location=getLink(this,externalCalls(idx));
        result.externalCalls=[result.externalCalls,subResult];
    end
end

function result=processOtherCalls(this,otherCalls,visitedFiles,result)
    if isequal(class(this.object),'Stateflow.EMFunction')
        for idx=1:numel(otherCalls)
            [bStatus,index]=ismember(otherCalls(idx).call,{this.emlCallables.name});
            if bStatus
                if isempty(this.emlCallables(index).result)
                    exEMLFcn=ModelAdvisor.internal.mScriptAnalyzer(this.emlCallables(index).object);
                    exEMLFcn.setEMLCallables(this.emlCallables);
                    subResult=exEMLFcn.getFunctionDetails(visitedFiles);
                    this.emlCallables(index).result=subResult;
                else
                    subResult=this.emlCallables(index).result;
                end
                subResult.location=getLink(this,otherCalls(idx));
                result.externalCalls=[result.externalCalls,subResult];
            end
        end
    end
end

function link=getLink(this,fcnCall)


    switch class(this.object)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        sid=Simulink.ID.getSID(this.object);
    case 'char'
        sid=this.location;
    otherwise
        sid='';
    end
    link=Advisor.Utils.Simulink.getEmlHyperlink(...
    sid,fcnCall.call,fcnCall.begin,fcnCall.end);

end
