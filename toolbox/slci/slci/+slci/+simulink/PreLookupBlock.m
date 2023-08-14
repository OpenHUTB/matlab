



classdef PreLookupBlock<slci.simulink.Block

    methods


        function obj=PreLookupBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);


            indexSearchConstraint=slci.compatibility.PositiveBlockParameterConstraint(...
            false,'IndexSearchMethod','Linear search','Binary search');
            obj.addConstraint(indexSearchConstraint);


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
            'OutputSelection','Index and fraction'));



            if strcmp(get_param(aBlk,'OutputSelection'),'Index and fraction')...
                &&strcmp(get_param(aBlk,'ExtrapMethod'),'Clip')
                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
                'UseLastBreakpoint','off'));
            end


            bpSpecConstraint=slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'BreakpointsSpecification','Explicit values');
            obj.addConstraint(bpSpecConstraint);


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
            'RndMeth','Floor'));



            obj.removeConstraint('SupportedPortDataTypes');


            obj.addConstraint(...
            slci.compatibility.PreLookupIndexDataTypeConstraint({'uint32'}));



            obj.addConstraint(...
            slci.compatibility.PreLookupDataTypesConstraint(...
            {'double','single'}));






            obj.addConstraint(...
            slci.compatibility.BlockConstantSampleTimeConstraint);
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
