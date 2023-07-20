%#codegen
function Y=hdleml_assign_vector_port(OneBasedIdx,Y0,U,Idx)


    coder.allowpcode('plain')
    eml_prefer_const(OneBasedIdx);

    if~isfloat(Idx)
        nt1=numerictype(Idx);
        fm1=fimath('SumMode','SpecifyPrecision',...
        'SumWordLength',nt1.WordLength,...
        'SumFractionLength',nt1.FractionLength);
    else
        nt1=[];
        fm1=[];
    end

    Y=hdleml_define(Y0);
    for i=1:length(Y0)
        if OneBasedIdx
            constVal=i;
        else
            constVal=i-1;
        end

        if isfloat(Idx)
            constValTyped=constVal;
        else
            constValTyped=fi(constVal,nt1,fm1);
        end
        if Idx==constValTyped
            Y(i)=U;
        else
            Y(i)=Y0(i);
        end
    end
end