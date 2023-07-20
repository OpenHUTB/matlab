function[animation,dataShow]=setBlockAppearance(mode,...
    defaultAnnotaionStr,defaultColorSet,disableColorSet,...
    debugAnnotationStr,enableInTrueColorParams,...
    isInit,...
    blockEnable,lastBlockEnable,...
    EnableIn,lastEnableIn,...
    EnableOut,lastEnableOut,...
    data,lastData,...
    lastAnimation,lastDataShow)




    formatBlk=gcb;
    rootMdl=bdroot(formatBlk);
    isDirty=get_param(rootMdl,'Dirty');
    resetDirty=onCleanup(@()set_param(rootMdl,'Dirty',isDirty));

    colorParams={'ForegroundColor','BackgroundColor'};
    if nargin==1
        defaultAnnotaionStr='';
    end
    if nargin<=2
        defaultColorSet={};
    end
    if nargin<=3
        disableColorSet={};
    end

    if isempty(defaultColorSet)
        defaultColorSet={'black','white'};
    end
    if ischar(defaultColorSet)
        defaultColorSet={defaultColorSet};
    end
    if numel(defaultColorSet)==1
        defaultColorSet=[defaultColorSet,'white'];
    end

    if isempty(disableColorSet)
        disableColorSet={'gray','white'};
    end
    if ischar(disableColorSet)
        disableColorSet={disableColorSet};
    end
    if numel(disableColorSet)==1
        disableColorSet=[disableColorSet,'white'];
    end

    pouBlock=get_param(formatBlk,'Parent');
    if strcmpi(mode,'reset')

        resetColors(pouBlock,colorParams,defaultColorSet);
        setBlockAnnotation(pouBlock,[],defaultAnnotaionStr,'');
        return
    end

    animationParamValue=slplc.api.getModelParam(rootMdl,'PLCLadderLogicAnimation');
    dataShowParamValue=slplc.api.getModelParam(rootMdl,'PLCLadderLogicDataShow');

    animation=strcmpi(animationParamValue,'on');
    dataShow=strcmpi(dataShowParamValue,'on');

    energizedColor='green';
    if animation&&blockEnable
        if EnableIn~=lastEnableIn||isInit||~lastAnimation||~lastBlockEnable
            if EnableIn

                for paramCount=1:numel(enableInTrueColorParams)
                    set_param(pouBlock,enableInTrueColorParams{paramCount},energizedColor);
                end
            else

                for paramCount=1:numel(colorParams)
                    set_param(pouBlock,colorParams{paramCount},defaultColorSet{paramCount});
                end
            end
        end
        if EnableOut~=lastEnableOut||isInit||~lastAnimation||~lastBlockEnable
            if EnableOut
                plcBlockType=slplc.utils.getParam(pouBlock,'PLCBlockType');
                if strcmpi(plcBlockType,'jump')

                    setEnableOutLineHilite(pouBlock,'fade');
                else
                    setEnableOutLineHilite(pouBlock,energizedColor);
                end
            else
                setEnableOutLineHilite(pouBlock,'blackWhite');
            end
        end
    elseif~animation&&lastAnimation

        resetColors(pouBlock,colorParams,defaultColorSet);
    elseif animation&&~blockEnable&&lastBlockEnable

        resetColors(pouBlock,colorParams,disableColorSet);
    end

    if dataShow
        if~isequal(data,lastData)||isInit||~lastDataShow
            setBlockAnnotation(pouBlock,data,defaultAnnotaionStr,debugAnnotationStr);
        end
    elseif lastDataShow

        setBlockAnnotation(pouBlock,[],defaultAnnotaionStr,'');
    end
end


function resetColors(block,colorParams,defaultColorSet)
    for paramCount=1:numel(colorParams)
        set_param(block,colorParams{paramCount},defaultColorSet{paramCount});
    end
    setEnableOutLineHilite(block,'none');
end


function setEnableOutLineHilite(pouBlock,hiliteColor)
    portHandles=get_param(pouBlock,'PortHandles');
    if~isempty(portHandles.Outport)
        outports=portHandles.Outport;
        for portCount=1:numel(outports)
            outport=outports(portCount);
            lh=get_param(outport,'Line');
            if lh>0
                if portCount>1
                    hiliteColor='blackWhite';
                end
                set_param(lh,'HiliteAncestors',hiliteColor);
            end
        end
        set_param(get_param(pouBlock,'Parent'),'HiliteAncestors','none');
    end
end



function setBlockAnnotation(pouBlock,data,defaultAnnotaionStr,debugAnnotationStr)
    blockPOUType=slplc.utils.getParam(pouBlock,'PLCPOUType');
    if strcmpi(blockPOUType,'function block')
        defaultAnnotaionStr='%<PLCPOUName>: %<PLCOperandTag>';
    elseif strcmpi(blockPOUType,'subroutine')
        plcBlockType=slplc.utils.getParam(pouBlock,'PLCBlockType');
        if strcmpi(plcBlockType,'InstructionSystem')

            defaultAnnotaionStr='%<PLCPOUName>(%<PLCArgumentExpression>)';
        else

            defaultAnnotaionStr='JSR(%<PLCPOUName>)';
        end
    end

    if isempty(data)&&isempty(defaultAnnotaionStr)

        set_param(pouBlock,'AttributesFormatString','');
        return
    end

    if isempty(data)

        set_param(pouBlock,'AttributesFormatString',defaultAnnotaionStr);
        return
    end

    annotationHeader=[defaultAnnotaionStr,debugAnnotationStr];

    if islogical(data)

        if data
            dataStr='TRUE';
        else
            dataStr='FALSE';
        end
        if isempty(annotationHeader)
            annotationStr=dataStr;
        else
            annotationStr=[annotationHeader,dataStr];
        end
        set_param(pouBlock,'AttributesFormatString',annotationStr);
        return
    end


    dataStr=evalc('disp(data)');
    lines=strsplit(strtrim(dataStr),newline);
    lines=strtrim(lines);
    if numel(lines)>1
        dataStr=strjoin(lines,newline);
        dataStr=['\n',dataStr];
    else
        dataStr=lines{1};
    end

    if isempty(annotationHeader)
        annotationStr=dataStr;
    else
        annotationStr=[annotationHeader,dataStr];
    end
    set_param(pouBlock,'AttributesFormatString',annotationStr)
end
