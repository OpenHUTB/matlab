function[firstCommand,firstLabel]=splitRefs(multiRef)



    command=multiRef.command;
    label=multiRef.label;

    prefix=strfind(label,' links: ');
    if isempty(prefix)
        firstCommand=command;
        firstLabel=label;
        return;
    else
        allLabels=label(prefix+length(' links: '):end);
        labels=splitLabels(allLabels);
    end

    [cmd,args]=rmiref.SLReference.parseCommand(command);
    commands=splitCommands({},cmd,args{1},args(2:end));

    if length(labels)==length(commands)
        firstCommand=commands{1};
        firstLabel=labels{1};
        spreadRefs(multiRef,commands,labels);
    else
        error(message('Slvnv:reqmgt:splitRefs:MismatchedTargetNumber',multiRef.moduleName));
    end
end

function labels=splitLabels(listOfLabels)
    mdlName=strtok(listOfLabels,'/');
    allMdlNames=strfind(listOfLabels,[mdlName,'/']);
    labels=cell(size(allMdlNames));
    for i=1:length(labels)
        next=i+1;
        if next<=length(labels)
            label=strtrim(listOfLabels(allMdlNames(i):allMdlNames(next)-3));
        else
            label=strtrim(listOfLabels(allMdlNames(i):end));
        end
        if label(end)==','
            label=label(1:end-1);
        end
        labels{i}=label;
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

function spreadRefs(multiRef,commands,labels)

    moduleId=multiRef.docname;
    objectId=multiRef.itemname;
    rmidoors.setObjAttribute(moduleId,objectId,'Object Text',labels{1});
    rmidoors.setObjAttribute(moduleId,objectId,'DmiSlNavCmd',commands{1});

    iconPath=rmiref.SLReference.fullIconPathName('normal');
    parentId=rmidoors.getObjAttribute(moduleId,objectId,'parentid');
    for i=2:length(labels)
        myLabel=['[Simulink reference: ',labels{i},']'];
        rmidoors.addLinkObj(moduleId,parentId,iconPath,myLabel,commands{i});
    end
end


