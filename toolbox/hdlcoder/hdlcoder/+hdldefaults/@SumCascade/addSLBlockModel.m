function[outputBlk,outputBlkPosition]=addSLBlockModel(this,hC,originalBlkPath,targetBlkPath)





    decomposition=1;
    bfp=hC.SimulinkHandle;

    if any(strcmp(fieldnames(get_param(bfp,'objectparameters')),'roundingMode'))
        rnd=get_param(bfp,'roundingMode');
        sat=strcmp(get_param(bfp,'overflowMode'),'on');
    else
        sat=strcmp(get_param(bfp,'DoSatur'),'on');
        rnd=get_param(bfp,'RndMeth');
    end

    in=hC.SLInputPorts(1).Signal;

    if length(in)==1
        invectsize=max(hdlsignalvector(in));
        if all(invectsize==0)
            invect=in;
        else
            invect=hdlexpandvectorsignal(in);
        end
    else
        invect=in;
    end

    config.invectsize=invectsize;
    config.decomposition=decomposition;
    config.rounding=rnd;
    config.saturation=sat;

    [outputBlk,outputBlkPosition]=implement_cascade(this,hC,config,originalBlkPath,targetBlkPath);




    function[outputBlk,outputBlkPosition]=implement_cascade(this,hC,config,originalBlkPath,targetBlkPath)

        start_position=[185,75];
        move_right=[200,0];
        move_down=[0,100];

        if config.invectsize<2
            decompose_vector=[1];
        else
            decompose_vector=hdlcascadedecompose(config.invectsize,config.decomposition);
        end

        first_element=1;
        invect_cell={};
        for cloop=1:length(decompose_vector)
            invect_1=[];
            if cloop==length(decompose_vector)
                last_element=(decompose_vector(cloop)+first_element-1);
                for i=first_element:last_element
                    invect_1=[invect_1,(cloop+i-1)];
                end
            else
                last_element=(decompose_vector(cloop)+first_element-2);
                for i=first_element:last_element
                    invect_1=[invect_1,(cloop+i-1)];
                end
            end
            first_element=first_element+decompose_vector(cloop)-2;
            invect_cell{end+1}=invect_1;
        end

        out=hC.SLOutputPorts(1).Signal;
        dt=localGetModeOutDataTypeScaling(out.Type);

        [compType,accumType]=this.getBlockInfo(hC.SimulinkHandle,out.Type);
        [dt_accum,sldt_accum]=localGetModeOutDataTypeScaling(accumType);


        if length(decompose_vector)==1
            if(decompose_vector>=3)




                genDataTypeConvertorPath=[targetBlkPath,'/',hC.Name,'_DataTypeConvertor'];
                add_block('built-in/DataTypeConversion',genDataTypeConvertorPath,...
                'OutDataTypeStr',dt_accum,...
                'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
                'SaturateOnIntegerOverflow',...
                get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));
                blkPosition=[start_position,start_position+blockSize(genDataTypeConvertorPath)];
                set_param(genDataTypeConvertorPath,'Position',blkPosition);
                add_line(targetBlkPath,['In1/1'],[hC.Name,'_DataTypeConvertor','/1'],'autorouting','on');
                start_position=start_position+move_right/3;
                blkpath=[targetBlkPath,'/',hC.Name];
                blkSize=blockSize(originalBlkPath);
                add_block(originalBlkPath,blkpath);
                set_param(blkpath,'OutDataTypeStr',dt,...
                'AccumDataTypeStr',sldt_accum,...
                'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
                'SaturateOnIntegerOverflow',...
                get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));
                blkPosition=[start_position,start_position+blockSize([targetBlkPath,'/',hC.Name])];
                set_param([targetBlkPath,'/',hC.Name],'Position',blkPosition);
                add_line(targetBlkPath,[hC.Name,'_DataTypeConvertor','/1'],[hC.Name,'/1'],'autorouting','on');
                outputBlk=hC.Name;
                outputBlkPosition=start_position+[blkSize(1),0];
            else
                blkpath=[targetBlkPath,'/',hC.Name];
                blkSize=blockSize(originalBlkPath);
                add_block(originalBlkPath,blkpath);
                set_param(blkpath,'OutDataTypeStr',dt,...
                'AccumDataTypeStr',sldt_accum,...
                'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
                'SaturateOnIntegerOverflow',...
                get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));
                add_line(targetBlkPath,['In1/1'],[hC.Name,'/1'],'autorouting','on');
                outputBlk=hC.Name;
                outputBlkPosition=start_position+[blkSize(1),0];
            end
        else


            genDataTypeConvertorPath=[targetBlkPath,'/',hC.Name,'_DataTypeConvertor'];

            add_block('built-in/DataTypeConversion',genDataTypeConvertorPath,...
            'OutDataTypeStr',dt_accum,...
            'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
            'SaturateOnIntegerOverflow',...
            get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));
            blkPosition=[start_position,start_position+blockSize(genDataTypeConvertorPath)];
            set_param(genDataTypeConvertorPath,'Position',blkPosition);
            add_line(targetBlkPath,['In1/1'],[hC.Name,'_DataTypeConvertor','/1'],'autorouting','on');
            start_position=start_position+move_right;

            for cloop=1:length(decompose_vector)
                genSelectorPath=[targetBlkPath,'/',hC.Name,'_selector',num2str(cloop)];
                add_block('built-in/Selector',genSelectorPath);
                set_param(genSelectorPath,'inputtype','Vector');
                set_param(genSelectorPath,'inputPortWidth',num2str(config.invectsize));
                set_param(genSelectorPath,'elements',vector2str(invect_cell{cloop}));
                localMoveDown=move_down*(cloop-1);
                blkPosition=[start_position+localMoveDown,start_position+localMoveDown+blockSize(genSelectorPath)];
                set_param(genSelectorPath,'Position',blkPosition);
                add_line(targetBlkPath,[hC.Name,'_DataTypeConvertor','/1'],[hC.Name,'_selector',num2str(cloop),'/1'],'autorouting','on');

            end
            start_position=start_position+...
            (length(decompose_vector)+1)*move_right;

            blkPosition=[start_position,start_position+blockSize([targetBlkPath,'/Out1'])];
            set_param([targetBlkPath,'/Out1'],'Position',blkPosition);

            start_position=start_position-move_right;

            for cloop=1:length(decompose_vector)


                if config.decomposition==0
                    sufix='';
                else
                    sufix=['_',num2str(decompose_vector(cloop))];
                end
                if cloop~=length(decompose_vector)

                    blkpath=[targetBlkPath,'/',hC.Name,'_Mux',sufix];
                    add_block('built-in/Mux',blkpath);
                    set_param(blkpath,'Inputs','2');
                    set_param(blkpath,'displayOption','bar');
                    blkPosition=[start_position-[70,0],start_position-[70,0]+blockSize(blkpath)];
                    set_param(blkpath,'Position',blkPosition);

                    add_line(targetBlkPath,[hC.Name,'_selector',num2str(cloop),'/1'],[hC.Name,'_Mux',sufix,'/1'],'autorouting','on');


                    blkpath=[targetBlkPath,'/',hC.Name,sufix];
                    blkSize=blockSize(originalBlkPath);
                    add_block(originalBlkPath,blkpath);
                    blkPosition=[start_position,start_position+blkSize];
                    if cloop==1
                        set_param(blkpath,'Position',blkPosition,...
                        'OutDataTypeStr',dt,...
                        'AccumDataTypeStr',sldt_accum,...
                        'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
                        'SaturateOnIntegerOverflow',...
                        get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));
                    else
                        set_param(blkpath,'Position',blkPosition,...
                        'OutDataTypeStr',dt_accum,...
                        'AccumDataTypeStr',sldt_accum,...
                        'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
                        'SaturateOnIntegerOverflow',...
                        get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));
                    end


                    add_line(targetBlkPath,[hC.Name,'_Mux',sufix,'/1'],[hC.Name,sufix,'/1'],'autorouting','on');
                    if cloop==1
                        outputBlkPosition=start_position+[blkSize(1),0];
                    end
                else

                    blkpath=[targetBlkPath,'/',hC.Name,sufix];
                    add_block(originalBlkPath,blkpath);
                    blkPosition=[start_position,start_position+blockSize(originalBlkPath)];
                    set_param(blkpath,'Position',blkPosition,...
                    'OutDataTypeStr',dt_accum,...
                    'AccumDataTypeStr',sldt_accum,...
                    'RndMeth',get_param(hC.SimulinkHandle,'RndMeth'),...
                    'SaturateOnIntegerOverflow',...
                    get_param(hC.SimulinkHandle,'SaturateOnIntegerOverflow'));


                    add_line(targetBlkPath,[hC.Name,'_selector',num2str(cloop),'/1'],[hC.Name,sufix,'/1'],'autorouting','on');

                end
                if cloop==1
                    outputBlk=[hC.Name,sufix];
                    preSufix=sufix;
                else
                    add_line(targetBlkPath,[hC.Name,sufix,'/1'],[hC.Name,'_Mux',preSufix,'/2'],'autorouting','on');
                    preSufix=sufix;
                end
                start_position=start_position-move_right+move_down;
            end
        end


        function str=vector2str(Vec)
            str=['['];
            for j=1:length(Vec)
                str=[str,' ',num2str(Vec(j))];
            end
            str=[str,']'];


            function blkSize=blockSize(Block)
                Position=get_param(Block,'Position');
                blkSize=[Position(3)-Position(1),Position(4)-Position(2)];


                function[dt,sldt]=localGetModeOutDataTypeScaling(inType,col)


                    [insltype,sldtprops]=getslsignaltype(inType);
                    if sldtprops.isnative
                        sldt=insltype.native;
                    else
                        sldt=insltype.viadialog;
                    end
                    [insize,inbp,insigned]=hdlwordsize(insltype.native);
                    sizes=[insize,inbp,insigned];

                    if sizes(1)==0
                        dt='double';
                    else
                        if nargin>1
                            sizes(1)=sizes(1)*2*col;
                            sizes(2)=sizes(2)*2;
                        end

                        wordLength=sizes(1);
                        fractionLength=sizes(2);
                        if sizes(3)
                            sign=1;
                        else
                            sign=0;
                        end

                        dt=sprintf('fixdt(%d,%d,%d)',sign,wordLength,fractionLength);
                    end





