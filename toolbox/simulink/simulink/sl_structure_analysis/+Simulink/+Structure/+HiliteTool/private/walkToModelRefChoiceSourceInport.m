function refSegments=walkToModelRefChoiceSourceInport(refBlock,inportBlock)

    ports=get_param(refBlock,'PortHandles');

    if(~isempty(ports.Inport))
        ind=str2double(get_param(inportBlock,'Port'));
        refSegments=get_param(ports.Inport(ind),'line');
    else
        refSegments=-1;
    end

end