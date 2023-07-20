function generateSLBlock(this,hC,targetBlkPath)


    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        error(message('hdlcoder:validate:invalidblockpath',sprintf('%e',hC.SimulinkHandle)));
    end

    targetBlkPath=addSLBlock(this,hC,'built-in/Subsystem',targetBlkPath);
    [turnhilitingon,color]=getHiliteInfo;
    set_param(targetBlkPath,'BackgroundColor',color);
    if turnhilitingon
        hiliteBlkAncestors(targetBlkPath,color);
    end

    cval=get_param(originalBlkPath,'vinit');

    init_horz=50;init_vert=50;
    dist_horz=100;dist_vert=100;
    size_horz=30;size_vert=30;

    method=this.getImplParams('softreset');

    if(strcmpi(method,'on'))
        pos_horz=init_horz;pos_vert=init_vert;
        block_name='Initial_Condition';
        add_block('built-in/Constant',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Value',cval);
        set_param([targetBlkPath,'/',block_name],'OutDataTypeStr','Inherit: Inherit via back propagation');
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_vert=init_vert+2*dist_vert;
        block_name='data_in';
        add_block('built-in/Inport',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_vert=init_vert+dist_vert;
        block_name='Reset';
        add_block('built-in/Inport',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=pos_horz+dist_horz;
        pos_vert=init_vert;
        block_name='switch';
        add_block('built-in/Switch',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+2*dist_vert+size_vert]);

        pos_horz=pos_horz+dist_horz;
        block_name='delay';
        add_block('built-in/UnitDelay',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'X0',cval);
        set_param([targetBlkPath,'/',block_name],'SampleTime','-1');
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+2*dist_vert+size_vert]);

        pos_horz=pos_horz+dist_horz;
        pos_vert=init_vert+dist_vert;
        block_name='data_out';
        add_block('built-in/Outport',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        add_line(targetBlkPath,'Initial_Condition/1','switch/1');
        add_line(targetBlkPath,'Reset/1','switch/2');
        add_line(targetBlkPath,'data_in/1','switch/3');
        add_line(targetBlkPath,'switch/1','delay/1');
        add_line(targetBlkPath,'delay/1','data_out/1');
    else
        pos_horz=init_horz;pos_vert=init_vert+2*dist_vert;
        block_name='Initial_Condition';
        add_block('built-in/Constant',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Value',cval);
        set_param([targetBlkPath,'/',block_name],'OutDataTypeStr','Inherit: Inherit via back propagation');
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz;pos_vert=init_vert+4*dist_vert;
        block_name='data_in';
        add_block('built-in/Inport',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz;pos_vert=init_vert+3*dist_vert;
        block_name='Reset';
        add_block('built-in/Inport',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+dist_horz;pos_vert=init_vert+2*dist_vert;
        block_name='switch1';
        add_block('built-in/Switch',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+2*dist_vert+size_vert]);

        pos_horz=init_horz+2*dist_horz;pos_vert=init_vert+2*dist_vert;
        block_name='Const_Zero';
        add_block('built-in/Constant',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Value','0');
        set_param([targetBlkPath,'/',block_name],'OutDataTypeStr','boolean');
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+3*dist_horz;pos_vert=init_vert+2*dist_vert;
        block_name='delay_up';
        add_block('built-in/UnitDelay',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'X0','1');
        set_param([targetBlkPath,'/',block_name],'SampleTime','-1');
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+3*dist_horz;pos_vert=init_vert+3*dist_vert;
        block_name='delay_down';
        add_block('built-in/UnitDelay',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'SampleTime','-1');
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+4*dist_horz;pos_vert=init_vert+dist_vert;
        block_name='OR';
        add_block('built-in/Logic',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Operator','OR');
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+dist_vert+size_vert]);

        pos_horz=init_horz+5*dist_horz;pos_vert=init_vert;
        block_name='switch2';
        add_block('built-in/Switch',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+2*dist_vert+size_vert]);

        pos_horz=init_horz+6*dist_horz;pos_vert=init_vert+dist_vert;
        block_name='data_out';
        add_block('built-in/Outport',[targetBlkPath,'/',block_name]);
        set_param([targetBlkPath,'/',block_name],'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        add_line(targetBlkPath,'Initial_Condition/1','switch1/1');
        add_line(targetBlkPath,'Reset/1','switch1/2');
        add_line(targetBlkPath,'data_in/1','switch1/3');
        add_line(targetBlkPath,'Const_Zero/1','delay_up/1');
        add_line(targetBlkPath,'switch1/1','delay_down/1');
        add_line(targetBlkPath,'Reset/1','OR/1');
        add_line(targetBlkPath,'delay_up/1','OR/2');
        add_line(targetBlkPath,'Initial_Condition/1','switch2/1');
        add_line(targetBlkPath,'OR/1','switch2/2');
        add_line(targetBlkPath,'delay_down/1','switch2/3');
        add_line(targetBlkPath,'switch2/1','data_out/1');
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
    color=hdlgetparameter('hilitecolor');
    turnhilitingon=hdlgetparameter('hiliteancestors');
end


