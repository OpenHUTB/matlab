classdef ModelEmitter<plccore.visitor.AbstractVisitor



    properties(Constant)
        LadderLibProgramBlock='studio5000_plclib/Program'
        LadderLibRungTermBlock='studio5000_plclib/Rung Terminal'
        LadderLibRungJunctionBlock='studio5000_plclib/Junction'
        LadderLibAOIBlock='studio5000_plclib/Function Block (AOI)'
        LadderLibRoutineBlock='studio5000_plclib/Subroutine'
        LadderLibControllerBlock='studio5000_plclib/PLC Controller'
        LadderLibTaskBlock='studio5000_plclib/Task'
        LadderLibVarReadBlock='studio5000_plclib/Variable Read'
        LadderLibVarWriteBlock='studio5000_plclib/Variable Write'
        LadderLibJMPBlock='studio5000_plclib/JMP'
        LadderLibLBLBlock='studio5000_plclib/LBL'
        LadderLibUnknownBlock='studio5000_corelib/UNKNOWN'
        LadderLib='studio5000_plclib'
        LadderCoreLib='studio5000_corelib'
        RowMaxCount=int32(5)
        RowMaxTaskCount=int32(3)
        ModelGenerationStatus='PLCModelGenerationStatus'
    end

    properties(Access=protected)
MdlBusDefineScriptName
MdlBusClearScriptName
MainMdlName
ModuleMdlName
AOIBlockMap
ProgramBlockMap
ControllerBlock
SLRequirementParam
UnsupportedInstructions
    end

    properties(Access=protected)
ctx
cfg
analyzer
initval_visitor
has_bus_type
txtWriterBusDefine
txtWriterBusClear
saveDir
start_x0
start_y0
current_pou_blk
current_pou_routineType
current_pou_IR
current_pou_power_start_blk
commentHandler
    end

    methods(Static)
        function closeModelFile(mdl_name)
            if bdIsLoaded(mdl_name)
                bdclose(mdl_name);
            end
        end

        function[x0,y0,x1,y1]=blockPosition(blk)
            blk_pos=get_param(blk,'Position');
            x0=blk_pos(1);
            y0=blk_pos(2);
            x1=blk_pos(3);
            y1=blk_pos(4);
        end

        function[width,height]=blockSize(blk)
            import plccore.visitor.*;
            [x0,y0,x1,y1]=ModelEmitter.blockPosition(blk);
            width=x1-x0;
            height=y1-y0;
        end

        function constExprNew=incrementConstExprValue(constExprArrIndex)
            type=constExprArrIndex.value.type;
            value=constExprArrIndex.value.value;

            newValue=num2str(str2double(value)+1);

            import plccore.expr.ConstExpr;
            import plccore.common.ConstValue;
            constExprNew=ConstExpr(ConstValue(type,newValue));
        end

        function multilineText=splitStringToMultiLine(str)
            maxCharPerLine=30;
            numChunks=ceil(length(str)/maxCharPerLine);
            multilineCell=cell(1,numChunks);
            for ii=1:numChunks
                startIndex=(ii-1)*maxCharPerLine+1;
                endIndex=min((ii)*maxCharPerLine,length(str));
                multilineCell{ii}=str(startIndex:endIndex);
            end
            multilineText=strjoin(multilineCell,newline);
        end
    end

    methods
        function obj=ModelEmitter(ctx)
            import plccore.visitor.*;
            obj@plccore.visitor.AbstractVisitor;
            obj.Kind='ModelEmitter';
            obj.ctx=ctx;
            obj.cfg=ctx.getPLCConfigInfo;
            obj.has_bus_type=false;
            obj.txtWriterBusDefine=plccore.util.TxtWriter;
            obj.txtWriterBusClear=plccore.util.TxtWriter;
            obj.AOIBlockMap=obj.createPOUBlockMap;
            obj.ProgramBlockMap=obj.createPOUBlockMap;
            obj.showDebugMsg;
        end

        function ret=generateModel(obj)
            obj.disableSLRequirementCheck;
            obj.createAnalyzer;
            obj.analyzer.doit;
            obj.generateBusType;

            obj.setupModel;
            add_param(obj.ModuleMdlName,obj.ModelGenerationStatus,'LibraryGeneation');
            add_param(obj.MainMdlName,obj.ModelGenerationStatus,'ModelGeneration');

            obj.generateModelInternal;

            obj.runConfigBeforeMdlCompile;


            set_param(obj.MainMdlName,obj.ModelGenerationStatus,'ModelUpdate');
            set_param(obj.MainMdlName,'UnconnectedInputMsg','none');
            set_param(obj.MainMdlName,'UnconnectedOutputMsg','none');
            set_param(obj.MainMdlName,'InheritedTsInSrcMsg','none');
            set_param(obj.MainMdlName,'ParameterPrecisionLossMsg','none');
            set_param(obj.MainMdlName,'ParameterOverflowMsg','none');

            slplc.api.loadDataTypes;
            try
                set_param(obj.MainMdlName,'SimulationCommand','Update');
            catch ME
                if strcmp(ME.identifier,'Simulink:Bus:SigHierPropSrcDstMismatchNonBusSrc')||...
                    strcmp(ME.identifier,'Simulink:Bus:BusTypePropSrcDstMismatchBusSrc')
                    set_param(obj.MainMdlName,'SimulationCommand','Update');
                else
                    rethrow(ME);
                end
            end

            set_param(obj.MainMdlName,'ParameterOverflowMsg','error');
            set_param(obj.MainMdlName,'ParameterPrecisionLossMsg','warning');
            set_param(obj.MainMdlName,'InheritedTsInSrcMsg','warning');
            set_param(obj.MainMdlName,'UnconnectedOutputMsg','warning');
            set_param(obj.MainMdlName,'UnconnectedInputMsg','warning');

            plcprivate('plc_configcomp_attach',obj.MainMdlName);
            configSetObj=plcprivate('plc_options',obj.MainMdlName);
            set(configSetObj,'TargetIDE','studio5000');


            delete_param(obj.ModuleMdlName,obj.ModelGenerationStatus)
            delete_param(obj.MainMdlName,obj.ModelGenerationStatus)

            if~isempty(obj.cfg.sampleTime)
                plcladderoption(obj.MainMdlName,'SampleTime',obj.cfg.sampleTime);
            end

            if obj.cfg.disableCallbacks
                plcladderoption(obj.MainMdlName,'Callbacks','off');
            end

            obj.runConfigAfterMdlCompile;
            obj.displayUnsupportedBlocks;
            obj.saveModel;
            obj.analyzer.generateDependencyFile;
            obj.generateAOIBlockListFile;
            ret=obj.MainMdlName;
            obj.restoreSLRequirementCheck;
        end

        function displayUnsupportedBlocks(obj)
            blocksCellArr=plc_find_system(obj.MainMdlName,'LookUnderMasks','all','FollowLinks','on','PLCBlockType','UnknownInstr');
            if~isempty(blocksCellArr)
                fprintf('Following unsupported instructions were generated. Please open the model before using the below hyperlink :\n');
            end
            for ii=1:length(blocksCellArr)
                blkName=get_param(blocksCellArr{ii},'Name');
                fprintf('<a href="matlab:hilite_system(''%s'')">%s</a>\n',blocksCellArr{ii},blkName);
            end
            obj.UnsupportedInstructions=blocksCellArr;
        end

        function ret=busDefineScriptName(obj)
            ret=[];
            if~isempty(obj.MdlBusDefineScriptName)
                [~,filename,ext]=fileparts(obj.MdlBusDefineScriptName);
                ret=[filename,ext];
            end
        end

        function ret=busClearScriptName(obj)
            ret=obj.MdlBusClearScriptName;
        end

        function ret=modelLibraryName(obj)
            ret=obj.ModuleMdlName;
        end

        function ret=unsupportedInstructions(obj)
            ret=obj.UnsupportedInstructions;
        end

        function ret=checkPOUBlockMap(obj,pou,pou_blk_map)%#ok<INUSL>
            assert(pou_blk_map.isKey(pou.name));
            ret=pou_blk_map(pou.name);
        end

        function ret=getPOUBlock(obj,pou)
            switch pou.kind
            case 'Program'
                ret=obj.checkPOUBlockMap(pou,obj.ProgramBlockMap);
            case 'FunctionBlock'
                ret=obj.checkPOUBlockMap(pou,obj.AOIBlockMap);
            case 'Routine'
                ret=obj.checkPOUBlockMap(pou,pou.program.tag);
            otherwise
                assert(false);
            end
        end
    end

    methods(Access=protected)
        function createAnalyzer(obj)
            import plccore.visitor.*;
            obj.analyzer=ContextAnalyzer(obj.ctx);
        end

        function ret=getSLAliasTypeName(obj,type)%#ok<INUSL>
            import plccore.visitor.SLAliasTypeVisitor;
            sltv=SLAliasTypeVisitor;
            ret=type.accept(sltv,[]);
        end

        function ret=getSLValue(obj,var,value)%#ok<INUSL>
            import plccore.type.*;
            import plccore.util.*;
            import plccore.visitor.SLValueVisitor;
            type=var.type;
            if TypeTool.isNamedStructType(type)||TypeTool.isArrayType(type)||TypeTool.isPOUType(type)
                ret=var.tag;
                return;
            end

            val_type=GetSLTypeName(var.type);
            if isempty(value)
                val='0';
            else
                slvv=SLValueVisitor;
                val=value.accept(slvv,[]);
            end
            ret=sprintf('%s(%s)',val_type,val);
        end

        function generateBusElement(obj,bus_name,name,type)
            txt=sprintf('elem = Simulink.BusElement;');
            obj.txtWriterBusDefine.writeLine(txt);
            txt=sprintf('elem.Name = ''%s'';',name);
            obj.txtWriterBusDefine.writeLine(txt);
            txt=sprintf('elem.DataType = ''%s'';',plccore.util.GetSLTypeName(type));
            obj.txtWriterBusDefine.writeLine(txt);
            dim_sz=1;
            if isa(type,'plccore.type.ArrayType')
                dim_sz=type.dims;
            end
            txt=sprintf('elem.Dimensions = %d;',dim_sz);
            obj.txtWriterBusDefine.writeLine(txt);
            txt=sprintf('%s.Elements(end+1) = elem;',bus_name);
            obj.txtWriterBusDefine.writeLine(txt);
        end

        function generateBusStructType(obj,type)
            bus_name=type.name;
            txt=sprintf('\n%s bus type for %s','%%',bus_name);
            obj.txtWriterBusDefine.writeLine(txt);
            txt=sprintf('%s = Simulink.Bus;',bus_name);
            obj.txtWriterBusDefine.writeLine(txt);
            txt=sprintf('clear %s;',bus_name);
            obj.txtWriterBusClear.writeLine(txt);
            type=type.type;
            for i=1:type.numFields
                field_name=type.fieldName(i);
                field_type=type.fieldType(i);
                obj.generateBusElement(bus_name,field_name,field_type);
            end
        end

        function generateClear(obj)
            txt=sprintf('\nclear elem;');
            obj.txtWriterBusDefine.writeLine(txt);
        end

        function generateBusFB(obj,fb)
            txt=sprintf('\n%s AOI bus type for %s','%%',fb.name);
            obj.txtWriterBusDefine.writeLine(txt);
            txt=sprintf('%s = Simulink.Bus;',fb.name);
            obj.txtWriterBusDefine.writeLine(txt);
            txt=sprintf('clear %s;',fb.name);
            obj.txtWriterBusClear.writeLine(txt);
            varList=fb.getVariableList;
            validIdx=cellfun(@(x)~fb.inOutScope.hasSymbol(x.name),varList,'UniformOutput',true);
            varList=varList(validIdx);
            for i=1:length(varList)
                if~strcmp(varList{i}.kind,'Var')
                    continue;
                end
                obj.generateBusElement(fb.name,varList{i}.name,varList{i}.type);
            end
        end

        function ret=pruneBuiltinBusType(obj,type_list)
            ret={};
            for i=1:length(type_list)
                type=type_list{i};
                if obj.ctx.builtinScope.hasSymbol(type.name)
                    continue;
                end
                ret{end+1}=type;%#ok<AGROW>
            end
        end

        function generateBusType(obj)
            import plccore.type.TypeTool;
            type_list=obj.analyzer.sortedTypeList;
            type_list=obj.pruneBuiltinBusType(type_list);
            if isempty(type_list)
                return;
            end

            obj.has_bus_type=true;
            for i=1:length(type_list)
                type=type_list{i};
                if TypeTool.isNamedType(type)
                    obj.generateBusStructType(type);
                else
                    assert(isa(type,'plccore.common.FunctionBlock'));
                    obj.generateBusFB(type);
                end
            end
            obj.generateClear;
            plccfg=obj.ctx.getPLCConfigInfo;
            obj.txtWriterBusDefine.writeFile(plccfg.fileDir,plccfg.L5XBusDefineFileName);
            obj.txtWriterBusClear.writeFile(plccfg.fileDir,plccfg.L5XBusClearFileName);
            obj.MdlBusDefineScriptName=fullfile(plccfg.fileDir,plccfg.L5XBusDefineFileName);
            obj.MdlBusClearScriptName=fullfile(plccfg.fileDir,plccfg.L5XBusClearFileName);
            bus_file=plccfg.L5XBusDefineFileName;
            evalin('base',sprintf('%s',bus_file(1:end-2)));
        end

        function checkCreateMdl(obj,mdl_name)
            obj.closeModelFile(mdl_name);
            mdl_file=[mdl_name,'.slx'];
            if exist(mdl_file,'file')
                delete(mdl_file);
            end
            new_system(mdl_name);
            if obj.cfg.openModel
                if strcmp(mdl_name,obj.ModuleMdlName)&&~obj.cfg.keepLibModel

                    return;
                end
                open_system(mdl_name);
            end
        end

        function setupModel(obj)
            obj.loadLadderTypes;
            plccfg=obj.cfg;
            obj.saveDir=cd(plccfg.fileDir);
            obj.MainMdlName=plccfg.L5XModelName;
            obj.ModuleMdlName=plccfg.L5XModuleModelName;
            obj.checkCreateMdl(obj.MainMdlName);
            obj.checkCreateMdl(obj.ModuleMdlName);


            import plccore.visitor.*;
            obj.initval_visitor=ModelInitialValueVisitor(obj.ctx,obj);
            obj.initval_visitor.doit;
            if obj.initval_visitor.hasInitialValue
                evalin('base',sprintf('load %s;',obj.cfg.MdlDataMATFileName));
            end

            obj.setupLoadCloseCallbacks;
        end

        function setupLoadCloseCallbacks(obj)
            obj.setupCallbackFcn(obj.MainMdlName,'PreLoadFcn','plcloadtypes;');
            obj.setupCallbackFcn(obj.ModuleMdlName,'PreLoadFcn','plcloadtypes');

            if obj.initval_visitor.hasInitialValue
                obj.setupCallbackFcn(obj.MainMdlName,'PreLoadFcn',sprintf('load %s;',obj.cfg.MdlDataMATFileName));
                obj.setupCallbackFcn(obj.MainMdlName,'CloseFcn',sprintf('clear %s;',obj.cfg.MdlDataStructName));
            end

            if obj.has_bus_type
                obj.setupBusTypeLoadCloseCallbacks;
            end
        end

        function setupBusTypeLoadCloseCallbacks(obj)
            plccfg=obj.ctx.getPLCConfigInfo;
            bus_file=plccfg.L5XBusDefineFileName;
            obj.setupCallbackFcn(obj.MainMdlName,'PreLoadFcn',sprintf('%s;',bus_file(1:end-2)));
            bus_file=plccfg.L5XBusClearFileName;
            obj.setupCallbackFcn(obj.MainMdlName,'CloseFcn',sprintf('%s;',bus_file(1:end-2)));
        end

        function setupCallbackFcn(obj,modelName,callbackFcnName,commands)%#ok<INUSL>
            existingComms=get_param(modelName,callbackFcnName);
            if isempty(existingComms)
                set_param(modelName,callbackFcnName,commands);
            else
                commandsNew=[existingComms,newline,commands];
                set_param(modelName,callbackFcnName,commandsNew);
            end
        end

        function saveModel(obj)
            import plccore.visitor.ModelEmitter;
            if obj.cfg.openModel
                if obj.cfg.keepLibModel
                    open_system(obj.ModuleMdlName);
                end
                open_system(obj.MainMdlName);
            end
            save_system(obj.MainMdlName);
            if obj.cfg.keepLibModel
                save_system(obj.ModuleMdlName);
            end
            if obj.cfg.openModel
                if~obj.cfg.keepLibModel
                    ModelEmitter.closeModelFile(obj.ModuleMdlName);
                end
                return;
            end

            ModelEmitter.closeModelFile(obj.LadderLib);
            ModelEmitter.closeModelFile(obj.MainMdlName);
            ModelEmitter.closeModelFile(obj.ModuleMdlName);
            ModelEmitter.closeModelFile(obj.LadderCoreLib);
            cd(obj.saveDir);
        end

        function ret=getBlock(obj,owner_blk,blk_type)%#ok<INUSL>
            blk=plc_find_system(owner_blk,'SearchDepth',1,'LookUnderMasks','all',...
            'FollowLinks','on','PLCBlockType',blk_type);
            assert(length(blk)==1);
            ret=blk{1};
        end

        function ret=getVarDefField(obj,var_name,field_name)%#ok<INUSL>
            ret=sprintf('PLCVar%s%s',var_name,field_name);
        end

        function ret=getVarDefFieldValue(obj,var_table_blk,var_name,field_name)
            ret=get_param(var_table_blk,obj.getVarDefField(var_name,field_name));
        end

        function setVarDefFieldValue(obj,var_table_blk,var_name,field_name,field_value)
            set_param(var_table_blk,obj.getVarDefField(var_name,field_name),field_value);
        end

        function ret=createVarDef(obj,idx,var,pou_blk,scope_name,port_type)%#ok<INUSL>
            import plccore.type.*;
            name=var.name;
            type=var.type;
            if(strcmp(scope_name,'Input')||strcmp(scope_name,'Output')||strcmp(scope_name,'InOut'))
                port_idx=num2str(idx);
            else
                port_idx='1';
            end
            data_type=obj.getSLAliasTypeName(type);
            if strcmp(type.kind,'ArrayType')
                data_sz=sprintf('[%s]',num2str(type.dims));
            else
                data_sz='1';
            end

            init_val=obj.getSLValue(var,var.initialValue);

            isFBInstance=plccore.type.TypeTool.isFunctionBlockPOUType(type);
            ret=slplc.api.createVariable(name,...
            'Scope',scope_name,...
            'PortType',port_type,...
            'PortIndex',port_idx,...
            'DataType',data_type,...
            'Size',data_sz,...
            'InitialValue',init_val,...
            'IsFBInstance',isFBInstance,...
            'IsAutoImport',1);
        end

        function ret=createScopeVarDef(obj,scope,pou_blk,scope_name,port_type,argList)
            ret=[];
            name_list=scope.getSymbolNames;
            port_index=0;
            for i=1:length(name_list)
                name=name_list{i};
                sym=scope.getSymbol(name);
                switch sym.kind
                case 'Var'
                    if strcmpi(scope_name,'Global')||strcmpi(scope_name,'Local')

                        port_index=1;
                    elseif strcmpi(scope_name,'Output')
                        if strcmpi(sym.name,'EnableOut')

                            port_index=1;
                        elseif~sym.required


                        else
                            port_index=port_index+1;
                        end
                    elseif strcmpi(scope_name,'InOut')||strcmpi(scope_name,'Input')
                        if strcmpi(sym.name,'EnableIn')

                            port_index=1;
                        elseif~sym.required


                        else


                            assert(~isempty(argList),['Input/Inout scope variable : ',name,' exists but argList is empty']);
                            assert(iscell(argList)&&size(argList,2)>0,['Input/Inout scope variable : ',name,' exists but argList is not a cell array of varNames']);
                            assert(any(strcmp(argList,name)),['Input/Inout scope variable : ',name,' not found in arglist:',strjoin(argList,',')]);
                            port_index=find(strcmp(argList,name))+1;
                        end
                    else
                        assert(false,'scope_name should be one of input,output, inout or global');
                    end

                    var=obj.createVarDef(port_index,sym,pou_blk,scope_name,port_type);

                    if~sym.required&&...
                        ~ismember(sym.name,{'EnableIn','EnableOut'})
                        var.PortType='Hidden';
                    end

                    if isempty(ret)
                        ret=var;
                    else
                        ret(end+1)=var;%#ok<AGROW>
                    end

                case{'Program','FunctionBlock','Routine','AliasInfo'}

                otherwise

                    if obj.debug==10
                        fprintf('skip symbol %s:%s in %s\n',sym.name,sym.kind,scope.name);
                    end
                end
            end
        end

        function cleanupVarTableMask(obj,var_table_blk)%#ok<INUSL>
            maskObj=Simulink.Mask.get(var_table_blk);
            propertyNum=8;
            varNum=round(numel(maskObj.Parameters)/propertyNum);
            for varCount=1:varNum
                nameParamIdx=(varCount-1)*propertyNum+1;
                scopeIdx=nameParamIdx+1;
                portTypeIdx=nameParamIdx+2;
                portIndexIdx=nameParamIdx+3;
                dataTypeIdx=nameParamIdx+4;
                dataSizeIdx=nameParamIdx+5;
                initValueIdx=nameParamIdx+6;
                maskObj.Parameters(scopeIdx).ReadOnly='off';
                maskObj.Parameters(portTypeIdx).ReadOnly='off';
                maskObj.Parameters(portIndexIdx).ReadOnly='off';
                maskObj.Parameters(dataTypeIdx).ReadOnly='off';
                maskObj.Parameters(dataSizeIdx).ReadOnly='off';
                maskObj.Parameters(initValueIdx).ReadOnly='off';
            end
        end

        function ret=createPOUVarDef(obj,pou,pou_blk)
            ret=[];
            if isa(pou,'plccore.common.Routine')
                return;
            end
            if strcmp(pou.Kind,'FunctionBlock')
                variableList=pou.getVariableList;
                port_index=0;
                nOutports=1;
                nInports=1;
                for i=1:length(variableList)
                    name=variableList{i}.name;
                    if pou.inputScope.hasSymbol(name)
                        scope_name='Input';
                        port_type='Inport';
                    elseif pou.inOutScope.hasSymbol(name)
                        scope_name='InOut';
                        port_type='Inport';
                    elseif pou.outputScope.hasSymbol(name)
                        scope_name='Output';
                        port_type='Outport';
                    else
                        scope_name='Local';
                        port_type='Hidden';
                    end
                    switch scope_name
                    case 'Output'
                        if strcmpi(name,'EnableOut')

                            port_index=1;
                        elseif variableList{i}.required
                            nOutports=nOutports+1;
                            port_index=nOutports;
                        end
                    case{'InOut','Input'}
                        if strcmpi(name,'EnableIn')

                            port_index=1;
                        elseif variableList{i}.required
                            nInports=nInports+1;
                            port_index=nInports;
                        end
                    otherwise
                        port_index=1;
                    end

                    var=obj.createVarDef(port_index,variableList{i},pou_blk,scope_name,port_type);

                    if~variableList{i}.required&&...
                        ~ismember(name,{'EnableIn','EnableOut'})
                        var.PortType='Hidden';
                    end

                    if isempty(ret)
                        ret=var;
                    else
                        ret(end+1)=var;%#ok<AGROW>
                    end
                end
            else
                argList=pou.argList;
                l1=obj.createScopeVarDef(pou.inputScope,pou_blk,'Input','Inport',argList);
                l2=obj.createScopeVarDef(pou.inOutScope,pou_blk,'InOut','Inport',argList);
                l3=obj.createScopeVarDef(pou.outputScope,pou_blk,'Output','Outport',argList);
                l4=obj.createScopeVarDef(pou.localScope,pou_blk,'Local','Hidden',argList);
                ret=[l1,l2,l3,l4];
            end
        end

        function ret=createControllerVarDef(obj)
            ret=obj.createScopeVarDef(obj.ctx.configuration.globalScope,obj.ControllerBlock,'Global','Hidden',[]);
        end

        function ret=getPOUImplementation(obj,pou,routineType)%#ok<INUSL>
            switch pou.kind
            case 'Program'
                if~pou.hasMainRoutine
                    ret=[];
                    return;
                end
                ret=pou.mainRoutine.impl;
            case{'FunctionBlock'}
                switch routineType
                case plccore.util.RoutineTypes.logic
                    if~pou.hasLogicRoutine
                        ret=[];
                        return;
                    end
                    ret=pou.logicRoutine.impl;
                case plccore.util.RoutineTypes.prescan
                    if~pou.hasPrescanRoutine
                        ret=[];
                        return;
                    end
                    ret=pou.prescanRoutine.impl;
                case plccore.util.RoutineTypes.enableInFalse
                    if~pou.hasEnableInFalseRoutine
                        ret=[];
                        return;
                    end
                    ret=pou.enableInFalseRoutine.impl;
                otherwise
                    assert(false,'Rockwell targets only permit ''Logic'', ''EnableInFalse'', ''Prescan'' routines for AOIs');
                end
            case 'Routine'
                ret=pou.impl;
            otherwise
                assert(false);
            end
        end

        function ret=getPOULibBlock(obj,pou)
            switch pou.kind
            case 'Program'
                ret=obj.LadderLibProgramBlock;
            case 'FunctionBlock'
                ret=obj.LadderLibAOIBlock;
            case 'Routine'
                ret=obj.LadderLibRoutineBlock;
            otherwise
                assert(false);
            end
        end

        function ret=getPOUBlockRoutinePath(obj,pou_blk,routineType)%#ok<INUSL>
            if nargin==2
                ret=slplc.utils.getInternalBlockPath(pou_blk,'Logic');
                return;
            end
            switch routineType
            case plccore.util.RoutineTypes.logic
                ret=slplc.utils.getInternalBlockPath(pou_blk,'Logic');
            case plccore.util.RoutineTypes.prescan
                ret=slplc.utils.getInternalBlockPath(pou_blk,'Prescan');
            case plccore.util.RoutineTypes.enableInFalse
                ret=slplc.utils.getInternalBlockPath(pou_blk,'EnableInFalse');
            otherwise
                assert(false,'Rockwell targets only permit ''Logic'', ''EnableInFalse'', ''Prescan'' routines for AOIs');
            end
        end

        function enableFunctionBlockRoutine(obj,pou_blk,routineType)%#ok<INUSL>

            switch routineType
            case plccore.util.RoutineTypes.logic

            case plccore.util.RoutineTypes.prescan
                set_param(pou_blk,'PLCAllowPrescan','on');
            case plccore.util.RoutineTypes.enableInFalse
                set_param(pou_blk,'PLCAllowEnableInFalse','on');
            otherwise
                assert(false,'Rockwell targets only permit ''Logic'', ''EnableInFalse'', ''Prescan'' routines for AOIs');
            end
        end

        function ret=getCurrentPOURoutinePath(obj)
            ret=obj.getPOUBlockRoutinePath(obj.current_pou_blk,obj.current_pou_routineType);
        end

        function createPOULadder(obj,pou,pou_blk,routineType)
            obj.current_pou_routineType=routineType;
            routine_sys_path=obj.getPOUBlockRoutinePath(pou_blk,routineType);
            obj.activateSystem(routine_sys_path,true);
            obj.commentHandler=plccore.util.CommentHandler(routine_sys_path);

            rung_term_blk=obj.getBlock(routine_sys_path,'RungTerminal');
            lh=get_param(rung_term_blk,'LineHandles');
            delete_line(lh.Inport(1));
            delete_block(rung_term_blk);
            obj.getStartPosition(routine_sys_path);
            impl=obj.getPOUImplementation(pou,routineType);
            if~isempty(impl)
                obj.processLayout(impl);
                obj.generateModelBlocks(impl,pou_blk,routineType);
                if strcmpi(pou.kind,'FunctionBlock')
                    obj.enableFunctionBlockRoutine(pou_blk,routineType);
                end
            end

            var_list=obj.createPOUVarDef(pou,pou_blk);
            if~isempty(var_list)
                slplc.utils.setVariableList(pou_blk,var_list);
                var_list=slplc.utils.getVariableList(pou_blk);
                slplc.api.createPOUPorts(pou_blk,var_list);
            end
        end

        function getStartPosition(obj,owner_blk)
            import plccore.visitor.*;
            power_start_blk=obj.getBlock(owner_blk,'PowerRailStart');
            [x0,y0,~,~]=ModelEmitter.blockPosition(power_start_blk);
            [w,h]=ModelEmitter.blockSize(power_start_blk);
            obj.start_x0=x0+w+ModelLayoutVisitor.StartXOffset;
            obj.start_y0=y0+h+ModelLayoutVisitor.StartYOffset;
            obj.current_pou_power_start_blk=power_start_blk;
        end

        function pou_block=createPOUBlock(obj,pou,idx)
            import plccore.visitor.*;
            pou_block=sprintf('%s/%s',obj.ModuleMdlName,pou.name);
            pou_lib_block=obj.getPOULibBlock(pou);
            add_block(pou_lib_block,pou_block);
            [blk_wd,blk_ht]=ModelEmitter.blockSize(pou_lib_block);
            base_sz=max(blk_wd,blk_ht);
            row=idivide(idx,obj.RowMaxCount);
            col=mod(idx,obj.RowMaxCount);
            x0=base_sz/2+(base_sz+blk_wd)*col;
            y0=base_sz/2+(base_sz+blk_ht)*row;
            set_param(pou_block,'Position',double([x0,y0,x0+blk_wd,y0+blk_ht]));
            obj.current_pou_IR=pou;
            obj.current_pou_blk=pou_block;

            import plccore.util.RoutineTypes;
            switch pou.kind
            case 'Program'
                set_param(pou_block,'Name',pou.name);
                obj.createPOULadder(pou,pou_block,RoutineTypes.logic);
            case{'FunctionBlock'}
                set_param(pou_block,'PLCPOUName',pou.name);
                obj.createPOULadder(pou,pou_block,RoutineTypes.logic);
                obj.createPOULadder(pou,pou_block,RoutineTypes.enableInFalse);
                obj.createPOULadder(pou,pou_block,RoutineTypes.prescan);
            case 'Routine'
                set_param(pou_block,'PLCPOUName',pou.name);
                obj.createPOULadder(pou,pou_block,RoutineTypes.logic);
            end

        end
    end

    methods
        function ret=visitLadderDiagram(obj,host,input)%#ok<INUSD>
            ret=[];
            rungs=host.rungs;
            tag=host.tag;
            tag.PredBlock=obj.current_pou_power_start_blk;
            host.setTag(tag);
            total_count=length(rungs);
            for i=1:total_count
                if obj.debug
                    fprintf('\n--->Rung generation: #%d of %d\n',i,total_count);
                end
                rungs{i}.accept(obj,tag);
            end
        end

        function ret=visitSeqRungOp(obj,host,pred_blk)
            ret=[];
            rungops=host.rungOps;
            for i=1:length(rungops)
                rungops{i}.accept(obj,pred_blk);
                pred_blk=rungops{i}.tag.Block;
            end
            tag=host.tag;
            tag.Block=rungops{end}.tag.Block;
            host.setTag(tag);
        end

        function ret=visitLadderRung(obj,host,input)
            import plccore.visitor.*;
            ret=[];
            obj.visitSeqRungOp(host,input.PredBlock);
            pred_blk=host.tag.Block;
            rungterm_blk=add_block(obj.LadderLibRungTermBlock,[obj.getCurrentPOURoutinePath,'/RungTerm'],'MakeNameUnique','on');
            x0=input.X0+input.Width+ModelLayoutVisitor.StartXOffset;
            y0=host.tag.Y0;
            [width,height]=ModelEmitter.blockSize(rungterm_blk);
            x1=x0+width;
            y1=y0+height;
            set_param(rungterm_blk,'Position',[x0,y0,x1,y1]);
            if~isempty(host.description)
                obj.commentHandler.createComment(rungterm_blk,host.description);
            end
            blk1=[get_param(pred_blk,'Name'),'/1'];
            blk2=[get_param(rungterm_blk,'Name'),'/1'];
            add_line(obj.getCurrentPOURoutinePath,blk1,blk2,'autorouting','on');
        end

        function ret=visitRungOpAtom(obj,host,input)
            import plccore.visitor.*;
            ret=[];

            if isa(host.instr,'plccore.ladder.UnknownInstr')
                obj.generateUnknownBlock(host,input);
                return;
            end

            if ismember(host.instr.name,{'TON','TOF','RTO','CTU','CTD'})
                obj.generateTimerCounterBlocks(host,input);
                return;
            end

            if isa(host.instr,'plccore.ladder.JSRInstr')
                obj.generateJSRBlock(host,input);
                return;
            end

            if ismember(host.instr.name,{'XIC','XIO','OTE','OTL',...
                'OTU','CLR','CMP','ONS'})
                obj.generatePLCOperandTagBlock(host,input);
                return;
            end

            if ismember(host.instr.name,{'RES'})
                obj.generateRESBlock(host,input);
                return;
            end

            if ismember(host.instr.name,{'JMP','LBL'})
                obj.generateJMPLBLBlock(host,input);
                return;
            end

            argStruct=host.instr.getInstrTypeStruct;
            if isempty(argStruct)
                obj.generateStandardBlock(host,input);
            else

                obj.generateSpecialBlock(host,input);
            end

        end

        function ret=visitRungOpTimer(obj,host,input)%#ok<INUSD>
            ret=[];
            assert(false,'Error: invalid timer ir');
        end

        function ret=visitRungOpFBCall(obj,host,input)
            import plccore.visitor.*;
            ret=[];

            pou=host.pou;
            rungop_blk=add_block(obj.getPOUBlock(pou),...
            [obj.getCurrentPOURoutinePath,'/',pou.name],'MakeNameUnique','on');
            x0=host.tag.X0;
            y0=host.tag.Y0;
            width=host.tag.Width;

            if host.tag.numInputPorts>0
                x0=x0+100;
                width=width-100;
            end
            if host.tag.numOutputPorts>0
                width=width-100;
            end

            x1=x0+width;
            y1=y0+host.tag.Height;
            set_param(rungop_blk,'Position',[x0,y0,x1,y1]);
            blk1=[get_param(input,'Name'),'/1'];
            blk2=[get_param(rungop_blk,'Name'),'/1'];
            add_line(obj.getCurrentPOURoutinePath,blk1,blk2,'autorouting','on');
            set_param(rungop_blk,'PLCPOUName',host.pou.name);
            slplc.utils.setTag(rungop_blk,'PLCOperandTag',host.instance.toString);
            tag=host.tag;
            tag.Block=rungop_blk;
            host.setTag(tag);

            [inputExprs,outputExprs]=getPortExprs(obj,host);
            canvas=obj.getCurrentPOURoutinePath;
            obj.connectInputs(canvas,rungop_blk,inputExprs);
            obj.connectOutputs(canvas,rungop_blk,outputExprs);
        end

        function[inputExprs,outputExprs]=getPortExprs(obj,host)%#ok<INUSL>
            argNames=host.pou.argList;
            exprs=host.argList;
            inputExprs={};
            outputExprs={};

            for ii=1:length(argNames)

                if any(ismember(host.pou.inputScope.getSymbolNames,argNames(ii)))
                    inputExprs{end+1}=exprs{ii};%#ok<AGROW>
                elseif any(ismember(host.pou.outputScope.getSymbolNames,argNames(ii)))
                    outputExprs{end+1}=exprs{ii};%#ok<AGROW>
                elseif any(ismember(host.pou.inOutScope.getSymbolNames,argNames(ii)))
                    inputExprs{end+1}=exprs{ii};%#ok<AGROW>

                end
            end
        end

        function ret=visitRungOpPar(obj,host,input)
            import plccore.visitor.*;
            ret=[];
            assert(length(host.rungOps)>1);
            rungops=host.rungOps;
            for i=1:length(rungops)
                rungops{i}.accept(obj,input);
            end
            tag=host.tag;
            pred_rung_blk=rungops{end}.tag.Block;
            for i=length(rungops)-1:-1:1
                rungop=rungops{i};
                junction_blk=add_block(obj.LadderLibRungJunctionBlock,[obj.getCurrentPOURoutinePath,'/RungJunction'],'MakeNameUnique','on');
                x0=tag.X0+tag.Width-ModelLayoutVisitor.JunctionWidth;
                y0=rungop.tag.Y0+20;
                [width,height]=ModelEmitter.blockSize(junction_blk);
                x1=x0+width;
                y1=y0+height;
                set_param(junction_blk,'Position',[x0,y0,x1,y1]);
                blk1=[get_param(rungop.tag.Block,'Name'),'/1'];
                blk2=[get_param(junction_blk,'Name'),'/1'];
                add_line(obj.getCurrentPOURoutinePath,blk1,blk2,'autorouting','on');
                blk3=[get_param(pred_rung_blk,'Name'),'/1'];
                blk2=[get_param(junction_blk,'Name'),'/2'];
                add_line(obj.getCurrentPOURoutinePath,blk3,blk2,'autorouting','on');
                pred_rung_blk=junction_blk;
            end
            tag.Block=pred_rung_blk;
            host.setTag(tag);
        end

        function ret=visitRungOpSeq(obj,host,input)
            ret=obj.visitSeqRungOp(host,input);
            assert(~isempty(host.rungOps));
            tag=host.tag;
            tag.Block=host.rungOps{end}.tag.Block;
            host.setTag(tag);
        end
    end

    methods(Access=protected)
        function processLayout(obj,ld)
            import plccore.visitor.*;
            layout_visitor=ModelLayoutVisitor(obj,obj.start_x0,obj.start_y0);
            ld.accept(layout_visitor,[]);
        end

        function connectOutputSLBlocks(obj,canvas,rungop_blk,slBlks)

            for i=1:length(slBlks)
                blk_name=slBlks{i};
                slblk=obj.addModelBlock(['built-in/',blk_name],[canvas,'/',blk_name]);
                set_param(slblk,'ShowName','off');
                import plccore.util.SLBlockUtil;
                outportHdl=SLBlockUtil.getPort(rungop_blk,'out',i+1);
                inportHdl=SLBlockUtil.getPort(slblk,'in',1);
                SLBlockUtil.moveBlocktoPositionRelativetoPort(slblk,outportHdl,'r',20)
                SLBlockUtil.connectBlocks(canvas,outportHdl,inportHdl);
            end
        end

        function generateTimerCounterBlocks(obj,rung_op,pred_blk)
            import plccore.visitor.*;
            [rungop_blk,x0,y0,x1,y1]=addLadderInstructionBlock(obj,rung_op);

            obj.updateRungOpTagWithBlk(rung_op,rungop_blk);

            set_param(rungop_blk,'Position',[x0,y0,x1,y1]);


            obj.connectCurrentBlkToPredBlk(rungop_blk,pred_blk);

            if rung_op.instr.getNumInput==3
                obj.updatePLCOperandTagParam(rungop_blk,rung_op.inputs{1});
            end
        end

        function generateUnknownBlock(obj,rung_op,pred_blk)
            if~obj.cfg.supportUnknownInstruction
                import plccore.common.plcThrowError;
                plccore.common.plcThrowError('plccoder:plccore:UnknownInstrNotSupported',rung_op.instr.instrName,obj.current_pou_IR.name);
            end
            rungop_blk=add_block(obj.LadderLibUnknownBlock,...
            [obj.getCurrentPOURoutinePath,'/Unknown_',rung_op.instr.instrName],...
            'MakeNameUnique','on');
            x0=rung_op.tag.X0;
            y0=rung_op.tag.Y0;
            x1=x0+rung_op.tag.Width;
            unknownInstrHeightOffset=100;
            y1=y0+rung_op.tag.Height-unknownInstrHeightOffset;

            obj.updateRungOpTagWithBlk(rung_op,rungop_blk);

            set_param(rungop_blk,'Position',[x0,y0,x1,y1]);


            obj.connectCurrentBlkToPredBlk(rungop_blk,pred_blk);

            set_param(rungop_blk,'PLCUnknownInstrName',rung_op.instr.instrName);

            assert(isa(rung_op,'plccore.ladder.RungOpAtom'),'Unknown instruction should be a rungOpAtom but was not in this case');
            unknownInstrInputs=rung_op.inputs;
            if~isempty(unknownInstrInputs)
                text=cell(1,length(unknownInstrInputs));
                for ii=1:length(unknownInstrInputs)
                    text{ii}=unknownInstrInputs{ii}.str;
                end
                unknownInstructionExprStr=strjoin(text,',');
                set_param(rungop_blk,'PLCUnknownInstrExp',unknownInstructionExprStr);
            else
                set_param(rungop_blk,'PLCUnknownInstrExp','');
            end
        end

        function generateJSRBlock(obj,rung_op,pred_blk)

            routine=rung_op.inputs{1}.routine;
            rungop_blk=add_block(obj.getPOUBlock(routine),...
            [obj.getCurrentPOURoutinePath,'/',routine.name],'MakeNameUnique','on');
            x0=rung_op.tag.X0;
            y0=rung_op.tag.Y0;
            x1=x0+rung_op.tag.Width;
            y1=y0+rung_op.tag.Height;

            obj.updateRungOpTagWithBlk(rung_op,rungop_blk);

            set_param(rungop_blk,'Position',[x0,y0,x1,y1]);


            obj.connectCurrentBlkToPredBlk(rungop_blk,pred_blk);

        end

        function generatePLCOperandTagBlock(obj,rung_op,pred_blk)

            [rungop_blk,x0,y0,x1,y1]=addLadderInstructionBlock(obj,rung_op);

            obj.updateRungOpTagWithBlk(rung_op,rungop_blk);

            set_param(rungop_blk,'Position',[x0,y0,x1,y1]);


            obj.connectCurrentBlkToPredBlk(rungop_blk,pred_blk);

            if rung_op.instr.getNumInput==1
                obj.updatePLCOperandTagParam(rungop_blk,rung_op.inputs{1})
            end
        end

        function generateJMPLBLBlock(obj,rung_op,pred_blk)

            if strcmp(rung_op.instr.name,'JMP')
                rungop_blk=add_block(obj.LadderLibJMPBlock,...
                [obj.getCurrentPOURoutinePath,'/',rung_op.instr.name],'MakeNameUnique','on');
            elseif strcmp(rung_op.instr.name,'LBL')
                rungop_blk=add_block(obj.LadderLibLBLBlock,...
                [obj.getCurrentPOURoutinePath,'/',rung_op.instr.name],'MakeNameUnique','on');
            else
                assert(false,['JMP or LBL instruction expected but found :',rung_op.instr.name]);
            end
            x0=rung_op.tag.X0;
            y0=rung_op.tag.Y0;
            x1=x0+rung_op.tag.Width;
            y1=y0+rung_op.tag.Height;

            obj.updateRungOpTagWithBlk(rung_op,rungop_blk);

            set_param(rungop_blk,'Position',[x0,y0,x1,y1]);


            obj.connectCurrentBlkToPredBlk(rungop_blk,pred_blk);

            set_param(rungop_blk,'PLCLabelTag',rung_op.inputs{1}.toString);

        end

        function generateRESBlock(obj,rung_op,pred_blk)

            [rungop_blk,x0,y0,x1,y1]=addLadderInstructionBlock(obj,rung_op);

            obj.updateRungOpTagWithBlk(rung_op,rungop_blk);

            set_param(rungop_blk,'Position',[x0,y0,x1,y1]);


            obj.connectCurrentBlkToPredBlk(rungop_blk,pred_blk);

            if rung_op.instr.getNumInput==1
                inputExp=rung_op.inputs{1};
                slplc.utils.setTag(rungop_blk,'PLCOperandTag',...
                inputExp.toString);
                structureType=plccore.common.Utils.getTypeFromExpr(obj.ctx,obj.current_pou_IR,inputExp);
                set_param(rungop_blk,'PLCTagDataType',structureType.name);
            end
        end

        function generateStandardBlock(obj,rung_op,pred_blk)

            [rungop_blk,x0,y0,x1,y1]=addLadderInstructionBlock(obj,rung_op);

            obj.updateRungOpTagWithBlk(rung_op,rungop_blk);

            if rung_op.instr.getNumInput>0
                x0=x0+100;
            end
            if rung_op.instr.getNumOutput>0
                x1=x1-100;
            end

            set_param(rungop_blk,'Position',[x0,y0,x1,y1]);


            obj.connectCurrentBlkToPredBlk(rungop_blk,pred_blk);

            canvas=obj.getCurrentPOURoutinePath;

            connectInputs(obj,canvas,rungop_blk,rung_op.inputs);

            connectOutputs(obj,canvas,rungop_blk,rung_op.outputs)
        end

        function generateSpecialBlock(obj,rung_op,pred_blk)

            [rungop_blk,x0,y0,x1,y1]=addLadderInstructionBlock(obj,rung_op);

            obj.updateRungOpTagWithBlk(rung_op,rungop_blk);

            if rung_op.instr.getNumInput>0&&...
                ~ismember(rung_op.instr.name,{'OSR','OSF'})
                x0=x0+100;
            end
            if rung_op.instr.getNumOutput>0||...
                ismember(rung_op.instr.name,{'OSR','OSF'})
                x1=x1-100;
            end


            set_param(rungop_blk,'Position',[x0,y0,x1,y1]);


            obj.connectCurrentBlkToPredBlk(rungop_blk,pred_blk);

            canvas=obj.getCurrentPOURoutinePath;
            switch(rung_op.instr.name)
            case 'FLL'
                connectFLLBlock(obj,rung_op,canvas,rungop_blk);
            case 'COP'
                connectCOPBlock(obj,rung_op,canvas,rungop_blk);
            case 'FBC'
                connectFBCBlock(obj,rung_op,canvas,rungop_blk);
            case 'CPT'
                connectCPTBlock(obj,rung_op,canvas,rungop_blk);
            case{'OSR','OSF'}
                connectOSROSFBlock(obj,rung_op,canvas,rungop_blk);
            otherwise
                [inputExprs,outputExprs]=getInputOutputExprsTargetInstr(obj,rung_op);
                obj.connectInputs(canvas,rungop_blk,inputExprs);
                obj.connectOutputs(canvas,rungop_blk,outputExprs);
            end
        end

        function[rungop_blk,x0,y0,x1,y1]=addLadderInstructionBlock(obj,rung_op)
            rungop_blk=add_block(rung_op.instr.blockPath,...
            [obj.getCurrentPOURoutinePath,'/',rung_op.instr.name],'MakeNameUnique','on');
            x0=rung_op.tag.X0;
            y0=rung_op.tag.Y0;
            x1=x0+rung_op.tag.Width;
            y1=y0+rung_op.tag.Height;

        end

        function connectCurrentBlkToPredBlk(obj,rungop_blk,pred_blk)

            pred_outPort=[get_param(pred_blk,'Name'),'/1'];
            currBlk_inport=[get_param(rungop_blk,'Name'),'/1'];
            add_line(obj.getCurrentPOURoutinePath,pred_outPort,currBlk_inport,'autorouting','on');
        end

        function updateRungOpTagWithBlk(obj,rung_op,rungop_blk)%#ok<INUSL>
            tag=rung_op.tag;
            tag.Block=rungop_blk;
            rung_op.setTag(tag);
        end

        function connectInputs(obj,canvas,rungop_blk,inputExprs)



            for ii=1:length(inputExprs)
                if isa(inputExprs{ii},'plccore.expr.ConstExpr')
                    constBlk=addConstBlock(obj,canvas,inputExprs{ii});
                    inputValueBlk=constBlk;
                else
                    varReadBlk=obj.addVariableRead(canvas,inputExprs{ii});
                    inputValueBlk=varReadBlk;
                end
                set_param(inputValueBlk,'ShowName','off');
                import plccore.util.SLBlockUtil;
                inportHdl=SLBlockUtil.getPort(rungop_blk,'in',ii+1);
                outportHdl=SLBlockUtil.getPort(inputValueBlk,'out',1);
                SLBlockUtil.moveBlocktoPositionRelativetoPort(inputValueBlk,inportHdl,'l',20)
                SLBlockUtil.connectBlocks(canvas,outportHdl,inportHdl);

            end
        end

        function constBlk=addConstBlock(obj,canvas,inputExpr)
            constBlk=add_block('built-in/Constant',[canvas,'/Const'],'MakeNameUnique','on');
            import plccore.visitor.SLValueVisitor;
            slValueVisit=SLValueVisitor;
            set_param(constBlk,'Value',inputExpr.value.accept(slValueVisit,[]));
            varReadPosition=get_param(obj.LadderLibVarReadBlock,'position');
            set_param(constBlk,'position',varReadPosition);

            typeStr=inputExpr.value.type.toString;
            if isempty(typeStr)
                typeStr='Inherit: Inherit via back propagation';
            end
            set_param(constBlk,'OutDataTypeStr',typeStr);
        end

        function varReadBlk=addVariableRead(obj,canvas,inputExpr)
            varReadBlk=add_block(obj.LadderLibVarReadBlock,[canvas,'/Variable Read'],'MakeNameUnique','on');
            obj.updatePLCOperandTagParam(varReadBlk,inputExpr)
        end

        function connectOutputs(obj,canvas,rungop_blk,outputExprs)



            for ii=1:length(outputExprs)
                varWriteBlk=addVariableWrite(obj,canvas,outputExprs{ii});
                set_param(varWriteBlk,'ShowName','off');
                import plccore.util.SLBlockUtil
                outportHdl=SLBlockUtil.getPort(rungop_blk,'out',ii+1);
                inportHdl=SLBlockUtil.getPort(varWriteBlk,'in',1);
                SLBlockUtil.moveBlocktoPositionRelativetoPort(varWriteBlk,outportHdl,'r',20)
                SLBlockUtil.connectBlocks(canvas,outportHdl,inportHdl);
            end
        end

        function varWriteBlk=addVariableWrite(obj,canvas,outputExpr)
            varWriteBlk=add_block(obj.LadderLibVarWriteBlock,[canvas,'/Variable Write'],'MakeNameUnique','on');
            obj.updatePLCOperandTagParam(varWriteBlk,outputExpr)
        end

        function updatePLCOperandTagParam(~,ladderBlk,operandExpr)
            expr=operandExpr.toString;
            slplc.utils.setTag(ladderBlk,'PLCOperandTag',expr);
        end

        function connectCOPBlock(obj,host,canvas,rungop_blk)

            [inputExprs,outputExprs]=getInputOutputExprsTargetInstr(obj,host);
            isCOP=true;
            checkTypeConversionCOPFLLSrcDest(obj,inputExprs{1},inputExprs{3},isCOP);


            if isa(inputExprs{1},'plccore.expr.ArrayRefExpr')
                srcArrOriginal=inputExprs{1};
                srcArr=srcArrOriginal.arrayExpr;
                assert(srcArrOriginal.getIndexCount==1,[host.instr.name,' supports only single index']);

                inputExprs{1}=srcArr;

                srcIndex=srcArrOriginal.indexExpr(1);
                if~isa(srcIndex,'plccore.expr.ConstExpr')
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:COPIndexNonNumeric',srcIndex.toString,host.toString,obj.current_pou_IR.name);
                end
                import plccore.visitor.ModelEmitter;
                inputExprs{end+1}=srcIndex;
            else

                srcIndex=plccore.expr.ConstExpr(plccore.common.ConstValue(plccore.type.DINTType,'1'));
                inputExprs{end+1}=srcIndex;
            end



            if isa(inputExprs{3},'plccore.expr.ArrayRefExpr')
                destArrOriginal=inputExprs{3};
                assert(isa(destArrOriginal,'plccore.expr.ArrayRefExpr'),[host.instr.name,' second argument should be an array expression']);
                destArr=destArrOriginal.arrayExpr;

                assert(destArrOriginal.getIndexCount==1,[host.instr.name,' supports only single index']);

                inputExprs{3}=destArr;

                destIndex=destArrOriginal.indexExpr(1);
                if~isa(destIndex,'plccore.expr.ConstExpr')
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:COPIndexNonNumeric',destIndex.toString,host.toString,obj.current_pou_IR.name);
                end
                import plccore.visitor.ModelEmitter;
                inputExprs{end+1}=destIndex;
                outputExprs{1}=destArr;
            else

                destIndex=plccore.expr.ConstExpr(plccore.common.ConstValue(plccore.type.DINTType,'1'));
                inputExprs{end+1}=destIndex;
                outputExprs{1}=inputExprs{3};
                destArr=inputExprs{3};
            end

            srcDataIndex=1;
            lengthIndex=2;
            obj.connectInputs(canvas,rungop_blk,inputExprs(srcDataIndex:lengthIndex));



            [~,aliasFound,isUnknownType]=plccore.common.Utils.getTypeFromExpr(obj.ctx,obj.current_pou_IR,destArr);
            if aliasFound
                warning('plc:ladder:modelemitter','Alias : %s found in rungs. Model generation for aliases is currently not possible',inputExprs{3});
            end
            if isUnknownType
                warning('plc:ladder:modelemitter','Unknown data type detected for tag/local variable : %s found in rungs. Model generation for aliases is currently not possible',inputExprs{3});
            end


            set_param(rungop_blk,'PLCSrcArrayIndex',srcIndex.toString);
            set_param(rungop_blk,'PLCDestArrayIndex',destIndex.toString);
            slplc.utils.setTag(rungop_blk,'PLCOperandTag',destArr.toString);



            if isa(outputExprs{1},'plccore.type.ArrayType')
                destType=destArr.var.initialValue.type;
                assert(isa(destType,'plccore.type.ArrayType'),'initial value should be of array type');

                if destType.numDims>1
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:COPFLLwithDimGreaterThanOne',type.name);
                end
                for ii=1:length(destType.numDims)


                end
            end

        end

        function checkTypeConversionCOPFLLSrcDest(obj,srcExpr,destExpr,isCOP)

            srcType=plccore.common.Utils.getTypeFromExpr(obj.ctx,obj.current_pou_IR,srcExpr);
            destType=plccore.common.Utils.getTypeFromExpr(obj.ctx,obj.current_pou_IR,destExpr);
            srcTypeStr=plccore.type.TypeTool.getTypeName(srcType);
            destTypeStr=plccore.type.TypeTool.getTypeName(destType);
            if~strcmp(srcTypeStr,destTypeStr)


                import plccore.common.plcThrowError;
                if isCOP
                    plcThrowError('plccoder:plccore:COPDataConversion',srcExpr.toString,srcTypeStr,destExpr.toString,destTypeStr,obj.current_pou_IR.name);
                else
                    plcThrowError('plccoder:plccore:FLLDataConversion',srcExpr.toString,srcTypeStr,destExpr.toString,destTypeStr,obj.current_pou_IR.name);
                end
            end
        end

        function connectFLLBlock(obj,host,canvas,rungop_blk)
            [inputExprs,outputExprs]=getInputOutputExprsTargetInstr(obj,host);

            isCOP=false;
            checkTypeConversionCOPFLLSrcDest(obj,inputExprs{1},inputExprs{3},isCOP);

            if isa(inputExprs{3},'plccore.expr.ArrayRefExpr')
                destArrOriginal=inputExprs{3};
                assert(isa(destArrOriginal,'plccore.expr.ArrayRefExpr'),[host.instr.name,' second argument should be an array expression']);
                destArr=destArrOriginal.arrayExpr;

                assert(destArrOriginal.getIndexCount==1,[host.instr.name,' supports only single index']);

                inputExprs{3}=destArr;

                destIndex=destArrOriginal.indexExpr(1);
                if~isa(destIndex,'plccore.expr.ConstExpr')
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:FLLDestIndexNonNumeric',destIndex.toString,host.toString,obj.current_pou_IR.name);
                end
                import plccore.visitor.ModelEmitter;
                inputExprs{end+1}=destIndex;
                outputExprs{1}=destArr;
            else

                destIndex=plccore.expr.ConstExpr(plccore.common.ConstValue(plccore.type.DINTType,'1'));
                inputExprs{end+1}=destIndex;
                outputExprs{1}=inputExprs{3};
                destArr=outputExprs{1};
            end

            srcDataIndex=1;
            lengthIndex=2;
            obj.connectInputs(canvas,rungop_blk,inputExprs(srcDataIndex:lengthIndex));

            [~,aliasFound,isUnknownType]=plccore.common.Utils.getTypeFromExpr(obj.ctx,obj.current_pou_IR,destArr);
            if aliasFound
                warning('plc:ladder:modelemitter','Alias : %s found in rungs. Model generation for aliases is currently not possible',inputExprs{3});
            end
            if isUnknownType
                warning('plc:ladder:modelemitter','Unknown data type detected for tag/local variable : %s found in rungs. Model generation for aliases is currently not possible',inputExprs{3});
            end

            set_param(rungop_blk,'PLCDestArrayIndex',destIndex.toString);
            slplc.utils.setTag(rungop_blk,'PLCOperandTag',destArr.toString);



            if isa(outputExprs{1},'plccore.type.ArrayType')
                destType=destArr.var.initialValue.type;
                assert(isa(destType,'plccore.type.ArrayType'),'initial value should be of array type');

                if destType.numDims>1
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:COPFLLwithDimGreaterThanOne',type.name);
                end
                for ii=1:length(destType.numDims)


                end
            end
        end

        function connectFBCBlock(obj,host,canvas,rungop_blk)
            [inputExprs,outputExprs]=getInputOutputExprsTargetInstr(obj,host);

            srcOriginal=inputExprs{1};
            assert(isa(srcOriginal,'plccore.expr.ArrayRefExpr'),'FLL second argument should be an array expression');
            srcArr=srcOriginal.arrayExpr;
            assert(srcOriginal.getIndexCount==1,'FLL supports only single index');

            inputExprs{1}=srcArr;

            inputExprs{end+1}=srcOriginal.indexExpr(1);

            refOriginal=inputExprs{2};
            assert(isa(refOriginal,'plccore.expr.ArrayRefExpr'),'FLL second argument should be an array expression');
            refArr=refOriginal.arrayExpr;
            assert(refOriginal.getIndexCount==1,'FLL supports only single index');

            inputExprs{2}=refArr;

            inputExprs{end+1}=refOriginal.indexExpr(1);


            destOriginal=inputExprs{3};
            assert(isa(destOriginal,'plccore.expr.ArrayRefExpr'),'FLL second argument should be an array expression');
            destArr=destOriginal.arrayExpr;
            assert(destOriginal.getIndexCount==1,'FLL supports only single index');

            inputExprs{3}=destArr;

            inputExprs{end+1}=destOriginal.indexExpr(1);
            outputExprs{1}=destArr;

            obj.connectInputs(canvas,rungop_blk,inputExprs);
            obj.connectOutputs(canvas,rungop_blk,outputExprs);
        end

        function connectCPTBlock(obj,host,canvas,rungop_blk)
            [inputExprs,outputExprs]=getInputOutputExprsTargetInstr(obj,host);
            destExpr=outputExprs;
            cptOperandExpr=inputExprs{1};
            assert(isa(cptOperandExpr,'plccore.expr.StringExpr'),'CPT second argument should be an string expression');

            obj.updatePLCOperandTagParam(rungop_blk,cptOperandExpr);
            obj.connectOutputs(canvas,rungop_blk,destExpr);


        end

        function connectOSROSFBlock(obj,host,canvas,rungop_blk)
            [inputExprs,outputExprs]=getInputOutputExprsTargetInstr(obj,host);
            destExpr=outputExprs;
            plcOperandExpr=inputExprs{1};


            obj.updatePLCOperandTagParam(rungop_blk,plcOperandExpr);
            obj.connectOutputs(canvas,rungop_blk,destExpr);


        end

        function[inputExprs,outputExprs]=getInputOutputExprsTargetInstr(obj,rungOpTargetInstr)%#ok<INUSL>




            argStruct=rungOpTargetInstr.instr.getInstrTypeStruct;


            inputExprs=cell(1,length(argStruct.inputIndices)+length(argStruct.inOutIndices));



            outputExprs=cell(1,length(argStruct.outputIndices)+length(argStruct.inOutIndices));

            for ii=1:length(argStruct.inputIndices)
                index=argStruct.inputIndices(ii);
                inputExprs{ii}=rungOpTargetInstr.inputs{index};
            end

            for ii=1:length(argStruct.inOutIndices)
                index=argStruct.inOutIndices(ii);
                inputExprs{ii+length(argStruct.inputIndices)}=rungOpTargetInstr.inputs{index};
            end

            for ii=1:length(argStruct.outputIndices)
                index=argStruct.outputIndices(ii);
                outputExprs{ii}=rungOpTargetInstr.inputs{index};
            end

            for ii=1:length(argStruct.inOutIndices)
                index=argStruct.inOutIndices(ii);
                outputExprs{ii+length(argStruct.outputIndices)}=rungOpTargetInstr.inputs{index};
            end

        end

        function generateModelBlocks(obj,ld,pou_blk,routineType)
            import plccore.visitor.*;
            routine_sys_path=obj.getPOUBlockRoutinePath(pou_blk,routineType);
            power_end_blk=obj.getBlock(routine_sys_path,'PowerRailTerminal');
            [x0,~,x1,~]=ModelEmitter.blockPosition(power_end_blk);
            [~,height]=ModelEmitter.blockSize(power_end_blk);
            ld_tag=ld.tag;
            y0=ld_tag.Y0+ld_tag.Height+ModelLayoutVisitor.StartYOffset;
            y1=y0+height;
            set_param(power_end_blk,'Position',[x0,y0,x1,y1]);
            ld.accept(obj,[]);
        end

        function ret=createPOUBlockMap(obj)%#ok<MANU>
            ret=containers.Map;
        end

        function addPOUBlock(obj,pou_block_map,pou,block)%#ok<INUSL>
            assert(~pou_block_map.isKey(pou.name));
            pou_block_map(pou.name)=block;%#ok<NASGU>
        end

        function generateGlobalVar(obj)
            var_list=obj.createControllerVarDef;
            if~isempty(var_list)
                slplc.api.setPOU(obj.ControllerBlock,'VariableList',var_list);
            end
        end

        function generatePOUList(obj,pou_list,pou_blk_map)
            persistent idx;
            if isempty(idx)
                idx=0;
            end
            row_count=mod(idx,obj.RowMaxCount);
            if row_count~=0
                idx=idx+obj.RowMaxCount-row_count;
            end
            obj.activateSystem(obj.ModuleMdlName,true);
            total_count=length(pou_list);
            for i=1:total_count
                pou=pou_list{i};
                if obj.debug
                    fprintf('\n\n--->Generate %s %s: #%d of %d\n',...
                    pou.name,pou.kind,i,total_count);
                end
                blk=obj.createPOUBlock(pou,idx);
                obj.addPOUBlock(pou_blk_map,pou,blk);
                idx=idx+1;
            end
        end

        function generateAOI(obj)
            obj.generatePOUList(obj.analyzer.sortedFBList,obj.AOIBlockMap);
        end

        function ret=getNonMainRoutineList(obj,prog)%#ok<INUSL>
            routine_list=prog.routineList;
            if~prog.hasMainRoutine
                ret=routine_list;
                return;
            end

            main_routine=prog.mainRoutine;
            idx=0;
            for i=1:length(routine_list)
                if routine_list{i}==main_routine
                    idx=i;
                    break;
                end
            end
            routine_list(idx)=[];
            ret=routine_list;
        end

        function generateProgram(obj)
            obj.activateSystem(obj.ModuleMdlName,true);
            prog_list=obj.ctx.configuration.globalScope.programList;
            total_count=length(prog_list);
            for i=1:total_count
                prog=prog_list{i};
                if obj.debug
                    fprintf('\n\n--->Generate Program %s: #%d of %d\n',...
                    prog.name,i,total_count);
                end
                prog.setTag(obj.createPOUBlockMap);
                obj.generatePOUList(obj.getNonMainRoutineList(prog),prog.tag);
                obj.generatePOUList({prog},obj.ProgramBlockMap);
            end
        end

        function ret=addModelBlock(obj,blk_path,new_path)%#ok<INUSL>
            new_blk=add_block(blk_path,new_path,'MakeNameUnique','on');
            ret=getfullname(new_blk);
        end

        function alignTaskBlock(obj,base_x0,base_y0,block,idx)
            import plccore.visitor.*;
            [blk_wd,blk_ht]=ModelEmitter.blockSize(block);
            base_sz=max(blk_wd,blk_ht);
            row=idivide(idx,obj.RowMaxTaskCount);
            col=mod(idx,obj.RowMaxTaskCount);
            x0=base_x0+(base_sz+blk_wd/2)*col;
            y0=base_y0+(base_sz+blk_ht/2)*row;
            set_param(block,'Position',double([x0,y0,x0+blk_wd,y0+blk_ht]));
        end

        function[base_x0,base_y0]=getSimpleBlockStartPosition(obj,owner_blk)
            import plccore.visitor.*;
            openparent_blk=obj.getBlock(owner_blk,'OpenParentPOU');
            [x0,y0,~,~]=ModelEmitter.blockPosition(openparent_blk);
            [~,h]=ModelEmitter.blockSize(openparent_blk);
            base_x0=x0-ModelLayoutVisitor.StartXOffset;
            base_y0=y0+h+ModelLayoutVisitor.StartYOffset;
        end

        function setTaskParams(obj,task,task_blk)%#ok<INUSL>
            switch task.kind
            case 'EventTask'
                set_param(task_blk,'SystemSampleTime',num2str(task.rate/1000));
            case 'PeriodicTask'
                set_param(task_blk,'SystemSampleTime',num2str(task.rate/1000));
            otherwise

            end
            set_param(task_blk,'Priority',num2str(task.priority));
            set_param(task_blk,'Description',task.desc);
        end

        function generateTaskProgram(obj,controller_path,task,idx)
            import plccore.visitor.*;
            obj.activateSystem(controller_path,false);
            task_block=sprintf('%s/%s',controller_path,task.name);
            task_block=obj.addModelBlock(obj.LadderLibTaskBlock,task_block);
            obj.setTaskParams(task,task_block);
            [controller_x0,controller_y0]=obj.getSimpleBlockStartPosition(controller_path);
            obj.alignTaskBlock(controller_x0,controller_y0,task_block,idx-1);
            obj.activateSystem(task_block,false);
            prog_list=task.programList;
            set_param(task_block,'PLCTaskWatchDog',num2str(task.watchdogTime));
            [task_x0,task_y0]=obj.getSimpleBlockStartPosition(task_block);
            for i=1:length(prog_list)
                prog=prog_list{i};
                prog_block=sprintf('%s/%s',task_block,prog.name);
                prog_block=obj.addModelBlock(obj.ProgramBlockMap(prog.name),prog_block);
                obj.alignTaskBlock(task_x0,task_y0,prog_block,i-1);
            end
        end

        function generateTask(obj)
            obj.activateSystem(obj.MainMdlName,false);
            set_param(obj.MainMdlName,'SolverType','Fixed-step');
            set_param(obj.MainMdlName,'Solver','FixedStepDiscrete');
            config=obj.ctx.configuration;
            controller_block=sprintf('%s/%s',obj.MainMdlName,config.name);
            controller_block=obj.addModelBlock(obj.LadderLibControllerBlock,controller_block);
            controller_path=obj.getPOUBlockRoutinePath(controller_block);
            obj.activateSystem(controller_path,false);
            task_list=config.taskList;
            for i=1:length(task_list)
                obj.generateTaskProgram(controller_path,task_list{i},i);
            end
            obj.ControllerBlock=controller_block;
        end

        function activateSystem(obj,sys_path,is_lib_mdl)
            open_mdl=obj.cfg.openModel;
            if is_lib_mdl&&~obj.cfg.keepLibModel
                open_mdl=false;
            end
            if open_mdl
                open_system(sys_path);
            else
                load_system(sys_path);
            end
        end

        function generateAOIBlockListFile(obj)
            txt_writer=plccore.util.TxtWriter;
            txt=sprintf('function [aoi_list, blk_list] = %s',obj.cfg.AOIBlockListFcnName);
            txt_writer.writeLine(txt);
            fb_list=obj.analyzer.sortedFBList;
            fb_list_sz=length(fb_list);
            txt_writer.indent;
            txt=sprintf('aoi_list = {};');
            txt_writer.writeLine(txt);
            txt_writer.indent;
            txt=sprintf('blk_list = {};');
            txt_writer.writeLine(txt);
            for i=1:fb_list_sz
                fb=fb_list{i};
                txt_writer.indent;
                txt=sprintf('aoi_list{end+1} = ''%s'';',fb.name);
                txt_writer.writeLine(txt);
                txt_writer.indent;
                txt=sprintf('blk_list{end+1} = ''%s'';',obj.AOIBlockMap(fb.name));
                txt_writer.writeLine(txt);
            end
            txt=sprintf('end');
            txt_writer.writeLine(txt);
            txt_writer.writeFile(obj.cfg.fileDir,obj.cfg.AOIBlockListFileName);
        end

        function generateModelInternal(obj)
            obj.generateAOI;
            obj.generateProgram;
            obj.generateTask;
            obj.generateGlobalVar;
        end

        function runConfigBeforeMdlCompile(obj)%#ok<MANU>
        end

        function runConfigAfterMdlCompile(obj)%#ok<MANU>
        end

        function disableSLRequirementCheck(obj)
            obj.SLRequirementParam=get_param(0,'CopyBlkRequirement');
            set_param(0,'CopyBlkRequirement','off')
        end

        function restoreSLRequirementCheck(obj)
            set_param(0,'CopyBlkRequirement',obj.SLRequirementParam);
        end

        function loadLadderTypes(obj)%#ok<MANU>
            evalin('base','plcloadtypes;');
        end
    end
end










