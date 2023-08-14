function parameterList=getParametersFromArtifacts(modelName,harnessName,targetApplication)




    stm.internal.genericrealtime.FollowProgress.progress('begin: getParametersFromArtifacts()');
    endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: getParametersFromArtifacts()'));
    appObj=slrealtime.Application(targetApplication);
    slrtParams=appObj.getParameters;
    nParams=length(slrtParams);
    topModel=getTopModel(modelName,harnessName);
    getRuntimeValue=true;
    tg=slrealtime;
    try
        if(tg.isConnected)
            tg.load(targetApplication);
        else
            getRuntimeValue=false;
        end
    catch
        getRuntimeValue=false;
    end
    parameterList=repmat(struct(...
    'TargetId','',...
    'Id','',...
    'Name','',...
    'ModelName','',...
    'SourceType','',...
    'ModelElement','',...
    'Value','',...
    'HarnessName','',...
    'ValueType','',...
    'Source','',...
    'SIDFullString','',...
    'IsMask','',...
    'TopModel',''),nParams,1);
    nTotalReturns=1;

    for blkItrIndex=1:nParams
        parameterName=slrtParams(blkItrIndex).BlockParameterName;
        modelElement=slrtParams(blkItrIndex).BlockPath;
        source='';
        if~isempty(modelElement)
            srcSplit=split(modelElement,'/');
            if numel(srcSplit)>1
                source=char(join(srcSplit(2:end)));
            end
        end




        if(isempty(source))
            parameterList(nTotalReturns).TargetId=parameterName;
        else
            parameterList(nTotalReturns).TargetId=...
            strcat(regexprep(modelElement,'\n',' '),...
            '/',parameterName);
        end


        parameterList(nTotalReturns).Id=parameterList(nTotalReturns).TargetId;

        parameterList(nTotalReturns).Name=parameterName;
        parameterList(nTotalReturns).ModelName=modelName;
        parameterList(nTotalReturns).HarnessName=harnessName;
        parameterList(nTotalReturns).TopModel=topModel;
        parameterList(nTotalReturns).SourceType='real-time application';
        if isempty(modelElement)
            [~,modelToUse,~]=fileparts(targetApplication);
            parameterList(nTotalReturns).ModelElement={modelToUse};
        else
            parameterList(nTotalReturns).ModelElement={modelElement};
        end
        parameterList(nTotalReturns).Source=source;
        parameterList(nTotalReturns).SIDFullString='';
        parameterList(nTotalReturns).IsMask=false;
        parameterList(nTotalReturns).Users='';
        parameterList(nTotalReturns).RuntimeValue='';
        parameterList(nTotalReturns).ValueType=1;
        if(getRuntimeValue)
            try
                if~isempty(modelElement)
                    val=tg.getparam(modelElement,parameterName);
                else
                    val=tg.getparam('',parameterName);
                end
                parameterList(nTotalReturns).RuntimeValue=val;
                [canShow,rows,columns,parameterList(nTotalReturns).Value]=getDisplayValue(val);
                if((max(rows,columns)==1&&canShow))
                    parameterList(nTotalReturns).ValueType=0;
                else
                    parameterList(nTotalReturns).ValueType=1;
                end
            catch
            end
        end
        nTotalReturns=nTotalReturns+1;
    end
    status=true;
end

function topModel=getTopModel(model,harness)
    ind=strfind(harness,'%%%');
    if isempty(ind)
        topModel=model;
    else
        topModel=harness(1:ind-1);
    end
end


function[canShow,rows,columns,displayText]=getDisplayValue(runtimeValue)
    [rows,columns]=size(runtimeValue);
    numElements=rows*columns;
    MAX_SIZE=10;

    canShow=isnumeric(runtimeValue)||islogical(runtimeValue)||issparse(runtimeValue);

    if(canShow&&numElements<=MAX_SIZE)
        if(issparse(runtimeValue))
            runtimeValue=full(runtimeValue);
        end
        displayText=mat2str(runtimeValue);
    elseif(ischar(runtimeValue))
        displayText=runtimeValue;
    else
        valueType=class(runtimeValue);
        displayText=sprintf('%dx%d %s',rows,columns,valueType);
    end
end
