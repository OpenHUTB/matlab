function result=isActionEnabled(this,actionId)
    result=true;
    switch(actionId)
    case{'Advisor::AcAssociateConfig','Advisor::AcRestoreDefaultConfig'}
        if isempty(this.maObj)
            result=false;
        else
            result=~isempty(this.maObj.ConfigFilePath);
        end
    otherwise
        result=true;
    end

end