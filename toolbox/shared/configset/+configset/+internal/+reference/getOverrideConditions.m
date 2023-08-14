function out=getOverrideConditions(ref,parameter)















    out={false,false,false,false,false,false};




    out{6}=~ref.isObjectLocked;

    try
        data=configset.internal.reference.getParameterInfo(ref,parameter);
    catch me
        if ref.isValidParam(parameter)

            return
        end
        rethrow(me);
    end

    modelRefData=data.ParamInfo.ModelRef;
    refConfigSet=ref.getRefConfigSet(true);




    restrictedParameters=[
"ProdHWDeviceType"
"TargetHWDeviceType"
"TargetUnknown"
"ProdEqTarget"
"BuildConfiguration"
"HardwareBoard"
"CoderTargetData"
"CodeCoverageSettings"
"MemSecFuncInitTerm"
"MemSecFuncExecute"
    ];
    if get_param(refConfigSet,'TargetLang')=="C++"

        restrictedParameters(end+1)="CodeInterfacePackaging";
    end







    out{1}=(isempty(modelRefData)||modelRefData.match~="on");
    out{2}=refConfigSet.getPropEnabled(parameter);


    out{3}=data.Adp.getParamStatus(parameter,data.ParamInfo)==configset.internal.data.ParamStatus.Normal;
    out{4}=~any(parameter==restrictedParameters)&&data.Component~="Simulink.STFCustomTargetCC";
    out{5}=true;


