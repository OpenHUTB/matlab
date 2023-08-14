function[uname,index]=hdlnewsignal(name,~,porthandle,complexity,isvector,vtype,sltype,rate,forward)












    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);


    if nargin<8
        rate=0;
    end


    if nargin<9
        forward=0;
    end

    if length(isvector)>1&&~any(isvector==0)&&max(isvector)~=prod(isvector)
        error(message('HDLShared:directemit:matrixnotsupported'));
    end

    if hdlispirbased||~emitMode
        if emitMode

            hDriver=hdlcurrentdriver;
            hN=hDriver.getCurrentNetwork;
        else
            if(rate==0)
                rate=hN.PirInputSignals(1).SimulinkRate;
            end
        end

        index=pirhdlnewsignal(...
        hN,name,porthandle,complexity,isvector,vtype,sltype,rate,forward);
        uname=index.Name;
    else
        signalTable=hdlgetsignaltable;

        if max(isvector)==1
            isvector=0;
        end
        [uname,index]=signalTable.createNewSignal(...
        name,porthandle,complexity,isvector,vtype,sltype,rate,forward);
    end
end
