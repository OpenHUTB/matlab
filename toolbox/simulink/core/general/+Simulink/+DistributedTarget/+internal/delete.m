function delete(varargin)







    narginchk(1,1);
    nargoutchk(0,0);

    dest=varargin{1};

    if~Simulink.DistributedTarget.internal.isvalidobj(dest)
        DAStudio.error('Simulink:mds:InvalidObjectIdentifier',dest);
    end

    archobj=strsplit(dest,'/');
    archH=Simulink.DistributedTarget.internal.getmappingmgr(archobj{1});

    if length(archobj)<=1

        DAStudio.error('Simulink:mds:DeleteRoot');
    else
        parenthandle=Simulink.DistributedTarget.internal.gethandle(archobj(2:end-1),archH);
        handle=Simulink.DistributedTarget.internal.gethandle(archobj(2:end),archH);
    end

    if ismethod(parenthandle,'del')
        parenthandle.del(handle);
    else
        DAStudio.error('Simulink:mds:NoDeleteMethod');
    end

end

