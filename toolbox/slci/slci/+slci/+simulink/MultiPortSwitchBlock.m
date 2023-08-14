

classdef MultiPortSwitchBlock<slci.simulink.Block

    methods

        function obj=MultiPortSwitchBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            pH=get_param(aBlk,'PortHandles');
            numInports=numel(pH.Inport);
            if(numInports==2)









                obj.addConstraint(...
                slci.compatibility.IndexPortDataTypeConstraint('Inport',1));

                obj.addConstraint(...
                slci.compatibility.MultiPortSwitchNonContiguousInputConstraint());



                obj.addConstraint(...
                slci.compatibility.RangeSelectionConstraint(2));
            else
                obj.addConstraint(...
                slci.compatibility.MultiPortSwitchConstraint());
                obj.addConstraint(...
                slci.compatibility.MultiPortSwitchConstraint2());
                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraintWithFix(...
                false,'RndMeth','Zero','Floor'));
                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraint(...
                false,'AllowDiffInputSizes','off'));
                obj.addConstraint(...
                slci.compatibility.NumInportsConstraint(3,Inf));


                obj.addConstraint(...
                slci.compatibility.ConstantPortConstraint('Inport',1));
            end
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


