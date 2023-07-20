function type=checkMLFBType(objectId)




    type='';

    h=idToHandle(sfroot,objectId);
    if isa(h,'Stateflow.EMFunction')
        type='EMFunction';
    elseif isa(h,'Stateflow.EMChart')
        type='EMChart';
    elseif isempty(h)
        try
            chartId=sf('get',objectId,'.chart');
            h=idToHandle(sfroot,chartId);
            if isa(h,'Stateflow.EMChart')
                type='EMChart';
            end
        catch ME
            warning([ME.identifier,':',ME.message]);
        end
    end
