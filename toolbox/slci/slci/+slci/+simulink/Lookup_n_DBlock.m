


classdef Lookup_n_DBlock<slci.simulink.Block

    methods

        function obj=Lookup_n_DBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
            'UseOneInputPortForAllInputData','off'));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
            'InterpMethod','Linear point-slope'));

            if~strcmp(get_param(aBlk,'InterpMethod'),...
                'Flat')
                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraint(false,...
                'ExtrapMethod','Clip','Linear'));
            end
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
            'IndexSearchMethod','Linear search','Binary search'));
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
            'SupportTunableTableSize','off'));


            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('Table'));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
            'TableSource','Dialog'));


            bpSpecConstraint=slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'BreakpointsSpecification','Explicit values');
            obj.addConstraint(bpSpecConstraint);




            num_of_tab_dim=slResolve(get_param(aBlk,'NumberOfTableDimensions'),aBlk);
            if(~isempty(num_of_tab_dim))



                num_of_supported_dim=30;
                num_of_dim_to_check=num_of_supported_dim;
                if(num_of_dim_to_check>num_of_tab_dim)
                    num_of_dim_to_check=num_of_tab_dim;
                end

                for i=1:num_of_dim_to_check

                    bp_str=['BreakpointsForDimension',num2str(i)];
                    runtimeConstraint=slci.compatibility.RuntimeParamConstraint(bp_str);
                    runtimeConstraint.addPreRequisiteConstraint(bpSpecConstraint);
                    obj.addConstraint(runtimeConstraint);

                end
                for i=1:3

                    bp_src_str=['BreakpointsForDimension',num2str(i),'Source'];
                    obj.addConstraint(...
                    slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
                    bp_src_str,'Dialog'));
                end
            end


            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);


            obj.addConstraint(...
            slci.compatibility.LookupndTableDataDataTypeConstraint());
            obj.addConstraint(...
            slci.compatibility.LookupndIntermediateResultsDataTypeConstraint());


            obj.addConstraint(...
            slci.compatibility.LookupndFractionDataTypeConstraint());


            obj.addConstraint(...
            slci.compatibility.TunableLookupTableObjectConstraint);

            if slcifeature('VLUTObject')

                obj.addConstraint(...
                slci.compatibility.LookupObjTableAndBreakpointDataTypeConstraint());
            end








            obj.addConstraint(...
            slci.compatibility.BlockConstantSampleTimeConstraint);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


