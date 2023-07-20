classdef Parameter<Simulink.Parameter



    properties(PropertyType='char',Hidden=true,...
        AllowedValues={'NotAccessible';...
        'ReadOnly';...
        'ReadWrite'})
        SwCalibrationAccess='ReadWrite';
    end
    properties(PropertyType='char',Hidden=true)
        DisplayFormat='';
    end

    methods

        function setupCoderInfo(h)

            useLocalCustomStorageClasses(h,'AUTOSAR');
        end

        function h=Parameter(varargin)



            h@Simulink.Parameter(varargin{:});
        end

    end
    methods(Hidden)

        function dlgStruct=getDialogSchema(obj,name)
            helpPages.parameter_help='autosar_parameter';
            helpPages.signal_help='autosar_signal';
            helpPages.mapfile='/autosar/helptargets.map';
            dlgStruct=dataddg(obj,name,'data',false,helpPages);
        end
    end
end
