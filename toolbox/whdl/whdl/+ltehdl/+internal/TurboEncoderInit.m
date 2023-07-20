function f1f2_param=TurboEncoderInit(blk)




%#codegen

    if coder.target('MATLAB')
        if~(builtin('license','checkout','LTE_HDL_Toolbox'))
            error(message('whdl:whdl:NoLicenseAvailable'));
        end
    else
        coder.license('checkout','LTE_HDL_Toolbox');
    end
    registersamplecontrolbus;
    Simulink.suppressDiagnostic([blk,'/TurboEncoderController/ReadAddr Generator1'],'SimulinkFixedPoint:util:Overflowoccurred');

    blksrc=get_param(blk,'BlockSizeSource');
    entail=get_param(blk,'EnableTailBits');

    K=[40:8:512,528:16:1024,1056:32:2048,2112:64:6144];

    f1f2_param=zeros(1,256);
    for k=1:length(K)
        [f1,f2]=getltef1f2(K(k));
        f1f2_param(k+1)=f1*2^10+f2;
    end

    switch blksrc
    case 'Property'
        if strcmp(get_param([blk,'/FrmLen'],'BlockType'),'Inport')
            replace_block([blk,'/FrmLen'],'Inport','Constant','noprompt');
            if strcmp(entail,'on')
                set_param(blk,'MaskDisplay','disp(''LTE Turbo Encoder''); port_label(''output'',1,''data''); port_label(''output'',2,''ctrl''); port_label(''input'',1,''data''); port_label(''input'',2,''ctrl''); port_label(''output'',3,''tail1''); port_label(''output'',4,''tail2'');');
            else
                set_param(blk,'MaskDisplay','disp(''LTE Turbo Encoder''); port_label(''output'',1,''data''); port_label(''output'',2,''ctrl''); port_label(''input'',1,''data''); port_label(''input'',2,''ctrl'');');
            end
        end
        frmlen=get_param(blk,'FrmLen');
        set_param([blk,'/FrmLen'],'OutDataTypeStr','fixdt(0,13,0)','Value',frmlen,'SampleTime','-1');
        [num,status]=str2num(frmlen);

        if status==true




            coder.internal.errorIf(~ismember(num,K),'whdl:TurboCode:InvalidLTEBlockSize',num);
        end

    case 'Input port'

        if strcmp(get_param([blk,'/FrmLen'],'BlockType'),'Inport')

        else
            replace_block([blk,'/FrmLen'],'Constant','Inport','noprompt');
        end
        if strcmp(entail,'on')
            set_param(blk,'MaskDisplay','disp(''LTE Turbo Encoder''); port_label(''output'',1,''data''); port_label(''output'',2,''ctrl''); port_label(''input'',1,''data''); port_label(''input'',2,''ctrl''); port_label(''input'',3,''blockSize''); port_label(''output'',3,''tail1''); port_label(''output'',4,''tail2'');');
        else
            set_param(blk,'MaskDisplay','disp(''LTE Turbo Encoder''); port_label(''output'',1,''data''); port_label(''output'',2,''ctrl''); port_label(''input'',1,''data''); port_label(''input'',2,''ctrl''); port_label(''input'',3,''blockSize'');');
        end

    end

    switch entail
    case 'on'
        if strcmp(get_param([blk,'/tail1'],'BlockType'),'Terminator')&&strcmp(get_param([blk,'/tail2'],'BlockType'),'Terminator')
            replace_block([blk,'/tail1'],'Terminator','Outport','noprompt');
            replace_block([blk,'/tail2'],'Terminator','Outport','noprompt');
            if strcmp(blksrc,'Property')
                set_param(blk,'MaskDisplay','disp(''LTE Turbo Encoder''); port_label(''output'',1,''data''); port_label(''output'',2,''ctrl''); port_label(''input'',1,''data''); port_label(''input'',2,''ctrl''); port_label(''output'',3,''tail1''); port_label(''output'',4,''tail2'');');
            else
                set_param(blk,'MaskDisplay','disp(''LTE Turbo Encoder''); port_label(''output'',1,''data''); port_label(''output'',2,''ctrl''); port_label(''input'',1,''data''); port_label(''input'',2,''ctrl''); port_label(''input'',3,''blockSize''); port_label(''output'',3,''tail1''); port_label(''output'',4,''tail2'');');
            end
        end
    otherwise
        if strcmp(get_param([blk,'/tail1'],'BlockType'),'Outport')&&strcmp(get_param([blk,'/tail2'],'BlockType'),'Outport')
            replace_block([blk,'/tail1'],'Outport','Terminator','noprompt');
            replace_block([blk,'/tail2'],'Outport','Terminator','noprompt');
            if strcmp(blksrc,'Property')
                set_param(blk,'MaskDisplay','disp(''LTE Turbo Encoder''); port_label(''output'',1,''data''); port_label(''output'',2,''ctrl''); port_label(''input'',1,''data''); port_label(''input'',2,''ctrl'');');
            else
                set_param(blk,'MaskDisplay','disp(''LTE Turbo Encoder''); port_label(''output'',1,''data''); port_label(''output'',2,''ctrl''); port_label(''input'',1,''data''); port_label(''input'',2,''ctrl''); port_label(''input'',3,''blockSize'');');
            end
        end
    end

end
