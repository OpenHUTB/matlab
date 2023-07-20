classdef ActualSrcDstSampleTimesChecker<handle




    properties
ConversionParameters
Logger
Systems
SubsystemPortBlocks
CurrentSubsystem
    end
    properties(Constant)
        DOWNSTREAM=3
        UPSTREAM=4
    end
    methods(Access=protected)
        function checkTsRCB(this,blkH,portTs,isInport,stream,streamTs,streamBlk,streamPort,compiledSampleTimes)
            if~isempty(streamTs)&&(~isequal(portTs,streamTs)&&~compiledSampleTimes.hasSampleTime(streamTs))

                if~this.ConversionParameters.ReplaceSubsystem
                    blockPath=Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(blkH),blkH);
                else
                    blockPath=getfullname(blkH);
                end

                id='';
                if stream==this.DOWNSTREAM
                    id='Simulink:modelReference:convertToModelReference_inportInvalidDownStreamSampleTimeErr';
                elseif stream==this.UPSTREAM
                    id='Simulink:modelReference:convertToModelReference_outportInvalidUpStreamSampleTimeErr';
                end

                msg=message(id,blockPath,num2str(portTs(1)),num2str(portTs(2)),...
                num2str(streamTs(1)),num2str(streamTs(2)),streamPort+1,...
                Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(streamBlk),streamBlk));

                if stream==this.DOWNSTREAM
                    if isInport
                        if~isequal(portTs(1),inf)
                            this.handleDiagnostic(msg);
                        end
                    else
                        this.Logger.addWarning(msg);
                    end
                elseif stream==this.UPSTREAM
                    if~isInport
                        this.handleDiagnostic(msg);
                    else
                        this.Logger.addWarning(msg);
                    end
                end
            end
        end
    end
    methods(Access=private)
        function handleDiagnostic(this,msg)
            if(this.ConversionParameters.Force)
                this.Logger.addWarning(msg);
            else
                throw(MSLException(msg));
            end
        end

        function[streamTs,streamBlk,streamPort]=getDownstreamSampleTimes(this,tsInfo)
            streamTs=[];
            streamBlk=-1;
            streamPort=-1;
            if tsInfo(this.DOWNSTREAM,1)~=-1
                streamBlk=tsInfo(this.DOWNSTREAM,1);
                streamPort=tsInfo(this.DOWNSTREAM,2);
                assert(tsInfo(this.DOWNSTREAM,3)==1);
                streamTs=tsInfo(this.DOWNSTREAM,4:5);
            end
        end

        function[streamTs,streamBlk,streamPort]=getUpstreamSampleTimes(this,tsInfo)
            streamTs=[];
            streamBlk=-1;
            streamPort=-1;
            if tsInfo(this.UPSTREAM,1)~=-1
                streamBlk=tsInfo(this.UPSTREAM,1);
                streamPort=tsInfo(this.UPSTREAM,2);
                assert(tsInfo(this.UPSTREAM,3)==0);
                streamTs=tsInfo(this.UPSTREAM,4:5);
            end
        end



        function checkBlockSampleTimes(this,stream,ph,blkH,isInport)











            tsInfo=get_param(ph,'PortBlockSampleTimeInfo');
            portTs=tsInfo(1,4:5);


            if~Simulink.ModelReference.Conversion.isBusElementPort(blkH)
                assert(blkH==tsInfo(1,1));
            end

            streamTs=[];
            streamBlk=-1;
            streamPort=-1;
            if stream==this.DOWNSTREAM
                [streamTs,streamBlk,streamPort]=this.getDownstreamSampleTimes(tsInfo);
            elseif stream==this.UPSTREAM
                [streamTs,streamBlk,streamPort]=this.getUpstreamSampleTimes(tsInfo);
            end

            compiledSampleTimes=Simulink.ModelReference.Conversion.CompiledSampleTimes(ph);
            this.checkTsRCB(blkH,portTs,isInport,stream,streamTs,streamBlk,streamPort,compiledSampleTimes);

        end
    end

    methods(Access=public)
        function this=ActualSrcDstSampleTimesChecker(Systems,SubsystemPortBlocks,ConversionParameters,Logger,currentSubsystem)
            this.Systems=Systems;
            this.SubsystemPortBlocks=SubsystemPortBlocks;
            this.ConversionParameters=ConversionParameters;
            this.Logger=Logger;
            this.CurrentSubsystem=currentSubsystem;
        end

        function checkForActualSrcDstSampleTimes(this)


            subsysIdx=find(this.Systems==this.CurrentSubsystem);

            ssInBlkHs=this.SubsystemPortBlocks{subsysIdx}.inportBlksH.blocks;
            for idx=1:numel(ssInBlkHs)
                blkH=ssInBlkHs(idx);
                phs=get_param(blkH,'PortHandles');
                ph=phs.Outport;
                isInport=true;
                this.checkBlockSampleTimes(this.UPSTREAM,ph,blkH,isInport);
                this.checkBlockSampleTimes(this.DOWNSTREAM,ph,blkH,isInport);
            end

            ssOutBlkHs=this.SubsystemPortBlocks{subsysIdx}.outportBlksH.blocks;
            for idx=1:numel(ssOutBlkHs)
                blkH=ssOutBlkHs(idx);
                phs=get_param(blkH,'PortHandles');
                ph=phs.Inport;
                isInport=false;
                this.checkBlockSampleTimes(this.UPSTREAM,ph,blkH,isInport);
                this.checkBlockSampleTimes(this.DOWNSTREAM,ph,blkH,isInport);
            end
        end
    end
end
