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
        case 'dataset'
            behaviorObj=internal.polariMBDataset;
        case 'dataset_buttondown'
            behaviorObj=internal.polariMBDataset(true);
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
        otherwise
            error('Unrecognized mouse behavior "%s".',behaviorStr);
        end

        behaviorCache(behaviorStr)=behaviorObj;
        p.pMouseBehaviorCache=behaviorCache;
    end


    p.pMouseBehavior=behaviorObj;
    install(behaviorObj,p);


