classdef RockwellEmitter<plccore.visitor.AbstractVisitor



    properties(Access=protected)
Context
GlobalScope
EmitController
XmlWriter
VarValueEmitter
    end

    properties(Access=private)
udt_bool_idx
udt_bool_target
udt_param_name_list
udt_param_value_list
analyzer
    end

    methods
        function obj=RockwellEmitter(ctx)
            import plccore.visitor.*;
            obj.Kind='RockwellEmitter';
            obj.Context=ctx;
            obj.GlobalScope=ctx.configuration.globalScope;
            obj.EmitController=true;
            obj.XmlWriter=[];
            obj.analyzer=ContextAnalyzer(ctx);
        end

        function[ret_flag,ret_file]=generateCode(obj)
            obj.analyzeContext;
            obj.setupEmitter;
            obj.generateUDT;
            obj.generateAOI;
            obj.generateGlobalVar;
            obj.generateProgram;
            obj.generateTask;
            ret_flag=true;
            ret_file={obj.generateCodeFile};
        end
    end

    methods(Access=protected)
        function ret=ctx(obj)
            ret=obj.Context;
        end

        function ret=globalScope(obj)
            ret=obj.GlobalScope;
        end

        function ret=getUDTList(obj)
            ret=obj.analyzer.sortedTypeList;
        end

        function ret=getAOIList(obj)
            ret=obj.analyzer.sortedFBList;
        end

        function analyzeContext(obj)
            obj.analyzer.doit;
            if isempty(obj.ctx.configuration.taskList)
                obj.EmitController=false;
            end
        end

        function ret=emitter(obj)
            ret=obj.XmlWriter;
        end

        function ret=value_emitter(obj)
            ret=obj.VarValueEmitter;
        end

        function setupEmitter(obj)
            if obj.EmitController
                obj.XmlWriter=plccore.util.RockwellXmlWriter('Controller');
                obj.emitter.setControllerName(obj.ctx.configuration.name);
            else
                obj.XmlWriter=plccore.util.RockwellXmlWriter('AOI');
            end
            obj.VarValueEmitter=plccore.visitor.L5XValueEmitter(obj.XmlWriter);
        end

        function resetUDTData(obj)
            obj.udt_param_name_list={};
            obj.udt_param_value_list={};
        end

        function registerUDTParam(obj,name,value)
            obj.udt_param_name_list{end+1}=name;
            obj.udt_param_value_list{end+1}=value;
        end

        function genUDTBoolInt(obj,idx)
            field_name=sprintf('ZZZZZZZZZZUDT%d',idx);
            obj.registerUDTParam('Name',field_name);
            obj.registerUDTParam('DataType','SINT');
            obj.registerUDTParam('Dimension','0');
            obj.registerUDTParam('Hidden','true');
            obj.emitter.genUDTMemberNode(obj.udt_param_name_list,obj.udt_param_value_list,[]);
            obj.udt_bool_target=field_name;
        end

        function registerUDTBool(obj,field_name)
            bit_idx=mod(obj.udt_bool_idx,8);
            if bit_idx==0
                int_idx=obj.udt_bool_idx/8;
                obj.genUDTBoolInt(int_idx);
                obj.resetUDTData;
            end
            obj.registerUDTParam('Name',field_name);
            obj.registerUDTParam('DataType','BIT');
            obj.registerUDTParam('Dimension','0');
            obj.registerUDTParam('Hidden','false');
            assert(~isempty(obj.udt_bool_target));
            obj.registerUDTParam('Target',obj.udt_bool_target);
            obj.registerUDTParam('BitNumber',num2str(bit_idx));
            obj.udt_bool_idx=obj.udt_bool_idx+1;
        end

        function registerUDTField(obj,field_name,field_type)
            import plccore.util.*;
            import plccore.type.*;
            obj.resetUDTData;
            if isa(field_type,'plccore.type.BOOLType')
                obj.registerUDTBool(field_name);
                return;
            end

            obj.registerUDTParam('Name',field_name);
            obj.registerUDTParam('DataType',GetL5XTypeName(field_type));
            if isa(field_type,'plccore.type.ArrayType')
                assert(field_type.numDims==1);
                obj.registerUDTParam('Dimension',num2str(field_type.dim(1)));
            else
                obj.registerUDTParam('Dimension','0');
            end
            obj.registerUDTParam('Hidden','false');
        end

        function emitUDT(obj,udt)
            import plccore.type.*;
            assert(TypeTool.isNamedStructType(udt));

            obj.emitter.beginGenUDTNode(udt.name);
            typ=udt.type;
            obj.udt_bool_idx=0;
            obj.udt_bool_target=[];
            for i=1:typ.numFields
                obj.registerUDTField(typ.fieldName(i),typ.fieldType(i));
                obj.emitter.genUDTMemberNode(obj.udt_param_name_list,obj.udt_param_value_list,...
                typ.fieldDescription(i));
            end
            obj.emitter.endGenUDTNode(udt.name);
        end

        function ret=pruneUDTType(obj,type_list)
            import plccore.type.*;
            ret={};
            for i=1:length(type_list)
                type=type_list{i};
                if obj.ctx.builtinScope.hasSymbol(type.name)
                    continue;
                end
                if~TypeTool.isNamedType(type)
                    continue;
                end
                ret{end+1}=type;%#ok<AGROW>
            end
        end

        function generateUDT(obj)
            import plccore.util.*;
            type_list=obj.getUDTList;
            type_list=obj.pruneUDTType(type_list);
            ApplyListFcn(type_list,@(t)obj.emitUDT(t));
        end

        function emitAOIVarValue(obj,var)
            if~var.hasInitialValue
                return;
            end
            ve=obj.value_emitter;
            ve.beginGenAOIVarValue;
            var.initialValue.accept(ve,[]);
            ve.endGenVarValue;
        end

        function[name_list,value_list]=emitArrayVarDimension(obj,var,name_list,value_list)%#ok<INUSL>
            import plccore.type.*;

            var_type=var.type;
            if TypeTool.isArrayType(var_type)
                name_list{end+1}='Dimensions';
                dim_list=var_type.dims;
                dim_list_txt=sprintf('%d ',dim_list);
                dim_list_txt=dim_list_txt(1:end-1);
                value_list{end+1}=dim_list_txt;
            end
        end

        function emitAOIParamVar(obj,skip_enable_var,var,usage,ext_access,required)
            import plccore.util.*;

            if skip_enable_var
                switch var.name
                case{'EnableIn','EnableOut'}
                    return;
                otherwise
                end
            end

            if required
                required='true';
            else
                required='false';
            end
            if isempty(ext_access)
                name_list={'Name','DataType','Usage','Required','Visible'};
                value_list={var.name,GetL5XTypeName(var.type),usage,required,required};
            else
                name_list={'Name','DataType','Usage','ExternalAccess','Required','Visible'};
                value_list={var.name,GetL5XTypeName(var.type),usage,ext_access,required,required};
            end
            [name_list,value_list]=obj.emitArrayVarDimension(var,name_list,value_list);
            obj.emitter.genAOIParamVar(name_list,value_list);
            obj.emitAOIVarValue(var);
        end

        function emitAOILocalVar(obj,var)
            import plccore.util.*;
            name_list={'Name','DataType'};
            value_list={var.name,GetL5XTypeName(var.type)};
            [name_list,value_list]=obj.emitArrayVarDimension(var,name_list,value_list);
            obj.emitter.genAOILocalVar(name_list,value_list);
            obj.emitAOIVarValue(var);
        end

        function emitRoutine(obj,routine)
            obj.emitter.beginGenRoutine(routine.name);
            routine.impl.accept(obj,[]);
            obj.emitter.endGenRoutine;
        end

        function clearVarListInitialValue(obj,var_list)%#ok<INUSL>
            for i=1:length(var_list)
                var=var_list{i};
                var.setInitialValue([]);
            end
        end

        function emitAOI(obj,aoi)
            import plccore.util.*;
            name_list={'Use','Name','ExecutePrescan','ExecutePostscan','ExecuteEnableInFalse'};
            pre_scan='false';
            if aoi.hasPrescanRoutine
                pre_scan='true';
            end
            enable_in_false='false';
            if aoi.hasEnableInFalseRoutine
                enable_in_false='true';
            end
            value_list={'Target',aoi.name,pre_scan,'false',enable_in_false};

            obj.emitter.beginGenAOINode(name_list,value_list);
            enable_in_txt='EnableIn';
            if aoi.inputScope.hasSymbol(enable_in_txt)
                enable_in_var=aoi.inputScope.getSymbol(enable_in_txt);
                obj.emitAOIParamVar(false,enable_in_var,'Input','Read Only',false);
            end
            enable_out_txt='EnableOut';
            if aoi.outputScope.hasSymbol(enable_out_txt)
                enable_out_var=aoi.outputScope.getSymbol(enable_out_txt);
                obj.emitAOIParamVar(false,enable_out_var,'Output','Read Only',false);
            end

            obj.clearVarListInitialValue(aoi.inOutScope.varList);
            varList=aoi.getVariableList;
            for i=1:numel(varList)
                if aoi.localScope.hasSymbol(varList{i}.name)
                    obj.emitAOILocalVar(varList{i});
                elseif aoi.inputScope.hasSymbol(varList{i}.name)
                    obj.emitAOIParamVar(true,varList{i},'Input','Read/Write',varList{i}.required);
                elseif aoi.inOutScope.hasSymbol(varList{i}.name)
                    obj.emitAOIParamVar(true,varList{i},'InOut',[],varList{i}.required);
                elseif aoi.outputScope.hasSymbol(varList{i}.name)
                    obj.emitAOIParamVar(true,varList{i},'Output','Read Only',varList{i}.required);
                end
            end

            if eval(pre_scan)
                obj.emitRoutine(aoi.prescanRoutine);
            end
            if eval(enable_in_false)
                obj.emitRoutine(aoi.enableInFalseRoutine);
            end
            if aoi.hasLogicRoutine
                obj.emitRoutine(aoi.logicRoutine);
            end
            obj.emitter.endGenAOINode;
        end

        function generateAOI(obj)
            import plccore.util.*;
            ApplyListFcn(obj.getAOIList,@(a)obj.emitAOI(a));
        end

        function emitGlobalVarValue(obj,var)
            if~var.hasInitialValue
                return;
            end
            ve=obj.value_emitter;
            ve.beginGenGlobalVarValue;
            var.initialValue.accept(ve,[]);
            ve.endGenVarValue;
        end

        function emitGlobalVar(obj,var)
            import plccore.util.*;
            name_list={'Name','DataType'};
            value_list={var.name,GetL5XTypeName(var.type)};
            import plccore.type.TypeTool;
            [name_list,value_list]=obj.emitArrayVarDimension(var,name_list,value_list);
            obj.emitter.genGlobalVar(name_list,value_list);
            obj.emitGlobalVarValue(var);
        end

        function generateGlobalVar(obj)
            import plccore.util.*;
            ApplyListFcn(obj.globalScope.varList,...
            @(v)obj.emitGlobalVar(v));
        end

        function emitProgVarValue(obj,var)
            if~var.hasInitialValue
                return;
            end
            ve=obj.value_emitter;
            ve.beginGenProgVarValue;
            var.initialValue.accept(ve,[]);
            ve.endGenVarValue;
        end

        function emitProgVar(obj,var,usage,ext_access)
            import plccore.util.*;
            if isempty(ext_access)
                name_list={'Name','DataType'};
                value_list={var.name,GetL5XTypeName(var.type)};
            else
                name_list={'Name','DataType','ExternalAccess'};
                value_list={var.name,GetL5XTypeName(var.type),ext_access};
            end
            if usage
                name_list{end+1}='Usage';
                value_list{end+1}=usage;
            end
            [name_list,value_list]=obj.emitArrayVarDimension(var,name_list,value_list);
            obj.emitter.genProgVar(name_list,value_list);
            obj.emitProgVarValue(var);
        end

        function emitProgram(obj,prog)
            import plccore.util.*;
            name_list={'Name'};
            value_list={prog.name};
            if prog.hasMainRoutine
                name_list{end+1}='MainRoutineName';
                value_list{end+1}=prog.mainRoutine.name;
            end

            obj.emitter.beginGenProgNode(name_list,value_list);

            ApplyListFcn(prog.inputScope.varList,@(v)obj.emitProgVar(v,'Input','Read/Write'));
            ApplyListFcn(prog.outputScope.varList,@(v)obj.emitProgVar(v,'Output','Read Only'));
            obj.clearVarListInitialValue(prog.inOutScope.varList);
            ApplyListFcn(prog.inOutScope.varList,@(v)obj.emitProgVar(v,'InOut',[]));
            ApplyListFcn(prog.localScope.varList,@(v)obj.emitProgVar(v,'','Read/Write'));

            ApplyListFcn(prog.routineList,@(r)obj.emitRoutine(r));
            obj.emitter.endGenProgNode;
        end

        function generateProgram(obj)
            import plccore.util.*;
            ApplyListFcn(obj.globalScope.programList,...
            @(v)obj.emitProgram(v));
        end

        function emitTask(obj,task)
            import plccore.visitor.*;
            import plccore.util.*;
            task_param=task.accept(L5XTaskVisitor,[]);
            obj.emitter.beginGenTaskNode(task_param.name_list,task_param.value_list,task);
            if~isempty(task.desc)
                obj.emitter.genTaskDescription(task.desc)
            end
            if isa(task,'plccore.common.EventTask')
                obj.emitter.genEventTaskTrigger(task.trigger);
            end
            ApplyListFcn(task.programList,@(p)obj.emitter.genTaskProgram(p.name));
            obj.emitter.endGenTaskNode;
        end

        function generateTask(obj)
            import plccore.util.*;
            ApplyListFcn(obj.ctx.configuration.taskList,...
            @(t)obj.emitTask(t));
        end

        function ret=generateCodeFile(obj)
            cfg=obj.ctx.getPLCConfigInfo;
            obj.XmlWriter.writeFile(cfg.fileDir,cfg.L5XCGFileName);
            ret=fullfile(cfg.fileDir,filesep,cfg.L5XCGFileName);
        end
    end

    methods
        function ret=visitLadderDiagram(obj,host,input)%#ok<INUSD>
            rungs=host.rungs;
            for i=1:length(rungs)
                rung=rungs{i};
                rung.accept(obj,i-1);
            end
            ret=[];
        end

        function ret=visitLadderRung(obj,host,input)
            rungops=host.rungOps;
            rung_code='';
            for i=1:length(rungops)
                rungop=rungops{i};
                rung_code=[rung_code,rungop.accept(obj,[])];%#ok<AGROW>
            end
            rung_code=[rung_code,';'];
            obj.emitter.genRung(input,rung_code,host.description);
            ret=[];
        end

        function ret=visitRungOpAtom(obj,host,input)%#ok<INUSL,INUSD>
            if isa(host.instr,'plccore.ladder.TargetInstruction')
                emit_fcn=host.instr.emitterFcn;
                ret=emit_fcn(host.instr.instrInfo,host.inputs,host.outputs);
                return;
            end

            rung_code=host.instr.name;
            rung_code=[rung_code,'('];
            inputs=host.inputs;
            for i=1:length(inputs)
                if i==1
                    sep='';
                else
                    sep=',';
                end
                rung_code=[rung_code,sep,inputs{i}.toString];%#ok<AGROW>
            end

            outputs=host.outputs;
            for i=1:length(outputs)
                if i==1&&isempty(inputs)
                    sep='';
                else
                    sep=',';
                end
                rung_code=[rung_code,sep,outputs{i}.toString];%#ok<AGROW>
            end

            if strcmp(host.instr.name,'JSR')
                rung_code=[rung_code,',0'];
            end

            rung_code=[rung_code,')'];
            ret=rung_code;
        end

        function ret=visitRungOpPar(obj,host,input)
            rungops=host.rungOps;
            rung_code='[';
            for i=1:numel(rungops)
                rungop=rungops{i};
                if i==1
                    sep='';
                else
                    sep=', ';
                end
                rung_code=[rung_code,sep,rungop.accept(obj,input)];%#ok<AGROW>
            end
            rung_code=[rung_code,']'];
            ret=rung_code;
        end

        function ret=visitRungOpSeq(obj,host,input)
            rungops=host.rungOps;
            rung_code='';
            for i=1:numel(rungops)
                rungop=rungops{i};
                rung_code=[rung_code,rungop.accept(obj,input)];%#ok<AGROW>
            end
            ret=rung_code;
        end

        function ret=visitRungOpTimer(obj,host,input)%#ok<INUSD>
            ret=[];
            assert(false,'Error: invalid timer ir');
        end

        function ret=visitRungOpFBCall(obj,host,input)%#ok<INUSD,INUSL>
            rung_code=[host.pou.name,'(',host.instance.toString];
            for i=1:length(host.argList)
                rung_code=[rung_code,',',host.argList{i}.toString];%#ok<AGROW>
            end
            rung_code=[rung_code,')'];
            rung_code=strrep(rung_code,'FALSE','0');
            rung_code=strrep(rung_code,'TRUE','1');
            ret=rung_code;
        end
    end
end



