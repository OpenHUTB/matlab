function registerAdaptor(reg,AdaptorDefinition)




    if isempty(AdaptorDefinition)

        return;
    end

    if(isa(AdaptorDefinition,'function_handle'))
        addAdaptor(reg,AdaptorDefinition);
    else

        AdaptorFiles=cellstr(AdaptorDefinition);

        for i=1:length(AdaptorFiles)
            addAdaptor(reg,AdaptorFiles{i});
        end

    end


    function addAdaptor(reg,AdaptorFile)
        if(~isa(AdaptorFile,'function_handle'))

            if~exist(AdaptorFile,'file')
                return;
            end
        end


        if isAdaptorRegistered(reg,AdaptorFile)
            return;
        end



        Adaptor=loadAdaptor(reg,AdaptorFile);


        len=length(reg.Toolchains);
        reg.Toolchains(len+1).Adaptor=Adaptor;
