function[summary,summline,needSymOptim,headHorz,headVert]=summaryofCoeffs(this)





    coeffs=this.Coefficients;
    total=length(coeffs);
    nzeros=total-length(find(coeffs));

    effective=total-nzeros;
    summary=[total,nzeros,effective];
    headHorz={'Total Coefficients','Zeros','Effective'};
    headVert={};
    summline=['\n',getString(message('HDLShared:hdlfilter:codegenmessage:flenserial',effective))];


    needSymOptim=0;

