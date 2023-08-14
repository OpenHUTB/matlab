function code=fixptConfigToScript(cfg)
    strs={};

    emitCfgConstructor();
    emitCfgProperties();
    emitCfgDesignRangeSpecifications();
    emitCfgAnnotations();
    emitCfgFunctionReplacements();
    emitCfgFunctionApproximations();

    code=strjoin(strs,'');


    function emitCfgConstructor()
        emit('cfg = coder.config(''fixpt'');\n');
    end


    function emitCfgProperties()
        path='cfg';
        firstTime=true;
        cfgActual=cfg;
        cfgDefault=coder.config('fixpt');
        for prop=properties(cfgActual)'
            propName=prop{1};
            actual=cfgActual.(propName);
            default=cfgDefault.(propName);
            if~isequal(actual,default)
                if firstTime
                    emit('\n');
                    firstTime=false;
                end
                if strcmp(propName,'TestBenchName')
                    if iscell(actual)
                        for ii=1:length(actual)
                            [~,fileName,ext]=fileparts(actual{ii});
                            actual{ii}=[fileName,ext];
                        end
                    else
                        [~,fileName,ext]=fileparts(actual);
                        actual=[fileName,ext];
                    end
                    emitprop(path,propName,actual);
                else
                    emitprop(path,propName,actual);
                end
            end
        end
    end


    function emitCfgDesignRangeSpecifications()
        fcnList=cfg.getDesignSpecifiedFunctions();

        for ii=1:length(fcnList)
            functionName=fcnList{ii};
            designRangeSpecifiedVars=cfg.getDesignSpecifiedVars(functionName);
            for jj=1:length(designRangeSpecifiedVars)
                varName=designRangeSpecifiedVars{jj};
                [designMin,designMax]=cfg.getDesignRangeSpecification(functionName,varName);
                emit('cfg.addDesignRangeSpecification(''%s'', ''%s'', %.17G, %.17G);\n',functionName,varName,designMin,designMax);
            end
        end

        if~isempty(fcnList)
            emit('\n');
        end
    end


    function emitCfgAnnotations()
        fcnList=cfg.getTypeSpecifiedFunctions();
        if~isempty(fcnList)
            emit('\n');
        end
        for ii=1:length(fcnList)
            functionName=fcnList{ii};
            typeSpecifiedVars=cfg.getTypeSpecifiedVars(functionName);

            for jj=1:length(typeSpecifiedVars)
                varName=typeSpecifiedVars{jj};
                typeSpec=cfg.getTypeSpecification(functionName,varName);

                if typeSpec.RoundingMethodSet||typeSpec.OverflowActionSet||typeSpec.IsIntegerSet||typeSpec.FimathSet
                    emit('typeSpec = coder.FixPtTypeSpec();\n');
                    if typeSpec.IsIntegerSet
                        emit('typeSpec.IsInteger = true;\n');
                    end
                    if typeSpec.ProposedTypeSet
                        emit('typeSpec.ProposedType = %s;\n',typeSpec.ProposedType.tostring());
                    end
                    if typeSpec.RoundingMethodSet
                        emit('typeSpec.RoundingMethod = ''%s'';\n',typeSpec.RoundingMethod);
                    end
                    if typeSpec.OverflowActionSet
                        emit('typeSpec.OverflowAction = ''%s'';\n',typeSpec.OverflowAction);
                    end
                    if typeSpec.FimathSet
                        emit('typeSpec.fimath = %s;\n',typeSpec.fimath.tostring());
                    end
                    emit('cfg.addTypeSpecification(''%s'', ''%s'', typeSpec);\n',functionName,varName);
                elseif typeSpec.ProposedTypeSet
                    emit('cfg.addTypeSpecification(''%s'', ''%s'', %s);\n',functionName,varName,typeSpec.ProposedType.tostring);
                end
            end
        end
    end


    function emitCfgFunctionApproximations()
        mathCfgs=cfg.getMathFcnConfigs();
        cellfun(@(approxCfg)emitApproximationConfig(approxCfg),mathCfgs.values);







        function emitApproximationConfig(appCfg)
            mathFcnGenCfg=coder.approximation('log');
            mathFcnGenCfg.Mode='UniformInterpolation';
            mathFcnGenCfg.NumberOfPoints=1000;
            mathFcnGenCfg.InterpolationDegree=3;
            mathFcnGenCfg.ErrorThreshold=1e-3;

            emit('approxConfig = coder.approximation(''%s'');\n',appCfg.getName());
            emit('approxConfig.InterpolationDegree = %d;\n',appCfg.InterpolationDegree);
            inputRange=appCfg.InputRange;
            if~isempty(inputRange)&&2==length(inputRange)
                emit('approxConfig.InputRange = [%.17G %.17G];\n',inputRange(1),inputRange(2));
            end
            emit('approxConfig.NumberOfPoints = %d;\n',appCfg.NumberOfPoints);
            emit('cfg.addApproximation(approxConfig);\n');
        end
    end


    function emitCfgFunctionReplacements()
        replacementMap=cfg.getFunctionReplacementMap();
        fcns=replacementMap.keys();
        for ii=1:length(fcns)
            functionName=fcns{ii};
            replacementName=replacementMap(functionName);
            emit('cfg.addFunctionReplacement(''%s'', ''%s'');\n',functionName,replacementName);
        end

        if~isempty(fcns)
            emit('\n');
        end
    end

    function emit(fmt,varargin)
        strs{end+1}=sprintf(fmt,varargin{:});
    end


    function result=cellPropToString(prop)
        result=cell(1,numel(prop));
        for i=1:numel(prop)
            result{i}=propToString(prop{i});
        end
    end


    function string=propToString(prop)
        switch class(prop)
        case 'char'
            meta={'%','\\','\n','\t',''''};
            if~all(cellfun('isempty',regexp(prop,meta,'once')))
                safe={'%%','\\\\','\\n','\\t',''''''};
                string=regexprep(prop,meta,safe);
                string=sprintf('sprintf(''%s'')',string);
            else
                string=sprintf('''%s''',prop);
            end
        case 'logical'
            if prop
                string='true';
            else
                string='false';
            end
        case 'cell'
            string=cellPropToString(prop);
        case 'function_handle'
            string=['@',func2str(prop)];
        otherwise
            string=num2str(prop);
        end
    end


    function emitprop(path,propName,propValue)
        dispValue=propToString(propValue);
        lhs=sprintf('%s.%s',path,propName);
        if~iscell(dispValue)
            emit('%s = %s;\n',lhs,dispValue);
        else
            N=numel(dispValue);
            indent=repmat(' ',1,numel(lhs)+4);
            for i=1:N
                string=dispValue{i};
                if i==1
                    emit('%s = { %s',lhs,string);
                else
                    emit('%s %s',indent,string);
                end

                if i==N
                    emit(' };\n');
                else
                    emit(', ...\n');
                end
            end
        end
    end

end
