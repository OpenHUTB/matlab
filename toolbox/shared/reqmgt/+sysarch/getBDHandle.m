function bdHandle=getBDHandle(mdlName)

    load_system(mdlName);
    bdHandle=get_param(mdlName,'handle');
end

