function checkLicense(obj)
    [lic,~]=builtin('license','checkout','Matlab_Coder');
    if~lic
        DAStudio.error('RTW:report:MATLABCoderLicense');
    end
    [lic,~]=builtin('license','checkout','Real-Time_Workshop');
    if~lic
        DAStudio.error('RTW:report:SimulinkCoderLicense');
    end
    param=obj.getAll;
    if any(strcmp(param(2:end),'on'))
        [lic,~]=builtin('license','checkout','RTW_Embedded_Coder');
        if~lic
            DAStudio.error('RTW:report:EmbeddedCoderLicense');
        end
    end
end
