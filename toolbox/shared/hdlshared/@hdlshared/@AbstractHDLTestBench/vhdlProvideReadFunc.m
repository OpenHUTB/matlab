function hdlbody=vhdlProvideReadFunc(this,hdlbody,fpTransmitMap,iosize,clkHold,FlagTxtOrTx,vectorPortSize)



    TxtValueSet=fpTransmitMap.values;
    TxtKeySet=fpTransmitMap.keys;

    morespace='      ';


    for ii=1:numel(TxtKeySet)
        hdlbody=[hdlbody,morespace,...
        'IF  not (ENDFILE(',['fp_',char(TxtKeySet{ii})],')) THEN\n'];

        hdlbody=[hdlbody,morespace,morespace,'readline(',...
        ['fp_',char(TxtKeySet{ii})],...
        ',',['line_',char(TxtKeySet{ii})],');\n'];

    end

    if iosize~=1
        prestr='SLICE(to_bitvector(';
        poststr=['),',int2str(iosize),')'];
        fread='hread(';
    else
        prestr=[];
        poststr=[];
        fread='read(';
    end




    for jj=1:numel(TxtKeySet)
        flatVal=cellstr(TxtValueSet{jj});
        fpKey=TxtKeySet{jj};

        hdlTxtBody=[];
        for mm=1:vectorPortSize
            hdlbody=[hdlbody,...
            morespace,morespace,fread,...
            ['line_',char(fpKey)],...
            ',',['data_',char(fpKey),'_',num2str(mm)],');\n'];


            hdlTxtBody=[hdlTxtBody,...
            prestr,['data_',char(fpKey),'_',num2str(mm)],poststr];


            if mm~=vectorPortSize
                hdlTxtBody=[hdlTxtBody,',\n',[morespace,morespace]];
            end
        end
        hdlbody=[hdlbody,...
        '       END IF;\n'];

        if strcmp(FlagTxtOrTx,'Txt')
            for kk=1:numel(flatVal)
                hdlbody=[morespace,morespace,hdlbody,'      ',...
                char(flatVal{kk}),' <= ','(',hdlTxtBody,')',...
                'AFTER ',clkHold,';\n'];
            end
        elseif strcmp(FlagTxtOrTx,'Rx')
            hdlbody=[hdlbody,'      ',...
            [char(fpKey),'_expected'],' := ','(',hdlTxtBody,');\n'];
            hdlbody=[hdlbody,'      ',...
            [char(fpKey),'_ref'],' <= ',[char(fpKey),'_expected'],';\n'];
        else
            error('unknown property for FlagTxtOrTx');
        end

    end

end