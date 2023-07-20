function[in,out,connections]=convertioformat(daes,inputs,outputs,conns,getIoNames)




    in=struct('src',{},'dst',{});
    out=struct('src',{},'dst',{});
    connections=struct('src',{},'dst',{});

    if isempty(daes)
        return;
    end


    inputIoNames=containers.Map('KeyType','double','ValueType','any');
    outputIoNames=containers.Map('KeyType','double','ValueType','any');
    for daeIdx=1:numel(daes)
        inputIoNames(daeIdx)=getIoNames(daes{daeIdx},'Input');
        outputIoNames(daeIdx)=getIoNames(daes{daeIdx},'Output');
    end



    for inputIdx=1:numel(inputs)
        conn=inputs(inputIdx).connector;
        src={conns.src};
        dstConns=conns(strcmp(conn,src));
        dst=struct('dae',{},'index',{});
        for dstIdx=1:numel(dstConns)
            for daeIdx=1:numel(daes)
                names=inputIoNames(daeIdx);
                if isempty(names)
                    continue;
                end
                ioIdx=find(strcmp(names,dstConns(dstIdx).dst));
                for idx=1:numel(ioIdx)
                    dst(end+1).dae=daeIdx;%#ok<AGROW>
                    dst(end).index=ioIdx(idx);
                end
            end
        end
        if~isempty(dst)
            in(end+1).src=inputs(inputIdx);%#ok<AGROW>            
            in(end).dst=dst;
        end
    end


    for outputIdx=1:numel(outputs)
        conn=outputs(outputIdx).connector;
        dst={conns.dst};
        srcConns=conns(strcmp(conn,dst));
        src=struct('dae',{},'index',{});
        for srcIdx=1:numel(srcConns)
            for daeIdx=1:numel(daes)
                names=outputIoNames(daeIdx);
                if isempty(names)
                    continue;
                end
                ioIdx=find(strcmp(names,srcConns(srcIdx).src));
                for idx=1:numel(ioIdx)
                    src(end+1).dae=daeIdx;%#ok<AGROW>
                    src(end).index=ioIdx(idx);
                end
            end
        end
        if~isempty(src)
            out(end+1).src=src;%#ok<AGROW>            
            out(end).dst={outputs(outputIdx)};
        end
    end



    if~isempty(out)
        out2=out(1);
        for idx=2:numel(out)
            jdx=lFindIndex(out2,out(idx).src);
            if isempty(jdx)
                out2(end+1)=out(idx);%#ok<AGROW>
            else
                out2(jdx).dst(end+1)=out(idx).dst;
            end
        end
        out=out2;
    end


    src=unique({conns.src});










    for idx=1:numel(src)



        if any(strcmp({inputs.connector},src(idx)))
            continue;
        end


        [srcDaeIdx,srcPortIdx]=lFindDaeIndex(daes,src(idx),outputIoNames);



        srcIdx=strcmp({conns.src},src(idx));
        dst={conns(srcIdx).dst};
        pm_assert(numel(dst)>=1);


        dsts=struct('dae',{},'index',{});



        for jdx=1:numel(dst)

            if any(strcmp({outputs.connector},dst(jdx)))
                continue;
            end


            [dstDaeIdx,dstPortIdx]=lFindDaeIndex(daes,dst(jdx),inputIoNames);
            dsts(end+1).dae=dstDaeIdx;%#ok<AGROW>
            dsts(end).index=dstPortIdx;
        end



        if~isempty(dsts)
            connections(end+1).src.dae=srcDaeIdx;%#ok<AGROW>
            connections(end).src.index=srcPortIdx;
            connections(end).dst=dsts;
        end
    end
end

function index=lFindIndex(out,test)
    index=[];
    for idx=1:numel(out)
        if(out(idx).src.dae==test.dae&&out(idx).src.index==test.index)
            index=idx;
            return;
        end
    end

end

function[daeIdx,ioIdx]=lFindDaeIndex(daes,id,ioNames)




    for daeIdx=1:numel(daes)
        names=ioNames(daeIdx);
        if isempty(names)
            continue;
        end
        ioIdx=strcmp(names,id);
        if any(ioIdx)

            pm_assert(numel(find(ioIdx))==1);
            ioIdx=find(ioIdx);
            return;
        end

    end


    daeIdx=-1;
    ioIdx=-1;

end

