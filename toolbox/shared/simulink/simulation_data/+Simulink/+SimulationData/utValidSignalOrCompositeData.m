function isValid=utValidSignalOrCompositeData(obj,varargin)











    persistent skip_validation
    if isempty(skip_validation)
        skip_validation=false;
    end
    if nargin>1
        skip_validation=varargin{1};
        isValid=true;
        return
    end
    if skip_validation
        isValid=true;
        return
    end


    if isa(obj,'timeseries')
        isValid=true;
        return;
    end

    if isa(obj,'timetable')
        isValid=true;
        return;
    end

    if isa(obj,'cell')
        for ndx=1:numel(obj)
            if~isa(obj{ndx},'timetable')
                isValid=false;
                return;
            end
        end
        isValid=true;
        return;
    end

    if isa(obj,'matlab.io.datastore.TabularDatastore')
        isValid=true;
        return;
    end


    if isempty(obj)
        isValid=true;
        return;
    end


    if~isstruct(obj)
        isValid=false;
        return;
    end


    isValid=true;
    fields=fieldnames(obj);
    for idxArray=1:numel(obj)
        for idx=1:length(fields)
            f=obj(idxArray).(fields{idx});
            if(~Simulink.SimulationData.utValidSignalOrCompositeData(f))
                isValid=false;
                return;
            end
        end
    end

end

