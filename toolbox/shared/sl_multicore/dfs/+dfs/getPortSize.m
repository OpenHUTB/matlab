function size=getPortSize(blockHandle,portNumber,isInput)
    portNumber=portNumber+1;
    portSizeExpr='';
    size=0;
    if slprivate('is_stateflow_based_block',blockHandle)
        chartId=sfprivate('block2chart',blockHandle);
        chartH=sf('IdToHandle',chartId);

        if isInput
            scopeVal='Input';
        else
            scopeVal='Output';
        end

        dataH=chartH.find('-isa','Stateflow.Data',...
        'Scope',scopeVal,'Port',portNumber,'-depth',1);
        portSizeExpr=dataH.Props.Array.Size;
    end

    if~isempty(portSizeExpr)


        a=eval(portSizeExpr);
        if isnumeric(a(1))
            size=a(1);
        end
    end
end
