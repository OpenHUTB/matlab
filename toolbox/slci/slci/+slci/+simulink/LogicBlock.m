


classdef LogicBlock<slci.simulink.Block

    methods

        function obj=LogicBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            if(slcifeature('SlciLevel1Checks')==1)
                obj.addConstraint(...
                slci.compatibility.SupportedOutPortDataTypesConstraint({'boolean'}));
            else
                obj.addConstraint(...
                slci.compatibility.SupportedOutPortDataTypesConstraint({'boolean','uint8'}));
            end
            obj.addConstraint(...
            slci.compatibility.UniformInputPortDataTypesConstraint);

            obj.addConstraint(...
            slci.compatibility.MisraXorConstraint);

        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end

