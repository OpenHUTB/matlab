classdef SLCompositionVisitor<handle





    properties(SetAccess=immutable,GetAccess=private)
        RootCompositionModel;
        VisitSubCompositions;
    end

    properties(Transient,Access=private)
        ComponentBlocks={};
        CompositionBlocks={};
    end

    methods
        function this=SLCompositionVisitor(rootCompositionModel,doVisitSubCompositions)
            assert(autosar.composition.Utils.isModelInCompositionDomain(rootCompositionModel),...
            '%s is not in AUTOSAR Composition subdomain',rootCompositionModel);
            this.RootCompositionModel=rootCompositionModel;
            if nargin<2
                doVisitSubCompositions=true;
            end
            this.VisitSubCompositions=doVisitSubCompositions;
        end
    end

    methods(Access=protected)
        function visitCompBlock(this,blk)%#ok<INUSD>


        end

        function visitComponent(this,blk)%#ok<INUSD>



        end

        function visitComposition(this,blk)%#ok<INUSD>



        end

        function visitCompBlocks(this,parentSys)







            this.collectCompBlocks(parentSys);


            for ii=1:length(this.ComponentBlocks)
                this.visitCompBlock(this.ComponentBlocks{ii});
            end


            for ii=1:length(this.CompositionBlocks)
                this.visitCompBlock(this.CompositionBlocks{ii});
            end
        end

        function visitComponents(this,parentSys)






            this.collectCompBlocks(parentSys);



            compsToVisit={};
            for ii=1:length(this.ComponentBlocks)
                blk=this.ComponentBlocks{ii};
                [isLinked,refMdl]=autosar.composition.Utils.isCompBlockLinked(blk);
                if isLinked
                    compToVisit=refMdl;
                else
                    compToVisit=blk;
                end
                if~any(strcmp(compToVisit,compsToVisit))
                    compsToVisit{end+1}=compToVisit;%#ok<AGROW>
                end
            end


            visitInfo=struct(...
            'NumElmsToVisit',length(compsToVisit),...
            'CurrentElmIdx',-1);


            for ii=1:length(compsToVisit)
                visitInfo.CurrentElmIdx=ii;
                this.visitComponent(compsToVisit{ii},visitInfo);
            end
        end

        function visitCompositions(this,parentSys)






            this.collectCompBlocks(parentSys);



            compsToVisit={};
            for ii=1:length(this.CompositionBlocks)
                blk=this.CompositionBlocks{ii};
                [isLinked,refMdl]=autosar.composition.Utils.isCompBlockLinked(blk);
                if isLinked
                    compToVisit=refMdl;
                else
                    compToVisit=blk;
                end
                if~any(strcmp(compToVisit,compsToVisit))
                    compsToVisit{end+1}=compToVisit;%#ok<AGROW>
                end
            end



            numElmsToVisit=length(compsToVisit);
            if strcmp(get_param(parentSys,'type'),'block_diagram')

                numElmsToVisit=numElmsToVisit+1;
            end
            visitInfo=struct(...
            'NumElmsToVisit',numElmsToVisit,...
            'CurrentElmIdx',-1);


            for ii=1:length(compsToVisit)
                visitInfo.CurrentElmIdx=ii;
                this.visitComposition(compsToVisit{ii},visitInfo);
            end


            if strcmp(get_param(parentSys,'type'),'block_diagram')
                visitInfo.CurrentElmIdx=numElmsToVisit;
                this.visitComposition(parentSys,visitInfo);
            end
        end
    end

    methods(Access=private)
        function collectCompBlocks(this,parentSys)


            this.ComponentBlocks={};
            this.CompositionBlocks={};


            this.doCollectCompBlocks(parentSys);



            this.ComponentBlocks=unique(this.ComponentBlocks,'stable');
            this.CompositionBlocks=unique(this.CompositionBlocks,'stable');
        end

        function doCollectCompBlocks(this,parentSys)

            parentSys=getfullname(parentSys);



            blocks=find_system(parentSys,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'type','block');
            blocks=blocks(~strcmp(blocks,parentSys));
            for ii=1:length(blocks)
                blk=blocks{ii};
                if autosar.composition.Utils.isCompositionBlock(blk)&&...
                    this.VisitSubCompositions
                    [isLinked,refMdl]=autosar.composition.Utils.isCompBlockLinked(blk);
                    if isLinked
                        if~bdIsLoaded(refMdl)
                            load_system(refMdl);
                        end

                        this.doCollectCompBlocks(refMdl);
                    else

                        this.doCollectCompBlocks(blk);
                    end
                    this.CompositionBlocks{end+1}=blk;
                elseif autosar.composition.Utils.isComponentBlock(blk)
                    [isLinked,refMdl]=autosar.composition.Utils.isCompBlockLinked(blk);
                    if isLinked
                        if~bdIsLoaded(refMdl)
                            load_system(refMdl);
                        end
                    end
                    this.ComponentBlocks{end+1}=blk;
                else


                end
            end
            if strcmp(get_param(parentSys,'type'),'block')
                this.CompositionBlocks{end+1}=parentSys;
            end
        end
    end
end



