function installMouseBehavior(p,behaviorStr)










    behaviorCache=p.pMouseBehaviorCache;
    if isKey(behaviorCache,behaviorStr)

        behaviorObj=behaviorCache(behaviorStr);
    else

        switch lower(behaviorStr)
        case 'none'
            behaviorObj=internal.polariMBNone;
        case 'general'
            behaviorObj=internal.polariMBGeneral;
        case 'grid'
            behaviorObj=internal.polariMBGrid;
        case 'grid_buttondown'
            behaviorObj=internal.polariMBGrid(true);
        case 'anglespan'
            behaviorObj=internal.polariMBAngleSpan;
        case 'anglespan_buttondown'
            behaviorObj=internal.polariMBAngleSpan(true);
        case 'angleticks'
            behaviorObj=internal.polariMBAngleTicks;
        case 'angleticks_buttondown'
            behaviorObj=internal.polariMBAngleTicks(true);
        case 'magticks'
            behaviorObj=internal.polariMBMagTicks;
        case 'magticks_buttondown'
            behaviorObj=internal.polariMBMagTicks(true);
        case 'anglemarker'
            behaviorObj=internal.polariMBAngleMarker;
        case 'anglemarker_buttondown'
            behaviorObj=internal.polariMBAngleMarker(true);
        case 'dataset'
            behaviorObj=internal.polariMBDataset;
        case 'dataset_buttondown'
            behaviorObj=internal.polariMBDataset(true);
        case 'spanreadout'
            behaviorObj=internal.polariMBSpanReadout;
        case 'spanreadout_buttondown'
            behaviorObj=internal.polariMBSpanReadout(true);
        case 'antennareadout'
            behaviorObj=internal.polariMBAntennaReadout;
        case 'antennareadout_buttondown'
            behaviorObj=internal.polariMBAntennaReadout(true);
        case 'titletop'
            behaviorObj=internal.polariMBTitle('top');
        case 'titletop_buttondown'
            behaviorObj=internal.polariMBTitle('top',true);
        case 'titlebottom'
            behaviorObj=internal.polariMBTitle('bottom');
        case 'titlebottom_buttondown'
            behaviorObj=internal.polariMBTitle('bottom',true);
        case 'legend'
            behaviorObj=internal.polariMBLegend;
        case 'peakstable'
            behaviorObj=internal.polariMBPeaksTable;

        otherwise
            error('Unrecognized mouse behavior "%s".',behaviorStr);
        end

        behaviorCache(behaviorStr)=behaviorObj;
        p.pMouseBehaviorCache=behaviorCache;
    end


    p.pMouseBehavior=behaviorObj;
    install(behaviorObj,p);


