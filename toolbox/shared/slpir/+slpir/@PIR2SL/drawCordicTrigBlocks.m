function drawCordicTrigBlocks(hC,originalBlkPath,newSlSubsystemName,fcn,iterNum,usePipelines,customLatency,latencyStrategy)










    if nargin<7
        customLatency=0;
    end

    if nargin<8
        latencyStrategy='MAX';
    end

    load_system('simulink');
    if contains(originalBlkPath,'hdlsllib')
        load_system('hdlsllib');
    end
    if strcmpi(fcn,'atan2')
        iterNum=iterNum+3;
        if(strcmpi(latencyStrategy,'MAX'))
            outputDelay=iterNum;
        elseif(strcmpi(latencyStrategy,'CUSTOM'))
            outputDelay=customLatency;
        else
            outputDelay=0;
        end
    else
        if(strcmpi(latencyStrategy,'MAX'))
            outputDelay=iterNum;
            inputDelay=1;
        elseif(strcmpi(latencyStrategy,'CUSTOM'))
            pipestages=iterNum+1;
            if(customLatency==0)
                outputDelay=0;
                inputDelay=0;
            elseif(customLatency==1||customLatency==2)
                if((pipestages-3)>0)
                    outputDelay=customLatency;
                    inputDelay=0;
                else
                    outputDelay=customLatency-1;
                    inputDelay=1;
                end
            else
                outputDelay=customLatency-1;
                inputDelay=1;
            end
        else
            outputDelay=0;
            inputDelay=0;
        end
    end
    inports=find_system(newSlSubsystemName,'SearchDepth',1,'BlockType','Inport');
    outports=find_system(newSlSubsystemName,'SearchDepth',1,'BlockType','Outport');
    inportNames=get_param(inports,'Name');
    outportNames=get_param(outports,'Name');

    xpos=220;
    ypos=65;


    newSlBlockName=add_block(originalBlkPath,[newSlSubsystemName,'/',hC.Name],...
    'Position',[xpos,ypos,xpos+30,ypos+40]);

    set_param(newSlBlockName,'Operator',fcn);
    if strcmpi(fcn,'atan2')
        set_param(newSlBlockName,'NumberOfIterations',int2str(iterNum-3));
    else
        set_param(newSlBlockName,'NumberOfIterations',int2str(iterNum));
    end

    if(usePipelines)
        if(strcmpi(fcn,'atan2'))
            add_line(newSlSubsystemName,[inportNames{1},'/1'],[hC.Name,'/1'],'autorouting','on');
            add_line(newSlSubsystemName,[inportNames{2},'/1'],[hC.Name,'/2'],'autorouting','on');
        else

            xpos=xpos-60;
            add_block('simulink/Discrete/Integer Delay',[newSlSubsystemName,'/Delay1'],...
            'Position',[xpos,ypos,xpos+30,ypos+40],...
            'NumDelays',num2str(inputDelay),...
            'samptime',num2str(-1));
            add_line(newSlSubsystemName,[inportNames{1},'/1'],'Delay1/1','autorouting','on');
            add_line(newSlSubsystemName,'Delay1/1',[hC.Name,'/1'],'autorouting','on');
        end

        xpos=xpos+120;
        add_block('simulink/Discrete/Integer Delay',[newSlSubsystemName,'/Delay2'],...
        'Position',[xpos,ypos,xpos+30,ypos+40],...
        'NumDelays',num2str(outputDelay),...
        'samptime',num2str(-1));
        add_line(newSlSubsystemName,[hC.Name,'/1'],'Delay2/1','autorouting','on');
        add_line(newSlSubsystemName,'Delay2/1',[outportNames{1},'/1'],'autorouting','on');

        if strcmpi(fcn,'sincos')

            add_block('simulink/Discrete/Integer Delay',[newSlSubsystemName,'/Delay3'],...
            'Position',[xpos,ypos+60,xpos+30,ypos+100],...
            'NumDelays',num2str(outputDelay),...
            'samptime',num2str(-1));
            add_line(newSlSubsystemName,[hC.Name,'/2'],'Delay3/1','autorouting','on');
            add_line(newSlSubsystemName,'Delay3/1',[outportNames{2},'/1'],'autorouting','on');
        end


    else

        add_line(newSlSubsystemName,[inportNames{1},'/1'],[hC.Name,'/1'],'autorouting','on');
        if strcmpi(fcn,'atan2')
            add_line(newSlSubsystemName,[inportNames{2},'/1'],[hC.Name,'/2'],'autorouting','on');
        end
        add_line(newSlSubsystemName,[hC.Name,'/1'],[outportNames{1},'/1'],'autorouting','on');
        if strcmpi(fcn,'sincos')
            add_line(newSlSubsystemName,[hC.Name,'/2'],[outportNames{2},'/1'],'autorouting','on');
        end
    end
end


