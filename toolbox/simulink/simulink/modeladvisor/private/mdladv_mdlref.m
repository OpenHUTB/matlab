function varargout=mdladv_mdlref(action,models)












    if nargin~=2
        DAStudio.error('Simulink:tools:MAInvalidNumArgs');
    end

    switch action
    case 'FindModelsWithModelRefAndTunableVars'
        topModel=get_param(models,'Name');
        mdlList=l_FindModelsWithModelRefAndTunableVars(topModel);
        varargout{1}=mdlList;

    case 'FindModelsWithImplicitSignalResolution'
        topModel=get_param(models,'Name');
        [mdlList,failedModelRefs]=l_FindModelsWithImplicitSignalResolution(topModel);
        varargout{1}=mdlList;
        varargout{2}=failedModelRefs;

    case 'ConvertTunableVarsToParameterObjects'
        models=HTMLencode(models,'decode');
        l_ConvertTunableVarsToParameterObjects(models);

    case 'DisableImplicitSignalResolution'
        models=HTMLencode(models,'decode');
        l_DisableImplicitSignalResolution(models);

    otherwise
        DAStudio.error('Simulink:tools:MAUnexpectedAction');
    end




    function mdlList=l_FindModelsWithModelRefAndTunableVars(topModel)




        mdlList=flipud(find_mdlrefs(topModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices));

        if length(mdlList)==1

            mdlList={};
            return;
        end


        for idx=length(mdlList):-1:1
            thisMdl=mdlList{idx};
            closeThisMdl=false;


            if isempty(find_system('Type','block_diagram','Name',thisMdl))
                load_system(thisMdl);
                closeThisMdl=true;
            end


            if isempty(get_param(thisMdl,'TunableVars'))
                mdlList(idx)=[];
            end

            if closeThisMdl
                bdclose(thisMdl);
            end
        end






        function[mdlList,failedModelRefs]=l_FindModelsWithImplicitSignalResolution(topModel)




            [mdlList,blkList]=find_mdlrefs(topModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'WarnForInvalidModelRefs',true);

            failedModelRefs={};
            modelsNoImplicit={};


            for idx=1:length(mdlList)
                thisMdl=mdlList{idx};
                closeThisMdl=false;


                if isempty(find_system('Type','block_diagram','Name',thisMdl))
                    try
                        load_system(thisMdl);
                        closeThisMdl=true;
                    catch
                        if~isempty(blkList)

                            for bIdx=1:length(blkList)


                                mRefs=find_mdlrefs(blkList{bIdx},'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'WarnForInvalidModelRefs',true);
                                if any(ismember(mRefs,thisMdl))
                                    result=['<li><a href="matlab:modeladvisorprivate(''hiliteSystem'',''',blkList{bIdx},''')">',thisMdl,'</a></li>'];
                                    failedModelRefs=[failedModelRefs;result];%#ok<AGROW>
                                    break;
                                end
                            end
                        end
                    end
                end

                try
                    if~strncmp(get_param(thisMdl,'SignalResolutionControl'),'TryResolve',10)
                        modelsNoImplicit=[modelsNoImplicit;mdlList(idx)];%#ok<AGROW>
                    end
                catch
                end

                if closeThisMdl
                    bdclose(thisMdl);
                end

            end

            mdlList=setdiff(mdlList,modelsNoImplicit);




            function l_ConvertTunableVarsToParameterObjects(mdlList)



                l_CallConversionFunction('tunablevars2parameterobjects',mdlList);




                function l_DisableImplicitSignalResolution(mdlList)



                    l_CallConversionFunction('disableimplicitsignalresolution',mdlList);




                    function l_CallConversionFunction(fcnName,mdlList)

                        if~iscell(mdlList)
                            mdlList={mdlList};
                        end


                        for idx=1:length(mdlList)
                            try

                                open_system(mdlList{idx});
                                thisMdl=get_param(mdlList{idx},'Name');



                                evalStr=sprintf('%s %s;',fcnName,thisMdl);

                                if(strcmp(fcnName,'disableimplicitsignalresolution'))
                                    evalc(evalStr);
                                else
                                    eval(evalStr);
                                end

                            catch E
                                MSLDiagnostic('ModelAdvisor:engine:ErrorConvertMdl',thisMdl,E.message).reportAsWarning;
                            end


                        end




