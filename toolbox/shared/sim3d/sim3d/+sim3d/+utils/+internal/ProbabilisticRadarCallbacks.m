classdef ProbabilisticRadarCallbacks

    properties(Constant,Access=public,Hidden)
        elevation_fields=struct(...
        "independent_field","HasElevation",...
        "dependent_fields",["ElevationResolution","ElevationBiasFraction"]...
        );

        range_rate_fields=struct(...
        "independent_field","HasRangeRate",...
        "dependent_fields",["RangeRateResolution","RangeRateBiasFraction","RangeRateLimits"]...
        );

        output_bus_fields=struct(...
        "independent_field","SpecifyOutputBusName",...
        "dependent_fields",["BusName"]...
        );
    end

    methods(Access=public,Static)
        function set_elevation_visibility(block)
            sim3d.utils.internal.ProbabilisticRadarCallbacks.set_dependent_field_visibility(...
            block,sim3d.utils.internal.ProbabilisticRadarCallbacks.elevation_fields);
        end

        function set_range_rate_visibility(block)
            sim3d.utils.internal.ProbabilisticRadarCallbacks.set_dependent_field_visibility(...
            block,sim3d.utils.internal.ProbabilisticRadarCallbacks.range_rate_fields);
        end

        function set_initial_seed_visibility(block)


            parameter_handle=...
            Simulink.Mask.get(block).getParameter("InitialSeed");

            parameter_handle.Visible="off";
            if strcmp(get_param(block,"InitialSeedSource"),"Specify seed")
                parameter_handle.Visible="on";
            end
        end

        function set_output_bus_name_visibility(block)
            sim3d.utils.internal.ProbabilisticRadarCallbacks.set_dependent_field_visibility(...
            block,sim3d.utils.internal.ProbabilisticRadarCallbacks.output_bus_fields);







            BusNameSource="Auto";
            if strcmp(get_param(block,sim3d.utils.internal.ProbabilisticRadarCallbacks.output_bus_fields.independent_field),"on")
                BusNameSource="Property";
            end

            sysobj=sprintf("%s/Simulation 3D Probabilistic Radar",block);
            set_param(sysobj,"BusNameSource",BusNameSource);
        end
    end

    methods(Access=private,Static)
        function set_dependent_field_visibility(block,fields)



            mask_handle=Simulink.Mask.get(block);

            independent_field_status=...
            get_param(block,fields.independent_field);

            for field=fields.dependent_fields
                parameter_handle=mask_handle.getParameter(field);
                parameter_handle.Visible=independent_field_status;
            end
        end
    end
end