function asap2SetAddressELFDwarfPrivate(ASAP2File,ELFFile,db,addrPrefix,addrSuffix)



















    a2lText=fileread(ASAP2File);







    missingSymbolList={};
    invalidAddressList={};
    repfun=@(name)loc_getSymbolValForName(name);%#ok<NASGU>
    newA2LText=regexprep(a2lText,[addrPrefix,'(\S+)',addrSuffix],...
    '0x${repfun($1)}');


    if~isempty(invalidAddressList)
        DAStudio.error('RTW:asap2:SymbolAddressExceedsLimit',strjoin(invalidAddressList,', '));
    end


    if~isempty(missingSymbolList)
        MSLDiagnostic('RTW:asap2:NoSymbolInTable',strjoin(missingSymbolList,', '),'ELF',ELFFile).reportAsWarning;
    end


    fid=fopen(ASAP2File,'w');
    fprintf(fid,'%s',newA2LText);
    fclose(fid);


    function hexaddr=loc_getSymbolValForName(name)
        try

            rec=db.describeSymbol(name);
            hexaddr=dec2hex(rec.address,8);
            if rec.address>0xFFFFFFFF
                invalidAddressList{end+1}=name;
            end
        catch

            hexaddr=['0000 /* @ECU_Address@',name,'@ */'];
            missingSymbolList{end+1}=name;
        end
    end

end


