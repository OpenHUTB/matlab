function generateSLBlock(this,hC,targetBlkPath)



    reporterrors(this,hC);

    try
        if~hC.Synthetic
            originalBlkPath=getfullname(hC.SimulinkHandle);
        else
            originalBlkPath=getfullname(hC.getSLBlockHandle);
        end
        validBlk=1;
    catch me
        validBlk=0;
    end

    if validBlk

        hInSignals=hC.PirInputSignals;
        hOutSignals=hC.PirOutputSignals;
        inputType=hInSignals.Type;
        outputType=hOutSignals.Type;

        inSigned=inputType.Signed;
        inputWL=inputType.WordLength;
        inputFL=-inputType.FractionLength;
        outSigned=outputType.Signed;
        outputWL=outputType.WordLength;
        outputFL=-outputType.FractionLength;


        ufix1_in=~inSigned&&(inputWL==1);
        sfix2_in=inSigned&&(inputWL==2);
        ufix1_out=~outSigned&&(outputWL==1);
        sfix2_out=outSigned&&(outputWL==2);
        if(ufix1_in||sfix2_in||ufix1_out||sfix2_out)
            targetBlkPath=addSLBlock(this,hC,originalBlkPath,targetBlkPath);
            setBlockSampleTime(this,hC,targetBlkPath);
            return;
        end


        load_system('simulink');


        addSLBlock(this,hC,'built-in/Subsystem',targetBlkPath);
        xstep=100;
        xpos=40;
        ypos=80;
        add_block('built-in/Inport',[targetBlkPath,'/In'],...
        'Position',[xpos,ypos+14,xpos+30,ypos+28]);
        xpos=xpos+xstep;


        xpos=xpos+xstep;
        if inSigned
            delayNumBefore=2;
        else
            delayNumBefore=1;
        end
        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay1'],...
        'Position',[xpos,ypos,xpos+30,ypos+40],...
        'NumDelays',num2str(delayNumBefore),...
        'samptime',num2str(-1));
        add_line(targetBlkPath,'In/1','Delay1/1','autorouting','on');


        if inSigned
            xpos=xpos+xstep;
            add_block('built-in/Abs',[targetBlkPath,'/Abs'],...
            'Position',[xpos,ypos,xpos+30,ypos+40],...
            'RndMeth','Nearest',...
            'SaturateOnIntegerOverflow','on');
            add_line(targetBlkPath,'Delay1/1','Abs/1','autorouting','on');

            xpos=xpos+xstep;
            din_usType=pir_ufixpt_t(inputWL,-inputFL);
            [~,~,~,sldt]=localGetSLDataTypeScaling(din_usType);
            add_block('built-in/DataTypeConversion',[targetBlkPath,'/Convert'],...
            'Position',[xpos,ypos,xpos+30,ypos+40],...
            'OutDataTypestr',sldt,...
            'RndMeth','Nearest',...
            'SaturateOnIntegerOverflow','on');
            add_line(targetBlkPath,'Abs/1','Convert/1','autorouting','on');
            soutport='Convert';
        else
            soutport='Delay1';
        end


        rsqrtoutType=hdlarch.newton.getNewtonSqrtType(hInSignals(1));
        [~,~,~,sldt]=localGetSLDataTypeScaling(rsqrtoutType);


        compType=hC.ClassName;
        if strcmp(compType,'black_box_comp')
            iterNum=num2str(this.getChoice);
        else
            iterNum=num2str(hC.getIterNum);
        end
        targetblk=[targetBlkPath,'/rSqrt'];
        xpos=xpos+xstep;
        add_block('built-in/Sqrt',targetblk,...
        'Position',[xpos,ypos,xpos+30,ypos+40],...
        'RndMeth','Nearest',...
        'SaturateOnIntegerOverflow','on',...
        'Function','rSqrt',...
        'AlgorithmType','Newton-Raphson',...
        'Iterations',iterNum,...
        'IntermediateResultsDataTypeStr','Inherit: Inherit from output',...
        'OutDataTypeStr',sldt);

        add_line(targetBlkPath,[soutport,'/1'],'rSqrt/1','autorouting','on');


        xpos=xpos+xstep;
        add_block('built-in/Product',[targetBlkPath,'/Product'],...
        'Position',[xpos,ypos,xpos+30,ypos+50],...
        'InputSameDT','off',...
        'RndMeth','Nearest',...
        'SaturateOnIntegerOverflow','on');


        if inSigned
            dout_usType=pir_ufixpt_t(outputWL,-outputFL);
        else
            dout_usType=outputType;
        end
        [~,~,~,sldt]=localGetSLDataTypeScaling(dout_usType);
        set_param([targetBlkPath,'/Product'],'OutDataTypeStr',sldt);
        add_line(targetBlkPath,'rSqrt/1','Product/1','autorouting','on');
        add_line(targetBlkPath,'rSqrt/1','Product/2','autorouting','on');


        xpos=xpos+xstep;
        if inSigned
            ASPath=[targetBlkPath,'/AddSign'];
            add_block('built-in/Subsystem',ASPath,...
            'Position',[xpos,ypos,xpos+30,ypos+40]);
            drawAddSign(ASPath,outputType,outSigned);
            add_line(targetBlkPath,'Product/1','AddSign/1','autorouting','on');
            add_line(targetBlkPath,'Delay1/1','AddSign/2','autorouting','on');
            osoutport='AddSign';
        else
            osoutport='Product';
        end


        latencyInfo=this.getLatencyInfo(hC);
        latencyNum=latencyInfo.outputDelay;


        xpos=xpos+xstep;
        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay2'],...
        'Position',[xpos,ypos,xpos+30,ypos+40],...
        'NumDelays',num2str(latencyNum-delayNumBefore),...
        'samptime',num2str(-1));
        add_line(targetBlkPath,[osoutport,'/1'],'Delay2/1','autorouting','on');

        xpos=xpos+xstep;
        add_block('built-in/Outport',[targetBlkPath,'/Out'],...
        'Position',[xpos,ypos+3,xpos+30,ypos+17]);
        add_line(targetBlkPath,portPath([targetBlkPath,'/Delay2'],1),portPath([targetBlkPath,'/Out'],1),...
        'autorouting','on');
    end



    function[mode,dt,scl,sldt]=localGetSLDataTypeScaling(inType,col)

        [insltype,sldtprops]=getslsignaltype(inType);
        if sldtprops.isnative
            sldt=insltype.native;
        else
            sldt=insltype.viadialog;
        end
        [insize,inbp,insigned]=hdlwordsize(insltype.native);
        sizes=[insize,inbp,insigned];

        if sizes(1)==0
            mode='double';
            dt='sfix(32)';
            scl='2^0';
        else
            if nargin>1
                sizes(1)=sizes(1)*2*col;
                sizes(2)=sizes(2)*2;
            end

            mode='Specify via dialog';
            dt=sprintf('fix(%d)',sizes(1));
            if sizes(2)<0
                scl=sprintf('2^%d',-sizes(2));
            else
                scl=sprintf('2^-%d',sizes(2));
            end
            if sizes(3)
                dt=['s',dt];
            else
                dt=['u',dt];
            end

        end


        function drawAddSign(ASPath,dtcoutType,outSigned)

            xstep=80;
            xpos=40;
            ypos=80;

            add_block('built-in/Inport',[ASPath,'/In1'],...
            'Position',[xpos,ypos,xpos+30,ypos+14]);

            add_block('built-in/Inport',[ASPath,'/In2'],...
            'Position',[xpos,ypos+50,xpos+30,ypos+64]);

            xpos=xpos+xstep;
            [~,~,~,sldt]=localGetSLDataTypeScaling(dtcoutType);
            add_block('built-in/DataTypeConversion',[ASPath,'/Convert'],...
            'Position',[xpos,ypos,xpos+30,ypos+40],...
            'OutDataTypestr',sldt,...
            'RndMeth','Nearest',...
            'SaturateOnIntegerOverflow','on');

            xpos=xpos+xstep;
            add_block('built-in/Signum',[ASPath,'/Sign'],...
            'Position',[xpos,ypos+50,xpos+30,ypos+90]);

            if outSigned
                add_block(['simulink/Math',char(10),'Operations/Unary Minus'],[ASPath,'/Minus'],...
                'Position',[xpos,ypos+100,xpos+30,ypos+140]);
                add_line(ASPath,portPath([ASPath,'/Convert'],1),portPath([ASPath,'/Minus'],1),...
                'autorouting','on');
            else
                add_block('built-in/Constant',[ASPath,'/Minus'],...
                'Position',[xpos,ypos+100,xpos+30,ypos+140],...
                'Value','0',...
                'SampleTime',num2str(-1),...
                'OutDataTypestr',sldt);
            end

            xpos=xpos+xstep;
            add_block('built-in/Switch',[ASPath,'/Switch'],...
            'Position',[xpos,ypos,xpos+40,ypos+50],...
            'RndMeth','Nearest',...
            'SaturateOnIntegerOverflow','on',...
            'Criteria','u2 >= Threshold',...
            'Threshold','0');

            xpos=xpos+xstep;
            add_block('built-in/Outport',[ASPath,'/Out'],...
            'Position',[xpos,ypos+13,xpos+30,ypos+27]);

            add_line(ASPath,portPath([ASPath,'/In1'],1),portPath([ASPath,'/Convert'],1),...
            'autorouting','on');
            add_line(ASPath,portPath([ASPath,'/Convert'],1),portPath([ASPath,'/Switch'],1),...
            'autorouting','on');
            add_line(ASPath,portPath([ASPath,'/In2'],1),portPath([ASPath,'/Sign'],1),...
            'autorouting','on');
            add_line(ASPath,portPath([ASPath,'/Sign'],1),portPath([ASPath,'/Switch'],2),...
            'autorouting','on');
            add_line(ASPath,portPath([ASPath,'/Minus'],1),portPath([ASPath,'/Switch'],3),...
            'autorouting','on');
            add_line(ASPath,portPath([ASPath,'/Switch'],1),portPath([ASPath,'/Out'],1),...
            'autorouting','on');



            function path=portPath(blkPath,portNumber)
                sep=strfind(blkPath,'/');
                if~isempty(sep)
                    blkPath=blkPath(sep(end)+1:end);
                end
                path=sprintf('%s/%d',blkPath,portNumber);



