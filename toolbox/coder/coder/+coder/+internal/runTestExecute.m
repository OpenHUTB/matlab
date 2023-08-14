function msgstruct=runTestExecute(tbm,testBenchResource)



    msgstruct=[];
    executionConfig=tbm.getExecutionConfig();

    [msgText,tbstack]=tbm.executeTestBench(testBenchResource,executionConfig.SuppressOutput);

    if isempty(msgText)
        return;
    end
    msgstruct=tbm.getErrorMsgStruct();
    if isempty(msgstruct)
        msgstruct.identifier='Coder:FE:Explicit';
        msgstruct.message=msgText;
        msgstruct.stack=tbstack;
    end



    mxstack=msgstruct.stack;




    if length(tbstack)>=length(mxstack)


        stack=mxstack;
    else
        mxOnlyStack=mxstack(1:(end-length(tbstack)));
        stack=[mxOnlyStack;tbstack];
    end


    if~isempty(stack)
        msgstruct.stack=hideStack('TestBenchManager.executeTestBench',msgstruct.stack,true);
        msgstruct.stack=hideStack('evalTestBenchResult',msgstruct.stack,true);
    end

    if isfield(msgstruct,'stack')&&isempty(msgstruct.stack)
        msgstruct=rmfield(msgstruct,'stack');
    end
end

function aStack=hideStack(aFunctionName,aStack,canBeEmpty)
    hide=find(cellfun(@(name)(strcmp(name,aFunctionName)),{aStack(:).name}),1);
    if~isempty(hide)&&hide>1
        aStack=aStack(1:hide-1);
    end

    if~isempty(hide)&&hide==1&&canBeEmpty
        aStack=repmat(aStack,0,1);
    end
end

