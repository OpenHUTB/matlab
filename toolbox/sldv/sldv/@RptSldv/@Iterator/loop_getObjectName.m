function oName=loop_getObjectName(c,objID,ps)











    if isstruct(objID)&&isfield(objID,'descr')
        oName=objID.descr;
    elseif~isempty(ps)
        oName=ps.getObjectName(objID);

    end
