function generateSLBlock(this,hC,targetBlkPath)



    reporterrors(this,hC);

    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        error(message('hdlcoder:validate:invalidblockpath',...
        sprintf('%e',hC.SimulinkHandle)));
    end

    if hC.getIsNativeFloatingPoint
        outDelay=hC.getImplementationLatency;
        generateSLBlockWithDelay(this,hC,originalBlkPath,targetBlkPath,outDelay);
        return
    end



    if this.optimizeForModelGen([],hC)

        addSLBlock(this,hC,originalBlkPath,targetBlkPath);
    else

        in1=hC.SLInputPorts(1).Signal;
        in1vect=hdlsignalvector(in1);
        vectorsize=max(in1vect);

        xstep=60;
        ystep=60;
        yqtrstep=ystep/2;
        xqtrstep=ystep/2;
        yinc=vectorsize*yqtrstep;
        ycenter=85+yinc;
        xpos=85;
        ypos=ycenter;


        targetBlkPath=addSLBlock(this,hC,'built-in/Subsystem',targetBlkPath);
        [turnhilitingon,color]=getHiliteInfo;
        set_param(targetBlkPath,'BackgroundColor',color);
        if turnhilitingon
            hiliteBlkAncestors(targetBlkPath,color);
        end


        for ii=1:length(hC.SLInputPorts)
            inportPath=[targetBlkPath,'/In',int2str(ii)];
            portCenter=ypos+(ii-1)*yqtrstep;
            DTstruct=getslsignaltype(hC.SLInputSignals(ii).Type);
            add_block('built-in/Inport',inportPath,...
            'OutDataTypeStr',DTstruct.viadialog,...
            'Position',[xpos,portCenter-7,xpos+30,portCenter+7]);
        end


        xpos=xpos+xstep;
        ypos=ycenter-8;
        itr=2;
        [~,~,accType,inputSigns]=this.getBlockInfo(hC);

        while numel(inputSigns)>=2
            cblk=['Sum',int2str(itr)];
            sumcol=[targetBlkPath,'/',cblk];


            dt=localGetModeOutDataTypeScaling(accType);

            if numel(inputSigns)<=2
                outType=hC.PirOutputSignals(1).Type.getLeafType;
                outt=localGetModeOutDataTypeScaling(outType);
            else
                outt=dt;
            end

            add_block('built-in/Sum',sumcol,...
            'Inputs',inputSigns(1:2),...
            'Position',[xpos,ypos,xpos+xqtrstep,ypos+yqtrstep],...
            'InputSameDT',get_param(hC.SimulinkHandle,'InputSameDT'),...
            'OutDataTypeStr',outt,...
            'AccumDataTypeStr',dt,...
            'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
            'SaturateOnIntegerOverflow',...
            get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));

            if itr==2
                prevStageOp='In1/1';
            end
            currStageIp=['In',int2str(itr),'/1'];

            add_line(targetBlkPath,prevStageOp,[cblk,'/1'],'autorouting','on');
            add_line(targetBlkPath,currStageIp,[cblk,'/2'],'autorouting','on');

            prevStageOp=[cblk,'/1'];
            itr=itr+1;
            ypos=ypos+ystep;
            xpos=xpos+xstep;
            inputSigns(2)='+';
            inputSigns(1)=[];
        end


        ypos=ypos-yqtrstep;
        add_block('built-in/Outport',[targetBlkPath,'/Out1'],'Position',...
        [xpos,ypos,xpos+30,ypos+14]);
        add_line(targetBlkPath,[cblk,'/1'],'Out1/1','autorouting','on');
    end
end


function hiliteBlkAncestors(blkPath,color)
    while~isempty(blkPath)
        set_param(blkPath,'BackgroundColor',color);
        blkPath=get_param(blkPath,'Parent');
        if isempty(get_param(blkPath,'Parent'))
            break;
        end
    end
end


function[turnhilitingon,color]=getHiliteInfo
    hCoderObj=hdlcurrentdriver;
    color=hCoderObj.getParameter('hilitecolor');
    turnhilitingon=hCoderObj.getParameter('hiliteancestors');
end


function dt=localGetModeOutDataTypeScaling(accType)
    if accType.isFloatType
        dt='double';
    elseif accType.isWordType
        dt=sprintf('fixdt(%d,%d,%d)',...
        accType.Signed,accType.WordLength,-accType.FractionLength);
    else
        dt='';
    end

    if accType.isComplexType
        dt=['Complex(',dt,',',dt,')'];
    end
end
