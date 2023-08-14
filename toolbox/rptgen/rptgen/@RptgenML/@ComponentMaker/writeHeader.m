function writeHeader(h,fid)




    if(h.isWriteHeader)
        currDate=datevec(now);
        fwrite(fid,sprintf(['\n\n',...
        '%%   Copyright 1999-%0.4i The MathWorks, Inc.\n',...
        '%%     \n\n'],...
        currDate(1)));
    end
    fprintf(fid,'\n%% Method for Report Generator component class "%s.%s"\n\n%%--------1---------2---------3---------4---------5---------6---------7---------8\n\n',...
    h.PkgName,h.ClassName);
