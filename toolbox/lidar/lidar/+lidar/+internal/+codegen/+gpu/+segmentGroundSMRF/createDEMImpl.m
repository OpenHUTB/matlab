function[surface,emptyGrids,countEmptyGrids]=createDEMImpl(rows,cols,validLocations,xmin,ymin,...
    gridRes)






































%#codegen

    coder.allowpcode('plain');


    surface=coder.internal.inf(rows,cols,'like',validLocations);


    numPts=size(validLocations,1);


    coder.gpu.kernel;
    for iter=1:numPts
        locX=validLocations(iter,1)-xmin;
        locY=validLocations(iter,2)-ymin;

        r=int32(round(locY/gridRes));
        c=int32(round(locX/gridRes));

        if r<0
            r=int32(0);
        elseif r>=rows
            r=int32(rows-1);
        end

        if c<0
            c=int32(0);
        elseif c>=cols
            c=int32(cols-1);
        end






        if coder.gpu.internal.isGpuEnabled

            if isa(validLocations(iter,3),'double')

                old=uint64(0);

                old=coder.ceval('-layout:any','-gpudevicefcn','__double_as_longlong',surface(r+1,c+1));



                while(validLocations(iter,3)<surface(r+1,c+1))
                    assumed=old;
                    assumedDouble=0;



                    assumedDouble=coder.ceval('-layout:any','-gpudevicefcn','__longlong_as_double',assumed);
                    val=uint64(0);

                    val=coder.ceval('-layout:any','-gpudevicefcn','__double_as_longlong',min(validLocations(iter,3),assumedDouble));

                    old=coder.ceval('-layout:any','-gpudevicefcn','atomicCAS',...
                    coder.wref(surface(r+1,c+1),'like',coder.opaque('unsigned long long','0')),assumed,val);
                    if old==assumed
                        break;
                    end
                end
            else

                old=uint32(0);

                old=coder.ceval('-layout:any','-gpudevicefcn','__float_as_int',surface(r+1,c+1));



                while(validLocations(iter,3)<surface(r+1,c+1))
                    assumed=old;
                    assumedSingle=0;



                    assumedSingle=coder.ceval('-layout:any','-gpudevicefcn','__int_as_float',assumed);
                    val=uint32(0);

                    val=coder.ceval('-layout:any','-gpudevicefcn','__float_as_int',min(validLocations(iter,3),assumedSingle));

                    old=coder.ceval('-layout:any','-gpudevicefcn','atomicCAS',...
                    coder.wref(surface(r+1,c+1),'like',coder.opaque('unsigned int','0')),assumed,val);
                    if old==assumed
                        break;
                    end
                end
            end
        else
            surface(r+1,c+1)=min(validLocations(iter,3),surface(r+1,c+1));
        end

    end



    emptyGrids=false(rows,cols);
    countEmptyGrids=uint32(0);
    coder.gpu.kernel;
    for riter=1:rows
        coder.gpu.kernel;
        for citer=1:cols
            if~isfinite(surface(riter,citer))
                surface(riter,citer)=coder.internal.nan;
                emptyGrids(riter,citer)=true;
                countEmptyGrids=gpucoder.atomicAdd(countEmptyGrids,uint32(1));
            end
        end
    end

end
