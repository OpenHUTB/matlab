classdef ModelVariableFinder<mlreportgen.finder.Finder



































































    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties



















        Regexp(1,1)matlab.lang.OnOffSwitchState=false;








        SearchMethod(1,1)string{mustBeMember(SearchMethod,["cached","compiled"])}="compiled"








        SearchReferencedModels(1,1)matlab.lang.OnOffSwitchState=true;






        Name string{mustBeScalarOrEmpty}












        SourceType string{mustBeScalarOrEmpty}























        Users string{mustBeVector(Users,"allow-all-empties")}







        LookUnderMasks=matlab.lang.OnOffSwitchState(true);









        FollowLibraryLinks(1,1)matlab.lang.OnOffSwitchState=true;
















        IncludeInactiveVariants(1,1)matlab.lang.OnOffSwitchState=false;
    end

    properties(Access=private)


        NodeList=[]


        NodeCount{mustBeInteger}=0


        NextNodeIndex{mustBeInteger}=0


        IsIterating{mlreportgen.report.validators.mustBeLogical}=false



        InstanceParams=[];
    end

    methods
        function this=ModelVariableFinder(varargin)
            this=this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function set.LookUnderMasks(this,value)

            mustBeNonempty(value);


            if strcmpi(value,"none")
                value=false;
            elseif strcmpi(value,"all")
                value=true;
            end

            value=matlab.lang.OnOffSwitchState(value);


            mustBeScalarOrEmpty(value);
            this.LookUnderMasks=value;
        end

        function results=find(this)












            findImpl(this);

            results=this.NodeList;
        end
    end

    methods
        function result=next(this)















            if hasNext(this)

                result=this.NodeList(this.NextNodeIndex);

                this.NextNodeIndex=this.NextNodeIndex+1;
            else
                result=slreportgen.finder.ModelVariableResult.empty();
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




            if~slreportgen.utils.isValidSlSystem(this.Container)
                error(message("slreportgen:finder:error:mustBeSimulinkModel",this.Container));
            end

            obj=slreportgen.utils.getSlSfObject(this.Container);
            container=getFullName(obj);



            opts=createFindVarsOptions(this,container);



            findVarsCleanup=uncompileRefModels(this,container);%#ok<NASGU>



            if~isempty(this.Users)
                users=this.Users;
                nUsers=numel(users);



                nodeList=[];
                for userIdx=1:nUsers
                    try
                        nodes=Simulink.findVars(container,opts{:},"Users",users(userIdx));
                    catch me
                        error(message("slreportgen:finder:error:findVarsError",...
                        [newline,newline,getReport(me,"basic")]));
                    end
                    nodeList=[nodeList;nodes];
                end
                nodeList=unique(nodeList,'stable');
            else


                try
                    nodeList=Simulink.findVars(container,opts{:});
                catch me
                    error(message("slreportgen:finder:error:findVarsError",...
                    [newline,newline,getReport(me,"basic")]));
                end
            end


            nodeList=filterByPropertiesList(this,nodeList);



            if this.LookUnderMasks
                maskOpts={'type','block'};
            else
                maskOpts={'mask','off'};
            end

            if Simulink.internal.useFindSystemVariantsMatchFilter()
                if this.IncludeInactiveVariants


                    variantOpts={'MatchFilter',@Simulink.match.allVariants};
                else





                    containerModel=bdroot(container);
                    if strcmpi(this.SearchMethod,"compiled")&&~slreportgen.utils.isModelCompiled(containerModel)
                        set_param(containerModel,"SimulationCommand","update");
                    end
                    variantOpts={'MatchFilter',@Simulink.match.activeVariants};
                end
            else
                if this.IncludeInactiveVariants


                    variantOpts={'Variants','ActivePlusCodeVariants'};
                else
                    variantOpts={'Variants','ActiveVariants'};
                end
            end
            if this.SearchReferencedModels
                [mdlList,refBlks]=find_mdlrefs(container,variantOpts{:});







                this.InstanceParams=getInstanceParams(this,container,refBlks);
            else
                mdlList={char(container)};
            end



            reportedSystems=getReportedSystems(this,mdlList,maskOpts,variantOpts);



            nodeList=filterBySystem(this,nodeList,reportedSystems);


            this.NodeList=getVariableResults(this,nodeList);
            this.NodeCount=length(this.NodeList);
        end

        function opts=createFindVarsOptions(this,container)



            opts={"Regexp",this.Regexp.string,...
            "SearchReferencedModels",this.SearchReferencedModels.string};



            if slreportgen.utils.isModelCompiled(container)
                opts=[opts,"SearchMethod","cached"];
            else
                opts=[opts,"SearchMethod",this.SearchMethod];
            end


            if~isempty(this.Name)
                opts=[opts,"Name",this.Name];
            end
            if~isempty(this.SourceType)
                verifySourceType(this);
                opts=[opts,"SourceType",this.SourceType];
            end
        end

        function findVarsCleanup=uncompileRefModels(this,container)







            findVarsCleanup=[];
            if strcmp(this.SearchMethod,"compiled")&&~slreportgen.utils.isModelCompiled(container)

                refMdls=find_mdlrefs(container,...
                'MatchFilter',@Simulink.match.allVariants);
                nMdls=length(refMdls);
                compileAfterSearch=strings(1,0);


                for k=nMdls:-1:1
                    currMdl=refMdls{k};
                    if slreportgen.utils.isModelLoaded(currMdl)&&...
                        slreportgen.utils.isModelCompiled(currMdl)
                        compileAfterSearch(end+1)=currMdl;
                        slreportgen.utils.uncompileModel(currMdl);
                    end
                end
                findVarsCleanup=onCleanup(@()compileModels(compileAfterSearch));
            end
        end

        function reportedSystems=getReportedSystems(this,mdlList,maskOpts,variantOpts)



            if this.LookUnderMasks
                lookUnderMasks='all';
            else
                lookUnderMasks='none';
            end
            reportedSystems=find_system(mdlList,...
            'LookUnderMasks',lookUnderMasks,...
            variantOpts{:},...
            'FollowLinks',char(this.FollowLibraryLinks),...
            'blocktype','SubSystem',...
            maskOpts{:});


            if~this.FollowLibraryLinks
                reportedSystems=filterLibraries(this,reportedSystems);
            end


            reportedSystems=union(reportedSystems,mdlList);
            reportedSystems=strrep(reportedSystems,newline,' ');
        end

        function filteredList=filterLibraries(~,allList)

            blockList=find_system(allList,...
            'SearchDepth',0,...
            'type','block');

            noLinkBlocks=find_system(blockList,...
            'SearchDepth',0,...
            'LinkStatus','none');

            inactiveLinkBlocks=find_system(blockList,...
            'SearchDepth',0,...
            'LinkStatus','inactive');

            unlinkedBlocks=union(inactiveLinkBlocks,noLinkBlocks);

            linkedBlocks=setdiff(blockList,unlinkedBlocks);

            if~isempty(linkedBlocks)
                modelList=setdiff(allList,blockList);
                filteredList=[modelList(:)
                unlinkedBlocks(:)];
            else
                filteredList=allList(:);
            end
        end

        function out=filterBySystem(~,in,sys)


            numberOfInputs=length(in);
            keep=false(1,numberOfInputs);
            for i=1:numberOfInputs
                users=in(i).Users;

                userSystems=string(get_param(users,"Parent"));




                topLevelUserIdx=userSystems=="";
                userSystems(topLevelUserIdx)=users(topLevelUserIdx);

                userSystems=strrep(userSystems,newline," ");
                if any(ismember(userSystems,sys))
                    keep(i)=true;
                end
            end

            out=in(keep);
        end

        function filteredNodes=filterByPropertiesList(this,nodes)




            props=this.Properties;
            if~isempty(props)
                nProps=numel(props);


                nNodes=numel(nodes);
                idx=true(1,nNodes);



                for i=1:2:nProps
                    name=props{i};
                    value=props{i+1};

                    try
                        nodePropVals={nodes.(name)};
                        idx=idx&cellfun(@(x)isequal(x,value),nodePropVals);
                    catch
                        idx=false(1,nNodes);
                        break;
                    end
                end
                filteredNodes=nodes(idx);
            else

                filteredNodes=nodes;
            end
        end

        function paramList=getInstanceParams(~,container,refBlks)







            paramList=struct.empty();
            instanceParams=get_param(refBlks,"InstanceParametersInfo");
            numInstanceParams=numel(instanceParams);
            for blkIdx=1:numInstanceParams
                blk=refBlks{blkIdx};
                isBlockInTopMdl=strcmp(container,bdroot(blk));
                blkParams=instanceParams{blkIdx};
                for paramIdx=1:numel(blkParams)
                    param=blkParams(paramIdx);
                    if isBlockInTopMdl||~param.Argument

                        param.ModelBlockPath=blk;
                        paramList=[paramList,param];%#ok<*AGROW>
                    end
                end
            end
        end

        function results=getVariableResults(this,vars)







            results=slreportgen.finder.ModelVariableResult.empty(0,0);
            for i=1:numel(vars)
                node=vars(i);
                if~isempty(this.InstanceParams)


                    sameSourceIdx=strcmp(node.Source,{this.InstanceParams.ParameterCreatedFrom});
                    instanceParamsIdx=sameSourceIdx&strcmp(node.Name,{this.InstanceParams.Name});
                    instanceParams=this.InstanceParams(instanceParamsIdx);

                    if isempty(instanceParams)

                        results(end+1)=slreportgen.finder.ModelVariableResult(node);
                    else




                        for ip=instanceParams
                            r=slreportgen.finder.ModelVariableResult(node);
                            r.ModelBlockPath=ip.ModelBlockPath;
                            results(end+1)=r;
                        end
                    end
                else
                    results(i)=slreportgen.finder.ModelVariableResult(node);
                end
            end
            this.InstanceParams=[];
        end

        function verifySourceType(this)
            sourceType=this.SourceType;
            options={'base workspace','model workspace',...
            'mask workspace','data dictionary'};
            if this.Regexp
                regexpSearch=regexp(options,sourceType);
                invalidExpr=isempty([regexpSearch{:}]);
            else
                invalidExpr=~ismember(sourceType,options);
            end

            if invalidExpr
                errorStr=[newline,'"',strjoin(options,['"',newline,'"']),'"'];
                error(message("slreportgen:finder:error:ModelVariableInvalidSourceType",sourceType,errorStr));
            end
        end

    end

end

function compileModels(mdls)
    nMdls=length(mdls);
    for k=1:nMdls
        slreportgen.utils.compileModel(mdls(k));
    end
end
