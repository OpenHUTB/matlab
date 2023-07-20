function category=gethdllibcategory(blk)










    if strncmpi(blk,'dsp',3)
        blk=dsphdlshared.hdllib.dsphdllibpath(blk);
    elseif strncmpi(blk,'whdlutilities',13)||strncmpi(blk,'whdledac',8)||strncmpi(blk,'whdl',4)||strncmpi(blk,'whdlmod',7)
        blk=dsphdlshared.hdllib.whdllibpath(blk);
    elseif strncmpi(blk,'comm',4)
        blk=dsphdlshared.hdllib.commhdllibpath(blk);
    elseif strncmpi(blk,'visionhdl',9)
        blk=visionhdlsupport.internal.visionhdllibpath(blk);
    elseif strncmpi(blk,'hdlvideo',8)
        blk=hdlvideoblks.hdllibpath(blk);
    elseif strncmpi(blk,'hdldemolib/',11)
        blk=[hdldemolibcategory,'/',blk(12:end)];
    elseif strncmpi(blk,'hdldemolib_bitops/',18)
        blk=[hdldemolibcategory,'/Bit Operators/',blk(19:end)];
    elseif strncmpi(blk,'modelsimlib/',12)
        blk=[hdledalinklibcategory,'/',blk(13:end)];
    elseif strncmpi(blk,'eml_lib/',8)
        blk=['Simulink/User-Defined',newline,'Functions/',blk(9:end)];
    elseif strncmpi(blk,'sflib/',6)
        blk=['Stateflow/',blk(7:end)];
    elseif strncmpi(blk,'built-in/SubSystem',18)
        blk=['Simulink/Ports &',newline,'Subsystems/Subsystem'];
    elseif strncmpi(blk,'hdlsllib/',9)
        blk=blk(10:end);
    end



    idx_list=strfind(blk,'/');
    if~isempty(idx_list)
        category=blk(1:idx_list(end)-1);
        if isempty(category)
            category='Misc';
        end
    else
        category='Misc';
    end


    category(1)=upper(category(1));


