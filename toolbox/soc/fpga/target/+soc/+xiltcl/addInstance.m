function addInstance(fid,ip_name,vlnv)
    fprintf(fid,'set %s [create_bd_cell -vlnv %s %s]\n',ip_name,vlnv,ip_name);
end