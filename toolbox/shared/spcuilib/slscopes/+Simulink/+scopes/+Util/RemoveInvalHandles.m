function ioSigsCell=RemoveInvalHandles(ioSigsCell,ax)
    ioSigsCell{ax}([ioSigsCell{ax}.Handle]==-1)=[];
end
