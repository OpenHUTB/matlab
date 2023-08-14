function generateSLBlock(this,hC,targetBlkPath)



    reporterrors(this,hC);

    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
        validBlk=1;
    catch me
        validBlk=0;
    end


    latencyInfo=this.getLatencyInfo(hC);
    latencyNum=latencyInfo.outputDelay;

    if validBlk
        load_system('simulink');

        hInSignals=hC.PirInputSignals;
        hOutSignals=hC.PirOutputSignals;


        targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);


        xpos=145;
        ypos=65;
        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay1'],...
        'Position',[xpos,ypos,xpos+30,ypos+40],...
        'NumDelays',num2str(1),...
        'samptime',num2str(-1));
        add_line(targetBlkPath,'In1/1','Delay1/1','autorouting','on');


        rsqrtoutType=hdlarch.newton.getNewtonSqrtType(hInSignals(1));
        [~,~,~,sldt]=localGetSLDataTypeScaling(rsqrtoutType);


        targetblk=[targetBlkPath,'/rSqrt'];
        xpos=xpos+60;
        add_block('built-in/Sqrt',targetblk,...
        'Position',[xpos,ypos-30,xpos+30,ypos+10],...
        'RndMeth','Nearest',...
        'SaturateOnIntegerOverflow','on',...
        'Function','rSqrt',...
        'AlgorithmType','Newton-Raphson',...
        'Iterations',num2str(this.getChoice),...
        'IntermediateResultsDataTypeStr','Inherit: Inherit from output',...
        'OutDataTypeStr',sldt);
        add_line(targetBlkPath,'Delay1/1','rSqrt/1','autorouting','on');


        xpos=xpos+60;
        add_block('built-in/Product',[targetBlkPath,'/Product'],...
        'Position',[xpos,ypos,xpos+30,ypos+50],...
        'InputSameDT','off',...
        'RndMeth',get_param(originalBlkPath,'RndMeth'),...
        'SaturateOnIntegerOverflow',get_param(originalBlkPath,'SaturateOnIntegerOverflow'));


        outputType=hOutSignals(1).Type;
        [~,~,~,sldt]=localGetSLDataTypeScaling(outputType);
        set_param([targetBlkPath,'/Product'],'OutDataTypeStr',sldt);
        add_line(targetBlkPath,'rSqrt/1','Product/1','autorouting','on');
        add_line(targetBlkPath,'Delay1/1','Product/2','autorouting','on');


        xpos=xpos+60;
        ypos=ypos+10;
        add_block('simulink/Discrete/Integer Delay',[targetBlkPath,'/Delay2'],...
        'Position',[xpos,ypos,xpos+30,ypos+40],...
        'NumDelays',num2str(latencyNum-1),...
        'samptime',num2str(-1));
        add_line(targetBlkPath,'Product/1','Delay2/1','autorouting','on');
        add_line(targetBlkPath,'Delay2/1','Out1/1','autorouting','on');

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

