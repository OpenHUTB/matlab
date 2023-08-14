function output=get_param(varargin)







    narginchk(2,2);
    nargoutchk(0,1);

    obj=varargin{1};
    param=varargin{2};

    if ischar(obj)
        if~Simulink.DistributedTarget.internal.isvalidobj(obj)
            DAStudio.error('Simulink:mds:InvalidObjectIdentifier',obj);
        end
        archobj=strsplit(obj,'/');
        archH=Simulink.DistributedTarget.internal.getmappingmgr(archobj{1});
        handle=Simulink.DistributedTarget.internal.gethandle(archobj(2:end),archH);
        errorObj=obj;
    else
        handle=obj;
        errorObj=handle.Name;
    end

    switch param

    case 'ArchitectureName'
        output=archH.Name;
    otherwise
        if isprop(handle,param)
            output=handle.(param);
        elseif isprop(handle,'TargetObject')&&~isempty(handle.TargetObject)...
            &&isprop(handle.TargetObject,param)

            output=handle.TargetObject.(param);
        else
            if isequal(strfind(param,'Compiled'),1)
                actParam=param(9:end);
                hasCompiledPrefix=true;
            else
                actParam=param;
                hasCompiledPrefix=false;
            end

            if isa(handle,'Simulink.DistributedTarget.BaseMappingEntity')&&...
                handle.hasProperty(actParam)
                if hasCompiledPrefix
                    output=handle.getEvaledProperty(actParam);
                else
                    output=handle.getProperty(actParam);
                end
            else
                DAStudio.error('Simulink:mds:NoSpecifiedProperty',...
                errorObj,param);
            end
        end
    end
end

