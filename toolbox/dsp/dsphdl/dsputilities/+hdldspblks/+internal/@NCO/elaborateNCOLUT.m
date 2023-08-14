function lutNet=elaborateNCOLUT(~,topNet,blockInfo,dataRate)




    if blockInfo.PhaseQuantization
        quantWL=blockInfo.quantWL;

    else
        quantWL=blockInfo.accumDType.WordLength;

    end

    lutaddrType=pir_ufixpt_t(quantWL-2,0);
    outType=pir_sfixpt_t(blockInfo.outWL,-blockInfo.outFL);

    inportnames={'lutaddr'};
    inporttypes=lutaddrType;
    inportrates=dataRate;
    outportnames={'lutoutput'};
    outporttypes=outType;


    lutNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','LookUpTableGen',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',outportnames,...
    'OutportTypes',outporttypes...
    );

    tlutaddr=lutNet.PirInputSignals(1);
    lutout=lutNet.PirOutputSignals(1);


    [tabledata,tableidx,bpType,oType,fType]=ComputeLUT(blockInfo,quantWL);

    comp=pirelab.getLookupNDComp(lutNet,tlutaddr,lutout,tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
    comp.addComment(' Quarter sine wave table');



end


function[table1,idx1,bpType1,oType,fType]=ComputeLUT(blockInfo,quantWL)

    outWL=blockInfo.outWL;
    outFL=blockInfo.outFL;


    Fsat=fimath('RoundMode','Nearest',...
    'OverflowMode','Saturate',...
    'SumMode','KeepLSB',...
    'SumWordLength',outWL,...
    'SumFractionLength',outFL,...
    'CastBeforeSum',true);


    oType=fi(0,1,outWL,outFL);
    fType=fi(0,0,32,31);



    dataIn=0:2^(quantWL-2)-1;
    quarterSine=sin(pi/2*dataIn/2^(quantWL-2));

    bpType1=fi(0,0,quantWL-2,0);
    idx1={fi(dataIn,bpType1.numerictype)};
    table1=fi(quarterSine,oType.numerictype,Fsat);

end