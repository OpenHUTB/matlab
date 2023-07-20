function[symbol,info]=evaluateSymbol(symbolInfo,symbolEnvironment)
    import sltest.assessments.internal.AssessmentsEvaluator.*;

    info='';

    if isfield(symbolInfo.children,'FieldElement')
        fieldElement=symbolInfo.children.FieldElement.value;
    else
        fieldElement='';
    end

    switch symbolInfo.scope
    case 'Signal'

        assert(isfield(symbolEnvironment,'LogsOut'),'logsout environment not provided');

        blockPath=symbolInfo.children.bindableMetaData.value.hierarchicalPathArr(2:end);
        if length(blockPath)==1
            blockPathStr=blockPath{1};
        else
            blockPathStr=sprintf('\n\t%s',blockPath{2:end});
        end
        portIndex=symbolInfo.children.bindableMetaData.value.outputPortNumber;

        if isempty(symbolEnvironment.LogsOut)
            error(message('sltest:assessments:MissingSignal',symbolInfo.value,blockPathStr,portIndex));
        end
        signal=symbolEnvironment.LogsOut.find('BlockPath',blockPath,'PortIndex',portIndex);
        if signal.numElements==0
            error(message('sltest:assessments:MissingSignal',symbolInfo.value,blockPathStr,portIndex));
        end
        if~isempty(symbolEnvironment.DiscreteEventSignals)
            discreteEventsignal=symbolEnvironment.DiscreteEventSignals.find('BlockPath',blockPath,'PortIndex',portIndex);
            if(discreteEventsignal.numElements>0)
                error(message('sltest:assessments:DiscreteEventSymbolValueType',symbolInfo.value,blockPathStr,portIndex));
            end
        end
        assert((isempty(symbolEnvironment.Workspace.sltest_simout)&&signal.numElements>=1)||signal.numElements==1,'unexpectedly found %d signals in sltest_simout at block path: %s\nport index: %d',signal.numElements,blockPathStr,portIndex);
        symbolValue=resolveSymbolValue(symbolInfo.value,signal.get(1).Values,fieldElement);
        isParameterConstant=false;
        if(numel(symbolValue.Time)==1&&~isempty(symbolEnvironment.ConstantSignals))
            signal=symbolEnvironment.ConstantSignals.find('BlockPath',blockPath,'PortIndex',portIndex);
            isParameterConstant=(signal.numElements>0);
        end
        if(isParameterConstant)
            symbol=sltest.assessments.Constant(symbolValue.Data(1));
        else
            interp=symbolValue.DataInfo.Interpolation;
            if isequal(interp,tsdata.interpolation.createLinear())&&~isfloat(symbolValue.Data)
                info=getString(message('sltest:assessments:InterpolationOverride'));
                symbolValue=setinterpmethod(symbolValue,'zoh');
            end
            symbol=sltest.assessments.Signal(symbolValue);
        end

    case{'Parameter','Variable'}

        assert(isfield(symbolEnvironment,'Parameters'),'parameter environment not provided');
        parameter=symbolEnvironment.Parameters{symbolEnvironment.SimIndex}.(symbolInfo.value);
        if~isempty(parameter.error)
            parameter.error.throw();
        end

        symbolValue=resolveSymbolValue(symbolInfo.value,parameter.value,fieldElement);

        symbol=sltest.assessments.Constant(symbolValue);
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

        if isa(value,'timeseries')
            interp=value.DataInfo.Interpolation;
            if isequal(interp,tsdata.interpolation.createLinear())&&~isfloat(value.Data)
                info=getString(message('sltest:assessments:InterpolationOverride'));
                value=setinterpmethod(value,'zoh');
            end
            symbol=sltest.assessments.Signal(value);
        elseif isnumeric(value)||isa(value,'logical')
            symbol=sltest.assessments.Constant(value);
        else
            assert(false,'unexpected value for symbol %s',symbolInfo.value);
        end
    case 'Fuzzer'
        stopTime=150;
        if~isempty(symbolEnvironment.Workspace.sltest_sut)
            stopTime=str2num(get_param(symbolEnvironment.Workspace.sltest_sut,'StopTime'))+1;
        end
        ts=Simulink.fuzzer.dialogs.FuzzerSettingsDialog.createFuzzerTimeSeries(...
        symbolInfo.children.fullFuzzer.objId,...
        symbolInfo.children.fullFuzzer,stopTime);
        value=ts;
        symbol=sltest.assessments.Signal(value);

    case 'Unresolved'
        error(message('sltest:assessments:UseOfUnresolvedSymbol',symbolInfo.value));

    otherwise
        assert(false,'unexpected symbol scope %s',symbolInfo.scope);
    end

    symbol=sltest.assessments.Alias(symbol,symbolInfo.value);
end
