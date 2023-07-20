function libpath=whdllibpath(blk)






    whdlblks=['Wireless HDL',newline,'Toolbox/'];

    whdlutilities='Utilities';
    whdlerrdetcorr=['Error Detection',newline,'and Correction'];
    whdlmoddemod='Modulation';

    if strncmpi(blk,'whdlutilities/',17)
        libpath=[whdlutilities,blk(17:end)];

    elseif strncmpi(blk,'whdledac/',11)
        libpath=[whdlerrdetcorr,blk(11:end)];

    elseif strncmpi(blk,'whdlmod/',10)
        libpath=[whdlmoddemod,blk(10:end)];


    else
        libpath='';
    end

    libpath=[whdlblks,libpath];

end

