

classdef DiscreteIntegratorBlock<slci.simulink.Block

    methods

        function obj=DiscreteIntegratorBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.addConstraint(...
            slci.compatibility.BlockStateStorageClassConstraint('StateName'));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'IntegratorMethod',...
            'Integration: Forward Euler',...
            'Integration: Backward Euler',...
            'Integration: Trapezoidal'));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'ShowStatePort','off'));


            obj.addConstraint(slci.compatibility.PositiveBlockParameterConstraint(...
            false,'ExternalReset','none'));




            obj.addConstraint(...
            slci.compatibility.SupportedOutPortDataTypesConstraint({'double','single'}));



            obj.addConstraint(slci.compatibility.DiscreteIntegratorInportDataTypesConstraint);


            obj.addConstraint(...
            slci.compatibility.BlockPortsScalarConstraint);

            obj.addConstraint(...
            slci.compatibility.DiscreteIntegratorEnabledSubsystemConstraint);


            if(~strcmpi(obj.ParentBlock().getParam('ExternalReset'),'none'))
                obj.addConstraint(...
                slci.compatibility.ConstantPortConstraint('Inport',2));
            end



            if(strcmpi(get_param(aBlk,'LimitOutput'),'on'))
                obj.addConstraint(...
                slci.compatibility.RuntimeParamConstraint('UpperSaturationLimit'));
                obj.addConstraint(...
                slci.compatibility.RuntimeParamConstraint('LowerSaturationLimit'));
            end

            obj.addConstraint(...
            slci.compatibility.DiscreteIntegratorUniformPortDataTypesConstraint);


            obj.removeConstraint('SupportedPortDataTypes');
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


