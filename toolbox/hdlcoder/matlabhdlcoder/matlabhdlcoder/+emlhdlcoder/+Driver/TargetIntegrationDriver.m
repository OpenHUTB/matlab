classdef TargetIntegrationDriver<handle



    properties(Access=private)
        hDI;
        hEMLHDLConfig;
    end

    methods


        function this=TargetIntegrationDriver(hdlConfig,hdlDriver)
            if isempty(hdlDriver.DownstreamIntegrationDriver)
                error(message('hdlcoder:engine:NoDIDriver'));
            else
                this.hDI=hdlDriver.DownstreamIntegrationDriver;
            end
            this.hEMLHDLConfig=hdlConfig;
            this.hDI.logDisplay=this.hEMLHDLConfig.Verbosity;

        end




        function ipcoreCreateProject(this,dumpResults)
            logTxt='';
            try
                [status,logTxt]=this.hDI.runCreateEmbeddedProject;
            catch
                status=0;
            end


            if(dumpResults)
                disp(logTxt);
            end

            if status
                hdldisp(message('hdlcoder:hdldisp:IPCoreCreateEmbeddedProjectSuccess'));
            else
                error(message('hdlcoder:hdldisp:IPCoreCreateEmbeddedProjectFailure'));
            end

            disp(' ');
        end



        function ipcoreBuildEmbeddedSystem(this,dumpResults)

            isExternalBuild=strcmpi(this.hEMLHDLConfig.BitstreamBuildMode,'External');
            this.hDI.hIP.setEmbeddedExternalBuild(isExternalBuild);
            [status,logTxt,validateCell]=this.hDI.runEmbeddedSystemBuild;

            if(dumpResults)
                disp(logTxt);
            end

            if status
                hdldisp(message('hdlcoder:hdldisp:IPCoreBuildEmbeddedSystemSuccess'));
            else
                error(message('hdlcoder:hdldisp:IPCoreBuildEmbeddedSystemFailure'));
            end

            disp(' ');
        end



        function ipcoreProgramTargetDevice(this,dumpResults)

            [status,logTxt]=this.hDI.runEmbeddedDownloadBitstream;

            if(dumpResults)
                disp(logTxt);
            end

            if status
                hdldisp(message('hdlcoder:hdldisp:ProgramTargetDeviceSuccess'));
            else
                error(message('hdlcoder:hdldisp:ProgramTargetDeviceFailure'));
            end

            disp(' ');
        end



        function fpgaturnkeyBuildBitstream(this,dumpResults)


            [status1,tmplogTxt1]=this.hDI.run('ProgrammingFile');

            [status2,tmplogTxt2]=this.hDI.hTurnkey.runPostProgramFilePass;

            logTxt=sprintf('%s\n%s',tmplogTxt1,tmplogTxt2);

            status=status1&&status2;

            if(dumpResults)
                disp(logTxt);
            end

            if status
                hdldisp(message('hdlcoder:hdldisp:FPGATurnkeyBuildBitstreamSuccess'));
            else
                error(message('hdlcoder:hdldisp:FPGATurnkeyBuildBitstreamFailure'));
            end

            disp(' ');
        end



        function fpgaturnkeyProgramTargetDevice(this,dumpResults)

            [status,logTxt]=this.hDI.hTurnkey.runDownloadCmd;

            if(dumpResults)
                disp(logTxt);
            end

            if status
                hdldisp(message('hdlcoder:hdldisp:ProgramTargetDeviceSuccess'));
            else
                error(message('hdlcoder:hdldisp:ProgramTargetDeviceFailure'));
            end

            disp(' ');
        end


        function doIt(this,dumpResults)
            if strcmpi(this.hEMLHDLConfig.Workflow,'IP Core Generation')

                if this.hEMLHDLConfig.CreateEmbeddedSystemProject
                    this.ipcoreCreateProject(dumpResults);
                end


                if this.hEMLHDLConfig.BuildBitstream
                    this.ipcoreBuildEmbeddedSystem(dumpResults);
                end


                if this.hEMLHDLConfig.ProgramTargetDevice
                    this.ipcoreProgramTargetDevice(dumpResults);
                end
            elseif strcmpi(this.hEMLHDLConfig.Workflow,'FPGA Turnkey')

                if this.hEMLHDLConfig.BuildBitstream
                    this.fpgaturnkeyBuildBitstream(dumpResults);
                end


                if this.hEMLHDLConfig.ProgramTargetDevice
                    this.fpgaturnkeyProgramTargetDevice(dumpResults);
                end
            end
        end
    end

end



