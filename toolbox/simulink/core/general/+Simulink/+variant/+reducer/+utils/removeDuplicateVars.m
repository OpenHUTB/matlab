function configInfos=removeDuplicateVars(configInfos,fullrangeVars)
















    fullrangeVarNames=fullrangeVars(1:2:end);


    if numel(fullrangeVarNames)~=numel(unique(fullrangeVarNames))


        errid='Simulink:VariantReducer:DuplicateFullRangeVars';
        err=MException(message(errid));
        throw(err);
    end

    Simulink.variant.reducer.utils.assert(isstruct(configInfos),'Configurations are expected to be struct');


    for cfgId=1:numel(configInfos)



        fn=fieldnames(configInfos);
        cfg=configInfos(cfgId).(fn{2});
        cfgVars=cfg(1:2:end);


        if numel(cfgVars)~=numel(unique(cfgVars))


            errid='Simulink:VariantReducer:DuplicateSpecVariables';
            err=MException(message(errid));
            throw(err);
        end


        for flvarId=1:numel(fullrangeVarNames)



            dupIds=strcmp(cfgVars,fullrangeVarNames(flvarId));






            dupIdx=2*(find(dupIds));
            toremoveIdxs=[dupIdx-1,dupIdx];

            cfg(toremoveIdxs)=[];
            configInfos(cfgId).(fn{2})=cfg;
        end
    end

end


