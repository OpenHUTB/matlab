




classdef UnitConversionBlock<slci.simulink.Block

    methods


        function obj=UnitConversionBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);



            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);


            obj.addConstraint(...
            slci.compatibility.SupportedOutPortDataTypesConstraint(...
            {'double','single'}));

            obj.addConstraint(...
            slci.compatibility.SupportedUnitConversionConstraint());

        end


        function out=checkCompatiblity(aObj)
            out=checkCompatiblity@slci.compatiblity.Block(aObj);
        end

    end

end
