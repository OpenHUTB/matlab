
function[result,objects]=hasMultipleDefaultTransitions(defaultTransitions)
    objects=[];
    result=true;

    if(size(defaultTransitions,1)<2)
        result=false;
        return;
    end


    objects=arrayfun(@(x)x.Destination,defaultTransitions,...
    'UniformOutput',false);

    if isempty(objects)
        result=false;
        return;
    end


    objectIds=arrayfun(@(x)x.Destination.Id,defaultTransitions);
    [~,unqIdx]=unique(objectIds,'stable');
    objects=objects(unqIdx);
end