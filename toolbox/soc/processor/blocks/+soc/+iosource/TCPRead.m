classdef TCPRead<soc.linux.TCPRead&matlab.mixin.CustomDisplay



    methods(Access=protected)
        function displayScalarObject(obj)
            header=getHeader(obj);
            disp(header);

            fprintf('            NetworkRole: ''%s''\n',obj.NetworkRole);
            fprintf('          RemoteAddress: ''%s''\n',obj.RemoteAddress);
            fprintf('             RemotePort: %d\n',obj.RemotePort);
            fprintf('              LocalPort: %d\n',obj.LocalPort);
            fprintf('               DataType: ''%s''\n',obj.DataType);
            fprintf('             DataLength: %d\n',obj.DataLength);
            fprintf('             SampleTime: %f\n',obj.SampleTime);
            fprintf('\n');


            fprintf('\n%s\n',getFooter(obj));
        end
    end
end

