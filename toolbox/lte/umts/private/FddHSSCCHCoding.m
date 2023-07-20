


























































function[HsscchCodedBits,codingValues]=FddHSSCCHCoding(hsscchConfig)

    [HsscchCodedBits,codingValues]=fdd('HsscchEncoder',hsscchConfig);

    codingValues.X1=double(codingValues.X1);
    codingValues.X2=double(codingValues.X2);
    codingValues.Y=double(codingValues.Y);
    codingValues.Z1=double(codingValues.Z1);
    codingValues.Z2=double(codingValues.Z2);
    codingValues.R1=double(codingValues.R1);
    codingValues.R2=double(codingValues.R2);
    codingValues.S1=double(codingValues.S1);
end