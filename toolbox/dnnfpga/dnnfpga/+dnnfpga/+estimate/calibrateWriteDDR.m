

function calibrateWriteDDR(h,BURST_LEN,ddrRDbase,ddrWRbase,ipBase,input)





    h.writememory([ddrRDbase,'000'],input);

    assignin('base','input',input);




    h.writememory([ipBase,'000'],1);


    h.writememory([ipBase,'008'],hex2dec([ddrRDbase,'000']));
    h.writememory([ipBase,'00C'],hex2dec([ddrRDbase,'000']));
    h.writememory([ipBase,'010'],hex2dec([ddrWRbase,'000']));


    h.writememory([ipBase,'108'],BURST_LEN);


    h.writememory([ipBase,'10C'],1);


    h.writememory([ipBase,'110'],1);
    h.writememory([ipBase,'110'],0);


    isDone=0;
    while~isDone


        isDone=h.readmemory([ipBase,'11C'],1,'OutputDataType','uint8');
        pause(2);
    end

end
