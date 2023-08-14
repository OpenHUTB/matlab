


classdef FILUnitTest<handle
    properties
BoardName
        FilBoardObj;
        FilBuildInfo;


        UseRetryQuestDlg=true;
        isEthernet=true;
        needToDeleteBoard=false;
    end
    methods
        function obj=FILUnitTest(boardObj,connection,ipAddress)
            narginchk(2,3);
            if nargin==2
                ipAddress='192.168.0.2';
            end
            obj.BoardName=boardObj.BoardName;
            mgr=eda.internal.boardmanager.BoardManager.getInstance;




            if~mgr.isBoard(obj.BoardName)
                mgr.addBoardObj(boardObj.BoardName,boardObj);
                obj.needToDeleteBoard=true;
            end

            obj.FilBoardObj=eda.internal.boardmanager.convertToFilObject(boardObj);
            obj.FilBuildInfo=eda.internal.workflow.FILBuildInfo;
            obj.FilBuildInfo.IPAddress=ipAddress;
            obj.FilBuildInfo.Board=obj.FilBoardObj;
            obj.FilBuildInfo.setConnection(connection);
            obj.isEthernet=strcmpi(connection.RTIOStreamLibName,'mwrtiostreamtcpip');
        end

        function delete(obj)
            if obj.needToDeleteBoard
                mgr=eda.internal.boardmanager.BoardManager.getInstance;
                mgr.removeBoardObj(obj.BoardName);
            end
        end

        function generateProgrammingFile(obj,workdir)

            warningID='EDALink:LegacyCodeFILManager:warnProjectOverwrite:OverwriteProjectFiles';
            warningState=warning('off',warningID);
            onCleanupObj=onCleanup(@()warning(warningState.state,warningID));


            if isempty(workdir)
                workdir=pwd;
            end


            if exist(workdir,'dir')==7


                success=l_checkWritableFolder(workdir);
            else
                [success,~,~]=mkdir(workdir);
            end
            if~success
                error(message('EDALink:boardmanager:FolderNonWritable',fullfile(workdir)));
            end



            src=fullfile(matlabroot,'toolbox','shared','eda','board','testfiles','fil_test.vhd');
            dst=fullfile(workdir,'fil_test.vhd');
            copyfile(src,dst,'f');


            obj.FilBuildInfo.addSourceFile(dst);
            obj.FilBuildInfo.DUTName='fil_test';
            obj.FilBuildInfo.FPGASystemClockFrequency='25MHz';
            obj.FilBuildInfo.addDUTPort('datain','In',8,'Data');
            obj.FilBuildInfo.addDUTPort('dataout','Out',8,'Data');
            obj.FilBuildInfo.addDUTPort('clk','In',1,'Clock');
            obj.FilBuildInfo.addDUTPort('clk_en','In',1,'Clock enable');
            obj.FilBuildInfo.addDUTPort('reset','In',1,'Reset');
            obj.FilBuildInfo.setTopLevelSourceFile(1);
            obj.FilBuildInfo.setOutputFolder(workdir);
            f=eda.internal.workflow.LegacyCodeFILManager(obj.FilBuildInfo);
            f.build('BuildOutput','FPGAFilesOnly','FirstFPGAProcess','BitGeneration','ContinueOnWarning','on');
        end
        function programFPGA(obj)
            [a,b,c]=fileparts(obj.FilBuildInfo.FPGAProgrammingFile);
            programmingFile=fullfile(a,[b,c]);
            arg={obj.FilBuildInfo.FPGATool,...
            programmingFile,...
            obj.FilBuildInfo.BoardObj.Component.ScanChain};


            retry=true;
            while retry
                try
                    filProgramFPGA(arg{:});
                    retry=false;
                catch ME
                    if obj.UseRetryQuestDlg
                        answer=questdlg(message('EDALink:boardmanager:RetryProgrammingFPGA',ME.message).getString,...
                        'Retry','Retry','Abort','Retry');
                        retry=strcmpi(answer,'Retry');
                    else
                        retry=false;
                    end
                    if~retry
                        rethrow(ME);
                    end
                end
            end
        end
        function checkConnection(obj)
            if~obj.isEthernet
                pause(5);
                return;
            end


            pause(5);
            if ispc
                cmd=['ping ',obj.FilBuildInfo.IPAddress];
            else
                cmd=['ping ',obj.FilBuildInfo.IPAddress,' -c 4'];
            end

            retry=true;
            while retry
                try
                    [s,r]=system(cmd,'-echo');
                    if s
                        error(message('EDALink:boardmanager:PingError',r));
                    end
                    retry=false;
                catch ME
                    if obj.UseRetryQuestDlg
                        answer=questdlg(message('EDALink:boardmanager:RetryPingFPGABoard').getString,...
                        'Retry','Retry','Abort','Retry');
                        retry=strcmpi(answer,'Retry');
                    else
                        retry=false;
                    end
                    if~retry
                        rethrow(ME);
                    end
                end
            end
        end
        function runSimulation(obj)
            sysobj=eda.internal.boardmanager.FILTestSysObj(obj.FilBuildInfo);
            out=step(sysobj,uint8(1:10)');

            if length(out)~=10
                success=false;
            else
                success=all(out==uint8(0:9)');
            end
            if~success
                error(message('EDALink:boardmanager:FILCosimWrongResult'));
            end
        end

        function runAll(obj)
            obj.generateProgrammingFile;
            obj.programFPGA;
            obj.checkConnection;
            obj.runSimulation;
        end
    end

    methods


    end
end



function res=l_checkWritableFolder(workdir)
    res=false;

    testFolderName=['HDLVHWSetupTest_',num2str(floor(rand*1e10))];

    if exist(workdir,'dir')==7
        [res,~,~]=mkdir(workdir,testFolderName);
        if res

            rmdir(fullfile(workdir,testFolderName));
        end
    end
end
