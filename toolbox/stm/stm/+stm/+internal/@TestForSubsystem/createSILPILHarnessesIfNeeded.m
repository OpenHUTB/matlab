function[correspondingSILHarnessCodePaths,sim2ModeToUse,silHarnessNames,preserve_dirty]=createSILPILHarnessesIfNeeded(tForSubsys,options)




    subsys=tForSubsys.subsys;
    subModel=tForSubsys.subModel;
    topModel=tForSubsys.topModel;
    numOfComps=tForSubsys.numOfComps;
    correspondingSILHarnessCodePaths=strings(numOfComps,1);
    sim2ModeToUse=strings(numOfComps,1);
    sim2ModeToUse(:)=tForSubsys.sim2Mode;
    silHarnessNames=strings(numOfComps,1);
    preserve_dirty=[];

    if tForSubsys.testType==sltest.testmanager.TestCaseTypes.Equivalence&&...
        (tForSubsys.sim2Mode=="Software-in-the-Loop (SIL)"||tForSubsys.sim2Mode=="Processor-in-the-Loop (PIL)")


        for i=1:numOfComps
            if tForSubsys.proceedToNextStep(i)
                if Simulink.SubsystemType.isBlockDiagram(subsys(i))

                    assert(subsys(i)~=topModel||(~bdIsLibrary(topModel)&&tForSubsys.createForTopModel));

                    if bdIsSubsystem(subsys(i))
                        eID='stm:TestForSubsystem:HarnessSILPILLimitationForComponent';
                        tForSubsys.populateErrorContainer(MException(eID,message(eID).getString),i);
                    end
                else
                    blkType=get_param(subsys(i),'BlockType');
                    if~(blkType=="SubSystem"||blkType=="ModelReference")


                        eID='stm:TestForSubsystem:HarnessSILPILLimitationForComponent';
                        tForSubsys.populateErrorContainer(MException(eID,message(eID).getString),i);
                    elseif blkType=="SubSystem"&&bdIsLibrary(topModel)&&tForSubsys.fcnInterface==""

                        eID='stm:TestForSubsystem:HarnessSILPILLimitationForLib';
                        tForSubsys.populateErrorContainer(MException(eID,message(eID).getString),i);
                    end
                end
            end
        end



        compIndsToBuildSILHrnssFor=[];
        for i=1:numOfComps
            [isSupported,errmsg]=stm.internal.util.isSupportedAtomicSS(subsys(i));
            if tForSubsys.proceedToNextStep(i)&&Simulink.SubsystemType(subsys(i)).isSubsystem&&...
                tForSubsys.fcnInterface==""&&...
                ~isSupported
                if(get_param(topModel,'AutosarCompliant')=="on")&&(get_param(subsys(i),'type')=="block")&&(get_param(subsys(i),'BlockType')=="SubSystem")



                    if~isempty(errmsg)&&(isa(errmsg{1},"MException")||isa(errmsg{1},"MSLException"))&&...
                        ~strcmp(errmsg{1}.identifier,'PIL:pil_subsystem:SubsystemMustGenerateFunction')
                        tForSubsys.populateErrorContainer(errmsg{1},i);
                        continue;
                    end
                end
                sim2ModeToUse(i)="Normal";

                compIndsToBuildSILHrnssFor=[compIndsToBuildSILHrnssFor,i];%#ok<AGROW>
            end
        end
        subsystemsToBuildSILHarnessFor=subsys(compIndsToBuildSILHrnssFor);


        if~isempty(subsystemsToBuildSILHarnessFor)

            switch(tForSubsys.sim2Mode)
            case "Software-in-the-Loop (SIL)"
                hrnsMode="SIL";
            case "Processor-in-the-Loop (PIL)"
                hrnsMode="PIL";
            end

            uqSetOfsubModels=cellstr(unique(subModel));
            uqSetOfsubModelHandles=cell2mat(get_param(uqSetOfsubModels,"Handle"));
            preserve_dirty=arrayfun(@(x)Simulink.PreserveDirtyFlag(x,'blockDiagram'),uqSetOfsubModelHandles);
            if~tForSubsys.isInBatchMode
                silHrnsNames=string(Simulink.harness.internal.getUniqueName(subModel.char,[subModel.char,'_',hrnsMode.char,'Harness1']));
                [silHarnessInfo,statusOfSILHarnessCreation]=Simulink.harness.internal.createMultipleHarnesses(...
                subsystemsToBuildSILHarnessFor,topModel,...
                'Name',silHrnsNames,...
                'DriveFcnCallWithTestSequence',false,...
                'Source',options.harnessSrcType,...
                'VerificationMode',hrnsMode);
            else
                origSetting=Simulink.harness.getHarnessCreateDefaults().Name;
                Simulink.harness.internal.setHarnessCreateDefaults(Name=['$Component$_',hrnsMode.char,'Harness']);
                ocpObj=onCleanup(@()Simulink.harness.internal.setHarnessCreateDefaults(Name=origSetting));
                [silHarnessInfo,statusOfSILHarnessCreation]=Simulink.harness.internal.createMultipleHarnesses(...
                subsystemsToBuildSILHarnessFor,topModel,...
                'DriveFcnCallWithTestSequence',false,...
                'Source',options.harnessSrcType,...
                'VerificationMode',hrnsMode);
            end

            for i=1:numel(subsystemsToBuildSILHarnessFor)
                if statusOfSILHarnessCreation(i)
                    Simulink.harness.load(subsystemsToBuildSILHarnessFor(i),silHarnessInfo{i}.name);
                    set_param(silHarnessInfo{i}.name,'SaveFormat','Dataset');
                    if silHarnessInfo{i}.param.saveExternally
                        save_system(silHarnessInfo{i}.name);
                    end
                    if options.sldvBackToBackMode
                        try


                            silPilBlk=find_system(silHarnessInfo{i}.name,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'lookundermasks','on','blocktype','S-Function');
                            correspondingSILHarnessCodePaths(compIndsToBuildSILHrnssFor(i))...
                            =get_param(silPilBlk{1},'CodeDir');
                        catch Mex
                        end
                    end
                    Simulink.harness.close(subsystemsToBuildSILHarnessFor(i),silHarnessInfo{i}.name);
                    silHarnessNames(compIndsToBuildSILHrnssFor(i))=silHarnessInfo{i}.name;
                else
                    tForSubsys.populateErrorContainer(silHarnessInfo{i},compIndsToBuildSILHrnssFor(i));
                end
            end
        end
    end
end
