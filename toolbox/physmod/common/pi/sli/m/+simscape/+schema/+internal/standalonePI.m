function res=standalonePI(setting)




    envID="SIMSCAPE_STANDALONE_PI";
    featureID='SimscapeLegacyDialog';

    slStarted=isSimulinkStarted();

    if slStarted
        res=slfeature(featureID)==0;
    else
        p=getenv(envID);
        res=isempty(p)||strcmp(p,'1');
    end


    if nargin>0
        if slStarted
            val=0;
            if~setting
                val=1;
            end
            slfeature('SimscapeLegacyDialog',val);
        else
            val='1';
            if~setting
                val='0';
            end
            setenv(envID,val);
        end
    end

end
