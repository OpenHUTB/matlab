function addConnections(fid,hbuild)
    fprintf(fid,'# Add connections\n');

    conn=hbuild.Connections;

    extIO={hbuild.ExternalIO.name};
    for i=1:2:numel(conn)
        if any(strcmpi(conn{i},extIO))
            fprintf(fid,'set_interface_property %s EXPORT_OF %s\n\n',conn{i},conn{i+1});
        elseif any(strcmpi(conn{i+1},extIO))
            fprintf(fid,'set_interface_property %s EXPORT_OF %s\n\n',conn{i+1},conn{i});
        elseif contains(conn{i+1},'master','IgnoreCase',true)
            fprintf(fid,'add_connection %s %s\n\n',conn{i+1},conn{i});
        else
            fprintf(fid,'add_connection %s %s\n\n',conn{i},conn{i+1});
        end
    end
end