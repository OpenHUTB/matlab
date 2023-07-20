function newBlock=createEmptySubsystem(obj,sys,blockType,varargin)












    srcBlock='built-in/SubSystem';
    hasEnable=false;
    hasTrigger=false;
    hasIfAction=false;
    hasReset=false;
    switch numel(varargin)
    case 1



        ports=varargin{1};
        numInputs=ports(1);
        numOutputs=ports(2);
        numLConn=ports(6);
        numRConn=ports(7);
        if ports(3)~=0
            hasEnable=true;
        elseif ports(4)~=0
            hasTrigger=true;
        elseif ports(8)~=0
            hasIfAction=true;
        elseif ports(9)~=0
            hasReset=true;
        end
    case 2
        numInputs=varargin{1};
        numOutputs=varargin{2};
        numLConn=0;
        numRConn=0;
    otherwise
        DAStudio.error('Simulink:ExportPrevious:NumArgError','createEmptySubsystem');
    end
    blkname=obj.generateTempName;
    newBlock=[sys,'/',blkname];


    existing_handle=getSimulinkBlockHandle(newBlock);
    if existing_handle>=0
        delete_block(existing_handle);
    end
    add_block(srcBlock,newBlock);

    if obj.ver.isR2019aOrEarlier
        set_param(newBlock,'ContentPreviewEnabled','off');
    end

    offset=0;
    yTop=40;
    for i=1:numInputs
        yI=yTop+3+offset;
        hI=yI+14;

        yT=yTop+offset;
        hT=yT+20;
        str_i=num2str(i);

        inport=[newBlock,'/In',str_i];
        term=[newBlock,'/Terminator',str_i];

        add_block('built-in/Inport',inport);
        add_block('built-in/Terminator',term);
        set_param(inport,'Position',[35,yI,65,hI]);
        set_param(term,'Position',[100,yT,120,hT]);
        add_line(newBlock,['In',str_i,'/1'],['Terminator',str_i,'/1']);

        offset=offset+60;
    end

    for i=1:numLConn
        yO=yTop+3+offset;
        hO=yO+14;
        str_i=num2str(i);
        outport=[newBlock,'/LConn',str_i];
        add_block('built-in/PMIOPort',outport);
        set_param(outport,'Position',[250,yO,280,hO],...
        'Side','Left');


        offset=offset+60;
    end


    for i=1:numOutputs
        yO=yTop+3+offset;
        hO=yO+14;
        yG=yTop+offset;
        hG=yG+20;
        str_i=num2str(i);

        outport=[newBlock,'/Out',str_i];
        ground=[newBlock,'/Ground',str_i];

        add_block('built-in/Outport',outport);
        add_block('built-in/Ground',ground);
        set_param(outport,'Position',[250,yO,280,hO]);
        set_param(ground,'Position',[185,yG,215,hG]);
        add_line(newBlock,['Ground',str_i,'/1'],['Out',str_i,'/1']);

        offset=offset+60;
    end

    for i=1:numRConn
        yO=yTop+3+offset;
        hO=yO+14;
        str_i=num2str(i);
        outport=[newBlock,'/RConn',str_i];
        add_block('built-in/PMIOPort',outport);
        set_param(outport,'Position',[250,yO,280,hO],...
        'Side','Right');


        offset=offset+60;
    end


    if hasEnable
        portKind='EnablePort';
        portName='enable';
    elseif hasTrigger
        portKind='TriggerPort';
        portName='trigger';
    elseif hasIfAction
        portKind='ActionPort';
        portName='action';
    elseif hasReset
        portKind='ResetPort';
        portName='reset';
    else
        portKind='';
        portName='';
    end

    if~isempty(portKind)
        xLeft=138;
        yTop=5;
        portPosition=[xLeft,yTop,xLeft+30,yTop+30];
        p=[newBlock,'/',portName];
        add_block(['built-in/',portKind],p);
        set_param(p,'Position',portPosition);
    end

    if isempty(blockType)
        return;
    end

    MaskDescMsg=DAStudio.message('Simulink:ExportPrevious:ReplacedBlock',obj.targetVersion.release);
    if~obj.ver.isSLX
        MATLABencoding=get_param(0,'CharacterEncoding');
        SIMULINKencoding=get_param(obj.modelName,'savedcharacterencoding');
        if~strcmp(MATLABencoding,SIMULINKencoding)


            MaskDescMsg='This is a newly introduced block which was replaced with an empty Subsystem.';
        end
    end


    escapedBlockType=regexprep(blockType,'\s',' ');

    escapedBlockType=strrep(escapedBlockType,'''','''''');

    fmtStr=DAStudio.message('Simulink:ExportPrevious:ReplacedBlockMaskFormat');
    try
        set_param(newBlock,...
        'Description','Replaced Block',...
        'ShowPortLabels','on',...
        'BackgroundColor','yellow',...
        'Mask','on',...
        'MaskType','Replaced Block',...
        'MaskDescription',MaskDescMsg,...
        'MaskDisplay',['fprintf(''',fmtStr,'\n'',''',escapedBlockType,''')'],...
        'MaskIconFrame','on',...
        'MaskIconOpaque','on',...
        'MaskIconRotate','none',...
        'MaskIconUnits','Autoscale');
    catch e
        disp(e.identifier);
        disp(e.message);
        if isDebugMode(obj)
            addDebugInfo(obj,'errorinfo',e);
        end
    end

    if~ismember(blockType,obj.blockTypesNotified)
        w=warning('query','Simulink:ExportPrevious:UnsupportedBlocksReplaced');
        if strcmp(w.state,'on')

            Simulink.output.info(DAStudio.message('Simulink:ExportPrevious:ReplacedBlockTypeMessage',...
            strrep(blockType,newline,' '),obj.targetVersion.release));
        end
        obj.blockTypesNotified{end+1}=blockType;
    end



    obj.incrementReplacedBlockCount;


