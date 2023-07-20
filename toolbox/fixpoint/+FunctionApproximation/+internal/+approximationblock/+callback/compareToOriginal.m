function varargout=compareToOriginal(variantSystemTag)%#ok<INUSD>







    variantSystemHandle=gcbh;
    maskObject=Simulink.Mask.get(variantSystemHandle);
    parameters=maskObject.Parameters;
    schema=FunctionApproximation.internal.approximationblock.BlockSchema();
    compareDataIndex=strcmp(schema.CompareDataParameterName,{parameters.Name});
    h=[];
    if any(compareDataIndex)
        compareData=parameters(compareDataIndex).Value;
        dataContext=FunctionApproximation.internal.visualizer.DataCollector.convertJSONToContext(compareData);
        if~isempty(dataContext)
            plotter=FunctionApproximation.internal.visualizer.PlotterFactory.getPlotter(numel(dataContext.Breakpoints));
            h=plotter.plot(dataContext);
        end
    end
    if nargout
        varargout{1}=h;
    end
end
