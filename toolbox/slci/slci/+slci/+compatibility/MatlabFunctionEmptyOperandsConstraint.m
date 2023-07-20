



classdef MatlabFunctionEmptyOperandsConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Matlab operator cannot have empty operands';
        end


        function obj=MatlabFunctionEmptyOperandsConstraint
            obj.setEnum('MatlabFunctionEmptyOperands');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            children=owner.getChildren();
            if isempty(children)&&~aObj.isValidEmptyBracket(owner)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum()...
                );
            end
        end
    end

    methods(Access=private)



        function out=isValidEmptyBracket(~,ast)
            out=false;
            lb=ast.getParent();
            if isa(lb,'slci.ast.SFAstConcatenateLB')
                parent=lb.getParent();
                out=isa(parent,'slci.ast.SFAstMin')...
                ||isa(parent,'slci.ast.SFAstMax')...
                ||isa(parent,'slci.ast.SFAstReshape');
            end
        end
    end

end
