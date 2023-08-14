function[reductionOK,numBlocksDeleted,sopts]=checkCondition(mdlName,conditionFunction,sopts,BlocksList,numBlocksDeleted,messageText)


    load_system(mdlName);

    if nargin<3
        sopts.topModel=mdlName;
        sopts.testModelExtn='_test';
        sopts.excludeBlocks={};
    end
    if nargin<4
        BlocksList={};
    end
    if nargin<5
        numBlocksDeleted=0;
    end
    if nargin<6
        messageText='Delete Block ';
    end


    [newModel,newTopModel,sopts.excludeBlocks]=Simulink.SimplifyModel.saveSystemAndMdlRefs(mdlName,sopts.topModel,sopts.testModelExtn,'append',sopts.excludeBlocks);


    load_system(newTopModel);
    load_system(newModel);
    try
        if nargin(conditionFunction)==0
            reductionOK=feval(conditionFunction);
        elseif nargin(conditionFunction)==1
            reductionOK=feval(conditionFunction,newTopModel);
        elseif nargin(conditionFunction)==2
            reductionOK=feval(conditionFunction,newTopModel,newModel);
        elseif nargin(conditionFunction)==3
            reductionOK=feval(conditionFunction,newTopModel,newModel,sopts);
        else
            error([conditionFunction,' has more than 3 input arguments']);
        end
    catch ME
        disp(['The function call ',conditionFunction,'(''',newTopModel,''') threw a hard error. Fix the issue and rerun.',10,10]);
        disp(ME.message);
        rethrow(ME);
    end

    if reductionOK
        for i=1:length(BlocksList)
            numBlocksDeleted=numBlocksDeleted+1;
            disp([messageText,':   ',BlocksList{i},10]);
        end
        [mdlNameTemp,topModelTemp,sopts.excludeBlocks]=Simulink.SimplifyModel.saveSystemAndMdlRefs(newModel,newTopModel,sopts.testModelExtn,'remove',sopts.excludeBlocks);%#ok







    else
        for i=1:length(BlocksList)
            disp(['Could not ',messageText,':   ',BlocksList{i},10]);
        end
    end

    load_system(mdlName);
    load_system(sopts.topModel);
    toc(sopts.startTime);
