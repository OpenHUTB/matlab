function cap=visionhdlmaskedcaps(~)


    cs_c=CapStruct('codegen','yes','');
    cs_p=CapStruct('production','no','');
    cset=CapSet(cs_c,cs_p);
    cap=Capabilities(cset);

end
