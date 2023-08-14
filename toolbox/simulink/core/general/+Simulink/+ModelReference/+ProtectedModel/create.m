function[harnessHandle,neededVars]=create(input,mode,varargin)




    input=convertStringsToChars(input);
    mode=convertStringsToChars(mode);

    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    import Simulink.ModelReference.ProtectedModel.*;




    try
        assert(strcmpi(mode,'create')||strcmpi(mode,'edit'),'Invalid mode');






        input=locCheckInput(input);



        if(isequal(mod(length(varargin),2),1))
            DAStudio.error('Simulink:protectedModel:protectModelIncorrectNumberOfInputArguments');
        end

        if strcmpi(mode,'create')
            creator=Simulink.ModelReference.ProtectedModel.Creator(input,false);
            stageName=DAStudio.message('Simulink:protectedModel:ProtectedModelCreationMessageViewerStageName');
        else
            creator=Simulink.ModelReference.ProtectedModel.Editor(input,false);
            stageName=DAStudio.message('Simulink:protectedModel:ProtectedModelModificationMessageViewerStageName');
        end

        stageObj=Simulink.output.Stage(stageName,'ModelName',creator.ModelName,'UIMode',false);%#ok<NASGU>

        addGenCodeWasSpecified=false;
        addGeneratedCode=false;

        webviewInfo.value=false;
        webviewInfo.set=false;

        changePasswordSpecified=false;
        specifiedArguments=containers.Map;

        for i=1:2:length(varargin)
            name=varargin{i};
            value=varargin{i+1};

            if isValidSingleString(name)
                name=char(name);
            elseif(~ischar(name))
                DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringForName',...
                nargin-length(varargin)+i);
            end

            lowerCaseName=lower(name);
            switch lowerCaseName
            case{'changesimulationpassword','changeviewpassword','changecodegenerationpassword'}
                if strcmp(mode,'create')
                    DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
                elseif((iscellstr(value)||isstring(value))&&(length(value)==2))
                    value=cellstr(value);
                    if~ischar(value{1})||~ischar(value{2})
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsCellArrayOfStringsValue',name);
                    end

                    switch lowerCaseName
                    case 'changesimulationpassword'
                        encryptionCategory='SIM';
                    case 'changeviewpassword'
                        encryptionCategory='VIEW';
                    case 'changecodegenerationpassword'
                        encryptionCategory='RTW';
                    otherwise
                        assert(false,'An invalid encryption category was used');
                    end
                    creator.changePasswordForEncryptionCategory(encryptionCategory,value);
                    changePasswordSpecified=true;
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsCellArrayOfStringsValue',name);
                end
            case 'modifiable'
                if strcmp(mode,'edit')


                    DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
                elseif(islogical(value))
                    creator.setModifiable(value);
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                end
            case 'path'
                if(ischar(value)||isValidSingleString(value))
                    value=getCharArray(value);
                    creator.setPackagePath(value);
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringValue',name);
                end
            case 'project'
                if(slfeature('ProtectedModelDirectSimulation')<2)
                    DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
                end
                if(islogical(value))
                    creator.setCreateProject(value);
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                end
            case 'projectname'
                if(slfeature('ProtectedModelDirectSimulation')<2)
                    DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
                end
                if(ischar(value)||isValidSingleString(value))
                    value=getCharArray(value);
                    creator.setProjectName(value);
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringValue',name);
                end
            case 'harness'
                if(islogical(value))
                    creator.setCreateHarness(value);
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                end
            case 'report'
                if(islogical(value))
                    if value
                        creator.enableReport();
                    end
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                end
            case 'encrypt'
                if(islogical(value))
                    if value
                        creator.enableEncryption();
                    end
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                end
            case 'addgeneratedcode'
                MSLDiagnostic('Simulink:protectedModel:DeprecatedAddGeneratedCode').reportAsWarning;

                if(islogical(value))
                    addGeneratedCode=value;
                    addGenCodeWasSpecified=true;
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                end

            case 'webview'
                if(islogical(value))
                    webviewInfo.value=value;
                    webviewInfo.set=true;
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                end
            case 'outputformat'
                value=getCharArray(value);
                if(~isempty(value)&&ischar(value))
                    if strcmpi(value,'CompiledBinaries')
                        creator.enablePackagingBinariesOnly;
                    elseif strcmpi(value,'MinimalCode')
                        creator.enablePackagingMinimalCode();
                    elseif strcmpi(value,'AllReferencedHeaders')
                        creator.enablePackagingAllSourceCode();
                    else
                        DAStudio.error('Simulink:protectedModel:InvalidProtectedModelSource',value);
                    end
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringValue',name);
                end
            case 'obfuscatecode'
                if(islogical(value))
                    creator.setObfuscation(value);
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                end

            case 'codeinterface'
                value=getCharArray(value);
                if~ischar(value)
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringValue',name);
                end

                if any(strcmp(value,{'Model reference','Top model'}))
                    creator.setCodeInterface(value);
                else
                    DAStudio.error('Simulink:protectedModel:InvalidProtectedModelCodeInterface',value);
                end
            case 'custompostprocessinghook'
                if(isa(value,'function_handle'))
                    creator.setCustomHookCommand(value);
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsFunctionValue',name);
                end
            case 'callbacks'
                if~iscell(value)
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsCellArray',name);
                end
                creator.setCallbacks(value);
            case 'mode'
                value=getCharArray(value);
                if(~isempty(value)&&ischar(value))
                    creator.setMode(value);
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringValue',name);
                end
            case 'tunableparameters'
                if(slfeature('ProtectedModelTunableParameters')<2)
                    DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
                end
                if(iscellstr(value))
                    creator.setTunableParameters(value);
                elseif isstring(value)&&length(value)>1
                    value=convertStringsToChars(value);
                    creator.setTunableParameters(value);
                else
                    value=getCharArray(value);
                    if ischar(value)
                        if strcmpi(value,'none')
                            creator.setTunableParameters({});
                        elseif strcmpi(value,'all')
                            creator.setTunableParameters({'-all'});
                        else
                            DAStudio.error('Simulink:protectedModel:nameValuePairForTunableParameters');
                        end
                    else
                        DAStudio.error('Simulink:protectedModel:nameValuePairForTunableParameters');
                    end
                end
            case 'accessibleparameters'
                if slfeature('ProtectedModelTunableParameters')~=1
                    DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
                end
                if(iscellstr(value))
                    creator.setAccessibleParameters(value);
                elseif isstring(value)&&length(value)>1
                    value=convertStringsToChars(value);
                    creator.setAccessibleParameters(value);
                else
                    value=getCharArray(value);
                    if ischar(value)&&strcmpi(value,'none')
                        creator.setAccessibleParameters({});
                    elseif(~ischar(value)||~strcmpi(value,'all'))
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsCellArrayOfStringsValue',name);
                    end
                end
            case 'accessiblesignals'
                if slfeature('ProtectedModelTunableParameters')~=1
                    DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
                end
                if(iscellstr(value))
                    creator.setAccessibleSignals(value);
                elseif isstring(value)&&length(value)>1
                    value=convertStringsToChars(value);
                    creator.setAccessibleSignals(value);
                else
                    value=getCharArray(value);
                    if ischar(value)&&strcmpi(value,'none')
                        creator.setAccessibleSignals({});
                    elseif(~ischar(value)||~strcmpi(value,'all'))
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsCellArrayOfStringsValue',name);
                    end
                end
            case 'hdl'
                if(islogical(value))
                    creator.setSupportsHDL(value);
                else
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                end
            case 'sign'
                value=convertStringsToChars(value);
                if~isempty(value)&&ischar(value)
                    creator.setSign(value);
                else
                    error(message('Simulink:modelReference:nameValuePairNeedsStringValue',name));
                end
            otherwise
                DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
            end


            if~isKey(specifiedArguments,lowerCaseName)
                specifiedArguments(lowerCaseName)=lowerCaseName;
            else
                DAStudio.error('Simulink:protectedModel:ProtectedModelParameterAlreadySpecified',name);
            end
        end



        if creator.isViewOnly()&&(webviewInfo.set&&~webviewInfo.value)
            DAStudio.error('Simulink:protectedModel:IncompatibleArgumentsViewOnlyWebview');
        elseif creator.isViewOnly()
            creator.enableSupportForViewOnly();
        elseif webviewInfo.set&&webviewInfo.value
            creator.enableSupportForView();
        end


        if changePasswordSpecified&&~creator.Encrypt
            DAStudio.error('Simulink:protectedModel:IncompatibleArgumentsChangePasswords');
        end



        if~creator.getSupportsHDL()&&~creator.getSupportsC()&&strcmp(creator.Modes,'CodeGeneration')
            DAStudio.error('Simulink:protectedModel:ProtectedModelTargetLanguageAbsent');
        end



        if~creator.supportsCodeGen()&&creator.hasCustomHook()
            DAStudio.error('Simulink:protectedModel:ProtectedModelCustomHookCodegenOnly');
        end


        if creator.getModifiable()&&creator.Sign
            error(message('Simulink:protectedModel:IncompatibleArgumentsModifiableAndSign'));
        end





        if addGenCodeWasSpecified
            if addGeneratedCode

                creator.addSupportForCodegen();
            else
                creator.enableSupportForNormal();
            end
        end


        cleanup=[];
        if creator.Sign
            pwManager=Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('getManager');
            certificate=creator.CertFile;
            if isempty(pwManager.getPasswordForCertificate(certificate))
                cleanup=onCleanup(@()pwManager.clearCertificate(certificate));
            end
            Simulink.ProtectedModel.internal.loadCertificate(certificate);
        end


        [harnessHandle,neededVars]=creator.protect();


        delete(cleanup);
    catch me
        throwAsCaller(me);
    end
end

function out=locCheckInput(input_val)
    out=input_val;
    if(ischar(input_val)||isstring(input_val))
        input=Simulink.ModelReference.ProtectedModel.getCharArray(input_val);
        if~contains(input,'/')


            [~,fname,fext]=fileparts(input);
            if isempty(fext)
                mdlpName=[fname,'.mdlp'];
            else
                mdlpName=input;
            end

            if~(exist(input,'file')==4)&&~(exist(mdlpName,'file')==2)
                DAStudio.error('Simulink:Commands:OpenSystemUnknownSystem',input);
            end
        end
        out=input;
    end
end




