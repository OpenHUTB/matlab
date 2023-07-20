



classdef ModelGenerationxPC<hdlturnkey.backend.ModelGeneration


    properties


        xPCPCIReadBlkName='';
        xPCPCIWriteBlkName='';
        xPCSetupBlkName='';
        xPCPCIRWBlkName='';


        matFilePath='';
        xpcParams=[];

    end

    methods

        function obj=ModelGenerationxPC(hTurnkey)


            obj=obj@hdlturnkey.backend.ModelGeneration(hTurnkey);
            obj.messageString='Simulink Real-Time Interface';
            obj.MdlNamePostfix='slrt';

        end


        function[status,result]=generateModelWithoutLibraryBlock(obj)
            aOriginalFeatureValue=slfeature('ReportMaskEditTimeErrorsFromSetParam',0);

            try
                status=true;
                result='';


                obj.validateLicense;


                obj.parseMATFile;


                obj.generateMATFile;


                validateModelGen(obj);


                [status,result]=obj.initModelGen(status,result);


                obj.configurexPCDUT;


                obj.configurexPCMdl;


                [status,result]=obj.finishModelGen(status,result);
            catch exp
                slfeature('ReportMaskEditTimeErrorsFromSetParam',aOriginalFeatureValue);
                rethrow(exp);
            end

            slfeature('ReportMaskEditTimeErrorsFromSetParam',aOriginalFeatureValue);
        end





        function[newPath,newName]=addxPCLibraryBlk(obj,blkLibPath,blkName,blkPosition,showBlkName)


            if nargin<5
                showBlkName=false;
            end

            blkMdlPath=obj.getTIFDutBlkPath(blkName);
            [newPath,newName]=obj.addBlockUnique(blkLibPath,blkMdlPath);


            set_param(newPath,'Position',blkPosition);
            if~showBlkName
                set_param(newPath,'ShowName','off');
            end
        end

        function swModelDutPath=getSWModelDUTPathForMask(obj)

            if isa(get_param(obj.tifDutPath,'Object'),'Simulink.BlockDiagram')


                swModelDutPath=obj.getGmDutName;
            else
                swModelDutPath=obj.tifDutPath;
            end
        end

    end

    methods(Access=protected)

        function validateLicense(obj)

            hDI=obj.hTurnkey.hD;
            if hDI.isxPCTargetBoard&&~hdlturnkey.isxpcinstalled
                error(message('hdlcommon:workflow:xPCLicenseUnavailable'));
            end
        end

        function parseMATFile(obj)
            hDI=obj.hTurnkey.hD;


            [~,fileName,~]=fileparts(hDI.getMCSFileName);


            obj.matFilePath=fullfile(hDI.hCodeGen.hCHandle.hdlMakeCodegendir,[fileName,'.mat']);


            if exist(obj.matFilePath,'file')
                load(obj.matFilePath,'turnkeyInfo');
                if~isempty(turnkeyInfo)&&isfield(turnkeyInfo,'xpcparameters')
                    obj.xpcParams=turnkeyInfo.xpcparameters;
                end
            end

        end

        function generateMATFile(obj)


            turnkeyInfo.dutName=obj.hTurnkey.hD.hCodeGen.getDutName;


            if obj.hTurnkey.hD.isIPCoreGen



                TopMCSFileName=hdlslrt.backend.getMCSFileName(...
                obj.hTurnkey.hD.hCodeGen.getDutName,obj.hTurnkey.modelgeninfo.TimestampValue);
                turnkeyInfo.mcsFile=TopMCSFileName;
            else

                turnkeyInfo.mcsFile=obj.hTurnkey.hD.getMCSFilePath;
            end


            turnkeyInfo.portInfo={};
            inPortList=obj.hTurnkey.hTable.hIOPortList.InputPortNameList;
            for ii=1:length(inPortList)
                portName=inPortList{ii};
                portInfo=obj.getPortInfo(portName);
                turnkeyInfo.portInfo{end+1}=portInfo;
            end

            outPortList=obj.hTurnkey.hTable.hIOPortList.OutputPortNameList;
            for ii=1:length(outPortList)
                portName=outPortList{ii};
                portInfo=obj.getPortInfo(portName);
                turnkeyInfo.portInfo{end+1}=portInfo;
            end


            if~isempty(obj.xpcParams)
                turnkeyInfo.xpcparameters=obj.xpcParams;
            end


            if obj.hTurnkey.hD.isIPCoreGen
                timestampInfo.timestampOffset=obj.hTurnkey.modelgeninfo.TimestampOffset;
                timestampInfo.timestampValue=obj.hTurnkey.modelgeninfo.TimestampValue;
            else
                timestampInfo.timestampOffset='';
                timestampInfo.timestampValue='';
            end
            turnkeyInfo.timestampInfo=timestampInfo;


            cmdStr=sprintf('save(''%s'', ''turnkeyInfo'');',obj.matFilePath);
            eval(cmdStr);
        end

        function portInfo=getPortInfo(obj,portName)

            hIOPort=obj.hTurnkey.hTable.hIOPortList.getIOPort(portName);
            portInfo.port_name=portName;
            portInfo.port_type=downstream.tool.getPortDirTypeStr(hIOPort.PortType);
            portInfo.data_type=hIOPort.SLDataType;
            portInfo.interface=obj.hTurnkey.hTable.hTableMap.getInterfaceStr(portName);
            portInfo.port_offset=obj.hTurnkey.hTable.hTableMap.getBitRangeStr(portName);
        end



        function configurexPCDUT(obj)



            obj.xPCPCIReadBlkName=downstream.tool.getBlockName(...
            obj.hTurnkey.hBoard.xPCPCIReadBlkPath);
            obj.xPCPCIWriteBlkName=downstream.tool.getBlockName(...
            obj.hTurnkey.hBoard.xPCPCIWriteBlkPath);
            obj.xPCSetupBlkName=downstream.tool.getBlockName(...
            obj.hTurnkey.hBoard.xPCSetupBlkPath);
            obj.xPCPCIRWBlkName=downstream.tool.getBlockName(...
            obj.hTurnkey.hBoard.xPCPCIRWBlkPath);


            obj.createSubsystemOnTopLevel;





            dutPath=obj.addTestPointPortsOnDUT();


            obj.createTunableConstantsUnderDUT();


            addxPCBoardSetupBlk(obj);



            validateCell=obj.generateInterfaceDrivers;


            addMaskOnxPCDUT(obj);
        end

        function addxPCBoardSetupBlk(obj)


            thresholdHeight=obj.setupBlkPosition(4)+40;
            moveAllBlocksBelow(obj,thresholdHeight);


            xPCSetupBlkPath=obj.addxPCLibraryBlk(obj.hTurnkey.hBoard.xPCSetupBlkPath,...
            obj.xPCSetupBlkName,obj.setupBlkPosition,true);


            boardID=obj.hTurnkey.hBoard.xPCSetupBlkBoardID;
            if~isempty(boardID)

                set_param(xPCSetupBlkPath,'boardtype',boardID);
            end


            set_param(xPCSetupBlkPath,'mdl_ss_name',obj.usrDutPath);
            set_param(xPCSetupBlkPath,'fpga_mat_file',obj.matFilePath);

            if obj.hTurnkey.hD.isIPCoreGen

                timestampOffset=hdlturnkey.data.Address.convertAddrCStrToDec(obj.hTurnkey.modelgeninfo.TimestampOffset);
                timestampValue=obj.hTurnkey.modelgeninfo.TimestampValue;
                set_param(xPCSetupBlkPath,'timestamp',timestampValue);
                set_param(xPCSetupBlkPath,'tsreg',timestampOffset);




                dutName=obj.hTurnkey.hD.hCodeGen.getDutName;
                TopMCSFileName=hdlslrt.backend.getMCSFileName(dutName,timestampValue);
                set_param(xPCSetupBlkPath,'bsf_file',TopMCSFileName);
            end
        end

        function moveAllBlocksBelow(obj,thresholdHeight)




            xpcDutObj=get_param(obj.tifDutPath,'Object');
            dutTopLevelBlks=xpcDutObj.Blocks;
            dutTopBlk=obj.fixBlockName(dutTopLevelBlks{1});
            dutTopBlkPath=obj.getTIFDutBlkPath(dutTopBlk);
            upperBlkPosition=get_param(dutTopBlkPath,'Position');


            for ii=1:length(dutTopLevelBlks)
                dutTopBlk=obj.fixBlockName(dutTopLevelBlks{ii});
                dutTopBlkPath=obj.getTIFDutBlkPath(dutTopBlk);
                blkPosition=get_param(dutTopBlkPath,'Position');
                if blkPosition(2)<upperBlkPosition(2)
                    upperBlkPosition=blkPosition;
                end
            end



            if upperBlkPosition(2)<thresholdHeight
                setupBlkAdjust=thresholdHeight-upperBlkPosition(2);
                for ii=1:length(dutTopLevelBlks)
                    dutTopBlk=obj.fixBlockName(dutTopLevelBlks{ii});
                    dutTopBlkPath=obj.getTIFDutBlkPath(dutTopBlk);
                    blkPosition=get_param(dutTopBlkPath,'Position');
                    updateBlkPosition=[...
                    blkPosition(1),...
                    blkPosition(2)+setupBlkAdjust,...
                    blkPosition(3),...
                    blkPosition(4)+setupBlkAdjust];
                    set_param(dutTopBlkPath,'Position',updateBlkPosition);
                end
            end

        end


        function addMaskOnxPCDUT(obj)



            boardName=obj.hTurnkey.hBoard.BoardName;
            dutBlk=obj.getSWModelDUTPathForMask;

            set_param(dutBlk,'MaskDescription',...
            sprintf('Simulink Real-Time Interface Block for %s.',boardName));



            if obj.hTurnkey.hD.isIPCoreGen

                maskDisplayStr=sprintf('%s\\n\\nTimestamp\\n%s',obj.hTurnkey.hBoard.xPCModelGenMaskDisp,obj.hTurnkey.modelgeninfo.TimestampValue);
            else
                maskDisplayStr=obj.hTurnkey.hBoard.xPCModelGenMaskDisp;
            end
            set_param(dutBlk,'MaskDisplay',sprintf('disp(sprintf(''%s''));',maskDisplayStr));


            set_param(dutBlk,'MaskIconOpaque','off');


            xpcparameters=obj.xpcParams;
            if isfield(xpcparameters,'deviceIdx')
                deviceIdx=xpcparameters.deviceIdx;
            else
                deviceIdx='0';
            end
            if isfield(xpcparameters,'slot')
                slot=xpcparameters.slot;
            else
                slot='-1';
            end
            if isfield(xpcparameters,'ts')
                ts=xpcparameters.ts;
            else
                ts='-1';
            end




            set_param(dutBlk,'MaskVariables','deviceIdx=@1;slot=@2;ts=@3');
            set_param(dutBlk,'MaskPrompts',...
            {'Device index:','PCI slot (-1: autosearch):','Sample time:'});
            set_param(dutBlk,'MaskStyles',{'edit','edit','edit'});
            set_param(dutBlk,'MaskValues',{deviceIdx,slot,ts});
            set_param(dutBlk,'MaskEnables',{'on','on','on'});

            set_param(dutBlk,'MaskHelp','');
            set_param(dutBlk,'MaskType',obj.hTurnkey.hBoard.xPCModelGenMaskType);
            set_param(dutBlk,'MaskInitialization','hdlslrt.backend.mfpgaparameters;');


            set_param(dutBlk,'Mask','on');



            set_param(dutBlk,'InitFcn','msgfpgachecks;');


            pciWriteBlkLibPath=obj.hTurnkey.hBoard.xPCPCIWriteBlkPath;
            pciReadBlkLibPath=obj.hTurnkey.hBoard.xPCPCIReadBlkPath;
            obj.setupxPCIOBlockOnType(pciWriteBlkLibPath);
            obj.setupxPCIOBlockOnType(pciReadBlkLibPath);

            if obj.hTurnkey.isCoProcessorMode
                pciRWBlkLibPath=obj.hTurnkey.hBoard.xPCPCIRWBlkPath;
                setupxPCIOBlockOnType(obj,pciRWBlkLibPath);
            end



            setupBlkDUTPath=obj.getTIFDutBlkPath(obj.xPCSetupBlkName);
            hSetupBlk=get_param(setupBlkDUTPath,'handle');

            set(hSetupBlk,'device_id','deviceIdx','pci_slot','slot');

        end

        function setupxPCIOBlockOnType(obj,blkLibPath)



            blkPaths=find_system(obj.tifDutPath,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on',...
            'LookUnderMasks','all',...
            'ReferenceBlock',blkLibPath);


            for ii=1:length(blkPaths)
                block=blkPaths{ii};
                set_param(block,'device_id','deviceIdx');
                set_param(block,'sample_time','ts');
            end
        end


        function configurexPCMdl(obj)



            tifTarget='slrealtime.tlc';


            set_param(obj.tifMdlName,'SystemTargetFile',tifTarget);


            set_param(obj.tifMdlName,'SolverType','Fixed-step');

        end


        function validateModelGen(obj)

            if obj.hTurnkey.hD.isBoardEmpty||...
                ~obj.hTurnkey.hBoard.isxPCBoard
                error(message('hdlcommon:workflow:NotxPCBoard',obj.hTurnkey.hD.get('Board')));
            end

            if isempty(obj.hTurnkey.hBoard.xPCSetupBlkPath)||...
                isempty(obj.hTurnkey.hBoard.xPCPCIWriteBlkPath)||...
                isempty(obj.hTurnkey.hBoard.xPCPCIReadBlkPath)||...
                isempty(obj.hTurnkey.hBoard.xPCPCIRWBlkPath)
                error(message('hdlcommon:workflow:MissingxPCBlkPath'));
            end

        end

    end

end






