function sigConvBlock(obj)





    warnForSignalCopy=false;

    if isR2011aOrEarlier(obj.ver)

        obj.appendRule('<BlockParameterDefaults<Block<BlockType|SignalConversion><ConversionOutput:repval "Contiguous copy">>>');

        sigConvBlocks=slexportprevious.utils.findBlockType(obj.modelName,'SignalConversion');

        if~isempty(sigConvBlocks)
            for i=1:length(sigConvBlocks)
                blk=sigConvBlocks{i};
                SID=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));
                convType=get_param(blk,'ConversionOutput');

                if contains(convType,'Signal copy')
                    obj.appendRule(['<Block<SID|"',SID,...
                    '"><ConversionOutput:repval "Contiguous copy">>']);
                    warnForSignalCopy=true;
                end
            end
        end
    end

    if warnForSignalCopy
        obj.reportWarning('Simulink:blocks:SignalConversionSaveAsParameters',obj.ver.release);
    end
