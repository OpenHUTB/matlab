function cloneHarnessForSSConversion(convObj,convLogger)















    conversionParams=convObj.ConversionParameters;
    numberOfSubsystems=numel(conversionParams.Systems);

    for subsysIdx=1:numberOfSubsystems
        currentSubsystem=conversionParams.Systems(subsysIdx);
        assert(ishandle(currentSubsystem)==true,'the variable currentSubsystem is not a handle');

        modelRefName=conversionParams.ModelReferenceNames{subsysIdx};

        origSS2MdlTHVal=slsvTestingHook('IgnoreOwnerTypeCheckDuringClone',1);
        backendCleanupObj=onCleanup(@()slsvTestingHook('IgnoreOwnerTypeCheckDuringClone',origSS2MdlTHVal));




        warn1=warning('off','Simulink:Harness:IndependentHarnessCopyEmbeddedWarning');
        oc1=onCleanup(@()warning(warn1.state,'Simulink:Harness:IndependentHarnessCopyEmbeddedWarning'));

        warn2=warning('off','Simulink:Harness:WarnAboutNameShadowingOnCreationfromCMD');
        oc2=onCleanup(@()warning(warn2.state,'Simulink:Harness:WarnAboutNameShadowingOnCreationfromCMD'));

        harnesses=Simulink.harness.find(currentSubsystem);
        numHarnesses=numel(harnesses);
        for hCtr=1:numHarnesses
            if harnesses(hCtr).verificationMode==0
                try




                    newHarnessName=generateHarnessNameForNewModel(harnesses(hCtr).name,...
                    harnesses(hCtr).model,...
                    modelRefName,...
                    hCtr);
                    tempHarnessName=[newHarnessName,'_1'];










                    if~strcmp(harnesses(hCtr).ownerFullPath,getfullname(currentSubsystem))
                        newHarnessOwnerPath=[modelRefName...
                        ,extractAfter(harnesses(hCtr).ownerFullPath,getfullname(currentSubsystem))];
                    else
                        newHarnessOwnerPath=modelRefName;
                    end





                    Simulink.harness.clone(harnesses(hCtr).ownerFullPath,...
                    harnesses(hCtr).name,...
                    'DestinationOwner',newHarnessOwnerPath,...
                    'Name',tempHarnessName);
                    Simulink.harness.set(newHarnessOwnerPath,...
                    tempHarnessName,'Name',newHarnessName);


                    if conversionParams.UseConversionAdvisor
                        convLogger.addInfo(message...
                        ('Simulink:Harness:HarnessCopiedLoggerInfo',...
                        harnesses(hCtr).name,newHarnessName,newHarnessOwnerPath));
                    else
                        disp(['#### ',DAStudio.message('Simulink:Harness:HarnessCopiedLoggerInfo',...
                        harnesses(hCtr).name,newHarnessName,newHarnessOwnerPath)]);
                    end
                catch ME


                    warning(ME.message)
                    continue
                end
            else

                convLogger.addWarning(message('Simulink:Harness:CannotCopySILPILHarness',harnesses(hCtr).name));
            end
        end
        backendCleanupObj.delete;
        warning(warn1.state,'Simulink:Harness:IndependentHarnessCopyEmbeddedWarning');
        warning(warn2.state,'Simulink:Harness:WarnAboutNameShadowingOnCreationfromCMD');
    end
end

function newHarnessName=generateHarnessNameForNewModel(origName,oldModelName,refModelName,harnessIndex)






    newHarnessName=strrep(origName,oldModelName,refModelName);
    if length(newHarnessName)>58
        newHarnessNamePrefix=newHarnessName(1:45);
        newHarnessName=[newHarnessNamePrefix,'_Harness',num2str(harnessIndex)];
    end
end