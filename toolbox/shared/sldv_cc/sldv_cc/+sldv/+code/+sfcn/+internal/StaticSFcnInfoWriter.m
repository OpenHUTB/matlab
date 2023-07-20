



classdef StaticSFcnInfoWriter<handle



    properties(Constant,Access=public,Hidden=true)
        InputType='Input';
        OutputType='Output';
        ParameterType='Parameter';
        DworkType='DWork';
        DiscreteType='Discrete';

        SimStructType='SimStruct';

        LhsParam='Lhs';
        RhsParam='Rhs';


        StdHeaders={'stdio.h','stdlib.h','math.h','assert.h','time.h','ctype.h',...
        'errno.h','string.h','stdarg.h','setjmp.h','signal.h','limits.h',...
        'float.h'}
    end

    properties(Access=public)
VarDecls
FunctionSpecs
FunctionArgs
Language
Compiler
CompilerVersion
Architecture

KeepSFcnMain



        HasSimStruct=false
    end

    properties(Access=private)
MainFileBody
    end

    properties(SetAccess=private,GetAccess=public)


SldvMainFile
StdioFile
    end

    properties(SetAccess=public,GetAccess=private)



OverridenFiles
    end

    properties(Access=public)
        Transpose2DMatrix=false
    end

    properties(SetAccess=public,GetAccess=private)




        DoMacroCheck=false
    end

    properties(Access=private)


        MacroCheckSymbols={};

        MacroCheckFunctions=[];
    end

    methods(Access=public)
        function obj=StaticSFcnInfoWriter(language)
            if nargin<1
                language='C';
            end

            obj.FunctionSpecs=struct([]);
            obj.VarDecls=struct([]);
            obj.FunctionArgs=struct([]);
            obj.SldvMainFile='';
            obj.MainFileBody='';
            obj.KeepSFcnMain=false;
            obj.Architecture=computer('arch');
            obj.setLanguage(language);

            obj.OverridenFiles={};
        end

        function setOverridenFiles(obj,overridenFiles)
            obj.OverridenFiles=overridenFiles;
        end

        function setMainFileBody(obj,mainFileBody)
            obj.MainFileBody=mainFileBody;
        end

        function setLanguage(obj,language)
            if strcmpi(language,'C')
                obj.Language='C';
            else
                obj.Language='C++';
            end
            obj.updateCompilerInfo();
        end

        function ext=getLanguageExt(obj)


            ext='.c';
            if~strcmpi(obj.Language,'C')
                ext='.cpp';
            end
        end

        function updateCompilerInfo(obj)



            feOptions=internal.cxxfe.util.getMexFrontEndOptions('lang',obj.Language);
            compilerInfos=sldv.code.internal.getCompilerInfo(feOptions);
            obj.Compiler=compilerInfos.compiler;
            obj.CompilerVersion=compilerInfos.compilerVersion;
        end

        function addVarDecl(obj,varCategory,name,dataType,index)
            newVar=struct('Category',varCategory,...
            'Name',name,...
            'DataType',dataType,...
            'Index',index);
            obj.VarDecls=[obj.VarDecls,newVar];
        end

        function addFunctionSpec(obj,functionName,calledName)
            newFunc=struct('Name',functionName,...
            'Called',calledName);
            obj.FunctionSpecs=[obj.FunctionSpecs,newFunc];
        end

        function addFunctionArg(obj,functionName,argSide,argIndex,...
            argIdent,argType,accessType,isScalar)
            newArg=struct('FunctionName',functionName,...
            'ArgSide',argSide,...
            'ArgIndex',argIndex,...
            'Identifier',argIdent,...
            'ArgType',argType,...
            'AccessType',accessType,...
            'IsScalar',isScalar);
            obj.FunctionArgs=[obj.FunctionArgs,newArg];
        end

        function setSldvMainFile(obj,mainFile)
            obj.SldvMainFile=polyspace.internal.getAbsolutePath(mainFile);
        end

        function checksum=updateTraceabilityDb(obj,dbFile,buildOptions,...
            instrumentedFiles,sfcnInfo,workingDir,frontEndOptions)
            extraFiles=obj.createExtraFiles(workingDir,frontEndOptions);

            sqldb=sldv.code.sfcn.internal.StaticDb(dbFile);

            sldvFiles=instrumentedFiles;
            if~isempty(obj.OverridenFiles)
                sldvFiles=obj.OverridenFiles;
            end

            sqldb.beginTransaction();

            [hasErrors,checksum]=sqldb.writeData(obj,sldvFiles,buildOptions,sfcnInfo,extraFiles);

            if~hasErrors
                sqldb.commitTransaction();
            else
                checksum='';
                sqldb.rollbackTransaction();

                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:DbWriteError');
            end

        end

        function overrideHandwrittenSources(obj,tmpDir,buildOptions)


            handwrittenInstrumenter=sldv.code.sfcn.internal.HandwrittenInstrumenter(tmpDir,buildOptions);
            obj.OverridenFiles=handwrittenInstrumenter.instrument();
        end

        function checkMacros(obj,symbols)
            if obj.DoMacroCheck
                if isempty(obj.MacroCheckSymbols)
                    obj.MacroCheckSymbols={obj.FunctionSpecs.Called};
                    obj.MacroCheckFunctions=false(size(obj.MacroCheckSymbols));
                end

                functions=symbols{2};
                for ii=1:numel(obj.MacroCheckSymbols)
                    if~obj.MacroCheckFunctions(ii)&&...
                        any(strcmp(obj.MacroCheckSymbols{ii},functions))
                        obj.MacroCheckFunctions(ii)=true;
                    end
                end
            end
        end

        function endMacroCheck(obj)
            if obj.DoMacroCheck
                if~all(obj.MacroCheckFunctions)
                    missingMacros=obj.MacroCheckSymbols(~obj.MacroCheckFunctions);
                    sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:MacroError',missingMacros{1});
                end
            end
        end
    end

    methods(Access=private,Static=true)
        function checkFEMessages(msgs,file)
            if any(strcmp({msgs.kind},'error')|strcmp({msgs.kind},'fatal'))
                errMsg=strjoin({msgs.desc},'\n');
                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:InternalParseError',file,errMsg);
            end
        end
    end

    methods(Access=private)
        function extraFiles=createExtraFiles(obj,workingDir,frontEndOptions)

            stdioText='';
            for ii=1:numel(obj.StdHeaders)
                stdioText=sprintf('%s#include <%s>\n',stdioText,obj.StdHeaders{ii});
            end

            obj.StdioFile=[tempname(workingDir),obj.getLanguageExt()];
            obj.StdioFile=polyspace.internal.getAbsolutePath(obj.StdioFile);
            extraFiles=struct('Content',stdioText,...
            'InstrumentedFile',obj.StdioFile);

            frontEndOptions.DoGenOutput=true;
            frontEndOptions.GenOutput=obj.StdioFile;
            msgs=internal.cxxfe.FrontEnd.parseText(stdioText,frontEndOptions);
            sldv.code.sfcn.internal.StaticSFcnInfoWriter.checkFEMessages(msgs,'stdio.h');

            fid=fopen(obj.StdioFile,'rb');
            if fid<3
                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:cannotOpenFileForWriting',obj.StdioFile);
            end
            txt=fread(fid,'*uint8')';
            fclose(fid);

            ret=uint8(newline);
            txt=[...
            uint8('#ifndef TMW_SFCN_INCLUDE'),ret,...
            uint8('#define TMW_SFCN_INCLUDE'),ret,...
            txt,ret,...
            uint8('#endif'),ret,ret...
            ];

            fid=fopen(obj.StdioFile,'wb');
            if fid<3
                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:cannotOpenFileForWriting',obj.StdioFile);
            end
            fwrite(fid,txt,'*uint8');
            fclose(fid);

            if isempty(obj.SldvMainFile)
                obj.SldvMainFile=[tempname(workingDir),obj.getLanguageExt()];
                obj.SldvMainFile=polyspace.internal.getAbsolutePath(obj.SldvMainFile);

                extraFiles=[extraFiles;struct('Content',obj.MainFileBody,...
                'InstrumentedFile',obj.SldvMainFile)];

                frontEndOptions.GenOutput=obj.SldvMainFile;




                [msgs,symbols]=internal.cxxfe.util.GlobalSymbolParser.parseText(obj.MainFileBody,frontEndOptions,3);
                sldv.code.sfcn.internal.StaticSFcnInfoWriter.checkFEMessages(msgs,'sfcn_main.c');



                allFiles=[symbols.Symbols.Files{:}];
                includedFiles=allFiles([allFiles.IsIncludedFile]&~[allFiles.IsSystemFile]);

                allFunctions=[symbols.Symbols.Functions{:}];
                if~isempty(allFunctions)


                    for ff=1:numel(obj.FunctionSpecs)
                        calledFcn=obj.FunctionSpecs(ff).Called;
                        if~any(strcmp(calledFcn,{allFunctions.Name}))
                            msg=message('sldv_sfcn:sldv_sfcn:nonVisibleCFunction',calledFcn);
                            warning('sldv_sfcn:nonVisibleFunction',...
                            msg.getString());
                        end
                    end
                    globalFunctions=allFunctions(strcmp({allFunctions.Storage},'global'));
                    globalFunctions=globalFunctions(~[globalFunctions.IsInline]);

                    includedFunctionIndexes=ismember([globalFunctions.FileIdx],[includedFiles.Idx]);

                    if any(includedFunctionIndexes)

                        includedFunctions=globalFunctions(includedFunctionIndexes);
                        fileIdx=includedFunctions(1).FileIdx;
                        filePath=allFiles(fileIdx).Name;
                        [~,fileName,fileExt]=fileparts(filePath);
                        sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:functionDefinitionInIncludedFile',[fileName,fileExt]);
                    end
                end

                allVariables=[symbols.Symbols.Variables{:}];
                if~isempty(allVariables)
                    globalVariables=allVariables(strcmp({allVariables.Storage},'global'));

                    includedVariableIndexes=ismember([globalVariables.FileIdx],[includedFiles.Idx]);
                    if any(includedVariableIndexes)
                        includedVariables=globalVariables(includedVariableIndexes);
                        fileIdx=includedVariables(1).FileIdx;
                        filePath=allFiles(fileIdx).Name;
                        [~,fileName,fileExt]=fileparts(filePath);

                        sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:variableDefinitionInIncludedFile',[fileName,fileExt]);
                    end
                end
            end
        end

    end
end





