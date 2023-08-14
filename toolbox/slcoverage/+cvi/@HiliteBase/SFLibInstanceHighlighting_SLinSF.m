function SFLibInstanceHighlighting_SLinSF(blockH,modelH)%#ok<INUSD>





    [toHighlight,informerObj,sfInstanceStruct]=cvi.Informer.SFLibInstanceHighlightingChecks(blockH);

    if~toHighlight
        return;
    end

    badgeHandler=informerObj.findBadgeHandler(modelH);

    colorTable=cvi.HiliteBase.getHighlightingColorTable;%#ok<NASGU>

    cvIds=sfInstanceStruct.cvIds;
    sfIds=cv('get',cvIds,'.handle');

    for idx=1:length(cvIds)
        if(cv('get',cvIds(idx),'.origin')==1)

            if~isempty(badgeHandler)
                udi=informerObj.getUdiObj(cvIds(idx));
                badgeHandler.addStyleAndBadge(cvIds(idx),[],sfIds(idx),udi,sfInstanceStruct.informerStrings{idx});
                covResults.modelH=modelH;
                covResults.Systems=blockH;
                covResults.FullCoverage=[];
                covResults.PartialCoverage=[];
                if sfInstanceStruct.isFullCoverage(idx)
                    covResults.FullCoverage=sfIds(idx);
                else
                    covResults.PartialCoverage=sfIds(idx);
                end
                covResults.FilteredCoverage=[];
                covResults.JustifiedCoverage=[];
                cvslhighlight('apply_style',informerObj.covStyleSession,covResults);
            else

                informerObj.infrmObj.mapData(sfIds(idx),['<big>',sfInstanceStruct.informerStrings{idx},'</big>']);

                if sfInstanceStruct.isFullCoverage(idx)==1
                    evalc('cvslhighlight(''apply'',modelH, sfIds(idx),''black'',colorTable.slGreen);');
                elseif sfInstanceStruct.isFullCoverage(idx)==2
                    evalc('cvslhighlight(''apply'',modelH, sfIds(idx),''black'',colorTable.slLightGreen);');
                elseif sfInstanceStruct.isFullCoverage(idx)==0
                    evalc('cvslhighlight(''apply'',modelH, sfIds(idx),''black'',colorTable.slRed);');
                end
            end
        end
    end


end