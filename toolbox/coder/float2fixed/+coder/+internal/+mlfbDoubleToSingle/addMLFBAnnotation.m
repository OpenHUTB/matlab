function addMLFBAnnotation(varSubsys,mlfbName,singleMlfbName)



    varSubsys=getfullname(varSubsys);
    templateDir=fullfile(matlabroot,'toolbox','coder','float2fixed','+coder','+internal','+mlfbDoubleToSingle','artifacts');
    templateMdl=load_system(fullfile(templateDir,'MLFBAnnotationTemplate.slx'));
    cleanupCloseMdl=onCleanup(@()bdclose(templateMdl));

    try


        annotationTemplate=find_system(templateMdl,'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'type','annotation');
        annotationTemplate=get_param(annotationTemplate,'object');


        ann=find_system(varSubsys,'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'type','annotation');
        if numel(ann)~=1
            annotation=Simulink.Annotation([varSubsys,'/note']);
        else

            annotation=get_param(ann,'object');
        end

        annotation.Interpreter=annotationTemplate.Interpreter;
        annotation.FixedWidth=annotationTemplate.FixedWidth;
        annotation.FixedHeight=annotationTemplate.FixedHeight;
        annotation.position=annotationTemplate.position;

        msg=annotationTemplate.text;
        msg=strrep(msg,'MLFB_Annotation_Msg1',message('Coder:FXPCONV:MLFB_Annotation_Single_Msg1').getString());
        msg=strrep(msg,'MLFB_Annotation_Msg2',message('Coder:FXPCONV:MLFB_Annotation_Single_Msg2').getString());

        msg=strrep(msg,'MLFB_Annotation_Msg31',message('Coder:FXPCONV:MLFB_Annotation_Single_Msg31').getString());
        msg=strrep(msg,'MLFB_Annotation_Msg3',message('Coder:FXPCONV:MLFB_Annotation_Single_Msg3',formatBlockName(singleMlfbName)).getString());

        msg=strrep(msg,'MLFB_Annotation_Msg41',message('Coder:FXPCONV:MLFB_Annotation_Single_Msg41').getString());
        msg=strrep(msg,'MLFB_Annotation_Msg4',message('Coder:FXPCONV:MLFB_Annotation_Single_Msg4',formatBlockName(mlfbName)).getString());

        annotation.text=msg;
        setAnnotationPosition(varSubsys,annotation);
    catch
    end
end

function name=formatBlockName(name)
    name=sprintf('<span style=" font-family:''monospace''; font-size:14px; font-weight:600; color:#000000; background-color:#efefef;">%s</span>',name);
end

function layoutVariantSubsystem(varSubsys)
    try
        blockNames=get_param(varSubsys,'blocks');
        if isempty(blockNames)
            return;
        end

        blocks={};
        for ii=1:numel(blockNames)
            blk=sprintf('%s/%s',varSubsys,blockNames{ii});
            blocks{end+1}=blk;
        end

        inports={};
        variants={};
        outports={};

        for ii=1:numel(blocks)
            blk=blocks{ii};
            switch get_param(blk,'blocktype')
            case{'Inport'},inports{end+1}=blk;
            case{'Outport'},outports{end+1}=blk;
            otherwise,variants{end+1}=blk;
            end
        end


        b=getBounds(inports);
        x=b(1);
        setX(inports,x);


        b=getBounds(inports);
        x=b(3)+100;
        setX(variants,x);


        b=getBounds(variants);
        x=b(3)+100;
        setX(outports,x);
    catch
    end
end

function setAnnotationPosition(varSubsys,annotation)
    layoutVariantSubsystem(varSubsys);
    annotationPos=annotation.position;

    blockNames=get_param(varSubsys,'blocks');
    if isempty(blockNames)
        return;
    end

    blocks={};
    for ii=1:numel(blockNames)
        blk=sprintf('%s/%s',varSubsys,blockNames{ii});
        blocks{end+1}=blk;
    end

    firstBlockPos=get_param(blocks{1},'position');
    maxX=firstBlockPos(3);
    maxY=firstBlockPos(4);

    for ii=2:numel(blocks)
        blockPos=get_param(blocks{ii},'position');
        maxX=max(maxX,blockPos(3));
        maxY=max(maxY,blockPos(4));
    end

    PADDING=50;

    width=annotationPos(3)-annotationPos(1);
    height=annotationPos(4)-annotationPos(2);
    x=annotationPos(1);
    y=maxY+PADDING;

    annotation.position=[x,y,x+width,y+height];
end

function rect=getBounds(blocks)
    rect=[0,0,0,0];
    if numel(blocks)>=1
        rect=get_param(blocks{1},'position');
    end

    for ii=2:numel(blocks)
        r=get_param(blocks{ii},'position');
        rect=[min(rect(1:2),r(1:2)),max(rect(3:4),r(3:4))];
    end
end

function setX(blocks,x)
    for ii=1:numel(blocks)
        p=get_param(blocks{ii},'position');
        d=x-p(1);
        set_param(blocks{ii},'position',p+[d,0,d,0]);
    end
end



