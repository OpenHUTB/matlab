function[NDLRB,cyclicPrefixType,windowCoeffNDLRB,windowCoeffNDLRB_inv,roundMethod]=OFDMModulatorInit()





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


    ndlrb=[6,15,25,50,75,100];
    minCPValues=[9,18,36,72,144,144;32,64,128,256,512,512];


    blockm1=[gcb,'/IFFT/IFFT HDL Optimized'];
    if strcmp(get_param(gcb,'FFTScaling'),'off')
        set_param(blockm1,'Normalize','off');
    else
        set_param(blockm1,'Normalize','on');
    end
    clear blockm1;


    blockm2=[gcb,'/IFFT/IFFT HDL Optimized'];
    roundMethod=get_param(gcb,'RoundingMethod');
    set_param(blockm2,'RoundingMethod',roundMethod);
    clear blockm2;



    blockm3=[gcb,'/IFFT/IFFT HDL Optimized'];
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
            blk0=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','reset');
            set_param([blk0{1}],'BackgroundColor','lightblue');
        end
        blkpath=find_system([gcb,'/IFFT'],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name','Terminator');
        if strcmp(get_param(blkpath,'BlockType'),'Terminator')
            delete_block(blkpath);
            delete_line(find_system([gcb,'/IFFT'],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','Type','line','Connected','off'));
            add_line([gcb,'/IFFT'],'Data Type Conversion/1','IFFT HDL Optimized/3');
        end
    else
        if strcmp(get_param([blk0{1}],'BlockType'),'Inport')
            replace_block([blk0{1}],'Inport','Constant','noprompt');
            set_param([blk0{1}],'Value','0','SampleTime','-1','OutDataTypeStr','boolean');
        end


        blkpath=find_system([gcb,'/IFFT'],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name','Terminator');
        if isempty(blkpath)
            delete_line(find_system([gcb,'/IFFT'],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','Type','line','Connected','off'));
            add_block('built-in/Terminator',[gcb,'/IFFT/Terminator']);
            set_param([gcb,'/IFFT/Terminator'],'position',[295,180,325,210]);
            add_line([gcb,'/IFFT'],'Data Type Conversion/1','Terminator/1');
        end
    end




    blk=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','NDLRB');
    switch NDLRBsrc
    case 'Input port'
        if strcmp(get_param([blk{1}],'BlockType'),'Constant')
            replace_block([blk{1}],'Constant','Inport','noprompt');
            blk=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','NDLRB');
            set_param([blk{1}],'BackgroundColor','lightblue');
        end

    case 'Property'
        NDLRB=str2num(get_param(gcb,'NDLRB'));
        if strcmp(get_param([blk{1}],'BlockType'),'Inport')
            replace_block([blk{1}],'Inport','Constant','noprompt');
            set_param([blk{1}],'Value','NDLRB','SampleTime','-1','OutDataTypeStr','fixdt(0,8,0)');
        end
    end




    blk1=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','cyclicPrefixType');
    switch cpsrc(1)
    case 'I'
        if strcmp(get_param([blk1{1}],'BlockType'),'Constant')
            replace_block([blk1{1}],'Constant','Inport','noprompt');
            blk1=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','Name','cyclicPrefixType');
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


    windowing=get_param(gcb,'windowing');


    if strcmp(windowing,'on')
        winLen=(get_param(gcb,'winLen'));
        [winLen1,status]=str2num(winLen);
        if status==false&&ismember(get_param(gcb,'winLen'),evalin('base','who'))
            winLen1=evalin('base',get_param(gcb,'winLen'));
        end
        windowCoeffNDLRB=ones(8,64);
        windowCoeffNDLRB_inv=ones(8,64);
    else
        winLen=('[0,0,0,0,0,0]');
        [winLen1,status]=str2num(winLen);
        windowCoeffNDLRB=ones(8,64);
        windowCoeffNDLRB_inv=ones(8,64);
    end
    [row,col]=size(winLen1);



    if status
        validateattributes(winLen1,{'double'},{'vector','real'},'OFDMModulator','window length');



        if length(winLen1)~=6||~((row==6&&col==1)||(row==1&&col==6))
            coder.internal.error('whdl:OFDMModulator:InValidWinLenVecErr');
        end
        for ii=1:6
            if winLen1(ii)-floor(winLen1(ii))~=0
                coder.internal.error('whdl:OFDMModulator:InValidWinLenFracErr');
            end

        end
    end
    if length(winLen1)==6&&strcmp(windowing,'on')
        winLen1_up=abs(round([winLen1(1)*16,winLen1(2)*8,winLen1(3)*4,winLen1(4)*2...
        ,winLen1(5),winLen1(6)]));
        windowCoeffNDLRB=ones(8,max(winLen1_up));
        windowCoeffNDLRB_inv=ones(8,max(winLen1_up));
        if strcmp(cpsrc,'Property')&&strcmp(NDLRBsrc,'Property')
            if cyclicPrefixType
                for ii=1:6
                    if winLen1(ii)>minCPValues(2,ii)||winLen1(ii)<0
                        coder.internal.error('whdl:OFDMModulator:InValidWinLenErr',ndlrb(ii),minCPValues(2,ii),'Extended');
                    end
                end
            else
                for ii=1:6
                    if winLen1(ii)>minCPValues(1,ii)||winLen1(ii)<0
                        coder.internal.error('whdl:OFDMModulator:InValidWinLenErr',ndlrb(ii),minCPValues(1,ii),'Normal');
                    end
                end
            end
        end
        if strcmp(windowing,'on')
            for ii=1:6
                w=abs(round(winLen1(ii)));
                w1=abs(round(winLen1_up(ii)));
                window=0.5*(1-sin(pi*(w+1-2*(1:w))/(2*w)));
                windowup=fliplr(window);
                windowCoeffNDLRB(ii,1:w1)=fi(resample(window,w1,w),1,16,14);
                windowCoeffNDLRB_inv(ii,1:w1)=fi(resample(windowup,w1,w),1,16,14);
            end
        end
    end
    set_param([gcb,'/winLen'],'OutDataTypeStr','fixdt(1,16,2)','Value',winLen,'SampleTime','-1');
end
