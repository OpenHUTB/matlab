%#codegen
function[corrected_z,corrected_d]=hdleml_divide_preCorrection(z,d,z_MSB,d_MSB,in1Type,in2Type,out1Type,out2Type)



    coder.allowpcode('plain')
    eml_prefer_const(in1Type);
    eml_prefer_const(in2Type);
    eml_prefer_const(out1Type);
    eml_prefer_const(out2Type);
    zFimath=eml_al_div_fimath(out1Type);
    dFimath=eml_al_div_fimath(out2Type);
    nt_z=numerictype(in1Type);
    nt_d=numerictype(in2Type);
    zWL=nt_z.WordLength;
    dWL=nt_d.WordLength;
    nt_corrected_z=numerictype(out1Type);
    nt_corrected_d=numerictype(out2Type);



    zNewType=numerictype(1,zWL+1,0);

    zNew=hdleml_dtc(z,zNewType,zFimath,2);


    if(z_MSB==1)
        zNewTemp=fi(-zNew,zNewType,zFimath);
    else
        zNewTemp=fi(zNew,zNewType,zFimath);
    end
    corrected_z=hdleml_dtc(zNewTemp,nt_corrected_z,zFimath,1);




    dNewType=numerictype(1,dWL+1,0);

    dNew=hdleml_dtc(d,dNewType,dFimath,2);


    if(d_MSB==1)
        dNewTemp=fi(-dNew,dNewType,dFimath);
    else
        dNewTemp=fi(dNew,dNewType,dFimath);
    end
    corrected_d=hdleml_dtc(dNewTemp,nt_corrected_d,dFimath,1);
end


function divFimath=eml_al_div_fimath(y_in)

    if isfloat(y_in)


        eml_assert(0);
    else
        y_inType=numerictype(y_in);


        divFimath=fimath(...
        'ProductMode','SpecifyPrecision',...
        'ProductWordLength',y_inType.WordLength,...
        'ProductFractionLength',y_inType.FractionLength,...
        'SumMode','SpecifyPrecision',...
        'SumWordLength',y_inType.WordLength,...
        'SumFractionLength',y_inType.FractionLength,...
        'RoundMode','floor',...
        'OverflowMode','wrap');
    end
end
function y=hdleml_dtc(u,nt,dsfimath,mode)
    if(mode==2)
        nt_u=numerictype(u);
        nt_new=numerictype(nt.SignednessBool,nt.WordLength,nt_u.FractionLength);
        ut=fi(u,nt_new,dsfimath);
        y=eml_reinterpret(ut,nt);
    else
        y=fi(u,nt,dsfimath);
    end
end


