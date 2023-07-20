


classdef DeviceConfigQuartus<handle
    properties
DevicePositionInChain
    end

    methods
        function obj=DeviceConfigQuartus(devicePositionInChain)
            if nargin<1
                obj.DevicePositionInChain=1;
            else
                obj.DevicePositionInChain=devicePositionInChain;
            end
        end

        function[status,result]=configureFPGA(obj,hTurnkey,scriptOnly)


            if nargin<3

                scriptOnly=false;
            end

            status=true;
            result='';

            if scriptOnly
                return;
            end

            sofFileName=sprintf('%s.sof',hTurnkey.hD.hToolDriver.hTool.ProjectName);
            CmdStr=sprintf('%s -m JTAG -o "p;%s@%d"',...
            fullfile(hTurnkey.hD.hToolDriver.getToolPath,'quartus_pgm'),...
            sofFileName,...
            obj.DevicePositionInChain);
            currentDir=pwd;
            try
                cd(hTurnkey.hD.getProjectPath);
                [status,result]=system(CmdStr);
            catch ME
                cd(currentDir);
                rethrow(ME);
            end
            cd(currentDir);
            status=~status;

        end

    end

end
