function hdlbody=vhdlGetfpVarDeclaration(this,hdlbody,fpTransmitMap,vtype,vectorPortSize,iosize)

    TxtValueSet=fpTransmitMap.values;
    TxtKeySet=fpTransmitMap.keys;


    if iosize==1
        ioTypeStr='std_logic';
    else
        mod4=mod(iosize,4);
        switch mod4
        case 0
            vecMax=iosize-1;
        case 1
            vecMax=(iosize+3)-1;
        case 2
            vecMax=(iosize+2)-1;
        case 3
            vecMax=(iosize+1)-1;
        end

        ioTypeStr=['std_logic_vector(',...
        num2str(vecMax),...
        ' DOWNTO ','0',')'];
    end


    for ii=1:numel(TxtKeySet)


        hdlbody=[hdlbody,'  FILE ',...
        ['fp_',char(TxtKeySet{ii})],...
        ' :TEXT OPEN READ_MODE IS ',...
        '"',[char(TxtKeySet{ii}),'.dat";\n']];


        hdlbody=[hdlbody,'  VARIABLE ',...
        ['line_',char(TxtKeySet{ii})],...
        ' :line;\n'];


        hdlbody=[hdlbody,'  VARIABLE ',...
        [char(TxtKeySet{ii}),'_expected'],...
        ' :',vtype,';\n'];


        for mm=1:vectorPortSize
            hdlbody=[hdlbody,'  VARIABLE ',...
            ['data_',char(TxtKeySet{ii}),'_',num2str(mm)],...
            ' :',ioTypeStr,';\n'];
        end
    end


