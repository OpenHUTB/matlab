function hisl_0077




    rec=getNewCheckObject('mathworks.hism.hisl_0077',false,@hCheckAlgo,'PostCompile');
    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{1}.Name=DAStudio.message('ModelAdvisor:hism:hisl_0077_Check_Sample_Time_Property');
    inputParamList{1}.Type='Bool';
    inputParamList{1}.Visible=false;
    inputParamList{1}.Value=true;
    inputParamList{1}.RowSpan=[1,1];
    inputParamList{1}.ColSpan=[1,2];

    rec.setLicense({HighIntegrity_License});
    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end


function violations=hCheckAlgo(system)

    violations=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    checkTsProperty=inputParams{1}.Value;


    if~isequal(system,bdroot(system))
        return;
    end


    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);



    hOutports=find_system(system,'SearchDepth',1,'BlockType','Outport');
    hOutports=mdlAdvObj.filterResultWithExclusion(hOutports);










    if Simulink.internal.isArchitectureModel(system)

        syshdl=get_param(system,'handle');
        comp=systemcomposer.utils.getArchitecturePeer(syshdl);

        allPorts=systemcomposer.internal.getWrapperForImpl(comp).Ports;

        hOutports=allPorts(arrayfun(@(x)strcmp(x.Direction,'Output'),allPorts));
        for i=1:length(hOutports)


            if isempty(hOutports(i).Interface)
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',hOutports(i).SimulinkHandle);
                vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0077_subtitle2');
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0077_warn5');
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0077_rec_action5');
                violations=[violations;vObj];%#ok<AGROW>
            elseif~isa(hOutports(i).Interface,'systemcomposer.interface.DataInterface')
                if isempty(str2num(hOutports(i).Interface.Dimensions))
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',hOutports(i).SimulinkHandle);
                    vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0077_subtitle2');
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0077_warn5');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0077_rec_action5');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end
        end
        return;
    end





    if checkTsProperty&&(strcmp(get_param(system,'SolverType'),'Variable-step')||...
        (strcmp(get_param(system,'SolverType'),'Fixed-step')&&...
        ~strcmp(get_param(system,'SampleTimeConstraint'),'STIndependent')))


        checkSampleTime=true;
    else
        checkSampleTime=false;
    end


    for i=1:length(hOutports)

        curr_out=hOutports{i};



        [sigObjIsUsed,sigObj,~,hasImplicitResolution]=loc_isSignalObjectUsed(system,curr_out,get_param(system,'SignalResolutionControl'));

        if hasImplicitResolution
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_out);
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0077_warn4');
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0077_rec_action4');
            violations=[violations;vObj];%#ok<AGROW>
        end




        evaluatedDimension=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_out,'PortDimensions');
        evaluatedDimension=evaluatedDimension{1};


        if iscell(evaluatedDimension)
            evaluatedDimension=cell2mat(evaluatedDimension);
        end

        evaluatedSampleTime=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_out,'SampleTime');



        if~sigObjIsUsed

            if strcmp(get_param(curr_out,'OutDataTypeStr'),'Inherit: auto')
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_out);
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0077_warn1');
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0077_rec_action1');
                vObj.CheckAlgoID='hisl_0077_a';
                violations=[violations;vObj];%#ok<AGROW>
            end

            if(evaluatedDimension(1)==-1)
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_out);
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0077_warn2');
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0077_rec_action2');
                vObj.CheckAlgoID='hisl_0077_b';
                violations=[violations;vObj];%#ok<AGROW>
            end

            if checkSampleTime
                if loc_isInheritedSampleTime(evaluatedSampleTime{1})
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_out);
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0077_warn3');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0077_rec_action3');
                    vObj.CheckAlgoID='hisl_0077_c';
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end


        else

            if~Advisor.Utils.Simulink.isEnumOutDataTypeStr(system,sigObj.DataType)

                if strcmp(sigObj.DataType,'auto')&&...
...
                    strcmp(get_param(curr_out,'OutDataTypeStr'),'Inherit: auto')
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_out);
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0077_warn1');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0077_rec_action1');
                    vObj.CheckAlgoID='hisl_0077_a';
                    violations=[violations;vObj];%#ok<AGROW>
                end


                if(sigObj.Dimensions(1)==-1)&&...
...
                    (evaluatedDimension(1)==-1)
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_out);
                    vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0077_warn2');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0077_rec_action2');
                    vObj.CheckAlgoID='hisl_0077_b';
                    violations=[violations;vObj];%#ok<AGROW>
                end


                if checkSampleTime
                    if loc_isInheritedSampleTime(sigObj.SampleTime)&&...
...
                        loc_isInheritedSampleTime(evaluatedSampleTime{1})
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_out);
                        vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0077_warn3');
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0077_rec_action3');
                        vObj.CheckAlgoID='hisl_0077_c';
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

function[status,sigObj,sigObjName,hasImplicitResolution]=loc_isSignalObjectUsed(system,hOutport,signalResolutionControl)

    sigObj=[];
    sigObjName='';
    hasImplicitResolution=false;




    outSignalNames=get_param(hOutport,'InputSignalNames');

    if(isequal(signalResolutionControl,'None')||...
        isempty(outSignalNames)||isempty(outSignalNames{1})||...
        ~isvarname(outSignalNames{1}))

        usesSignalObj=false;

    else

        lineHandles=get_param(hOutport,'LineHandles');

        if(~isempty(lineHandles)&&~isempty(lineHandles(1).Inport)&&...
            get(lineHandles(1).Inport,'MustResolveToSignalObject'))

            sigObjName=outSignalNames{1};


            sigObj=loc_getSigObj(system,sigObjName);

            if isempty(sigObj)
                usesSignalObj=false;
            else
                usesSignalObj=true;
            end





        elseif(strncmp(signalResolutionControl,'TryResolve',10)&&...
            ~isempty(lineHandles)&&~isempty(lineHandles(1).Inport))

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

