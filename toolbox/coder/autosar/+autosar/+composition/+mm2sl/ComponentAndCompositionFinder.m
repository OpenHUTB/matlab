classdef ComponentAndCompositionFinder<handle





    properties(Access=private)
        SequenceOfM3IComponents;
        SequenceOfM3ICompositions;
        M3IModelSplitter;
    end

    methods
        function this=ComponentAndCompositionFinder(m3iTopComposition,m3iModelSplitter)
            this.M3IModelSplitter=m3iModelSplitter;
            this.findComponentsAndCompositionsUnder(m3iTopComposition);
        end

        function m3iAtomicSwcs=getAtomicComponents(this)
            m3iAtomicSwcs=this.SequenceOfM3IComponents;
        end

        function m3iCompositions=getCompositions(this)
            m3iCompositions=this.SequenceOfM3ICompositions;
        end
    end

    methods(Access=private)
        function findComponentsAndCompositionsUnder(this,m3iTopComposition)
            if~isempty(this.M3IModelSplitter)

                this.SequenceOfM3IComponents=this.M3IModelSplitter.getAtomicComponents();
                this.SequenceOfM3ICompositions=this.M3IModelSplitter.getCompositions();
            else
                m3iModel=m3iTopComposition.rootModel;
                this.SequenceOfM3IComponents=Simulink.metamodel.arplatform.component.SequenceOfAtomicComponent.make(m3iModel);
                this.SequenceOfM3ICompositions=Simulink.metamodel.arplatform.composition.SequenceOfCompositionComponent.make(m3iModel);



                m3iComponents=autosar.composition.Utils.findAtomicComponents(...
                m3iTopComposition,true,false);
                for m3iComponent=m3iComponents
                    this.SequenceOfM3IComponents.append(m3iComponent);
                end

                m3iCompositions=autosar.composition.Utils.findCompositionComponents(...
                m3iTopComposition,true);
                for m3iComposition=m3iCompositions
                    this.SequenceOfM3ICompositions.append(m3iComposition);
                end
            end
        end
    end
end
