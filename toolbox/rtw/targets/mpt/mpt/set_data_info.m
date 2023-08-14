function status=set_data_info(objName,property,newValue,varargin)

























































    if isstring(objName)
        objName=char(objName);
    end

    if isempty(varargin)
        modelName='';
    else
        modelName=varargin{1};
        assert(ischar(modelName)||isstring(modelName));
    end

    try
        status=1;

        if isEmptyString(modelName)
            objExists=evalin('base',['exist(''',objName,''',''var'');'])==1;
        else
            objExists=existsInGlobalScope(modelName,objName);
        end
        if objExists
            if isEmptyString(modelName)
                obj=evalin('base',objName);
            else
                obj=evalinGlobalScope(modelName,objName);
            end
            if~isa(obj,'Simulink.Data')
                MSLDiagnostic('RTW:mpt:GetDataInforMsg1',objName).reportAsWarning;
                status=0;
                return;
            end
        else
            MSLDiagnostic('RTW:mpt:GetDataInforMsg2',objName).reportAsWarning;
            status=0;
            return;
        end


        CoderInfo=obj.CoderInfo;
        if(isprop(obj,property)&&...
            ~strcmp(property,'StorageClass'))


            obj.(property)=newValue;
        elseif isprop(CoderInfo,property)

            obj.CoderInfo.(property)=newValue;
        else
            if isprop(CoderInfo,'CustomAttributes')

                cusAttri=CoderInfo.CustomAttributes;
                if~isempty(cusAttri)&&isprop(cusAttri,property)
                    obj.CoderInfo.CustomAttributes.(property)=newValue;
                else
                    MSLDiagnostic('RTW:mpt:GetDataInforMsg3',property).reportAsWarning;
                    status=0;
                    return
                end
            else
                MSLDiagnostic('RTW:mpt:GetDataInforMsg3',property).reportAsWarning;
                status=0;
                return
            end
        end


        if isEmptyString(modelName)
            assignin('base',objName,obj);
        else
            assigninGlobalScope(modelName,objName,obj);
        end

    catch merr
        MSLDiagnostic('RTW:mpt:GetDataInforMsg4',property,merr.message).reportAsWarning;
        status=0;
    end

end

function empty=isEmptyString(name)

    if((ischar(name)&&isempty(name))||(isstring(name)&&(name=="")))
        empty=true;
    else
        empty=false;
    end

end

