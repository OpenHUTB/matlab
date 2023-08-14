function hModeVecTypeConversion=utilAddModeVecTypeConversion(parent,refModeVecs,refQVecs,position,intModeInds,globalInfo)






    intModeInds=sort(intModeInds,'ascend');

    hModeVecTypeConversion=utilAddSubsystem(parent,'Mode Vector Type Conversion',position);
    modeVectorTypeConversion=getfullname(hModeVecTypeConversion);


    hmodeVectorTypeConversionSystemIn1=add_block('hdlsllib/Sources/In1',strcat(modeVectorTypeConversion,'/Mode vec'),...
    'MakeNameUnique','on');

    fModechart=matlab.internal.feature("SSC2HDLModechart");

    if(fModechart)
        if(globalInfo.numQs>0)
            hmodeVectorTypeConversionSystemInQ=add_block('hdlsllib/Sources/In1',strcat(modeVectorTypeConversion,'/Q vec'),...
            'MakeNameUnique','on');
        end
    end


    hmodeVectorTypeConversionSystemOut1h=add_block('hdlsllib/Sinks/Out1',strcat(modeVectorTypeConversion,'/Out1'),...
    'MakeNameUnique','on');



    numModes=size(refModeVecs,1);

    if(fModechart)
        numModes=numModes+size(refQVecs,1);
    end


    set_param(hmodeVectorTypeConversionSystemIn1,'Position',[125,78,155,92]);
    set_param(hmodeVectorTypeConversionSystemOut1h,'Position',[675,88,705,102]);

    hselectors={};
    hconversions={};

    slDrawLimit=32767;

    ssPosIncr=floor(double(slDrawLimit)/(numModes+1));
    if ssPosIncr>50
        ssPosIncr=50;
    end
    initialPos=[315,75,360,115];

    if~isempty(refModeVecs)

        if(isempty(intModeInds))


            hconversions{end+1}=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(modeVectorTypeConversion,'/Data Type Conversion'),...
            'MakeNameUnique','on',...
            'Position',initialPos+[80,0,80,0],...
            'OutDataTypeStr','boolean',...
            'RndMeth','Nearest');



            add_line(modeVectorTypeConversion,strcat(get_param(hmodeVectorTypeConversionSystemIn1,'Name'),'/1'),strcat(get_param(hconversions{1},'Name'),'/1'),...
            'autorouting','on');

            initialPos=initialPos+[0,ssPosIncr,0,ssPosIncr];

        else

            index=0;


            for ii=intModeInds

                if(ii-index>1)


                    hselectors{end+1}=add_block('hdlsllib/Signal Routing/Selector',strcat(modeVectorTypeConversion,'/SelectMode'),...
                    'MakeNameUnique','on',...
                    'Indices',strcat('[',int2str((index+1):(ii-1)),']'),...
                    'InputPortWidth','-1',...
                    'Position',initialPos);


                    add_line(modeVectorTypeConversion,strcat(get_param(hmodeVectorTypeConversionSystemIn1,'Name'),'/1'),strcat(get_param(hselectors{end},'Name'),'/1'),...
                    'autorouting','on');

                    hconversions{end+1}=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(modeVectorTypeConversion,'/Data Type Conversion'),...
                    'MakeNameUnique','on',...
                    'Position',initialPos+[80,0,80,0],...
                    'OutDataTypeStr','boolean',...
                    'RndMeth','Nearest');


                    add_line(modeVectorTypeConversion,strcat(get_param(hselectors{end},'Name'),'/1'),strcat(get_param(hconversions{end},'Name'),'/1'),...
                    'autorouting','on');

                    initialPos=initialPos+[0,ssPosIncr,0,ssPosIncr];
                end



                largestValue=max(abs(refModeVecs(ii,:)),[],'all');
                numDigits=length(dec2bin(largestValue));

                hconversions{end+1}=addIntMode(modeVectorTypeConversion,hmodeVectorTypeConversionSystemIn1,ii,largestValue,numDigits,initialPos);

                initialPos=initialPos+[0,ssPosIncr+50,0,ssPosIncr+50];

                index=ii;

            end


            if(intModeInds(end)<size(refModeVecs,1))


                hselectors{end+1}=add_block('hdlsllib/Signal Routing/Selector',strcat(modeVectorTypeConversion,'/SelectMode'),...
                'MakeNameUnique','on',...
                'Indices',strcat('[',int2str((intModeInds(end)+1):(size(refModeVecs,1))),']'),...
                'InputPortWidth','-1',...
                'Position',initialPos);


                add_line(modeVectorTypeConversion,strcat(get_param(hmodeVectorTypeConversionSystemIn1,'Name'),'/1'),strcat(get_param(hselectors{end},'Name'),'/1'),...
                'autorouting','on');

                hconversions{end+1}=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(modeVectorTypeConversion,'/Data Type Conversion'),...
                'MakeNameUnique','on',...
                'Position',initialPos+[80,0,80,0],...
                'OutDataTypeStr','boolean',...
                'RndMeth','Nearest');


                add_line(modeVectorTypeConversion,strcat(get_param(hselectors{end},'Name'),'/1'),strcat(get_param(hconversions{end},'Name'),'/1'),...
                'autorouting','on');
            end
        end

    elseif(fModechart)

        hTerm=add_block('hdlsllib/Sinks/Terminator',[modeVectorTypeConversion,'/term'],...
        'MakeNameUnique','on',...
        'Position',[935,130,955,150]);

        add_line(modeVectorTypeConversion,strcat(get_param(hmodeVectorTypeConversionSystemIn1,'Name'),'/1'),strcat(get_param(hTerm,'Name'),'/1'),...
        'autorouting','on');
    end

    if(fModechart)
        if~isempty(refQVecs)

            hQConversion=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(modeVectorTypeConversion,'/Data Type Conversion'),...
            'MakeNameUnique','on',...
            'OutDataTypeStr','int32',...
            'RndMeth','Nearest');

            add_line(modeVectorTypeConversion,strcat(get_param(hmodeVectorTypeConversionSystemInQ,'Name'),'/1'),strcat(get_param(hQConversion,'Name'),'/1'),...
            'autorouting','on');

            for i=1:size(refQVecs,1)


                largestValue=max(abs(refQVecs(i,:)),[],'all');
                numDigits=length(dec2bin(largestValue));

                hconversions{end+1}=addIntMode(modeVectorTypeConversion,hQConversion,i,largestValue,numDigits,initialPos);

                initialPos=initialPos+[0,ssPosIncr+50,0,ssPosIncr+50];
            end
        elseif(globalInfo.numQs>0)
            hTerm=add_block('hdlsllib/Sinks/Terminator',[modeVectorTypeConversion,'/term'],...
            'MakeNameUnique','on',...
            'Position',[935,130,955,150]);

            add_line(modeVectorTypeConversion,strcat(get_param(hmodeVectorTypeConversionSystemInQ,'Name'),'/1'),strcat(get_param(hTerm,'Name'),'/1'),...
            'autorouting','on');

        end
    end

    if(numel(hconversions)>1)


        hVecConcat=add_block('hdlsllib/Math Operations/Vector Concatenate',strcat(modeVectorTypeConversion,'/Vector Concat'),...
        'numInputs',int2str(numel(hconversions)),...
        'MakeNameUnique','on',...
        'Position',[515,71,585,119]);


        for ii=1:numel(hconversions)
            add_line(modeVectorTypeConversion,strcat(get_param(hconversions{ii},'Name'),'/1'),strcat(get_param(hVecConcat,'Name'),strcat('/',int2str(ii))),...
            'autorouting','on');
        end

        add_line(modeVectorTypeConversion,strcat(get_param(hVecConcat,'Name'),'/1'),strcat(get_param(hmodeVectorTypeConversionSystemOut1h,'Name'),'/1'),...
        'autorouting','on');
    else

        add_line(modeVectorTypeConversion,strcat(get_param(hconversions{1},'Name'),'/1'),strcat(get_param(hmodeVectorTypeConversionSystemOut1h,'Name'),'/1'),...
        'autorouting','on');
    end

end



function hconversion=addIntMode(modeVectorTypeConversion,hIn,index,largestValue,numDigits,position)


    hSelector=add_block('hdlsllib/Signal Routing/Selector',strcat(modeVectorTypeConversion,'/SelectMode'),...
    'MakeNameUnique','on',...
    'Indices',strcat('[',int2str(index),']'),...
    'InputPortWidth','-1',...
    'Position',position);


    add_line(modeVectorTypeConversion,strcat(get_param(hIn,'Name'),'/1'),strcat(get_param(hSelector,'Name'),'/1'),...
    'autorouting','on');



    intToBoolFcnString=join(['function boolMode = integerToBits(u)',newline,...
    'numDigits = ',int2str(numDigits),';',newline...
    ,'boolMode = logical([ (u>=0); reshape(bitget(abs(u), [numDigits:-1:1]), numDigits, 1)]);',newline,'end']);



    hconversion=add_block('hdlsllib/User-Defined Functions/MATLAB Function',strcat(modeVectorTypeConversion,'/Convert Int to Bool'),...
    'MakeNameUnique','on',...
    'Position',position+[80,0,80,0]);
    hmatlabCodeBlk=find(slroot,'-isa','Stateflow.EMChart','Path',getfullname(hconversion));


    hdlset_param(getfullname(hconversion),'Architecture','MATLAB Datapath');

    hmatlabCodeBlk.Script=intToBoolFcnString;
    hmatlabCodeBlk.TreatAsFi='Fixed-point & Integer';
    hmatlabCodeBlk.Inputs(1).DataType='int32';
    hmatlabCodeBlk.Outputs(1).DataType='boolean';
    hmatlabCodeBlk.InputFimath=join(['fimath('...
    ,'''RoundMode'', ''floor'','...
    ,'''OverflowMode'', ''wrap'','...
    ,'''ProductMode'', ''KeepLSB'', ''ProductWordLength'', 32,'...
    ,'''SumMode'', ''KeepLSB'', ''SumWordLength'', 32,'...
    ,'''CastBeforeSum'', true)']);


    hAssert=add_block(sprintf('hdlsllib/Model Verification/Check \nStatic Range'),strcat(modeVectorTypeConversion,'/Out-of-range Mode Assert'),...
    'MakeNameUnique','on',...
    'enabled','on',...
    'max',int2str(largestValue),...
    'min',int2str(-largestValue),...
    'Position',position+[100,25,100,25]);


    add_line(modeVectorTypeConversion,strcat(get_param(hSelector,'Name'),'/1'),strcat(get_param(hAssert,'Name'),'/1'),...
    'autorouting','on');



    add_line(modeVectorTypeConversion,strcat(get_param(hSelector,'Name'),'/1'),strcat(get_param(hconversion,'Name'),'/1'),...
    'autorouting','on');

end
