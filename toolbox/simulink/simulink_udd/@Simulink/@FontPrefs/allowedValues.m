function[faces,sizes,nsizes]=allowedValues(~)











    assert(matlab.ui.internal.hasDisplay);

    faces=MG2.Font.getInstalledFontNames;


    sizes={'8','9','10','12','14','18','24','36','48'};
    nsizes=[8,9,10,12,14,18,24,36,48];


