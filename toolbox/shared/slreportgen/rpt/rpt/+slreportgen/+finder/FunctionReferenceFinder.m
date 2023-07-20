classdef FunctionReferenceFinder<mlreportgen.finder.Finder











































































    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties







        FunctionType(1,1)string="all";










        SearchDepth(1,1)=inf;








        SearchReferencedModels(1,1)logical=true;








        LookUnderMasks(1,1)logical=true;










        FollowLibraryLinks(1,1)logical=true;














        IncludeInactiveVariants(1,1)logical=false;
    end

    properties(Access=private)


        NodeList=[]


        NodeCount{mustBeInteger}=0


        NextNodeIndex{mustBeInteger}=0


        IsIterating{mlreportgen.report.validators.mustBeLogical}=false



        InstanceParams=[];
    end

    methods
        function this=FunctionReferenceFinder(varargin)
            this=this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function set.FunctionType(this,value)

            mustBeMember(lower(value),["all","built-in","user-defined"]);
            this.FunctionType=value;
        end

        function results=find(this)
















            findImpl(this);

            results=this.NodeList;
        end

        function set.SearchDepth(this,val)

            mustBeNumeric(val)
            if~isinf(val)
                mustBeInteger(val);
                mustBeNonnegative(val)
            end

            this.SearchDepth=val;
        end
    end

    methods
        function result=next(this)














            if hasNext(this)

                result=this.NodeList(this.NextNodeIndex);

                this.NextNodeIndex=this.NextNodeIndex+1;
            else
                result=slreportgen.finder.FunctionReferenceResult.empty();
            end
        end

        function tf=hasNext(this)























            if this.IsIterating
                if this.NextNodeIndex<=this.NodeCount
                    tf=true;
                else
                    tf=false;
                end
            else
                findImpl(this);
                if this.NodeCount>0
                    this.NextNodeIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end
    end

    methods(Access=protected)
        function tf=isIterating(this)






            tf=this.IsIterating;
        end

        function reset(this)







            this.NodeList=[];
            this.IsIterating=false;
            this.NodeCount=0;
            this.NextNodeIndex=0;
        end
    end

    methods(Access=private,Hidden)
        function findImpl(this)





            try
                mustBeNonempty(this.Container);
                obj=slreportgen.utils.getSlSfHandle(this.Container);
                container=getfullname(obj);
                type=get_param(container,'Type');
            catch me
                error(message("slreportgen:finder:error:mustBeSimulinkBlockOrModel"));
            end
            if~ismember(type,["block","block_diagram"])
                error(message("slreportgen:finder:error:mustBeSimulinkBlockOrModel"));
            end


            if slreportgen.utils.isModel(container)


                wList=getChildBlockWords(this,container);
            else


                maskType=mlreportgen.utils.safeGet(container,'Mask','get_param');
                if strcmp(maskType,"off")
                    wList=getBlockParameterWords(container);
                else
                    wList=getMaskParameterWords(container);
                end



                isModelBlock=slreportgen.utils.isModelReferenceBlock(container);
                if isModelBlock
                    wList=[wList;getInstanceParameterWords(container)];
                end



                if isModelBlock||strcmp(get_param(container,"blocktype"),"SubSystem")
                    wList=[wList;getChildBlockWords(this,container)];
                end
            end



            try
                vars=Simulink.findVars(bdroot(container),...
                'SearchMethod','cached',...
                'SearchReferencedModels',this.SearchReferencedModels);
            catch me %#ok<NASGU>
                warning(message("slreportgen:finder:warning:unableToGetModelVariables",bdroot(container)))
                vars=Simulink.VariableUsage();
            end


            nodeList=createResultObjects(this,wList,vars);


            props=this.Properties;
            if~isempty(props)
                nodeList=filterNodesByProperty(nodeList,props);
            end


            this.NodeList=nodeList;
            this.NodeCount=length(nodeList);
        end

        function wList=getChildBlockWords(this,container)






            wList=cell(0,4);


            diagFinder=slreportgen.finder.DiagramFinder(Container=container,...
            SearchDepth=this.SearchDepth,...
            IncludeMaskedSubsystems=this.LookUnderMasks,...
            IncludeReferencedModels=this.SearchReferencedModels,...
            IncludeSimulinkLibraryLinks=this.FollowLibraryLinks);


            blkFinder=slreportgen.finder.BlockFinder(container);

            if this.IncludeInactiveVariants
                diagFinder.IncludeVariants="All";
                blkFinder.IncludeVariants="All";
            end




            sfBlocksToFilter=[];
            while hasNext(diagFinder)
                r=next(diagFinder);


                if~startsWith(r.Type,"Stateflow")


                    isInternalSFBlk=~isempty(sfBlocksToFilter)&&startsWith(r.Path,sfBlocksToFilter);


                    searchDiag=this.FollowLibraryLinks||...
                    ~strcmp(r.Type,"Simulink.SubSystem")||...
                    isempty(get_param(r.Object,'ReferenceBlock'));
                    if~isInternalSFBlk&&searchDiag

                        blkFinder.Container=r.Object;
                        blkResults=find(blkFinder);
                        if~isempty(blkResults)

                            isUnmasked=cellfun(@(x)strcmp(x,'off'),...
                            mlreportgen.utils.safeGet([blkResults.Object],'Mask','get_param'));



                            nBlocks=numel(blkResults);

                            for i=1:nBlocks
                                currBlk=blkResults(i);
                                if isUnmasked(i)
                                    wList=[wList;getBlockParameterWords(currBlk.Object)];%#ok<AGROW>
                                else
                                    wList=[wList;getMaskParameterWords(currBlk.Object)];%#ok<AGROW>
                                end


                                if strcmp(currBlk.Type,"ModelReference")
                                    wList=[wList;getInstanceParameterWords(currBlk.Object)];%#ok<AGROW>
                                end
                            end
                        end
                    end
                else




                    sfBlocksToFilter=[sfBlocksToFilter,string(r.Object.Path)+"/"];%#ok<AGROW>
                end

            end
        end

        function nodeList=createResultObjects(this,wList,vars)






            nodeList=slreportgen.finder.FunctionReferenceResult.empty();
            [uniqueWords,~,wListIdx]=unique(wList(:,1));
            numWords=numel(uniqueWords);
            filterStrings={'on','off','auto','inf','held',vars.Name};
            includeAllFcns=strcmpi(this.FunctionType,"all");
            for wIdx=1:numWords
                currWord=uniqueWords{wIdx};
                if~ismember(currWord,filterStrings)

                    whichResult=which(currWord);
                    functionType=[];
                    if strncmp(whichResult,'built-in',8)
                        functionType="built-in";
                        filePath=string.empty;
                    elseif~isempty(whichResult)&&endsWith(whichResult,[".m",".p",".mlx"],"IgnoreCase",true)
                        functionType="user-defined";
                        filePath=whichResult;
                    end



                    if~isempty(functionType)&&...
                        (includeAllFcns||strcmpi(functionType,this.FunctionType))
                        wListEntries=wList(wListIdx==wIdx,:);
                        currFcnResult=slreportgen.finder.FunctionReferenceResult(Object=currWord,...
                        FunctionType=functionType,...
                        CallingExpressions=wListEntries(:,2),...
                        CallingBlocks=wListEntries(:,3),...
                        FilePath=filePath,...
                        BlockParameters=wListEntries(:,4));
                        nodeList=[nodeList,currFcnResult];%#ok<AGROW>
                    end
                end
            end
        end
    end

end

function allWords=getBlockParameterWords(block)






    allWords=[];
    if slprivate('is_stateflow_based_block',block)
        return;
    end


    dParams=getBlockEvaluatedParams(block);


    allWords=cell(0,4);
    for j=1:length(dParams)
        currParam=dParams{j};
        try
            paramExpr=get_param(block,currParam);
        catch ME %#ok
            paramExpr='';
        end

        if~isempty(paramExpr)&&ischar(paramExpr)&&~strcmpi(paramExpr,'inf')


            wordsInExpr=getVarAndFuncNames(paramExpr);
            numWords=numel(wordsInExpr);
            if numWords>0
                newWords=cell(numWords,4);
                newWords(:,1)=wordsInExpr;
                newWords(:,2)={paramExpr};
                newWords(:,3)={getfullname(block)};
                newWords(:,4)={currParam};
                allWords=[allWords;newWords];%#ok<AGROW>
            end
        end
    end
end

function allWords=getMaskParameterWords(block)






    maskValues=get_param(block,'MaskValues');
    maskStyles=get_param(block,'MaskStyles');
    maskVisbility=get_param(block,'MaskVisibilities');




    maskVarsExpr=get_param(block,'MaskVariables');
    maskVarTypes=regexp(maskVarsExpr,...
    '=([^;]*)\d+;','tokens');


    varPattern=lettersPattern+asManyOfPattern(alphanumericsPattern|"_");
    maskParamNames=extract(maskVarsExpr,varPattern);

    allWords=cell(0,4);
    if~isempty(maskVarTypes)
        for i=1:length(maskValues)
            if strcmp(maskStyles{i},'edit')&&...
                strcmpi(maskVisbility{i},'on')&&...
                strcmpi(maskVarTypes{i}{1},'@')


                wordsInExpr=getVarAndFuncNames(maskValues{i});
                numWords=numel(wordsInExpr);
                if numWords>0
                    newWords=cell(numWords,3);
                    newWords(:,1)=wordsInExpr;
                    newWords(:,2)=maskValues(i);
                    newWords(:,3)={getfullname(block)};
                    newWords(:,4)={maskParamNames{i}};
                    allWords=[allWords;newWords];%#ok<AGROW>
                end
            end
        end
    end
end

function allWords=getInstanceParameterWords(block)







    instanceParams=get_param(block,"InstanceParametersInfo");

    allWords=cell(0,4);
    for j=1:length(instanceParams)
        currParam=instanceParams(j);
        paramExpr=currParam.Value;

        if~isempty(paramExpr)&&ischar(paramExpr)&&~strcmpi(paramExpr,'inf')


            wordsInExpr=getVarAndFuncNames(paramExpr);
            numWords=numel(wordsInExpr);
            if numWords>0
                newWords=cell(numWords,4);
                newWords(:,1)=wordsInExpr;
                newWords(:,2)={paramExpr};
                newWords(:,3)={getfullname(block)};
                newWords(:,4)={currParam.Name};
                allWords=[allWords;newWords];%#ok<AGROW>
            end
        end
    end
end

function dParams=getBlockEvaluatedParams(blk)



    blkType=mlreportgen.utils.safeGet(blk,'blocktype','get_param');
    dParams=cell.empty;
    if~ismember(blkType,{'Scope','ToWorkspace','ToFile','Display','','N/A'})

        paramStruct=get_param(blk,'intrinsicdialogparameters');
        if isstruct(paramStruct)
            pNames=fieldnames(paramStruct);
            evalDialogParams=cell.empty;


            for j=1:length(pNames)
                pInfo=paramStruct.(pNames{j});
                if strcmp(pInfo.Type,'string')...
                    &&~any(strcmp(pInfo.Attributes,'dont-eval'))
                    evalDialogParams{end+1}=pNames{j};%#ok<AGROW>
                end
            end
            dParams=evalDialogParams;
        end
    end
end

function allWords=getVarAndFuncNames(valStr)



    allWords=cell.empty;

    if~isempty(valStr)

        validVarNamePattern=asManyOfPattern(alphanumericsPattern|"_"|".");
        valStr=extract(valStr,validVarNamePattern);

        invalidStartPattern=digitsPattern(1)|".";
        for i=1:length(valStr)
            wordToken=valStr{i};

            if~isempty(wordToken)&&~startsWith(wordToken,invalidStartPattern)
                if contains(wordToken,".")
                    wordToken=extractBefore(wordToken,".");
                end
                allWords{end+1,1}=wordToken;%#ok<AGROW>
            end
        end
    end

    allWords=unique(allWords);
end

function nodeList=filterNodesByProperty(nodeList,props)
    nProps=numel(props);


    nNodes=numel(nodeList);
    idx=true(1,nNodes);



    for i=1:2:nProps
        name=props{i};
        value=props{i+1};
        try
            nodePropVals={nodeList.(name)};
            idx=idx&cellfun(@(x)isequal(x,value),nodePropVals);
        catch
            idx=false(1,nNodes);
            break;
        end
    end
    nodeList=nodeList(idx);
end