function r=minus(p,q)




















    p=cvdata(p);
    q=cvdata(q);


    p.checkDataCompatibility(q);

    opFcn=@(x)((x(:,1)>0&x(:,2)==0).*x(:,1));
    out_metrics=perform_operation(p,q,opFcn,'-',[]);

    r=cvdata;
    r.createDerivedData(p,q,out_metrics,[]);

    r.sfcnCovData=SlCov.results.CodeCovDataGroup.performOp(p.sfcnCovData,q.sfcnCovData,'-');
    r.codeCovData=SlCov.results.CodeCovData.performOp(p.codeCovData,q.codeCovData,'-');
