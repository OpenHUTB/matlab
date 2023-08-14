function hisl_0026

    rec=getNewCheckObject('mathworks.hism.hisl_0026',false,@hCheckAlgo,'PostCompile');

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)

    violations=[];


    system=bdroot(system);


    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    hOutports=find_system(system,'SearchDepth',1,'BlockType','Outport');
    hOutports=mdlAdvObj.filterResultWithExclusion(hOutports);


    hEnumPorts=detectEnumAndBoolPorts(system,hOutports);
    hOutports=setdiff(hOutports,hEnumPorts);











    if Simulink.internal.isArchitectureModel(system)

        syshdl=get_param(system,'handle');
        comp=systemcomposer.utils.getArchitecturePeer(syshdl);

        allPorts=systemcomposer.internal.getWrapperForImpl(comp).Ports;

        hOutports=allPorts(arrayfun(@(x)strcmp(x.Direction,'Output'),allPorts));
        for i=1:length(hOutports)

            if isempty(hOutports(i).Interface)
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',hOutports(i).SimulinkHandle);
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0026_warn1');
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action6');
                violations=[violations;vObj];%#ok<AGROW>
            else

                interface=hOutports(i).Interface;

                if isa(hOutports(i).Interface,'systemcomposer.interface.DataInterface')

                    elems=interface.Elements;
                    for j=1:length(elems)
                        minVal=str2num(elems(j).Type.Minimum);
                        maxVal=str2num(elems(j).Type.Maximum);

                        if isempty(minVal)||isempty(maxVal)
                            vObj=ModelAdvisor.ResultDetail;
                            ModelAdvisor.ResultDetail.setData(vObj,'SID',hOutports(i).SimulinkHandle);
                            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0026_warn1');
                            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action6');
                            violations=[violations;vObj];%#ok<AGROW>
                            break;
                        end
                    end
                else

                    minVal=str2num(interface.Minimum);
                    maxVal=str2num(interface.Maximum);

                    if isempty(minVal)||isempty(maxVal)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',hOutports(i).SimulinkHandle);
                        vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0026_warn1');
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action6');
                        violations=[violations;vObj];%#ok<AGROW>
                    end
                end
            end
        end
        return;
    end

    for i=1:numel(hOutports)

        curr_outp=hOutports{i};



        minOutport=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_outp,'OutMin');
        maxOutport=Advisor.Utils.Simulink.evalSimulinkBlockParameters(curr_outp,'OutMax');

        [sigObjIsUsed,sigObj,~,hasImplicitResolution]=loc_isSignalObjectUsed(system,curr_outp,get_param(system,'SignalResolutionControl'));
        hasBusSignal=loc_isBusSignal(curr_outp);

        if hasImplicitResolution
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_outp);
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action5');
            violations=[violations;vObj];%#ok<AGROW>
        end

        outportHasInheritedDataType=~isempty(regexp(get_param(curr_outp,'OutDataTypeStr'),'^Inherit:.*','once'));


        if~sigObjIsUsed


            if hasBusSignal&&~outportHasInheritedDataType



                FlaggedBusPorts=getPortsUnderspecBO(system,{getfullname(curr_outp)});

                if~isempty(FlaggedBusPorts)
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_outp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action2');
                    violations=[violations;vObj];%#ok<AGROW>
                end

                if~(isempty(minOutport{1})&&isempty(maxOutport{1}))
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_outp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action4');
                    violations=[violations;vObj];%#ok<AGROW>
                end

            elseif~outportHasInheritedDataType
                if isempty(minOutport{1})||isempty(maxOutport{1})
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_outp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action1');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end


        else

            if~Advisor.Utils.Simulink.isEnumOutDataTypeStr(system,sigObj.DataType)

                minSigObj=sigObj.Min;
                maxSigObj=sigObj.Max;

                hasInheritedSignalObjDataType=strcmp(sigObj.DataType,'auto');

                if hasBusSignal&&~outportHasInheritedDataType



                    FlaggedBusPorts=getPortsUnderspecBO(system,{getfullname(curr_outp)});
                    if~isempty(FlaggedBusPorts)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_outp);
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action2');
                        violations=[violations;vObj];%#ok<AGROW>
                    end


                    if~(isempty(minSigObj)&&isempty(maxSigObj))||~(isempty(minOutport{1})&&isempty(maxOutport{1}))
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_outp);
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action4');
                        violations=[violations;vObj];%#ok<AGROW>
                    end

                elseif hasBusSignal&&outportHasInheritedDataType
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_outp);
                    vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action3');
                    violations=[violations;vObj];%#ok<AGROW>       

                elseif~hasInheritedSignalObjDataType


                    if(isempty(minSigObj)||isempty(maxSigObj))&&...
                        (isempty(minOutport{1})||isempty(maxOutport{1}))
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',curr_outp);
                        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0026_rec_action1');
                        violations=[violations;vObj];%#ok<AGROW>
                    end
                end
            end
        end

    end
end

function hEnumBoolPorts=detectEnumAndBoolPorts(system,hUnsetNumericPorts)
    dataTypeStrs=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,get_param(hUnsetNumericPorts,'OutDataTypeStr'));
    isEnumType=false(size(hUnsetNumericPorts));


    if ischar(dataTypeStrs)
        dataTypeStrs={dataTypeStrs};
    end

    for i=1:length(hUnsetNumericPorts)
        isEnumType(i,1)=Advisor.Utils.Simulink.isEnumOutDataTypeStr(system,dataTypeStrs{i,1})||strcmpi(dataTypeStrs{i,1},'boolean');;
    end

    if~isempty(isEnumType)
        hEnumBoolPorts=hUnsetNumericPorts(isEnumType,1);
    else
        hEnumBoolPorts=[];
    end
end

function busObjectUsed=loc_isBusSignal(hOutport)
    busObjectUsed=false;
    portHandles=get_param(hOutport,'PortHandles');

    if~isempty(portHandles)&&~isempty(portHandles(1).Inport)
        CompiledBusTypes=get_param(portHandles(1).Inport,'CompiledBusType');
        busObjectUsed=strcmp('NON_VIRTUAL_BUS',CompiledBusTypes)||...
        strcmp('VIRTUAL_BUS',CompiledBusTypes);
    end
end


function[status,sigObj,sigObjName,hasImplicitResolution]=loc_isSignalObjectUsed(system,hOutport,signalResolutionControl)

    sigObj=[];
    sigObjName='';
    hasImplicitResolution=false;




    inSignalNames=get_param(hOutport,'InputSignalNames');


    if(isequal(signalResolutionControl,'None')||...
        isempty(inSignalNames)||isempty(inSignalNames{1})||...
        ~isvarname(inSignalNames{1}))

        usesSignalObj=false;

    else

        lineHandles=get_param(hOutport,'LineHandles');

        if(~isempty(lineHandles)&&~isempty(lineHandles(1).Inport)&&...
            get(lineHandles(1).Inport,'MustResolveToSignalObject'))

            sigObjName=inSignalNames{1};

            sigObj=loc_getSigObj(system,sigObjName);

            if isempty(sigObj)
                usesSignalObj=false;
            else
                usesSignalObj=true;
            end


        elseif(strncmp(signalResolutionControl,'TryResolve',10)&&...
            ~isempty(lineHandles)&&~isempty(lineHandles(1).Inport))

            sigObjName=inSignalNames{1};
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

    elseif modelObj.ModelWorkspace.hasVariable(sigObjName)&&...
        isa(modelObj.ModelWorkspace.getVariable(sigObjName),'Simulink.Signal')

        sigObj=modelObj.ModelWorkspace.getVariable(sigObjName);

    else
        sigObj=[];
    end
end