function buildCodeInfoTable(aObj)






    if Simulink.internal.useFindSystemVariantsMatchFilter()



        sub_model_names=find_mdlrefs(aObj.getModelName(),'AllLevels',false,...
        'MatchFilter',@Simulink.match.codeCompileVariants);
    else
        sub_model_names=find_mdlrefs(aObj.getModelName(),false);
    end


    top_mdl_name=sub_model_names{end};
    top_mdl_code_folder=aObj.getDerivedCodeFolder();
    if aObj.fTopModel
        codeinfo_name='codeInfo.mat';
    else
        codeinfo_name=[top_mdl_name,'_mr_codeInfo.mat'];
    end
    extract(aObj,top_mdl_code_folder,codeinfo_name,top_mdl_name);


    for i=1:numel(sub_model_names)-1
        sub_mdl_name=sub_model_names{i};

        sub_mdl_code_folder=aObj.ChildModelFolder(sub_mdl_name);

        codeinfo_name=[sub_mdl_name,'_mr_codeInfo.mat'];

        extract(aObj,sub_mdl_code_folder,codeinfo_name,sub_mdl_name);
    end
end

function extract(aObj,codeinfo_folder,codeinfo_name,mdl_name)
    slci_codeinfo_name=[mdl_name,'_SLCIcodeInfo.mat'];
    SLCICodeInfo=slci.internal.extractCodeInfo(...
    codeinfo_folder,...
    codeinfo_name,...
    mdl_name,...
    slci_codeinfo_name,...
    aObj.getVerbose(),...
    get_param(getModelName(aObj),'SystemTargetFile'));

    aObj.fCodeInfoTable(mdl_name)=SLCICodeInfo;
end


