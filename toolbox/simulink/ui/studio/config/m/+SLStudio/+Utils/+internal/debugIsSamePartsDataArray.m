function res=debugIsSamePartsDataArray(inOld,inNew,inCategory)





    res=true;
    if isempty(inOld)&&isempty(inNew)
        return
    end
    if isempty(inOld)~=isempty(inNew)
        disp(sprintf('debugIsSamePartsDataArray with %s category. One empty, one not. old: %d, new: %d',inCategory,isempty(inOld),isempty(inNew)));%#ok<DSPS>
    else
        if length(inOld)~=length(inNew)
            disp(sprintf('debugIsSamePartsDataArray wrong size category: %s - old: %d   new: %d',inCategory,length(inOld),length(inNew)));%#ok<DSPS>
        else
            for i=1:length(inOld)
                a=inOld(i);
                b=inNew(i);
                if(a~=b)
                    res=false;
                    disp(sprintf('debugIsSamePartsDataArray (%s): old: %d, new: %d',inCategory,length(inOld),length(inNew)));%#ok<DSPS>
                    return
                end
            end
        end
    end
end
