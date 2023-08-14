function this=add(this,cvd)




    narginchk(2,2);
    validateattributes(cvd,{'cvdata'},{'nonempty'},2);

    checkId(cvd);
    cvdId=cvd.id;
    if cvdId~=0
        modelcovId=cv('get',cvdId,'testdata.modelcov');
    else
        modelcovId=cv('get',cvd.rootId,'.modelcov');
    end
    name=SlCov.CoverageAPI.getModelcovMangledName(modelcovId);
    this.m_data(name)=cvd;


