function[success,errMessage]=generateMATLABScript(variantConfigurationObject,variantConfigurationObjectName,outputFileName)








    success=false;
    [~,outputFileNamePart]=fileparts(outputFileName);



    if any(strcmpi(outputFileNamePart,{'tempvarConfigDataNameForInternalUse',...
        'tempconfigObjectForInternalUse','extractVarNameFcnForInternalUse'}))


        msg=message('Simulink:Variants:VariantManagerSaveVCDOFileNameisReserved',outputFileNamePart);
        errMessage=msg.getString();
        return;
    end



    if strcmp(outputFileNamePart,variantConfigurationObjectName)


        msg=message('Simulink:Variants:VariantManagerSaveVCDOFileNameisVCDOName',outputFileNamePart);
        errMessage=msg.getString();
        return;
    end

    [fid,errMessage]=fopen(outputFileName,'w');
    if fid==-1
        return;


    end




    try
        tempDir=[];
        tempFile=[];
        headerText=getString(message('Simulink:Variants:MATLABTimeStampEng',datestr(now),version));
        fprintf(fid,'%s',headerText);
        headerText='% Create and configure Variant Configuration object.';
        fprintf(fid,'%s\n',headerText);

        fprintf(fid,'%s\n',[variantConfigurationObjectName,' = Simulink.VariantConfigurationData;']);


        for i=1:numel(variantConfigurationObject.VariantConfigurations)

            config=variantConfigurationObject.VariantConfigurations(i);
            fprintf(fid,'\n\n%s\n',['% Add configuration ',config.Name,'.']);
            if isempty(config.Description)
                fprintf(fid,'%s\n',[variantConfigurationObjectName,'.addConfiguration(''',config.Name,''');']);
            else
                fprintf(fid,'%s\n',[variantConfigurationObjectName,'.addConfiguration(''',config.Name,''', ''',config.Description,''');']);
            end




            parameterControlVariableSetupScript=[];

            if~isempty(config.ControlVariables)
                hasSourceSpecified=any(strcmp('Source',fieldnames(config.ControlVariables)));
                controlVarStructString='cell2struct({';


                for j=1:numel(config.ControlVariables)
                    if isa(config.ControlVariables(j).Value,'char')
                        controlVarStructString=[controlVarStructString,['''',config.ControlVariables(j).Name,''', ''',config.ControlVariables(j).Value,''' ;']];%#ok<AGROW>
                        if hasSourceSpecified
                            controlVarStructString(end)=[];
                            controlVarStructString=[controlVarStructString,', ''',config.ControlVariables(j).Source,''' ; '];%#ok<AGROW>
                        end
                    elseif isa(config.ControlVariables(j).Value,'Simulink.Parameter')||isa(config.ControlVariables(j).Value,'Simulink.VariantControl')
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
                        if strcmp(parameterVariableName,variantConfigurationObjectName)
                            msg=message('Simulink:Variants:VariantManagerParamNameisVCDOName',...
                            parameterVariableName,class(config.ControlVariables(j).Value),config.Name,variantConfigurationObjectName);
                            expection=MException(msg);
                            throw(expection);
                        end

                        eval([parameterVariableName,' =  config.ControlVariables(j).Value']);
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
                        controlVarStructString=[controlVarStructString,['''',parameterVariableName,''', ',parameterVariableName,';']];%#ok<AGROW>

                        if hasSourceSpecified
                            controlVarStructString(end)=[];
                            controlVarStructString=[controlVarStructString,', ''',config.ControlVariables(j).Source,''' ;'];%#ok<AGROW>
                        end
                    else
                        Simulink.variant.utils.assert(false,'Internal error: Invalid data type for control variable ''%s'' in configuration ''%s''.',...
                        config.ControlVariables(j).Name,config.Name);
                    end
                end

                if~isempty(parameterControlVariableSetupScript)
                    fprintf(fid,'%s \n',parameterControlVariableSetupScript);
                end
                controlVarStructString(end)=[];
                if hasSourceSpecified
                    controlVarStructString=strcat(controlVarStructString,'}, {''Name'', ''Value'', ''Source''}, 2)');
                else
                    controlVarStructString=strcat(controlVarStructString,'}, {''Name'', ''Value''}, 2)');
                end
                fprintf(fid,'\n%s\n',['% Associate variant control variables for configuration ',config.Name,'.']);
                fprintf(fid,'%s\n',[variantConfigurationObjectName,'.addControlVariables(''',config.Name,''', ',controlVarStructString,');']);
            end

            if~isempty(config.SubModelConfigurations)
                subModelConfigStructString='struct(';
                modelNamesCell={config.SubModelConfigurations.ModelName};
                modelConfigurationsCell={config.SubModelConfigurations.ConfigurationName};
                modelNamesCellString='{';
                modelConfigurationsCellString='{';

                for j=1:numel(config.SubModelConfigurations)
                    modelNamesCellString=[modelNamesCellString,['''',modelNamesCell{j},'''; ']];%#ok<AGROW>
                    modelConfigurationsCellString=[modelConfigurationsCellString,['''',modelConfigurationsCell{j},'''; ']];%#ok<AGROW>
                end
                modelNamesCellString(end-1:end)=[];
                modelNamesCellString=strcat(modelNamesCellString,'}');
                modelConfigurationsCellString(end-1:end)=[];
                modelConfigurationsCellString=strcat(modelConfigurationsCellString,'}');
                subModelConfigStructString=strcat(subModelConfigStructString,['''ModelName'', ',modelNamesCellString,...
                ', ''ConfigurationName'', ',modelConfigurationsCellString,'']);
                fprintf(fid,'\n%s\n',['% Associate configurations for submodels for configuration ',config.Name,'.']);
                fprintf(fid,'%s\n',[variantConfigurationObjectName,'.addSubModelConfigurations(''',config.Name,''', ',subModelConfigStructString,'));']);
            end
        end


        if~isempty(variantConfigurationObject.Constraints)
            fprintf(fid,'\n\n%s\n','% Add model-wide constraints.');

            for i=1:numel(variantConfigurationObject.Constraints)
                constraint=variantConfigurationObject.Constraints(i);
                if isempty(constraint.Description)

                    fprintf(fid,'%s\n',[variantConfigurationObjectName,'.addConstraint(''',constraint.Name,''', ''',constraint.Condition,''');']);
                else
                    fprintf(fid,'%s\n',[variantConfigurationObjectName,'.addConstraint(''',constraint.Name,''', ''',constraint.Condition,''', ''',constraint.Description,''');']);
                end
            end
        end


        if~isempty(variantConfigurationObject.DefaultConfigurationName)
            fprintf(fid,'\n\n%s','% Set the default configuration.');
            fprintf(fid,'\n%s',[variantConfigurationObjectName,'.setDefaultConfigurationName(''',variantConfigurationObject.DefaultConfigurationName,''');']);
        end

        if~isempty(tempDir)

            try rmdir(tempDir,'s');end %#ok<TRYNC>
        end
        fclose(fid);



        try
            success=verifySuccessfulMATLABScriptGeneration(outputFileName,variantConfigurationObject,variantConfigurationObjectName);
            Simulink.variant.utils.assert(success);
        catch ME
            msg=message('Simulink:Variants:VariantManagerSaveVCDOUnableToValidateCorrectness');
            expection=MException(msg);
            expection=expection.addCause(ME);
            throw(expection);
        end
    catch ME
        try %#ok<TRYNC>
            try fclose(fid);end %#ok<TRYNC>
        end
        errMessage=Simulink.variant.utils.i_convertMExceptionHierarchyToMessage(ME);
    end
end



function success=verifySuccessfulMATLABScriptGeneration(outputFileNameForInternalUse,configObject,varConfigDataName)%#ok<INUSD>

    configObject.DataDictionaryName='';


    configObject.updateSource(slvariants.internal.config.utils.getGlobalWorkspaceName(''),...
    slvariants.internal.config.utils.getGlobalWorkspaceName_R2020b(''));



    [~,tempvarConfigDataNameForInternalUse]=fileparts(tempname);
    eval([tempvarConfigDataNameForInternalUse,'= varConfigDataName;']);

    [~,tempconfigObjectForInternalUse]=fileparts(tempname);
    eval([tempconfigObjectForInternalUse,'= configObject;']);

    extractVarNameFcnForInternalUse=@(X)inputname(1);
    [~,outputFileNamePart]=fileparts(outputFileNameForInternalUse);

    clear 'varConfigDataName' 'configObject';




    if any(strcmpi(outputFileNamePart,{'outputFileNamePart','outputFileNameForInternalUse'}))
        outputFileName_replaced=outputFileNameForInternalUse;
        clear(extractVarNameFcnForInternalUse(outputFileNamePart));
        run(outputFileName_replaced);
    else
        run(outputFileNameForInternalUse);
    end
    success=isequal(eval(tempconfigObjectForInternalUse),eval(eval(tempvarConfigDataNameForInternalUse)));
end
