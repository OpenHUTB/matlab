


classdef DeviceConfigiMPACT<handle


    properties

        DevicePositionInChain=0;

        DigilentPlugin=false;

        BatchFileName='';
        BitstreamFileName='';


        hTurnkey=[];

    end

    methods

        function obj=DeviceConfigiMPACT(devicePositionInChain,useDigilentPlugin)

            if nargin<2
                useDigilentPlugin=false;
            end

            obj.DevicePositionInChain=devicePositionInChain;
            obj.DigilentPlugin=useDigilentPlugin;
        end

        function[status,result]=configureFPGA(obj,hTurnkey,scriptOnly)


            if nargin<3

                scriptOnly=false;
            end

            obj.hTurnkey=hTurnkey;
            status=true;
            result='';


            obj.generateiMPACTBatchFile;
            if scriptOnly
                return;
            end


            [status,result]=hdlturnkey.DeviceConfigiMPACT.runiMPACTBatchFile(...
            obj.hTurnkey,obj.BatchFileName);
        end

    end

    methods(Access=protected,Hidden=true)

        function generateiMPACTBatchFile(obj)



            [fid,obj.BatchFileName]=...
            hdlturnkey.DeviceConfigiMPACT.createiMPACTBatchFile(obj.hTurnkey);


            obj.printiMPACTBatchCmd(fid);


            fclose(fid);

        end

        function printiMPACTBatchCmd(obj,fid)



            fprintf(fid,'setMode -bscan\n');

            if obj.DigilentPlugin

                fprintf(fid,'setCable -target "digilent_plugin"\n');
            else

                fprintf(fid,'setCable -p auto\n');
            end


            fprintf(fid,'identify\n');


            obj.BitstreamFileName=sprintf('%s.bit',obj.hTurnkey.hElab.TopNetName);
            fprintf(fid,'assignFile -p %d -file "%s"\n',...
            obj.DevicePositionInChain,obj.BitstreamFileName);


            fprintf(fid,'program -p %d\n',obj.DevicePositionInChain);
            fprintf(fid,'quit\n');
        end

    end

    methods(Static)

        function[fid,batchFileName]=createiMPACTBatchFile(hTurnkey)



            batchFileName=sprintf('%s.cmd',hTurnkey.hElab.TopNetName);
            batchFilePath=fullfile(hTurnkey.hD.getProjectPath,batchFileName);

            fid=fopen(batchFilePath,'w');
            if fid==-1
                error(message('hdlcommon:workflow:UnableCreateBatchFile',batchFilePath));
            end
        end

        function[status,result]=runiMPACTBatchFile(hTurnkey,batchFileName)



            CmdStr=sprintf('%s -batch %s',fullfile(hTurnkey.hD.hToolDriver.getToolPath,'impact'),batchFileName);
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
