function out=custom_update(hBlock,newReferenceBlock)







    num_LConn_HBlock=numel(get_param(hBlock,'PortHandles').LConn);
    num_RConn_HBlock=numel(get_param(hBlock,'PortHandles').RConn);

    try
        set_param(hBlock,'ReferenceBlock',newReferenceBlock)
        set_param(hBlock,'SourceFile',get_param(newReferenceBlock,'SourceFile'))
        set_param(hBlock,'ComponentPath',get_param(newReferenceBlock,'ComponentPath'))
        set_param(hBlock,'ComponentVariants',get_param(newReferenceBlock,'ComponentVariants'))
        set_param(hBlock,'ComponentVariantNames',get_param(newReferenceBlock,'ComponentVariantNames'))
    catch
    end


    num_LConn_ILBlock=numel(get_param(hBlock,'PortHandles').LConn);
    num_RConn_ILBlock=numel(get_param(hBlock,'PortHandles').RConn);

    if(num_LConn_HBlock~=num_LConn_ILBlock)||(num_RConn_HBlock~=num_RConn_ILBlock)



        broken_connections.messages={'Mismatched number of ports between the Hydraulic block and Isothermal Liquid block. Check block connections in the model.'};
        broken_connections.subsystem=getfullname(hBlock);
        out.broken_connections=broken_connections;
    else
        out=struct;
    end

end



