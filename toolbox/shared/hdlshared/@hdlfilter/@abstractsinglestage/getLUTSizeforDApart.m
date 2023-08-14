function[lutsize,lutsizestr]=getLUTSizeforDApart(this,dalutpart,coeffs)






    dalutpart=dalutpart(find(dalutpart));

    [~,coeffsvbp]=hdlgetsizesfromtype(this.CoeffSLType);
    coeffs_values=coeffs(find(coeffs~=0));
    strt=1;
    lutsize=zeros(1,length(dalutpart));
    lutwidths=zeros(1,length(dalutpart));
    lutsizestr={};
    for lutnum=1:length(dalutpart)
        coeffs4lut=coeffs_values(strt:strt+dalutpart(lutnum)-1);
        strt=strt+dalutpart(lutnum);
        lut_max=max(abs(sum(coeffs4lut(coeffs4lut<0))),sum(coeffs4lut(coeffs4lut>0)));
        lutwidths(lutnum)=ceil(log2(lut_max+2^(-1*coeffsvbp)))+coeffsvbp+1;
        lutsize(lutnum)=2^dalutpart(lutnum)*lutwidths(lutnum);
        lutsizestr=[lutsizestr,[num2str(2^dalutpart(lutnum)),'x',num2str(lutwidths(lutnum))]];
    end
    lutsize=sum(lutsize);


