function[inPortNames,outPortNames]=getPortNamesFromSimulink(this,blockHandle)





    if strcmp(get_param(blockHandle,'BlockType'),'ModelReference')
        phan=get_param(blockHandle,'PortHandles');
        inPortNames=cell(1,length(phan.Inport));
        outPortNames=cell(1,length(phan.Outport));

        inportnamestruct=get_param(blockHandle,'InputPortNames');
        outportnamestruct=get_param(blockHandle,'OutputPortNames');

        for n=1:length(phan.Inport)
            iport=get(get_param(phan.Inport(n),'Object'),'PortNumber');
            portn=['port',num2str(iport-1)];
            inPortNames{n}=inportnamestruct.(portn);
        end

        for n=1:length(phan.Outport)
            oport=get(get_param(phan.Outport(n),'Object'),'PortNumber');
            portn=['port',num2str(oport-1)];
            outPortNames{n}=outportnamestruct.(portn);
        end
    else


        [inPortNames,outPortNames]=getPortNamesFromSimulink@hdldefaults.abstractBBox(this,blockHandle);
    end

end
