function generateSLBlock(this,hC,targetBlkPath)





    reporterrors(this,hC);

    validBlk=1;

    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        validBlk=0;
    end


    if validBlk
        load_system('simulink');


        this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);


        blockInfo=getBlockInfo(this,hC);
        trellis=blockInfo.trellis;
        nsdec=blockInfo.nsDec;
        blkInput_latency=3;
        adder_latency=ceil(log2(blockInfo.n))-1;
        minmax_latency=ceil(log2(trellis.numStates))+2;

        latency1=blkInput_latency+adder_latency+minmax_latency;

        latency2=4;




        xpos=130;
        ypos=65;


        isBoolean=false;

        in=hC.PirInputSignals;
        inType=in.Type;
        if inType.BaseType.isBooleanType

            isBoolean=true;

            add_block('built-in/DataTypeConversion',[targetBlkPath,'/DTCin'],...
            'Position',[xpos,ypos,xpos+20,ypos+40],...
            'outDataTypeStr','fixdt(0,1,0)',...
            'sampleTime',num2str(-1));

        end

        xpos=xpos+50;

        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay1'],...
        'Position',[xpos,ypos,xpos+20,ypos+40],...
        'NumDelays',num2str(latency1),...
        'samptime',num2str(-1));




        load_system('eml_lib');
        load_system(fullfile(matlabroot,'toolbox','comm','commhdloptimized','commutilities',...
        'mviterbi_RAMTraceback_modelgen.mdl'));







        xpos=xpos+50;

        emlblock_name=[targetBlkPath,'/Viterbi_RAM'];
        add_block('mviterbi_RAMTraceback_modelgen/viterbi_RAM',...
        emlblock_name,...
        'Position',[xpos,ypos,xpos+50,ypos+40]);


        bdclose('mviterbi_RAMTraceback_modelgen');
        close_system('eml_lib');




        maskValues=get_param(emlblock_name,'MaskValues');





        maskValueList={'trellis','nsdecb','tbdepth'};

        bfp=hC.SimulinkHandle;
        for ii=1:numel(maskValueList)
            maskValues{ii}=get_param(bfp,maskValueList{ii});
        end


        maskValues{2}=num2str(nsdec);

        set_param(emlblock_name,'MaskValues',maskValues);


        [thred,normVal,stmetNT]=this.renormparam(trellis,nsdec);


        maskinistr=['thred = ',num2str(thred),';'];
        maskinistr=[maskinistr,'normVal = ',num2str(normVal),';'];
        maskinistr=[maskinistr,'decBits= ',num2str(nsdec),';'];
        maskinistr=[maskinistr,'stmetWlen = ',num2str(stmetNT.WordLength),';'];
        maskinistr=[maskinistr,'treoutputs_dec= oct2dec(trellis.outputs)+1;'];

        set_param(emlblock_name,'maskInitialization',maskinistr);


        maskEnables={'off','off','off'};
        set_param(emlblock_name,'MaskEnables',maskEnables);




        out=hC.PirOutputSignals(1);
        outType=out.Type;
        xpos=xpos+70;
        if outType.BaseType.isBooleanType
            add_block('built-in/DataTypeConversion',[targetBlkPath,'/DTC'],...
            'Position',[xpos,ypos,xpos+20,ypos+40],...
            'outDataTypeStr','boolean',...
            'sampleTime',num2str(-1));
        else
            outdt=sprintf('fixdt(%d,%d,%d)',...
            outType.BaseType.Signed,outType.BaseType.Wordlength,...
            outType.BaseType.Fractionlength);
            add_block('built-in/DataTypeConversion',[targetBlkPath,'/DTC'],...
            'Position',[xpos,ypos,xpos+20,ypos+40],...
            'outDataTypeStr',outdt,...
            'sampleTime',num2str(-1));
        end



        xpos=xpos+50;

        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay2'],...
        'Position',[xpos,ypos,xpos+20,ypos+40],...
        'NumDelays',num2str(latency2),...
        'samptime',num2str(-1));

        if(isBoolean)
            add_line(targetBlkPath,'In1/1','DTCin/1','autorouting','on');
            add_line(targetBlkPath,'DTCin/1','Delay1/1','autorouting','on');
        else
            add_line(targetBlkPath,'In1/1','Delay1/1','autorouting','on');
        end

        add_line(targetBlkPath,'Delay1/1','Viterbi_RAM/1','autorouting','on');

        add_line(targetBlkPath,'Viterbi_RAM/1','DTC/1','autorouting','on');
        add_line(targetBlkPath,'DTC/1','Delay2/1','autorouting','on');

        add_line(targetBlkPath,'Delay2/1','Out1/1','autorouting','on');
    end



