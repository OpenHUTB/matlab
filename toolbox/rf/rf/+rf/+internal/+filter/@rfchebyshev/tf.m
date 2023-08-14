function[num,den]=tf(obj)




    num=cell(2);
    num{1,1}=polyGen(obj.designData.Numerator11);
    if strcmp(obj.ResponseType,'Bandstop')
        num{2,1}=polyGen(obj.designData.Auxiliary.Numerator21Polynomial);
    else
        num{2,1}=obj.designData.Auxiliary.Numerator21Polynomial;
    end
    num{1,2}=num{2,1};
    num{2,2}=polyGen(obj.designData.Numerator22);
    den=polyGen(obj.designData.Denominator);
end
