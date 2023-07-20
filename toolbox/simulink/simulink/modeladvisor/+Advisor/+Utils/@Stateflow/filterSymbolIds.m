











function filteredSymbolIds=filterSymbolIds(symbolIds,symbolType)

    switch symbolType
    case 'state',typeId=4;
    case 'event',typeId=7;
    case 'data',typeId=8;
    case 'script',typeId=14;
    otherwise,typeId=-1;
    end

    if typeId==-1
        filteredSymbolIds=[];
    else

        filteredSymbolIds=zeros(size(symbolIds));

        writeIndex=0;
        for loopIndex=1:length(symbolIds)
            if sf('get',symbolIds(loopIndex),'.isa')==typeId
                writeIndex=writeIndex+1;
                filteredSymbolIds(writeIndex)=symbolIds(loopIndex);
            end
        end

        filteredSymbolIds=filteredSymbolIds(1:writeIndex);

    end

end

