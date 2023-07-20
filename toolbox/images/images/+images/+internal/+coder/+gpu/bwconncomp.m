

function[RegionIndices,RegionLengths,NumObjects]=bwconncomp(BW,conn)%#codegen
























    coder.allowpcode('plain');

    if nargin<2
        conn=8;
    end

    if coder.target('MATLAB')
        outStruct=bwconncomp(BW,conn);
        RegionIndices=cat(1,outStruct.PixelIdxList);

        NumObjects=outStruct.NumObjects;
        RegionLengths=zeros(outStruct.NumObjects,1);
        for i=1:outStruct.NumObjects
            RegionLengths(i)=length(outStruct.PixelIdxList);
        end
    else
        [RegionIndices,RegionLengths,NumObjects]=images.internal.coder.gpu.bwconncompGPUImpl(BW,conn);
    end
end
