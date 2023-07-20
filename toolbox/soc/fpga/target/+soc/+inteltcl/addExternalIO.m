function addExternalIO(fid,hbuild)
    fprintf(fid,'# Add conduit IOs\n');
    for i=1:numel(hbuild.ExternalIO)
        fprintf(fid,'add_interface %s conduit end\n\n',hbuild.ExternalIO(i).name);
    end
end
