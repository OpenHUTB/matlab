function[summary,summline,needSymOptim,headHorz,headVert]=summaryofCoeffs(this)





    coeffs=this.Polyphasecoefficients;
    summary=zeros(size(coeffs,1),5);
    for n=1:size(coeffs,1)
        c=coeffs(n,:);
        total=length(c);
        nzeros=total-length(find(c));
        indxpowerof2=ispowerof2(c);
        powerof2=length(find(indxpowerof2));
        c(find(indxpowerof2))=0;
        c=abs(c);
        c=c(c~=0);
        effective=length(unique(c));
        symms=length(c)-effective;
        effective=total-nzeros-powerof2-symms;
        summary(n,:)=[total,nzeros,powerof2,symms,effective];
    end



    effectivelens=summary(:,end);
    maxpolylen=max(effectivelens);
    symmsnums=summary(:,end-1);
    indx_symms=find(summary(:,end-1));
    effLensforSymmPP=effectivelens(indx_symms);







    needSymOptim=any(effLensforSymmPP==maxpolylen)||...
    any(effLensforSymmPP+symmsnums(indx_symms)>maxpolylen);


    headHorz={'Coefficients','Total','Zeros','^2s','A/Symm','Effective'};
    ratechangefactor=this.phases;
    for n=1:ratechangefactor
        headVert{n}=getString(message('HDLShared:hdlfilter:codegenmessage:polyphasenum',...
        n));%#ok<AGROW> %['Polyphase # ', num2str(n)];
    end
    summline=['\n',getString(message('HDLShared:hdlfilter:codegenmessage:polyflenserial',...
    maxpolylen))];


    function pwr2=ispowerof2(coeffs)

        pwr2=zeros(1,length(coeffs));
        for n=1:length(coeffs)
            pwr2(n)=hdlispowerof2(coeffs(n));
        end




