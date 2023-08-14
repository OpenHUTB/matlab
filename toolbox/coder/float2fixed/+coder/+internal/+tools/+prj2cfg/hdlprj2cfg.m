function vargout=hdlprj2cfg(javaConfig,xDoc)



    designFullName=getDesign(javaConfig);
    fixptCfg=to_fixptCfg(javaConfig);
    hdlCfg=to_hdlCfg(xDoc);

    vargout{1}=fixptCfg;
    vargout{2}=hdlCfg;
    vargout{3}=designFullName;
end

function cfg=to_hdlCfg(xDoc)
    cfg=coder.config('hdl');
    emlcprivate('emlcHDLPrjParse',xDoc,cfg);
end

function cfg=to_fixptCfg(javaConfig)
    cfg=coder.FixPtConfig;
    configMap=ParamToFixPtConfigMap;
    optionsMap=optionsToValueMap;

    params=configMap.keys;
    for ii=1:length(params)
        param=params{ii};
        prop=configMap(param);

        val=javaConfig.getParamAsObject(param);
        cfg.(prop)=screenValue(val,optionsMap);
    end

    cfg.TestBenchName=getTestBench(javaConfig);


    proposalKind=javaConfig.getParamAsObject('param.fixptconv.FixptProposalKind');
    if strcmpi(proposalKind,'option.fixptconv.ProposeFracLenBasedOnWordLen')
        cfg.ProposeFractionLengthsForDefaultWordLength=true;
        cfg.ProposeWordLengthsForDefaultFractionLength=false;
    elseif strcmpi(proposalKind,'option.fixptconv.ProposeWordLenBasedOnFracLen')
        cfg.ProposeFractionLengthsForDefaultWordLength=false;
        cfg.ProposeWordLengthsForDefaultFractionLength=true;
    else
        disp('Found unknown proposal option, defaulting to proposed fraction length for fixed word length');
    end

    cfg=addFunctionReplacements(cfg,javaConfig);
    cfg=addTypeProposalSettings(cfg,javaConfig);



    function configMap=ParamToFixPtConfigMap
        configMap=coder.internal.lib.Map();


        configMap('param.fixptconv.LogHistogram')='HistogramLogging';


        configMap('param.fixptconv.StaticAnalysisTimeout')='StaticAnalysisTimeoutMinutes';
        configMap('param.fixptconv.StaticAnalysisGlobalRangesOnly')='StaticAnalysisQuickMode';

        configMap('param.fixptconv.DefaultFixptWordLength')='DefaultWordLength';
        configMap('param.fixptconv.DefaultFixptFractionLength')='DefaultFractionLength';


        configMap('param.fixptconv.OptimizeWholeNumbers')='OptimizeWholeNumber';
        configMap('param.fixptconv.DefaultFixedPointSignedness')='DefaultSignedness';
        configMap('param.fixptconv.SafetyMargin')='SafetyMargin';
        configMap('param.fixptconv.FixPtFileNameSuffix')='FixPtFileNameSuffix';
        configMap('param.fixptconv.FiMathString')='fimath';


        configMap('param.fixptconv.LogAllIOValues')='LogIOForComparisonPlotting';


        configMap('param.fixptconv.FICastFiVariables')='FiCastFiVars';



    end



    function optionsMap=optionsToValueMap
        optionsMap=coder.internal.lib.Map();

        optionsMap('option.fixptconv.proposetypes.floor')='Floor';
        optionsMap('option.fixptconv.proposetypes.ceiling')='Ceiling';
        optionsMap('option.fixptconv.proposetypes.convergent')='Convergent';
        optionsMap('option.fixptconv.proposetypes.nearest')='Nearest';
        optionsMap('option.fixptconv.proposetypes.round')='Round';
        optionsMap('option.fixptconv.proposetypes.zero')='Zero';

        optionsMap('option.fixptconv.proposetypes.wrap')='Wrap';
        optionsMap('option.fixptconv.proposetypes.saturate')='Saturate';

        optionsMap('option.fixptconv.DefaultFixedPointSignedness.Automatic')='Automatic';
        optionsMap('option.fixptconv.DefaultFixedPointSignedness.Signed')='Signed';
        optionsMap('option.fixptconv.DefaultFixedPointSignedness.Unsigned')='Unsigned';
    end

    function cfg=addTypeProposalSettings(cfg,javaConfig)
        cfg=addTypeSpecAndDesignRanges(cfg,javaConfig.getParamAsObject('param.transformedVariables'));


        function cfg=addTypeSpecAndDesignRanges(cfg,xmlReader)

            if isempty(xmlReader)
                return;
            end

            prjToTypeSpecMap=getPrjToTypeSpecMap();
            getSpecName=@(prjName)prjToTypeSpecMap.get(prjName);
            functionReader=xmlReader.getChild('Function');
            while functionReader.isPresent()
                functionName=functionReader.readAttribute('name').toCharArray';
                variableReader=functionReader.getChild('Variable');
                while(variableReader.isPresent)
                    variableName=variableReader.readAttribute('name').toCharArray';

                    fieldReader=variableReader.getChild('Column');

                    typeSpec=[];
                    typeSpecGet=@(typeSpec)safeGet(typeSpec,@coder.FixPtTypeSpec);
                    designMin=[];
                    designMax=[];
                    while fieldReader.isPresent
                        fieldName=fieldReader.readAttribute('property').toCharArray';
                        fieldValue=fieldReader.readAttribute('value').toCharArray';
                        if strcmp(fieldName,'ProposedType')...
                            ||strcmp(fieldName,'RoundMode')...
                            ||strcmp(fieldName,'OverflowMode')...
                            ||strcmp(fieldName,'IsInteger')
                            typeSpec=typeSpecGet(typeSpec);
                            typeSpec.(getSpecName(fieldName))=convertToActualType(fieldName,fieldValue);
                        end
                        if strcmp(fieldName,'DesignMin')
                            designMin=convertToActualType(fieldName,fieldValue);
                        end
                        if strcmp(fieldName,'DesignMax')
                            designMax=convertToActualType(fieldName,fieldValue);
                        end
                        fieldReader=fieldReader.next();
                    end

                    if~isempty(typeSpec)
                        cfg.addTypeSpecification(functionName,variableName,typeSpec);
                    end
                    if~isempty(designMin)||~isempty(designMax)
                        cfg.addDesignRangeSpecification(functionName,variableName,designMin,designMax);
                    end

                    variableReader=variableReader.next();
                end
                functionReader=functionReader.next();
            end

            function nameMap=getPrjToTypeSpecMap
                nameMap=coder.internal.lib.Map({'ProposedType','RoundMode','OverflowMode','IsInteger'}...
                ,{'ProposedType','RoundingMethod','OverflowAction','IsInteger'});
            end



            function val=safeGet(val,createObj)
                if~isempty(val)
                    return;
                end
                val=createObj();
            end

            function fieldValue=convertToActualType(fieldName,fieldValue)
                switch(fieldName)
                case{'DesignMin','DesignMax'}
                    fieldValue=str2double(fieldValue);
                case 'IsInteger'
                    fieldValue=str2bool(fieldValue);
                end
            end
        end
    end

    function cfg=addFunctionReplacements(cfg,javaConfig)
        xmlReader=javaConfig.getParamAsObject('param.fixptconv.generatefixptcode.function_replacements');

        if isempty(xmlReader)
            return;
        end

        functionReader=xmlReader.getChild('Function');
        while functionReader.isPresent()
            functionName=functionReader.readAttribute('name').toCharArray';
            functionReplacement=functionReader.readAttribute('replacement').toCharArray';
            cfg.addFunctionReplacement(functionName,functionReplacement);
            functionReader=functionReader.next();
        end
    end
end



function val=screenValue(val,optionsMap)
    if ischar(val)&&length(val)>7&&strcmp('option.',val(1:7))
        if optionsMap.isKey(val)
            val=optionsMap(val);
        end
    else
        val=javaToMATLABVal(val);
    end
end

function val=javaToMATLABVal(obj)

    switch class(obj)
    case 'char'

        t=str2double(obj);
        if~isempty(t)&&~isa(t,'embedded.fimath')&&~isnan(t)
            val=t;
            return;
        end
        obj=str2bool(obj);
        val=obj;
    case 'java.math.BigDecimal'
        val=obj.doubleValue;

    case 'java.util.ArrayList'
        if obj.isEmpty
            val=[];
        else
            val=obj;
        end
    otherwise
        val=obj;
    end
end



function bVal=str2bool(sVal)
    if strcmp(sVal,'true')
        bVal=true;
    elseif strcmp(sVal,'false')
        bVal=false;
    else
        bVal=sVal;
    end
end

function designFullName=getDesign(javaConfig)
    designList=javaConfig.getFileSet('fileset.entrypoints');
    designFullName='';
    if designList.getFiles.size>0
        designFullName=char(designList.getFiles.first.toString);
    end
end

function tbs=getTestBench(javaConfig)
    tbs={};
    fileSet=javaConfig.getFileSet('fileset.scriptfile');
    if(~isempty(fileSet))
        if(fileSet.getFiles.size()>0)
            tbFilePath=char(fileSet.getFiles.iterator.next.getAbsolutePath);
            [~,scriptName,~]=fileparts(tbFilePath);
            tbs=[tbs,scriptName];
        end
    end
end
