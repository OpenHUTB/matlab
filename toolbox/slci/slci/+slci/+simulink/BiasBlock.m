


classdef BiasBlock<slci.simulink.Block

    methods

        function obj=BiasBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);


            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);

            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('Bias'));
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
