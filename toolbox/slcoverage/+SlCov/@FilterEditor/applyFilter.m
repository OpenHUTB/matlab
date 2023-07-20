function[cvd,cvdc]=applyFilter(this)



    [cvd,cvdc]=cvresults(this.modelName);
    apply_filter(this,cvd);
    if~isempty(cvdc)
        apply_filter(this,cvdc);
    end

    function apply_filter(this,cvd)

        if~isempty(cvd)
            if isa(cvd,'cv.cvdatagroup')
                allCvd=cvd.getAll('Mixed');
            else
                allCvd={cvd};
            end
            for idx=1:numel(allCvd)
                allCvd{idx}.filter=this.fileName;
            end
        end