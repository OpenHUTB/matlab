function[topModel,totalNumBlocksDeleted]=startSimplification(mdlName,conditionFunction,varargin)

    if nargin<2
        error('Function should have 2 or more inputs');
    end
    if~ischar(mdlName)
        error('First input should be name of a model or a SubSystem');
    end
    if~ischar(conditionFunction)
        error('Second input should be name of the condition function');
    end
    if rem(nargin,2)~=0
        error('Function accepts even number of arguments');
    end

    totalNumBlocksDeleted=0;
    sopts.excludeBlocks={};
    sopts.makeCopy=true;
    sopts.copyExtension='_0';
    sopts.testModelExtn='_test';
    sopts.topModel=mdlName;
    sopts.maxIterations=1;
    sopts.BinarySearchLimit=10;
    sopts.BreakLibraryLinks=0;
    sopts.SimplifyMdlRefs=true;
    sopts.SimplifySubSys=true;
    sopts.recursionLevel=0;
    sopts.flattenHierarchy=true;
    sopts.startTime=tic;

    if nargin>=3
        for i=1:2:length(varargin)
            name=varargin{i};
            value=varargin{i+1};
            if isfield(sopts,name)
                sopts.(name)=value;
            else
                error([name,' Parameter is not an expected input']);
            end

            switch(name)
            case 'excludeBlocks'
                if~iscell(value)
                    error([name,'  should be a cell array of blocks full names or blocks SID''s']);
                end
            case{'makeCopy','maxIterations','BinarySearchLimit','BreakLibraryLinks','SimplifyMdlRefs','SimplifySubSys','recursionLevel','flattenHierarchy','startTime'}
                if~isreal(value)||~isscalar(value)
                    error([name,' should be a real scalar or a logical']);
                end
            case{'copyExtension','testModelExtn','topModel'}
                if~ischar(value)
                    error([name,' should be a string']);
                end
            otherwise
                error([name,' is not an expected parameter name']);
            end
        end
    end

    [mdlName,subSysName]=Simulink.SimplifyModel.getSubsystemName(mdlName);
    [sopts.topModel]=Simulink.SimplifyModel.getSubsystemName(sopts.topModel);
    topModel=sopts.topModel;
    load_system(mdlName);
    load_system(sopts.topModel);


    if~isempty(subSysName)&&~Simulink.SimplifyModel.canBeSimplified([mdlName,'/',subSysName],sopts)
        return;
    end


    if sopts.makeCopy
        [mdlName,sopts.topModel,sopts.excludeBlocks]=Simulink.SimplifyModel.saveSystemAndMdlRefs(mdlName,sopts.topModel,sopts.copyExtension,'append',sopts.excludeBlocks);
    end

    if isempty(subSysName)
        FullPath=mdlName;
    else
        FullPath=[mdlName,'/',subSysName];
    end

    if sopts.recursionLevel==0
        iterationLimit=sopts.maxIterations;
    else
        iterationLimit=1;
    end

    for startIdx=1:iterationLimit
        numBlocksDeleted=0;
        disp(['#########System name = ',FullPath,'##########']);
        disp(['#########Iteration number = ',num2str(startIdx),'##########']);



        Simulink.SimplifyModel.removeUnconnectedLines(FullPath);
        if sopts.recursionLevel==0&&sopts.flattenHierarchy
            [~,sopts]=Simulink.SimplifyModel.flattenHierarchy(mdlName,FullPath,sopts,conditionFunction,totalNumBlocksDeleted);
        end



        [numBlocksDeleted,sopts]=Simulink.SimplifyModel.removeFromGotoBlocks(FullPath,mdlName,conditionFunction,sopts,numBlocksDeleted);



        [numBlocksDeleted,sopts]=deleteUsingBinarySearch(mdlName,FullPath,conditionFunction,numBlocksDeleted,sopts);



        totalNumBlocksDeleted=totalNumBlocksDeleted+numBlocksDeleted;
        if numBlocksDeleted==0
            break;
        end
    end

    disp('################################################');
    disp(['    Number of Blocks deleted = ',num2str(totalNumBlocksDeleted)]);
    disp('################################################');



    function inputcell=convertStructToCell(sopts)
        inputcell={};
        f=fields(sopts);
        for i=1:length(f)
            inputcell{end+1}=f{i};%#ok<*AGROW>
            inputcell{end+1}=sopts.(f{i});
            if strcmp(f{i},'makeCopy')
                inputcell{end}=0;
            end
            if strcmp(f{i},'recursionLevel')
                inputcell{end}=sopts.recursionLevel+1;
            end
        end


        function[blocksNumRemoved,sopts]=deleteUsingBinarySearch(mdlName,FullPath,conditionFunction,blocksNumRemoved,sopts)

            load_system(mdlName);
            [allBlocks,cutLocations]=Simulink.SimplifyModel.getBlocksList(FullPath,sopts.excludeBlocks);

            for totalRuns=1:length(cutLocations)-1
                blocksListDeleted={};
                blocksList=allBlocks(cutLocations(totalRuns)+1:cutLocations(totalRuns+1));
                if length(blocksList)==length(allBlocks)
                    numSplits=2;
                else
                    numSplits=1;
                end

                for j=1:sopts.BinarySearchLimit
                    splitSize=ceil(length(blocksList)/numSplits);

                    for i=1:numSplits
                        chunksList={};

                        for p=((i-1)*splitSize+1):min(length(blocksList),i*splitSize)
                            if~ismember(blocksList{p},blocksListDeleted)
                                chunksList{end+1}=blocksList{p};
                            end
                        end


                        if~isempty(chunksList)
                            [reductionOK,blocksNumRemoved,sopts,canRewire]=Simulink.SimplifyModel.deleteBlockAndCheck(chunksList,FullPath,sopts,0,conditionFunction,blocksNumRemoved);
                            if canRewire&&~reductionOK
                                [reductionOK,blocksNumRemoved,sopts]=Simulink.SimplifyModel.deleteBlockAndCheck(chunksList,FullPath,sopts,1,conditionFunction,blocksNumRemoved);
                            end


                            if reductionOK
                                blocksListDeleted=[blocksListDeleted,chunksList];
                            elseif length(chunksList)==1
                                [simplifiable,subsystemOrMdl]=Simulink.SimplifyModel.canBeSimplified(chunksList{1},sopts);
                                if~simplifiable
                                    continue;
                                end



                                inputcell=convertStructToCell(sopts);
                                [sopts.topModel,totalNum]=Simulink.SimplifyModel.startSimplification(subsystemOrMdl,conditionFunction,inputcell{:});
                                blocksNumRemoved=blocksNumRemoved+totalNum;
                            end
                        end
                    end
                    numSplits=numSplits*2;


                    if isequal(unique(blocksListDeleted),unique(blocksList))||splitSize<=1
                        break;
                    end
                end
            end
