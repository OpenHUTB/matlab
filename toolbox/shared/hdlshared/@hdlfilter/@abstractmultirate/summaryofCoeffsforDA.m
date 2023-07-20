function[summary,summline]=summaryofCoeffsforDA(this)





    coeffs=this.Polyphasecoefficients;
    summary=zeros(size(coeffs,1),3);
    for n=1:size(coeffs,1)
        c=coeffs(n,:);
        total=length(c);
        nzeros=total-length(find(c));
        c=c(c~=0);
        effective=length(c);
        symms=length(c)-effective;
        effective=total-nzeros;
        summary(n,:)=[total,nzeros,effective];
    end



    effectivelens=summary(:,end);
    maxpolylen=max(effectivelens);

    summline=['\n',getString(message('HDLShared:hdlfilter:codegenmessage:polyflenserial',...
    maxpolylen))];





