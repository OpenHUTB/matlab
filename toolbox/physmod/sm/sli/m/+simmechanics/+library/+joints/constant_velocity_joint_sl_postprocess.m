function outData=constant_velocity_joint_sl_postprocess(inData)











    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    instanceData=[];
    if isfield(inData,'InstanceData')
        instanceData=inData.InstanceData;
    else
        instanceData=inData.NewInstanceData;
    end

    if(~isempty(instanceData))

        [ParameterNames{1:length(instanceData)}]=instanceData.Name;

        aa=pm_message('mech2:cvPrimitive:parameters:sensing:azimuth:position:ParamName');
        ba=pm_message('mech2:cvPrimitive:parameters:sensing:bend:position:ParamName');
        ai=strncmp(aa,ParameterNames,length(aa));
        bi=strncmp(ba,ParameterNames,length(ba));

        if(any(ai)&&any(bi))



            internalStateParam=...
            pm_message('mech2:cvPrimitive:parameters:internalState:ParamName');

            if~ismember(internalStateParam,ParameterNames)


                instanceData(end+1).Name=internalStateParam;
                instanceData(end).Value=...
                pm_message(['mech2:cvPrimitive:parameters:internalState:values:'...
                ,'quaternion:Param']);
            end


            outData.NewInstanceData=instanceData;

        else
            outData=inData;
        end

    end

end
