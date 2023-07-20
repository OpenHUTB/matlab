



classdef DataStoreWriteBlock<slci.simulink.Block

    properties

        fElementsAst={};


        fDsmHandle=[];


        fResolvedTypes;
    end

    methods


        function obj=DataStoreWriteBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.populateElementsAst();
            obj.addConstraint(...
            slci.compatibility.DatastoreContiguousSelectionConstraint());
            obj.addConstraint(...
            slci.compatibility.DatastoreBracketSelectionConstraint());
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
            obj.fResolvedTypes=containers.Map;
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end


        function elementsAst=getElementsAst(aObj)
            elementsAst=aObj.fElementsAst;
        end


        function resolvedType=getType(aObj,typeName)
            if~isKey(aObj.fResolvedTypes,typeName)
                aObj.fResolvedTypes(typeName)=...
                slci.simulink.DataStoreReadBlock.getResolvedType(...
                typeName,...
                aObj.getDataStoreHandle());
            end
            resolvedType=aObj.fResolvedTypes(typeName);
        end


        function dsmHandle=getDataStoreHandle(aObj)
            if isempty(aObj.fDsmHandle)
                aObj.fDsmHandle=slci.internal.getDataStoreHandle(...
                aObj.getParam('Object'));
            end
            dsmHandle=aObj.fDsmHandle;
        end

    end

    methods(Access=private)





        function populateElementsAst(aObj)
            dataStoreElements=get_param(aObj.getSID(),'DataStoreElements');
            if~isempty(dataStoreElements)
                elements=regexp(dataStoreElements,'#','split');
                for k=1:numel(elements)
                    aObj.fElementsAst{end+1}=aObj.getAst(elements{k});
                end
            end
        end


        function ast=getAst(aObj,mexpr)
            ast=slci.matlab.astTranslator.translateMATLABExpr(mexpr,aObj);
        end

    end

end



