function[ports,signals]=splitMatrix2RowVectors(hN,hInSignals)




    ht=hInSignals.Type;
    hBaseT=ht.BaseType;
    maxrow=hInSignals.Type.Dimensions(1);
    maxcol=hInSignals.Type.Dimensions(2);
    hInScalar=hdlhandles(maxcol,maxrow);
    colSplit=hInSignals.split;
    baseRow=0;
    for cc=1:maxcol
        csig=colSplit.PirOutputSignals(cc).split;
        for rr=1:maxrow
            myRow=baseRow+rr;
            hInScalar(cc,myRow)=csig.PirOutputSignals(rr);
        end
    end


    signals=hdlhandles(1,maxrow);
    hColType=hN.getType('Array','BaseType',hBaseT,'Dimensions',...
    maxcol,'VectorOrientation',2);


    ports=[];
    for cc=1:maxrow
        signals(cc)=hN.addSignal(hColType,sprintf('row_%d',cc));
        newC=pirelab.getConcatenateComp(hN,hInScalar(:,cc),signals(cc),...
        'Vector','2');
        ports=[ports,newC.PirOutputPorts];%#ok<AGROW>
    end
end