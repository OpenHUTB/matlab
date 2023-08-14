function[dcStamp,tleData]=mltle_getDCTleStamp(tleData)%#codegen




    n=tleData.nLines;
    Yother=zeros(n);
    Yself=zeros(n);
    if all(tleData.DCR==0)
        losslessFudge=1e7;
        if n==1



            Yself=losslessFudge*tleData.Yo{1}.D(1);
            Yother=losslessFudge*tleData.Yo{1}.D(1);
        else
            d=zeros(n);
            for i=1:n
                d(:,i)=tleData.Yo{i}.D;
            end
            Yself=losslessFudge*d;
            Yother=losslessFudge*d;
        end
    else
        Yother=tleData.DCR\((tleData.DCalphaV*diag(1./sinhc(tleData.DCalphaD)))/tleData.DCalphaV);
        Yself=Yother*((tleData.DCalphaV*diag(cosh(tleData.DCalphaD)))/tleData.DCalphaV);
    end
    incMat=[eye(n);-ones(1,n)];
    YselfExt=incMat*Yself*incMat';
    YotherExt=-incMat*Yother*incMat';
    dcStamp=[YselfExt,YotherExt;YotherExt,YselfExt];
    tleData.dcStamp=dcStamp;
end

function y=sinhc(x)

    y=(expm1(x)-expm1(-x))./(2*x);
    y(x==0)=1;
end
