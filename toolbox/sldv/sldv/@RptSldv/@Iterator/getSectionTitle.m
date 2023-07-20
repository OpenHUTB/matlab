function title=getSectionTitle(c,objID)




    title='';
    try
        tt=evalin('base',c.SectionTitle);
        if~isempty(tt)&&isfield(objID,'idx')
            idx=objID.idx;
            if isstruct(tt)&&ischar(idx)
                title=getfield(tt,idx)
            elseif iscell(tt)
                title=tt{idx};
            else
                title=tt(idx);
            end
        end
    catch
    end

