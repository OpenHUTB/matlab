function UDPReceiver(obj)




    if isR2018bOrEarlier(obj.ver)




        UDP_blocks=obj.findBlocksWithMaskType('UDP Receiver');

        numDRBlks=length(UDP_blocks);

        if numDRBlks>0
            for blkIdx=1:numDRBlks
                blk=UDP_blocks{blkIdx};

                isCplx=get_param(blk,'isComplex');

                if strcmp(isCplx,'on')
                    obj.replaceWithEmptySubsystem(blk,...
                    'UDP Receiver',...
                    DAStudio.message('dsp:block:NewFeaturesNotAvailable'));
                end
            end
        end

    end

end
