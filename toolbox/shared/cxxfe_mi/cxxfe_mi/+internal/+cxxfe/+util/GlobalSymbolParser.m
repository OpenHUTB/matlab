


classdef GlobalSymbolParser<handle

    properties(Constant,Hidden)
        KindSet=[-2,-1,0,1,2,3]
    end

    properties(SetAccess=private,GetAccess=private)
IsFile
Kind
    end

    properties(SetAccess=private)
Symbols
    end

    methods(Access=protected)



        function this=GlobalSymbolParser(isFile,kind)
            this.IsFile=isFile;
            this.Kind=kind;
            this.Symbols=[];
        end
    end

    methods(Static)




        function varargout=parseFile(fileName,varargin)
            [varargout{1:nargout}]=internal.cxxfe.util.GlobalSymbolParser.invoke(true,fileName,varargin{:});
        end




        function varargout=parseText(textBuffer,varargin)
            [varargout{1:nargout}]=internal.cxxfe.util.GlobalSymbolParser.invoke(false,textBuffer,varargin{:});
        end

    end

    methods(Static,Access=private)



        function[msgs,out]=invoke(isFile,fileOrText,feOpts,kind)

            if nargin<4
                kind=0;
            end

            if nargin<3||isempty(feOpts)
                feOpts=internal.cxxfe.FrontEndOptions();
            end

            assert(ismember(double(kind),internal.cxxfe.util.GlobalSymbolParser.KindSet));

            if kind==-1||kind==3

                opts=deepCopy(feOpts);
                if kind==-1
                    opts.ExtractDependenciesOnly=true;
                else
                    opts.KeepCommentsPosition=true;
                    opts.KeepCommentsText=true;
                end
            else
                opts=feOpts;
            end

            obj=internal.cxxfe.util.GlobalSymbolParser(isFile,kind);
            cb={@frontEndHandler,obj,'%options','%file'};

            if isFile
                msgs=internal.cxxfe.FrontEnd.parseFile(fileOrText,opts,cb);
            else
                msgs=internal.cxxfe.FrontEnd.parseText(fileOrText,opts,cb);
            end


            if kind<=0
                out=obj.Symbols;
            else
                out=obj;
            end

            function frontEndHandler(obj,feOptions,fName)
                if~obj.IsFile
                    fName={''};
                end
                [~,obj.Symbols]=global_symbols_parser_mex(fName,feOptions,obj.Kind);
            end

        end
    end

    methods(Access=protected)



        function out=makeFullname(this,name,nsIdx)
            if nargin<3
                nsIdx=[];
            end
            out=name;
            if~isempty(nsIdx)
                nsName=this.getNamespaceFullName(nsIdx);
                if~isempty(nsName)
                    out=[nsName,'::',out];
                end
            end
        end
    end

    methods



        function out=getSymbols(this)

            out=this.Symbols;
        end

        function out=getTypes(this)

            out=this.Symbols.DataTypes;
        end

        function out=getVariables(this)

            out=this.Symbols.Variables;
        end

        function out=getFiles(this)

            out=this.Symbols.Files;
        end

        function out=getFunctions(this)

            out=this.Symbols.Functions;
        end

        function out=getMacros(this)

            out=this.Symbols.Macros;
        end

        function out=getNamespaces(this)

            out=this.Symbols.Namespaces;
        end




        function out=getNumTypes(this)

            out=0;
            if~isempty(this.Symbols)&&isfield(this.Symbols,'DataTypes')
                out=numel(this.Symbols.DataTypes);
            end
        end

        function out=getTypeRecord(this,typeIdx)

            out=this.Symbols.DataTypes{typeIdx};
        end

        function typeIdx=getTypePointedTo(this,typeIdx)

            if this.isTypePointer(typeIdx)
                typeIdx=this.Symbols.DataTypes{typeIdx}.BaseIdx;
            end
        end

        function typeIdx=getTypeArrayElement(this,typeIdx)

            if this.isTypeArray(typeIdx)
                typeIdx=this.Symbols.DataTypes{typeIdx}.BaseIdx;
            end
        end

        function typeIdx=getTypeVectorElement(this,typeIdx)

            if this.isTypeVector(typeIdx)
                typeIdx=this.skipTypeAttributes(typeIdx);
                typeIdx=this.Symbols.DataTypes{typeIdx}.BaseIdx;
            end
        end

        function typeIdx=getTypeBottomTypedef(this,typeIdx)

            while this.isTypeTypedef(typeIdx)
                typeIdx=this.Symbols.DataTypes{typeIdx}.BaseIdx;
            end
        end

        function typeIdx=getTypeBottomTyperef(this,typeIdx)

            while(this.isTypeQualified(typeIdx)||this.isTypeTypedef(typeIdx)||...
                this.isTypeAttribute(typeIdx))
                typeIdx=this.Symbols.DataTypes{typeIdx}.BaseIdx;
            end
        end

        function typeIdx=getTypeUnqualified(this,typeIdx)

            while(this.isTypeQualified(typeIdx))
                typeIdx=this.Symbols.DataTypes{typeIdx}.BaseIdx;
            end
        end

        function typeIdx=getTypeBase(this,typeIdx)

            if this.isTypeQualified(typeIdx)||...
                this.isTypeTypedef(typeIdx)||this.isTypePointer(typeIdx)||...
                this.isTypeArray(typeIdx)||this.isTypeVector(typeIdx)||...
                this.isTypeTypeop(typeIdx)
                typeIdx=this.skipTypeAttributes(typeIdx);
                typeIdx=this.Symbols.DataTypes{typeIdx}.BaseIdx;
            end
        end

        function typeIdx=getTypeBottom(this,typeIdx)

            while 1
                baseId=this.getTypeBase(typeIdx);
                if baseId==typeIdx
                    break
                end
                typeIdx=baseId;
            end
        end

        function typeIdx=skipTypeAttributes(this,typeIdx)

            while(this.isTypeAttribute(typeIdx))
                typeIdx=this.Symbols.DataTypes{typeIdx}.BaseIdx;
            end
        end

        function out=getTypeQualifier(this,typeIdx)

            out=[];
            if this.isTypeQualified(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.Ctor;
            end
        end

        function out=getTypeOperatorKind(this,typeIdx)

            out=[];
            if this.isTypeTypeop(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.Kind;
            end
        end

        function out=getTypeOperatorTypeArg(this,typeIdx)

            out=[];
            if this.isTypeTypeop(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.TypeArgIdx;
            end
        end

        function out=isTypeConst(this,typeIdx)

            out=contains(this.Symbols.DataTypes{typeIdx}.Ctor,"const");
        end

        function out=isTypeVolatile(this,typeIdx)

            out=contains(this.Symbols.DataTypes{typeIdx}.Ctor,"volatile");
        end

        function out=isTypeRestrict(this,typeIdx)

            out=contains(this.Symbols.DataTypes{typeIdx}.Ctor,"restrict");
        end

        function out=isTypeQualifier(this,typeIdx)


            out=contains(this.Symbols.DataTypes{typeIdx}.Ctor,"qualifier");
        end

        function out=isTypeVoid(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'void');
        end

        function out=isTypeQualified(this,typeIdx)
            out=this.isTypeConst(typeIdx)||this.isTypeVolatile(typeIdx)||this.isTypeRestrict(typeIdx)||...
            this.isTypeQualifier(typeIdx)||contains(this.Symbols.DataTypes{typeIdx}.Ctor,"qualified");
        end

        function out=isTypeAttribute(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'typeattr');
        end

        function out=isTypeTypeop(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'typeop');
        end

        function out=isTypeError(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'error');
        end

        function out=isTypeUnknown(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'unknown');
        end

        function out=isTypeTypedef(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'typedef');
        end

        function out=isTypePointer(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'pointer');
        end

        function out=isTypeArray(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'array');
        end

        function out=isTypeVector(this,typeIdx)

            typeIdx=this.skipTypeAttributes(typeIdx);
            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'vector');
        end

        function out=isTypeClass(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'class');
        end

        function out=isTypeStruct(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'struct');
        end

        function out=isTypeUnion(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'union');
        end

        function out=isTypeAggregate(this,typeIdx)

            out=this.isTypeClass(typeIdx)||...
            this.isTypeStruct(typeIdx)||...
            this.isTypeUnion(typeIdx);
        end

        function out=isTypeEnum(this,typeIdx)
            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'enum');
        end

        function out=isTypeChar(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'char');
        end

        function out=isTypeInteger(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'integer');
        end

        function out=isTypeFloat(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'float');
        end

        function out=isTypeFunction(this,typeIdx)

            out=strcmpi(this.Symbols.DataTypes{typeIdx}.Ctor,'function');
        end

        function out=isTypeSigned(this,typeIdx)

            if this.isTypeInteger(typeIdx)||this.isTypeChar(typeIdx)||...
                this.isTypeEnum(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.IsSigned;
            elseif this.isTypeFloat(typeIdx)
                out=true;
            else
                out=false;
            end
        end

        function out=getTypeSize(this,typeIdx)

            if this.isTypeInteger(typeIdx)||this.isTypeChar(typeIdx)||...
                this.isTypeEnum(typeIdx)||this.isTypeFloat(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.Size;
            else
                out=-1;
            end
        end

        function out=getTypeName(this,typeIdx)

            out=[];

            if this.isTypeInteger(typeIdx)||this.isTypeFloat(typeIdx)||...
                this.isTypeTypedef(typeIdx)||this.isTypeEnum(typeIdx)||...
                this.isTypeClass(typeIdx)||...
                this.isTypeStruct(typeIdx)||this.isTypeUnion(typeIdx)

                out=this.Symbols.DataTypes{typeIdx}.Name;
            elseif this.isTypeVoid(typeIdx)
                out='void';
            end
        end

        function out=getTypeSLName(this,typeIdx)

            out=[];
            type=this.getTypeRecord(typeIdx);

            if this.isTypeInteger(typeIdx)
                out='int';
                if type.IsSigned==0
                    out=sprintf('u%s',out);
                end

                out=sprintf('%s%d',out,type.Size*8);

            elseif this.isTypeFloat(typeIdx)
                if type.Size==4
                    out='single';
                elseif type.Size==8
                    out='double';
                else
                    out='long double';
                end

            elseif this.isTypeChar(typeIdx)
                out='uint8';

            elseif this.isTypeTypedef(typeIdx)||this.isTypeEnum(typeIdx)||...
                this.isTypeStruct(typeIdx)||this.isTypeUnion(typeIdx)

                out=this.Symbols.DataTypes{typeIdx}.Name;
            else

            end
        end

        function out=getTypeRTWName(this,typeIdx)

            out=[];
            type=this.getTypeRecord(typeIdx);

            if this.isTypeInteger(typeIdx)
                out='int';
                if type.IsSigned==0
                    out=sprintf('u%s',out);
                end

                out=sprintf('%s%d_T',out,type.Size*8);

            elseif this.isTypeFloat(typeIdx)
                if type.Size==4
                    out='real32_T';
                elseif type.Size==8
                    out='real_T';
                else
                    out='long double';
                end

            elseif this.isTypeChar(typeIdx)
                out='char_T';

            elseif this.isTypeTypedef(typeIdx)||this.isTypeEnum(typeIdx)||...
                this.isTypeStruct(typeIdx)||this.isTypeUnion(typeIdx)

                out=this.Symbols.DataTypes{typeIdx}.Name;
            else

            end
        end

        function out=getTypeCName(this,typeIdx)

            out=[];

            if this.isTypeInteger(typeIdx)||this.isTypeFloat(typeIdx)||...
                this.isTypeTypedef(typeIdx)||this.isTypeEnum(typeIdx)||...
                this.isTypeClass(typeIdx)||...
                this.isTypeStruct(typeIdx)||this.isTypeUnion(typeIdx)

                out=this.Symbols.DataTypes{typeIdx}.Name;

            elseif this.isTypeChar(typeIdx)
                out='char';

            else

            end
        end

        function out=getTypeNumDimensions(this,typeIdx)

            out=0;
            if isTypeArray(typeIdx)
                out=numel(this.Symbols.DataTypes{typeIdx}.Dims);
            end
        end

        function out=getTypeDimensions(this,typeIdx)

            out=[];
            if this.isTypeArray(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.Dims;
            end
        end

        function out=getTypeWidth(this,typeIdx)

            out=0;
            if this.isTypeArray(typeIdx)||this.isTypeVector(typeIdx)
                typeIdx=this.skipTypeAttributes(typeIdx);
                out=this.Symbols.DataTypes{typeIdx}.Width;
            end
        end

        function out=getTypeElements(this,typeIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo;
            end
        end

        function out=getTypeNumElements(this,typeIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=numel(this.Symbols.DataTypes{typeIdx}.MemberInfo.Names);
            end
        end

        function out=getTypeElementNames(this,typeIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.Names;
            end
        end

        function out=getTypeElementTypes(this,typeIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.TypeIdx;
            end
        end

        function out=getTypeElementAccesses(this,typeIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.Access;
            end
        end

        function out=getTypeElementAccess(this,typeIdx,eleIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.Access{eleIdx};
            end
        end

        function out=getTypeElementName(this,typeIdx,eleIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.Names{eleIdx};
            end
        end

        function out=getTypeElementType(this,typeIdx,eleIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.TypeIdx(eleIdx);
            end
        end

        function out=getTypeElementBitSizes(this,typeIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.BitSize;
            end
        end

        function out=getTypeElementBitSize(this,typeIdx,eleIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.BitSize{eleIdx};
            end
        end

        function out=getTypeElementIsBitFields(this,typeIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.IsBitField;
            end
        end

        function out=getTypeElementIsBitField(this,typeIdx,eleIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.IsBitField{eleIdx};
            end
        end

        function out=getTypeElementPositions(this,typeIdx)
            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.Position;
            end
        end

        function out=getTypeElementPosition(this,typeIdx,eleIdx)
            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.Position{eleIdx};
            end
        end

        function out=getTypeClassInfo(this,typeIdx)

            out=[];
            if this.isTypeAggregate(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.MemberInfo.ClassInfo;
            end
        end

        function out=getTypeMembers(this,typeIdx)
            out=this.getTypeElements(typeIdx);
        end

        function out=getTypeNumMembers(this,typeIdx)
            out=this.getTypeNumElements(typeIdx);
        end

        function out=getTypeMemberNames(this,typeIdx)
            out=this.getTypeElementNames(typeIdx);
        end

        function out=getTypeMemberTypes(this,typeIdx)
            out=this.getTypeElementTypes(typeIdx);
        end

        function out=getTypeMemberAccesses(this,typeIdx)
            out=this.getTypeElementAccesses(typeIdx);
        end

        function out=getTypeMemberAccess(this,typeIdx,eleIdx)
            out=this.getTypeElementAccess(typeIdx,eleIdx);
        end

        function out=getTypeMemberName(this,typeIdx,eleIdx)
            out=this.getTypeElementName(typeIdx,eleIdx);
        end

        function out=getTypeMemberFullName(this,typeIdx,eleIdx)
            out=[this.getTypeFullName(typeIdx),'::',this.getTypeElementName(typeIdx,eleIdx)];
        end

        function out=getTypeMemberType(this,typeIdx,eleIdx)
            out=this.getTypeElementType(typeIdx,eleIdx);
        end

        function out=getTypeMemberBitSizes(this,typeIdx)
            out=this.getTypeElementBitSizes(typeIdx);
        end

        function out=getTypeMemberBitSize(this,typeIdx,eleIdx)
            out=this.getTypeElementBitSize(typeIdx,eleIdx);
        end

        function out=getTypeMemberIsBitFields(this,typeIdx)
            out=this.getTypeElementIsBitFields(typeIdx);
        end

        function out=getTypeMemberIsBitField(this,typeIdx,eleIdx)
            out=this.getTypeElementIsBitField(typeIdx,eleIdx);
        end

        function out=getTypeMemberPositions(this,typeIdx)
            out=this.getTypeElementPositions(typeIdx);
        end

        function out=getTypeMemberPosition(this,typeIdx,eleIdx)
            out=this.getTypeElementPosition(typeIdx,eleIdx);
        end

        function out=getTypeNumBaseClasses(this,typeIdx)
            out=numel(this.getBaseClasses(typeIdx));
        end

        function out=getTypeBaseClasses(this,typeIdx)
            out=[];
            if this.isTypeAggregate(typeIdx)
                mInfo=this.Symbols.DataTypes{typeIdx}.MemberInfo;
                if~isempty(mInfo)&&~isempty(mInfo.ClassInfo)
                    out=mInfo.ClassInfo.BaseClasses;
                end
            end
        end

        function out=getTypeBaseClass(this,typeIdx,eIdx)
            out=[];
            members=this.getTypeBaseClasses(typeIdx);
            if eIdx<=numel(members)
                out=members{eIdx};
            end
        end

        function out=getTypeBaseClassName(this,typeIdx,eIdx)
            out=[];
            idx=this.getTypeBaseClassType(typeIdx,eIdx);
            if~isempty(idx)
                out=this.getTypeFullName(idx);
            end
        end

        function out=getTypeBaseClassFullName(this,typeIdx,eleIdx)
            out=this.makeFullname(this.getTypeBaseClassName(typeIdx,eleIdx),...
            this.getTypeNamespace(typeIdx));
        end

        function out=getTypeBaseClassTypes(this,typeIdx)
            out=[];
            members=this.getTypeBaseClasses(typeIdx);
            numMembers=numel(members);
            if numMembers>0
                out=uint32(numMembers,1);
                for ii=1:numMembers
                    out{ii}=members{ii}.TypeIdx;
                end
            end
        end

        function out=getTypeBaseClassType(this,typeIdx,eIdx)
            out=[];
            cls=this.getTypeBaseClass(typeIdx,eIdx);
            if~isempty(cls)
                out=cls.TypeIdx;
            end
        end

        function out=getTypeBaseClassInheritances(this,typeIdx)
            out=[];
            members=this.getTypeBaseClasses(typeIdx);
            numMembers=numel(members);
            if numMembers>0
                out=cell(numMembers,1);
                for ii=1:numMembers
                    out{ii}=members{ii}.InheritanceKind;
                end
            end
        end

        function out=getTypeBaseClassInheritance(this,typeIdx,eIdx)
            out=[];
            cls=this.getTypeBaseClass(typeIdx,eIdx);
            if~isempty(cls)
                out=cls.InheritanceKind;
            end
        end

        function out=getTypeBaseClassIsDirect(this,typeIdx,eIdx)
            out=[];
            cls=this.getTypeBaseClass(typeIdx,eIdx);
            if~isempty(cls)
                out=cls.IsDirect;
            end
        end

        function out=getTypeNumMethods(this,typeIdx)
            out=numel(this.getTypeMethods(typeIdx));
        end

        function out=getTypeMethods(this,typeIdx)
            out=[];
            if this.isTypeAggregate(typeIdx)
                mInfo=this.Symbols.DataTypes{typeIdx}.MemberInfo;
                if~isempty(mInfo)&&~isempty(mInfo.ClassInfo)
                    out=mInfo.ClassInfo.Methods;
                end
            end
        end

        function out=getTypeMethod(this,typeIdx,eIdx)
            out=[];
            members=this.getTypeMethods(typeIdx);
            if eIdx<=numel(members)
                out=members{eIdx};
            end
        end

        function out=getTypeMethodNames(this,typeIdx)
            out=[];
            members=this.getTypeMethods(typeIdx);
            numMembers=numel(members);
            if numMembers>0
                out=cell(numMembers,1);
                for ii=1:numMembers
                    out{ii}=members{ii}.Name;
                end
            end
        end

        function out=getTypeMethodName(this,typeIdx,eIdx)
            out=[];
            fcn=this.getTypeMethod(typeIdx,eIdx);
            if~isempty(fcn)
                out=fcn.Name;
            end
        end

        function out=getTypeMethodPosition(this,typeIdx,eIdx)
            out=[];
            fcn=this.getTypeMethod(typeIdx,eIdx);
            if~isempty(fcn)
                out=fcn.Position;
            end
        end

        function out=getTypeMethodBodyPosition(this,typeIdx,eIdx)
            out=[];
            fcn=this.getTypeMethod(typeIdx,eIdx);
            if~isempty(fcn)
                out=fcn.BodyPosition;
            end
        end

        function out=getTypeMethodFile(this,typeIdx,eIdx)
            out=[];
            fcn=this.getTypeMethod(typeIdx,eIdx);
            if~isempty(fcn)
                out=fcn.File;
            end
        end

        function out=getTypeMethodFullName(this,typeIdx,eleIdx)
            out=[this.getTypeFullName(typeIdx),'::',this.getTypeMethodName(typeIdx,eleIdx)];
        end

        function out=getTypeMethodTypes(this,typeIdx)
            out=[];
            members=this.getTypeMethods(typeIdx);
            numMembers=numel(members);
            if numMembers>0
                out=uint32(numMembers,1);
                for ii=1:numMembers
                    out{ii}=members{ii}.DataTypeIdx;
                end
            end
        end

        function out=getTypeMethodType(this,typeIdx,eIdx)
            out=[];
            fcn=this.getTypeMethod(typeIdx,eIdx);
            if~isempty(fcn)
                out=fcn.DataTypeIdx;
            end
        end

        function out=getTypeMethodAccesses(this,typeIdx)
            out=[];
            members=this.getTypeMethods(typeIdx);
            numMembers=numel(members);
            if numMembers>0
                out=cell(numMembers,1);
                for ii=1:numMembers
                    out{ii}=members{ii}.Access;
                end
            end
        end

        function out=getTypeMethodAccess(this,typeIdx,eIdx)
            out=[];
            fcn=this.getTypeMethod(typeIdx,eIdx);
            if~isempty(fcn)
                out=fcn.Access;
            end
        end

        function out=getTypeMethodNumArgs(this,typeIdx,eIdx)
            out=0;
            fcn=this.getTypeMethod(typeIdx,eIdx);
            if~isempty(fcn)
                out=numel(fcn.ArgNames);
            end
        end

        function out=getTypeMethodArgNames(this,typeIdx,eIdx)
            out=[];
            fcn=this.getTypeMethod(typeIdx,eIdx);
            if~isempty(fcn)
                out=fcn.ArgNames;
            end
        end

        function out=getTypeMethodArgName(this,typeIdx,eIdx,aIdx)
            out=[];
            fcn=this.getTypeMethod(typeIdx,eIdx);
            if~isempty(fcn)&&aIdx<=numel(fcn.ArgNames)
                out=fcn.ArgNames{aIdx};
            end
        end

        function out=getTypeMethodArgTypes(this,typeIdx,eIdx)
            out=[];
            idx=this.getTypeMethodType(typeIdx,eIdx);
            if~isempty(idx)
                out=this.getTypeFunctionArgTypes(idx);
            end
        end

        function out=getTypeMethodArgType(this,typeIdx,fcnIdx,argIdx)
            out=this.getTypeFunctionArgType(this.getTypeMethodType(typeIdx,fcnIdx),argIdx);
        end

        function out=getTypeMethodReturnType(this,typeIdx,fcnIdx)
            out=this.getTypeFunctionReturnType(this.getTypeMethodType(typeIdx,fcnIdx));
        end

        function out=getTypeNumStaticMembers(this,typeIdx)
            out=numel(this.getTypeStaticMembers(typeIdx));
        end

        function out=getTypeStaticMembers(this,typeIdx)
            out=[];
            if this.isTypeAggregate(typeIdx)
                mInfo=this.Symbols.DataTypes{typeIdx}.MemberInfo;
                if~isempty(mInfo)&&~isempty(mInfo.ClassInfo)
                    out=mInfo.ClassInfo.StaticMembers;
                end
            end
        end

        function out=getTypeStaticMember(this,typeIdx,eIdx)
            out=[];
            members=this.getTypeStaticMembers(typeIdx);
            if eIdx<=numel(members)
                out=members{eIdx};
            end
        end

        function out=getTypeStaticMemberNames(this,typeIdx)
            out=[];
            members=this.getTypeStaticMembers(typeIdx);
            numMembers=numel(members);
            if numMembers>0
                out=cell(numMembers,1);
                for ii=1:numMembers
                    out{ii}=members{ii}.Name;
                end
            end
        end

        function out=getTypeStaticMemberName(this,typeIdx,eIdx)
            out=[];
            members=this.getTypeStaticMembers(typeIdx);
            if eIdx<=numel(members)
                out=members{eIdx}.Name;
            end
        end

        function out=getTypeStaticMemberFullName(this,typeIdx,eleIdx)
            out=this.makeFullname(this.getTypeStaticMemberName(typeIdx,eleIdx),...
            this.getTypeNamespace(typeIdx));
        end

        function out=getTypeStaticMemberTypes(this,typeIdx)
            out=[];
            members=this.getTypeStaticMembers(typeIdx);
            numMembers=numel(members);
            if numMembers>0
                out=uint32(numMembers,1);
                for ii=1:numMembers
                    out{ii}=members{ii}.DataTypeIdx;
                end
            end
        end

        function out=getTypeStaticMemberType(this,typeIdx,eIdx)
            out=[];
            members=this.getTypeStaticMembers(typeIdx);
            if eIdx<=numel(members)
                out=members{eIdx}.DataTypeIdx;
            end
        end

        function out=getTypeStaticMemberAccesses(this,typeIdx)
            out=[];
            members=this.getTypeStaticMembers(typeIdx);
            numMembers=numel(members);
            if numMembers>0
                out=cell(numMembers,1);
                for ii=1:numMembers
                    out{ii}=members{ii}.Access;
                end
            end
        end

        function out=getTypeStaticMemberAccess(this,typeIdx,eIdx)
            out=[];
            members=this.getTypeStaticMembers(typeIdx);
            if eIdx<=numel(members)
                out=members{eIdx}.Access;
            end
        end

        function out=getTypeEnums(this,typeIdx)

            out=[];
            if this.isTypeEnum(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.EnumInfo;
            end
        end

        function out=getTypeEnumStrings(this,typeIdx)

            out=[];
            if this.isTypeEnum(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.EnumInfo.Strings;
            end
        end

        function out=getTypeEnumValues(this,typeIdx)

            out=[];
            if this.isTypeEnum(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.EnumInfo.Values;
            end
        end

        function out=getTypeEnumString(this,typeIdx,enumIdx)

            out=[];
            if this.isTypeEnum(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.EnumInfo.Strings{enumIdx};
            end
        end

        function out=getTypeEnumValue(this,typeIdx,enumIdx)

            out=[];
            if this.isTypeEnum(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.EnumInfo.Values(enumIdx);
            end
        end

        function out=getTypeFunctionNumArgs(this,typeIdx)

            out=[];
            if this.isTypeFunction(typeIdx)
                out=numel(this.Symbols.DataTypes{typeIdx}.InputIdx);
            end
        end

        function out=getTypeFunctionArgTypes(this,typeIdx)

            out=[];
            if this.isTypeFunction(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.InputIdx;
            end
        end

        function out=getTypeFunctionArgType(this,typeIdx,inIdx)

            out=[];
            if this.isTypeFunction(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.InputIdx(inIdx);
            end
        end

        function out=getTypeFunctionReturnType(this,typeIdx)

            out=[];
            if this.isTypeFunction(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.RetIdx;
            end
        end

        function out=getTypeFunctionIsVariadic(this,typeIdx)

            out=false;
            if this.isTypeFunction(typeIdx)
                out=this.Symbols.DataTypes{typeIdx}.IsVariadic;
            end
        end

        function out=getTypeFile(this,typeIdx)


            out=[];
            if this.isTypeTypedef(typeIdx)||this.isTypeAggregate(typeIdx)||...
                this.isTypeEnum(typeIdx)

                out=this.Symbols.DataTypes{typeIdx}.FileIdx;
            end
        end

        function out=getTypePosition(this,typeIdx)

            out=[];
            if this.isTypeTypedef(typeIdx)||this.isTypeAggregate(typeIdx)||...
                this.isTypeEnum(typeIdx)

                out=this.Symbols.DataTypes{typeIdx}.Position;
            end
        end

        function out=getTypeNamespace(this,typeIdx)

            out=[];
            rec=this.Symbols.DataTypes{typeIdx};
            if isfield(rec,'NamespaceIdx')&&~isempty(rec.NamespaceIdx)
                out=this.Symbols.Namespaces{rec.NamespaceIdx}.Idx;
            end
        end

        function out=getTypeFullName(this,typeIdx)
            rec=this.getTypeRecord(typeIdx);
            if isfield(rec,'ParentIdx')&&~isempty(rec.ParentIdx)
                out=[this.getTypeFullName(rec.ParentIdx),'::',this.getTypeName(typeIdx)];
            else
                out=this.makeFullname(this.getTypeName(typeIdx),...
                this.getTypeNamespace(typeIdx));
            end
        end

        function out=getTypeOfType(this,ctor)
            out=[];
            types=this.getTypes();
            for ii=1:numel(types)
                if strcmpi(types{ii}.Ctor,ctor)
                    out=[out;ii];%#ok<AGROW>
                end
            end
        end

        function[buffer,visitedId]=displayType(this,typeIdx,buffer,visitedId)

            if nargin<4
                visitedId=[];
            end

            if nargin<3
                buffer='';
            end

            if ismember(typeIdx,visitedId)

                buffer=sprintf('%s%s',this.getTypeName(typeIdx));
                return
            end

            if this.isTypeQualified(typeIdx)
                [buffer1,visitedId]=this.displayType(this.getTypeBase(typeIdx),'',visitedId);
                buffer=sprintf('%s%s(%s)',buffer,...
                this.getTypeQualifier(typeIdx),buffer1);

            elseif this.isTypeTypedef(typeIdx)
                [buffer1,visitedId]=this.displayType(this.getTypeBase(typeIdx),'',visitedId);
                buffer=sprintf('%stypedef(%s, %s)',...
                buffer,this.getTypeName(typeIdx),buffer1);

            elseif this.isTypePointer(typeIdx)
                [buffer1,visitedId]=this.displayType(this.getTypeBase(typeIdx),'',visitedId);
                buffer=sprintf('%spointer(%s)',...
                buffer,buffer1);

            elseif this.isTypeChar(typeIdx)||...
                this.isTypeInteger(typeIdx)||...
                this.isTypeFloat(typeIdx)
                buffer=sprintf('%s%s',buffer,this.getTypeSLName(typeIdx));

            elseif this.isTypeArray(typeIdx)
                [buffer1,visitedId]=this.displayType(this.getTypeBase(typeIdx),'',visitedId);
                buffer=sprintf('%sarray(%s, [%s])',...
                buffer,buffer1,num2str(this.getTypeDimensions(typeIdx)));

            elseif this.isTypeVector(typeIdx)
                typeIdx=this.skipTypeAttributes(typeIdx);
                [buffer1,visitedId]=this.displayType(this.getTypeBase(typeIdx),'',visitedId);
                buffer=sprintf('%svector(%s, [%s])',...
                buffer,buffer1,num2str(this.getTypeWidth(typeIdx)));

            elseif this.isTypeTypeop(typeIdx)
                switch this.getTypeOperatorKind(typeIdx)
                case 'is_decltype'
                    buffer1='decltype';
                case 'is_typeof'
                    buffer1='__typeof';
                case 'is_underlying_type'
                    buffer1='__underlying_type';
                case 'is_bases'
                    buffer1='__bases';
                case 'is_direct_bases'
                    buffer1='__direct_bases';
                otherwise
                    buffer1='<unknown type operator>';
                end
                [buffer2,visitedId]=this.displayType(this.getTypeBase(typeIdx),'',visitedId);
                buffer=sprintf('%s%s(%s)',...
                buffer,buffer1,buffer2);

            elseif this.isTypeAggregate(typeIdx)
                visitedId(end+1)=typeIdx;
                buffer=sprintf('%s%s(%s',...
                buffer,this.Symbols.DataTypes{typeIdx}.Ctor,...
                this.Symbols.DataTypes{typeIdx}.Name);
                names=this.getTypeElementNames(typeIdx);
                types=this.getTypeElementTypes(typeIdx);
                bitsizes=this.getTypeElementBitSizes(typeIdx);
                isbitfield=this.getTypeElementIsBitFields(typeIdx);
                sep='';
                for ii=1:numel(names)
                    [buffer1,visitedId]=this.displayType(types(ii),'',visitedId);
                    buffer=sprintf('%s%s"%s", %s',buffer,sep,names{ii},...
                    buffer1);
                    if isbitfield(ii)
                        buffer=sprintf('%s:%d',buffer,bitsizes(ii));
                    end
                    sep=', ';
                end
                buffer=sprintf('%s)',buffer);
                visitedId(visitedId==typeIdx)=[];

            elseif this.isTypeEnum(typeIdx)
                buffer=sprintf('enum(%s',...
                this.Symbols.DataTypes{typeIdx}.Name);
                names=this.getTypeEnumStrings(typeIdx);
                values=this.getTypeEnumValues(typeIdx);
                for ii=1:numel(names)
                    buffer=sprintf('%s, %s==%d',buffer,names{ii},values(ii));
                end
                buffer=sprintf('%s)',buffer);

            elseif this.isTypeFunction(typeIdx)
                buffer=sprintf('%s (',buffer);

                sep='';

                for ii=1:this.getTypeFunctionNumArgs(typeIdx)
                    [buffer1,visitedId]=this.displayType(this.getTypeFunctionArgType(typeIdx,ii),'',visitedId);
                    buffer=sprintf('%s%s%s',buffer,sep,buffer1);
                    sep=', ';
                end

                if this.getTypeFunctionIsVariadic(typeIdx)
                    buffer=sprintf('%s...',buffer);
                end

                [buffer1,visitedId]=this.displayType(this.getTypeFunctionReturnType(typeIdx),'',visitedId);
                if isempty(buffer1)
                    buffer1='void';
                end
                buffer=sprintf('%s) -> %s',buffer,buffer1);

            end
        end

        function buffer=displayCType(this,typeIdx,buffer)
            if nargin<3
                buffer='';
            end

            if this.isTypeVoid(typeIdx)
                buffer='void';

            elseif this.isTypeQualified(typeIdx)
                buffer1=this.displayCType(this.getTypeBase(typeIdx));
                buffer=sprintf('%s %s',...
                this.getTypeQualifier(typeIdx),buffer1);

            elseif this.isTypeTypedef(typeIdx)
                buffer1=this.displayCType(this.getTypeBase(typeIdx));%#ok<NASGU>
                buffer=sprintf('%s',...
                this.getTypeName(typeIdx));

            elseif this.isTypePointer(typeIdx)
                buffer1=this.displayCType(this.getTypeBase(typeIdx));
                buffer=sprintf('%s*',buffer1);

            elseif this.isTypeChar(typeIdx)||...
                this.isTypeInteger(typeIdx)||...
                this.isTypeFloat(typeIdx)
                buffer=sprintf('%s',this.getTypeSLName(typeIdx));

            elseif this.isTypeArray(typeIdx)
                buffer1=this.displayCType(this.getTypeBase(typeIdx));
                buffer=sprintf('%s[%s])',...
                buffer1,num2str(this.getTypeDimensions(typeIdx)));

            elseif this.isTypeAggregate(typeIdx)
                buffer='';

            elseif this.isTypeEnum(typeIdx)
                buffer='enum';

            elseif this.isTypeFunction(typeIdx)
                buffer='function';

            end
        end




        function out=getNumVariables(this)

            out=0;
            if~isempty(this.Symbols)&&isfield(this.Symbols,'Variables')
                out=numel(this.Symbols.Variables);
            end
        end

        function out=getVariableRecord(this,varIdx)

            out=this.Symbols.Variables{varIdx};
        end

        function out=getVariableName(this,varIdx)

            out=this.Symbols.Variables{varIdx}.Name;
        end

        function out=getVariableType(this,varIdx)

            out=this.Symbols.Variables{varIdx}.DataTypeIdx;
        end

        function out=getVariableFile(this,varIdx)

            out=this.Symbols.Variables{varIdx}.FileIdx;
        end

        function out=getVariableStorageClass(this,varIdx)

            out=this.Symbols.Variables{varIdx}.Storage;
        end

        function out=isVariableGlobal(this,varIdx)

            out=strcmpi(this.Symbols.Variables{varIdx}.Storage,'global');
        end

        function out=isVariableExtern(this,varIdx)

            out=strcmpi(this.Symbols.Variables{varIdx}.Storage,'extern');
        end

        function out=isVariableStatic(this,varIdx)

            out=strcmpi(this.Symbols.Variables{varIdx}.Storage,'static');
        end

        function out=isVariableConst(this,varIdx)

            out=this.isTypeConst(getVarType(varIdx));
        end

        function out=isVariableVolatile(this,varIdx)

            out=this.isTypeVolatile(getVarType(varIdx));
        end

        function out=isVariableQualified(this,varIdx)

            out=this.isTypeQualified(getVarType(varIdx));
        end

        function out=getVariablePosition(this,varIdx)


            out=this.Symbols.Variables{varIdx}.Position;
        end

        function out=getVariableInitValue(this,varIdx)

            out=this.Symbols.Variables{varIdx}.Value;
        end

        function buffer=displayVariable(this,varIdx)
            buffer=sprintf('%s var("%s", %s)',...
            this.Symbols.Variables{varIdx}.Storage,...
            this.getVariableName(varIdx),...
            this.displayType(this.getVariableType(varIdx)));

        end

        function out=getVariableNamespace(this,varIdx)

            out=[];
            rec=this.Symbols.Variables{varIdx};
            if isfield(rec,'NamespaceIdx')&&~isempty(rec.NamespaceIdx)
                out=this.Symbols.Namespaces{rec.NamespaceIdx}.Idx;
            end
        end

        function out=getVariableFullName(this,varIdx)
            out=this.makeFullname(this.getVariableName(varIdx),...
            this.getVariableNamespace(varIdx));
        end




        function out=getNumFiles(this)

            out=0;
            if~isempty(this.Symbols)&&isfield(this.Symbols,'Files')
                out=numel(this.Symbols.Files);
            end
        end

        function out=getFileRecord(this,fileIdx)

            out=this.Symbols.Files{fileIdx};
        end

        function out=getFileName(this,fileIdx)

            out=this.Symbols.Files{fileIdx}.Name;
            if strcmpi(out,'-')
                out=[];
            end
        end

        function out=isFileIncluded(this,fileIdx)

            out=this.Symbols.Files{fileIdx}.IsIncludedFile;
        end

        function out=isFileSystemIncluded(this,fileIdx)


            out=this.Symbols.Files{fileIdx}.IsSystemFile;
        end

        function out=getFileNumIncluded(this,fileIdx)

            out=numel(this.Symbols.Files{fileIdx}.IncludedIdx);
        end

        function out=getFileIncludedFiles(this,fileIdx)

            out=this.Symbols.Files{fileIdx}.IncludedIdx;
        end

        function out=getFileIncludedFile(this,fileIdx,incIdx)

            out=this.Symbols.Files{fileIdx}.IncludedIdx(incIdx);
        end




        function out=getNumFunctions(this)
            out=0;
            if~isempty(this.Symbols)&&isfield(this.Symbols,'Functions')
                out=numel(this.Symbols.Functions);
            end
        end

        function out=getFunctionRecord(this,fcnIdx)

            out=this.Symbols.Functions{fcnIdx};
        end

        function out=getFunctionName(this,fcnIdx)

            out=this.Symbols.Functions{fcnIdx}.Name;
        end

        function out=getFunctionBodyPosition(this,fcnIdx)
            out=this.Symbols.Functions{fcnIdx}.BodyPosition;
        end

        function out=getFunctionFullName(this,fcnIdx)
            out=this.makeFullname(this.getFunctionName(fcnIdx),...
            this.getFunctionNamespace(fcnIdx));
        end

        function out=getFunctionType(this,fcnIdx)

            out=this.Symbols.Functions{fcnIdx}.DataTypeIdx;
        end

        function out=getFunctionNumArgs(this,fcnIdx)

            out=this.getTypeFunctionNumArgs(this.getFunctionType(fcnIdx));
        end

        function out=getFunctionArgNames(this,fcnIdx)

            out=this.Symbols.Functions{fcnIdx}.ArgNames;
        end

        function out=getFunctionArgName(this,fcnIdx,argIdx)

            out=this.Symbols.Functions{fcnIdx}.ArgNames{argIdx};
        end

        function out=getFunctionArgTypes(this,fcnIdx)

            out=this.getTypeFunctionArgTypes(this.getFunctionType(fcnIdx));
        end

        function out=getFunctionArgType(this,fcnIdx,argIdx)

            out=this.getTypeFunctionArgType(this.getFunctionType(fcnIdx),argIdx);
        end

        function out=getFunctionReturnType(this,fcnIdx)

            out=this.getTypeFunctionReturnType(this.getFunctionType(fcnIdx));
        end

        function out=getFunctionFile(this,fcnIdx)

            out=this.Symbols.Functions{fcnIdx}.FileIdx;
        end

        function out=getFunctionStorageClass(this,fcnIdx)

            out=this.Symbols.Functions{fcnIdx}.Storage;
        end

        function out=getFunctionPosition(this,fcnIdx)


            out=this.Symbols.Functions{fcnIdx}.Position;
        end

        function out=isFunctionBuiltin(this,fcnIdx)

            out=this.Symbols.Functions{fcnIdx}.IsBuiltIn;
        end

        function out=isFunctionGlobal(this,fcnIdx)

            out=strcmpi(this.Symbols.Functions{fcnIdx}.Storage,'global');
        end

        function out=isFunctionExtern(this,fcnIdx)

            out=strcmpi(this.Symbols.Functions{fcnIdx}.Storage,'extern');
        end

        function out=isFunctionStatic(this,fcnIdx)

            out=strcmpi(this.Symbols.Functions{fcnIdx}.Storage,'static');
        end

        function out=isFunctionVariadic(this,fcnIdx)

            out=this.getTypeFunctionIsVariadic(this.getFunctionType(fcnIdx));
        end

        function buffer=displayFunction(this,fcnIdx)
            buffer=sprintf('%s(',this.getFunctionName(fcnIdx));

            sep='';
            for ii=1:this.getFunctionNumArgs(fcnIdx)
                buffer=sprintf('%s%s%s',buffer,sep,this.getFunctionArgName(fcnIdx,ii));
                sep=', ';
            end

            if this.isFunctionVariadic(fcnIdx)
                buffer=sprintf('%s...',buffer);
            end

            buffer1=this.displayType(this.getFunctionType(fcnIdx));
            buffer=sprintf('%s): %s',buffer,buffer1);
        end

        function out=getFunctionNamespace(this,fcnIdx)

            out=[];
            rec=this.Symbols.Functions{fcnIdx};
            if isfield(rec,'NamespaceIdx')&&~isempty(rec.NamespaceIdx)
                out=this.Symbols.Namespaces{rec.NamespaceIdx}.Idx;
            end
        end




        function out=getNumMacros(this)
            out=0;
            if~isempty(this.Symbols)&&isfield(this.Symbols,'Macros')
                out=numel(this.Symbols.Macros);
            end
        end




        function out=getNumNamespaces(this)

            out=0;
            if~isempty(this.Symbols)&&isfield(this.Symbols,'Namespaces')
                out=numel(this.Symbols.Namespaces);
            end
        end

        function out=getNamespaceRecord(this,idx)

            out=this.Symbols.Namespaces{idx};
        end

        function out=getNamespaceName(this,idx)

            out=this.Symbols.Namespaces{idx}.Name;
        end

        function out=getNamespaceFullName(this,idx)

            out=this.getNamespaceName(idx);
            pIdx=this.getNamespaceParent(idx);
            if~isempty(pIdx)
                if isempty(out)
                    out='<anonymous>';
                end
                names={out};
                while~isempty(pIdx)&&pIdx>0
                    pName=this.getNamespaceName(pIdx);
                    pIdx=this.getNamespaceParent(pIdx);


                    names{end+1}=pName;%#ok<AGROW>

                end
                out=strjoin(fliplr(names),'::');
            end
        end

        function out=getNamespaceParent(this,idx)

            out=this.Symbols.Namespaces{idx}.ParentIdx;
        end




        function disp(this)


            fprintf(1,'\tSummary:\n');
            fprintf(1,'\t\t%d Type(s)\n',this.getNumTypes());
            fprintf(1,'\t\t%d Variable(s)\n',this.getNumVariables());
            fprintf(1,'\t\t%d Function(s)\n',this.getNumFunctions());
            fprintf(1,'\t\t%d Macro(s)\n',this.getNumMacros());
            fprintf(1,'\t\t%d File(s)\n',this.getNumFiles());
            fprintf(1,'\t\t%d Namespace(s)\n',this.getNumNamespaces());

        end

    end
end


