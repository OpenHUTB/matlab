function[NDLRB,cyclicPrefixType]=OFDMDemodulatorInit()






%#codegen

    if coder.target('MATLAB')
        if~(builtin('license','checkout','LTE_HDL_Toolbox'))
            error(message('whdl:whdl:NoLicenseAvailable'));
        end
    else
        coder.license('checkout','LTE_HDL_Toolbox');
    end

    Simulink.suppressDiagnostic(gcb,'SimulinkFixedPoint:util:Overflowoccurred');
    Simulink.suppressDiagnostic(gcb,'SimulinkFixedPoint:util:fxpParameterPrecisionLoss');
    Simulink.suppressDiagnostic(gcb,'SimulinkFixedPoint:util:fxpParameterOverflow');

    NDLRBsrc=get_param(gcb,'NDLRB_source');
    cpsrc=get_param(gcb,'cp_src');


    NDLRB=6;
    cyclicPrefixType=false;


    cpval=get_param(gcb,'cpFraction');
    [cpval1,status]=str2num(cpval);
    if status==true
        if cpval1<0||cpval1>1
            coder.internal.error('whdl:OFDMDemodulator:InvalidCPFraction');
        end
    end

    set_param([gcb,'/cpFraction'],'OutDataTypeStr','fixdt(0,11,10)','Value',cpval,'SampleTime','-1');


    blockm1=[gcb,'/FFT/FFT HDL Optimized'];
    if strcmp(get_param(gcb,'FFTScaling'),'off')
        set_param(blockm1,'Normalize','off');
    else
        set_param(blockm1,'Normalize','on');
    end
    clear blockm1;


    blockm2=[gcb,'/FFT/FFT HDL Optimized'];
    roundMethod=get_param(gcb,'RoundingMethod');
    set_param(blockm2,'RoundingMethod',roundMethod);
    clear blockm2;


    blockm3=[gcb,'/FFT/FFT HDL Optimized'];
    if strcmp(get_param(gcb,'resetPort'),'off')
        set_param(blockm3,'ResetInputPort','off');
    else
        set_param(blockm3,'ResetInputPort','on');
    end
    clear blockm3;




    blk0=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','reset');
    resetPort=get_param(gcb,'resetPort');
    if strcmp(resetPort,'on')
        if strcmp(get_param([blk0{1}],'BlockType'),'Constant')
            replace_block([blk0{1}],'Constant','Inport','noprompt');
            set_param([blk0{1}],'BackgroundColor','lightblue');
        end
        blkpath=find_system([gcb,'/FFT'],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name','Terminator');
        if strcmp(get_param(blkpath,'BlockType'),'Terminator')
            delete_block(blkpath);
            delete_line(find_system([gcb,'/FFT'],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','Type','line','Connected','off'));
            add_line([gcb,'/FFT'],'Data Type Conversion/1','FFT HDL Optimized/3');
        end
    else
        if strcmp(get_param([blk0{1}],'BlockType'),'Inport')
            replace_block([blk0{1}],'Inport','Constant','noprompt');
            set_param([blk0{1}],'Value','0','SampleTime','-1','OutDataTypeStr','boolean');
        end


        blkpath=find_system([gcb,'/FFT'],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name','Terminator');
        if isempty(blkpath)
            delete_line(find_system([gcb,'/FFT'],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','Type','line','Connected','off'));
            add_block('built-in/Terminator',[gcb,'/FFT/Terminator']);
            set_param([gcb,'/FFT/Terminator'],'position',[85,280,105,300]);
            add_line([gcb,'/FFT'],'Data Type Conversion/1','Terminator/1');
        end
    end



    blk=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','NDLRB');
    switch NDLRBsrc
    case 'Input port'
        if strcmp(get_param([blk{1}],'BlockType'),'Constant')
            replace_block([blk{1}],'Constant','Inport','noprompt');
            set_param([blk{1}],'BackgroundColor','lightblue');
        end

    case 'Property'
        NDLRB=str2num(get_param(gcb,'NDLRB'));
        if strcmp(get_param([blk{1}],'BlockType'),'Inport')
            replace_block([blk{1}],'Inport','Constant','noprompt');
            set_param([blk{1}],'Value','NDLRB','SampleTime','-1','OutDataTypeStr','fixdt(0,16,0)');
        end
    end



    blk1=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','cyclicPrefixType');
    switch cpsrc(1)
    case 'I'
        if strcmp(get_param([blk1{1}],'BlockType'),'Constant')
            replace_block([blk1{1}],'Constant','Inport','noprompt');
            set_param([blk1{1}],'BackgroundColor','lightblue');
        end
    case 'P'
        vec2=(get_param(gcb,'cyclicPrefixType'));
        if strcmp(vec2,'Normal')
            cyclicPrefixType=false;
        else
            cyclicPrefixType=true;
        end
        if strcmp(get_param([blk1{1}],'BlockType'),'Inport')
            replace_block([blk1{1}],'Inport','Constant','noprompt');
            set_param([blk1{1}],'Value','cyclicPrefixType','SampleTime','-1','OutDataTypeStr','boolean');
        end
    end


    inputSampRate=get_param(gcb,'inSampleRate');

    if strcmp(inputSampRate,'Match input data sample rate to NDLRB')


        blkpath=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','Terminator');
        if sum(strcmp(blkpath,[gcb,'/Terminator']))==1

            replace_block([gcb,'/Terminator'],'Terminator','Outport','noprompt');
            set_param([gcb,'/Terminator'],'BackgroundColor','green','Name','ready');
        end
    elseif strcmp(inputSampRate,'Use maximum input data sample rate')


        blkpath=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','ready');
        if~isempty(blkpath)
            replace_block([gcb,'/ready'],'Outport','Terminator','noprompt');
            set_param([gcb,'/ready'],'Name','Terminator');
        end
    end



    n=3;
    if strcmp(NDLRBsrc(1),'I')
        set_param([blk{1}],'Port',num2str(n))
        n=n+1;
    end
    if strcmp(cpsrc(1),'I')
        set_param([blk1{1}],'Port',num2str(n))
        n=n+1;
    end
    if strcmp(resetPort,'on')
        set_param([blk0{1}],'Port',num2str(n))
    end
end
