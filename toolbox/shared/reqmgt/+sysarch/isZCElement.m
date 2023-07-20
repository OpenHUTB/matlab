function result=isZCElement(iZCIdentifier)

    result=false;
    if(~isempty(iZCIdentifier)&&ischar(iZCIdentifier))
        parts=strsplit(iZCIdentifier,':');
        if(isequal(numel(parts),2)&&strcmp(parts{1},'ZC'))
            result=true;
        end
    end
end

