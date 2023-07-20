function[testCaseId,harnessInfo]=createHarnessOnly(obj)












    harnessName='';
    subs=obj.subs;

    assert(~obj.isInBatchMode||obj.fcnInterface=="");
    obj.abortIfNoRemainingCUT();

    if obj.createHarness


        if~isempty(obj.harnessOptions)
            p=inputParser;
            p.KeepUnmatched=1;
            p.addParameter('Name','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            p.addParameter('FunctionInterfaceName',[],@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            p.parse(obj.harnessOptions{:});
            assert(any(ismember(p.UsingDefaults,'FunctionInterfaceName')));
            harnessName=p.Results.Name;

        end




        if~obj.isInBatchMode
            if harnessName==""
                if obj.fcnInterface~=""
                    harnessName=Simulink.harness.internal.getUniqueName(obj.subModel.char,[obj.fcnInterface,'_harness1']);
                else
                    harnessName=Simulink.harness.internal.getDefaultName(obj.subModel.char,subs{1}.handle,[]);
                end
                obj.harnessOptions{end+1}='Name';
                obj.harnessOptions{end+1}=harnessName;
            end






            Simulink.harness.create(subs{1}.handle,'FunctionInterfaceName',obj.fcnInterface,obj.harnessOptions{:});


            harnessInfo={Simulink.harness.find(subs{1}.handle,'Name',harnessName)};
            harnessCreationSuccess=1;
        else
            origStatus=obj.proceedToNextStep;
            subsysToCreateHrnssFor=obj.subsys(origStatus);
            [tempHarnessInfo,tempHarnessCreationSuccess]=Simulink.harness.internal.createMultipleHarnesses(subsysToCreateHrnssFor,obj.topModel,obj.harnessOptions{:});
            harnessInfo=cell(obj.numOfComps,1);
            harnessCreationSuccess=false(obj.numOfComps,1);
            harnessInfo(origStatus)=tempHarnessInfo;
            harnessCreationSuccess(origStatus)=tempHarnessCreationSuccess;
        end
    end

    assert(numel(harnessCreationSuccess)==obj.numOfComps,"Incompatible sizes after batch harness creation.");

    testCaseId=zeros(obj.numOfComps,1);

    for i=1:obj.numOfComps


        if obj.proceedToNextStep(i)
            if harnessCreationSuccess(i)
                try
                    testCaseId(i)=stm.internal.createTestFromSubsystem(...
                    obj.parentSuiteID,...
                    obj.subModel(i),...
                    subs{i}.getFullName,...
                    harnessInfo{i}.name,...
                    '',...
                    '',...
                    int32(obj.testType),...
                    false,...
                    false,...
                    false,...
                    obj.isInBatchMode);
                catch me

                    obj.populateErrorContainer(me,i);
                end
            else
                obj.populateErrorContainer(harnessInfo{i},i);
            end
        end
    end



    if~obj.isInBatchMode
        harnessInfo=harnessInfo{1};
    end


    for i=1:obj.numOfComps
        if obj.proceedToNextStep(i)
            tcObj=sltest.testmanager.TestCase([],testCaseId(i));
            tcObj.setProperty('SimulationMode',obj.sim1Mode);
        end
    end

end

