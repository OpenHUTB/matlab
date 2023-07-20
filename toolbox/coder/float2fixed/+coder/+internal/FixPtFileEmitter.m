classdef FixPtFileEmitter<coder.internal.MTreeVisitor
    properties
originalFilePath
compiledExprInfo
simExprInfo
fcnRegistry
fcnTypeInfoMap
typeProposalSettings
fxpConversionSettings
fiOperatorMapper
outputPath

mtree
annotations
errMsgs
autoReplaceHndlr
structCopyHandler
classSpecializationName
classProperties

uniqueNamesService
globalUniqNameMap
fimathFcnName
    end

    methods
        function this=FixPtFileEmitter(originalFilePath,fcnRegistry,compiledExprInfo,simExprInfo,typeProposalSettings,fxpConversionSettings,fiOperatorMapper,outputPath,autoReplaceHndlr,classSpecializationName,uniqueNameService,globalUniqNameMap,fimathFcnName)
            this.originalFilePath=originalFilePath;
            this.fcnRegistry=fcnRegistry;
            this.compiledExprInfo=compiledExprInfo;
            this.simExprInfo=simExprInfo;
            this.typeProposalSettings=typeProposalSettings;
            this.fxpConversionSettings=fxpConversionSettings;
            this.fiOperatorMapper=fiOperatorMapper;
            this.outputPath=outputPath;
            this.autoReplaceHndlr=autoReplaceHndlr;
            this.structCopyHandler=coder.internal.StructCopyHandler();
            this.classSpecializationName=classSpecializationName;

            code=this.fileread(this.originalFilePath);
            this.mtree=coder.internal.translator.F2FMTree(code,'-comments');

            this.fcnTypeInfoMap=containers.Map();
            fcnTypeInfos=fcnRegistry.getAllFunctionTypeInfos();


            for ii=1:length(fcnTypeInfos)
                fcnInfo=fcnTypeInfos{ii};
                if~strcmp(fcnInfo.classSpecializationName,this.classSpecializationName)
                    continue;
                end
                if strcmp(fcnInfo.scriptPath,this.originalFilePath)
                    if this.fcnTypeInfoMap.isKey(fcnInfo.functionName)
                        fcnsWithSameName=this.fcnTypeInfoMap(fcnInfo.functionName);
                    else
                        fcnsWithSameName={};
                    end
                    fcnsWithSameName{end+1}=fcnInfo;%#ok<AGROW>
                    this.fcnTypeInfoMap(fcnInfo.functionName)=fcnsWithSameName;
                end
            end

            this.classProperties=[];

            this.uniqueNamesService=uniqueNameService;
            this.globalUniqNameMap=globalUniqNameMap;
            this.fimathFcnName=fimathFcnName;
            this.errMsgs=coder.internal.lib.Message.empty();
        end

        function[code,errorMsgs]=emit(this)

            this.fiOperatorMapper.beginSession();

            this.annotations={};
            node=this.mtree.root;
            while~isempty(node)
                this.visit(node,[]);
                node=node.Next;
            end

            code='';
            node=this.mtree.root;
            while~isempty(node)
                node_str=node.tree2str(0,1,this.annotations);
                code=[code,node_str,newline];
                node=node.Next;
            end

            operatorCode=this.getCodeForFunctionReplacements(code);
            if~isempty(operatorCode)
                code=[code,newline,operatorCode];
            end

            mathFcnGenCode=this.autoReplaceHndlr.getCode();
            if~isempty(mathFcnGenCode)
                code=[code,newline,mathFcnGenCode];
            end

            structCopyCode=this.structCopyHandler.getCode();
            if~isempty(structCopyCode)
                code=[code,newline,structCopyCode];
            end
            errorMsgs=this.errMsgs;

            if this.fxpConversionSettings.EmitSeperateFimathFunction&&~this.fxpConversionSettings.DoubleToSingle
                fimathFcnCode=coder.internal.DesignTransformer.getFiMathFunctionCode(this.fimathFcnName,this.fxpConversionSettings.globalFimathStr);
                code=[code,newline,fimathFcnCode,newline];
            end
        end
    end

    methods
        function code=getCodeForFunctionReplacements(this,translatedCode)
            code='';
            fcns=this.fiOperatorMapper.getReplacementFcnsUsed();
            includedFcns={};
            for ii=1:length(fcns)
                t=mtree(translatedCode);%#ok<CPROPLC>
                fcn=fcns{ii};
                if~isempty(t.mtfind('Kind','CALL','Left.String',fcn))
                    includedFcns{end+1}=fcn;
                    fcnCode=this.fiOperatorMapper.getLibraryCode(fcn);
                    code=[code,newline,newline,fcnCode];

                    dependencies=this.fiOperatorMapper.getFunctionDependencies(fcn);
                    for jj=1:length(dependencies)
                        dep=dependencies{jj};
                        if~any(ismember(includedFcns,dep))
                            includedFcns{end+1}=dep;
                            fcnCode=this.fiOperatorMapper.getLibraryCode(dep);
                            code=[code,newline,newline,fcnCode];
                        end
                    end
                end
            end
        end
    end

    methods
        function out=visitFUNCTION(this,fcnNode,input)%#ok<INUSD>
            out=[];
            fcnName=fcnNode.Fname.stringval;
            switch fcnName
            case{'getNumOutputsImpl','getNumInputsImpl'}

                return;
            case{'releaseImpl','validateInputsImpl','infoImpl'}

                return;
            case{'stepImpl','setupImpl','resetImpl','isDoneImpl'}

            end

            code='';
            if this.fcnTypeInfoMap.isKey(fcnName)
                fcnsWithSameName=this.fcnTypeInfoMap(fcnName);
                code='';
                for ii=1:length(fcnsWithSameName)
                    fcnTypeInfo=fcnsWithSameName{ii};
                    if fcnTypeInfo.emitted
                        [compiledFcnExprInfo,simFcnExprInfo]=this.getExprInfo(fcnTypeInfo.uniqueId);
                        translator=coder.internal.translator.MultiPass(fcnNode,fcnTypeInfo,compiledFcnExprInfo,simFcnExprInfo,this.fcnRegistry,this.typeProposalSettings,this.fxpConversionSettings,this.fiOperatorMapper,this.autoReplaceHndlr,this.structCopyHandler,this.outputPath,this.uniqueNamesService,this.globalUniqNameMap,this.fimathFcnName);
                        [functionCode,eers,~]=translator.translate(0);
                        code=[code,newline,functionCode];%#ok<AGROW>
                        this.errMsgs=[this.errMsgs,eers];
                    end
                end
            end
            this.annotations{end+1}=fcnNode;
            this.annotations{end+1}=code;
        end

        function out=visitCLASSDEF(this,node,inp)
            cexpr=node.Cexpr;
            classNameNode=[];
            switch cexpr.kind
            case 'ID'
                classNameNode=cexpr;
            case 'LT'
                classNameNode=cexpr.Left;
            end

            className=classNameNode.stringval;

            assert(~isempty(this.fcnRegistry.classMap));
            assert(this.fcnRegistry.classMap.isKey(className));

            this.classProperties=this.fcnRegistry.classMap(className);

            this.annotations{end+1}=classNameNode;
            this.annotations{end+1}=this.classSpecializationName;
            out=this.visitCLASSDEF@coder.internal.MTreeVisitor(node,inp);
        end

        function output=visitProperty(this,propNameNode,valueNode,input)%#ok<INUSD>
            output=[];
            if isempty(valueNode)
                return;
            end

            propName=propNameNode.stringval;
            propInfo=this.classProperties(propName);


            isAlwaysInt=[];
            if propInfo.isConstant
                assert(isfield(propInfo,'initialValue'));
                assert(~isempty(propInfo.initialValue));
                type=coder.internal.translator.Phase.getFixPtTypeForValue(propInfo.initialValue,isAlwaysInt,this.typeProposalSettings);
            else
                if isfield(propInfo,'vars')
                    type=propInfo.vars{1}.annotated_Type;
                else


                    type=coder.internal.translator.Phase.getFixPtTypeForValue(propInfo.initialValue,isAlwaysInt,this.typeProposalSettings);
                end

                if isempty(type)
                    return;
                end
            end



            fimathStr=this.fxpConversionSettings.globalFimathStr;
            code=valueNode.tree2str(0,1);
            castedCode=coder.internal.translator.Phase.wrapExpressionCodeWithType(code,type,fimathStr,false,this.fxpConversionSettings.DoubleToSingle);
            this.annotations{end+1}=valueNode;
            this.annotations{end+1}=castedCode;
        end
    end

    methods(Static)
        function str=fileread(filePath)
            fid=coder.internal.safefopen(filePath,'r');
            str=fread(fid,'*char')';
            fclose(fid);
        end
    end

    methods(Access='private')
        function[compiledFcnExprInfo,simFcnExprInfo]=getExprInfo(this,functionId)
            simFcnExprInfo=coder.internal.lib.Map.empty();
            if~isempty(this.simExprInfo)&&isKey(this.simExprInfo,functionId)
                simFcnExprInfo=this.simExprInfo(functionId);
            end

            compiledFcnExprInfo=coder.internal.lib.Map.empty();
            if~isempty(this.compiledExprInfo)&&isKey(this.compiledExprInfo,functionId)
                compiledFcnExprInfo=this.compiledExprInfo(functionId);
            end
        end
    end
end