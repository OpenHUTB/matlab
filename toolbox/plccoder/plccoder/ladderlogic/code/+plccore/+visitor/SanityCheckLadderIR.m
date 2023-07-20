classdef SanityCheckLadderIR<plccore.visitor.BaseEmitter


    properties
        currentPOU;
        currentRung;
        currentRungInstruction;
        isFirstRungInstruction(1,1)logical=true;
        isCurrentRoutinePrescan(1,1)logical=false;
    end

    methods
        function obj=SanityCheckLadderIR(ctx)
            obj@plccore.visitor.BaseEmitter(ctx);
            obj.Kind='SanityTest_ContactCoil1';
            obj.analyzeContext;
        end

        function startSanityCheck(obj)
            obj.SanityCheckFunctionBlock;
            obj.SanityCheckProgram;
        end

        function ret=visitGlobalScope(obj,host,input)%#ok<INUSD>
            ret=[];
            name_list=host.getSymbolNames;
            for i=1:numel(name_list)
                name=name_list{i};
                sym=host.getSymbol(name);
                switch sym.kind
                case 'NamedType'
                    obj.DataTypeList{end+1}=sym;
                case 'Var'
                    obj.GlobalVarList{end+1}=sym;
                case 'FunctionBlock'
                    obj.FunctionBlockList{end+1}=sym;
                case 'Program'
                    obj.ProgramList{end+1}=sym;
                end
            end
        end
    end

    methods(Access=private)

        function SanityCheckFunctionBlock(obj)
            for i=1:numel(obj.FunctionBlockList)
                fb=obj.FunctionBlockList{i};
                fb.accept(obj,[]);
            end
        end

        function SanityCheckProgram(obj)
            for i=1:numel(obj.ProgramList)
                fb=obj.ProgramList{i};
                fb.accept(obj,[]);
            end
        end

        function checkLadderInstrArgTypes(obj,instr,inputs,outputs)
            if isa(instr,'plccore.ladder.TargetInstruction')

                inputParamTypes=instr.getInputTypeList;
                if~isempty(inputParamTypes)
                    obj.checkParamTypesMatchArgTypes(instr,inputParamTypes,inputs);
                end

                outputParamTypes=instr.getOutputTypeList;
                if~isempty(outputParamTypes)
                    obj.checkParamTypesMatchArgTypes(instr,outputParamTypes,outputs);
                end
            end
        end

        function checkParamTypesMatchArgTypes(obj,instr,paramTypes,args)
            import plccore.visitor.SanityCheckLadderIR;
            import plccore.common.Utils;
            import plccore.common.plcThrowError;

            if isa(instr,'plccore.ladder.TargetInstruction')
                isPOUInstruction=false;
            else
                isPOUInstruction=true;
            end

            for i=1:numel(args)
                if isa(args{i},'plccore.expr.WildCardExpr')
                    continue;
                end

                if isa(args{i},'plccore.expr.UnknownExpr')
                    if~isempty(obj.Context.getPLCConfigInfo)&&...
                        ~obj.Context.getPLCConfigInfo.supportUnknownInstruction
                        plcThrowError('plccoder:plccore:UnsupportedExpression',args{i}.str);
                    else
                        continue;
                    end
                end
                if isa(args{i},'plccore.expr.StringExpr')
                    continue;
                end
                [argType,aliasFound,isUnknownType]=Utils.getTypeFromExpr(obj.Context,obj.currentPOU,args{i});

                if aliasFound||isUnknownType
                    continue;
                end

                paramTypesForArg=paramTypes{i};

                [aretypesequal,argTypeStr,paramStrs]=SanityCheckLadderIR.typeEquality(paramTypesForArg,argType,isPOUInstruction,obj.Context);
                if~aretypesequal
                    plcThrowError('plccoder:plccore:UnsupportedArgumentDataTypeInInstr',args{i}.toString,argTypeStr,instr.name,strjoin(paramStrs,', '),obj.currentPOU.name,obj.currentRung.toString);
                end
            end
        end

        function checkPOUInstrArgTypes(obj,pou,instance,arglist)
            import plccore.common.Utils.ladderType2Str;
            import plccore.common.Utils.getVarInstance;
            import plccore.common.plcThrowError;
            import plccore.common.Utils;
            import plccore.type.TypeTool;
            assert(isa(pou,'plccore.common.POU'));

            [typ,isAlias,isunknown]=Utils.getTypeFromExpr(obj.Context,obj.currentPOU,instance);
            if~isAlias&&~isunknown
                instanceType=TypeTool.getTypeName(typ);
                if~strcmpi(pou.name,instanceType)
                    plcThrowError('plccoder:plccore:UnsupportedArgumentDataTypeInInstr',instance.toString,instanceType,pou.name,pou.name,obj.currentPOU.name,obj.currentRung.toString);
                end
            end

            if isempty(pou.argList)&&~isempty(arglist)
                plcThrowError('plccoder:plccore:POUArgListCountMismatch',pou.name,'0',num2str(length(arglist)),obj.currentPOU.name,obj.currentRung.toString);
            end

            aliasFoundInArgList=false;
            for ii=1:numel(pou.argList)
                paramName=pou.argList{ii};
                param=getVarInstance(paramName,obj.Context,pou);
                if isa(param,'plccore.common.AliasInfo')
                    aliasFoundInArgList=true;
                end
            end

            if~aliasFoundInArgList
                if length(pou.argList)~=length(arglist)
                    plcThrowError('plccoder:plccore:POUArgListCountMismatch',pou.name,num2str(length(pou.argList)),num2str(length(arglist)),obj.currentPOU.name,obj.currentRung.toString);
                end

                paramTypes={};
                for ii=1:numel(pou.argList)
                    paramName=pou.argList{ii};
                    param=getVarInstance(paramName,obj.Context,pou);
                    if~param.required
                        plcThrowError('plccoder:plccore:POUArgListContainsNonRequiredVar',pou.name,paramName);
                    end
                    paramTypes{end+1}=param.type;%#ok<AGROW>
                end
                obj.checkParamTypesMatchArgTypes(pou,paramTypes,arglist);
            end
        end
    end

    methods
        function ret=visitVar(obj,host,input)%#ok<INUSL,INUSD>
            ret=[];
            if isa(host.type,'plccore.type.UnknownType')
                assert(false);
            end
        end

        function ret=visitAliasInfo(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitScope(obj,host,input)
            name_list=host.getSymbolNames;
            for i=1:numel(name_list)
                symbol=host.getSymbol(name_list{i});
                symbol.accept(obj,input);
            end
            ret=[];
        end

        function ret=visitFunction(obj,host,input)%#ok<INUSD>
            assert(false,'function is not supported on RSLogix targets');
            ret=[];
        end

        function ret=visitFunctionBlock(obj,host,input)
            obj.currentPOU=host;
            host.inputScope.accept(obj,'Input');
            host.outputScope.accept(obj,'Output');
            host.localScope.accept(obj,'Local');
            host.inOutScope.accept(obj,'InOut');
            if~isempty(host.impl)
                ret=host.impl.accept(obj,input);
            else
                ret=[];
            end

        end

        function ret=visitProgram(obj,host,input)%#ok<INUSD>
            obj.currentPOU=host;
            host.inputScope.accept(obj,'Tag');
            host.outputScope.accept(obj,'Tag');
            host.localScope.accept(obj,'Tag');
            host.inOutScope.accept(obj,'InOut');
            ret=[];
        end

        function ret=visitRoutine(obj,host,input)%#ok<INUSD>
            if strcmpi(host.name,'Prescan')
                obj.isCurrentRoutinePrescan=true;
            end
            ret=host.impl.accept(obj,[]);
            if obj.isCurrentRoutinePrescan
                obj.isCurrentRoutinePrescan=false;
            end
        end

        function ret=visitLadderDiagram(obj,host,input)%#ok<INUSD>
            rungs=host.rungs;
            for i=1:numel(rungs)
                rung=rungs{i};
                rung.accept(obj,i);
            end
            ret=[];
        end

        function ret=visitLadderRung(obj,host,input)%#ok<INUSD>
            obj.currentRung=host;
            obj.isFirstRungInstruction=true;
            rungops=host.rungOps;
            for i=1:numel(rungops)
                rungop=rungops{i};
                rungop.accept(obj,[]);
            end
            ret=[];

        end

        function ret=visitRungOpAtom(obj,host,input)%#ok<INUSD>
            import plccore.common.plcThrowError;
            obj.currentRungInstruction=host.instr;

            if obj.isCurrentRoutinePrescan
                if ismember(host.instr.name,{'OTE','OSR','OSF','ONS','TON','TOF','RTO','CTU','CTD'})
                    plcThrowError('plccoder:plccore:UnsupportedInstructionPrescanRoutine',host.instr.name,obj.currentPOU.name);
                end
            end

            if isa(obj.currentRungInstruction,'plccore.ladder.LBLInstr')...
                &&~obj.isFirstRungInstruction
                plcThrowError('plccoder:plccore:LBLShouldBeFirstElementInRung',obj.currentRung.toString,obj.currentPOU.name);
            end

            obj.checkLadderInstrArgTypes(obj.currentRungInstruction,host.inputs,host.outputs);

            if obj.isFirstRungInstruction
                obj.isFirstRungInstruction=false;
            end
            ret=[];
        end

        function ret=visitRungOpFBCall(obj,host,input)%#ok<INUSD>
            import plccore.common.plcThrowError;
            if obj.isCurrentRoutinePrescan
                plcThrowError('plccoder:plccore:UnsupportedFunctionBlockCallPrescanRoutine',host.pou.name,obj.currentPOU.name);
            end
            obj.checkPOUInstrArgTypes(host.pou,host.instance,host.argList);
            ret=[];
        end

        function ret=visitRungOpPar(obj,host,input)
            rungops=host.rungOps;
            for i=1:numel(rungops)
                rungop=rungops{i};
                rungop.accept(obj,input);
            end
            ret=[];

        end

        function ret=visitRungOpSeq(obj,host,input)
            rungops=host.rungOps;
            for i=1:numel(rungops)
                rungop=rungops{i};
                rungop.accept(obj,input);
            end
            ret=[];
        end

        function ret=visitLadderInstruction(obj,host,input)%#ok<INUSL,INUSD>
            ret=host.name;
        end

        function ret=visitCoilInstr(obj,host,input)%#ok<INUSD>
            ret='OTE';
        end

        function ret=visitGEQInstr(obj,host,input)%#ok<INUSD>
            ret='GEQ';
        end

        function ret=visitLEQInstr(obj,host,input)%#ok<INUSD>
            ret='LEQ';
        end

        function ret=visitNCCInstr(obj,host,input)%#ok<INUSD>
            ret='XIO';
        end

        function ret=visitNOCInstr(obj,host,input)%#ok<INUSD>
            ret='XIC';
        end

        function ret=visitNTCInstr(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitNTCoilInstr(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitNegCoilInstr(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitPTCInstr(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitPTCoilInstr(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitResetCoilInstr(obj,host,input)%#ok<INUSD>
            ret='OTU';
        end

        function ret=visitSetCoilInstr(obj,host,input)%#ok<INUSD>
            ret='OTL';
        end

        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSD>
            ret=[];
        end

    end

    methods(Static,Access=private)
        function[tf,actualTypeStr,expectedTypeStrs]=typeEquality(expectedTypes,actualType,isPOUInstruction,ctx)
            tf=false;
            containsStructType=false;
            if isa(actualType,'plccore.type.BitFieldType')
                actualType=plccore.type.BOOLType;
            end
            expectedTypeStrs=cell(1,length(expectedTypes));
            if isPOUInstruction
                import plccore.type.TypeTool;
                if TypeTool.isNamedType(expectedTypes)
                    expectedTypeStrs={expectedTypes.name};
                elseif TypeTool.isPOUType(expectedTypes)
                    pou=ctx.configuration.globalScope.getSymbol(expectedTypes.toString);
                    expectedTypeStrs={pou.name};
                else
                    expectedTypeStrs={class(expectedTypes)};
                end
            else
                for ii=1:length(expectedTypes)
                    expectedTypeStrs{ii}=class(expectedTypes{ii});
                    if isa(expectedTypes{ii},'plccore.type.StructType')
                        containsStructType=true;
                    elseif isa(expectedTypes{ii},'plccore.type.NamedType')
                        expectedTypeStrs{ii}=expectedTypes{ii}.name;
                    end
                end

            end
            if isa(actualType,'plccore.type.NamedType')
                if~isPOUInstruction&&containsStructType
                    actualTypeStr=class(actualType.type);
                else
                    actualTypeStr=actualType.name;
                end
            elseif TypeTool.isPOUType(actualType)
                pou=ctx.configuration.globalScope.getSymbol(actualType.toString);
                actualTypeStr=pou.name;
            else
                actualTypeStr=class(actualType);
            end


            if~ismember(actualTypeStr,expectedTypeStrs)
                dintype=plccore.type.DINTType;
                booltype=plccore.type.BOOLType;
                if strcmpi(actualTypeStr,class(dintype))
                    if ismember(class(booltype),expectedTypeStrs)
                        tf=true;
                    end
                end
            else
                tf=true;
            end
        end
    end

end




