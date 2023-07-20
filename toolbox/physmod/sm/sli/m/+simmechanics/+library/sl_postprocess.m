function outData=sl_postprocess(inData)


    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    ParameterNames={};


    if isfield(inData,'InstanceData')
        [ParameterNames{1:length(inData.InstanceData)}]=inData.InstanceData.Name;
        outData.NewInstanceData=inData.InstanceData;
    else
        [ParameterNames{1:length(inData.NewInstanceData)}]=inData.NewInstanceData.Name;
        outData=inData;
    end



    blkFunc=pm_message('mech2:messages:parameters:block:blockFunction:ParamName');

    classNameParam=simmechanics.library.helper.get_class_name_param('dummy');
    clsName=classNameParam.VarName;

    bi=strncmp(blkFunc,ParameterNames,length(blkFunc));
    ci=strncmp(clsName,ParameterNames,length(clsName));

    i=bi|ci;
    outData.NewInstanceData(i)=[];


    outData=simmechanics.library.helper.translate_hertz_units(outData);


    outData=simmechanics.library.body_elements.sl_postprocess2(outData);


    outData=simmechanics.library.joints.constant_velocity_joint_sl_postprocess(outData);

