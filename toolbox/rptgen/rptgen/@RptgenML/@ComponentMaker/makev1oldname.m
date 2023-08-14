function makev1oldname(h)




    if isempty(h.v1ClassName)
        return;

    end

    fid=h.openFile('v1oldname.m');

    fwrite(fid,sprintf('function n=v1oldname(h)\n%%V10LDNAME returns the name of the component in v1.x\n%%   STATIC\n'));

    h.writeHeader(fid);

    fwrite(fid,sprintf('n=''%s'';',h.v1ClassName));
    fclose(fid);

    h.viewFile('v1oldname.m');
