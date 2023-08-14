function generateSLBlock(this,hC,targetBlkPath)


    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        error(message('hdlcoder:validate:invalidblockpath',sprintf('%e',hC.SimulinkHandle)));
    end

    targetBlkPath=this.addSLBlock(hC,'built-in/Subsystem',targetBlkPath);
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
    if strcmpi(method,'on')
        pos_horz=init_horz;
        pos_vert=init_vert+dist_vert;
        block_path=[targetBlkPath,'/data_in'];
        add_block('built-in/Inport',block_path);
        set_param(block_path,...
        'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz;
        pos_vert=init_vert+2*dist_vert;
        block_path=[targetBlkPath,'/Enable'];
        add_block('built-in/Inport',block_path);
        set_param(block_path,...
        'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+dist_horz;
        pos_vert=init_vert+dist_vert;
        block_path=[targetBlkPath,'/switch1'];
        add_block('built-in/Switch',block_path);
        set_param(block_path,...
        'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+2*dist_vert+size_vert]);

        pos_horz=init_horz+2*dist_horz;
        pos_vert=init_vert;
        block_path=[targetBlkPath,'/Initial_Condition'];
        add_block('built-in/Constant',block_path);
        set_param(block_path,'Value',cval);
        set_param(block_path,'OutDataTypeStr','Inherit: Inherit via back propagation');
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+2*dist_horz;
        pos_vert=init_vert+dist_vert;
        block_path=[targetBlkPath,'/Reset'];
        add_block('built-in/Inport',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+3*dist_horz;
        pos_vert=init_vert;
        block_path=[targetBlkPath,'/switch2'];
        add_block('built-in/switch',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+2*dist_vert+size_vert]);

        pos_horz=init_horz+4*dist_horz;
        pos_vert=init_vert+dist_vert;
        block_path=[targetBlkPath,'/Unit_Delay'];
        add_block('built-in/UnitDelay',block_path);
        set_param(block_path,'vinit',cval);
        set_param(block_path,'SampleTime','-1');
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+5*dist_horz;
        pos_vert=init_vert+dist_vert;
        block_path=[targetBlkPath,'/data_out'];
        add_block('built-in/Outport',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        add_line(targetBlkPath,'Initial_Condition/1','switch2/1','autorouting','on');
        add_line(targetBlkPath,'Reset/1','switch2/2','autorouting','on');
        add_line(targetBlkPath,'switch1/1','switch2/3','autorouting','on');
        add_line(targetBlkPath,'switch2/1','Unit_Delay/1','autorouting','on');
        add_line(targetBlkPath,'data_in/1','switch1/1','autorouting','on');
        add_line(targetBlkPath,'Enable/1','switch1/2','autorouting','on');
        add_line(targetBlkPath,'Unit_Delay/1','switch1/3','autorouting','on');
        add_line(targetBlkPath,'Unit_Delay/1','data_out/1','autorouting','on');
    else
        pos_horz=init_horz;pos_vert=init_vert+2*dist_vert;
        block_path=[targetBlkPath,'/data_in'];
        add_block('built-in/Inport',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz;
        pos_vert=init_vert+3*dist_vert;
        block_path=[targetBlkPath,'/Enb'];
        add_block('built-in/Inport',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+dist_horz;
        pos_vert=init_vert+2*dist_vert;
        block_path=[targetBlkPath,'/switch0'];
        add_block('built-in/Switch',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+2*dist_vert+size_vert]);

        pos_horz=init_horz+2*dist_horz;
        pos_vert=init_vert+2*dist_vert;
        block_path=[targetBlkPath,'/Initial_Condition'];
        add_block('built-in/Constant',block_path);
        set_param(block_path,'Value',cval);
        set_param(block_path,'OutDataTypeStr','Inherit: Inherit via back propagation');
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+2*dist_horz;
        pos_vert=init_vert+3*dist_vert;
        block_path=[targetBlkPath,'/Reset'];
        add_block('built-in/Inport',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+3*dist_horz;
        pos_vert=init_vert+2*dist_vert;
        block_path=[targetBlkPath,'/switch1'];
        add_block('built-in/Switch',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+2*dist_vert+size_vert]);

        pos_horz=init_horz+4*dist_horz;
        pos_vert=init_vert+2*dist_vert;
        block_path=[targetBlkPath,'/Const_Zero'];
        add_block('built-in/Constant',block_path);
        set_param(block_path,'Value','0');
        set_param(block_path,'OutDataTypeStr','boolean');
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+5*dist_horz;
        pos_vert=init_vert+2*dist_vert;
        block_path=[targetBlkPath,'/delay_up'];
        add_block('built-in/UnitDelay',block_path);
        set_param(block_path,'X0','1');
        set_param(block_path,'SampleTime','-1');
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+5*dist_horz;
        pos_vert=init_vert+3*dist_vert;
        block_path=[targetBlkPath,'/delay_down'];
        add_block('built-in/UnitDelay',block_path);
        set_param(block_path,'SampleTime','-1');
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        pos_horz=init_horz+6*dist_horz;
        pos_vert=init_vert+dist_vert;
        block_path=[targetBlkPath,'/OR'];
        add_block('built-in/Logic',block_path);
        set_param(block_path,'Operator','OR');
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+dist_vert+size_vert]);

        pos_horz=init_horz+7*dist_horz;
        pos_vert=init_vert;
        block_path=[targetBlkPath,'/switch2'];
        add_block('built-in/Switch',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+2*dist_vert+size_vert]);

        pos_horz=init_horz+8*dist_horz;
        pos_vert=init_vert+dist_vert;
        block_path=[targetBlkPath,'/data_out'];
        add_block('built-in/Outport',block_path);
        set_param(block_path,'Position',[pos_horz,pos_vert,pos_horz+size_horz,pos_vert+size_vert]);

        add_line(targetBlkPath,'data_in/1','switch0/1','autorouting','on');
        add_line(targetBlkPath,'Enb/1','switch0/2','autorouting','on');
        add_line(targetBlkPath,'switch2/1','switch0/3','autorouting','on');
        add_line(targetBlkPath,'Initial_Condition/1','switch1/1','autorouting','on');
        add_line(targetBlkPath,'Reset/1','switch1/2','autorouting','on');
        add_line(targetBlkPath,'switch0/1','switch1/3','autorouting','on');
        add_line(targetBlkPath,'Const_Zero/1','delay_up/1','autorouting','on');
        add_line(targetBlkPath,'switch1/1','delay_down/1','autorouting','on');
        add_line(targetBlkPath,'Reset/1','OR/1','autorouting','on');
        add_line(targetBlkPath,'delay_up/1','OR/2','autorouting','on');
        add_line(targetBlkPath,'Initial_Condition/1','switch2/1','autorouting','on');
        add_line(targetBlkPath,'OR/1','switch2/2','autorouting','on');
        add_line(targetBlkPath,'delay_down/1','switch2/3','autorouting','on');
        add_line(targetBlkPath,'switch2/1','data_out/1','autorouting','on');
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


