function schema=getAdaptiveDefaultSchema()




    if slfeature('AutosarAdaptiveR2011')
        schema='R20-11';
    else
        schema='R19-11';
    end
end
