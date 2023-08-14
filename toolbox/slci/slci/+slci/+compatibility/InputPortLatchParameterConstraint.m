

classdef InputPortLatchParameterConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Inport blocks within triggered modelreference block are not permitted to latch inputs by delaying outside signal';
        end

        function obj=InputPortLatchParameterConstraint()
            obj.setEnum('InputPortLatchParameter');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            blk_type=aObj.ParentBlock().getParam('BlockType');
            assert(strcmpi(blk_type,'ModelReference'));
            parameterValue=...
            aObj.ParentBlock().getParam('InputPortLatchByDelayingOutsideSignal');
            assert(isstruct(parameterValue));
            field_names=fieldnames(parameterValue);
            for idx=1:numel(field_names)
                curr_param_value=parameterValue.(field_names{idx});
                if strcmpi(curr_param_value,'on')
                    out=slci.compatibility.Incompatibility(aObj,'InputPortLatchParameter');
                    return
                end
            end
        end
    end
end


