



classdef SwitchBlock<slci.simulink.Block

    methods

        function obj=SwitchBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.SwitchConstraint());
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'AllowDiffInputSizes','off'));


            if(slcifeature('SlciLevel1Checks')==1)
                obj.addConstraint(...
                slci.compatibility.ControlPortDataTypeConstraint('Inport',2));
            end

            obj.addConstraint(...
            slci.compatibility.ConstantPortConstraint('Inport',2));

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
