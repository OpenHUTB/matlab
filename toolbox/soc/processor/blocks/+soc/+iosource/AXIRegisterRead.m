classdef AXIRegisterRead<soc.linux.AXIRegisterRead&matlab.mixin.CustomDisplay



    methods(Access=protected)
        function displayScalarObject(obj)
            header=getHeader(obj);
            disp(header);

            fprintf('             DeviceName: ''%s''\n',obj.DeviceName);
            fprintf('         RegisterOffset: %d\n',obj.RegisterOffset);
            fprintf('               DataType: ''%s''\n',obj.DataType);
            fprintf('             DataLength: %d\n',obj.DataLength);
            fprintf('             SampleTime: %f\n',obj.SampleTime);
            fprintf('\n');


            fprintf('\n%s\n',getFooter(obj));
        end
    end
end


