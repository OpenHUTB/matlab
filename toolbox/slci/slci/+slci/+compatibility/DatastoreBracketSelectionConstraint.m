




classdef DatastoreBracketSelectionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Datastore selection does not support indexing with bracket';
        end


        function obj=DatastoreBracketSelectionConstraint()
            obj.setEnum('DatastoreBracketSelection');
            obj.setCompileNeeded(true);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            if~aObj.isCompatible()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'DatastoreBracketSelection',...
                aObj.ParentBlock().getName());
            end
        end
    end

    methods(Access=private)


        function isCompat=isCompatible(aObj)
            isCompat=true;
            parentBlock=aObj.getOwner();
            assert(isa(parentBlock,'slci.simulink.DataStoreReadBlock')...
            ||isa(parentBlock,'slci.simulink.DataStoreWriteBlock'));
            selectionAst=parentBlock.getElementsAst();
            for k=1:numel(selectionAst)
                ast=selectionAst{k};


                if isa(ast,'slci.ast.SFAstArray')
                    if~aObj.isSupportedSubscript(ast)
                        isCompat=false;
                        return;
                    end
                end
            end
        end



        function res=isSupportedSubscript(aObj,ast)
            res=true;
            assert(isa(ast,'slci.ast.SFAstArray'));
            children=ast.getChildren();
            assert(numel(children)>=2);
            indices=children(2:end);
            for k=1:numel(indices)
                index=indices{k};
                if aObj.hasBrackets(index)
                    res=false;
                    return;
                end
            end
        end




        function res=hasBrackets(aObj,ast)
            res=false;
            if isa(ast,'slci.ast.SFAstConcatenateLB')
                res=true;
            else
                children=ast.getChildren();
                for k=1:numel(children)
                    child=children{k};
                    if aObj.hasBrackets(child)
                        res=true;
                        return;
                    end
                end
            end
        end

    end


end
