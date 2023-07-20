function out=getSharedUtilsMap(aObj)





    try

        sharedFile=[aObj.getSharedUtilsFolder(),filesep...
        ,slci.Configuration.cSharedUtilityFile];

        sharedUtilsObj=SharedCodeManager.SharedUtilityInterface(sharedFile);
        allData=sharedUtilsObj.retrieveAllData('SCM_UTILITIES');
        out=containers.Map();

        for i=1:numel(allData)
            out(allData{i}.NameWithEncodings)=allData{i}.Identifier;
        end
    catch Exception %#ok
        assert(true,'Could not retrieve shared file database.');
    end
end
