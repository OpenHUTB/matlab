function[slHs,sfHs,crossDomainItems]=getHandlesWithRequirements(model,filterSettings)

    if ischar(model)
        modelName=model;
        modelH=rmisl.getmodelh(model);
    else
        modelH=model;
        modelName=get_param(modelH,'Name');
    end

    if nargin<2
        filterSettings=rmi.settings_mgr('get','filterSettings');
    end

    if rmidata.isExternal(modelH)
        [slHs,sfHs]=rmidata.getLinkedHandles(modelH,filterSettings);
        crossDomainItems=slreq.utils.getIDsForLinkedText(modelName,filterSettings);
    else
        [slAllHs,sfAllHs,slFlags,sfFlags,indirectObjHs]=rmisl.getAllObjectsAndRmiFlags(modelH,filterSettings);
        slHs=slAllHs(slFlags);
        sfHs=sfAllHs(sfFlags);

        if nargout==3
            crossDomainItems={};

            if~rmisf.isStateflowLoaded()
                return;
            end

            if isempty(indirectObjHs)
                return;
            end

            sfRoot=Stateflow.Root;
            for i=1:length(indirectObjHs)
                if floor(indirectObjHs(i))<indirectObjHs(i)
                    chartObj=sf('Private','block2chart',indirectObjHs(i));
                else
                    chartObj=indirectObjHs(i);
                end
                if~isempty(sfRoot)&&~isempty(chartObj)&&chartObj~=0
                    key=Simulink.ID.getSID(sfRoot.idToHandle(chartObj));
                    if rmiml.hasLinks(key)
                        crossDomainItems{end+1}=key;%#ok<AGROW>
                        isIncluded=(sfHs==chartObj);
                        if any(isIncluded)&&isempty(rmi.getReqs(chartObj))
                            sfHs(isIncluded)=[];
                        end
                    end
                end
            end
        end
    end
end
