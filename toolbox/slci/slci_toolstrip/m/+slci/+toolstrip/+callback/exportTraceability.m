


function exportTraceability(cbinfo)
    try
        configObj=slci.toolstrip.util.getConfiguration(cbinfo.studio);
    catch ME
        slci.internal.outputMessage(ME,'error');
        return;
    end


    configObj.ComputeDerivedCodeFolder();
    buildDir=configObj.getDerivedCodeFolder();
    build_info_file=fullfile(buildDir,'buildInfo.mat');
    if~exist(build_info_file,'file')
        DAStudio.error('Slci:report:MissingBuildInfo');
    end

    [file_name,file_path]=uiputfile('*.xls','Choose excel file to export');
    if ischar(file_name)

        slci.ExportTraceReport(configObj,file_name,file_path);
    end
end
