function[firstCommand,firstLabel]=splitRefs(shapeObject)

    btnObj=shapeObject.OLEFormat.Object;
    command=btnObj.MLEvalString;
    label=btnObj.ToolTipString;

    prefix=strfind(label,' links: ');
    if isempty(prefix)
        firstCommand=command;
        firstLabel=label;
        return;
    else
        allLabels=label(prefix+length(' links: '):end);
        labels=splitLabels({},allLabels);
    end

    [cmd,args]=rmiref.SLReference.parseCommand(command);
    commands=splitCommands({},cmd,args{1},args(2:end));
    if length(labels)==length(commands)
        firstCommand=commands{1};
        firstLabel=labels{1};
        spreadRefs(shapeObject,commands,labels,true);
    else
        error(message('Slvnv:reqmgt:splitRefs:MismatchedTargetNumber',btnObj.Name));
    end
end

function labels=splitLabels(labels,remainder)
    [next,remainder]=strtok(remainder,',');
    labels{end+1}=next;
    if~isempty(remainder)
        labels=splitLabels(labels,remainder(3:end));
    end
end

function commands=splitCommands(commands,cmd,model,args)
    if isempty(args)
        return;
    elseif length(args)==1
        commands{end+1}=[cmd,'(''',model,''',''',args{1},''');'];
    elseif~ischar(args{2})
        commands{end+1}=[cmd,'(''',model,''',''',args{1},''',',args{2},');'];
        commands=splitCommands(commands,cmd,model,args(3:end));
    else
        nextArg=args{1};
        if nextArg(1)=='!'

            nextModel=nextArg(2:end);
        else

            commands{end+1}=[cmd,'(''',model,''',''',nextArg,''');'];
            nextModel=model;
        end
        nextArgs=args(2:end);
        commands=splitCommands(commands,cmd,nextModel,nextArgs);
    end
end

function spreadRefs(prevObj,commands,labels,replace)
    if replace
        oldBtn=prevObj.OLEFormat.Object;
        oldBtn.MLEvalString=commands{1};
        oldBtn.ToolTipString=labels{1};
        nextShape=prevObj;
    else
        progId=prevObj.OLEFormat.ProgID;
        hDoc=prevObj.Parent;
        nextShape=hDoc.InlineShapes.AddOLEControl(progId,prevObj.Range);
        nextShape.Height=15;
        nextShape.Width=15;
        newBtn=nextShape.OLEFormat.object;
        newBtn.ToolTipString=labels{1};
        newBtn.MLEvalString=commands{1};
    end
    if length(labels)>1
        spreadRefs(nextShape,commands(2:end),labels(2:end),false);
    end
end


