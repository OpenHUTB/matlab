function copyResources(obj)





    css_file='rtwreport.css';
    resourcesBuild={'rtwhilite.js',css_file,'search.js','rtwreport_utils.js','hilite_warning.png','rtwmsg.html',...
    'nav.html','navToolbar.html','inspect.html'};
    resourceDir=Simulink.report.ReportInfo.getResourceDir;

    coder.report.ReportInfoBase.copyFiles(resourceDir,resourcesBuild,obj.getReportDir);

    sharedResources={'rtwshrink.js'};
    sharedResourcesDir=fullfile(matlabroot,'toolbox','shared','codergui','web','resources');
    coder.report.ReportInfoBase.copyFiles(sharedResourcesDir,sharedResources,obj.getReportDir);

    if isunix&&~ismac
        fid=fopen(fullfile(obj.getReportDir,css_file),'a');
        fprintf(fid,'\npre#RTWcode {\n');
        fprintf(fid,'  font-family: Courier;\n');
        fprintf(fid,'}\n');
        fclose(fid);
    elseif ispc
        try
            encoding=get_param(obj.getActiveModelName,'SavedCharacterEncoding');
            lang=get(0,'language');




            if strcmpi(encoding,'Shift_JIS')||strncmp(lang,'ja',2)
                fid=fopen(fullfile(obj.getReportDir,css_file),'a');
                fprintf(fid,'\npre#RTWcode {\n');
                fprintf(fid,'  font-family: "MS Gothic";\n');
                fprintf(fid,'}\n');
                fclose(fid);
            end
        catch me %#ok

        end
    end
    sharedUtil=~isempty(obj.GenUtilsPath)&&~strcmp(obj.GenUtilsPath,obj.BuildDirectory);
    if(sharedUtil)
        resourcesShared={css_file,'rtwreport_utils.js','nav.html','navToolbar.html','inspect.html'};

        coder.report.ReportInfoBase.copyFiles(obj.getReportDir,resourcesShared,fullfile(obj.GenUtilsPath,'html'));
    end
end
