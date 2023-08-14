function this=add(this,varargin)




    for idx=1:length(varargin)
        ccvt=varargin{idx};
        if isa(ccvt,'cvtest')
            cvt=ccvt;
        else
            cvt=cvtest(ccvt);
        end
        name=SlCov.CoverageAPI.getModelcovName(cvt.modelcov);
        this.m_data(name)=cvt.id;
    end
