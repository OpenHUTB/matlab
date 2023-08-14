function appendReducerOptions(rpt)





    import mlreportgen.dom.*



    optionsMsg=message('Simulink:VariantReducer:ReducerOptions');
    redopts=Heading1(optionsMsg.getString());
    redopts.Style={Bold,Color('black'),BackgroundColor('white')};
    idAttr=CustomAttribute('id','reducerOptions');
    redopts.CustomAttributes=idAttr;
    append(rpt,redopts);





    vrConfigMsg=message('Simulink:VariantReducer:ConfigHeading');
    configuration=Heading2(vrConfigMsg.getString());
    configuration.Style={Bold,Color('black'),BackgroundColor('white')};
    append(rpt,configuration);

    configs=rpt.RepData.Configurations;
    if isempty(configs)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(rpt,par);
    else

        vrConfigAbstractMsg=message('Simulink:VariantReducer:ConfigAbstract');
        vrConfigAbstract=Paragraph(vrConfigAbstractMsg.getString());
        vrConfigAbstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
        idAttr=CustomAttribute('id','configabstract');
        vrConfigAbstract.CustomAttributes=idAttr;
        append(rpt,vrConfigAbstract);


        if~isempty(rpt.RepData.VarSpecAsNaN)
            dcMsg=message('Simulink:VariantReducer:DCMessage');

            dcPar=Paragraph(dcMsg.getString());
            dcPar.Style={Bold,Color('black')};
            append(rpt,dcPar);


            dcVarList=UnorderedList(sort(rpt.RepData.VarSpecAsNaN)');
            append(rpt,dcVarList);
        end




        i_fillConfigsList(rpt,configs);
    end


    if slfeature('VRedReduceForCodegen')>0&&strcmp(rpt.RepData.CompileMode,'codegen')
        vrCompileModeGroup=Container();
        vrCompileModeMsg=message('Simulink:VariantReducer:CompilationMode');
        compileMode=Heading2(vrCompileModeMsg.getString());
        compileMode.Style={Bold,Color('black'),BackgroundColor('white')};
        append(vrCompileModeGroup,compileMode);

        cmList=UnorderedList();
        redForCodegenMsg=message('Simulink:VariantReducer:CompileMode');
        redForCodegen=ListItem([redForCodegenMsg.getString(),' ',rpt.RepData.CompileMode]);
        append(cmList,redForCodegen);

        append(vrCompileModeGroup,cmList);
        append(rpt,vrCompileModeGroup);
    end


    excludeFiles=rpt.RepData.ExcludeFiles;
    if Simulink.variant.reducer.utils.isExcludeFilesOptionValid()&&~isempty(excludeFiles)
        vrExcludeFilesGroup=Container();
        excludeFilesMsg=message('Simulink:VariantReducer:ExcludeFiles');
        excludeFilesH=Heading2(excludeFilesMsg.getString());
        excludeFilesH.Style={Bold,Color('black'),BackgroundColor('white')};
        append(vrExcludeFilesGroup,excludeFilesH);

        excludeFilesAbstractMsg=message('Simulink:VariantReducer:ExcludeFilesAbstract');
        excludeFilesAbstract=Paragraph(excludeFilesAbstractMsg.getString());
        excludeFilesAbstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
        idAttr=CustomAttribute('id','skipfilesabstract');
        excludeFilesAbstract.CustomAttributes=idAttr;
        append(vrExcludeFilesGroup,excludeFilesAbstract);

        sfList=UnorderedList();
        idAttr=CustomAttribute('id','excludeFilesList');
        sfList.CustomAttributes=idAttr;
        for idx=1:numel(excludeFiles)
            append(sfList,excludeFiles{idx});
        end
        append(vrExcludeFilesGroup,sfList);
        append(rpt,vrExcludeFilesGroup);
    end






    outspecGroup=Container();
    outSpecMsg=message('Simulink:VariantReducer:OutputSpec');
    outspec=Heading2(outSpecMsg.getString());
    outspec.Style={Bold,Color('black'),BackgroundColor('white')};
    append(outspecGroup,outspec);

    outspecAbstractMsg=message('Simulink:VariantReducer:OutputSpecAbstract');
    outspecAbstract=Paragraph(outspecAbstractMsg.getString());
    outspecAbstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','outspecabstract');
    outspecAbstract.CustomAttributes=idAttr;
    append(outspecGroup,outspecAbstract);

    optList=UnorderedList();



    outFolderMsg=message('Simulink:VariantReducer:OutputFolder');
    outputFolder=ListItem([outFolderMsg.getString(),' ',rpt.RepData.OutputFolder]);

    append(optList,outputFolder);


    mdlSuffixMsg=message('Simulink:VariantReducer:ModelSuffix');
    suffix=ListItem([mdlSuffixMsg.getString(),' ',rpt.RepData.ModelSuffix]);
    append(optList,suffix);


    prSigAttribMsg=message('Simulink:VariantReducer:PreserveSigAttrib');
    preserveSigAttrib=ListItem([prSigAttribMsg.getString(),' ',i_convertLogicalToChar(rpt.RepData.ReducerFlags.PreserveSignalAttributes)]);
    append(optList,preserveSigAttrib);


    verboseMsg=message('Simulink:VariantReducer:Verbose');
    verboseFlag=ListItem([verboseMsg.getString(),' ',i_convertLogicalToChar(rpt.RepData.ReducerFlags.Verbose)]);
    append(optList,verboseFlag);

    append(outspecGroup,optList);


    idAttr=CustomAttribute('id','outputSpec');
    outspecGroup.CustomAttributes=idAttr;

    append(rpt,outspecGroup);
end

function valStr=i_convertLogicalToChar(logicalVal)
    if logicalVal
        valStr='true';
    else
        valStr='false';
    end
end

function i_fillConfigsList(rpt,configs)
    import mlreportgen.dom.*


    configContainer=Container();

    for configId=1:numel(configs)

        configGroup=Container();

        if~strcmp(configs(configId).ModelName,rpt.RepData.OrigTopModelName)
            continue;
        end

        i_fillConfigGroup(configGroup,configs,configId,3);


        idAttr=CustomAttribute('id',configs(configId).Name);
        configGroup.CustomAttributes=idAttr;

        append(configContainer,configGroup);
    end



    if isempty(configs)
        currVarValMsg=message('Simulink:VariantReducer:CurrentVarControlVals');
        configDef=Heading3(currVarValMsg.getString());
        configDef.Style={Bold,Color('black'),BackgroundColor('white')};
        append(configContainer,configDef);


        vcVarMsgDef=message('Simulink:VariantReducer:VariantVariables');
        vcVarDef=Paragraph(vcVarMsgDef.getString());
        vcVarDef.Style={Bold,Color('black'),BackgroundColor('white')};
        append(configContainer,vcVarDef);

        vcvariables=Simulink.VariantManager.findVariantControlVars(rpt.RepData.OrigTopModelName);
        vcList=UnorderedList();
        for varId=1:numel(vcvariables)
            vcName=vcvariables(varId).Name;
            vcValue=i_getValueString(vcvariables(varId).Value);



            vcnameeq=[vcName,' = '];
            [nrows,~]=size(vcValue);
            vcNameToAppend=[vcnameeq;repmat(' ',nrows-1,numel(vcnameeq))];
            vcItemText=Text([vcNameToAppend,vcValue]);


            append(vcList,vcItemText);
        end

        append(configContainer,vcList);
    end


    idAttr=CustomAttribute('id','variantConfigurations');
    configContainer.CustomAttributes=idAttr;


    append(rpt,configContainer);
end

function varValue=i_getValueString(value)
    if isa(value,'Simulink.VariantControl')
        value=value.Value;
    end
    if isa(value,'Simulink.Parameter')
        varValue=Simulink.variant.reducer.utils.i_num2str(value.Value);
    else
        varValue=Simulink.variant.reducer.utils.i_num2str(value);
    end
end

function i_fillConfigGroup(configGroup,allconfigs,configId,level,varargin)
    import mlreportgen.dom.*

    if nargin==4
        mdlName='';
    else
        mdlName=[varargin{1},' : '];
    end

    config=allconfigs(configId);


    configName=Heading(level,[mdlName,config.Name]);
    configName.Style={Bold,Color('black'),BackgroundColor('white')};
    append(configGroup,configName);


    vcVarMsg=message('Simulink:VariantReducer:VariantVariables');
    vcVar=Paragraph(vcVarMsg.getString());
    vcVar.Style={Bold,Color('black'),BackgroundColor('white')};
    append(configGroup,vcVar);


    if~isempty(config.ControlVariables)
        varList=UnorderedList();
        [~,sidx]=sort({config.ControlVariables.Name});
        config.ControlVariables=config.ControlVariables(sidx);
        for ctrlVarId=1:numel(config.ControlVariables)
            varName=config.ControlVariables(ctrlVarId).Name;
            varVal=i_getValueString(config.ControlVariables(ctrlVarId).Value);
            itemText=Text([varName,' = ',varVal]);
            append(varList,itemText);
        end


        append(configGroup,varList);
    end

    if~isempty(config.SubModelConfigurations)

        subModelsMsg=message('Simulink:VariantReducer:SubModelConfigs');
        subMdlC=Paragraph(subModelsMsg.getString());
        subMdlC.Style={Bold,Color('black'),BackgroundColor('white')};
        append(configGroup,subMdlC);

        for subCId=1:numel(config.SubModelConfigurations)
            subMdlName=config.SubModelConfigurations(subCId).ModelName;
            subMdlConfig=config.SubModelConfigurations(subCId).ConfigurationName;
            subconfigId=arrayfun(@(x)(strcmp(x.Name,subMdlConfig)&&strcmp(x.ModelName,subMdlName)),allconfigs);
            if any(subconfigId)
                subconfigGroup=Container();
                i_fillConfigGroup(subconfigGroup,allconfigs,subconfigId,4,subMdlName);
                append(configGroup,subconfigGroup);
            end
        end
    end
end



