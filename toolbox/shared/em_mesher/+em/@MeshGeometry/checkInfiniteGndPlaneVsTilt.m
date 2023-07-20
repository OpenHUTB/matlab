function checkInfiniteGndPlaneVsTilt(obj,propVal)


    if isempty(obj.Tilt)
        return;
    end


    excludelist={'em.MonopoleAntenna','em.MicrostripAntenna',...
    'em.BackingStructure','helix','helixMultifilar','fractalSnowflake',...
    'monocone'};
    bool=cell2mat(cellfun(@(x)isa(obj,x),excludelist,'UniformOutput',false));
    if any(bool)
        if(propVal==inf&&obj.Tilt~=0)
            error(message('antenna:antennaerrors:Unsupported',...
            'Tilt','Infinite ground plane'));
        end
    end