function tf=isSimulinkReportGeneratorInstalled()










    persistent IS_SLRPTGEN_INSTALLED;

    if isempty(IS_SLRPTGEN_INSTALLED)
        IS_SLRPTGEN_INSTALLED=logical(license("test","SIMULINK_Report_Gen"));
        if IS_SLRPTGEN_INSTALLED
            pathOut=path();
            if ispc()
                delimiter=";";
            else
                delimiter=":";
            end
            IS_SLRPTGEN_INSTALLED=IS_SLRPTGEN_INSTALLED&&...
            contains(pathOut,fullfile(toolboxdir("rptgen"),"rptgen"+delimiter));
        end
    end

    tf=IS_SLRPTGEN_INSTALLED;
end