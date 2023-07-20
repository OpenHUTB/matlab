function hisl_0024




    rec=getNewCheckObject('mathworks.hism.hisl_0024',false,@hCheckAlgo,'PostCompile');

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end


function violations=hCheckAlgo(system)

    violations=[];

    if~isequal(system,bdroot(system))
        return;
    end


    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);









    if Simulink.internal.isArchitectureModel(system)

        syshdl=get_param(system,'handle');
        comp=systemcomposer.utils.getArchitecturePeer(syshdl);

        allPorts=systemcomposer.internal.getWrapperForImpl(comp).Ports;

        hInports=allPorts(arrayfun(@(x)strcmp(x.Direction,'Input'),allPorts));
        for i=1:length(hInports)


            if isempty(hInports(i).Interface)
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',hInports(i).SimulinkHandle);
                vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0024_subtitle2');
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0024_warn1');
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0024_rec_action5');
                violations=[violations;vObj];%#ok<AGROW>
            elseif~isa(hInports(i).Interface,'systemcomposer.interface.DataInterface')
                if isempty(str2num(hInports(i).Interface.Dimensions))
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',hInports(i).SimulinkHandle);
                    vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0024_subtitle2');
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0024_warn1');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0024_rec_action5');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end
        end
        return;
    end


    hInports=find_system(system,'SearchDepth',1,'BlockType','Inport');


    hFcnCallInports=unique(find_system(hInports,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'OutputFunctionCall','on'));
    functionCallTrigger=find_system(system,'SearchDepth',1,'BlockType','TriggerPort','TriggerType','function-call');


    hInports=setdiff(hInports,hFcnCallInports);
    hInports=mdlAdvObj.filterResultWithExclusion(hInports);


    if strcmp(get_param(system,'SolverType'),'Variable-step')||...
        (strcmp(get_param(system,'SolverType'),'Fixed-step')&&...
        ~strcmp(get_param(system,'SampleTimeConstraint'),'STIndependent')&&...
        isempty(hFcnCallInports)&&isempty(functionCallTrigger)&&...
        ~hasSimulinkFunction(hInports))


        checkSampleTime=true;
    else
        checkSampleTime=false;
    end


    for i=1:length(hInports)
        curr_inp=hInports{i};




        [sigObjIsUsed,sigObj,~,hasImplicitResolution]=loc_isSignalObjectUsed(system,curr_inp,get_param(system,'SignalResolutionControl'));

        if hasImplicitResolution
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0024_rec_action4');
            violations=[violations;vObj];%#ok<AGROW>
        end




        evaluatedDimension=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_inp,'PortDimensions');
        evaluatedDimension=evaluatedDimension{1};


        if iscell(evaluatedDimension)
            evaluatedDimension=cell2mat(evaluatedDimension);
        end


        evaluatedSampleTime=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_inp,'SampleTime');


        if~sigObjIsUsed

            if strcmp(get_param(curr_inp,'OutDataTypeStr'),'Inherit: auto')
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0024_rec_action1');
                vObj.CheckAlgoID='hisl_0024_a';
                violations=[violations;vObj];%#ok<AGROW>
            end

            if(evaluatedDimension(1)==-1)
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0024_rec_action2');
                vObj.CheckAlgoID='hisl_0024_b';
                violations=[violations;vObj];%#ok<AGROW>
            end

            if checkSampleTime
                if loc_isInheritedSampleTime(evaluatedSampleTime{1})
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0024_rec_action3');
                    vObj.CheckAlgoID='hisl_0024_c';
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end


        else

            if~Advisor.Utils.Simulink.isEnumOutDataTypeStr(system,sigObj.DataType)

                if strcmp(sigObj.DataType,'auto')&&...
...
                    strcmp(get_param(curr_inp,'OutDataTypeStr'),'Inherit: auto')
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0024_rec_action1');
                    vObj.CheckAlgoID='hisl_0024_a';
                    violations=[violations;vObj];%#ok<AGROW>
                end


                if(sigObj.Dimensions(1)==-1)&&...
...
                    (evaluatedDimension(1)==-1)
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0024_rec_action2');
                    vObj.CheckAlgoID='hisl_0024_b';
                    violations=[violations;vObj];%#ok<AGROW>
                end


                if checkSampleTime
                    if loc_isInheritedSampleTime(sigObj.SampleTime)&&...
...
                        loc_isInheritedSampleTime(evaluatedSampleTime{1})
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0024_rec_action3');
                        vObj.CheckAlgoID='hisl_0024_c';
                        violations=[violations;vObj];%#ok<AGROW>
                    end
                end
            end
        end
    end
end




function status=loc_isInheritedSampleTime(sampleTime)
    if length(sampleTime)>1&&(sampleTime(1)==-1)&&(sampleTime(2)==0)
        status=true;
    elseif length(sampleTime)==1&&(sampleTime(1)==-1)
        status=true;
    else
        status=false;
    end
end

function[status,sigObj,sigObjName,hasImplicitResolution]=loc_isSignalObjectUsed(system,hInport,signalResolutionControl)

    sigObj=[];
    sigObjName='';
    hasImplicitResolution=false;




    outSignalNames=get_param(hInport,'OutputSignalNames');

    if(isequal(signalResolutionControl,'None')||...
        isempty(outSignalNames)||isempty(outSignalNames{1})||...
        ~isvarname(outSignalNames{1}))

        usesSignalObj=false;

    else

        lineHandles=get_param(hInport,'LineHandles');

        if(~isempty(lineHandles)&&~isempty(lineHandles(1).Outport)&&...
            get(lineHandles(1).Outport,'MustResolveToSignalObject'))

            sigObjName=outSignalNames{1};


            sigObj=loc_getSigObj(system,sigObjName);

            if isempty(sigObj)
                usesSignalObj=false;
            else
                usesSignalObj=true;
            end


        elseif(strncmp(signalResolutionControl,'TryResolve',10)&&...
            ~isempty(lineHandles)&&~isempty(lineHandles(1).Outport))

            sigObjName=outSignalNames{1};
            implicitSigObj=loc_getSigObj(system,sigObjName);



            usesSignalObj=false;

            if~isempty(implicitSigObj)
                hasImplicitResolution=true;
            end

        else


            usesSignalObj=false;
        end
    end

    status=usesSignalObj;
end

function sigObj=loc_getSigObj(system,sigObjName)
    modelObj=get_param(system,'object');

    if existsInGlobalScope(system,sigObjName)&&...
        isa(evalinGlobalScope(system,sigObjName),'Simulink.Signal')

        sigObj=evalinGlobalScope(system,sigObjName);

    elseif~isempty(modelObj.ModelWorkspace)&&modelObj.ModelWorkspace.hasVariable(sigObjName)&&...
        isa(modelObj.ModelWorkspace.getVariable(sigObjName),'Simulink.Signal')

        sigObj=modelObj.ModelWorkspace.getVariable(sigObjName);

    else
        sigObj=[];
    end
end

function has_simulink_function=hasSimulinkFunction(hInports)
    has_simulink_function=false;
    for i=1:length(hInports)
        inport=get_param(get_param(hInports{i},'handle'),'object');
        if~ishandle(inport.LineHandles.Outport)
            continue;
        end
        outport=get_param(inport.LineHandles.Outport,'object');
        if~ishandle(outport.DstBlockHandle)
            continue;
        end
        dstHandles=outport.DstBlockHandle;
        for count=1:length(dstHandles)
            if~ishandle(dstHandles(count))
                continue;
            end
            blk=get_param(dstHandles(count),'object');
            if strcmp(blk.BlockType,'SubSystem')
                subsystem_path=blk.getFullName();
                trigger_port=find_system(subsystem_path,'SearchDepth',1,...
                'BlockType','TriggerPort');

                if strcmp(get_param(trigger_port,'isSimulinkFunction'),'on')
                    has_simulink_function=true;
                    return;
                end
            end
        end
    end
end