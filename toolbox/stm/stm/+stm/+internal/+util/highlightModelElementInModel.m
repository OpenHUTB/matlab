function highlightModelElementInModel(modelName,harnessName,modelElement,sid,isRealtime)


    if(isempty(harnessName))
        modelToUse=modelName;
    else
        modelToUse=stm.internal.util.resolveHarness(modelName,harnessName);
    end


    if iscell(modelElement)&&~isempty(modelElement)
        modelElementToUse=modelElement{1};
    else
        modelElementToUse=modelElement;
    end



    splitStrings=strsplit(modelElementToUse,'/');
    usedModel=splitStrings{1};
    if~strcmp(usedModel,modelToUse)
        modelToUse=findModelToBeUsedForHighlight(usedModel,modelToUse);
    end

    if isempty(modelToUse)
        error(message('stm:SystemUnderTestView:CannotFindSignal'));
    end

    open_system(modelToUse);
    set_param(bdroot,'HiliteAncestors','off');
    if(isempty(sid)||str2double(sid)==0)
        if isRealtime
            modelElementToUse=locDemangleRealtimePath(modelElementToUse);
        end
        hilite_system(modelElementToUse,'find');
    else
        sidstr=[modelToUse,':',sid];
        Simulink.ID.hilite(sidstr);
    end
end

function bpath=locDemangleRealtimePath(bpath)


    els=regexp(bpath,'(?<!/)/(?!/)','split');

    tmppath=els{1};
    els(1)=[];

    try
        while true
            tmppath=[tmppath,'/',els{1}];%#ok<AGROW>
            els(1)=[];
            if isempty(els)
                bpath=tmppath;
                return
            elseif strcmp(get_param(tmppath,'BlockType'),'ModelReference')
                tmppath=get_param(tmppath,'ModelName');
                load_system(tmppath);
            end
        end
    catch

    end
end

function modelToUse=findModelToBeUsedForHighlight(usedModel,topModel)
    modelToUse='';



    mdlRefs=find_mdlrefs(topModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    if any(find(strcmp(mdlRefs,usedModel)))
        modelToUse=usedModel;
    else

        load_system(topModel);
        obsMdls=Simulink.observer.internal.getObserverModelNamesInBD(get_param(topModel,'handle'));
        if any(find(strcmp(obsMdls,usedModel)))
            modelToUse=usedModel;
        else

            for indx=1:length(obsMdls)


                mdlRefs=find_mdlrefs(obsMdls{indx},'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                if~isempty(mdlRefs)&&any(find(strcmp(mdlRefs,usedModel)))
                    modelToUse=usedModel;
                    return;
                end
            end
        end
    end
end