function functionInfo=getcallinfo(filename)




















    fileCode=getmcode(filename);
    nonLines=false(length(fileCode),1);

    try
        tree=mtree(filename,'-file');
    catch exception
        if strcmp(exception.identifier,'MATLAB:mtree:input');
            error('MATLAB:codetools:BadInput',exception.message);
        else
            exception.rethrow;
        end
    end
    if count(tree)==1&&iskind(tree,'ERR')
        error(message('MATLAB:codetools:SyntaxError',string(tree)));
    end

    type=internal.matlab.codetools.reports.matlabType.findType(tree);
    functions=mtfind(tree,'Kind','FUNCTION');
    fileIsFunction=(type==internal.matlab.codetools.reports.matlabType.Function);
    numberOfNonTopFunctions=count(functions)-1*fileIsFunction;


    [~,fname]=fileparts(filename);





    idx=functions.indices;
    rootNode=root(tree);

    functionInfo.name=fname;

    structSize=cell(1,numberOfNonTopFunctions);
    nonTopFunctionInfo=struct('name',structSize,'firstline',structSize,'lastline',structSize,'linemask',structSize);


    for i=1:numberOfNonTopFunctions

        functionNode=select(functions,idx(i-~fileIsFunction+1));

        nonTopFunctionInfo(i)=parseInfo(functionNode,nonLines);
    end


    if tree.count>0

        functionInfo=addLineInfo(functionInfo,rootNode,nonLines);


        if isa(type,'internal.matlab.codetools.reports.matlabType.Script')


            if numberOfNonTopFunctions~=0




                firstLocalFunctionStart=min([nonTopFunctionInfo.firstline]);
                functionInfo.lastline=firstLocalFunctionStart-1;

                functionInfo.linemask(1:(firstLocalFunctionStart-1))=1;





            else


                functionInfo.lastline=getlastexecutableline(rootNode);
                functionInfo.linemask=functionInfo.linemask|1;
            end
        end
    else
        functionInfo.firstline=0;
        functionInfo.lastline=0;
        functionInfo.linemask=false;
    end

    functionInfo=[functionInfo,nonTopFunctionInfo];


    if isa(type,'internal.matlab.codetools.reports.matlabType.Class')
        if length(functionInfo)>1
            functionInfo=functionInfo(2:end);
        end
    end
end

function info=parseInfo(functionNode,nonLines)
    info.name=char(strings(Fname(functionNode)));
    info=addLineInfo(info,functionNode,nonLines);
end

function functionInfo=addLineInfo(functionInfo,functionNode,nonLines)
    innerfcns=mtfind(subtree(functionNode)-functionNode,'Kind','FUNCTION');


    functionInfo.firstline=lineno(functionNode);
    try
        functionInfo.lastline=lastone(functionNode);
    catch ex
        if strcmp(ex.identifier,'MATLAB:badsubscript')
            functionInfo.lastline=functionInfo.firstline;
        else
            ex.rethrow
        end
    end

    lineMask=nonLines;
    lineMask(functionInfo.firstline:functionInfo.lastline)=true;
    functionInfo.linemask=lineMask;

    oidx=innerfcns.indices;
    for i=1:length(oidx)
        otherNode=select(innerfcns,oidx(i));
        functionInfo.linemask(otherNode.lineno:otherNode.lastone)=false;
    end
end

function matlabCodeAsCellArray=getmcode(filename)



    fileContentsAsString=matlab.internal.getCode(filename);
    if(isempty(fileContentsAsString))
        matlabCodeAsCellArray={};
    else
        matlabCodeAsCellArray=strsplit(fileContentsAsString,{'\r\n','\n','\r'},'CollapseDelimiters',false)';
    end
end
