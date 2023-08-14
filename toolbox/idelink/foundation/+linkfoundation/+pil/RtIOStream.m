classdef RtIOStream<rtw.pil.RtIOStreamLink







    properties(GetAccess='private',SetAccess='private')
        Launcher;
        BlockHandle;
        BreakPtAddress;
        IdeRtIOStreamRecvBufferAddress;
        IdeRtIOStreamSendDataPtrAddress;
        IdeRtIOStreamSendDataAvailAddress;
        IdeRtIOStreamPtrType;
        IdeRtIOStreamSizeTType;
        LinkObject;
    end

    methods
        function this=RtIOStream(launcher,...
            rxBufferSizeBytes)

            this@rtw.pil.RtIOStreamLink(rxBufferSizeBytes);
            this.Launcher=launcher;
        end
    end

    methods(Access='protected')
        function openStreamHook(this)
            narginchk(1,1);
            try

                myLauncher=this.Launcher;
                internalData=myLauncher.getInternalData();
                this.BlockHandle=internalData.blockHandle;
            catch ex
                this.BlockHandle=[];
                error(message('ERRORHANDLER:pjtgenerator:NoBlockHandle'));
            end

            linkObject=this.Launcher.getLinkObject;
            this.IdeRtIOStreamRecvBufferAddress=address(linkObject,'IdeRtIOStreamRecvBuffer');
            this.IdeRtIOStreamSendDataPtrAddress=address(linkObject,'IdeRtIOStreamSendDataPtr');
            this.IdeRtIOStreamSendDataAvailAddress=address(linkObject,'IdeRtIOStreamSendDataAvail');
            IdeRtIOStreamPtrSizeAddress=address(linkObject,'IdeRtIOStreamPtrSize');
            IdeRtIOStreamSizeTSizeAddress=address(linkObject,'IdeRtIOStreamSizeTSize');
            IdeRtIOStreamPtrSize=read(linkObject,IdeRtIOStreamPtrSizeAddress,this.getIODataType,1);
            IdeRtIOStreamSizeTSize=read(linkObject,IdeRtIOStreamSizeTSizeAddress,this.getIODataType,1);
            this.IdeRtIOStreamPtrType=linkfoundation.pil.RtIOStream.getDataTypeForSize(IdeRtIOStreamPtrSize);
            this.IdeRtIOStreamSizeTType=linkfoundation.pil.RtIOStream.getDataTypeForSize(IdeRtIOStreamSizeTSize);
            this.BreakPtAddress=address(linkObject,'pilDataBreakpoint');

            this.LinkObject=linkObject;











        end

        function sendHook(this,data)
            linkObject=this.LinkObject;

            write(linkObject,this.IdeRtIOStreamRecvBufferAddress,data);
        end

        function data=recvHook(this)
            linkObject=this.LinkObject;

            dataAvail=read(linkObject,this.IdeRtIOStreamSendDataAvailAddress,this.IdeRtIOStreamSizeTType,1);
            sendDataPtrAddress=this.IdeRtIOStreamSendDataPtrAddress;

            dataAddress=read(linkObject,sendDataPtrAddress,this.IdeRtIOStreamPtrType,1);
            switch length(sendDataPtrAddress)
            case 1

                sendDataAddress=dataAddress;
            case 2

                sendDataAddress(1)=dataAddress;
                sendDataAddress(2)=sendDataPtrAddress(2);
            otherwise
                assert(false,...
                'Unexpected sendDataPtrAddress length: %d',...
                length(sendDataPtrAddress));
            end

            data=read(linkObject,sendDataAddress,this.getIODataType,double(dataAvail));
        end

        function closeStreamHook(this)%#ok<MANU>
        end

        function continueHook(this)
            linkObject=this.LinkObject;

            waitForPILBreakpoint(this,linkObject);
        end
    end

    methods(Access='private',Static)

        function datatype=getDataTypeForSize(dataTypeSize)
            switch dataTypeSize
            case 1
                datatype='uint8';
            case 2
                datatype='uint16';
            case 4
                datatype='uint32';
            case 8
                datatype='uint64';
            otherwise
                assert(false,'Unexpected dataTypeSize: %d\n',dataTypeSize);
            end
        end
    end

    methods(Access='private')
        function waitForPILBreakpoint(this,link)

            run(link,'runtohalt');



            if(~atBreakPoint(this,link))
                waiting=true;

                hilite_system(this.BlockHandle,'find');
                wBar=createWaitBar(this);
                waitCounter=0;
                waitCounterMax=100;
                pauseTime=1.0;
                while(waiting)


                    pause(pauseTime);

                    if(atBreakPoint(this,link))
                        waiting=false;
                    elseif isSimulationTerminating(this)
                        hilite_system(this.BlockHandle,'none');
                        close(wBar);
                        error(message('ERRORHANDLER:pjtgenerator:PilStoppedWhileWaitingOnUser'));
                    else
                        waitCounter=waitCounter+1;
                        if waitCounter>waitCounterMax

                            position=get(wBar,'Position');
                            close(wBar);
                            wBar=createWaitBar(this);
                            set(wBar,'Position',position);
                            waitCounter=0;
                        end
                        if~ishandle(wBar)


                            hilite_system(this.BlockHandle,'none');
                            error(message('ERRORHANDLER:pjtgenerator:PilStoppedByClosingDialog'));
                        end
                        waitbar(waitCounter/waitCounterMax,wBar);
                    end
                end
                close(wBar);
            end
        end

        function wBar=createWaitBar(this)%#ok<MANU>
            nl=sprintf('\n');
            wBar=waitbar(0,['               PIL Simulation has hit a user breakpoint.              ',nl,nl...
            ,'Simulink is waiting for you to finish debugging in the IDE.',nl,nl...
            ,'To continue co-simulation, remove the user breakpoint and click "Run" in IDE',nl...
            ,'To stop simulation, close this dialog box.'],'Name','IDE Link: PIL');
        end

        function atBreakPt=atBreakPoint(this,link)
            try
                addr=invokeIdeModule(link,'GetPC');
            catch ex %#ok<NASGU>


                addr=0;
            end
            atBreakPt=isequal(addr,this.BreakPtAddress(1));
        end

        function terminating=isSimulationTerminating(this)
            simstatus=get_param(bdroot(this.BlockHandle),'SimulationStatus');
            terminating=strcmpi(simstatus,'terminating');
        end
    end
end
