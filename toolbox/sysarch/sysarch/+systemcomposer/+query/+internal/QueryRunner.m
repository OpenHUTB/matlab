classdef QueryRunner<handle




    properties
RootArch
Constraint
IsRecursive
FlattenReferences
CompPaths
Elems
ElemImpls
PathPrefix
ElemKindToFind
    end

    properties(Hidden=true)
        isEvaluatedUsingNewSystem=false;
    end

    methods
        function obj=QueryRunner(rootArch,constraint,isRecursive,flattenReferences,elemKind)


            obj.RootArch=rootArch;
            obj.Constraint=constraint;


            if checkIfEvaluatedUsingNewSystem(obj)
                obj.isEvaluatedUsingNewSystem=true;
            end

            obj.IsRecursive=isRecursive;
            obj.FlattenReferences=flattenReferences;
            obj.Elems=[];
            obj.CompPaths={};
            obj.Elems=[];

            obj.ElemKindToFind=systemcomposer.query.internal.ElementKindEnum.make(elemKind);




            parent=rootArch.Parent;
            obj.PathPrefix='';
            if~isempty(parent)
                obj.PathPrefix=[parent.Parent.getQualifiedName,'/'];
            end
        end

        function execute(obj)

            if obj.isEvaluatedUsingNewSystem


                levelCount=1;
                obj.searchUsingNewSystem(obj.RootArch,[],levelCount);
            else

                obj.searchArchitecture(obj.RootArch);
            end
        end
    end

    methods(Access=private)
        function evalUsingNewSys=checkIfEvaluatedUsingNewSystem(obj)
            evalUsingNewSys=false;






            if obj.isNegationConstraint
                return;
            end

            evalUsingNewSys=obj.Constraint.isEvaluatedUsingNewSystem();
        end

        function res=isNegationConstraint(obj)
            res=false;
            constraint=obj.Constraint;
            while~isempty(constraint)
                if constraint.isNegationConstraint
                    res=true;
                    break;
                end
                if isprop(constraint,'CompareFcnHdl')
                    if isequal(constraint.CompareFcnHdl,@ne)
                        res=true;
                        break;
                    end
                end


                if isprop(constraint,'SubConstraint')
                    constraint=constraint.SubConstraint;
                else
                    constraint=[];
                end
            end
        end

        function searchUsingNewSystem(obj,archsToBeProcessed,parentResolvers,levelCount)
            import systemcomposer.query.internal.*;

            for archToBeProcessed=archsToBeProcessed
                [refArchs,resolvers]=obj.filterAndCollectReferenceArchitectures(archToBeProcessed);

                if obj.ElemKindToFind==ElementKindEnum.Connector
                    elemKind='systemcomposer.arch.BaseConnector';
                elseif obj.ElemKindToFind==ElementKindEnum.Port
                    elemKind='systemcomposer.arch.BasePort';
                else
                    elemKind='systemcomposer.arch.BaseComponent';
                end


                elems=obj.Constraint.getSatisfied(archToBeProcessed,elemKind,obj.FlattenReferences,parentResolvers);



                obj.filterResultingModelElems(elems);





                if~isempty(refArchs)&&(obj.FlattenReferences||levelCount<2)
                    for idx=1:numel(refArchs)
                        obj.searchUsingNewSystem(refArchs(idx),[resolvers(idx),parentResolvers],levelCount+1);
                    end
                end
            end
        end

        function filterResultingModelElems(obj,modelElems)
            for idx=1:numel(modelElems)
                modelElem=modelElems(idx);
                containingArchElem=[];
                if isa(modelElem,'systemcomposer.arch.ComponentPort')
                    compElem=modelElem.Parent;
                    if obj.RootArch.getImpl.isAncestorOfComponent(compElem.getImpl)
                        containingArchElem=compElem.Parent;
                    else
                        continue;
                    end
                elseif isa(modelElem,'systemcomposer.arch.ArchitecturePort')
                    if obj.RootArch.getImpl.isAncestorOfArchitecture(modelElem.Parent.getImpl)
                        containingArchElem=modelElem.Parent;
                    else
                        continue;
                    end
                elseif isa(modelElem,'systemcomposer.arch.BaseComponent')
                    if obj.RootArch.getImpl.isAncestorOfComponent(modelElem.getImpl)
                        containingArchElem=modelElem.Parent;
                    else
                        continue;
                    end
                elseif isa(modelElem,'systemcomposer.arch.BaseConnector')

                end
                if~obj.IsRecursive&&~isequal(containingArchElem,obj.RootArch)
                    continue;
                end
                obj.addElement(modelElem);
            end
        end

        function[refArchs,resolvers]=filterAndCollectReferenceArchitectures(obj,arch)
            import systemcomposer.architecture.model.*;
            refArchs=[];
            resolvers=[];
            mf0Model=mf.zero.getModel(arch.getImpl);
            if(~isempty(mf0Model))

                topElems=mf0Model.topLevelElements;
                resolversInt=[];
                for topElem=topElems
                    if(isa(topElem,'systemcomposer.services.proxy.SysArchCompModelResolver'))
                        resolversInt=[resolversInt,topElem];%#ok<AGROW>
                    end
                end



                if~isempty(obj.PathPrefix)
                    filteredCompModelResolvers=obj.filterCompModelResolvers(resolversInt);
                else
                    filteredCompModelResolvers=resolversInt;
                end



                for idx=1:numel(filteredCompModelResolvers)
                    resolver=filteredCompModelResolvers(idx);
                    resolvedZCMdl=SystemComposerModel.getSystemComposerModel(resolver.getResolvedModel);
                    refArchs=[refArchs...
                    ,systemcomposer.internal.getWrapperForImpl(resolvedZCMdl.getRootArchitecture)];%#ok<AGROW>
                    resolvers=[resolvers,resolver];%#ok<AGROW>
                end
            end
        end

        function filteredCompModelResolvers=filterCompModelResolvers(obj,resolvers)
            filteredCompModelResolvers=[];
            for resolver=resolvers
                for proxy=resolver.Proxies.toArray
                    for source=proxy.Source.toArray
                        realElem=source.realElement;
                        if~isa(realElem,'systemcomposer.architecture.model.design.Component')
                            continue;
                        end


                        if obj.RootArch.getImpl.isAncestorOfArchitecture(realElem.getArchitecture)
                            filteredCompModelResolvers=[filteredCompModelResolvers,resolver];%#ok<AGROW>
                            break;
                        end
                    end
                end
            end
            filteredCompModelResolvers=unique(filteredCompModelResolvers);
        end

        function searchArchitecture(obj,arch)
            import systemcomposer.query.internal.*;

            if(obj.ElemKindToFind==ElementKindEnum.Connector)
                obj.searchConnectors(arch);
            elseif(obj.ElemKindToFind==ElementKindEnum.Port)
                obj.searchPorts(arch);
            end

            compsToSearch=arch.Components;
            for i=1:numel(compsToSearch)
                obj.searchComponentInternal(compsToSearch(i));
            end

        end

        function searchComponent(obj,comp)
            compsToSearch=comp.getImpl.getComponents;
            for i=1:numel(compsToSearch)
                compImpl=compsToSearch(i);
                comp=systemcomposer.internal.getWrapperForImpl(compImpl);
                obj.searchComponentInternal(comp);
            end
        end

        function searchPorts(obj,comp)

            portsToSearch=comp.Ports;
            for i=1:numel(portsToSearch)
                if(obj.Constraint.isSatisfied(portsToSearch(i)))
                    obj.addElement(portsToSearch(i));
                end
            end

        end

        function searchConnectors(obj,comp)

            connsToSearch=comp.getImpl.getConnectors;
            for i=1:numel(connsToSearch)
                conn=systemcomposer.internal.getWrapperForImpl(connsToSearch(i));
                if(obj.Constraint.isSatisfied(conn))
                    obj.addElement(conn);
                end
            end

        end

        function searchComponentInternal(obj,comp)
            import systemcomposer.query.internal.*;

            switch obj.ElemKindToFind
            case ElementKindEnum.Component
                if(obj.Constraint.isSatisfied(comp))
                    obj.addElement(comp);
                end

            case ElementKindEnum.Port
                obj.searchPorts(comp);
            case ElementKindEnum.Connector
                obj.searchConnectors(comp);
            end

            if(obj.IsRecursive)
                isRef=false;
                try
                    isRef=comp.isReference;
                catch

                end

                if(isRef&&obj.FlattenReferences)||~isRef
                    obj.searchComponent(comp);
                end
            end
        end

        function addElement(obj,elem)
            obj.Elems=[obj.Elems,elem];
            obj.ElemImpls=[obj.ElemImpls,elem.getImpl];
            if isa(elem,'systemcomposer.base.BaseComponent')
                obj.CompPaths=[obj.CompPaths,elem.getQualifiedName];
            end
        end
    end
end

