function SFLibInstanceHighlighting(blockH)


































    [toHighlight,informerObj,sfInstanceStruct]=cvi.Informer.SFLibInstanceHighlightingChecks(blockH);

    if~toHighlight
        return;
    end

    root=Stateflow.Root;

    cvIds=sfInstanceStruct.cvIds;
    sfIds=cv('get',cvIds,'.handle');


    sfFullCovStyle=sf('find','all','style.name','Full coverage');
    sfMissingCovStyle=sf('find','all','style.name','Missing coverage');
    sfJustifiedCovStyle=sf('find','all','style.name','Justified coverage');




    modelH=get_param(bdroot(blockH),'handle');
    badgeHandler=informerObj.findBadgeHandler(modelH);


    covResults.SFCoverage.sfCovered=struct('sfIds',[],'cvIds',[]);
    covResults.SFCoverage.sfMissing=struct('sfIds',[],'cvIds',[]);
    covResults.SFCoverage.sfJustified=struct('sfIds',[],'cvIds',[]);
    covResults.SFCoverage.sfFiltered=[];
    covResults.SFCoverage.noCovTrans=[];
    covResults.SFCoverage.noCovStates=[];

    for idx=1:length(sfIds)

        if(cv('get',cvIds(idx),'.origin')==2)

            udi=root.idToHandle(sfIds(idx));

            if(isa(udi,'Stateflow.Chart')||isa(udi,'Stateflow.State')||isa(udi,'Stateflow.Transition')||isa(udi,'Stateflow.SLFunction'))



                if~isempty(badgeHandler)
                    badgeHandler.addStyleAndBadge(cvIds(idx),[],sfIds(idx),udi,sfInstanceStruct.informerStrings{idx});
                else

                    informerObj.infrmObj.mapData(udi,['<big>',sfInstanceStruct.informerStrings{idx},'</big>']);
                end

                if sfInstanceStruct.isFullCoverage(idx)==1

                    sf('SetAltStyle',sfFullCovStyle(1),sfIds(idx));
                    covResults.SFCoverage.sfCovered.sfIds(end+1)=sfIds(idx);
                    covResults.SFCoverage.sfCovered.cvIds(end+1)=cvIds(idx);

                elseif sfInstanceStruct.isFullCoverage(idx)==0

                    sf('SetAltStyle',sfMissingCovStyle(1),sfIds(idx));
                    covResults.SFCoverage.sfMissing.sfIds(end+1)=sfIds(idx);
                    covResults.SFCoverage.sfMissing.cvIds(end+1)=cvIds(idx);
                elseif sfInstanceStruct.isFullCoverage(idx)==2

                    sf('SetAltStyle',sfJustifiedCovStyle(1),sfIds(idx));
                    covResults.SFCoverage.sfJustified.sfIds(end+1)=sfIds(idx);
                    covResults.SFCoverage.sfJustified.cvIds(end+1)=cvIds(idx);
                end

            end
        end
    end

    cvslhighlight('apply_style',informerObj.covStyleSession,covResults);

end

