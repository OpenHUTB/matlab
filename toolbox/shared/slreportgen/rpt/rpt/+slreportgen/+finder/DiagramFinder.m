classdef DiagramFinder<mlreportgen.finder.Finder

























































































    properties




        SearchDepth(1,1)double{mustBeIntegerOrInfinite}=inf;






        IncludeMaskedSubsystems(1,1)logical=true;






        IncludeReferencedModels(1,1)logical=true;






        IncludeReferencedSubsystems(1,1)logical=true;










        IncludeSimulinkLibraryLinks(1,1)logical=true;










        IncludeUserLibraryLinks(1,1)logical=true;




        IncludeCommented(1,1)logical=false;









        IncludeVariants="Active";














        AutoCloseModel(1,1)logical=true;
    end

    properties(Constant,Hidden)
        InvalidPropertyNames=[];
    end

    properties(Constant,Access=private)



        ImplementationDiagramList={...
'Stateflow.StateTransitionTableChart'...
        ,'Stateflow.TruthTableChart'...
        ,'Stateflow.TruthTable'};
    end

    properties(Access=private)
        m_traversalConstraintTreeFilter;
        m_variantConstraintActiveVariant;
        m_findResultsState;
    end

    methods
        function h=DiagramFinder(varargin)
            h=h@mlreportgen.finder.Finder(varargin{:});
            reset(h);
        end

        function delete(h)
            unloadSelfLoadedModel(h);
        end

        function set.SearchDepth(h,val)
            mustNotBeIterating(h,"SearchDepth");
            h.SearchDepth=val;
            reset(h);
        end

        function set.IncludeMaskedSubsystems(h,val)
            mustNotBeIterating(h,"IncludeMaskedSubsystems");
            h.IncludeMaskedSubsystems=val;
            reset(h);
        end

        function set.IncludeReferencedModels(h,val)
            mustNotBeIterating(h,"IncludeReferencedModels");
            h.IncludeReferencedModels=val;
            reset(h);
        end

        function set.IncludeReferencedSubsystems(h,val)
            mustNotBeIterating(h,"IncludeReferencedSubsystems");
            h.IncludeReferencedSubsystems=val;
            reset(h);
        end

        function set.IncludeSimulinkLibraryLinks(h,val)
            mustNotBeIterating(h,"IncludeSimulinkLibraryLinks");
            h.IncludeSimulinkLibraryLinks=val;
            reset(h);
        end

        function set.IncludeUserLibraryLinks(h,val)
            mustNotBeIterating(h,"IncludeUserLibraryLinks");
            h.IncludeUserLibraryLinks=val;
            reset(h);
        end

        function set.IncludeCommented(h,val)
            mustNotBeIterating(h,"IncludeCommented");
            h.IncludeCommented=val;
            reset(h);
        end

        function set.IncludeVariants(h,val)
            mustNotBeIterating(h,"IncludeVariants");
            switch lower(string(val))
            case "all"
                val="All";
            case "active"
                val="Active";
            case "activepluscode"
                val="ActivePlusCode";
            end
            mustBeMember(val,["All","Active","ActivePlusCode"]);
            h.IncludeVariants=val;
            reset(h);
        end

        function results=find(h)

















































            origAutoClose=h.AutoCloseModel;
            h.AutoCloseModel=false;


            state=h.m_findResultsState;


            reset(h);


            results=slreportgen.finder.DiagramResult.empty();
            while hasNextContainer(h)
                moveToNextContainer(h);
                results=[results,h.m_findResultsState.results];%#ok
            end




            h.m_findResultsState=state;
            h.m_findResultsState.m_selfLoadedModel=string.empty();
            h.AutoCloseModel=origAutoClose;
        end

        function result=next(h)










            if hasNext(h)
                result=h.m_findResultsState.results(h.m_findResultsState.index);
                moveToNextResult(h);
            else
                result=slreportgen.finder.DiagramResult.empty();
            end
        end

        function tf=hasNext(h)








































            tf=isIterating(h);
            while(~tf&&hasNextContainer(h))
                moveToNextContainer(h);
                tf=isIterating(h);
            end
        end
    end

    methods(Hidden)
        function result=first(h)
            reset(h);
            result=next(h);
        end
    end

    methods(Access=protected)
        function tf=isIterating(h)
            tf=~isempty(h.m_findResultsState)...
            &&(h.m_findResultsState.index>0)...
            &&(h.m_findResultsState.index<=h.m_findResultsState.nResults);
        end

        function tf=satisfyResultConstraint(h,result)%#ok
            tf=true;
        end

        function reset(h)
            h.m_findResultsState=struct(...
            'index',-1,...
            'results',[],...
            'nResults',0,...
            'containerQueue',{{slreportgen.utils.getDiagramPath(h.Container)}},...
            'referencedModels',string.empty(),...
            'selfLoadedModel',string.empty());
        end
    end

    methods(Access=private)
        function moveToNextResult(h)
            if(h.m_findResultsState.index>0)&&(h.m_findResultsState.index<h.m_findResultsState.nResults)
                h.m_findResultsState.index=h.m_findResultsState.index+1;
            else
                h.m_findResultsState.index=0;
            end
        end

        function moveToNextContainer(h)
            unloadSelfLoadedModel(h);

            containerQueue=h.m_findResultsState.containerQueue;
            if~isempty(containerQueue)
                container=h.m_findResultsState.containerQueue{1};
                loadModelIfNecessary(h,container);

                hs=slreportgen.utils.HierarchyService;
                containerHID=hs.getDiagramHID(container);
                h.m_findResultsState.containerQueue(1)=[];
                results=findImpl(h,containerHID);

                nResults=numel(results);
                if(nResults>0)
                    index=1;
                else
                    index=0;
                end
            else
                index=0;
                nResults=0;
                results=[];
            end

            h.m_findResultsState.index=index;
            h.m_findResultsState.nResults=nResults;
            h.m_findResultsState.results=results;
        end

        function tf=hasNextContainer(h)
            tf=~isempty(h.m_findResultsState.containerQueue);
        end

        function loadModelIfNecessary(h,container)
            pathSplits=slreportgen.utils.pathSplit(container);
            modelName=pathSplits(1);

            isLoaded=~isempty(find_system(0,'SearchDepth',0,'Name',modelName));
            if~isLoaded
                load_system(modelName);
                h.m_findResultsState.selfLoadedModel=modelName;
            end
        end

        function unloadSelfLoadedModel(h)
            if~isempty(h.m_findResultsState)
                model=h.m_findResultsState.selfLoadedModel;
                if(h.AutoCloseModel&&~isempty(model))

                    slreportgen.utils.uncompileModel(model);
                    close_system(model,0);
                end
                h.m_findResultsState.selfLoadedModel=string.empty();
            end
        end

        function addModelReferenceToContainerQueue(h,eobjH)
            models=string(get_param(eobjH,'ModelName'));

            if(h.IncludeVariants=="All")...
                ||((h.IncludeVariants=="ActivePlusCode")...
                &&strcmp(get_param(eobjH,'GeneratePreprocessorConditionals'),'on'))

                variants=get(eobjH,'Variants');
                if~isempty(variants)
                    models=string({variants.ModelName});
                end
            end

            referencedModels=h.m_findResultsState.referencedModels;
            containerQueue=h.m_findResultsState.containerQueue;
            for model=models
                if all(model~=referencedModels)
                    referencedModels=[referencedModels,model];%#ok
                    containerQueue{end+1}=model;%#ok
                end
            end

            h.m_findResultsState.referencedModels=referencedModels;
            h.m_findResultsState.containerQueue=containerQueue;
        end

        function results=findImpl(h,startHID)
            hs=slreportgen.utils.HierarchyService;
            results=[];
            queue=slreportgen.finder.DiagramResult(...
            'Object',startHID,...
            'Name',string(hs.getName(startHID)),...
            'Path',string(hs.getPath(startHID)));
            maxDepth=h.SearchDepth;
            currentDepth=0;
            remainders=1;
            nextRemainders=0;

            while(~isempty(queue))

                result=queue(1);
                queue(1)=[];

                if(satisfyObjectPropertiesConstraint(h,result.Object)...
                    &&satisfyResultConstraint(h,result))
                    results=[results,result];%#ok
                end

                resultChildren=getResultChildren(h,result);

                nextRemainders=nextRemainders+numel(resultChildren);
                remainders=remainders-1;
                if(remainders==0)
                    currentDepth=currentDepth+1;
                    if(currentDepth>maxDepth)
                        break;
                    end
                    remainders=nextRemainders;
                    nextRemainders=0;
                end


                queue=[queue,resultChildren];%#ok
            end


            if~isempty(results)
                [~,i]=sort([results.Path]);
                results=results(i);
            end
        end

        function results=getResultChildren(h,result)
            hs=slreportgen.utils.HierarchyService;
            results=[];
            dhid=getDiagramHID(result);
            dobjH=result.Object;
            dPath=result.Path;

            if(h.IncludeSimulinkLibraryLinks||h.IncludeUserLibraryLinks)
                slreportgen.utils.loadAllSystems(dobjH);
            end

            setupTraversalConstraint(h,dobjH);
            ehids=hs.getChildren(dhid);
            for ehid=ehids
                if satisfyTraversalConstraint(h,ehid)
                    cdhid=hs.getDiagramHID(ehid);
                    cdName=string(hs.getName(cdhid));

                    cResult=slreportgen.finder.DiagramResult(...
                    'Object',cdhid,...
                    'Name',cdName,...
                    'Path',slreportgen.utils.pathJoin(dPath,cdName));

                    results=[results,cResult];%#ok
                end
            end
        end

        function setupTraversalConstraint(h,dobjH)
            h.m_traversalConstraintTreeFilter=SLM3I.SLTreeFilter();
            treeFilter=h.m_traversalConstraintTreeFilter;
            treeFilter.ShowSystemsWithMaskedParameters=h.IncludeMaskedSubsystems;
            treeFilter.ShowReferencedModels=h.IncludeReferencedModels;
            treeFilter.ShowMathworksLinks=h.IncludeSimulinkLibraryLinks;
            treeFilter.ShowUserLinks=h.IncludeUserLibraryLinks;
            if isa(dobjH,'Stateflow.Object')

                treeFilter.ShowMathworksLinks=h.IncludeUserLibraryLinks;
            end

            setupVariantConstraint(h,dobjH);
        end

        function setupVariantConstraint(h,dobjH)
            h.m_variantConstraintActiveVariant=[];
            if(isprop(dobjH,'Variant')&&strcmp(get(dobjH,'Variant'),'on'))...
                &&((h.IncludeVariants=="Active")...
                ||(h.IncludeVariants=="ActivePlusCode")&&strcmp(get(dobjH,'VariantActivationTime'),'update diagram'))

                activeVariantBlock=get(dobjH,'ActiveVariantBlock');
                if~isempty(activeVariantBlock)
                    h.m_variantConstraintActiveVariant=get_param(activeVariantBlock,'Handle');
                end
            end
        end

        function tf=satisfyTraversalConstraint(h,ehid)
            tf=false;

            if keepHid(h.m_traversalConstraintTreeFilter,ehid)
                eobjH=slreportgen.utils.getSlSfHandle(ehid);

                if(satisfyVariantConstraint(h,eobjH)&&satisfyCommentedConstraint(h,eobjH))

                    if(h.IncludeReferencedModels&&slreportgen.utils.isModelReferenceBlock(eobjH))
                        addModelReferenceToContainerQueue(h,eobjH)

                    elseif slreportgen.utils.isSubsystemReferenceBlock(eobjH)&&~h.IncludeReferencedSubsystems

                        tf=false;
                    else

                        hs=slreportgen.utils.HierarchyService;
                        dhid=hs.getDiagramHID(ehid);
                        domain=hs.getDomain(dhid);
                        if(strcmp(domain,'Simulink')||strcmp(domain,'Stateflow'))
                            dobjH=slreportgen.utils.getSlSfHandle(dhid);
                            if~ismember(class(dobjH),h.ImplementationDiagramList)

                                tf=true;
                            end
                        end
                    end
                end
            end
        end

        function tf=satisfyVariantConstraint(h,eobjH)
            tf=(isempty(h.m_variantConstraintActiveVariant)||(eobjH==h.m_variantConstraintActiveVariant));
        end

        function tf=satisfyCommentedConstraint(h,eobjH)
            tf=(h.IncludeCommented||~slreportgen.utils.isCommented(eobjH));
        end
    end
end

function mustBeIntegerOrInfinite(val)
    mustBeNumeric(val)
    if~isinf(val)
        mustBeInteger(val);
    end
end