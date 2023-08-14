function[dataType,size]=getDataTypeFromMnode(node,inference)








    functionName=getNodeParentFunctionName(node);


    FcnIndex=getFunctionIndex(inference,functionName);
    if isempty(FcnIndex)
        dataType='unknown';
        return;
    end



    scriptID=inference.Functions(FcnIndex).ScriptID;
    mt=mtree(inference.Scripts(scriptID).ScriptText,'-com','-cell','-comments');
    node=mt.select(node.indices);

    switch node.kind
    case{'ID'}
        stIndex=node.position-1;
        len=node.endposition-stIndex;
        [dataType,size]=getDataTypeFromInference(inference,functionName,stIndex,len);
    case{'INT'}
        stIndex=node.position-1;
        len=node.endposition-stIndex;
        [dataType,size]=getDataTypeFromInference(inference,functionName,stIndex,len);




        if strcmp(dataType,'unknown')
            dataType='int32';
        end
    case{'DOUBLE'}
        stIndex=node.position-1;
        len=node.endposition-stIndex;
        [dataType,size]=getDataTypeFromInference(inference,functionName,stIndex,len);




        if strcmp(dataType,'unknown')
            dataType='double';
        end
    case 'CALL'
        stIndex=node.lefttreepos-1;
        len=node.righttreepos-stIndex;
        [dataType,size]=getDataTypeFromInference(inference,functionName,stIndex,len);
        if isTypeCast(node)&&strcmp(dataType,'unknown')


            [dataType,size]=Advisor.Utils.Eml.getDataTypeFromMnode(node.Right,inference);
        end
    case 'PARENS'
        stIndex=node.Arg.lefttreepos-1;
        len=node.Arg.righttreepos-stIndex;
        [dataType,size]=getDataTypeFromInference(inference,functionName,stIndex,len);
    case{'MUL','DIV','LDIV','ADD','SUB','PLUS','MINUS'}
        stIndex=node.lefttreepos-1;
        len=node.righttreepos-stIndex;
        [dataType,size]=getDataTypeFromInference(inference,functionName,stIndex,len);
    case 'SUBSCR'
        stIndex=node.lefttreepos-1;
        len=node.righttreepos-stIndex;
        [dataType,size]=getDataTypeFromInference(inference,functionName,stIndex,len);
    case{'TRANS','DOTTRANS','LB','ROW','NOT','UMINUS','UPLUS'}
        [dataType,size]=Advisor.Utils.Eml.getDataTypeFromMnode(node.Arg,inference);
    otherwise
        dataType='unknown';
        size=[];
    end
end

function[dataType,size]=getDataTypeFromInference(rpi,functionName,stIndex,textLength)
    dataType='unknown';
    size=[];
    FcnIndex=getFunctionIndex(rpi,functionName);
    if isempty(FcnIndex)
        return;
    end
    functionStruct=rpi.Functions(FcnIndex);
    MxInfers=functionStruct.MxInfoLocations;

    for i=1:length(MxInfers)
        if MxInfers(i).TextStart==stIndex&&MxInfers(i).TextLength==textLength
            dataType=getClassName(rpi,rpi.MxInfos{MxInfers(i).MxInfoID});
            size=rpi.MxInfos{MxInfers(i).MxInfoID}.Size;
            return;
        end
    end
end
function fIndex=getFunctionIndex(rpi,fName)
    AllFcnNames={rpi.Functions(:).FunctionName};
    fIndex=find(strcmp(fName,AllFcnNames));
end

function funcName=getNodeParentFunctionName(node)

    while~strcmp(node.kind,'FUNCTION')
        node=node.Parent;
    end

    funcName=node.Fname.string;
end

function className=getClassName(rpi,MxInfoObj)


    className=MxInfoObj.Class;
    if strcmp(className,'embedded.fi')

        fiObj=rpi.MxArrays{MxInfoObj.NumericTypeID};
        nt=numerictype(fiObj);
        className=nt.tostringInternalSlName;
    end
end

function bResult=isTypeCast(node)

    funcName=node.Left.string;
    bResult=startsWith(funcName,'int')||startsWith(funcName,'uint')||ismember(funcName,{'single','double','cast'});
end