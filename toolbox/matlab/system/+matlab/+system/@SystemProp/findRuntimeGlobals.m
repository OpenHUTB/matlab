function[globalList,glStepOutput,glUpdate,glList,glMethods]=findRuntimeGlobals(obj)



    rawClassName=class(obj);
    PkgClassCell=regexp(rawClassName,'\.+','split');
    className=PkgClassCell{end};

    fileNamePath=which(rawClassName);
    isMcoded=~(exist(fileNamePath,'file')~=2);
    assert(isMcoded);


    t=mtree(fileNamePath,'-file');
    anyGlobals=mtfind(t,'Kind','GLOBAL');
    if isempty(anyGlobals)
        globalList={};
        glStepOutput={};
        glUpdate={};
        glList={};
        glMethods={};
        return
    end



    if isa(obj,'matlab.DiscreteEventSystem')
        protectedFunList=matlab.system.editor.internal.CodeTemplate.AllSystemObjectMethodNames;
        allowedDESFunList={'entry','exit','timer','iterate','blocked','destroy','testEntry',...
        'generate','resourceAcquired','resourceReleased'};
        protectedFunList=setdiff(protectedFunList,allowedDESFunList);
    else
        protectedFunList=matlab.system.editor.internal.CodeTemplate.AllSystemObjectMethodNamesNoDES;
    end

    allowedFunList={'stepImpl','outputImpl','updateImpl'};
    [~,index]=intersect(protectedFunList,allowedFunList);
    protectedFunList(index)=[];
    illegalFunList=[protectedFunList,className];


    funNodes=mtfind(subtree(t),'Kind','FUNCTION');
    funStrings=funNodes.Fname.strings;
    commonFunStr=intersect(funStrings,illegalFunList);



    lenComFunStr=length(commonFunStr);
    for idx=1:lenComFunStr
        findRes=findGlobalsInMethods(t,commonFunStr{idx});
        if~isempty(findRes)
            error(message('MATLAB:system:globalDeclarationNotAllowed',...
            commonFunStr{idx}));
        end
    end

    glOutput=findGlobalsInMethods(t,'outputImpl');
    glUpdate=findGlobalsInMethods(t,'updateImpl');
    glStepOutput=findGlobalsInMethods(t,'stepImpl');
    glStepOutput=union(glStepOutput,glOutput);
    globalList=union(glOutput,glUpdate);
    globalList=union(glStepOutput,globalList);




    [glList,glMethods]=obj.getGlobalsForFunctions();
    if~isempty(glList)

        globalList=unique(glList);
        glStepOutput=globalList;
    end
end


function gl=findGlobalsInMethods(t,method)


    miNode=mtfind(subtree(t),'Fun',method);
    glNodeStart=mtfind(miNode.Parent.Parent.Parent.Body,'Kind','GLOBAL');


    glNodeList=miNode.Parent.Parent.Parent.Body.List;
    foundNonGlobal=false;
    foundGlobalAfterNonGlobal=false;


    for glNodeIdx=indices(glNodeList)
        glNode=select(glNodeList,glNodeIdx);

        if glNode.kind~="GLOBAL"
            foundNonGlobal=true;
        end


        if foundNonGlobal&&glNode.kind=="GLOBAL"
            foundGlobalAfterNonGlobal=true;
            break;
        end
    end
    if foundGlobalAfterNonGlobal
        error(message('MATLAB:system:globalDeclarationMustBeFirst',glNode.Arg.tree2str,method));
    end

    gl=cell(1,30);
    lenAllGl=1;
    while iskind(glNodeStart,'GLOBAL')
        thisGl=fillFromGlobalLine(glNodeStart);
        glNodeStart=glNodeStart.Next;
        lenGl=length(thisGl);
        gl(lenAllGl:lenAllGl+lenGl-1)=thisGl;
        lenAllGl=lenAllGl+lenGl;
    end
    gl(lenAllGl:end)=[];
end



function gl=fillFromGlobalLine(glNodeStart)

    gl=cell(1,10);
    thisNode=glNodeStart.Arg;
    i=1;
    while~isempty(thisNode)
        gl{i}=thisNode.string;
        thisNode=thisNode.Next;
        i=i+1;
    end
    gl(i:end)=[];
end


