function out=f2f_overflow_lib(action,fcnNameOrBuffer,fcnPath,exprStart,exprLength)
    persistent pTable pIdx
    if isempty(pIdx)
        pIdx=uint32(1);
        pTable=[];
    end


    switch action
    case 'newIdx'
        idx=pIdx;
        pIdx=pIdx+1;

        fcnName=fcnNameOrBuffer;
        S.FunctionName=fcnName;
        S.FunctionPath=fcnPath;
        S.ExprStart=exprStart;
        S.ExprLength=exprLength;
        pTable=[pTable,S];
        out=idx;

    case 'gen_overflow_info'
        out=makeMexableDesc(pTable);
        clear pIdx;

    case 'process'
        buffer=fcnNameOrBuffer;
        out=makeTableFromMexDesc(buffer.Info,buffer.Table);
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
    exprPos=[];
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
        exprs=[exprs,{num2str(fcnIdx)}];
        exprPos(ii,1)=S.ExprStart;
        exprPos(ii,2)=S.ExprLength;
    end
    Desc.Functions=strjoin(functionIdList,sep);
    Desc.Exprs=strjoin(exprs,sep);
    Desc.ExprPos=exprPos;
end

function table=makeTableFromMexDesc(Desc,overflows)
    sep=separator();
    functions=strsplit(Desc.Functions,sep);
    exprs=strsplit(Desc.Exprs,sep);
    table=[];
    if numel(exprs)>=2
        for ii=1:1:numel(exprs)
            S.idx=ii;
            fcnIdx=str2double(exprs{ii});
            S.FunctionName=functions{2*(fcnIdx-1)+1};
            S.FunctionPath=functions{2*(fcnIdx-1)+2};
            S.ExprStart=Desc.ExprPos(ii,1);
            S.ExprLength=Desc.ExprPos(ii,2);

            S.Overflows=uint32(0);
            if ii<=numel(overflows)
                S.Overflows(:)=overflows(ii);
            end
            table=[table,S];
        end
    end
end
