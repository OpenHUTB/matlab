function apset=getAlgorithmParameters(h)




    key=h.Key;
    if isempty(key)


        DAStudio.error('CoderFoundation:AlgorithmParameters:EmptyKey');
    end

    apset={};
    switch(key)
    case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D','lookupND'}

        apset=coder.algorithm.parameterset.Lookup();
    case{'interp1D','interp2D','interp3D','interp4D','interp5D','interpND'}

        apset=coder.algorithm.parameterset.Interp();
    case{'prelookup'}

        apset=coder.algorithm.parameterset.Prelookup();
    case{'lookupND_Direct'}

        apset=coder.algorithm.parameterset.DirectLookup();
    case{'edge_trigger'}

        apset=coder.algorithm.parameterset.EfxEdgeTrigger();
    case{'hysteresis'}

        apset=coder.algorithm.parameterset.MflHysteresis();
    case{'trig_atan2'}

        apset=coder.algorithm.parameterset.McbTrigBlocks();
    case{'mcb_ipark','mcb_park'}

        apset=coder.algorithm.parameterset.McbTransformPark();
    case{'sin','cos','sincos','cexp','atan2'}

        apset=coder.algorithm.parameterset.Trigonometry();
    end


    if~isempty(h.AlgorithmParams)
        aps=h.AlgorithmParams;

        if~isempty(apset)

            for i=1:length(aps)
                ap=aps(i);
                apset=apset.setPropertyValue(ap.Name,ap.Value);
            end
        end
    end

end
