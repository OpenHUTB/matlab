function OLTCtransformerCback(block,callbackparameter);






    tempMaskVis=get_param(block,'MaskVisibilities');
    switch callbackparameter
    case 1
        if strcmp(get_param(block,'ShowParam'),'Transformer parameters')
            tempMaskVis{2}='on';tempMaskVis{3}='on';tempMaskVis{4}='on';tempMaskVis{5}='on';
            tempMaskVis{6}='on';tempMaskVis{7}='on';tempMaskVis{8}='on';tempMaskVis{17}='on';
            tempMaskVis{9}='off';tempMaskVis{10}='off';tempMaskVis{11}='off';tempMaskVis{12}='off';
            tempMaskVis{13}='off';tempMaskVis{14}='off';tempMaskVis{15}='off';tempMaskVis{16}='off';
            tempMaskVis{16}='off';
        else
            tempMaskVis{2}='off';tempMaskVis{3}='off';tempMaskVis{4}='off';tempMaskVis{5}='off';
            tempMaskVis{6}='off';tempMaskVis{7}='off';tempMaskVis{8}='off';tempMaskVis{17}='off';
            tempMaskVis{9}='on';tempMaskVis{10}='on';tempMaskVis{11}='on';tempMaskVis{12}='on';
            tempMaskVis{13}='on';tempMaskVis{14}='on';tempMaskVis{17}='off';
            if strcmp(get_param(gcb,'ExternalControl'),'off')
                tempMaskVis{15}='on';
                if strcmp(get_param(gcb,'RegulatorOn'),'on')
                    tempMaskVis{16}='on';
                else
                    tempMaskVis{16}='off';
                end
            else
                tempMaskVis{15}='off';
                tempMaskVis{16}='off';
            end
        end
    case 2
        Inport_Vm_On=strcmp('Inport',get_param([gcb,'/Vm (pu)'],'BlockType'));
        if strcmp(get_param(gcb,'ExternalControl'),'on')&Inport_Vm_On


            tempMaskVis{15}='off';
            tempMaskVis{16}='off';
            replace_block(gcb,'followlinks','on','Name','Vm (pu)','Constant','noprompt');
            replace_block(gcb,'followlinks','on','Name','Up','Inport','noprompt');
            replace_block(gcb,'followlinks','on','Name','Down','Inport','noprompt');
            set_param([gcb,'/ExternalControl'],'Value','1');
        elseif strcmp(get_param(gcb,'ExternalControl'),'off')&~Inport_Vm_On
            tempMaskVis{15}='on';
            tempMaskVis{16}='on';
            replace_block(gcb,'followlinks','on','Name','Vm (pu)','Inport','noprompt');
            replace_block(gcb,'followlinks','on','Name','Up','Constant','noprompt');
            replace_block(gcb,'followlinks','on','Name','Down','Constant','noprompt');
            set_param([gcb,'/ExternalControl'],'Value','0');
        end
    case 3
        if strcmp(get_param(gcb,'RegulatorOn'),'on')&strcmp(get_param(gcb,'ExternalControl'),'off')
            tempMaskVis{16}='on';
        else
            tempMaskVis{16}='off';
        end
    end
    set_param(gcb,'MaskVisibilities',tempMaskVis);