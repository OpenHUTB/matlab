function generateQsysTclInterfaceDefinition(fid,interface,dirMode,type,proplist,portlist)




    if dirMode==hdlturnkey.IOType.IN
        interfaceMode='end';
    else
        interfaceMode='start';
    end

    fprintf(fid,'# connection point %s\n',interface);
    fprintf(fid,'add_interface %s %s %s\n',interface,type,interfaceMode);
    for ii=1:numel(proplist)
        thisProp=proplist{ii};
        fprintf(fid,'set_interface_property %s',interface);
        for jj=1:numel(thisProp)
            fprintf(fid,' %s',thisProp{jj});
        end
        fprintf(fid,'\n');
    end
    for ii=1:numel(portlist)
        thisPort=portlist{ii};
        fprintf(fid,'add_interface_port %s',interface);
        for jj=1:numel(thisPort)
            fprintf(fid,' %s',thisPort{jj});
        end
        fprintf(fid,'\n');
    end
    fprintf(fid,'\n');

end
