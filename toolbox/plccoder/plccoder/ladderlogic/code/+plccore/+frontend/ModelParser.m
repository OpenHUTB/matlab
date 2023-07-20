classdef ModelParser<handle













    properties(Access=private)
        Ctx(1,1)plccore.common.Context;
        Cfg(1,1)plccore.common.PLCConfigInfo;
        POUParserObj plccore.frontend.model.POUParser;
        ModelName(1,:)char;
        IsCompiled(1,1)logical;
        LadderBlock;
        Debug(1,:)logical;
        TaskIR;
    end

    properties(Constant)
        LadderControllerPOUType='PLC Controller';
        LadderTaskPOUType='Task';
        LadderProgramPOUType='Program';
        LadderAOIRunnerPOUType='AOIRunner';
        LadderAOIPOUType='Function Block';
        LadderSubroutinePOUType='Subroutine';
    end

    methods
        function obj=ModelParser(ladderBlock,cfg)

            validateattributes(ladderBlock,{'cell','char','string'},{'nonempty'});


            obj.LadderBlock=convertStringsToChars(ladderBlock);
            obj.IsCompiled=false;
            obj.POUParserObj=plccore.frontend.model.POUParser.empty;
            obj.ModelName=bdroot(ladderBlock);
            obj.Debug=plcfeature('PLCLadderDebug');
            if nargin==1
                cfg=plccore.common.PLCConfigInfo;
            end
            obj.Cfg=cfg;
        end

        function doit(obj)
            obj.initEngineInterface();
            obj.startParsing();
            obj.stopEngineInterface();
            obj.performIRSanityChecks();
            obj.runNamingPass();
        end

        function out=ctx(obj)
            out=obj.Ctx;
        end

        function delete(obj)



            obj.stopEngineInterface();
        end
    end

    methods(Access=private)
        function initEngineInterface(obj)
            feature('EngineInterface',Simulink.EngineInterfaceVal.plc);
            set_param(bdroot(obj.ModelName),'SimulationCommand','update');
            model=get_param(bdroot(obj.ModelName),'UDDObject');
            try
                model.init;
            catch ex
                error(['Error compiling model : ',ex.message]);
            end
            obj.IsCompiled=true;
        end

        function stopEngineInterface(obj)
            if obj.IsCompiled
                model=get_param(bdroot(obj.ModelName),'UDDObject');
                model.term;
                obj.IsCompiled=false;
            end
            feature('EngineInterface',0);
        end

        function startParsing(obj)
            import plccore.frontend.ModelParser;
            [isLadder,ldBlkInfo]=ModelParser.isLadderBlock(obj.LadderBlock);
            blkPath=getfullname(obj.LadderBlock);
            if isLadder

                obj.Ctx=ModelParser.createContext;
                obj.Ctx.setPLCConfigInfo(obj.Cfg);

                if strcmpi(ldBlkInfo.PLCPOUType,obj.LadderControllerPOUType)
                    controllerName=get_param(obj.LadderBlock,'Name');
                    obj.Ctx.createConfiguration(controllerName);
                else
                    obj.Ctx.createConfiguration('Controller');
                end
                import plccore.common.plcThrowError;
                import plccore.frontend.ModelParser;


                assert(~(ModelParser.isTBEnabled(obj.ModelName,obj.LadderBlock)&&...
                ~strcmpi(ldBlkInfo.PLCBlockType,obj.LadderAOIRunnerPOUType)),...
                'code gen not supported');


                assert(~isempty(ldBlkInfo.PLCPOUType),'Code gen not supported');

                switch ldBlkInfo.PLCPOUType
                case obj.LadderControllerPOUType
                    obj.parseController(obj.LadderBlock);
                case obj.LadderProgramPOUType
                    if strcmpi(ldBlkInfo.PLCBlockType,obj.LadderAOIRunnerPOUType)
                        obj.parseAOIRunner(obj.LadderBlock);
                    else
                        assert(false,'code gen not supported');
                    end
                case obj.LadderAOIPOUType
                    obj.parseAOI(obj.LadderBlock);
                otherwise
                    assert(false,'codegen not supported');
                end
            else
                blkType=ModelParser.getBlockType(obj.LadderBlock);
                plcThrowError('plccoder:plccore:InvalidLadderCodeGenBlock',blkType,blkPath,...
                obj.LadderControllerPOUType,obj.LadderAOIRunnerPOUType,obj.LadderAOIPOUType);
            end
        end



        function performIRSanityChecks(obj)
            import plccore.visitor.SanityCheckLadderIR;
            sanityCheck=SanityCheckLadderIR(obj.ctx);
            sanityCheck.startSanityCheck;
        end

        function runNamingPass(obj)
            import plccore.visitor.NamingPassVisitor;
            namingPassVisitor=NamingPassVisitor(obj.ctx);
            namingPassVisitor.runPass;
        end

        function parseController(obj,controllerBlk)
            obj.generateGlobalDataIR(controllerBlk);

            pouInfo=slplc.api.getPOU(controllerBlk);
            tasksBlks=plc_find_system(pouInfo.LogicBlock,'SearchDepth',1,'PLCPOUType',obj.LadderTaskPOUType);

            programsBlks=plc_find_system(pouInfo.LogicBlock,'LookUnderMasks','on','SearchDepth',1,'PLCPOUType','Program');

            if~isempty(programsBlks)
                import plccore.common.plcThrowError;
                plcThrowError('plccoder:plccore:ControllerContainsProgram',getfullname(controllerBlk));
            end

            if~isempty(tasksBlks)
                for taskIndex=1:size(tasksBlks,1)
                    taskBlk=tasksBlks{taskIndex};
                    obj.parseTask(taskBlk);
                end
            end
        end

        function parseTask(obj,task_blk)
            import plccore.common.TaskClass;
            import plccore.frontend.ModelParser;

            [task_name,task_rate,task_priority,task_watchdog,task_desc]=ModelParser.getTaskBlockInfo(task_blk);

            if isempty(task_rate)

                if strcmp(task_watchdog,'0')
                    task_watchdog='500';
                end
                obj.TaskIR=obj.Ctx.configuration.createContinuousTask(task_name,...
                task_desc,...
                task_priority,task_watchdog,...
                TaskClass.Standard);
            else

                if strcmp(task_watchdog,'0')
                    task_watchdog=task_rate;
                end
                obj.TaskIR=obj.Ctx.configuration.createPeriodicTask(task_name,...
                task_desc,...
                task_priority,task_watchdog,...
                TaskClass.Standard,...
                task_rate);
            end

            programsBlks=plc_find_system(task_blk,'LookUnderMasks','on','SearchDepth',1,'PLCPOUType','Program');

            if~isempty(programsBlks)
                for prgIndex=1:size(programsBlks,1)
                    program=programsBlks{prgIndex};
                    obj.parseProgram(program);
                end
            end
        end

        function parseProgram(obj,progBlk)
            progIR=obj.generatePouIR(progBlk);
            if~isempty(obj.TaskIR)
                obj.TaskIR.appendProgram(progIR);
            end
        end

        function parseAOIRunner(obj,aoiRunnerblk)
            pouInfo=slplc.api.getPOU(aoiRunnerblk);
            aoiBlk=plc_find_system(pouInfo.LogicBlock,'LookUnderMasks','on','SearchDepth',1,'PLCPOUType',obj.LadderAOIPOUType);

            if~isempty(aoiBlk)
                assert(length(aoiBlk)==1,'Assert AOI Runner block should have only one AOI function block');
                obj.parseAOI(aoiBlk);
            end
        end

        function parseAOI(obj,aoiBlk)
            obj.generatePouIR(aoiBlk);
        end

        function out=generatePouIR(obj,currentPOUPath)
            import plccore.frontend.model.POUParser;
            obj.POUParserObj=POUParser(currentPOUPath,obj.Ctx);
            out=obj.POUParserObj.startParsing();
        end

        function generateGlobalDataIR(obj,configurationPath)
            import plccore.frontend.ModelParser;
            if isempty(configurationPath)
                return;
            end
            if obj.Debug
                fprintf('Generating IR for global variables in block : %s\n',configurationPath);
            end
            controllerInfo=slplc.api.getPOU(configurationPath);
            globalVars=controllerInfo.VariableList;

            ModelParser.generateDataIR(globalVars,obj.Ctx,[]);
        end

    end

    methods(Static)
        function[out,pouInfo]=isLadderBlock(SubsystemBlk)
            out=false;
            pouInfo='';
            import plccore.frontend.ModelParser;
            if ModelParser.isSubsystemBlock(SubsystemBlk)
                pouInfo=slplc.api.getPOU(SubsystemBlk);
                if~isempty(pouInfo.PLCBlockType)
                    out=true;
                end
            end
        end

        function[out,pouInfo]=isProgramBlk(SubsystemBlk)
            out=false;
            pouInfo='';
            import plccore.frontend.ModelParser;
            if ModelParser.isSubsystemBlock(SubsystemBlk)
                pouInfo=slplc.api.getPOU(SubsystemBlk);
                if ismember(pouInfo.PLCPOUType,{'Program'})
                    out=true;
                end
            end
        end

        function[out,pouInfo]=isAOIBlk(SubsystemBlk)
            out=false;
            pouInfo='';
            import plccore.frontend.ModelParser;
            if ModelParser.isSubsystemBlock(SubsystemBlk)
                pouInfo=slplc.api.getPOU(SubsystemBlk);
                if ismember(pouInfo.PLCPOUType,{'Function Block'})
                    out=true;
                end
            end
        end

        function[out,pouInfo]=isControllerBlk(SubsystemBlk)
            out=false;
            pouInfo='';
            import plccore.frontend.ModelParser;
            if ModelParser.isSubsystemBlock(SubsystemBlk)
                pouInfo=slplc.api.getPOU(SubsystemBlk);
                if ismember(pouInfo.PLCPOUType,{'PLC Controller'})
                    out=true;
                end
            end

        end

        function out=isSubsystemBlock(blk)
            out=false;
            type=get_param(blk,'Type');

            if strcmpi(type,'block')
                blockType=get_param(blk,'BlockType');
                if strcmpi(blockType,'SubSystem')
                    out=true;
                end
            end
        end

        function out=getBlockType(blk)
            out=get_param(blk,'Type');

            if strcmpi(out,'block')
                out=get_param(blk,'BlockType');
            end
        end

        function out=isModel(blkPath)
            out=false;

            try
                modelName=bdroot(blkPath);
            catch
                error('PLC:ladderExport:InvalidInput',[blkPath...
                ,'is not a simulink model or block path']);
            end
            if strcmpi(modelName,blkPath)
                out=true;
            end
        end

        function tf=isAOI(aoiName)
            import plccore.frontend.ModelParser;
            if~isempty(ModelParser.getMLVarFromWS(['FB_',aoiName]))
                tf=true;
            else
                tf=false;
            end
        end

        function out=getMLVarFromWS(varName,ws)
            if nargin==1
                ws='base';
            end

            var=evalin(ws,['whos (''',varName,''')']);
            if isempty(var)
                out=[];
            else
                out=evalin('base',varName);
            end

        end

        function ctx=createContext()
            import plccore.common.Context;
            ctx=Context;
        end

        function fb=createFunctionBlock(fbName,ctx)
            fb=ctx.configuration.createFunctionBlock(fbName);
        end

        function plcType=getTypefromTypeName(typeName,ctx)


            typeName=regexprep(typeName,'^BUS:','','ignorecase');
            typeName=strtrim(typeName);

            plcType=plccore.frontend.ML2IRTypeMap.map(upper(typeName));
            if isempty(plcType)
                if ctx.configuration.globalScope.hasSymbol(typeName)
                    sym=ctx.configuration.globalScope.getSymbol(typeName);
                    if isa(sym,'plccore.common.FunctionBlock')
                        import plccore.type.POUType;
                        plcType=POUType(sym);
                    else
                        assert(isa(sym,'plccore.type.NamedType'));
                        plcType=sym;
                    end
                elseif ctx.builtinScope.hasSymbol(typeName)
                    plcType=ctx.builtinScope.getSymbol(typeName);
                else

                    import plccore.frontend.ModelParser;
                    plcType=ModelParser.generateTypeIRfromBus(ctx,typeName);
                    assert(~isempty(plcType),...
                    [typeName,' : Ladder type bus cannot be found in base workspace']);

                end
            end
        end

        function plcType=generateTypeIRfromBus(ctx,ladderTypeName)
            Debug=plcfeature('PLCLadderDebug');


            import plccore.frontend.ModelParser;
            import plccore.type.ArrayType;
            busObj=ModelParser.getMLVarFromWS(ladderTypeName,'base');
            if isempty(busObj)
                import plccore.common.plcThrowError;
                plcThrowError('plccoder:plccore:UnsupportedTypeForCodeGen',ladderTypeName);
            end

            if ModelParser.isAOI(ladderTypeName)
                aoiFBObj=ModelParser.getMLVarFromWS(['FB_',ladderTypeName]);

                fbIR=ModelParser.createFunctionBlock(ladderTypeName,ctx);

                if Debug
                    fprintf('Generated vars for AOI : %s\n',ladderTypeName);
                end
                ModelParser.generateDataIR(aoiFBObj.VariableList,ctx,fbIR);
                ModelParser.incompleteAOIListObj.insertAOI(fbIR.name);
                import plccore.type.POUType;
                plcType=POUType(fbIR);
            else
                busObj=evalin('base',ladderTypeName);

                if~isa(busObj,'Simulink.Bus')
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:UnsupportedTypeForCodeGen',ladderTypeName);
                end

                busElementNames=cell(1,length(busObj.Elements));
                busElementTypes=cell(1,length(busObj.Elements));
                for busElementIndex=1:length(busObj.Elements)
                    busElement=busObj.Elements(busElementIndex);
                    name=busElement.Name;
                    dims=busElement.Dimensions;
                    datatypeStr=busElement.DataType;

                    datatypeIR=ModelParser.getTypefromTypeName(datatypeStr,ctx);
                    if ischar(dims)
                        dims=str2double(dims);
                    end
                    if isscalar(dims)
                        if dims~=1
                            datatypeIR=plccore.type.ArrayType(dims,datatypeIR);
                        end
                    else
                        datatypeIR=plccore.type.ArrayType(dims,datatypeIR);
                    end

                    busElementNames{busElementIndex}=name;
                    busElementTypes{busElementIndex}=datatypeIR;
                end
                busTypeIR=plccore.type.StructType(busElementNames,busElementTypes);
                plcType=ctx.configuration.globalScope.createNamedType(ladderTypeName,busTypeIR);
                if Debug
                    fprintf('Generated vars for bus : %s\n',ladderTypeName);
                end
            end
        end

        function generateDataIR(variableList,ctx,pou)
            import plccore.type.ArrayType;
            import plccore.frontend.ModelParser;

            nParam=0;
            nLocals=0;
            for ii=1:length(variableList)
                currVar=variableList(ii);

                if strcmpi(currVar.Scope,'External')&&~isempty(pou)

                    return;
                end
                if strcmpi(currVar.DataType,'Inherit: auto')
                    currVar.DataType='BOOL';
                end

                plcType=ModelParser.getTypefromTypeName(currVar.DataType,ctx);
                [dimList,OK]=str2num(currVar.Size);%#ok<ST2NM>
                assert(OK,['Variable ''',currVar.Name,''' size should be convertible to MATLAB array, however present value : ''',currVar.Size,''' is not']);
                if isscalar(dimList)
                    if dimList==1
                        varTypeIR=plcType;
                    else
                        varTypeIR=plccore.type.ArrayType(dimList,plcType);
                    end
                else
                    varTypeIR=plccore.type.ArrayType(dimList,plcType);
                end

                if strcmp(currVar.PortType,'Hidden')
                    required=false;
                else
                    required=true;
                end
                visible=true;

                varScopeIR=ModelParser.getScopeIR(currVar.Scope,ctx,pou);

                if any(strcmp(varScopeIR.name,{'Input','InOut','Output'}))
                    nParam=nParam+1;
                    param_index=nParam;
                elseif strcmp(varScopeIR.name,'Local')
                    nLocals=nLocals+1;
                    param_index=nLocals;
                else
                    param_index=[];
                end

                if~ismember(currVar.Name,varScopeIR.getSymbolNames)
                    varIR=varScopeIR.createVar(currVar.Name,varTypeIR,'',required,visible,param_index);
                else
                    varIR=varScopeIR.getSymbol(currVar.Name);
                end


                try

                    if isa(pou,'plccore.common.FunctionBlock')&&...
                        (strcmp(currVar.Name,'EnableIn')||...
                        strcmp(currVar.Name,'EnableOut'))
                        continue;
                    end
                    if isa(varTypeIR,'plccore.type.POUType')
                        initialValue=evalin('base',['FB_',varTypeIR.pou.name,'.InitialValue']);
                    else
                        initialValue=evalin('base',currVar.InitialValue);
                    end
                catch
                    error('PLC:LadderExport:InitialValue',...
                    'Initial value for variable %s cannot be evaluated',currVar.Name);
                end
                if~strcmpi(currVar.Scope,'InOut')
                    import plccore.type.TypeTool;
                    if~(TypeTool.isIntegerType(varTypeIR)||TypeTool.isRealType(varTypeIR)||TypeTool.isBoolType(varTypeIR))...
                        &&(isscalar(initialValue)&&~isstruct(initialValue))...
                        &&initialValue==0

                    else
                        import plccore.visitor.InitialValueIRGenFromTypeVisitor;
                        ivGen=InitialValueIRGenFromTypeVisitor;
                        initialValueIR=varTypeIR.accept(ivGen,initialValue);
                        varIR.setInitialValue(initialValueIR);
                    end
                end

                if~ismember(varIR.name,{'EnableIn','EnableOut'})&&varIR.required&&~isempty(pou)
                    argList=pou.argList;
                    pou.setArgList([argList,{varIR.name}]);
                end
            end
        end

        function out=getVarFromIR(varName,ctx,pou)
            inputScope=pou.inputScope;
            outputScope=pou.outputScope;
            localScope=pou.localScope;
            globalscope=ctx.configuration.globalScope;



            out=getSymbol(localScope,varName);
            if~isempty(out)
                return;
            end

            out=getSymbol(outputScope,varName);
            if~isempty(out)
                return;
            end

            out=getSymbol(inputScope,varName);
            if~isempty(out)
                return;
            end

            if isa(pou,'plccore.common.Program')

                out=getSymbol(globalscope,varName);
                if~isempty(out)
                    return;
                end
            end

            error('PLC:ladder2IR:varNotFoundInIR',...
            'Variable not found in any local, input, output or global scopes');

            function out=getSymbol(scope,fvarName)
                out=[];
                fscopeVarNames=scope.getSymbolNames;
                if any(contains(fscopeVarNames,fvarName))
                    fsymName=fscopeVarNames{contains(fscopeVarNames,fvarName)};
                    out=scope.getSymbol(fsymName);
                    return;
                end
            end
        end

        function scopeIR=getScopeIR(scopeName,ctx,pou)
            if isempty(pou)
                scopeIR=ctx.configuration.globalScope;
            else
                switch(upper(scopeName))
                case 'LOCAL'
                    scopeIR=pou.localScope;
                case 'INPUT'
                    scopeIR=pou.inputScope;
                case 'OUTPUT'
                    scopeIR=pou.outputScope;
                case 'INOUT'
                    scopeIR=pou.inOutScope;
                case 'EXTERNAL'
                    scopeIR=ctx.configuration.globalScope;
                case 'GLOBAL'
                    scopeIR=ctx.configuration.globalScope;
                otherwise

                    assert(false,'Invalid scope name specified, possibly invalid model file');
                end
            end
        end

        function out=incompleteAOIListObj(incompleteAOIListObj)

            persistent Var;
            if isempty(Var)
                Var=plccore.frontend.model.IncompleAOIList;
            end

            if nargin
                Var=incompleteAOIListObj;
            end
            out=Var;
        end

        function[task_name,task_rate,task_priority,task_watchdog,task_desc]=getTaskBlockInfo(task_blk)
            task_name=get_param(task_blk,'Name');
            task_rate=get_param(task_blk,'SystemSampleTime');
            task_watchdog=get_param(task_blk,'PLCTaskWatchDog');
            if isempty(task_rate)||strcmpi(task_rate,'-1')
                task_rate='';
            else
                task_rate=num2str(str2num(task_rate)*1000);%#ok<ST2NM>
            end
            task_priority=get_param(task_blk,'Priority');
            if isempty(task_priority)||strcmpi(task_priority,'-1')
                task_priority='10';
            end

            task_desc=get_param(task_blk,'Description');
        end

        function tf=isTBEnabled(modelName,ladderBlock)
            plcprivate('plc_configcomp_attach',modelName,ladderBlock);
            configSetObj=plcprivate('plc_options',modelName);
            gentb=get(configSetObj,'GenerateTestbench');

            if strcmpi(gentb,'on')
                tf=true;
            else
                tf=false;
            end
        end
    end


end






