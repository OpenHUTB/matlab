function asap2SetAddressELFSymtabPrivate(ASAP2File,ELFFile,addrPrefix,addrSuffix)



















    a2lText=fileread(ASAP2File);


    try
        esa=rtw.esa.ESA(ELFFile);
    catch ME1
        if strcmp(ME1.identifier,'RTW:asap2:FileNotELF')
            DAStudio.error('RTW:asap2:FileNotELF',ELFFile);
        else
            DAStudio.error('RTW:asap2:UnableAnalyzeFile',ELFFile);
        end
    end

    try

        symtab=esa.getSymbolTable;
    catch ME2
        DAStudio.error('RTW:asap2:UnableAnalyzeFile',ELFFile);
    end






    invalidAddressList={};
    repfun=@(name)loc_getSymbolValForName(name);%#ok<NASGU>
    newA2LText=regexprep(a2lText,[addrPrefix,'(\w+)',addrSuffix],...
    '0x${repfun($1)}');


    if~isempty(invalidAddressList)
        DAStudio.error('RTW:asap2:SymbolAddressExceedsLimit',strjoin(invalidAddressList,', '));
    end


    fid=fopen(ASAP2File,'w');
    fprintf(fid,'%s',newA2LText);
    fclose(fid);

    function hexaddr=loc_getSymbolValForName(name)
        try

            hexaddr=rtw.esa.ESA.getSymbolValForName(symtab,name);
            if hex2dec(hexaddr)>0xFFFFFFFF
                invalidAddressList{end+1}=name;
            end
        catch

            hexaddr=['0000 /* @ECU_Address@',name,'@ */'];
            MSLDiagnostic('RTW:asap2:NoSymbolInTable',name,'ELF',ELFFile).reportAsWarning;
        end
    end

end


