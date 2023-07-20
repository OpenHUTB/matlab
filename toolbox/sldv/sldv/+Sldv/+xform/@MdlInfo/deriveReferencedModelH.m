function refmodelH=deriveReferencedModelH(obj,mdlBlkH)




    referencedModelName=get_param(mdlBlkH,'ModelName');
    try
        refmodelH=get_param(referencedModelName,'Handle');
    catch Mex %#ok<NASGU>
        refmodelH=[];
    end
    if isempty(refmodelH)
        Sldv.load_system(referencedModelName);
        obj.MdlsLoadedForMdlRefTree{end+1}=referencedModelName;
        refmodelH=get_param(referencedModelName,'Handle');
    end
end