function set_param(varargin)







    narginchk(3,3);
    nargoutchk(0,0);

    obj=varargin{1};
    param=varargin{2};
    paramval=varargin{3};

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

    if isprop(handle,param)
        handle.(param)=paramval;
    elseif isprop(handle,'TargetObject')&&~isempty(handle.TargetObject)...
        &&isprop(handle.TargetObject,param)

        handle.TargetObject.(param)=paramval;
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
                DAStudio.error('Simulink:mds:CannotSetCompiledProperty',errorObj,param);
            else
                handle.setProperty(actParam,paramval);
            end
        else
            DAStudio.error('Simulink:mds:NoSpecifiedProperty',errorObj,param);
        end
    end

