function cMap=getSystemObjectConstraints()
































    mlock;
    persistent constraintsMap
    if isempty(constraintsMap)
        constraintsMap=containers.Map();
        try



            d=which('dsp.util.getSystemObjectConstraintsForF2F');
            if~isempty(d)
                tmpMap=dsp.util.getSystemObjectConstraintsForF2F();
                constraintsMap=[constraintsMap;tmpMap];
            end
        catch

        end
    end
    cMap=constraintsMap;
end