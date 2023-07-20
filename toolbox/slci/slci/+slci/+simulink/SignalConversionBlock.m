


classdef SignalConversionBlock<slci.simulink.Block

    methods

        function obj=SignalConversionBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'ConversionOutput','Signal copy','Contiguous copy'));



            conversionOutput=get_param(aBlk,'ConversionOutput');
            if strcmpi(conversionOutput,'Signal copy')...
                ||strcmpi(conversionOutput,'Contiguous copy')



                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraintWithFix(...
                false,'OverrideOpt','on'));
            end
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
