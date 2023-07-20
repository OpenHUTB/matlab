function[counts,binLocations]=imhistImpl(in,nbins,range,offset,isCmap)
%#codegen



    coder.allowpcode('plain');
    coder.inline('always');

    nelements=numel(in);
    if islogical(in)
        [counts,binLocations]=logicalHistogramAlgorithm(in,nelements);
    elseif nbins>1
        counts=coder.nullcopy(zeros(nbins,1));
        countsuint=zeros(nbins,1,'uint32');
        if isempty(in)
            counts=zeros(nbins,1);
        else
            MAX_SHARED_MEMORY=coder.gpu.internal.availableSharedMemory;
            SIZEOF_BIN=coder.const(4);
            useShared=nbins*SIZEOF_BIN<MAX_SHARED_MEMORY;

            if useShared
                if isCmap
                    coder.ceval('-layout:any','-gpuhostdevicefcn','call_gpu_imhist_cmap',...
                    coder.rref(in(1),'gpu'),...
                    coder.wref(countsuint(1),'gpu'),...
                    nelements,...
                    nbins);
                else
                    coder.ceval('-layout:any','-gpuhostdevicefcn','call_gpu_imhist_numeric',...
                    coder.rref(in(1),'gpu'),...
                    coder.wref(countsuint(1),'gpu'),...
                    nelements,...
                    nbins,...
                    range,...
                    offset);
                end
            else

                countsuint=globalHistogramAlgorithm(in,nelements,countsuint,isCmap,nbins,offset,range);
            end
        end

        [counts,binLocations]=castToDouble(in,countsuint,counts,isCmap,nbins,offset,range);
    else

        binLocations=range-offset;
        counts=nelements;
    end

end

function[countsuint]=globalHistogramAlgorithm(in,nelements,countsuint,isCmap,nbins,offset,range)


    for i=1:nelements
        curValue=real(in(i));
        if isCmap
            if isfloat(in)
                binIndex=max(1,min(nbins,double(curValue)));
            else
                binIndex=max(0,min(nbins-1,double(curValue)))+1;
            end

            if isnan(curValue)
                binIndex=1;
            end
        elseif isfloat(curValue)
            binIndex=max(0,min(nbins-1,round(double(curValue)*(nbins-1))))+1;
            if isnan(curValue)
                binIndex=1;
            end
        else
            scale=(nbins-1)/range;
            binIndex=min(nbins-1,round((double(curValue)+offset)*double(scale)))+1;
        end
        countsuint(binIndex)=gpucoder.atomicAdd(countsuint(binIndex),uint32(1));
    end
end

function[counts,binLocations]=logicalHistogramAlgorithm(in,nelements)
    counts=coder.nullcopy(zeros(2,1));
    countsuint=uint32(0);
    for i=1:nelements
        if~in(i)
            countsuint(1)=gpucoder.atomicAdd(countsuint(1),uint32(1));
        end
    end

    counts(1)=double(countsuint(1));
    counts(2)=double(nelements-countsuint(1));
    binLocations=(0:1)';
end

function[counts,binLocations]=castToDouble(in,countsuint,counts,isCmap,nbins,offset,range)
    binLocations=coder.nullcopy(zeros(nbins,1));
    if isCmap
        binLocations=coder.nullcopy(zeros(1,nbins));
    end
    for i=1:nbins
        if isCmap
            binLocations(i)=i-1;
            if isfloat(in)
                binLocations(i)=i;
            end
        else
            binLocations(i)=-offset+((i-1)*range/max(nbins-1,1));
        end
        counts(i)=double(countsuint(i));
    end
end
