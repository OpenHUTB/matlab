function issueInitValueWarning(obj,slicedMdl,sliceXfrmr,transformedSys)





    try
        vars=Simulink.findVars(slicedMdl);
    catch Mx %#ok<NASGU>


        return;
    end
    hasSigObjWithInitValue=false;
    for n=1:length(vars)
        try
            v=modelslicerprivate('evalinModel',slicedMdl,vars(n).Name);
            if isa(v,'Simulink.Signal')&&~isempty(v.InitialValue)
                initV=modelslicerprivate('evalinModel',slicedMdl,v.InitialValue);
                if isempty(initV)||(isscalar(initV)&&initV==0)

                else
                    hasSigObjWithInitValue=true;
                    break;
                end
            end
        catch
        end
    end
    if hasSigObjWithInitValue
        for n=1:length(transformedSys)
            sliceSysH=sliceXfrmr.sliceMapper.findInSlice(transformedSys(n));
            if~isempty(sliceSysH)
                fullName=getfullname(sliceSysH);
                msg=getString(message('Sldv:ModelSlicer:ModelSlicer:InitialValueMayNotAvailable',obj.model,fullName));
                Mex=MException('ModelSlicer:InitialValueMayNotAvailable',msg);
                modelslicerprivate('MessageHandler','warning',Mex,obj.model)
            end
        end
    end
end
