





classdef MatlabFunctionForIndexMonoIncrRangeConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Index range of statement for must be mono incremental colon';
        end


        function obj=MatlabFunctionForIndexMonoIncrRangeConstraint
            obj.setEnum('MatlabFunctionForIndexMonoIncrRange');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstFor'));
            index_range=owner.getIndexRangeAST();
            index_range=index_range{1};

            supported=true;
            if isa(index_range,'slci.ast.SFAstColon')
                colonChildren=index_range.getChildren();
                if numel(colonChildren)==3
                    [success,value]=...
                    slci.matlab.astProcessor.AstSlciInferenceUtil.evalValue(colonChildren{2});
                    if success

                        supported=isscalar(value)&&(value>0);
                    end
                end
            end

            if~supported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum()...
                );
            end
        end

    end

end