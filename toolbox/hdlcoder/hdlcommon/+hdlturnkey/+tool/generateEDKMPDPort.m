function generateEDKMPDPort(fid,portName,portWidth,portType)




    if portType==hdlturnkey.IOType.IN
        dirStr='DIR = I';
    else
        dirStr='DIR = O';
    end

    if portWidth==1
        vecStr='';
    else
        vecStr=sprintf(', VEC = [%d:0]',portWidth-1);
    end

    fprintf(fid,'PORT %s = "", %s%s\n',portName,dirStr,vecStr);

end

