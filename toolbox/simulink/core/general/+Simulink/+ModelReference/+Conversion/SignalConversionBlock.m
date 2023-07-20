


classdef SignalConversionBlock<handle
    properties(SetAccess=private,GetAccess=public)
ConversionData
Logger
    end

    properties(Constant)
        AddLineOptions={'autorouting','on'};
        ExcludedPortParameters={'ShowPropagatedSignals','PropagatedSignals','PerturbationForJacobian'}
    end

    methods(Access=public)
        function this=SignalConversionBlock(params)
            this.ConversionData=params;
            this.Logger=this.ConversionData.Logger;
        end

        function insert(this,currentSubsystem,outportMask)
            if any(outportMask)
                ph=get_param(currentSubsystem,'PortHandles');
                portIndexes=find(outportMask==true);
                parentBlock=get_param(currentSubsystem,'Parent');
                srcBlkName=get_param(currentSubsystem,'Name');


                for portIdx=1:numel(portIndexes)
                    portNum=portIndexes(portIdx);
                    oPort=ph.Outport(portNum);
                    aLine=get_param(oPort,'Line');



                    if ishandle(aLine)
                        dstBlocks=get_param(aLine,'DstBlockHandle');
                        if~all(strcmp(get_param(dstBlocks,'BlockType'),'SignalConversion'))
                            dstPorts=arrayfun(@(aPort)get_param(aPort,'PortNumber'),get_param(aLine,'DstPortHandle'));
                            [disViewers,disAxes]=this.disconnectViewers(oPort);
                            [prmNames,prmVals]=Simulink.ModelReference.Conversion.PortUtils.getOutputSigInfo(oPort);


                            [prmNames,ia]=setdiff(prmNames,this.ExcludedPortParameters);
                            prmVals=prmVals(ia);


                            blkH=this.createSignalConversionBlock(currentSubsystem,portNum);
                            signalConversionBlockName=get_param(blkH,'Name');


                            delete_line(aLine);


                            add_line(parentBlock,...
                            sprintf('%s/%d',srcBlkName,portNum),...
                            sprintf('%s/%d',signalConversionBlockName,1),this.AddLineOptions{:});


                            arrayfun(@(blkIdx)add_line(parentBlock,...
                            sprintf('%s/%d',signalConversionBlockName,1),...
                            sprintf('%s/%d',get_param(dstBlocks(blkIdx),'Name'),dstPorts(blkIdx)),...
                            this.AddLineOptions{:}),1:numel(dstBlocks));


                            scPortHandles=get_param(blkH,'PortHandles');
                            scPortBlock=scPortHandles.Outport;


                            if~isempty(disViewers)
                                this.connectViewers(scPortBlock,disViewers,disAxes);
                            end


                            Simulink.ModelReference.Conversion.PortUtils.setOutputSigInfo(scPortBlock,prmNames,prmVals);



                            ssName=Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(...
                            getfullname(currentSubsystem),currentSubsystem);
                            this.Logger.addInfo(...
                            message('Simulink:modelReferenceAdvisor:InsertSignalConversionBlock',...
                            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(blkH),blkH),...
                            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(num2str(portNum),oPort),...
                            ssName,ssName));
                        end
                    end
                end
            end
        end
    end
    methods(Access=public,Static)
        function blk=create(currentSubsystem,portNum,blockName)
            phs=get_param(currentSubsystem,'PortHandles');
            ph=phs.Outport(portNum);
            pos=get_param(ph,'Position');
            over=pos(1);
            down=pos(2);

            orientation=get_param(currentSubsystem,'Orientation');

            offset=5;
            sigHeight=20;
            sigWidth=30;

            switch(orientation)
            case 'up'
                sigLeft=over-(sigWidth/2);
                sigRight=over+(sigWidth/2);
                sigTop=down-offset-sigHeight;
                sigBottom=down-offset;

            case 'down'
                sigLeft=over-(sigWidth/2);
                sigRight=over+(sigWidth/2);
                sigTop=down+offset;
                sigBottom=down+offset+sigHeight;

            case 'left'
                sigLeft=over-offset-sigWidth;
                sigRight=over-offset;
                sigTop=down-(sigHeight/2);
                sigBottom=down+(sigHeight/2);

            case 'right'
                sigLeft=over+offset;
                sigRight=over+offset+sigWidth;
                sigTop=down-(sigHeight/2);
                sigBottom=down+(sigHeight/2);
            end

            sigPos=[sigLeft,sigTop,sigRight,sigBottom];
            blk=add_block('built-in/SignalConversion',...
            blockName,...
            'MakeNameUnique','on',...
            'Position',sigPos,...
            'Orientation',orientation,...
            'ConversionOutput','Virtual bus',...
            'ShowName','off');
        end
    end
    methods(Access=private)
        function blk=createSignalConversionBlock(~,currentSubsystem,portNum)
            newBlockName=[get_param(currentSubsystem,'Parent'),'/SignalConversion'];
            blk=Simulink.ModelReference.Conversion.SignalConversionBlock.create(currentSubsystem,portNum,newBlockName);
        end

        function[disViewers,disAxes]=disconnectViewers(this,outport)
            try
                [disViewers,disAxes]=Simulink.ModelReference.Conversion.Utilities.disconnectViewers(outport);
            catch me
                cellfun(@(msg)this.Logger.addWarning(msg),...
                Simulink.ModelReference.Conversion.ConversionLogger.createMessageFromException(me));
            end
        end

        function connectViewers(this,outport,viewers,vAxes)
            try
                Simulink.ModelReference.Conversion.Utilities.connectViewers(outport,viewers,vAxes)
            catch me
                cellfun(@(msg)this.Logger.addWarning(msg),...
                Simulink.ModelReference.Conversion.ConversionLogger.createMessageFromException(me));
            end
        end
    end
end


