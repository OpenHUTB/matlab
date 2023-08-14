function selectedElems=getDestinationElement(this)





    lineHdls=this.SimulinkHandle;
    srcComponentHdl=this.SourcePort.Parent.SimulinkHandle;
    selectedElems={};
    if isa(this.DestinationPort,'systemcomposer.arch.ArchitecturePort')

        for i=1:numel(lineHdls)
            seg=get_param(lineHdls(i),'Object');
            if isa(this.SourcePort,'systemcomposer.arch.ComponentPort')
                srcBlkHdl=seg.SrcBlockHandle;
                if isequal(srcBlkHdl,srcComponentHdl)&&isequal(seg.SrcPortHandle,this.SourcePort.SimulinkHandle)
                    for m=1:numel(seg.DstBlockHandle)
                        if ismember(seg.DstBlockHandle(m),this.DestinationPort.SimulinkHandle)
                            dstPort=get_param(seg.DstBlockHandle(m),'object');
                            selectedElems=[selectedElems,{dstPort.Element}];
                        end
                    end
                end
            else
                for m=1:numel(this.SourcePort.SimulinkHandle)
                    if isequal(seg.SrcBlockHandle,this.SourcePort.SimulinkHandle(m))
                        for n=1:numel(seg.DstBlockHandle)
                            if ismember(seg.DstBlockHandle(n),this.DestinationPort.SimulinkHandle)
                                dstPort=get_param(seg.dstBlockHandle(n),'object');
                                selectedElems=[selectedElems,{dstPort.Element}];
                            end
                        end
                    end
                end
            end

        end
    end
    selectedElems=unique(selectedElems);
end