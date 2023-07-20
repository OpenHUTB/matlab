function[summary,summline,needSymOptim,headHorz,headVert]=summaryofCoeffs(this)





    coeffs=this.Coefficients;

    total=length(coeffs);
    nzeros=total-length(find(coeffs));

    halflen=ceil(total/2);
    symms=floor(total/2);
    effective=length(find(coeffs(1:halflen)));

    summary=[total,nzeros,symms,effective];
    headHorz={'Total Coefficients','Zeros','A/Symm','Effective'};
    headVert={};

    summline=['\n',getString(message('HDLShared:hdlfilter:codegenmessage:flenserial',effective))];

    needSymOptim=0;



