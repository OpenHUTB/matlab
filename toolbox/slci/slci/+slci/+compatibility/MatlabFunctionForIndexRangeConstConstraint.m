





classdef MatlabFunctionForIndexRangeConstConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Index range of statement for must be literal const integer';
        end


        function obj=MatlabFunctionForIndexRangeConstConstraint
            obj.setEnum('MatlabFunctionForIndexRangeConst');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstFor'));
            index_range=owner.getIndexRangeAST();

            isSupported=aObj.isSupportedIndex(index_range{1});

            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum()...
                );
            end
        end

    end

    methods(Access=private)
        function out=isSupportedIndex(~,index_range)
            out=false;

            [success,value]=...
            slci.matlab.astProcessor.AstSlciInferenceUtil.evalValue(index_range);
            if success

                out=isequal(value,floor(value));
                return;
            end

        end
    end

end
