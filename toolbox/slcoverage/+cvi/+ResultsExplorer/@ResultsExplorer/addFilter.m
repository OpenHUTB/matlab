function addFilter(obj,cvd,isTmp,filterFileName)







    if nargin<3
        isTmp=false;
    end
    if nargin<4
        if obj.filterEditor.needSave


            filterFileName=obj.tempFilterFileName;
        else

            filterFileName=obj.filterEditor.fileName;
        end
    end
    if isTmp

        filterFileName=tempname;
    end
    ts=obj.filterEditor.needSave;
    obj.filterEditor.save(filterFileName);
    obj.filterEditor.needSave=ts;

    if obj.filterEditor.isEmpty
        filterFileName='';
    end
    if isa(cvd,'cv.cvdatagroup')
        allCvd=cvd.getAll('Mixed');
    else
        allCvd={cvd};
    end
    for idx=1:numel(allCvd)
        ccvd=allCvd{idx};
        ccvd.filter=filterFileName;
    end
end