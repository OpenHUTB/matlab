

function[ReadLatency,WriteLatency]=calibrateReadDDR(h,IPBase)







    h.writememory([IPBase,'10C'],0);

    h.writememory([IPBase,'110'],1);
    h.writememory([IPBase,'110'],0);


    isDone=0;
    while~isDone


        isDone=h.readmemory([IPBase,'120'],1,'OutputDataType','uint8');
        pause(2);
    end



    ReadLatency=h.readmemory([IPBase,'114'],1,'OutputDataType','uint32');
    WriteLatency=h.readmemory([IPBase,'118'],1,'OutputDataType','uint32');

end
