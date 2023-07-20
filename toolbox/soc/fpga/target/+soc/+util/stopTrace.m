function traceDataStruct=stopTrace(JTAGMaster,PMInfo)
    JTAGMaster.writememory(PMInfo.TRCE_CR,uint32(0));
    valid_entries=JTAGMaster.readmemory(PMInfo.TRCE_NEVT,1);
    if valid_entries==0
        disp(message('soc:msgs:noTransactionDetected').getString());
        traceDataStruct=[];
    else

        numslots=PMInfo.NumSlots;
        numDmas=PMInfo.NumDmas;





        if(numDmas==0)
            if numslots<4
                readLen=valid_entries*(numslots+1);
                catFact=(numslots+1);
            elseif numslots<8
                readLen=valid_entries*numslots;
                catFact=numslots;
            else
                readLen=valid_entries*(numslots-1);
                catFact=(numslots-1);
            end
        else
            if numslots<5
                readLen=valid_entries*(numslots+1);
                catFact=(numslots+1);
            else
                readLen=valid_entries*numslots;
                catFact=numslots;
            end
        end


        JTAGMaster.writememory(PMInfo.TRCE_FIFORP,uint32(1));
        JTAGMaster.writememory(PMInfo.TRCE_FIFORP,uint32(0));


        readdata=zeros(1,readLen);

        for i=1:readLen
            readdata(i)=JTAGMaster.readmemory(PMInfo.TRCE_FIFORD,1);
        end








        flagNames={'WAL','FW','LW','RES','RAL','FR','LR','WLEN','RLEN'};
        dmaNames={'DMA1Diag','DMA2Diag'};

        for nn=1:valid_entries
            Logdata.Overflow(nn)=false;
            Logdata.TimeDiff(nn)=0;
            Logdata.MasterValid(nn,:)=zeros(1,numslots);
            for slotCtrl=1:numslots
                slot=sprintf('Master%d',slotCtrl);
                for mm=1:numel(flagNames)
                    if(mm<8)
                        Logdata.(slot).(flagNames{mm})(nn)=false;
                    else
                        Logdata.(slot).(flagNames{mm})(nn)=0;
                    end
                end
            end
            if(numDmas~=0)
                for ii=1:numDmas
                    Logdata.(dmaNames{ii})(nn)=0;
                end
            end
        end
        for ii=1:valid_entries
            tempPacket='';







            for jj=(ii-1)*catFact+1:ii*catFact
                tempPacket=strcat(dec2bin(readdata(jj),32),tempPacket);
            end
            PacketLength=length(tempPacket);
            Logdata.Overflow(ii)=bin2dec(tempPacket(PacketLength-32));
            Logdata.TimeDiff(ii)=bin2dec(tempPacket(PacketLength-31:PacketLength));
            for slotCtrl=1:numslots
                slot=sprintf('Master%d',slotCtrl);
                for mm=1:numel(flagNames)
                    thisFlag=flagNames{mm};
                    if(mm<8)
                        Logdata.(slot).(thisFlag)(ii)=bin2dec(tempPacket(PacketLength-32-(slotCtrl-1)*24-mm));
                        if(Logdata.(slot).(thisFlag)(ii))
                            Logdata.MasterValid(ii,slotCtrl)=1;
                        end
                    elseif(mm<9)
                        Logdata.(slot).(thisFlag)(ii)=bin2dec(tempPacket(PacketLength-32-(slotCtrl-1)*24-mm-7:PacketLength-32-(slotCtrl-1)*24-mm));
                    else
                        Logdata.(slot).(thisFlag)(ii)=bin2dec(tempPacket(PacketLength-32-(slotCtrl-1)*24-mm-14:PacketLength-32-(slotCtrl-1)*24-mm-7));
                    end
                end
            end
            if(numDmas~=0)
                for nn=1:numDmas
                    Logdata.(dmaNames{nn})(ii)=bin2dec(tempPacket(PacketLength-32-(slotCtrl*24)-((nn-1)*3)-2:PacketLength-32-(slotCtrl)*24-((nn-1)*3)));
                end
            end
        end

        if any(Logdata.Overflow(2:end)~=0)
            warning("Overflow occured!");
        end
        traceDataStruct=Logdata;
    end
end