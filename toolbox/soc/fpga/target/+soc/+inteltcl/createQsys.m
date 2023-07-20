function createQsys(fid,hbuild)



    fprintf(fid,'package require qsys\n');
    fprintf(fid,'create_system {system_top}\n');
    fprintf(fid,'set_project_property DEVICE_FAMILY {%s}\n',hbuild.Board.DeviceFamily);
    fprintf(fid,'set_project_property DEVICE {%s}\n',hbuild.Board.Device);
    fprintf(fid,'set_project_property HIDE_FROM_IP_CATALOG {false}\n\n');

end

