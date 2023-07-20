classdef BuiltinScope<plccore.common.Scope



    properties(Access=protected)
TargetIDE
        TargetInstrFileName='plc_ladder_instr';
        TargetDataTypeFileName='plc_ladder_datatype';
    end

    methods
        function obj=BuiltinScope
            obj.Kind='Builtin';
            obj.Name='Built-in Scope';
            obj.createLadderInstructions;
        end

        function processTarget(obj,target_ide)
            switch target_ide
            case{'studio5000','rslogix5000'}
                obj.processRockwellTarget;
            otherwise
            end
        end

        function ret=getIOSlotType(obj,name)
            name=strrep(name,':','_');
            if~obj.hasSymbol(name)
                ret=obj.createIOSlotType(name);
            else
                ret=obj.getSymbol(name);
            end
        end
    end

    methods(Access=private)
        function ret=createIOSlotType(obj,name)
            import plccore.type.*;
            darray_type=ArrayType(32,SINTType);
            struct_type=StructType({'Data'},{darray_type});
            typ=NamedType(name,struct_type);
            obj.addSymbol(name,typ);
            ret=typ;
        end

        function createLadderInstructions(obj)
            instr_list={'NOCInstr',...
            'NCCInstr',...
            'PTCInstr',...
            'NTCInstr',...
            'CoilInstr',...
            'NegCoilInstr',...
            'SetCoilInstr',...
            'ResetCoilInstr',...
            'PTCoilInstr',...
            'NTCoilInstr',...
            'LEQInstr',...
            'GEQInstr',...
            'TONInstr',...
            'TOFInstr',...
            'CTUInstr',...
            'CTDInstr',...
            'CTUDInstr',...
            'JMPInstr',...
            'LBLInstr',...
'JSRInstr'
            };

            for i=1:numel(instr_list)
                obj.createInstr(instr_list{i});
            end
        end

        function createInstr(obj,name)
            cls_name=sprintf('plccore.ladder.%s',name);
            cls=str2func(cls_name);
            scopes=obj.createPOUScopeTriple;
            instr=cls(scopes{1},scopes{2},scopes{3});
            obj.addSymbol(instr.name,instr);
        end

        function processRockwellTarget(obj)
            obj.processRockwellTargetDataType;
            obj.processRockwellTargetInstr;
        end

        function processRockwellTargetDataType(obj)
            target_file_paths=which('-all',obj.TargetDataTypeFileName);
            funcs={};
            for i=1:length(target_file_paths)
                funcs{end+1}=builtin('_GetFunctionHandleForFullpath',target_file_paths{i});%#ok<AGROW>
            end

            for i=length(funcs):-1:1
                try
                    datatype_info=feval(funcs{i});
                    if~(strcmp(datatype_info.target,'studio5000')||...
                        strcmp(datatype_info.target,'rslogix5000'))
                        continue;
                    end
                    for j=1:length(datatype_info.datatype_list)
                        obj.processLadderDataType(datatype_info.datatype_list(j));
                    end
                catch ME
                    fprintf('The following error occurred while evaluating  "%s" for RSLogix ladder data type.\n',...
                    target_file_paths{length(target_file_paths)+1-i});
                    disp(ME.message);
                end
            end
        end

        function processRockwellTargetInstr(obj)
            target_file_paths=which('-all',obj.TargetInstrFileName);
            funcs={};
            for i=1:length(target_file_paths)
                funcs{end+1}=builtin('_GetFunctionHandleForFullpath',target_file_paths{i});%#ok<AGROW>
            end

            for i=length(funcs):-1:1
                try
                    instr_info=feval(funcs{i});
                    assert(strcmp(instr_info.target,'studio5000')||...
                    strcmp(instr_info.target,'rslogix5000'));
                    for j=1:length(instr_info.instr_list)
                        obj.processLadderInstr(instr_info.instr_list(j));
                    end
                catch ME
                    fprintf('The following error occurred while evaluating  "%s" for RSLogix ladder instrucion.\n',...
                    target_file_paths{length(target_file_paths)+1-i});
                    disp(ME.message);
                end
            end
        end

        function processLadderInstr(obj,instr_info)
            scopes=obj.createPOUScopeTriple;
            instr_info.InputTypeList=obj.convertParamTypes(instr_info.InputTypeList);
            instr_info.OutputTypeList=obj.convertParamTypes(instr_info.OutputTypeList);
            instr=plccore.ladder.TargetInstruction(instr_info.Name,...
            instr_info.BlockPath,...
            instr_info.NumInput,...
            instr_info.NumOutput,...
            instr_info.InputTypeList,...
            instr_info.OutputTypeList,...
            instr_info.EmitterFcn,...
            scopes{1},scopes{2},scopes{3},...
            instr_info.ArgStruct,...
            instr_info);
            obj.addSymbol(instr.name,instr);
        end

        function processLadderDataType(obj,datatype_info)
            import plccore.type.*;
            type=NamedType(datatype_info.Name,...
            StructType(datatype_info.FieldList,obj.getIRTypeList(datatype_info.TypeList)));
            obj.addSymbol(type.name,type);
        end

        function ret=convertParamTypes(obj,param_types)
            ret=cellfun(@(pt)obj.getIRTypeList(pt),param_types,'UniformOutput',false);
        end

        function ret=getIRTypeList(obj,type_list)
            ret=cellfun(@(t)obj.getIRType(t),type_list,'UniformOutput',false);
        end

        function ret=getIRType(obj,type_name)
            import plccore.type.*;
            switch type_name
            case 'BOOL'
                ret=BOOLType;
            case 'SINT'
                ret=SINTType;
            case 'INT'
                ret=INTType;
            case 'DINT'
                ret=DINTType;
            case 'USINT'
                ret=USINTType;
            case 'UINT'
                ret=UINTType;
            case 'UDINT'
                ret=UDINTType;
            case 'REAL'
                ret=REALType;
            case 'LREAL'
                ret=LREALType;
            otherwise
                if startsWith(type_name,'ARRAY')
                    etype_name=regexprep(type_name,'ARRAY\((\w)+\)','$1');
                    etype=obj.getIRType(etype_name);
                    ret=ArrayType([],etype);
                elseif strcmp(type_name,'STRUCT')
                    ret=StructType([],[]);
                elseif obj.hasSymbol(type_name)
                    typ=obj.getSymbol(type_name);
                    assert(isa(typ,'plccore.type.AbstractType'));
                    ret=typ;
                else
                    assert(false,sprintf('%s type is not allowed',type_name));
                end
            end
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitBuiltinScope(obj,input);
        end
    end
end



