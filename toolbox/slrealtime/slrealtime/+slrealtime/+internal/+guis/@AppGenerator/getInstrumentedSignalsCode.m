function code=getInstrumentedSignalsCode(sourceFile,modelName,uiaxesName,appArgName)







    try


        hInst=slrealtime.Instrument(sourceFile);
        hInst.addInstrumentedSignals();
    catch


        hInst=slrealtime.Instrument;
        getInstrumentedSignalsFromModel(modelName,hInst,{});
    end




    code=hInst.generateScript();



    code=code(contains(code,'addSignal'));





    code=strrep(code,'addSignal(',['connectLine(',appArgName,'.',uiaxesName,', ']);



    code=cellfun(@(x)['            ',x],code,'UniformOutput',false);



    code={code{:}};%#ok
end




function getInstrumentedSignalsFromModel(model,hInst,prefix)
    try
        find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    catch
        try
            load_system(model);
            cleanup=onCleanup(@()close_system(model,false));
        catch
            slrealtime.internal.throw.Error(...
            'slrealtime:appdesigner:ModelNotFound',...
            model);
            return;
        end
    end
    sigs=get_param(model,'InstrumentedSignals');
    if~isempty(sigs)
        for i=1:sigs.Count
            sig=sigs.get(i);
            bp=sig.BlockPath.convertToCell();
            if numel(bp)==1&&isempty(bp{1})
                continue;
            end
            hInst.addSignal([prefix,sig.BlockPath.convertToCell()],sig.OutputPortIndex);
        end
    end

    modelBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','Block','BlockType','ModelReference');
    for i=1:length(modelBlks)
        getInstrumentedSignalsFromModel(get_param(modelBlks{i},'ModelName'),hInst,[prefix,modelBlks(i)])
    end
end
