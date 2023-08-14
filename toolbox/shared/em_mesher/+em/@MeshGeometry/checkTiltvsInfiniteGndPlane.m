function checkTiltvsInfiniteGndPlane(obj,propVal)






    excludelist={'em.MonopoleAntenna','em.MicrostripAntenna',...
    'em.BackingStructure','helix','helixMultifilar','fractalSnowflake',...
    'monocone','em.DielectricResonatorAntenna','monopoleCylindrical'};
    bool=0;
    if isa(obj,'em.Array')&&~isempty(obj.Tilt)
        if isprop(obj,'Element')
            bool=cell2mat(cellfun(@(x)isa(obj.Element,x),excludelist,'UniformOutput',false));
        end
    else
        bool=cell2mat(cellfun(@(x)isa(obj,x),excludelist,'UniformOutput',false));
    end
    if any(bool)
        if~isempty(getInfGPState(obj))
            if getInfGPState(obj)&&any(propVal~=0)
                error(message('antenna:antennaerrors:Unsupported',...
                'Tilt','Infinite ground plane'));
            end
        end
    end








