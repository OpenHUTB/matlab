classdef ModelInitialValueVisitor<plccore.visitor.AbstractVisitor





    properties(Access=protected)
ctx
emitter
VarNameValueMap
MdlDataStruct
VarNameStack

    end

    methods
        function obj=ModelInitialValueVisitor(ctx,emitter)
            obj.Kind='ModelInitialValueVisitor';
            obj.ctx=ctx;
            obj.emitter=emitter;
            obj.VarNameStack={};
        end

        function doit(obj)
            obj.VarNameValueMap=containers.Map;
            obj.MdlDataStruct=struct;
            obj.showDebugMsg;
            if~obj.ctx.getPLCConfigInfo.generateAOIModel
                obj.checkInitialValueGlobalVars;
                obj.checkInitialValueforPrograms;
            end
            obj.checkInitialValueforFBs;
            obj.generateMdlDataFile;
        end

        function ret=hasInitialValue(obj)
            if obj.VarNameValueMap.Count
                ret=true;
            else
                ret=false;
            end
        end

        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            ret=true;
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSD,INUSL>
            import plccore.util.*;
            val_type=GetSLTypeName(host.type);
            expr=sprintf('%s(%s)',val_type,host.value);
            ret=eval(expr);
        end

        function ret=createScalarArrayValue(obj,array_type,array_value,sl_type)
            dims=array_type.dims;
            dim_txt=int2str(dims(1));
            if length(dims)>1
                for i=2:length(dims)
                    dim_txt=sprintf('%s, %d',dim_txt,dims(i));
                end
            else
                dim_txt=sprintf('%s, %d',dim_txt,1);
            end
            ret=eval(sprintf('zeros(%s, ''%s'')',dim_txt,sl_type));
            num_dim=array_type.numDims;
            idx=1;
            val_list=array_value.elemValueList;
            switch num_dim
            case 1
                for i=1:dims(1)
                    ret(i)=val_list{idx}.accept(obj,[]);
                    idx=idx+1;
                end
            case 2
                for i=1:dims(1)
                    for j=1:dims(2)
                        ret(i,j)=val_list{idx}.accept(obj,[]);
                        idx=idx+1;
                    end
                end
            case 3
                for i=1:dims(1)
                    for j=1:dims(2)
                        for k=1:dims(3)
                            ret(i,j,k)=val_list{idx}.accept(obj,[]);
                            idx=idx+1;
                        end
                    end
                end
            otherwise
                assert(false,sprintf('Unexpected array dim size: %d\n',num_dim));
            end
        end

        function ret=createStructArrayValue(obj,array_type,array_value)
            import plccore.type.*;
            dims=array_type.dims;
            val_dim=dims;
            num_dim=array_type.numDims;
            if num_dim==1
                val_dim=[val_dim,1];
            end
            idx=1;
            val_list=array_value.elemValueList;
            assert(TypeTool.isNamedType(array_type.elemType)||TypeTool.isPOUType(array_type.elemType));
            ret=Simulink.Bus.createMATLABStruct(array_type.elemType.name,[],val_dim);
            switch num_dim
            case 1
                for i=1:dims(1)
                    ret(i)=val_list{idx}.accept(obj,[]);
                    idx=idx+1;
                end
            case 2
                for i=1:dims(1)
                    for j=1:dims(2)
                        ret(i,j)=val_list{idx}.accept(obj,[]);
                        idx=idx+1;
                    end
                end
            case 3
                for i=1:dims(1)
                    for j=1:dims(2)
                        for k=1:dims(3)
                            ret(i,j,k)=val_list{idx}.accept(obj,[]);
                            idx=idx+1;
                        end
                    end
                end
            otherwise
                assert(false,sprintf('Unexpected array dim size: %d\n',num_dim));
            end
        end

        function ret=visitArrayValue(obj,host,input)%#ok<INUSD>
            import plccore.type.TypeTool;
            import plccore.util.*;
            array_type=host.type;
            elem_type=array_type.elemType;
            assert(~TypeTool.isArrayType(elem_type));
            sl_type=GetSLTypeName(elem_type);
            if TypeTool.isStructType(elem_type)||...
                TypeTool.isPOUType(elem_type)
                ret=obj.createStructArrayValue(array_type,host);
            else
                if strcmpi(sl_type,'boolean')
                    sl_type='logical';
                end
                ret=obj.createScalarArrayValue(array_type,host,sl_type);
            end
        end

        function ret=visitStructValue(obj,host,input)%#ok<INUSD>
            import plccore.type.*;
            assert(TypeTool.isNamedType(host.type)||TypeTool.isPOUType(host.type));
            ret=Simulink.Bus.createMATLABStruct(host.type.name);
            field_name_list=host.fieldNameList;
            field_value_list=host.fieldValueList;
            assert(length(field_name_list)==length(field_value_list));
            for i=1:length(field_name_list)
                ret.(field_name_list{i})=field_value_list{i}.accept(obj,[]);
            end
            if TypeTool.isPOUType(host.type)
                ret=obj.getFBLocalValue(ret,host.type);
            end
        end
    end

    methods(Access=private)
        function ret=cfg(obj)
            ret=obj.ctx.getPLCConfigInfo;
        end

        function ret=globalScope(obj)
            ret=obj.ctx.configuration.globalScope;
        end

        function checkInitialValueVar(obj,var,idx,prefix)



            import plccore.type.TypeTool;
            if~var.hasInitialValue
                return;
            end

            val=var.initialValue;
            val_type=val.type;
            if~TypeTool.isStructType(val_type)&&...
                ~TypeTool.isArrayType(val_type)&&...
                ~TypeTool.isPOUType(val_type)
                return;
            end

            if isempty(prefix)
                var_name=var.name;
            else
                var_name=sprintf('%s%d_%s',prefix,idx,var.name);
            end






            obj.appendToVarNameStack(var_name);
            assert(~obj.VarNameValueMap.isKey(var_name));
            sl_value=val.accept(obj,[]);
            obj.VarNameValueMap(var_name)=sl_value;
            obj.MdlDataStruct.(var_name)=sl_value;
            var.setTag(sprintf('%s.%s',obj.cfg.MdlDataStructName,var_name));
            obj.deleteFromVarNameStack(var_name)
        end

        function checkInitialValueGlobalVars(obj)
            obj.checkInitialValueforScope(obj.globalScope,0,'');
        end

        function checkInitialValueforScope(obj,scope,idx,prefix)
            var_list=scope.varList;
            num_var=length(var_list);
            for i=1:num_var
                var=var_list{i};
                obj.checkInitialValueVar(var,idx,prefix);
            end
        end

        function checkInitialValueforPOU(obj,pou,idx,prefix)
            obj.checkInitialValueforScope(pou.inputScope,idx,prefix);
            obj.checkInitialValueforScope(pou.outputScope,idx,prefix);
            obj.checkInitialValueforScope(pou.inOutScope,idx,prefix);
            obj.checkInitialValueforScope(pou.localScope,idx,prefix);
        end

        function checkInitialValueforPrograms(obj)
            import plccore.util.*;
            ApplyListFcnIdx(obj.globalScope.programList,...
            @(p,idx)obj.checkInitialValueforPOU(p,idx,'P'));
        end

        function checkInitialValueforFBs(obj)
            import plccore.util.*;
            fb_list=obj.globalScope.functionBlockList;
            if obj.ctx.getPLCConfigInfo.generateAOIModel
                aoi=obj.globalScope.getSymbol(obj.emitter.topAOIName);
                fb_list={aoi};
            end
            ApplyListFcnIdx(fb_list,...
            @(p,idx)obj.checkInitialValueforPOU(p,idx,'A'));
        end

        function generateMdlDataFile(obj)
            if~obj.hasInitialValue
                return;
            end

            filename=obj.cfg.MdlDataMATFileName;
            if isfile(filename)
                delete(filename);
            end

            expr=sprintf('%s = obj.MdlDataStruct;',obj.cfg.MdlDataStructName);
            eval(expr);
            save(filename,obj.cfg.MdlDataStructName);
        end

        function pou_val=getFBLocalValue(obj,pou_val,pou_type)
            import plccore.util.*;
            fb=obj.globalScope.getSymbol(pou_type.name);
            assert(isa(fb,'plccore.common.FunctionBlock'));
            var_list=fb.localScope.varList;
            for i=1:length(var_list)
                var=var_list{i};
                if var.hasInitialValue




                    obj.appendToVarNameStack(var.name);
                    pou_val.(var.name)=var.initialValue.accept(obj,[]);
                    var.setTag(obj.getInitialValueString());
                    obj.deleteFromVarNameStack(var.name)
                end
            end
        end

        function appendToVarNameStack(obj,var_name)


            obj.VarNameStack{end+1}=var_name;
        end

        function deleteFromVarNameStack(obj,var_name)


            idx=ismember(obj.VarNameStack,var_name);
            obj.VarNameStack(idx)=[];
        end

        function ret=getInitialValueString(obj)














            ret=[obj.cfg.MdlDataStructName,sprintf('.%s',obj.VarNameStack{1:end})];
        end
    end
end



