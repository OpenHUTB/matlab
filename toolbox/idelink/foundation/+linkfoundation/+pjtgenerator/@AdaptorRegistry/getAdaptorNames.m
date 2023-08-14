function[names,shortNames]=getAdaptorNames(reg)






    numToolchains=length(reg.Toolchains);
    names=cell(1,numToolchains);


    for i=1:length(reg.Toolchains)
        names{i}=reg.Toolchains(i).Adaptor.Name;
    end

    if nargout>1
        shortNames=cell(1,numToolchains);
        for i=1:length(reg.Toolchains)
            shortNames{i}=reg.Toolchains(i).Adaptor.ShortName;
        end
    end

end

