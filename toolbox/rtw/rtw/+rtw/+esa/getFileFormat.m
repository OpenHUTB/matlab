function fileFormat=getFileFormat(FileName)











    first4bytes=memmapfile(FileName,...
    'format','uint8',...
    'repeat',4,...
    'offset',0);
    first4bytes=first4bytes.data;

    if(strcmpi(char(first4bytes'),rtw.esa.ELF.ELFMagicNumber))
        fileFormat='ELF';
    elseif all(first4bytes'==rtw.esa.MachO.MachOMagicNumber)
        fileFormat='Mach-O';
    else
        fileFormat='Unknown';
    end
end