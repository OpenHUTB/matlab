function addPort(fid,port_name,port_dir,port_type,port_width)



    if(nargin<4)
        typeStr='';
    else
        typeStr=sprintf('-type %s ',port_type);
    end

    if(nargin<5)
        vecStr='';
    else
        vecStr=sprintf('-from %d -to 0',port_width-1);
    end

    fprintf(fid,'create_bd_port -dir %s %s %s %s\n',...
    upper(port_dir),typeStr,vecStr,port_name);
end
