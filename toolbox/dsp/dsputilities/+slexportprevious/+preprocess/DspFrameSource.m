function DspFrameSource(obj)






    verobj=obj.ver;

    if isR2015aOrEarlier(verobj)
        fullBlockList={'Sine Wave',...
        'Chirp',...
        'Random source',...
        'Discrete Impulse',...
        'From Audio Device',...
        'NCO',...
        'Signal From Workspace',...
        'CIC Interpolation',...
        'Delay Line',...
        'Dyadic Synthesis Filter Bank',...
        'Dyadic Analysis Filter Bank',...
        'DWT',...
        'IDWT',...
        'Triggered Signal From Workspace',...
        'Inverse Short-Time FFT',...
'Buffer'
        };

        numFrameUpgradedBlks=length(fullBlockList);
        for idx=1:numFrameUpgradedBlks

            frameUpgradedBlks=obj.findBlocksOfType(fullBlockList{idx});
            n2bReplaced=length(frameUpgradedBlks);

            for i=1:n2bReplaced
                blk=frameUpgradedBlks{i};
                outputFrames=get_param(blk,'OutputFrames');



                if strcmp(outputFrames,'off')&&outputsSampleInOldRelease(blk,fullBlockList{idx})
                    blkLHandles=get_param(blk,'LineHandles');
                    for count=1:length(blkLHandles.Outport)
                        if blkLHandles.Outport(count)~=-1
                            blkLHOutport=get(blkLHandles.Outport(count));
                            InsertExtraBlock(blk,blkLHOutport,'Post',80,0,...
                            'dspobslib','dspobslib/Frame Conversion',...
                            {'OutFrame'},{'Sample-based'});
                        end
                    end
                end
            end
        end

    end

    function flag=outputsSampleInOldRelease(blkHandle,blkName)

        flag=false;
        switch blkName
        case 'Sine Wave'
            flag=comparetoOne(blkHandle,'SamplesPerFrame');
        case 'Chirp'
            flag=comparetoOne(blkHandle,'spf');
        case 'Random Source'
            flag=comparetoOne(blkHandle,'SampFrame');
        case 'Discrete Impulse'
            flag=comparetoOne(blkHandle,'FrameSample');
        case 'From Audio Device'
            flag=comparetoOne(blkHandle,'framesize');
        case 'NCO'
            flag=comparetoOne(blkHandle,'SamplesPerFrame');
        case 'Signal From Workspace'
            flag=comparetoOne(blkHandle,'nsamps');
        case{'CIC Interpolation','Delay Line','Dyadic Synthesis Filter Bank'}
            flag=true;
        case 'Dyadic Analysis Filter Bank'
            ph=get_param(blkHandle,'PortHandles');
            flag=(length(ph.Outport)>1);
        case 'Buffer'
            flag=comparetoOne(blkHandle,'N');
        otherwise
        end

        function flag=comparetoOne(blkHandle,param)
            valStr=get_param(blkHandle,param);
            [val,resolved]=slResolve(valStr,blkHandle);
            if(resolved)
                flag=(val>1);
            else
                flag=true;
            end
