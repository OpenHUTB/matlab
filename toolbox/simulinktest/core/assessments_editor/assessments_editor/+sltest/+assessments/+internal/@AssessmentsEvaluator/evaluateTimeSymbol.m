function[symbol,info]=evaluateTimeSymbol(symbolInfo,symbolEnvironment)
    import sltest.assessments.internal.AssessmentsEvaluator.*;

    info='';

    if isfield(symbolInfo.children,'FieldElement')
        fieldElement=symbolInfo.children.FieldElement.value;
    else
        fieldElement='';
    end

    switch symbolInfo.scope
    case 'Signal'
        error(message('sltest:assessments:InvalidTimeSymbol',symbolInfo.value));

    case{'Parameter','Variable'}

        assert(isfield(symbolEnvironment,'Parameters'),'parameter environment not provided');
        parameter=symbolEnvironment.Parameters{symbolEnvironment.SimIndex}.(symbolInfo.value);
        if~isempty(parameter.error)
            parameter.error.throw();
        end

        symbol=resolveSymbolValue(symbolInfo.value,parameter.value,fieldElement);
        info=parameter.info;

    case 'Expression'

        try
            value=evaluateExpression(symbolInfo.children.Expression.value,symbolEnvironment.Workspace);
        catch ME
            error(message('sltest:assessments:ErrorEvaluatingSymbolExpression',symbolInfo.value,ME.message));
        end

        if isa(value,'Simulink.SimulationData.BlockData')
            value=value.Values;
        end

        checkValueIsValidScalar(symbolInfo.value,value);
        symbol=value;
    case 'Fuzzer'
        error(message('sltest:assessments:InvalidTimeSymbol',symbolInfo.value));

    case 'Unresolved'
        error(message('sltest:assessments:UseOfUnresolvedSymbol',symbolInfo.value));

    otherwise
        assert(false,'unexpected symbol scope %s',symbolInfo.scope);
    end

    if~isscalar(symbol)||~isnumeric(symbol)
        error(message('sltest:assessments:InvalidTimeSymbol',symbolInfo.value));
    end

end
