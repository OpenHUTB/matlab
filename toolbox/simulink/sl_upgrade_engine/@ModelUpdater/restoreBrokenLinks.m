function restoreBrokenLinks(h)

































    if h.CheckFlags.LinkRestore


        fillLinkMappingData(h);






        commonArgs={'LookUnderMasks','all',...
        'LookInsideSubsystemReference','off',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices};

        brokenLinks=find_system(h.MyModel,commonArgs{:},'BlockType','S-Function','LinkStatus','none');
        temp1=find_system(h.MyModel,commonArgs{:},'BlockType','S-Function','LinkStatus','inactive');
        temp2=find_system(h.MyModel,commonArgs{:},'BlockType','SubSystem','LinkStatus','none');
        temp3=find_system(h.MyModel,commonArgs{:},'BlockType','SubSystem','LinkStatus','inactive');
        temp4=find_system(h.MyModel,commonArgs{:},'BlockType','M-S-Function','LinkStatus','none');
        temp5=find_system(h.MyModel,commonArgs{:},'BlockType','M-S-Function','LinkStatus','inactive');
        temp6=find_system(h.MyModel,commonArgs{:},'BlockType','StateSpace','LinkStatus','none');
        temp7=find_system(h.MyModel,commonArgs{:},'BlockType','StateSpace','LinkStatus','inactive');
        temp8=find_system(h.MyModel,commonArgs{:},'BlockType','MATLABSystem','LinkStatus','none');
        temp9=find_system(h.MyModel,commonArgs{:},'BlockType','MATLABSystem','LinkStatus','inactive');
        brokenLinks=[brokenLinks;temp1;temp2;temp3;temp4;temp5;temp6;temp7',temp8;temp9];




        numBrokenLinks=numel(brokenLinks);
        for iBrokenLink=1:numBrokenLinks

            curBadBlock=brokenLinks{iBrokenLink};




            try
                status=get_param(curBadBlock,'LinkStatus');
                if strcmpi(status,'resolved')
                    continue;
                end
                replacementInfo=determineBrokenLinkReplacement(h,curBadBlock);
            catch %#ok<CTCH>
                continue;
            end


            if isempty(replacementInfo.newRefBlock)
                continue
            end






            stillExists=find_system(curBadBlock,'LookUnderMasks','all',...
            'FirstResultOnly','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);

            if isempty(stillExists)
                continue
            end


            if askToReplace(h,curBadBlock)
                if isfield(replacementInfo,'linkMappingCallback')&&...
                    ~isempty(replacementInfo.linkMappingCallback)
                    funcSet=uBlock2Link(h,curBadBlock,replacementInfo.newRefBlock,replacementInfo.linkMappingCallback);
                else
                    funcSet=uBlock2Link(h,curBadBlock,replacementInfo.newRefBlock);
                end
                appendTransaction(h,curBadBlock,h.RestoreLinkReasonStr,{funcSet});
            end

        end

    end

end


