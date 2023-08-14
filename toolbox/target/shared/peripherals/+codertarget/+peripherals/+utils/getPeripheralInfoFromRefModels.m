function[refMdls,blockPeripheralInfo,groupPeripheralInfo]=getPeripheralInfoFromRefModels(model)







    blockPeripheralInfo=[];
    groupPeripheralInfo=[];
    refMdls={};


    mdlRefs=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true,'ReturnTopModelAsLastElement',false);
    if isempty(mdlRefs)
        mdlRefs={model};
    end

    for i=1:numel(mdlRefs)
        pInfo=codertarget.data.getPeripheralInfo(mdlRefs{i});
        if~isempty(pInfo)
            types=fieldnames(pInfo);
            for j=1:numel(types)
                blockInfo=pInfo.(types{j}).Block;

                if~isfield(blockPeripheralInfo,types{j})
                    blockPeripheralInfo.(types{j})=blockInfo;
                    if~ismember(mdlRefs(i),refMdls)
                        refMdls(end+1)=mdlRefs(i);%#ok<AGROW>
                    end
                else
                    for k=1:numel(blockInfo)
                        blockPeripheralInfo.(types{j})(end+1)=blockInfo(k);
                    end
                    if~ismember(mdlRefs(i),refMdls)
                        refMdls(end+1)=mdlRefs(i);%#ok<AGROW>
                    end
                end

                if isfield(pInfo.(types{j}),'Group')
                    groupInfo=pInfo.(types{j}).Group;

                    if~isfield(groupPeripheralInfo,types{j})
                        groupPeripheralInfo.(types{j})=groupInfo;
                    end
                end
            end
        end
    end
end