



classdef StreamingDriver<handle


    properties

    end

    properties(Access=private)



        AXI4StreamFrameMode=false;






        AutoReadyDisable=false;


        hTurnkey=[];
    end

    methods

        function obj=StreamingDriver(hTurnkey)

            obj.hTurnkey=hTurnkey;
        end


        function isa=isStreamingMode(obj)

            isa=obj.isAXI4StreamBasedAssigned||obj.isAXI4VDMAMode;
        end

        function isa=isFrameToSampleMode(obj)


            if(~obj.hTurnkey.hD.isMLHDLC)
                isa=strcmp(hdlget_param(obj.hTurnkey.hD.getModelName,...
                'FrameToSampleConversion'),'on');
            else

                isa=false;
            end
        end

        function[isa,hStreamCell]=isAXI4StreamAssigned(obj)


            hStreamCell=obj.getAssignedAXI4StreamInterface;
            isa=~isempty(hStreamCell);
        end

        function[isa,hStreamCell]=isAXI4StreamBasedAssigned(obj)


            hStreamCell=obj.getAssignedAXI4StreamBasedInterface;
            isa=~isempty(hStreamCell);
        end

        function isa=isAXI4StreamFrameMode(obj)

            isa=obj.AXI4StreamFrameMode;
        end

        function[isa,hStreamCell]=isAXI4VDMAMode(obj)


            hStreamCell=obj.getAssignedAXI4VDMAInterface;
            if length(hStreamCell)==2
                isa=true;
            else
                isa=false;
            end
        end


        function validateCell=validateStreamingInterface(obj,validateCell)




            validateCell=validateAXI4StreamBasedInterface(obj,validateCell);


            validateCell=validateAXI4StreamInterface(obj,validateCell);


            validateCell=validateAXI4VDMAInterface(obj,validateCell);


            if(obj.isFrameToSampleMode)
                updateModelGenerationFrameMode(obj);
            end
        end

        function isa=hasStreamingInterface(obj)

            isa=false;
            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);
                if obj.isAXI4StreamBasedInterface(hInterface)||...
                    obj.isAXI4VDMAInterface(hInterface)
                    isa=true;
                    break;
                end
            end
        end


        function isit=isAutoReadyDisabled(obj)
















            isit=obj.AutoReadyDisable||(length(obj.getAssignedAXI4StreamBasedInterface)>1)||...
            obj.isFrameToSampleMode;
        end

        function msg=getReadyUnassignedMsg(obj)





            msg=[];
            [hStreamCell,hChannelIDMultiList]=obj.getInterfacesWithReadyUnassigned;
            if obj.isAutoReadyDisabled&&~isempty(hStreamCell)
                interfaceStr='';

                for ii=1:length(hStreamCell)





                    hInterface=hStreamCell{ii};
                    if hInterface.isAXI4StreamInterface&&hInterface.isFrameToSample()
                        continue;
                    end
                    hChannelIDList=hChannelIDMultiList{ii};
                    channelStr=strjoin(hChannelIDList,', ');
                    interfaceStr=[interfaceStr,channelStr,'; '];%#ok<AGROW>
                end
                if(length(interfaceStr)>1)
                    interfaceStr(end-1:end)='';
                end

                if obj.AutoReadyDisable
                    msg=message('hdlcommon:workflow:AutoReadyDisabledUser',interfaceStr);
                elseif(length(obj.getAssignedAXI4StreamBasedInterface)>1)&&~obj.isFrameToSampleMode


                    msg=message('hdlcommon:workflow:AutoReadyDisabledMultipleStream',interfaceStr);
                end
            end
        end


        function hStreamCell=getAssignedAXI4StreamInterface(obj)

            hStreamCell={};

            interfaceIDList=obj.hTurnkey.hTable.hTableMap.getAssignedInterfaces;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);
                if obj.isAXI4StreamInterface(hInterface)
                    hStreamCell{end+1}=hInterface;%#ok<AGROW>
                end
            end
        end

        function isa=isAXI4StreamInterface(~,hInterface)
            isa=hInterface.isIPInterface&&hInterface.isAXI4StreamInterface;
        end

        function hStreamCell=getAssignedAXI4StreamBasedInterface(obj)

            hStreamCell={};

            interfaceIDList=obj.hTurnkey.hTable.hTableMap.getAssignedInterfaces;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);
                if obj.isAXI4StreamBasedInterface(hInterface)
                    hStreamCell{end+1}=hInterface;%#ok<AGROW>
                end
            end
        end

        function isa=isAXI4StreamBasedInterface(~,hInterface)
            isa=hInterface.isIPInterface&&hInterface.isAXI4StreamBasedInterface;
        end

        function channelIDStr=printAssignedAXI4StreamChannelIDs(obj)

            channelIDStr='';
            hStreamCell=obj.getAssignedAXI4StreamInterface;
            interfaceNum=length(hStreamCell);
            for ii=1:interfaceNum
                hInterface=hStreamCell{ii};
                channelIDList=hInterface.getAssignedChannelIDList;
                channelNum=length(channelIDList);
                for jj=1:channelNum
                    channelID=channelIDList{jj};
                    if interfaceNum==1&&channelNum==1
                        channelIDStr=channelID;
                    elseif ii==interfaceNum&&jj==channelNum
                        channelIDStr=sprintf('%s and %s',channelIDStr,channelID);
                    else
                        channelIDStr=sprintf('%s%s, ',channelIDStr,channelID);
                    end
                end
            end
        end


        function hStreamCell=getAssignedAXI4VDMAInterface(obj)

            hStreamCell={};
            interfaceIDList=obj.hTurnkey.hTable.hTableMap.getAssignedInterfaces;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);
                if obj.isAXI4VDMAInterface(hInterface)
                    hStreamCell{end+1}=hInterface;%#ok<AGROW>
                end
            end
        end

        function isa=isAXI4VDMAInterface(~,hInterface)
            isa=hInterface.isStreamBasedVDMAInterface;
        end



        function hMasterCell=getAssignedAXI4MasterInterface(obj)

            hMasterCell={};

            interfaceIDList=obj.hTurnkey.hTable.hTableMap.getAssignedInterfaces;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);
                if hInterface.isIPInterface&&hInterface.isAXI4MasterInterface
                    hMasterCell{end+1}=hInterface;%#ok<AGROW>
                end
            end
        end

        function[isa,hMasterCell]=isAXI4MasterAssigned(obj)


            hMasterCell=obj.getAssignedAXI4MasterInterface;
            isa=~isempty(hMasterCell);
        end

        function isa=hasAXI4MasterInterface(obj)

            isa=false;
            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);
                if hInterface.isIPInterface&&hInterface.isAXI4MasterInterface
                    isa=true;
                    break;
                end
            end
        end

    end

    methods



    end

    methods(Access=protected)

        function validateCell=validateAXI4StreamBasedInterface(obj,validateCell)
            msg=obj.getReadyUnassignedMsg();
            if~isempty(msg)
                validateCell{end+1}=hdlvalidatestruct('Warning',msg);
            end
        end

        function[hStreamCell,hChannelIDMultiList]=getInterfacesWithReadyUnassigned(obj)




            hStreamCell={};


            hChannelIDMultiList={};


            streamCell=obj.getAssignedAXI4StreamBasedInterface;
            for ii=1:length(streamCell)
                hInterface=streamCell{ii};
                [isUnassigned,channelIDList]=obj.isReadyPortUnassigned(hInterface);
                if isUnassigned

                    hStreamCell{end+1}=hInterface;%#ok<AGROW>


                    hChannelIDMultiList{end+1}=channelIDList;%#ok<AGROW>
                end
            end
        end

        function[isit,hChannelIDList]=isReadyPortUnassigned(~,hInterface)





            hChannelIDList={};



            channelIDlist=hInterface.getAssignedChannelIDList;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                if~hInterface.isReadyPortAssigned(channelID)

                    hChannelIDList{end+1}=channelID;%#ok<AGROW>
                end
            end

            isit=~isempty(hChannelIDList);
        end


        function validateCell=validateAXI4StreamInterface(obj,validateCell)



            updateVectorModeStatus(obj);

        end

        function updateVectorModeStatus(obj)

            obj.AXI4StreamFrameMode=false;
            hStreamCell=obj.getAssignedAXI4StreamInterface;
            for ii=1:length(hStreamCell)
                hInterface=hStreamCell{ii};
                isFrameMode=hInterface.isFrameMode;
                if isFrameMode
                    obj.AXI4StreamFrameMode=true;
                    break;
                end
            end
        end

        function updateModelGenerationFrameMode(obj)


            hStreamCell=obj.getAssignedAXI4StreamInterface;
            for ii=1:length(hStreamCell)
                hInterface=hStreamCell{ii};
                if hInterface.hasMatrixPortAssigned
                    obj.hTurnkey.hD.hIP.setGenerateSoftwareInterfaceModelEnable(false);
                    break;
                end
            end
        end


        function validateCell=validateAXI4VDMAInterface(obj,validateCell)

            hStreamCell=obj.getAssignedAXI4VDMAInterface;


            if isempty(hStreamCell)
                return;
            end


            if obj.hTurnkey.isCoProcessorMode
                currentMode=obj.hTurnkey.hD.get('ExecutionMode');
                freerunMode=obj.hTurnkey.hExecMode.FreeRun;
                copModeMsg=message('HDLShared:hdldialog:HDLWAInputFPGAExecutionModeStr');
                copModeName=copModeMsg.getString;
                error(message('hdlcommon:workflow:StreamCopNotSupported',...
                currentMode,freerunMode,copModeName));
            end



            if length(hStreamCell)==1
                hStream=hStreamCell{1};
                interfaceID=hStream.InterfaceID;
                pairedID=hStream.PairedInterfaceID;
                error(message('hdlcommon:workflow:StreamInOutPair',...
                interfaceID,pairedID));
            end



            if length(hStreamCell)>2
                error(message('hdlcommon:workflow:StreamMoreThanTwo'));
            end
        end

    end


end



