function addPreTcl(fid,included_tcl)
    for i=1:numel(included_tcl)
        fprintf(fid,'source %s\n',included_tcl{i});
    end
end