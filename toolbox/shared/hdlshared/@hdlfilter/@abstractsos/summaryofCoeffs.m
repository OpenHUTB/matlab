function[summary,summline,needSymOptim,headHorz,headVert]=summaryofCoeffs(this)






    coeff_scale(:,1)=this.scaleValues;

    coeffs_num(:,:)=this.coefficients(:,1:3);

    coeffs_denum(:,:)=this.coefficients(:,5:6);

    [na,nb]=size(coeffs_num);

    [nc,nd]=size(coeffs_denum);

    total=length(coeff_scale)+(na*nb)+(nc*nd);

    zero_co_sc=length(find(coeff_scale));
    zero_co_num=length(find(coeffs_num));
    zero_co_denum=length(find(coeffs_denum));

    scoeff=length(coeff_scale);
    zscoeff=scoeff-zero_co_sc;
    numcoeff=(na*nb);
    znumcoeff=numcoeff-zero_co_num;
    denumcoeff=(nc*nd);
    zdenumcoeff=denumcoeff-zero_co_denum;


    nzeros=total-(zero_co_sc+zero_co_num+zero_co_denum);

    effective=total-nzeros;
    summary=[scoeff,zscoeff,numcoeff,znumcoeff,denumcoeff,zdenumcoeff,total,nzeros,effective];
    headHorz={'Scale Coeff','ZeScale Coeff','Num Coeff',...
    'ZeNum Coeff','Denum Coeff','ZeDenum Coeff','Total Coeff',...
    'Total Zeros','Effective'};
    headVert={};
    summline=['\n',getString(message('HDLShared:hdlfilter:codegenmessage:ffcoeff',effective))];


    needSymOptim=0;

