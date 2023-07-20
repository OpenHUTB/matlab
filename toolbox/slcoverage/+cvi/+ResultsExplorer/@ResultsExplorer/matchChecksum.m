function[res,partial]=matchChecksum(obj,cvd)




    res=[];
    partial=false;
    if isa(cvd,'cv.cvdatagroup')
        newcvdg=cv.cvdatagroup;
        an=cvd.allNames;
        for idx=1:numel(an)
            cn=an{idx};
            ccvd=cvd.get(cn);

            for ii=1:numel(ccvd)
                if compareChecksum(obj,ccvd(ii),cn)
                    newcvdg.add(ccvd(ii));
                else
                    partial=true;
                end
            end
        end
        if isempty(newcvdg.allNames)
            res=[];
        elseif numel(newcvdg.allNames('Mixed'))==1
            res=newcvdg.getAll{1};
        else
            res=newcvdg;
        end
    else
        if compareChecksum(obj,cvd,cvd.modelinfo.analyzedModel)
            res=cvd;
        end
    end
end