function obj=setChecksum(topModelName,cvdIn)




    obj=cvi.ResultsExplorer.ResultsExplorer.findExistingDlg(topModelName);
    if~isempty(obj)
        obj.removeInvalidData();
        if isa(cvdIn,'cv.cvdatagroup')
            cvd=cvdIn.getAll;
            modelNames=cvdIn.allNames;
        else
            cvd={cvdIn};
            modelNames={topModelName};
        end
        rid=false;
        for idx=1:numel(cvd)
            for ii=1:numel(cvd{idx})
                ccvd=cvd{idx}(ii);
                cmn=modelNames{idx};

                if isequal(ccvd.modelinfo.ownerModel,cmn)
                    trid=addChecksum(obj,ccvd.modelinfo.ownerBlock,ccvd);
                else
                    trid=addChecksum(obj,cmn,ccvd);
                end
                rid=rid||trid;
            end
        end
        if rid
            removeIncompatibleData(obj);
        end
    end

end