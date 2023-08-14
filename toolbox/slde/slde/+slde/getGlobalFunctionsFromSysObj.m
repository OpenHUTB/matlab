function[glList,glMethods]=getGlobalFunctionsFromSysObj(obj)
    glList={};
    glMethods={};
    rawClassName=class(obj);
    fileNamePath=which(rawClassName);
    t=mtree(fileNamePath,'-file');

    funNodes=mtfind(subtree(t),'Kind','FUNCTION');
    funStrings=funNodes.Fname.strings;
    nonDesFunStrings={};

    allowedDESFunList={'entry','exit','timer','iterate',...
    'blocked','destroy','testEntry',...
    'generate','resourceAcquired','resourceReleased'};

    allowedNonDESFunList={'getEntityPortsImpl','getEntityStorageImpl'...
    ,'getEntityTypesImpl','getIconImpl','isInactivePropertyImpl'...
    ,'getOutputSizeImpl','getOutputDataTypeImpl','isOutputComplexImpl'...
    ,'getDiscreteStateSpecificationImpl','releaseImpl','loadObjectImpl'...
    ,'isDoneImpl','getDiscreteStateImpl','getGlobalNamesImpl'...
    ,'getHeaderImpl','getInputNamesImpl','getNumInputsImpl'...
    ,'getNumOutputsImpl','getOutputNamesImpl','getPropertyGroupsImpl'...
    ,'getSimulateUsingImpl','infoImpl','resetImpl','saveObjectImpl'...
    ,'setProperties','setupImpl','validateInputsImpl'...
    ,'validatePropertiesImpl'};

    for idx1=1:numel(funStrings)
        desFunction=false;
        for idx2=1:numel(allowedDESFunList)

            r=allowedDESFunList{idx2};
            pat=['.*[',r(1),upper(r(1)),']',r(1,2:length(r)),'$'];
            foundFcnIdx=regexp(funStrings{idx1},pat);
            if(foundFcnIdx>0)
                list=findGlobalsInMethods(t,funStrings{idx1});
                methods=repmat(funStrings(idx1),[1,numel(list)]);
                glList=[glList,list];
                glMethods=[glMethods,methods];
                desFunction=true;
                break;
            end
        end
        if~desFunction
            nonDesFunStrings=[nonDesFunStrings,funStrings{idx1}];
        end
    end







end

function findGlobalsInNonDesMethod(obj,t,method,glList)

    rawClassName=class(obj);
    miNode=mtfind(subtree(t),'Fun',method);


    glNodeList=miNode.Parent.Parent.Parent.Body.List;
    foundUnrefGlobal=false;


    for glNodeIdx=indices(glNodeList)
        glNode=select(glNodeList,glNodeIdx);


        variable='';
        if glNode.kind=="GLOBAL"
            tree=glNode.Arg;
            while~isempty(tree)
                if~any(strcmp(glList,tree.tree2str))
                    foundUnrefGlobal=true;
                    variable=tree.tree2str;
                    break;
                end
                tree=tree.Next;
            end
            if foundUnrefGlobal
                break;
            end
        end
    end

    if foundUnrefGlobal
        error(message(...
        'SimulinkDiscreteEvent:MatlabEventSystem:UnreferencedGlobalInLocalFunction',...
        variable,method,rawClassName));
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
