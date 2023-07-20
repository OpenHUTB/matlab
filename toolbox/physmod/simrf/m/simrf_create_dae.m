function dae=simrf_create_dae(mp,sp,solver,dae,inputs,outputs,conns)





    [inputInfo,outputInfo,~]=...
    simscape.engine.sli.internal.convertioformat({dae},inputs,outputs,conns,@lDaeIoNames);
    inputInfo=addDimToInputs(inputInfo,dae,inputs,conns,@lDaeIoNames,@lDaeIoDims);



    dae=simrf_create_dae2(mp,sp,solver,dae,inputInfo,outputInfo);
end

function names=lDaeIoNames(dae,iotype)
    infos=get(dae.(iotype));


    if~isempty(infos)
        names={infos.Name};
    else
        names=[];
    end
end

function names=lDaeIoDims(dae,iotype)
    infos=get(dae.(iotype));


    if~isempty(infos)
        names={infos.Dimension};
    else
        names=[];
    end
end

function in=addDimToInputs(in,dae,inputs,conns,getIoNames,getIoDims)

    if isempty(in)
        return;
    end

    names=getIoNames(dae,'Input');
    dims=getIoDims(dae,'Input');
    src={conns.src};


    ind=1;
    dim=[];
    for inputIdx=1:numel(inputs)
        conn=inputs(inputIdx).connector;
        dstConns=conns(strcmp(conn,src));
        for dstIdx=1:numel(dstConns)
            if isempty(names)
                continue;
            end
            dim=dims(strcmp(names,dstConns(dstIdx).dst));
        end
        if~isempty(dim)

            if isequal(in(ind).src,inputs(inputIdx))&&...
                (numel(dim)==1||isequal(dim{:}))
                in(ind).dim=dim{1};
            else

                error('input dimensions mismatch');

            end
            ind=ind+1;
        end
    end
end