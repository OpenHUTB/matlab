function UDPSendBlock(obj)







    if isR2019bOrEarlier(obj.ver)
        UDP_blocks=obj.findBlocksWithMaskType('UDP Send');
        numUDPBlks=length(UDP_blocks);
        if numUDPBlks>0
            for blkIdx=1:numUDPBlks
                blk=UDP_blocks{blkIdx};
                if(evalin('base',get_param(blk,'sendBufferSize'))>8192)

                    w=warning('backtrace','off');
                    MSLDiagnostic('dsp:block:NewFeaturesNotAvailable').reportAsWarning;
                    warning(w);
                end
            end
        end
    end

end
