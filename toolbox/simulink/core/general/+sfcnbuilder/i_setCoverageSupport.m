function dataStruct=i_setCoverageSupport(dataStruct,val)

    if isfield(dataStruct,'SupportCoverage')
        dataStruct.SupportCoverage=val;
    end
end