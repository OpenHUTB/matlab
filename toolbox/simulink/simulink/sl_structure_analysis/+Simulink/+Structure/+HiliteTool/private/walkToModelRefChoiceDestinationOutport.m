function refSegment=walkToModelRefChoiceDestinationOutport(refBlock,outportBlock)

    ports=get_param(refBlock,'PortHandles');
    if(~isempty(ports.Outport))
        ind=str2double(get_param(outportBlock,'Port'));
        refSegment=get_param(ports.Outport(ind),'line');
    else
        refSegment=-1;
    end

end