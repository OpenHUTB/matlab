function removeReplacedButUnusedBlocks(obj,sliceXfrmr)





    blks=sliceXfrmr.slicerReplacedBlockH;



    if obj.options.InlineOptions.ModelBlocks



        sigBlks=find_system(sliceXfrmr.sliceMdlName,'regexp','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','BlockType','SignalConversion','name','__SLDVAddConversion');
        if iscell(sigBlks)
            sigBlks=cellfun(@(b)get_param(b,'handle'),sigBlks);
        end
        sigBlks=reshape(sigBlks,1,length(sigBlks));
        blks=[blks,sigBlks];
    end
    for idx=1:length(blks)
        try
            ph=get(blks(idx),'PortHandles');
            outLH=get(ph.Outport,'Line');
            inLH=get(ph.Inport,'Line');
            deleteOutLine=false;
            deleteBlock=false;
            if outLH==-1
                deleteBlock=true;
            else
                if get(outLH,'DstBlockHandle')==-1
                    deleteBlock=true;
                    deleteOutLine=true;
                end
            end
            if deleteBlock
                parent=get_param(blks(idx),'Parent');
                sliceXfrmr.deleteBlock(blks(idx));
                if deleteOutLine
                    sliceXfrmr.deleteLine(outLH);
                end
                if inLH>0
                    dstBlockHandle=get(inLH,'DstBlockHandle');
                    if isscalar(dstBlockHandle)&&dstBlockHandle<0
                        sliceXfrmr.deleteLine(inLH);
                    end
                end


                if strcmp(get_param(parent,'type'),'block')


                    blk=find_system(parent,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','type','block');
                    if numel(blk)==1
                        outLH=get_param(parent,'LineHandles');
                        flds=fieldnames(outLH);
                        allEmpty=true;
                        for i=1:length(flds)
                            if~isempty(outLH.(flds{i}))
                                allEmpty=false;
                            end
                        end
                        if allEmpty
                            sliceXfrmr.deleteBlock(parent);
                        end
                    end
                end
            end
        catch Mex %#ok<NASGU>

        end
    end
end
