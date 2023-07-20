%#codegen



function[Exp,MantRounded]=rounding_normals(Exp,MantExtended,sticky)




    coder.allowpcode('plain');


    Mant_tmp=bitconcat(fi(0,0,1,0),MantExtended);

    if(bitget(Mant_tmp,1)~=0)&&((bitget(Mant_tmp,2)~=0)||sticky)
        Mant_tmp(:)=Mant_tmp+cast(2,'like',Mant_tmp);
    end

    if(bitget(Mant_tmp,Mant_tmp.WordLength)~=0)

        Exp(:)=Exp+cast(1,'like',Exp);
        MantRounded=fi(0,0,MantExtended.WordLength-1,0);
    else
        MantRounded=bitsliceget(Mant_tmp,Mant_tmp.WordLength-1,2);
    end

    if(Exp==0)
        MantRounded(:)=0;
    end
end