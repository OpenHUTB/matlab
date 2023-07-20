function setChecksumFirstTime(obj,cvdatas)






    allModelNames=find_mdlrefs(obj.topModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    for idx0=1:numel(allModelNames)
        modelName=allModelNames{idx0};
        for idx=1:numel(cvdatas)
            cvd=cvdatas{idx}{2};
            if isa(cvd,'cv.cvdatagroup')
                allNames=cvd.allNames;
                for ii=1:numel(allNames)
                    cn=allNames{ii};
                    ccvds=cvd.get(cn);

                    for idx1=1:numel(ccvds)
                        ccvd=ccvds(idx1);
                        if any(contains(allModelNames,cn))||...
                            ccvd.isExternalMATLABFile||...
                            ccvd.isSimulinkCustomCode||...
                            ccvd.isSharedUtility||...
                            ccvd.isCustomCode
                            addChecksum(obj,cn,ccvd);
                        end
                    end
                end
            else
                mn='';
                if isequal(modelName,cvd.modelinfo.analyzedModel)
                    mn=modelName;
                elseif isequal(modelName,cvd.modelinfo.ownerModel)
                    mn=cvd.modelinfo.ownerBlock;
                end
                if~isempty(mn)
                    addChecksum(obj,modelName,cvd);
                end
            end
        end
    end
end