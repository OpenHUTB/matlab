function[newhandles,newport_handles]=...
    trace_through_hiddenbuf(oldhandles,oldport_handles)




    newhandles=[];
    newport_handles=[];

    for i=1:length(oldhandles)
        walkHandle=oldhandles(i);
        walkObj=get(walkHandle,'Object');
        synthesized=walkObj.isSynthesized;
        type=get(walkHandle,'BlockType');
        if synthesized&&strcmpi(type,'SignalConversion')

            porthandles=get(walkHandle,'PortHandles');

            inPort=get(porthandles.Inport,'Object');
            outporthandles=inPort.getActualSrc;
            srcnames=get(outporthandles(:,1),'Parent');
            if~iscell(srcnames)
                newhandles=[newhandles;outporthandles(:,1)];
                newport_handles=[newport_handles;outporthandles];
            else
                for j=1:length(srcnames)
                    newhandles=[newhandles;outporthandles(j,1)];
                    newport_handles=[newport_handles;outporthandles(j,:)];
                end
            end
        else
            newhandles=[newhandles;oldhandles(i)];
            newport_handles=[newport_handles;oldport_handles(i,:)];
        end
    end
end
