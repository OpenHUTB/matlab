function data=serialize(~,dataObj,asVersion)






    if nargin<3

        asVersion='';
    else

        suportedVersions=slreq.utils.VersionHandler.getPreviousVersions();
        if~isempty(asVersion)&&~any(strcmp(asVersion,suportedVersions))
            error(['Invalid asVersion argument. Use '''' to get the current version.'...
            ,'Or use a previous release number such as ''R2017b''.']);
        end
    end





    if isa(dataObj,'slreq.data.DataModelObj')
        mfObj=dataObj.getModelObj();
    else
        mfObj=dataObj;
    end

    data=mfObj.serialize(asVersion);
end
