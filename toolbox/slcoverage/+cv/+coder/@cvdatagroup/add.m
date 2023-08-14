function this=add(this,cvd)




    narginchk(2,2);
    validateattributes(cvd,{'cv.coder.cvdata'},{'nonempty'},2);
    checkId(cvd);

    name=cvd.moduleinfo.name;
    name=SlCov.CoverageAPI.mangleModelcovName(name,cvd.simMode,cvd.dbVersion);
    this.m_data(name)=cvd;
