function instanceParamValues=copyComponentParametersToModel(blockH,modelH)






    instanceParamValues=containers.Map;

    swComp=systemcomposer.utils.getArchitecturePeer(blockH);
    comp=systemcomposer.internal.getWrapperForImpl(swComp);
    paramNames=comp.getParameterNames;
    numParams=numel(paramNames);

    if numParams>0
        mdlWks=get_param(modelH,'ModelWorkspace');


        if isempty(mdlWks)
            msg=message('SystemArchitecture:Parameter:NoParameterSupportInSubsystemReference',getfullname(blockH));
            warning('SystemArchitecture:Parameter:NoParameterSupportInSubsystemReference',msg.string);
            return;
        end

        mdlArgs="";
        for i=1:numParams

            fullName=paramNames(i);
            param=comp.getParameter(fullName);
            ownerH=param.Type.Owner.SimulinkHandle;
            if ownerH==blockH

                paramName=fullName;
                [paramValue.expr,paramValue.unit]=comp.getParameterValue(paramName);


                value=eval(param.Value);
                po=Simulink.Parameter(value);
                po.DataType=param.Type.DataType;
                po.Unit=param.Type.Units;
                if strlength(param.Type.Minimum)>0
                    po.Min=eval(param.Type.Minimum);
                else
                    po.Min=[];
                end
                if strlength(param.Type.Maximum)>0
                    po.Max=eval(param.Type.Maximum);
                else
                    po.Max=[];
                end





                assignin(mdlWks,paramName,po);


                mdlArgs=mdlArgs.append(paramName+",");
                instanceParamValues(paramName)=paramValue;
            else



                [paramName,path]=systemcomposer.internal.arch.internal.parseParameterFQN(fullName);


                swModel=systemcomposer.utils.getArchitecturePeer(modelH);
                model=systemcomposer.internal.getWrapperForImpl(swModel);
                model.exposeParameter('Path',path,'Parameters',paramName);
            end
        end

        set_param(modelH,'ParameterArgumentNames',mdlArgs.strip('right',','));
    end

end

