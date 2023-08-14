function setInstance(fid,ip_name,pv_pairs)
    for i=1:2:numel(pv_pairs)
        fprintf(fid,'set_property -dict [list CONFIG.%s {%s}] $%s\n',pv_pairs{i},pv_pairs{i+1},ip_name);
    end
end