


classdef TurnkeyUnitTest<handle
    properties

        TurnkeyBoardObj;

        LED_ID;
        Model='';
        hD;
        LED;


        UseRetryQuestDlg=true;
    end
    methods
        function obj=TurnkeyUnitTest(boardObj,led)
            obj.TurnkeyBoardObj=boardObj;
            obj.LED=led;
        end
        function delete(obj)
            if~isempty(obj.Model)
                close_system(obj.Model,0);
                close_system(['gm_',obj.Model],0);
            end
        end

        function generateProgrammingFile(obj,workdir)

            if nargin<2||isempty(workdir)
                workdir=pwd;
            end


            model=fullfile(matlabroot,'toolbox','shared','eda','board','testfiles','turnkey_test_model.slx');
            load_system(model);
            obj.Model='turnkey_test_model';

            interface=obj.TurnkeyBoardObj.getInterface(obj.LED);
            if interface.PortWidth>1
                obj.LED_ID=[obj.LED,' ',sprintf('[%d:%d]',0,interface.PortWidth-1)];
            else
                obj.LED_ID=obj.LED;
            end



            freq=obj.TurnkeyBoardObj.hClockModule.ClockOutputMHz*1e6;
            lowerIndx=round(log2(freq))-3;
            if lowerIndx>31
                bitRange=[31,31];
            else
                upperIndx=lowerIndx+interface.PortWidth-1;
                if upperIndx>=31
                    upperIndx=31;
                end
                bitRange=[lowerIndx,upperIndx];
            end;

            bitRange=sprintf('[%d %d]',bitRange(1),bitRange(2));

            dut='turnkey_test_model/DUT';
            set_param([dut,'/Extract Bits'],'bitIdxRange',bitRange)


            obj.hD=downstream.integration('Model',dut,'cmdDisplay',false);
            obj.hD.set('Workflow','FPGA Turnkey');
            boardName=obj.TurnkeyBoardObj.BoardName;

            if~obj.hD.hAvailableBoardList.PluginObjList.isKey(boardName)&&~obj.hD.hAvailableBoardList.CustomObjList.isKey(boardName)
                obj.hD.hAvailableBoardList.CustomObjList(boardName)=obj.TurnkeyBoardObj;
            end
            obj.hD.set('Board',obj.TurnkeyBoardObj.BoardName);
            obj.hD.hTurnkey.hTable.populateInterfaceTable;
            obj.hD.hTurnkey.hTable.setInterfaceStrCmd('Out1',obj.LED_ID);


            [success,message,~]=mkdir(workdir);
            if~success
                error(message('EDALink:boardmanager:SysError',message));
            end
            obj.hD.setProjectPath(workdir);

            obj.hD.hTurnkey.hCHandle.makehdlturnkey;
            obj.hD.run('CreateProject');
            obj.hD.run('Synthesis');
            obj.hD.skipWorkflow('PostMapTiming');
            obj.hD.run('Map');
            obj.hD.run({'PAR','PostPARTiming'});
            obj.hD.run('ProgrammingFile');
            obj.hD.hTurnkey.runPostProgramFilePass;

        end
        function programFPGA(obj)

            retry=true;
            while retry
                try
                    [status,systemResult]=obj.hD.hTurnkey.runDownloadCmd;
                    if status==0
                        error(message('EDALink:boardmanagergui:SystemError',systemResult));
                    end
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


        function runAll(obj)
            obj.generateProgrammingFile;
            obj.programFPGA;
        end
    end

end


