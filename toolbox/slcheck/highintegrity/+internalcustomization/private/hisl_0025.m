function hisl_0025




    rec=getNewCheckObject('mathworks.hism.hisl_0025',false,@hCheckAlgo,'PostCompile');

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)

    violations=[];


    system=bdroot(system);


    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    hInports=find_system(system,'SearchDepth',1,'BlockType','Inport');
    hInports=mdlAdvObj.filterResultWithExclusion(hInports);






    hFcnCallInports=unique(find_system(hInports,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'OutputFunctionCall','on'));
    hInports=setdiff(hInports,hFcnCallInports);











    if Simulink.internal.isArchitectureModel(system)

        syshdl=get_param(system,'handle');
        comp=systemcomposer.utils.getArchitecturePeer(syshdl);

        allPorts=systemcomposer.internal.getWrapperForImpl(comp).Ports;

        hInports=allPorts(arrayfun(@(x)strcmp(x.Direction,'Input'),allPorts));
        for i=1:length(hInports)

            if isempty(hInports(i).Interface)
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',hInports(i).SimulinkHandle);
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0025_warn1');
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action6');
                violations=[violations;vObj];%#ok<AGROW>
            else

                interface=hInports(i).Interface;

                if isa(hInports(i).Interface,'systemcomposer.interface.DataInterface')

                    elems=interface.Elements;
                    for j=1:length(elems)
                        minVal=str2num(elems(j).Type.Minimum);
                        maxVal=str2num(elems(j).Type.Maximum);

                        if isempty(minVal)||isempty(maxVal)
                            vObj=ModelAdvisor.ResultDetail;
                            ModelAdvisor.ResultDetail.setData(vObj,'SID',hInports(i).SimulinkHandle);
                            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0025_warn1');
                            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action6');
                            violations=[violations;vObj];%#ok<AGROW>
                            break;
                        end
                    end
                else

                    minVal=str2num(interface.Minimum);
                    maxVal=str2num(interface.Maximum);

                    if isempty(minVal)||isempty(maxVal)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',hInports(i).SimulinkHandle);
                        vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0025_warn1');
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action6');
                        violations=[violations;vObj];%#ok<AGROW>
                    end
                end
            end
        end
        return;
    end


    hEnumPorts=detectEnumAndBoolPorts(system,hInports);
    hInports=setdiff(hInports,hEnumPorts);

    for i=1:length(hInports)
        curr_inp=hInports{i};


        [isSigObjUsed,sigObj,~,hasImplicitResolution]=loc_isSignalObjectUsed(system,curr_inp,get_param(system,'SignalResolutionControl'));

        if hasImplicitResolution
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action1');
            violations=[violations;vObj];%#ok<AGROW>
        end

        hasBusSignal=loc_isBusObjectUsed(curr_inp);

        if~isSigObjUsed
            minInport=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_inp,'OutMin');
            maxInport=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_inp,'OutMax');

            if hasBusSignal


                FlaggedBusPorts=getPortsUnderspecBO(system,{getfullname(curr_inp)});

                if~isempty(FlaggedBusPorts)
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action2');
                    violations=[violations;vObj];%#ok<AGROW>
                end

                if~(isempty(minInport{1})&&isempty(maxInport{1}))
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action3');
                    violations=[violations;vObj];%#ok<AGROW>
                end

            else
                hasInheritedDataType=~isempty(regexp(get_param(curr_inp,'OutDataTypeStr'),'^Inherit:.*','once'));

                if~hasInheritedDataType
                    if(isempty(minInport{1})||isempty(maxInport{1}))
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action4');
                        violations=[violations;vObj];%#ok<AGROW>
                    end
                else

                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action5');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end

        else

            minSigObj=sigObj.Min;
            maxSigObj=sigObj.Max;

            minInport=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_inp,'OutMin');
            maxInport=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_inp,'OutMax');

            if hasBusSignal
                FlaggedBusPorts=getPortsUnderspecBO(system,{getfullname(curr_inp)});

                if~isempty(FlaggedBusPorts)
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action2');
                    violations=[violations;vObj];%#ok<AGROW>
                end

                if~(isempty(minSigObj)&&isempty(maxSigObj))||~(isempty(minInport{1})&&isempty(maxInport{1}))
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action3');
                    violations=[violations;vObj];%#ok<AGROW>
                end

            else
                if~Advisor.Utils.Simulink.isEnumOutDataTypeStr(system,sigObj.DataType)

                    if(isempty(minSigObj)||isempty(maxSigObj))&&...
                        (isempty(minInport{1})||isempty(maxInport{1}))
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action4');
                        violations=[violations;vObj];%#ok<AGROW>
                    end

                    if strcmp(sigObj.DataType,'auto')
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_inp);
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0025_rec_action5');
                        violations=[violations;vObj];%#ok<AGROW>
                    end

                end
            end
        end
    end
end

function hEnumBoolPorts=detectEnumAndBoolPorts(system,hUnsetNumericPorts)
    dataTypeStrs=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,get_param(hUnsetNumericPorts,'OutDataTypeStr'));
    isEnumBoolType=false(size(hUnsetNumericPorts));


    if ischar(dataTypeStrs)
        dataTypeStrs={dataTypeStrs};
    end

    for n=1:length(hUnsetNumericPorts)
        isEnumBoolType(n,1)=Advisor.Utils.Simulink.isEnumOutDataTypeStr(system,dataTypeStrs{n,1})||strcmpi(dataTypeStrs{n,1},'boolean');
    end

    if~isempty(isEnumBoolType)
        hEnumBoolPorts=hUnsetNumericPorts(isEnumBoolType,1);
    else
        hEnumBoolPorts=[];
    end
end

function busObjectUsed=loc_isBusObjectUsed(hInport)
    busObjectUsed=false;
    portHandles=get_param(hInport,'PortHandles');

    if~isempty(portHandles)&&~isempty(portHandles(1).Outport)
        CompiledBusTypes=get_param(portHandles(1).Outport,'CompiledBusType');
        busObjectUsed=strcmp('NON_VIRTUAL_BUS',CompiledBusTypes)||...
        strcmp('VIRTUAL_BUS',CompiledBusTypes);
    end
end

function[status,sigObj,sigObjName,hasImplicitResolution]=loc_isSignalObjectUsed(system,hInport,signalResolutionControl)

    sigObj=[];
    sigObjName='';
    hasImplicitResolution=false;




    outSignalNames=get_param(hInport,'OutputSignalNames');

    if(isequal(signalResolutionControl,'None')||isempty(outSignalNames)||isempty(outSignalNames{1})||~isvarname(outSignalNames{1}))
        usesSignalObj=false;
    else

        lineHandles=get_param(hInport,'LineHandles');



        if(isempty(lineHandles)||isempty(lineHandles(1).Outport)||...
            lineHandles(1).Outport==-1)
            usesSignalObj=false;
        else
            if get(lineHandles(1).Outport,'MustResolveToSignalObject')

                sigObjName=outSignalNames{1};

                sigObj=loc_getSigObj(system,sigObjName);
                usesSignalObj=~isempty(sigObj);

            elseif strncmp(signalResolutionControl,'TryResolve',10)


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
    end

    status=usesSignalObj;
end

function sigObj=loc_getSigObj(system,sigObjName)
    modelObj=get_param(system,'object');

    if existsInGlobalScope(system,sigObjName)&&isa(evalinGlobalScope(system,sigObjName),'Simulink.Signal')
        sigObj=evalinGlobalScope(system,sigObjName);
    elseif modelObj.ModelWorkspace.hasVariable(sigObjName)&&isa(modelObj.ModelWorkspace.getVariable(sigObjName),'Simulink.Signal')
        sigObj=modelObj.ModelWorkspace.getVariable(sigObjName);
    else
        sigObj=[];
    end
end