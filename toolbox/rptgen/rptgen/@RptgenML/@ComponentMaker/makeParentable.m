function makeParentable(thisCM)




    fid=thisCM.openFile('getParentable.m');

    fprintf(fid,'function p = getParentable(thisComp)\n%%GETPARENTABLE tells whether or not the component can have children\n');

    thisCM.writeHeader(fid);

    if thisCM.Parentable
        fprintf(fid,'p = true;\n');
    else
        fprintf(fid,'p = false;\n');
    end

    fclose(fid);

    thisCM.viewFile('getParentable.m',2);
