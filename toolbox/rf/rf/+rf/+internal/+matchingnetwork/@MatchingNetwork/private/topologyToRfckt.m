


function ckt=topologyToRfckt(net,values)

    rfcktslist=arrayfun(@helperfcn,net,values,'UniformOutput',0);



    ckt=arrayfun(@(k)(helperfcn2(rfcktslist(k,1:end))),1:length(rfcktslist(:,1)));

end

function cktpiece=helperfcn(componenttype,value)
    EMPTY=0;
    SER_CAP=1;
    SER_INDCT=2;
    SHNT_CAP=3;
    SHNT_INDCT=4;
    SER_RES=5;
    SHNT_RES=6;
    switch(componenttype)
    case SER_CAP
        cktpiece=rfckt.seriesrlc('C',value);
    case SER_INDCT
        cktpiece=rfckt.seriesrlc('L',value);
    case SHNT_CAP
        cktpiece=rfckt.shuntrlc('C',value);
    case SHNT_INDCT
        cktpiece=rfckt.shuntrlc('L',value);
    case SER_RES
        cktpiece=rfckt.shuntrlc('R',value);
    case SHNT_RES
        cktpiece=rfckt.shuntrlc('R',value);
    case EMPTY

        cktpiece=[];
    otherwise

        error(message('rf:matchingnetwork:UndefinedElement','topologyToRfckt'));
    end
end

function ckt=helperfcn2(cascadeComponents)
    filteredList=cascadeComponents;
    filteredList(cellfun(@(a)isempty(a),filteredList))=[];
    if(isempty(filteredList))
        ckt=rfckt.cascade;

        warning(message('rf:matchingnetwork:RfcktExport_EmptyResult'));
    else
        ckt=rfckt.cascade('Ckts',filteredList);
    end
end