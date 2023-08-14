function usrDefines=extractUserDefines(userDefinesTxt)





    usrDefines=[];
    if~isempty(userDefinesTxt)

        defs=regexp(userDefinesTxt,'(?:[-/]D\s*)?(\w+(=("[^"]*"|\w*))?)','tokens');
        usrDefines=[defs{:}];
    end


