classdef LadderL5XParser<plccore.frontend.XMLParser



    properties(Access=protected)
PLCCtx
HasController
        ProgramNodeIRMap(:,2)cell={}
        AOINodeIRMap(:,2)cell={}
TaskNodeList
    end

    properties(Access=private)
udt
tag
array_stack
struct_stack
debug
pou
tskinfo
    end

    methods
        function obj=LadderL5XParser(file_path,cfg)
            import plccore.common.Context;
            import plccore.frontend.XMLParser;
            import plccore.visitor.*;
            obj@plccore.frontend.XMLParser(file_path);
            obj.debug=plcfeature('PLCLadderDebug');
            if obj.debug
                fprintf('------>Ladder parsing: %s\n\n',file_path);
            end
            obj.PLCCtx=Context();
            if nargin==1
                cfg=plccore.common.PLCConfigInfo;
            end
            obj.PLCCtx.setPLCConfigInfo(cfg);
            obj.HasController=false;
            obj.TaskNodeList={};
            obj.array_stack={};
            obj.struct_stack={};
            obj.parse;
            if obj.debug
                obj.ctx.configuration.globalScope.printUnknownType;
            end
            fixUnknownTypes=FixUnknownTypesVisitor(obj.ctx);
            fixUnknownTypes.doit;
            if obj.debug
                obj.ctx.configuration.globalScope.printUnknownType;
            end
            assert(~obj.ctx.configuration.globalScope.hasUnknownType);

            sanityCheck=SanityCheckLadderIR(obj.ctx);
            sanityCheck.startSanityCheck;

            if obj.debug
                fprintf('\n------>Ladder parsing done\n\n');
            end
        end

        function ret=ctx(obj)
            ret=obj.PLCCtx;
        end

        function ret=cfg(obj)
            ret=obj.ctx.getPLCConfigInfo;
        end

        function parse(obj)
            root=obj.root;
            if~strcmp(obj.name(root),'RSLogix5000Content')
                plccore.common.plcThrowError(...
                'plccoder:plccore:InvalidL5XFile',...
                plccore.util.Msg(obj.FilePath));
            end
            obj.visitChildren(root,@(n)obj.parseRSLogix5000Content(n));


            obj.parsePOURoutinesSecondRun(obj.ProgramNodeIRMap);
            obj.parsePOURoutinesSecondRun(obj.AOINodeIRMap);
            obj.parseTask;
        end
    end

    methods(Access=private)
        function parseRSLogix5000Content(obj,node)
            switch obj.name(node)
            case 'Controller'
                assert(~obj.HasController);
                obj.HasController=true;
                if obj.hasAttrib(node,'Name')
                    obj.ctx.createConfiguration(obj.attrib(node,'Name'));
                else
                    obj.ctx.createConfiguration('');
                end
                obj.visitChildren(node,@(n)obj.parseController(n));
            otherwise

            end
        end

        function appendTaskNode(obj,node)
            if~strcmp(obj.name(node),'Task')
                return;
            end

            obj.TaskNodeList{end+1}=node;
        end

        function reportUnprocessedNode(obj,node)
            fprintf(1,'===>Not processed: %s\n',obj.name(node));
        end

        function parseController(obj,node)
            switch obj.name(node)
            case 'DataTypes'
                obj.visitChildren(node,@(n)obj.parseUDT(n));
            case 'AddOnInstructionDefinitions'
                obj.visitChildren(node,@(n)obj.parseAOI(n));
            case 'Programs'
                obj.visitChildren(node,@(n)obj.parseProgram(n));
            case 'Tags'
                obj.visitChildren(node,@(n)obj.parseTag(n));
            case 'Tasks'
                obj.visitChildren(node,@(n)obj.appendTaskNode(n));
            case '#text'

            otherwise
                if obj.debug
                    obj.reportUnprocessedNode(node);
                end
            end
        end

        function parsePOURoutinesSecondRun(obj,POUNodeIRMap)

            node_count=size(POUNodeIRMap,1);
            for i=1:node_count
                POUNode=POUNodeIRMap{i,1};
                POUIR=POUNodeIRMap{i,2};
                obj.pou=struct;
                obj.pou.name=obj.attrib(POUNode,'Name');
                obj.pou.ir=POUIR;
                if(obj.debug)
                    fprintf(1,'\n\n--->Parse Ladder %s: %s\n#%d of %d\n',...
                    obj.pou.name,obj.pou.ir.kind,i,node_count);
                end
                obj.visitChildren(POUNode,@(n)obj.parsePOURoutineBody(n));
                obj.pou=[];
            end
        end

        function parseUDT(obj,node)
            if~strcmp(obj.name(node),'DataType')
                return;
            end
            obj.udt=struct;
            obj.udt.Name=obj.attrib(node,'Name');
            obj.udt.Description='';
            obj.udt.Fields={};
            if obj.debug
                fprintf(1,'UDT: %s\n',obj.udt.Name);
            end
            obj.visitChildren(node,@(n)obj.parseDataType(n));

            obj.createUDT;
        end

        function parseDataType(obj,node)
            switch obj.name(node)
            case 'Description'
                desc=obj.cdata(node);
                if~isempty(desc)
                    obj.udt.Description=desc;
                end
            case 'Members'
                obj.visitChildren(node,@(n)obj.parseDataTypeMember(n));
            otherwise

            end
        end

        function parseDataTypeMember(obj,node)
            if~strcmp(obj.name(node),'Member')
                return;
            end
            member=struct;
            member.Name=obj.attrib(node,'Name');
            member.DataType=obj.attrib(node,'DataType');
            member.Dimension=obj.attrib(node,'Dimension');
            member.Hidden=obj.attrib(node,'Hidden');
            if strcmp(member.DataType,'BIT')
                member.Target=obj.attrib(node,'Target');
                member.Index=obj.attrib(node,'BitNumber');
            end

            if strcmp(member.Hidden,'false')
                obj.udt.Fields{end+1}=member;
            end
        end

        function parseAOI(obj,node)
            if~strcmp(obj.name(node),'AddOnInstructionDefinition')
                return;
            end

            obj.pou=struct;
            obj.pou.name=obj.attrib(node,'Name');
            if obj.debug
                fprintf(1,'\n\n--->AOI: %s\n',obj.pou.name);
            end

            obj.pou.ir=obj.ctx.configuration.createFunctionBlock(obj.pou.name);
            obj.pou.arglist={};
            obj.pou.arg_order_checker=plccore.common.ArgOrderChecker(obj.pou.name);
            obj.pou.isPrescanEnabled=obj.isAOIRotineEnabled(node,'ExecutePrescan');
            obj.pou.isEnableInFalseEnabled=obj.isAOIRotineEnabled(node,'ExecuteEnableInFalse');
            obj.visitChildren(node,@(n)obj.parseAOIMemberFirstRun(n));
            obj.pou.ir.setArgList(obj.pou.arglist);


            obj.AOINodeIRMap{end+1,1}=node;
            obj.AOINodeIRMap{end,2}=obj.pou.ir;
            obj.pou=[];
        end

        function tf=isAOIRotineEnabled(obj,node,routineOptionName)
            tf=false;
            assert(ismember(routineOptionName,{'ExecuteEnableInFalse','ExecutePrescan'}),'Routine Option should be one amongst ''ExecuteEnableInFalse'', ''ExecutePrescan''');
            if obj.hasAttrib(node,routineOptionName)
                if strcmpi(obj.attrib(node,routineOptionName),'true')
                    tf=true;
                end
            end
        end

        function parseProgram(obj,node)
            if~strcmp(obj.name(node),'Program')
                return;
            end
            obj.pou=struct;
            obj.pou.ld=[];
            assert(obj.hasAttrib(node,'Name'));
            obj.pou.name=obj.attrib(node,'Name');
            if obj.debug
                fprintf(1,'\n\n--->Program: %s\n',obj.pou.name);
            end

            obj.pou.ir=obj.ctx.configuration.createProgram(obj.pou.name);
            if obj.hasAttrib(node,'MainRoutineName')
                main_routine_name=obj.attrib(node,'MainRoutineName');
                obj.pou.ir.setMainRoutineName(main_routine_name);
            end
            obj.pou.arglist={};

            obj.visitChildren(node,@(n)obj.parseProgramMemberFirstRun(n));
            obj.pou.ir.setArgList(obj.pou.arglist);


            obj.ProgramNodeIRMap{end+1,1}=node;
            obj.ProgramNodeIRMap{end,2}=obj.pou.ir;
            obj.pou=[];
        end

        function parseTag(obj,node)
            if~strcmp(obj.name(node),'Tag')&&...
                ~strcmp(obj.name(node),'Parameter')&&...
                ~strcmp(obj.name(node),'LocalTag')
                return;
            end
            obj.createLadderVar(node);
        end

        function checkArgOrder(obj,arg_name,usage)
            import plccore.common.*;
            switch lower(usage)
            case 'input'
                obj.pou.arg_order_checker.checkArg(arg_name,ArgType.InArg);
            case 'output'
                obj.pou.arg_order_checker.checkArg(arg_name,ArgType.OutArg);
            case 'inout'
                obj.pou.arg_order_checker.checkArg(arg_name,ArgType.InOutArg);
            otherwise

            end
        end

        function createLadderVar(obj,node)
            obj.tag=struct;
            obj.tag.Name=obj.attrib(node,'Name');
            if~isvarname(obj.tag.Name)&&~obj.PLCCtx.getPLCConfigInfo.supportUnknownInstruction
                plccore.common.plcThrowError(...
                'plccoder:plccore:UnsupportedVarName',obj.tag.Name);
            end

            obj.tag.isAlias=false;
            if obj.hasAttrib(node,'TagType')&&...
                strcmp(obj.attrib(node,'TagType'),'Alias')
                alias_ref=obj.attrib(node,'AliasFor');
                if contains(alias_ref,':')&&~obj.PLCCtx.getPLCConfigInfo.supportUnknownInstruction
                    plccore.common.plcThrowError(...
                    'plccoder:plccore:HardwareSlotNotSupportedAsAlias',alias_ref,obj.tag.Name);
                end
                obj.tag.isAlias=true;
            else
                dataType=obj.attrib(node,'DataType');
                if contains(dataType,':')&&~obj.PLCCtx.getPLCConfigInfo.supportUnknownInstruction
                    plccore.common.plcThrowError(...
                    'plccoder:plccore:HardwareSlotNotSupportedAsDataType',dataType,obj.tag.Name);
                end
                obj.tag.Type=obj.mapL5XType(dataType);
            end
            if obj.hasAttrib(node,'Dimensions')
                typ_dim=cell2mat(cellfun(@str2num,strsplit(obj.attrib(node,'Dimensions'),' '),'uniform',0));
                obj.tag.Type=plccore.type.ArrayType(typ_dim,obj.tag.Type);
            end

            obj.tag.Description='';
            obj.tag.Value=[];
            obj.tag.parentScope=[];
            obj.tag.L5KInitialValueFound=false;
            if obj.hasAttrib(node,'Usage')

                usage=obj.attrib(node,'Usage');
                if isa(obj.pou.ir,'plccore.common.Program')
                    if~strcmpi(usage,'local')&&~obj.PLCCtx.getPLCConfigInfo.supportUnknownInstruction
                        plccore.common.plcThrowError(...
                        'plccoder:plccore:UnsupportedVarScope',usage,obj.tag.Name,obj.pou.name);
                    end
                end
            else
                usage='Local';
            end

            obj.tag.parentScope=obj.getVarScope(usage);

            obj.tag.required=true;
            if obj.hasAttrib(node,'Required')
                if~strcmpi(obj.attrib(node,'Required'),'true')
                    obj.tag.required=false;
                end
            end

            obj.tag.visible=true;
            if obj.hasAttrib(node,'Visible')
                if~strcmpi(obj.attrib(node,'Visible'),'true')
                    obj.tag.visible=false;
                end
            end

            if~strcmpi(usage,'local')&&obj.tag.required
                obj.pou.arglist{end+1}=obj.tag.Name;
            end

            if obj.debug
                fprintf(1,'Tag: %s\n',obj.tag.Name);
            end
            if~obj.tag.isAlias&&isa(obj.tag.Type,'plccore.type.POUType')
                if obj.debug
                    fprintf(1,'Tag of type POU: %s\n',obj.attrib(node,'DataType'));
                end
            end

            obj.visitChildren(node,@(n)obj.parseTagInfo(n));


            if~obj.cfg.skipConformanceChecks
                if~(strcmpi(obj.tag.parentScope.kind,'InOut')||obj.tag.isAlias||...
                    ismember(obj.tag.Name,{'EnableIn','EnableOut'}))
                    if isempty(obj.tag.Value)&&obj.tag.L5KInitialValueFound
                        import plccore.common.plcThrowError;
                        if isempty(obj.pou)
                            plcThrowError('plccoder:plccore:UnsupportedL5XInitialValueFormatInController',...
                            obj.tag.Name);
                        else
                            plcThrowError('plccoder:plccore:UnsupportedL5XInitialValueFormatInPOU',...
                            obj.tag.Name,obj.pou.name);
                        end
                    end
                end
            end


            if obj.tag.isAlias
                obj.createAliasTag(node,obj.tag.parentScope);
            else
                obj.createVar;
            end

        end

        function scope=getVarScope(obj,usage)
            if isempty(obj.pou)
                scope=obj.ctx.configuration.globalScope;
            else
                switch lower(usage)
                case 'local'
                    scope=obj.pou.ir.localScope;
                case 'input'
                    scope=obj.pou.ir.inputScope;
                case 'output'
                    scope=obj.pou.ir.outputScope;
                case 'inout'
                    scope=obj.pou.ir.inOutScope;
                otherwise

                    if obj.debug
                        fprintf(1,'Unsupported usage of scope detected:data name : %s  : Usage :  %s . Defaulting to input scope',obj.tag.Name,usage);
                    end
                    scope=obj.pou.ir.inputScope;
                end
            end
        end

        function createUDT(obj)
            import plccore.type.StructType;
            [field_names,field_types]=obj.getUDTFields;
            udt_type=StructType(field_names,field_types);
            obj.ctx.configuration.globalScope.createNamedType(obj.udt.Name,...
            udt_type,obj.udt.Description);
        end

        function[field_names,field_types]=getUDTFields(obj)
            field_sz=length(obj.udt.Fields);
            field_names=cell(1,field_sz);
            field_types=cell(1,field_sz);
            for i=1:field_sz
                field_names{i}=obj.udt.Fields{i}.Name;
                field_types{i}=obj.getUDTFieldType(obj.udt.Fields{i});
            end
        end

        function typ=getUDTFieldType(obj,field_info)
            typ_name=field_info.DataType;
            if strcmp(typ_name,'BIT')
                typ=obj.mapL5XType('BOOL');
                return;
            end
            typ=obj.mapL5XType(typ_name);
            typ_dim=field_info.Dimension;
            if~strcmp(typ_dim,'0')
                typ=plccore.type.ArrayType(str2double(typ_dim),typ);
            end
        end

        function typ=mapL5XType(obj,typ_name)
            import plccore.frontend.L5XTypeMap;
            import plccore.type.POUType;
            typ=L5XTypeMap.map(typ_name);
            if isempty(typ)
                if obj.ctx.configuration.globalScope.hasSymbol(typ_name)
                    sym=obj.ctx.configuration.globalScope.getSymbol(typ_name);
                    if isa(sym,'plccore.common.FunctionBlock')
                        typ=POUType(sym);
                        return;
                    end
                    assert(isa(sym,'plccore.type.NamedType'));
                    typ=sym;
                elseif obj.ctx.builtinScope.hasSymbol(typ_name)
                    sym=obj.ctx.builtinScope.getSymbol(typ_name);
                    assert(isa(sym,'plccore.type.AbstractType'));
                    typ=sym;
                elseif contains(typ_name,':')
                    typ=obj.ctx.builtinScope.getIOSlotType(typ_name);
                else
                    if obj.debug
                        fprintf(1,'\n--->Unknown type %s\n\n',typ_name);
                    end
                    typ=obj.ctx.configuration.globalScope.createUnknownType(typ_name);
                end
            end
        end

        function parseTagInfo(obj,node)
            switch obj.name(node)
            case 'Description'
                desc=obj.cdata(node);
                if~isempty(desc)
                    obj.tag.Description=desc;
                end
            case{'Data','DefaultData'}
                if obj.hasAttrib(node,'Format')
                    if strcmp(obj.attrib(node,'Format'),'L5K')
                        obj.tag.L5KInitialValueFound=true;
                    elseif strcmp(obj.attrib(node,'Format'),'Decorated')
                        obj.visitChildren(node,@(n)obj.parseTagValue(n));
                    end
                end
            otherwise

            end
        end

        function parseTagValue(obj,node)
            if strcmp(obj.name(node),'#text')
                return;
            end
            assert(isempty(obj.tag.Value));
            obj.tag.Value=obj.parseDataValue(node);
        end

        function val=parseDataValue(obj,node)

            val=[];
            switch obj.name(node)
            case 'DataValue'
                val=obj.parseSimpleValue(node);
            case 'Structure'
                val=obj.parseStructValue(node);
            case 'Array'
                val=obj.parseArrayValue(node);
            otherwise
                if obj.debug
                    fprintf(1,'Unhandled value\n');
                end
            end
        end

        function val=getSimpleValue(obj,node,typ,radix)
            import plccore.common.*;
            import plccore.type.*;
            val_txt=obj.attrib(node,'Value');
            if isa(typ,'plccore.type.BOOLType')
                switch val_txt
                case '1'
                    val=ConstTrue;
                case '0'
                    val=ConstFalse;
                otherwise
                    assert(false,sprintf('Unexpected bool value: %s',val_txt));
                end
                return
            end

            if TypeTool.isRealType(typ)
                val=ConstValue(typ,val_txt);
                return;
            end

            if~TypeTool.isIntegerType(typ)
                plccore.common.plcThrowError(...
                'plccoder:plccore:IntegerTypeExpected',...
                plccore.util.Msg(typ.toString));
            end

            if isempty(radix)
                radix='Decimal';
            end

            switch radix
            case 'Decimal'
                val=ConstValue(typ,val_txt);
                return;
            case 'Binary'
                val_txt=val_txt(3:end);
                val_txt=strrep(val_txt,'_','');
                val=ConstValue(typ,num2str(bin2dec(val_txt)));
                return;
            case 'Hex'
                val_txt=val_txt(4:end);
                val_txt=strrep(val_txt,'_','');
                val=ConstValue(typ,num2str(hex2dec(val_txt)));
                return;
            otherwise
                plccore.common.plcThrowError(...
                'plccoder:plccore:UnsupportedRadixFormat',...
                plccore.util.Msg(radix));
            end
        end

        function val=parseSimpleValue(obj,node)
            import plccore.frontend.L5XTypeMap;
            typ=L5XTypeMap.map(obj.attrib(node,'DataType'));
            if obj.hasAttrib(node,'Radix')
                radix=obj.attrib(node,'Radix');
            else
                radix=[];
            end
            val=obj.getSimpleValue(node,typ,radix);
        end

        function val=parseStructValue(obj,node)
            import plccore.common.StructValue;
            import plccore.type.TypeTool;
            obj.struct_stack{end+1}=struct;
            typ=obj.mapL5XType(obj.attrib(node,'DataType'));
            assert(TypeTool.isStructType(typ)||...
            TypeTool.isUnknownType(typ)||...
            TypeTool.isPOUType(typ));
            obj.struct_stack{end}.Type=typ;
            obj.struct_stack{end}.Names={};
            obj.struct_stack{end}.Values={};
            obj.visitChildren(node,@(n)obj.parseStructMember(n));
            val=StructValue(typ,obj.struct_stack{end}.Names,obj.struct_stack{end}.Values);
            obj.struct_stack=obj.struct_stack(1:end-1);
        end

        function parseStructMember(obj,node)

            if strcmp(obj.name(node),'#text')
                return;
            end
            switch obj.name(node)
            case 'DataValueMember'
                val=obj.parseSimpleValue(node);
            case 'ArrayMember'
                val=obj.parseArrayValue(node);
            case 'StructureMember'
                val=obj.parseStructValue(node);
            otherwise
                if obj.debug
                    fprintf(1,'Unhandled value\n');
                end
                return;
            end
            obj.struct_stack{end}.Names{end+1}=obj.attrib(node,'Name');
            obj.struct_stack{end}.Values{end+1}=val;
        end

        function val=parseArrayValue(obj,node)
            import plccore.type.ArrayType;
            import plccore.common.ArrayValue;
            import plccore.type.TypeTool;
            obj.array_stack{end+1}={};
            typ=obj.mapL5XType(obj.attrib(node,'DataType'));
            dim=cell2mat(cellfun(@str2num,strsplit(obj.attrib(node,'Dimensions'),','),'uniform',0));
            if obj.hasAttrib(node,'Radix')
                radix=obj.attrib(node,'Radix');
            else
                radix=[];
            end
            obj.visitChildren(node,@(n)obj.parseArrayElementValue(n,typ,radix));
            assert(length(obj.array_stack{end})==prod(dim),'array value size mismatch');
            val=ArrayValue(ArrayType(dim,typ),obj.array_stack{end});
            obj.array_stack=obj.array_stack(1:end-1);
        end

        function parseArrayElementValue(obj,node,typ,radix)
            import plccore.type.*;
            if~strcmp(obj.name(node),'Element')
                return;
            end
            if~obj.hasAttrib(node,'Value')
                child_list=obj.childList(node);
                for i=1:length(child_list)
                    if strcmp(obj.name(child_list{i}),'Structure')
                        obj.array_stack{end}{end+1}=obj.parseStructValue(child_list{i});
                        return;
                    end
                end
                assert(false,'Unexpected array element struct value');
            end

            if isempty(radix)
                plccore.common.plcThrowError(...
                'plccoder:plccore:RadixFormatNotFound');
            end
            obj.array_stack{end}{end+1}=obj.getSimpleValue(node,typ,radix);
        end





        function createVar(obj)

            if isempty(obj.pou)
                var=obj.tag.parentScope.createVar(obj.tag.Name,...
                obj.tag.Type,...
                obj.tag.Description,...
                obj.tag.required,...
                obj.tag.visible,...
                0);
            else
                if isfield(obj.pou,'paramIndex')
                    var=obj.tag.parentScope.createVar(obj.tag.Name,...
                    obj.tag.Type,...
                    obj.tag.Description,...
                    obj.tag.required,...
                    obj.tag.visible,...
                    obj.pou.paramIndex);
                    obj.pou.paramIndex=obj.pou.paramIndex+1;
                else
                    var=obj.tag.parentScope.createVar(obj.tag.Name,...
                    obj.tag.Type,...
                    obj.tag.Description,...
                    obj.tag.required,...
                    obj.tag.visible,...
                    0);
                end
            end
            if~isempty(obj.tag.Value)
                var.setInitialValue(obj.tag.Value);
            end
        end

        function createAliasTag(obj,node,scope)
            alias_name=obj.attrib(node,'Name');
            alias_ref=obj.attrib(node,'AliasFor');

            aliasInfo=scope.createAliasInfo(alias_name,alias_ref);
            if isempty(obj.pou)
                obj.ctx.configuration.appendToAliasVarsMap(aliasInfo);
            else
                obj.pou.ir.appendToAliasVarsMap(aliasInfo);
            end
        end

        function parseProgramMemberFirstRun(obj,node)
            switch obj.name(node)
            case 'Tags'
                obj.visitChildren(node,@(n)obj.parseTag(n));
            case 'Routines'
                obj.visitChildren(node,@(n)obj.parseRoutineDecl(n));
            case '#text'

            otherwise
                if obj.debug
                    obj.reportUnprocessedNode(node);
                end
            end
        end

        function parseAOIMemberFirstRun(obj,node)
            switch obj.name(node)
            case 'Parameters'
                obj.pou.paramIndex=1;
                obj.visitChildren(node,@(n)obj.parseParameter(n));
            case 'LocalTags'
                obj.pou.paramIndex=1;
                obj.visitChildren(node,@(n)obj.parseTag(n));
            case 'Routines'
                obj.visitChildren(node,@(n)obj.parseRoutineDecl(n));
            case{'#text'}

            otherwise
                if obj.debug
                    obj.reportUnprocessedNode(node);
                end
            end
        end

        function parsePOURoutineBody(obj,node)
            switch obj.name(node)
            case 'Parameters'
            case 'LocalTags'
            case 'Routines'
                obj.visitChildren(node,@(n)obj.parseRoutineBody(n));
            case{'#text','Tags'}

            otherwise
                if obj.debug
                    obj.reportUnprocessedNode(node);
                end
            end
        end

        function parseParameter(obj,node)
            if~strcmp(obj.name(node),'Parameter')
                return;
            end
            obj.createLadderVar(node);
        end

        function parseLocalData(obj,node)
            if~strcmp(obj.name(node),'LocalTag')
                return;
            end
            if obj.debug
                fprintf(1,'process localtag: %s\n',obj.attrib(node,'Name'));
            end
            obj.createLadderVar(node);
        end

        function parseRoutineDecl(obj,node)
            if~strcmp(obj.name(node),'Routine')
                return;
            end

            assert(obj.hasAttrib(node,'Name'));
            routine_name=obj.attrib(node,'Name');

            if isa(obj.pou.ir,'plccore.common.FunctionBlock')
                if strcmpi(obj.PLCCtx.targetIDE,'studio5000')||strcmpi(obj.PLCCtx.targetIDE,'rslogix5000')
                    aoi_name=obj.pou.ir.name;
                    assert(ismember(routine_name,{'Logic','EnableInFalse','Prescan'}),'Ladder import support ''Logic'', ''EnableInFalse'', ''Prescan'' routines for Rockwell AOIs, however routine ''%s'' was found in AOI ''%s''',routine_name,aoi_name);
                end
            end

            if~obj.isAOIRoutineSupported(routine_name)&&~obj.cfg.allowDisabledAOIRoutine
                import plccore.common.plcThrowError;
                plcThrowError('plccoder:plccore:DisabledAOIRoutine',routine_name,obj.pou.name);
            end

            obj.pou.ir.createRoutine(routine_name);
        end

        function tf=isAOIRoutineSupported(obj,routineName)
            tf=true;
            if strcmpi(routineName,'Prescan')
                if~obj.pou.isPrescanEnabled
                    tf=false;
                end
            elseif strcmpi(routineName,'EnableInFalse')
                if~obj.pou.isEnableInFalseEnabled
                    tf=false;
                end
            end
        end

        function parseRoutineBody(obj,node)
            if~strcmp(obj.name(node),'Routine')
                return;
            end
            import plccore.ladder.LadderDiagram;
            routine=obj.pou.ir.localScope.getSymbol(obj.attrib(node,'Name'));
            assert(isa(routine,'plccore.common.Routine'));
            owner_pou=routine;

            obj.pou.ld=LadderDiagram.createLadderDiagram(owner_pou);
            if(obj.debug)
                fprintf(1,'\n--->Parse routine %s of %s\n',...
                owner_pou.name,owner_pou.kind);
            end
            obj.visitChildren(node,@(n)obj.parseRoutineMember(n));
        end

        function parseRoutineMember(obj,node)
            if~strcmp(obj.name(node),'RLLContent')
                return;
            end
            obj.visitChildren(node,@(n)obj.parseRung(n));
        end

        function parseRung(obj,node)
            if~strcmp(obj.name(node),'Rung')
                return;
            end
            if obj.debug
                fprintf('--->Rung #: %s\n',obj.attrib(node,'Number'));
            end
            child_list=obj.childList(node);
            rungComment='';
            for i=1:length(child_list)

                child=child_list{i};
                if strcmp(obj.name(child),'Text')

                    rungText=obj.cdata(child);
                    rungText=strrep(rungText,';','');
                elseif strcmp(obj.name(child),'Comment')

                    rungComment=obj.cdata(child);
                end
            end

            obj.createRung(rungText,rungComment);
        end

        function createRung(obj,rungText,rungComment)
            rungIR=plccore.frontend.L5X.L5XRung2IR(obj.ctx,obj.pou.ir,rungText,[]);

            currentrungIR=obj.pou.ld.createRung(rungComment);
            if isempty(rungIR.ir)
                currentrungIR.clear();
            elseif isa(rungIR.ir,'plccore.ladder.RungOpSeq')

                rungOps=rungIR.ir.rungOps;
                for v=1:length(rungOps)
                    currentrungIR.appendRungOp(rungOps{v});
                end
            else
                currentrungIR.appendRungOp(rungIR.ir);
            end
        end

        function parseTaskProgram(obj,node)
            if~strcmp(obj.name(node),'ScheduledProgram')
                return;
            end
            obj.tskinfo.proglist{end+1}=obj.attrib(node,'Name');
        end

        function parseTaskNodeInfo(obj,node)
            switch obj.name(node)
            case 'Description'
                desc=obj.cdata(node);
                if~isempty(desc)
                    obj.tskinfo.Description=desc;
                end
            case 'ScheduledPrograms'
                obj.visitChildren(node,@(n)obj.parseTaskProgram(n));
            case 'EventInfo'
                assert(strcmp(obj.tskinfo.Type,'EVENT'));
                obj.tskinfo.EventTrigger=obj.attrib(node,'EventTrigger');
            case '#text'

            otherwise
                if obj.debug
                    obj.reportUnprocessedNode(node);
                end
            end
        end

        function parseTaskNode(obj,node)
            import plccore.common.TaskClass;
            obj.tskinfo=struct;
            obj.tskinfo.Name=obj.attrib(node,'Name');
            obj.tskinfo.Type=obj.attrib(node,'Type');
            if strcmp(obj.tskinfo.Type,'PERIODIC')||...
                strcmp(obj.tskinfo.Type,'EVENT')
                obj.tskinfo.Rate=obj.attrib(node,'Rate');
            end
            obj.tskinfo.Priority=obj.attrib(node,'Priority');
            obj.tskinfo.Watchdog=obj.attrib(node,'Watchdog');
            class_name='';
            if obj.hasAttrib(node,'Class')
                class_name=obj.attrib(node,'Class');
            end
            obj.tskinfo.Class=TaskClass.getClass(class_name);
            obj.tskinfo.Description='';
            obj.tskinfo.proglist={};
            obj.visitChildren(node,@(n)obj.parseTaskNodeInfo(n));
            obj.createTask;
        end

        function createTask(obj)
            tinfo=obj.tskinfo;
            switch tinfo.Type
            case 'CONTINUOUS'
                task=obj.ctx.configuration.createContinuousTask(tinfo.Name,...
                tinfo.Description,tinfo.Priority,tinfo.Watchdog,...
                tinfo.Class);
            case 'PERIODIC'
                task=obj.ctx.configuration.createPeriodicTask(tinfo.Name,...
                tinfo.Description,tinfo.Priority,tinfo.Watchdog,...
                tinfo.Class,tinfo.Rate);
            case 'EVENT'
                task=obj.ctx.configuration.createEventTask(tinfo.Name,...
                tinfo.Description,tinfo.Priority,tinfo.Watchdog,...
                tinfo.Class,tinfo.Rate,tinfo.EventTrigger);
            otherwise
                assert(false);
            end

            gscope=obj.ctx.configuration.globalScope;
            for i=1:length(tinfo.proglist)
                prog_name=tinfo.proglist{i};
                prog=gscope.getSymbol(prog_name);
                assert(isa(prog,'plccore.common.Program'));
                task.appendProgram(prog);
            end
        end

        function parseTask(obj)
            for i=1:length(obj.TaskNodeList)
                obj.parseTaskNode(obj.TaskNodeList{i});
            end
        end
    end
end



