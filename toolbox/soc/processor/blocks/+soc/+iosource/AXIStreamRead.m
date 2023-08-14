classdef AXIStreamRead<soc.libiio.axistream.read&matlab.mixin.CustomDisplay




    methods(Access=protected)
        function displayScalarObject(obj)
            header=getHeader(obj);
            disp(header);

            fprintf('                devName: ''%s''\n',obj.devName);
            fprintf('            dataTypeStr: ''%s''\n',obj.dataTypeStr);
            fprintf('        SamplesPerFrame: %d\n',obj.SamplesPerFrame);
            fprintf('             SampleTime: %f\n',obj.SampleTime);
            fprintf('\n');


            fprintf('\n%s\n',getFooter(obj));
        end
    end
end
