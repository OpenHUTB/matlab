function block=getSigGenSourceBlock(port)




    block=[];
    if SLStudio.Utils.objectIsValidPort(port)
        if strcmpi(port.type,'In Port')


            ownerH=port.container.handle;
            pc=get_param(ownerH,'PortConnectivity');
            pn=get_param(port.handle,'PortNumber');
            srcBlock=pc(pn).SrcBlock;
            if ishandle(srcBlock)&&strcmpi(get_param(srcBlock,'IOType'),'siggen')
                block=srcBlock;
            end
        end
    end
end
