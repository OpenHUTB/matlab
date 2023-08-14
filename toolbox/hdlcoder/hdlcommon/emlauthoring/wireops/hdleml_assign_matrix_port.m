%#codegen
function Y=hdleml_assign_matrix_port(OneBasedIdx,Y0,U,Idx,Idx2)


    coder.allowpcode('plain')
    eml_prefer_const(OneBasedIdx);

    if~isfloat(Idx)
        nt1=numerictype(Idx);
        fm1=fimath('SumMode','SpecifyPrecision',...
        'SumWordLength',nt1.WordLength,...
        'SumFractionLength',nt1.FractionLength);
    end
    if~isfloat(Idx2)
        nt2=numerictype(Idx2);
        fm2=fimath('SumMode','SpecifyPrecision',...
        'SumWordLength',nt2.WordLength,...
        'SumFractionLength',nt2.FractionLength);
    end

    Y=hdleml_define(Y0);
    sz=size(Y0);

    for jj=1:sz(2)
        for ii=1:sz(1)
            if OneBasedIdx
                constVal=ii;
                constVal2=jj;
            else
                constVal=ii-1;
                constVal2=jj-1;
            end

            if isfloat(Idx)
                constValTyped=constVal;
            else
                constValTyped=fi(constVal,nt1,fm1);
            end
            if isfloat(Idx2)
                constVal2Typed=constVal2;
            else
                constVal2Typed=fi(constVal2,nt2,fm2);
            end
            if Idx==constValTyped&&Idx2==constVal2Typed
                Y(ii,jj)=U;
            else
                Y(ii,jj)=Y0(ii,jj);
            end
        end
    end
end