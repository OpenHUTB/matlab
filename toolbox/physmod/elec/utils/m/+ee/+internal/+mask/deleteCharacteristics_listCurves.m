function varargout=deleteCharacteristics_listCurves(modelName)



    mws=get_param(modelName,'modelworkspace');
    variableList=evalin(mws,'who');
    ds=simscapeBlockDataset.empty;
    for ii=1:length(variableList)
        if isa(evalin(mws,variableList{ii}),'simscapeBlockDataset')
            ds(end+1)=evalin(mws,variableList{ii});%#ok<AGROW>
        end
    end
    if isempty(ds)
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:deleteCharacteristics_listCurves:error_ModelWorkspaceSimscapeBlockDataset')));
    end
    if length(ds)>1
        pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:utils:mask:deleteCharacteristics_listCurves:error_ModelWorkspaceSimscapeBlockDatasets')));
    end
    terminals=ds.getTabulatedDataFromSymbol('term');
    referenceTerminal=ds.getTabulatedDataFromSymbol('ref');
    if nargout>=1
        [~,varargout{1}]=ee.internal.mask.displayCharacteristicData(ds);
    else
        fprintf(ee.internal.mask.convertLegendStringToUseTerminalNames(...
        ee.internal.mask.displayCharacteristicData(ds),...
        terminals,referenceTerminal));
    end
end