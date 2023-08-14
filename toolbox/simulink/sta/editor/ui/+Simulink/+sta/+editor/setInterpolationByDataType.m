function aVar=setInterpolationByDataType(aVar)

    if isa(aVar,'Simulink.SimulationData.Dataset')||isa(aVar,'Simulink.SimulationData.DatasetRef')


        dsTemp=Simulink.SimulationData.Dataset;
        elNames=aVar.getElementNames();


        for kEl=1:aVar.numElements
            dsEl=aVar.get(kEl);
            dsEl=Simulink.sta.editor.setInterpolationByDataType(dsEl);

            dsTemp=dsTemp.addElement(dsEl,elNames{kEl});
        end
        aVar=dsTemp;
    elseif isa(aVar,'struct')

        if isscalar(aVar)

            leafNames=fieldnames(aVar);

            for kLeaf=1:length(leafNames)
                aVar.(leafNames{kLeaf})=Simulink.sta.editor.setInterpolationByDataType(aVar.(leafNames{kLeaf}));
            end
        else

            numEl=numel(aVar);

            for kAob=1:numEl
                aVar(kAob)=Simulink.sta.editor.setInterpolationByDataType(aVar(kAob));
            end

        end

    elseif isa(aVar,'timeseries')||isa(aVar,'Simulink.Timeseries')

        if any(strcmpi(class(aVar.Data),{'boolean','logical'}))||isenum(aVar.Data)
            aVar.DataInfo.Interpolation=tsdata.interpolation('zoh');
        else
            aVar.DataInfo.Interpolation=tsdata.interpolation('linear');
        end

    elseif isa(aVar,'Simulink.SimulationData.BlockData')

        aVar.Values=Simulink.sta.editor.setInterpolationByDataType(aVar.Values);

    end