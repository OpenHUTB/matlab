function checkLinkStatus(blockToBreakLink,blockInfo)




    linkStatus=get_param(blockToBreakLink,'linkstatus');

    switch(linkStatus)
    case 'none'
        if blockInfo.ReplacementInfo.UnderSelfModifMaskException



            parent=get_param(blockToBreakLink,'Parent');
            if~strcmp(get_param(parent,'Type'),'block_diagram')
                Sldv.xform.BlkRepRule.checkLinkStatus(getfullname(get_param(parent,'Handle')),blockInfo);
            end
        end
        return;
    case{'inactive','resolved'}
        linkData=get_param(blockToBreakLink,'LinkData');

        set_param(blockToBreakLink,'LinkStatus','none');

        for i=1:length(linkData)
            blockPath=[blockToBreakLink,'/',linkData(i).BlockName];
            if getSimulinkBlockHandle(blockPath)>0
                fieldNames=fieldnames(linkData(i).DialogParameters);
                for j=1:length(fieldNames)
                    set_param(blockPath,fieldNames{j},linkData(i).DialogParameters.(fieldNames{j}));
                end
            end
        end

        if blockInfo.rtwFcnNameCheckRequired
            checkParentRTWFcnName(get_param(blockToBreakLink,'Handle'),blockInfo);
        end
        return;
    case 'implicit'
        parent=get_param(blockToBreakLink,'Parent');
        Sldv.xform.BlkRepRule.checkLinkStatus(getfullname(get_param(parent,'Handle')),blockInfo);
        return;
    end

end

function checkParentRTWFcnName(blockHToBreakLink,blockInfo)
    if strcmp(get_param(blockHToBreakLink,'Type'),'block_diagram')||...
        ~strcmp(get_param(blockHToBreakLink,'BlockType'),'SubSystem')
        return;
    end

    if blockInfo.ReplacementInfo.TableLibLinkBrokenSS.isKey(blockHToBreakLink)
        return;
    end

    if Sldv.xform.isRtwReusableFcnSS(blockHToBreakLink)
        set_param(blockHToBreakLink,'RTWSystemCode','Auto');
        blockInfo.ReplacementInfo.TableLibLinkBrokenSS(blockHToBreakLink)=true;
    else
        blockInfo.ReplacementInfo.TableLibLinkBrokenSS(blockHToBreakLink)=false;
    end

    parent=get_param(blockHToBreakLink,'Parent');
    checkParentRTWFcnName(get_param(parent,'Handle'),blockInfo);
end
