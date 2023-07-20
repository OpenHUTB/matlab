

function out=getMappingDirection(this,mfMapping)






    if~isempty(mfMapping)
        out=mfMapping.getDirection();
    else

        out=slreq.datamodel.MappingDirectionEnum.Unknown;
    end
end