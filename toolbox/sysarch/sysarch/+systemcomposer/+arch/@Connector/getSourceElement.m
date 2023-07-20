function selectedElems=getSourceElement(this)





    lineHdls=this.SimulinkHandle;
    dstComponentHdl=this.DestinationPort.Parent.SimulinkHandle;
    selectedElems={};
    if isa(this.SourcePort,'systemcomposer.arch.ArchitecturePort')

        for i=1:numel(lineHdls)
            seg=get_param(lineHdls(i),'Object');
            if isa(this.DestinationPort,'systemcomposer.arch.ComponentPort')
                dstBlkHdl=seg.DstBlockHandle;
                if isequal(dstBlkHdl,dstComponentHdl)
                    srcPort=get_param(seg.srcBlockHandle(1),'object');
                    selectedElems=[selectedElems,{srcPort.Element}];
                end
            else
                for m=1:numel(seg.DstBlockHandle)
                    if ismember(seg.DstBlockHandle(m),this.DestinationPort.SimulinkHandle)&&...
                        ismember(seg.srcBlockHandle(1),this.SourcePort.SimulinkHandle)
                        srcPort=get_param(seg.srcBlockHandle(1),'object');
                        selectedElems=[selectedElems,{srcPort.Element}];
                    end
                end
            end

        end
    end
    selectedElems=unique(selectedElems);
end