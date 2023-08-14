classdef UDPRead<soc.linux.UDPRead&matlab.mixin.CustomDisplay



    methods(Access=protected)
        function displayScalarObject(obj)
            header=getHeader(obj);
            disp(header);

            fprintf('              LocalPort: %d\n',obj.LocalPort);
            fprintf('             DataLength: %d\n',obj.DataLength);
            fprintf('               DataType: ''%s''\n',obj.DataType);
            fprintf('      ReceiveBufferSize: %d\n',obj.ReceiveBufferSize);
            fprintf('             SampleTime: %f\n',obj.SampleTime);
            fprintf('\n');


            fprintf('\n%s\n',getFooter(obj));
        end
    end
end

