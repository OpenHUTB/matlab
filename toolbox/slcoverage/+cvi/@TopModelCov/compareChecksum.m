function[res,diff]=compareChecksum(newObj,oldObj)





    res=true;
    if cv('get','default','root.isa')==cv('get',newObj,'.isa')
        topSlsfNew=cv('get',newObj,'.topSlsf');
    else
        topSlsfNew=newObj;
    end
    if cv('get','default','root.isa')==cv('get',oldObj,'.isa')
        topSlsfOld=cv('get',oldObj,'.topSlsf');
    else
        topSlsfOld=oldObj;
    end

    if isequal(cv('get',topSlsfOld,'.cvChecksum'),...
        cv('get',topSlsfNew,'.cvChecksum'))
        return;
    end

    descsOld=[topSlsfOld,cv('DecendentsOf',topSlsfOld)];
    descsNew=[topSlsfNew,cv('DecendentsOf',topSlsfNew)];
    diff=[];
    for idx=1:numel(descsOld)
        blockOldCvId=descsOld(idx);
        blockNewCvId=descsNew(idx);
        old=cv('get',blockOldCvId,'.cvChecksum');
        new=cv('get',blockNewCvId,'.cvChecksum');
        if~isequal(old,new)
            tdf.name=getfullname(cv('get',blockNewCvId,'.handle'));
            tdf.newCvId=blockNewCvId;
            tdf.oldCvId=blockOldCvId;
            if isempty(diff)
                diff=tdf;
            else
                diff(end+1)=tdf;
            end
            res=false;
        end
    end
