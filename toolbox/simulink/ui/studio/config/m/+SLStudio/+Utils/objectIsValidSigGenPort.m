function res=objectIsValidSigGenPort(obj)




    res=false;
    if SLStudio.Utils.objectIsValidPort(obj)
        if strcmpi(obj.type,'In Port')


            ownerH=obj.container.handle;
            pc=get_param(ownerH,'PortConnectivity');
            pn=get_param(obj.handle,'PortNumber');
            srcBlock=pc(pn).SrcBlock;
            if ishandle(srcBlock)&&strcmpi(get_param(srcBlock,'IOType'),'siggen')
                res=true;
            end
        end
    end
end
