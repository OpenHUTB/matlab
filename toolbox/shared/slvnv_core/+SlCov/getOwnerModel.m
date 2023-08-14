



function ownerH=getOwnerModel(cvId)

    try
        owner_name=cv('get',cvId,'.ownerModel');
        if~isempty(owner_name)
            ownerH=get_param(owner_name,'Handle');
        else
            ownerH=0;
        end
    catch
        ownerH=0;
    end