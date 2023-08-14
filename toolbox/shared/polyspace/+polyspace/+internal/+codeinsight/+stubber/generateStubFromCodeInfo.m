

function stubInfo=generateStubFromCodeInfo(codeInfo,varargin)




    isCharCompatible=@(x)ischar(x)||(isstring(x)&&isscalar(x));
    isCellStrCompatible=@(x)iscellstr(x)||isstring(x);
    isCellOrCharCompatible=@(x)isCellStrCompatible(x)||isCharCompatible(x);
    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addRequired(argParser,'codeInfo',@(x)isa(x,'polyspace.internal.codeinsight.parser.CodeInfo'));
        addParameter(argParser,'OutputFile',"",@(x)isCellOrCharCompatible(x));
    end
    argParser.parse(codeInfo,varargin{:});

    undefinedFunctions=codeInfo.Functions([codeInfo.Functions.IsDefined]==false);
    undefinedAndUndeclaredFunctions=undefinedFunctions([undefinedFunctions.IsDeclared]==false);
    if~isempty(undefinedAndUndeclaredFunctions)
        warningState=warning('off','backtrace');
        warning("Missing declaration for functions: '"+strjoin([undefinedAndUndeclaredFunctions.Name],",")+"'."+newline+"No stub can be generated, please provide missing declarations.")
        warning(warningState);
    end
    undefinedFunctions=undefinedFunctions([undefinedFunctions.IsDeclared]==true);

    stubInfo.functionStubObjs=arrayfun(@(x)polyspace.internal.codeinsight.stubber.functionStubInfo(x),undefinedFunctions);
    stubInfo.TypeIncludes=string([]);


    typeList=unique([[undefinedFunctions.ReturnedType],[undefinedFunctions.FormalArguments]]);


    stubInfo.variablesStubObjs=[];
    undefinedVariables=codeInfo.Variables([codeInfo.Variables.IsDefined]==false);

    stubInfo.variablesStubObjs=arrayfun(@(x)polyspace.internal.codeinsight.stubber.variableStubInfo(...
    x.Name,...
    x.TypeName,...
    x.Type.StubDefinition),undefinedVariables);

    typeList=[typeList,[undefinedVariables.Type]];

    stubInfo.TypeIncludes=getTypeIncludes(typeList);



    if~ismember('OutputFile',argParser.UsingDefaults)
        outputFile=string(argParser.Results.OutputFile);
        if~isempty(stubInfo.functionStubObjs)
            exportedGlobals=arrayfun(@(x)"extern "+x,[stubInfo.functionStubObjs.extraGlobal]);
        else
            exportedGlobals=string([]);
        end
        hTypeIncludes="";
        hexportedGlobalsDefs="";
        if~isempty(stubInfo.TypeIncludes)
            hTypeIncludes=join(stubInfo.TypeIncludes,newline)+newline;
        end
        if~isempty(exportedGlobals)
            hexportedGlobalsDefs=join(exportedGlobals,newline)+newline;
        end
        [dir,name]=fileparts(outputFile);
        commentHeader="/*************************************************************************/"+newline+...
        "/* Automatically generated "+string(datestr(now))+"                          */"+newline+...
        "/* This file can be edited/modified by hand to adapt functionality.      */"+newline+...
        "/*************************************************************************/"+newline+newline;
        includeGuardMacro=upper(name)+"_";
        includeGuardStart=sprintf("#ifndef %s",includeGuardMacro)+...
        newline+sprintf("#define %s",includeGuardMacro)+newline;
        includeGuardEnd=("#endif");
        funDecls="";
        if~isempty(stubInfo.functionStubObjs)

            decls=[stubInfo.functionStubObjs.Signature];
            funDecls=newline+...
            "/*************************************************************************/"+newline+...
            "/* Function Declarations                                                 */"+newline+...
            "/*************************************************************************/"+newline+...
            sprintf("%s;\n",decls)+...
            newline;
        end

        hstr=commentHeader+includeGuardStart+hTypeIncludes+newline+...
        hexportedGlobalsDefs+newline+funDecls+newline+includeGuardEnd;

        stubHeader=fullfile(dir,name+".h");
        str=commentHeader;
        if~isempty(stubInfo.functionStubObjs)&&any([stubInfo.functionStubObjs.useMemCpy])
            str=str+sprintf('#include <string.h> /* memcpy */')+newline;
        end
        str=str+sprintf('#include "')+name+".h"+sprintf('"')+newline+newline;


        if~isempty(stubInfo.variablesStubObjs)



            constDefinition=contains([stubInfo.variablesStubObjs.Definition],"const ");
            varDefList=[stubInfo.variablesStubObjs.Definition];
            if any(constDefinition)
                str=str+"/*************************************************************************/"+newline+...
                "/* Constant Global Variable definitions                                  */"+newline+...
                "/*************************************************************************/"+newline+...
                join(varDefList(constDefinition),newline)+newline+...
                newline;
            end
            if any(~constDefinition)
                str=str+"/*************************************************************************/"+newline+...
                "/* Global Variable definitions                                           */"+newline+...
                "/*************************************************************************/"+newline+...
                join(varDefList(~constDefinition),newline)+newline+...
                newline;
            end
        end

        if~isempty(stubInfo.functionStubObjs)
            gInterface=[stubInfo.functionStubObjs.extraGlobal];
            if(~isempty(gInterface))

                str=str+"/*************************************************************************/"+newline+...
                "/* Generated Global Variables for Stubbed Functions Interface            */"+newline+...
                "/*************************************************************************/"+newline+...
                join(gInterface,newline)+newline+...
                newline;
            end

            str=str+"/*************************************************************************/"+newline+...
            "/* Function Definitions                                                  */"+newline+...
            "/*************************************************************************/"+newline+...
            join(arrayfun(@(x)x.getDefinition(),stubInfo.functionStubObjs),newline)+...
            newline;
        end

        fid=fopen(outputFile,'w');
        if fid==-1

            error("OutputFile is not a valid file");
        end
        fprintf(fid,"%s",str);
        fclose(fid);


        fid2=fopen(stubHeader,'w');

        if fid2==-1

            error("OutputFile is not a valid file");
        end
        fprintf(fid2,"%s",hstr);
        fclose(fid2);
    end
end

function typeIncludes=getTypeIncludes(typelist)
    typeIncludes=string([]);
    seenTypes=polyspace.internal.codeinsight.parser.TypeInfo.empty();

    function extractTypeIncludes(t)
        header=t.DefinitionFile;
        if any(seenTypes==t)
            return;
        end
        seenTypes(end+1)=t;
        if~isempty(t.Members)
            for m=t.Members
                extractTypeIncludes(m.Type);
            end
        end
        if~isempty(t.Type)
            extractTypeIncludes(t.Type);
        end
        if strlength(header)==0
            return;
        end
        [~,headerName,headerExt]=fileparts(header);
        include=sprintf("#include ""%s""",headerName+headerExt);
        if~ismember(include,typeIncludes)
            typeIncludes(end+1)=include;
        end
    end
    if~isempty(typelist)
        for t=typelist
            extractTypeIncludes(t);
        end
    end
end

function result=isEnumType(type)
    while(~isempty(type)&&strcmp(type.Kind,'TypedefType'))
        type=type.Type;
    end
    result=~isempty(type)&&strcmp(type.Kind,'EnumType');
end
