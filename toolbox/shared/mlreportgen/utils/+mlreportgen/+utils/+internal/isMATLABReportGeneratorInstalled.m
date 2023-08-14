function tf=isMATLABReportGeneratorInstalled()









    persistent IS_INSTALLED;

    if isempty(IS_INSTALLED)
        IS_INSTALLED=logical(license("test","MATLAB_Report_Gen"));
        if IS_INSTALLED
            pathOut=path();
            if ispc()
                delimiter=";";
            else
                delimiter=":";
            end
            IS_INSTALLED=IS_INSTALLED&&...
            contains(pathOut,fullfile(toolboxdir("rptgen"),"rptgen"+delimiter));
        end
    end

    tf=IS_INSTALLED;
end
