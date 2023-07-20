function cap=dsphdlmaskedcaps(blkh)




    cs_c=CapStruct('codegen','yes','');
    cs_p=CapStruct('production','no','');



    masktype=get_param(blkh,'MaskType');
    if strcmp(masktype(1:3),'CIC')
        cs_f=CapStruct('fixedptSgn','yes','');
    else
        cs_f=CapStruct('fixedpt','yes','');
    end

    cset=CapSet(cs_c,cs_p,cs_f);
    cap=Capabilities(cset);

end
