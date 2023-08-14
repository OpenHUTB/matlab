function res=isCovDataUsedBySlicer(varargin)




    res=false;
    try
        if nargin==1&&slfeature('UseSlCheckLicenseForSlicer')>0
            cvd=varargin{1};
            if isa(cvd,'cv.cvdatagroup')
                allCvds=cvd(1).getAll();
                model=allCvds{1}(1).modelinfo.analyzedModel;
            elseif isa(cvd,'cvdata')
                model=cvd(1).modelinfo.analyzedModel;
            else
                return;
            end
            res=SlCov.CoverageAPI.isCovToolUsedBySlicer(model);
        end
    catch
        res=false;
    end
end
