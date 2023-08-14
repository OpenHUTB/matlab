function[result,status]=configureTestCasesAndBuildResultsArray(tForSubsys,testCaseId,silHarnessNames,sim2ModeToUse,options)




    subsys=tForSubsys.subsys;
    topModel=tForSubsys.topModel;
    numOfComps=tForSubsys.numOfComps;
    result=cell(numOfComps,1);
    for i=1:numOfComps
        if tForSubsys.proceedToNextStep(i)

            assert(testCaseId(i)>0);
            tcObj=sltest.testmanager.TestCase([],testCaseId(i));
            if tForSubsys.testType==sltest.testmanager.TestCaseTypes.Equivalence

                tcObj.copySimulationSettings(1,2);

                if tForSubsys.sim2Mode=="Software-in-the-Loop (SIL)"||tForSubsys.sim2Mode=="Processor-in-the-Loop (PIL)"

                    if Simulink.SubsystemType(subsys(i)).isSubsystem&&...
                        tForSubsys.fcnInterface==""&&~stm.internal.util.isSupportedAtomicSS(subsys(i))
                        tcObj.setProperty('HarnessName',silHarnessNames(i),...
                        'HarnessOwner',subsys(i),'SimulationIndex',2);


                        if options.harnessSrcType=="Signal Editor"

                            harnessName=tcObj.getProperty('HarnessName');
                            sltest.harness.load(subsys(i),harnessName);
                            sigBlk=stm.internal.blocks.SignalEditorBlock(harnessName);
                            srcFile=sigBlk.getFileName();
                            sltest.harness.close(subsys(i),harnessName);


                            sltest.harness.load(subsys(i),silHarnessNames(i));
                            sigBlk=stm.internal.blocks.SignalEditorBlock(silHarnessNames(i));
                            sigBlk.setFileName(srcFile);
                            sltest.harness.close(subsys(i),silHarnessNames(i));
                        end
                    end
                    if Simulink.SubsystemType(subsys(i)).isSubsystem






                        if~(tForSubsys.fcnInterface==""&&stm.internal.util.isSupportedAtomicSS(subsys(i)))

                            for simIdx=1:2
                                tcObj.setProperty('OverrideModelOutputSettings',true,...
                                'SaveOutput',true,...
                                'SignalLogging',false,...
                                'DSMLogging',false,...
                                'SimulationIndex',simIdx);
                            end
                        end
                    end
                end
                tcObj.setProperty('SimulationMode',tForSubsys.sim1Mode,'SimulationIndex',1);
                tcObj.setProperty('SimulationMode',sim2ModeToUse(i),'SimulationIndex',2);
            end

            tcObj.Releases=string(message('stm:MultipleReleaseTesting:CurrentRelease'));
            result{i}=tcObj;
        else
            assert(testCaseId(i)==0);
            result{i}=tForSubsys.MExTracker{i};
        end
    end
    status=tForSubsys.proceedToNextStep;
    if~tForSubsys.isInBatchMode
        result=result{1};
    end
end
