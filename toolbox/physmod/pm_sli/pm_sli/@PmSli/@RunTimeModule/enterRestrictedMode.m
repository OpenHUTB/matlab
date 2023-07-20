function success=enterRestrictedMode(this,hModel)







    success=false;

    if isempty(this.getModelBlockSnapshots(hModel))




        success=this.storeModelSnapshot(hModel);

    end

end


