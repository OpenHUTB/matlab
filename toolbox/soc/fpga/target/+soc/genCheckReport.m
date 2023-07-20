function genCheckReport(checkfpga_info,socsysinfo,folder)
    if~isfolder(folder)
        mkdir(folder);
    end

    startVer='2019';
    currVer=datestr(version('-date'),'YYYY');
    if strcmpi(startVer,currVer)
        copyRightYr=startVer;
    else
        copyRightYr=sprintf('%s-%s',startVer,currVer);
    end


    report_location=fullfile(folder,[socsysinfo.modelinfo.sys,'_validation_report.m']);
    fid=fopen(report_location,'w');
    fprintf(fid,'%%%% socBuilder Validation Report\n');
    fprintf(fid,'%% This report was automatically generated on %s by SoC Blockset.\n',datetime);
    fprintf(fid,'%%%%%% Model Information\n');
    fprintf(fid,'%% * Top model : %s\n',socsysinfo.modelinfo.sys);

    fprintf(fid,'\n');

    fprintf(fid,'%%%%%% FPGA Design Validation\n');
    fprintf(fid,'%%\n');

    if any([checkfpga_info.Status])
        fprintf(fid,'%% <html><table border=1>\n');
        for i=1:numel(checkfpga_info)
            this_check=checkfpga_info(i);
            if this_check.Status==1
                fprintf(fid,'%% <tr><td><font color=red>Error:</font></td>\n');
                fprintf(fid,'%% <td>%s</td/tr>\n',this_check.Message);
            elseif this_check.Status==2
                fprintf(fid,'%% <tr><td><font color=orange>Warning:</font></td>\n');
                fprintf(fid,'%% <td>%s</td/tr>\n',this_check.Message);
            end
        end
        fprintf(fid,'%% </table></html>\n');
        fprintf(fid,'%%\n');
    else
        fprintf(fid,'%% FPGA design validation was successful.\n');
    end

    fprintf(fid,'%%\n');
    fprintf(fid,'%% (C) %s The MathWorks, Inc.  All Rights Reserved.\n',copyRightYr);

    fclose(fid);


    publish(report_location,'evalCode',false);
    if isfile(report_location)
        delete(report_location);
    end

end