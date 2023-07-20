function rec=createBlockConstraintCheck(checkID,varargin)




    checkID=convertStringsToChars(checkID);

    if~ischar(checkID)
        DAStudio.error('Advisor:engine:NonStringPropertyName');
    end


    Simulink.DDUX.logData('CHECK_AUTHORING','checkauthoring','BlockConstraint');
    rec=ModelAdvisor.BlockConstraintCheck(checkID,varargin{:});

end
