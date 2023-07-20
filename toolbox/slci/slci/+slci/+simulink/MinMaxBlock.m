


classdef MinMaxBlock<slci.simulink.Block

    methods

        function obj=MinMaxBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.updateConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single','int8','uint8','int16',...
            'uint16','int32','uint32'}));
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'RndMeth','Zero','Floor'));
            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);



            pH=get_param(aBlk,'PortHandles');
            numInports=numel(pH.Inport);
            if(numInports==1)
                obj.addConstraint(...
                slci.compatibility.PositiveModelParameterConstraint(...
                false,'CodeReplacementLibrary',...
                'None','C89/C90 (ANSI)','ANSI_C'));
                obj.addConstraint(...
                slci.compatibility.PositiveModelParameterConstraint(...
                false,'TargetLangStandard','C89/C90 (ANSI)'));
            end
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
