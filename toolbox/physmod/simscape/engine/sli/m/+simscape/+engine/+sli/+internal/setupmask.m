function setupmask(block,components,componentNames)





    import simscape.compiler.sli.internal.*;

    pm_assert(numel(components)==numel(componentNames));

    assert(simscape.engine.sli.internal.issimscapeblock(block),...
    'SETUPMASK works on Simscape blocks.');

    setappdata(0,'pmGlobals',lGetGlobals);
    lSetup(block,components,componentNames);

end


function lCommonSetup(hSlObj,templ_struct,cs)



    fields=fieldnames(templ_struct.slBlockProps);

    mo=Simulink.Mask.get(hSlObj);
    if isempty(mo)
        mo=Simulink.Mask.create(hSlObj);
    else
        mo.removeAllParameters();
    end

    for idx=1:length(fields)
        mo.(fields{idx})=templ_struct.slBlockProps.(fields{idx});
    end




    if isfield(templ_struct,'maskedProps')


        lCopyVisibleFields(hSlObj,templ_struct.maskedProps);
    end



    lSetupBlockIcon(hSlObj,cs);
end

function lSetup(block,components,componentNames)
    schemaLoader=@(sourceFile)physmod.schema.internal.blockComponentSchema(block,sourceFile).info;
    cs=schemaLoader(components{1});

    parentObj=get(bdroot(block),'Object');
    if parentObj.isLibrary
        blockName=get_param(block,'Name');
    else
        blockName=cs.Descriptor;
    end

    templ_struct=lCreateBlockTemplate(schemaLoader,blockName,components,componentNames);

    lCommonSetup(block,templ_struct,cs);
    mo=get_param(block,'MaskObject');

    mo.Description=cs.Description;

end




function lCopyVisibleFields(block,template)



    pm=getappdata(0,'pmGlobals');

    if(~isempty(template))
        allFields=fieldnames(template);


        paramVars={};
        paramPrompts={};
        visibleCount=0;
        paramHide={};

        for j=1:length(allFields)
            field=allFields{j};
            fieldVal=template.(field);


            if(length(fieldVal)<length(pm.MASK_PARAM))
                tmp=fieldVal;
                fieldVal=pm.MASK_PARAM;
                [fieldVal{1:length(tmp)}]=deal(tmp{:});
                if(strcmp(fieldVal{pm.EVAL_FLAG},'string')),fieldVal{pm.EVAL_FLAG}=pm.LITERAL;end
                if(isempty(fieldVal{pm.FIELD_TYPE})),fieldVal{pm.FIELD_TYPE}='edit';end;
            end



            if(fieldVal{pm.INMASK}==pm.SHOW)

                visibleCount=visibleCount+1;




                paramVars{visibleCount}=field;%#ok<AGROW>


                if(~isempty(fieldVal{pm.VAR_LABEL}))
                    current_paramName=fieldVal{pm.VAR_LABEL};
                else

                    current_paramName=field;
                end
                paramPrompts{visibleCount}=current_paramName;%#ok<AGROW>


                paramHide{visibleCount}=fieldVal{pm.MASK_VAR_HIDE};%#ok<AGROW>


                if strcmp(fieldVal{pm.EVAL_FLAG},pm.LITERAL)
                    paramEval{visibleCount}='off';%#ok<AGROW>
                else
                    paramEval{visibleCount}='on';%#ok<AGROW>
                end


                paramTun{visibleCount}=fieldVal{pm.MASK_VAR_TUN};%#ok<AGROW>



                paramValue{visibleCount}=fieldVal{pm.DEFAULT_VAL};%#ok<AGROW>


                paramType{visibleCount}=fieldVal{pm.FIELD_TYPE};%#ok<AGROW>


                typeOptions{visibleCount}=fieldVal{pm.TYPE_OPTIONS};%#ok<AGROW>


                callbackOptions{visibleCount}=fieldVal{pm.CALLBACK};%#ok<AGROW>                


                paramMxarray{visibleCount}=fieldVal{pm.MXARRAY_PARAM};%#ok<AGROW>
            end
        end


        mo=Simulink.Mask.get(block);
        for iParam=1:numel(paramVars)
            mp=mo.addParameter(...
            'Name',paramVars{iParam},...
            'Prompt',paramPrompts{iParam},...
            'Hidden',paramHide{iParam},...
            'Tunable',paramTun{iParam},...
            'Type',paramType{iParam},...
            'TypeOptions',typeOptions{iParam},...
            'Value',paramValue{iParam},...
            'Evaluate',paramEval{iParam},...
            'Callback',callbackOptions{iParam});

            mp.setAttributes('mxarray',paramMxarray{iParam});
        end
    end
end

function lSetupBlockIcon(hSlObj,cs)

    mo=Simulink.Mask.get(hSlObj);


    mo.Display='';



    if~strcmp(cs.Rotation,'rotates')&&~isempty(cs.Rotation)
        mo.IconRotate='none';
    end
















    if builtin('_can_change_port_rotation',hSlObj)
        mo.PortRotate='physical';
    end
end


function tStruct=lCreateBlockTemplate(schemaLoader,blockName,variants,names)

    tStruct.classProps.FactoryBlock='Factory Generic';

    v1=schemaLoader(variants{1});

    className=v1.Name;
    if numel(variants)>1
        className='Simscape variant';
    end


    tStruct.slBlockProps=struct(...
    'Type',blockName,...
    'IconUnits','pixels',...
    'IconRotate','on',...
    'Help','web(nesl_help(gcbh))',...
    'SelfModifiable','on',...
    'RunInitForIconRedraw','off',...
    'Initialization','simscape.compiler.sli.internal.preinitmask(gcb);'...
    );
    pmGlobal=getappdata(0,'pmGlobals');

    variantsStr=simscape.internal.encodeVariantList(variants);
    namesStr=simscape.internal.encodeVariantList(names);

    import simscape.engine.sli.internal.addmaskparam;
    tStruct=addmaskparam(tStruct,'ComponentPath',pmGlobal.INMASK,pmGlobal.SHOW,...
    pmGlobal.MASK_VAR_HIDE,'on',pmGlobal.DEFAULT_VAL,variants{1},...
    pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);

    tStruct=addmaskparam(tStruct,'ComponentVariants',pmGlobal.INMASK,pmGlobal.SHOW,...
    pmGlobal.MASK_VAR_HIDE,'on',pmGlobal.DEFAULT_VAL,variantsStr,...
    pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);

    tStruct=addmaskparam(tStruct,'ComponentVariantNames',pmGlobal.INMASK,pmGlobal.SHOW,...
    pmGlobal.MASK_VAR_HIDE,'on',pmGlobal.DEFAULT_VAL,namesStr,...
    pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);

    tStruct=addmaskparam(tStruct,'ClassName',pmGlobal.INMASK,pmGlobal.SHOW,...
    pmGlobal.MASK_VAR_HIDE,'on',pmGlobal.DEFAULT_VAL,className,...
    pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);

    tStruct=addmaskparam(tStruct,'SchemaVersion',pmGlobal.INMASK,pmGlobal.SHOW,...
    pmGlobal.MASK_VAR_HIDE,'on',pmGlobal.DEFAULT_VAL,'1',...
    pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);

    if simscape.versioning.internal.enabled
        idpth=strsplit(variants{1},'.');
        vernum=simscape.versioning.internal.libversion(idpth{1});
        tStruct=addmaskparam(tStruct,'SimscapeLibraryVersion',...
        pmGlobal.INMASK,pmGlobal.SHOW,...
        pmGlobal.MASK_VAR_HIDE,'on',...
        pmGlobal.DEFAULT_VAL,char(vernum),...
        pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);
    end

    runtimeMap=lGenerateRuntimeMap(schemaLoader,variants);

    for jdx=1:numel(variants)

        component=variants{jdx};
        cs=schemaLoader(component);
        nParams=numel(cs.Members.Parameters);

        paramNames=cell(1,nParams);

        for idx=1:nParams
            hParam=cs.Members.Parameters(idx);
            paramNames{idx}=hParam.ID;

            valStr=lValUnitToMask(hParam.Default);

            paramAdditionalNames=lGetParamAdditionalNames(hParam.ID);

            runtime=runtimeMap(hParam.ID);



            mxarrayParam=false;










            [~,canonicalEnum]=pm.sli.getEnumData(valStr);
            if~isempty(canonicalEnum)
                runtime=false;
                valStr=canonicalEnum;
                mxarrayParam=true;


            end

            tunable='off';
            if runtime
                tunable='on';
            end

            tStruct=addmaskparam(tStruct,hParam.ID,...
            pmGlobal.VAR_LABEL,hParam.Label,...
            pmGlobal.DEFAULT_VAL,valStr,...
            pmGlobal.MASK_VAR_TUN,tunable,...
            pmGlobal.MXARRAY_PARAM,mxarrayParam);

            [unitVal,unitOptions]=lGetUnit(hParam.Default.Unit);
            tStruct=addmaskparam(tStruct,paramAdditionalNames.Unit,pmGlobal.DEFAULT_VAL,unitVal,...
            pmGlobal.FIELD_TYPE,'combobox',...
            pmGlobal.TYPE_OPTIONS,unitOptions,...
            pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);

            confValues={'compiletime'};
            if runtime
                confValues{end+1}='runtime';%#ok<AGROW>
            end

            confParamVal=confValues{1};
            tStruct=addmaskparam(tStruct,paramAdditionalNames.Conf,...
            pmGlobal.DEFAULT_VAL,confParamVal,...
            pmGlobal.FIELD_TYPE,'popup',...
            pmGlobal.TYPE_OPTIONS,confValues,...
            pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);
        end


        lValidateParamNames(paramNames,component);

        lValidateParamsAndTargets(cs.Members.Parameters,cs.Members.Variables);

        numVariables=numel(cs.Members.Variables);
        for idx=1:numVariables
            var=cs.Members.Variables(idx);
            varName=var.ID;

            variableTargetNames=lGetVariableTargetNames(varName);
            icValStr=lValUnitToMask(var.Default.Value);
            [icValUnit,icValUnitOptions]=lGetUnit(var.Default.Value.Unit);

            defaultPriority=var.Default.Priority;



            specifyCheckbox='off';
            nominalSpecifyCheckbox='off';

            tStruct=addmaskparam(tStruct,variableTargetNames.icSpecify,pmGlobal.VAR_LABEL,...
            varName,pmGlobal.FIELD_TYPE,'checkbox',pmGlobal.DEFAULT_VAL,specifyCheckbox,...
            pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);
            tStruct=addmaskparam(tStruct,variableTargetNames.icPriority,pmGlobal.VAR_LABEL,...
            varName,pmGlobal.FIELD_TYPE,'popup',pmGlobal.TYPE_OPTIONS,{'None','Low','High'},...
            pmGlobal.DEFAULT_VAL,defaultPriority,pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);
            tStruct=addmaskparam(tStruct,variableTargetNames.icVar,pmGlobal.DEFAULT_VAL,icValStr,...
            pmGlobal.MASK_VAR_TUN,specifyCheckbox);
            tStruct=addmaskparam(tStruct,variableTargetNames.icUnit,pmGlobal.DEFAULT_VAL,icValUnit,...
            pmGlobal.FIELD_TYPE,'combobox',pmGlobal.TYPE_OPTIONS,icValUnitOptions,...
            pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);


            if~var.Event
                nomValStr=lValUnitToMask(var.Default.Nominal);
                [nomValUnit,nomValUnitOptions]=lGetUnit(var.Default.Nominal.Unit);

                tStruct=addmaskparam(tStruct,variableTargetNames.nomSpecify,pmGlobal.VAR_LABEL,...
                varName,pmGlobal.FIELD_TYPE,'checkbox',pmGlobal.DEFAULT_VAL,nominalSpecifyCheckbox,...
                pmGlobal.EVAL_FLAG,pmGlobal.LITERAL);
                tStruct=addmaskparam(tStruct,variableTargetNames.nomUnit,pmGlobal.DEFAULT_VAL,nomValUnit,...
                pmGlobal.EVAL_FLAG,pmGlobal.LITERAL,pmGlobal.TYPE_OPTIONS,nomValUnitOptions,...
                pmGlobal.FIELD_TYPE,'combobox');
                tStruct=addmaskparam(tStruct,variableTargetNames.nomVal,pmGlobal.DEFAULT_VAL,nomValStr,...
                pmGlobal.MASK_VAR_TUN,'off');
            end

        end

    end

end

function runtimeMap=lGenerateRuntimeMap(schemaLoader,variants)

    runtimeMap=containers.Map();
    for jdx=1:numel(variants)
        component=variants{jdx};
        info=schemaLoader(component);
        params=info.Members.Parameters;

        for idx=1:numel(params)
            name=params(idx).ID;
            runtime=params(idx).Runtime;
            if~runtimeMap.isKey(name)||~runtime
                runtimeMap(name)=runtime;
            end
        end
    end

end

function lValidateParamNames(paramNames,sourceFile)
    if isempty(paramNames)
        return;
    end
    paramNames=sort(paramNames);
    paramNamesLowerCase=lower(paramNames);
    [~,uniqueIdx]=unique(paramNamesLowerCase,'legacy');
    uniqueParamNames=paramNames(uniqueIdx);


    nParams=numel(paramNames);
    if numel(uniqueParamNames)~=numel(paramNames)
        idx=1:nParams;

        dupIdx=setdiff(idx,uniqueIdx,'legacy');

        dupParamNames=paramNames(dupIdx);

        [~,idx]=intersect(lower(uniqueParamNames),lower(dupParamNames),'legacy');
        dupParamsInUniqueList=uniqueParamNames(idx);
        uniqueStr=sprintf('''%s''',dupParamsInUniqueList{1});


        for idx=2:numel(dupParamsInUniqueList)
            uniqueStr=sprintf('%s, ''%s''',uniqueStr,dupParamsInUniqueList{idx});
        end
        duplicateStr=sprintf('''%s''',dupParamNames{1});
        for idx=2:numel(dupParamNames)
            duplicateStr=sprintf('%s, ''%s''',duplicateStr,dupParamNames{idx});
        end

        pm_error('physmod:simscape:engine:sli:block:ParamsDifferingInCaseOnly',...
        duplicateStr,uniqueStr,sourceFile);
    end
end


function variableTargetNames=lGetVariableTargetNames(v)
    variableSuffixes=simscape.engine.sli.internal.maskvariablesuffixes();

    variableTargetNames.icVar=[v,variableSuffixes.varSuffix];
    variableTargetNames.icUnit=[v,variableSuffixes.unitSuffix];
    variableTargetNames.icPriority=[v,variableSuffixes.prioritySuffix];
    variableTargetNames.icSpecify=[v,variableSuffixes.specifySuffix];
    variableTargetNames.nomVal=[v,variableSuffixes.nominalValueSuffix];
    variableTargetNames.nomUnit=[v,variableSuffixes.nominalUnitSuffix];
    variableTargetNames.nomSpecify=[v,variableSuffixes.nominalSpecifySuffix];
end

function paramAdditionalNames=lGetParamAdditionalNames(p)
    paramSuffixes=simscape.engine.sli.internal.maskparametersuffixes();

    paramAdditionalNames.Unit=[p,paramSuffixes.unitSuffix];
    paramAdditionalNames.Conf=[p,paramSuffixes.configurationSuffix];
end

function lValidateParamsAndTargets(paramData,varData)

    params=cell(1,numel(paramData));
    vars=cell(1,numel(varData));
    derivedParams=cell(1,0);
    for idx=1:numel(params)
        params{idx}=paramData(idx).ID;
        derivedParams=[derivedParams,[params{idx},'_unit']];
    end
    for idx=1:numel(vars)
        variableTargetNames=lGetVariableTargetNames(varData(idx).ID);
        vars{idx}=variableTargetNames.icVar;
        derivedParams=[derivedParams,variableTargetNames.icUnit...
        ,variableTargetNames.icPriority,variableTargetNames.icSpecify];
        if~varData(idx).Event
            derivedParams=[derivedParams,variableTargetNames.nomVal,...
            variableTargetNames.nomUnit,variableTargetNames.nomSpecify];
        end
    end

    lowerParams=lower(params);
    lowerVars=lower(vars);
    derivedParams=lower(derivedParams);
    [~,paramVarIdx]=intersect(lowerParams,lowerVars);
    [~,paramDerivedIdx]=intersect(lowerParams,derivedParams);
    [~,varDerivedIdx]=intersect(lowerVars,derivedParams);

    errorStr='';
    if any(paramVarIdx)
        paramStr=lStringify(params(paramVarIdx));
        errorStr='The following parameters differ only in case with public variables:\n%s\n';
        error('simscape:engine:sli:ConflictingParameterNames',errorStr,paramStr);
    end

    if any(paramDerivedIdx)
        paramDerivedStr=lStringify(params(paramDerivedIdx));
        errorStr=sprintf('%sThe following parameters conflict with derived parameters that are used to manage units or variable targets:\n%s\n',...
        errorStr,paramDerivedStr);
    end

    if~isempty(varDerivedIdx)
        varDerivedStr=lStringify(vars(varDerivedIdx));
        errorStr=sprintf('%sThe following variables conflict with derived parameters that are used to manage units or variable targets:\n%s\n',...
        errorStr,varDerivedStr);
    end
    if~isempty(errorStr)
        error('simscape:engine:sli:ParameterClash',errorStr);
    end
end

function str=lStringify(params)
    str='';
    for idx=1:numel(params)
        if idx==1
            str=sprintf('''%s''',params{idx});
        else
            str=sprintf('%s, ''%s''',str,params{idx});
        end
    end


end

function str=lValUnitToMask(in)
    import simscape.engine.sli.internal.cleanmaskvalue;
    if isa(in.Value,'simscape.Value')
        str=cleanmaskvalue(value(in.Value,lGetUnit(in.Unit)));
    else
        assert(ischar(in.Value));
        str=in.Value;
    end
end

function[unit,choices]=lGetUnit(in)
    if ischar(in)
        unit=in;
        if nargout>1
            choices=pm_suggestunits(unit);
        end
    else
        assert(isstruct(in));
        unit=in.Default;
        choices=in.Units;
    end
end






function pm=lGetGlobals
    pm.HIDE='h';
    pm.SHOW='s';


    pm.LITERAL='&';
    pm.EVAL='@';










    pm.INMASK=1;
    pm.DEFAULT_VAL=2;
    pm.FIELD_TYPE=3;
    pm.EVAL_FLAG=4;
    pm.VAR_NAME=5;
    pm.VAR_LABEL=6;
    pm.MASK_VAR_HIDE=7;
    pm.MASK_VAR_TUN=8;
    pm.TYPE_OPTIONS=9;
    pm.MXARRAY_PARAM=10;
    pm.CALLBACK=11;



    pm.MASK_PARAM={pm.SHOW,'','edit',pm.EVAL,'','','off','off',cell(0,1),false,''};

end
