function setGroundPlaneFlags(obj,propVal)




    if isa(propVal,'em.MonopoleAntenna')||...
        isa(propVal,'em.MicrostripAntenna')||isa(propVal,'helix')||...
        isa(propVal,'reflector')||isa(propVal,'reflectorCircular')||...
        isa(propVal,'fractalSnowflake')||isa(propVal,'monocone')||...
        isa(obj.Element,'draRectangular')||isa(obj.Element,'draCylindrical')||...
        isa(propVal,'monopoleCylindrical')
        setDynamicPropertyAdded(obj);
    else
        setFiniteGPStateFlags(obj)
    end

end

function setFiniteGPStateFlags(obj)
    resetDynamicPropertyAdded(obj);
    setInfGPState(obj,false);
    setInfGPConnState(obj,false);
end
