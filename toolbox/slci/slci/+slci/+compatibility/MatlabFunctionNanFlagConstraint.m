





classdef MatlabFunctionNanFlagConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out=['NanFlag in Matlab operators '...
            ,' must be ''includenan'''];
        end


        function obj=MatlabFunctionNanFlagConstraint
            obj.setEnum('MatlabFunctionNanFlag');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();

            assert(isa(owner,'slci.ast.SFAstProd')...
            ||isa(owner,'slci.ast.SFAstMean')...
            ||isa(owner,'slci.ast.SFAstSum'));
            nanflag=owner.getNanFlag();
            if~aObj.isSupportedNanFlag(nanflag)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end

        end

    end

    methods(Access=private)

        function out=isSupportedNanFlag(~,nanflag)
            out=strcmpi(nanflag,'includenan');
        end
    end

end