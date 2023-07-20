function exportToMFile(configObject,varConfigDataName,fileName)



    generateMATLABScript(configObject,varConfigDataName,fileName);
end

function generateMATLABScript(configObject,varConfigDataName,fileName)
    [~,outputFileNamePart]=fileparts(fileName);


    if any(strcmpi(outputFileNamePart,{'tempvarConfigDataNameForInternalUse',...
        'tempconfigObjectForInternalUse','extractVarNameFcnForInternalUse'}))
        msg=message('Simulink:Variants:VariantManagerSaveVCDOFileNameisReserved',outputFileNamePart);
        expection=MException(msg);
        throw(expection);
    end



    if strcmp(outputFileNamePart,varConfigDataName)
        msg=message('Simulink:Variants:VariantManagerSaveVCDOFileNameisVCDOName',outputFileNamePart);
        expection=MException(msg);
        throw(expection);
    end

    fileWriter=slvariants.internal.manager.ui.config.FileWriter;
    fileWriter.createFileWriter(fileName);

    try
        generateMATLABScriptHelper(configObject,varConfigDataName,fileWriter);
    catch ME
        fileWriter.deleteFile();
        throw(ME);
    end
end

function generateMATLABScriptHelper(configObject,varConfigDataName,fileWriter)
    tempDir=[];
    headerText=getString(message('Simulink:Variants:MATLABTimeStampEng',datestr(now),version));
    fileWriter.write(headerText);
    headerText='% Create and configure Variant Configurations object.';
    fileWriter.write(headerText);
    fileWriter.appendLines(1);

    fileWriter.write([varConfigDataName,' = Simulink.VariantConfigurationData;']);
    fileWriter.appendLines(1);

    generateConfigurationsScript(configObject,fileWriter,varConfigDataName,tempDir);


    generateConstraintsScript(configObject,fileWriter,varConfigDataName);


    if~isempty(configObject.PreferredConfiguration)
        fileWriter.appendLines(2);
        fileWriter.write('% Set the preferred configuration.');
        fileWriter.appendLines(1);
        fileWriter.write([varConfigDataName,'.setPreferredConfiguration(''',configObject.PreferredConfiguration,''');']);
    end

    if~isempty(tempDir)

        try rmdir(tempDir,'s');end %#ok<TRYNC>
    end
end

function generateConfigurationsScript(varConfigs,fileWriter,varConfigDataName,tempDir)

    if numel(varConfigs.Configurations)<0
        return;
    end

    fileWriter.appendLines(2);
    fileWriter.write('% Add variant configurations.');
    fileWriter.appendLines(1);

    fileWriter.write('configurationsList = struct(''Name'', {}, ''ControlVariables'', {}, ''Description'', {});');
    fileWriter.appendLines(1);

    comp2Configs=struct('ConfigurationName','','ComponentName','','ComponentConfigurationName','');
    comp2Configs(1)=[];


    for configIdx=1:numel(varConfigs.Configurations)
        config=varConfigs.Configurations(configIdx);
        fileWriter.appendLines(2);
        fileWriter.write(['% Add configuration ',config.Name,'.']);
        fileWriter.appendLines(2);




        parameterControlVariableSetupScript=[];

        if~isempty(config.ControlVariables)
            controlVarStructString='cell2struct({';


            [controlVarStructString,parameterControlVariableSetupScript]=...
            generateControlVariablesScript(config,varConfigDataName,...
            controlVarStructString,tempDir,parameterControlVariableSetupScript);

            if~isempty(parameterControlVariableSetupScript)
                fileWriter.write(parameterControlVariableSetupScript);
                fileWriter.appendLines(1);
            end
            controlVarStructString(end)=[];
            controlVarStructString=strcat(controlVarStructString,'}, {''Name'', ''Value'', ''Source''}, 2)');
            fileWriter.appendLines(1);
            fileWriter.write(['% Associate variant control variables for configuration ',config.Name,'.']);
        else
            controlVarStructString='struct(''Name'', {}, ''Value'', {}, ''Source'', {})';
        end


        varConfigsIth=varConfigs.VariantConfigurations(configIdx);
        for compConfigsIdx=1:length(varConfigsIth.SubModelConfigurations)
            comp2Configs(end+1).ConfigurationName=config.Name;%#ok<AGROW> 
            comp2Configs(end).ComponentName=varConfigsIth.SubModelConfigurations(compConfigsIdx).ModelName;
            comp2Configs(end).ComponentConfigurationName=varConfigsIth.SubModelConfigurations(compConfigsIdx).ConfigurationName;
        end


        fileWriter.appendLines(1);
        fileWriter.write(['configurationsList(end+1) = '...
        ,'struct(''Name'' , ''',config.Name,''','...
        ,' ''ControlVariables'', ',controlVarStructString,','...
        ,' ''Description'', ''',config.Description,''');']);
        fileWriter.appendLines(1);
    end



    fileWriter.write([varConfigDataName,'.setConfigurations(configurationsList);']);

    if~isempty(comp2Configs)
        fileWriter.write('% Associate component configurations');
        fileWriter.appendLines(1);
    end
    for ii=1:length(comp2Configs)
        fileWriter.write([varConfigDataName,'.addComponentConfiguration('...
        ,'''ConfigurationName'', ''',comp2Configs(ii).ConfigurationName,''','...
        ,' ''ComponentName'', ''',comp2Configs(ii).ComponentName,''','...
        ,' ''ComponentConfigurationName'', ''',comp2Configs(ii).ComponentConfigurationName,''','...
        ,' ''PopulateControlVariables'', false);']);
        fileWriter.appendLines(1);
    end

    fileWriter.appendLines(1);
end

function generateConstraintsScript(configObject,fileWriter,varConfigDataName)
    if isempty(configObject.Constraints)
        return;
    end

    fileWriter.appendLines(2);
    fileWriter.write('% Add model-wide constraints.');
    fileWriter.appendLines(1);

    fileWriter.write('constraintsList = struct(''Name'', {}, ''Condition'', {}, ''Description'', {});');
    fileWriter.appendLines(1);


    for i=1:numel(configObject.Constraints)
        constraint=configObject.Constraints(i);
        constraintCondition=regexprep(constraint.Condition,'''','''''');
        fileWriter.write(['constraintsList(end + 1) = '...
        ,'struct(''Name'', ''',constraint.Name,''', ''Condition'', ''',constraintCondition,''','...
        ,' ''Description'', ''',constraint.Description,''');']);
        fileWriter.appendLines(1);
    end

    fileWriter.appendLines(1);
    fileWriter.write([varConfigDataName,'.setConstraints(constraintsList)']);
    fileWriter.appendLines(1);
end

function[controlVarStructString,parameterControlVariableSetupScript]=...
    generateControlVariablesScript(config,varConfigDataName,...
    controlVarStructString,tempDir,parameterControlVariableSetupScript)

    tempFile=[];
    for j=1:numel(config.ControlVariables)
        if isempty(tempDir)



            tempDir=tempname;
            if mkdir(tempDir)
                tempFile=[tempDir,filesep,'VariantManagerHelper.m'];
            else
                msg=message('Simulink:Variants:VariantManagerSaveVCDOTmpDirFailure',fileparts(tempDir));
                expection=MException(msg);
                throw(expection);
            end
        end
        parameterVariableName=config.ControlVariables(j).Name;
        if strcmp(parameterVariableName,varConfigDataName)
            msg=message('Simulink:Variants:VariantManagerParamNameisVCDOName',...
            parameterVariableName,class(config.ControlVariables(j).Value),config.Name,varConfigDataName);
            expection=MException(msg);
            throw(expection);
        end

        eval([parameterVariableName,' =  config.ControlVariables(j).Value;']);
        try
            [~,variablesSavedToMatFile]=matlab.io.saveVariablesToScript(tempFile,parameterVariableName,'SaveMode','create');
            Simulink.variant.utils.assert(isempty(variablesSavedToMatFile));
        catch
            msg=message('Simulink:Variants:VariantManagerSaveVCDOUnableToValidateCorrectness');
            expection=MException(msg);
            throw(expection);
        end
        parameterVariableScript=fileread(tempFile);
        varInfoStruct=matlab.io.savevars.internal.getVariableCodelineRangefromMFile(tempFile);
        lineNumStart=varInfoStruct.(parameterVariableName)(1);
        lineNumEnd=varInfoStruct.(parameterVariableName)(2);
        lineBreakLoc=regexp(parameterVariableScript,'\n');
        parameterVariableScript=parameterVariableScript(lineBreakLoc(lineNumStart-1):lineBreakLoc(lineNumEnd)-1);
        parameterVariableScript=[newline,'% Configure control variable ',parameterVariableName,'.',parameterVariableScript,newline];%#ok<AGROW>
        parameterControlVariableSetupScript=strcat(parameterControlVariableSetupScript,parameterVariableScript);
        controlVarStructString=[controlVarStructString,['''',parameterVariableName,''', ',parameterVariableName,', ''',config.ControlVariables(j).Source,''';']];%#ok<AGROW>
    end
end


