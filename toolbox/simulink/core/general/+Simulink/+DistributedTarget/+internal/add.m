function[varargout]=add(varargin)







    narginchk(2,2);
    nargoutchk(0,1);

    type=varargin{1};
    dest=varargin{2};

    if~Simulink.DistributedTarget.internal.isvalidobj(dest)
        DAStudio.error('Simulink:mds:InvalidObjectIdentifier',dest);
    end

    archobj=strsplit(dest,'/');
    archH=Simulink.DistributedTarget.internal.getmappingmgr(archobj{1});

    if length(archobj)<=1

        DAStudio.error('Simulink:mds:AddRoot');
    else
        handle=Simulink.DistributedTarget.internal.gethandle(archobj(2:end-1),archH);
        name=archobj{end};
    end

    if ismethod(handle,'add')
        handle.add(name,type);
        if nargout>0
            varargout{1}=dest;
        end
    else
        DAStudio.error('Simulink:mds:NoAddMethod',class(handle));
    end

end

