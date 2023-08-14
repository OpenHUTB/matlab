function[mdlCode,supportCode]=getGeneratedCodeList(mdlName,buildDir,ext)






    mdlCode={};
    supportCode={};

    try
        src=rtwprivate('rtwfindfile',buildDir,ext);
    catch
        return
    end

    for i=1:length(src)
        [p,fileName]=fileparts(src{i});
        if strncmpi(fileName,mdlName,length(mdlName))
            mdlCode=[mdlCode;src{i}];
        else
            supportCode=[supportCode;src{i}];
        end
    end


