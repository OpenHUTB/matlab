function CommFrameUpgradeSourceBlock(obj)





    if isR2015aOrEarlier(obj.ver)



        blkList=find_system(obj.modelName,...
        'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'RegExp','on',...
        'ReferenceBlock',...
        [sprintf('commseqgen3/PN Sequence\nGenerator'),'|'...
        ,sprintf('commseqgen3/Gold Sequence\nGenerator'),'|'...
        ,sprintf('commseqgen3/Kasami\nSequence\nGenerator'),'|'...
        ,sprintf('commseqgen3/Barker Code\nGenerator'),'|',...
        sprintf('commseqgen3/Hadamard\nCode Generator'),'|',...
        sprintf('commseqgen3/OVSF Code\nGenerator'),'|',...
        sprintf('commseqgen3/Walsh Code\nGenerator'),'|',...
        sprintf('commrandsrc3/Random Integer\nGenerator'),'|',...
        sprintf('commrandsrc3/Bernoulli Binary\nGenerator'),'|',...
        sprintf('commrandsrc3/Poisson Integer\nGenerator')]);



        for p=1:length(blkList)
            block=blkList{p};

            refBlock=get_param(block,'ReferenceBlock');

            try
                sampPerFrameStr=get_param(block,'sampPerFrame');
            catch
                sampPerFrameStr=get_param(block,'SamplesPerFrame');
            end

            try
                sampPerFrameVal=evalin('base',sampPerFrameStr);
                if sampPerFrameVal>1
                    frameBased='on';
                else
                    frameBased='off';
                end
            catch
                frameBased='off';
            end

            if strcmp(frameBased,'on')




                blkLHandles=get_param(block,'LineHandles');
                blkLHOutport=get(blkLHandles.Outport(1));
                InsertExtraBlock(block,blkLHOutport,'Post',80,0,...
                'dspobslib','dspobslib/Frame Conversion',...
                {'OutFrame'},{'Sample-based'});
            end
            identifyingRule=[slexportprevious.rulefactory.identifyBlockBySID(block)...
            ,sprintf('<SourceBlock|"%s">',strrep(refBlock,newline,'\n'))];
            obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(...
            identifyingRule,'frameBased',frameBased));
        end
    end
end
