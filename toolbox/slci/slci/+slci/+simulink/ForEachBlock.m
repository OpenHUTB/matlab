

classdef ForEachBlock<slci.simulink.Block
    properties(Access=private)
        fInputPartitionDimension=[];
        fInputPartitionWidth=[];
        fOutputConcatenationDimension=[];
        fSubsysMaskParameterPartitionDimension=[];
        fSubsysMaskParameterPartitionWidth=[];
    end

    methods

        function obj=ForEachBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.populateProperty();




            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'ShowIterationIndex','off'));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'NeedActiveIterationSignal','off'));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'RequestParallelExec','on'));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'StateReset','held'));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'StateType','Separate states for each iteration'));


            obj.addConstraint(...
            slci.compatibility.ForEachMaskParameterConstraint);


            obj.addConstraint(...
            slci.compatibility.ForEachDimensionConstraint);


            obj.addConstraint(...
            slci.compatibility.ForEachSpecifiedNumItersConstraint);
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end


        function out=getInputPartitionDimension(aObj)
            out=aObj.fInputPartitionDimension;
        end


        function out=getInputPartitionWidth(aObj)
            out=aObj.fInputPartitionWidth;
        end


        function out=getOutputConcatenationDimension(aObj)
            out=aObj.fOutputConcatenationDimension;
        end


        function out=getSubsysMaskParameterPartitionDimension(aObj)
            out=aObj.fSubsysMaskParameterPartitionDimension;
        end


        function out=getSubsysMaskParameterPartitionWidth(aObj)
            out=aObj.fSubsysMaskParameterPartitionWidth;
        end
    end

    methods(Access=private)

        function populateProperty(aObj)
            aObj.fInputPartitionDimension=...
            aObj.resolveValue('InputPartitionDimension');
            aObj.fInputPartitionWidth=aObj.resolveValue('InputPartitionWidth');
            aObj.fOutputConcatenationDimension=...
            aObj.resolveValue('OutputConcatenationDimension');
            aObj.fSubsysMaskParameterPartitionDimension=...
            aObj.resolveValue('SubsysMaskParameterPartitionDimension');
            aObj.fSubsysMaskParameterPartitionWidth=...
            aObj.resolveValue('SubsysMaskParameterPartitionWidth');
        end


        function value=resolveValue(aObj,param_name)
            value=[];
            param=aObj.getParam(param_name);
            if~isempty(param)
                value=slci.internal.resolveSymbol(param,'double',aObj.getSID());

                assert(~isempty(value));
                assert(strcmpi(class(value),'double'));
            end
        end
    end
end
