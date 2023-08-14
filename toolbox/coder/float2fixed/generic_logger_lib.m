function[out1,out2]=generic_logger_lib(action,fcnName,fcnPath,exprID)
    persistent pTable pIdx
    if isempty(pIdx)
        pIdx=uint32(2);
        pTable=[];
    end


    switch action
    case 'newIdx'
        idx=pIdx;
        pIdx=pIdx+1;

        S.FunctionName=fcnName;
        S.FunctionPath=fcnPath;
        S.ExprId=exprID;
        pTable=[pTable,S];

        out1='generic_logger';
        out2=idx;

    case 'gen_logger_lib'
        out1=makeMexableDesc(pTable);
        clear pIdx;
    case 'idxOffset'
        out1=uint32(0);

    case 'get_logged_locations_info'
        mexName=fcnName;
        data=feval(mexName,'fetchLoggedData');

        out1=makeTableFromMexDesc(data.info);
    case 'enable_all_locations_logging'
        mexName=fcnName;
        data=feval(mexName,'fetchLoggedData');

        numInstrumentPoints=numel(makeTableFromMexDesc(data.info));

        feval(mexName,'coderEnableLog',uint32((1:numInstrumentPoints)+1),true);
    case 'get_logged_data'

        mexName=fcnName;
        data=feval(mexName,'fetchLoggedData');
        data.info=makeTableFromMexDesc(data.info);
        numInstrumentPoints=numel(data.info);


        data.buffers(1)=[];

        for ii=1:numInstrumentPoints
            if ii>numel(data.buffers)
                break;
            end


            data.buffers(ii).Data=data.buffers(ii).Data(1:data.buffers(ii).DataSize-1);
            data.buffers(ii).DataSize=data.buffers(ii).DataSize-1;
        end

        count=0;
        for ii=1:numInstrumentPoints
            if ii>numel(data.buffers)||isempty(data.buffers(ii).Data)

                continue;
            end
            count=count+1;
        end

        out1=[];
        outIdx=1;
        for ii=1:numel(data.info)
            if ii>numel(data.buffers)||isempty(data.buffers(ii).Data)

                continue;
            end
            S.FunctionName=strtrim(data.info(ii).FunctionName);
            S.FunctionPath=strtrim(data.info(ii).FunctionPath);
            S.ExprId=strtrim(data.info(ii).ExprId);
            S.Dims=data.buffers(ii).Dims;
            S.Varsize=data.buffers(ii).Varsize;
            S.Min=data.buffers(ii).Min;
            S.Max=data.buffers(ii).Max;
            S.idx=ii;

            switch data.buffers(ii).Class
            case 'embedded.fi'
                [~,fm]=evalc(data.buffers(ii).Fimath);
                [~,nt]=evalc(data.buffers(ii).NumericType);
                intExample=fi2sim(fi(0,nt,fm));
                ints=typecast(data.buffers(ii).Data,class(intExample));
                rows=size(intExample,1);
                cols=numel(ints)/rows;
                ints=reshape(ints,rows,cols);
                vals=sim2fi(ints,nt);
                vals=setfimath(vals,fm);
            case 'logical'
                vals=logical(data.buffers(ii).Data);
            otherwise
                vals=typecast(data.buffers(ii).Data,data.buffers(ii).Class);
            end
            S.LoggedData=[];
            if isempty(out1)
                out1=repmat(S,[1,count]);
            end
            S.LoggedData=vals;
            out1(outIdx)=S;
            outIdx=outIdx+1;
        end
        if isfield(data,'Overflows')
            out1.DataLogs=out1;
            out1.Overflows=f2f_overflow_lib('process',data.Overflows);
        end
    end
end

function s=separator()
    s='<>';
end

function Desc=makeMexableDesc(table)
    functionIds=containers.Map();
    exprs={};
    sep=separator();
    functionIdList={};
    for ii=1:numel(table)
        S=table(ii);
        fcnId=[S.FunctionName,sep,S.FunctionPath];
        if~functionIds.isKey(fcnId)
            fcnIdx=numel(functionIdList)+1;
            functionIdList{fcnIdx}=fcnId;

            functionIds(fcnId)=fcnIdx;
        else
            fcnIdx=functionIds(fcnId);
        end
        exprs=[exprs,{num2str(fcnIdx),S.ExprId}];
    end
    Desc.Functions=strjoin(functionIdList,sep);
    Desc.Exprs=strjoin(exprs,sep);
end

function table=makeTableFromMexDesc(Desc)
    sep=separator();
    functions=strsplit(Desc.Functions,sep);
    exprs=strsplit(Desc.Exprs,sep);
    table=[];
    if numel(exprs)>=2
        for ii=1:2:numel(exprs)
            fcnIdx=str2double(exprs{ii});
            S.FunctionName=functions{2*(fcnIdx-1)+1};
            S.FunctionPath=functions{2*(fcnIdx-1)+2};
            S.ExprId=exprs{ii+1};

            table=[table,S];
        end
    end
end

