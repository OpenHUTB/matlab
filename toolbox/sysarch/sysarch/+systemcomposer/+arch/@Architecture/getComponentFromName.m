function comp=getComponentFromName(this,compName)

    comp=compName;
    if ischar(compName)
        if isempty(compName)
            comp=systemcomposer.arch.Component.empty;
        else
            fullPath=compName;
            if isempty(strfind(compName,this.Name))
                fullPath=[this.Name,'/',compName];
            end
            hdl=get_param(fullPath,'Handle');
            comp=systemcomposer.internal.getWrapperForImpl(systemcomposer.utils.getArchitecturePeer(hdl),'systemcomposer.arch.Component');
        end
    end

end