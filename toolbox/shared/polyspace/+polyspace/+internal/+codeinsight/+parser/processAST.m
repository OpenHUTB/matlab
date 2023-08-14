

function codeInfo=processAST(AST,varargin)

    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addRequired(argParser,'AST',@(x)isa(x,'internal.cxxfe.ast.Ast'));
        addParameter(argParser,'Debug',false,@(x)isa(x,'logical'));
        addParameter(argParser,'AllTypes',false,@(x)isa(x,'logical'));
    end
    argParser.parse(AST,varargin{:});



    assert(AST.Project.Compilations.Size==1,"Expected AST to have only one compilation unit");
    compilationUnit=AST.Project.Compilations.at(1);
    codeInfo=polyspace.internal.codeinsight.parser.CodeInfo;


    files=compilationUnit.Files.toArray;
    nFiles=numel(files);

    codeInfo.Files(1,nFiles)=polyspace.internal.codeinsight.parser.FileInfo;



    for fIdx=1:nFiles
        current=files(fIdx);
        fhandle=codeInfo.addFile(current.Path);
        fhandle.Path=current.Path;
        codeInfo.Files(fIdx)=fhandle;

        includes=current.IncludedFiles.toArray;
        addHeaderDependency(codeInfo,fhandle,includes);
        codeInfo.Files(fIdx)=fhandle;
    end


    if argParser.Results.AllTypes
        typeList=compilationUnit.Types.toArray;
        nTypes=numel(typeList);
        if(nTypes>0)

            codeInfo.Types(1,nTypes)=polyspace.internal.codeinsight.parser.TypeInfo;
            for tIdx=1:nTypes
                codeInfo.Types(tIdx)=processType(codeInfo,typeList(tIdx));
            end
        end
    end



    isUserDefinedFunction=@(x)(~(isempty(x.DefPos)&&isempty(x.DeclPos))&&~x.IsCompilerGenerated);
    funs=compilationUnit.Funs.toArray;
    funs=funs(arrayfun(isUserDefinedFunction,funs));

    funs=funs([funs.StorageClass]~=internal.cxxfe.ast.StorageClassKind.Static);
    nFuns=numel(funs);
    if nFuns>0

        codeInfo.Functions(1,nFuns)=polyspace.internal.codeinsight.parser.FunInfo;

        for funIdx=1:nFuns
            funhandle=codeInfo.addFunction(funs(funIdx).Name);
            funhandle.Name=funs(funIdx).Name;
            funhandle.Signature=funs(funIdx).generateSignature();
            if~isempty(funs(funIdx).DefPos)&&~isempty(funs(funIdx).BodyPosition)
                funhandle.IsDefined=true;
                funhandle.DefinitionFile=codeInfo.addFile(string(funs(funIdx).BodyPosition.Start.File.Path));
                funhandle.DefinitionBlock.File=funhandle.DefinitionFile;
                funhandle.DefinitionBlock.StartLine=funs(funIdx).DefPos.Line;

                funhandle.DefinitionBlock.EndLine=funs(funIdx).BodyPosition.End.Line;
                funhandle.DefinitionBlock.EndCol=funs(funIdx).BodyPosition.End.Col;
            end

            if~isempty(funs(funIdx).DeclPos)

                if(funs(funIdx).DeclPos.Size>0)
                    declPos=funs(funIdx).DeclPos.toArray;

                    declIdxs=arrayfun(@(x)~(funhandle.IsDefined&&isequal(x,funs(funIdx).DefPos)),declPos);
                    declPos=declPos(declIdxs);
                    if numel(declPos)>0
                        funhandle.IsDeclared=true;
                        funhandle.DeclarationFile=arrayfun(@(x)(codeInfo.addFile(string(x.File.Path))),declPos);
                        funhandle.DeclarationLine=[declPos.Line];
                    end
                end
            end
            if funs(funIdx).Params.Size>0
                fparams=funs(funIdx).Params.toArray;
                funhandle.FormalArguments=arrayfun(@(x)(processAndStoreType(codeInfo,x)),[fparams.Type]);
            end
            funhandle.ReturnedType=processAndStoreType(codeInfo,funs(funIdx).Type.RetType);
            funhandle.IsImportCompliant=...
            funhandle.ReturnedType.IsImportCompliantAsFunctionReturn==true...
            &&~any([funhandle.FormalArguments.IsImportCompliantAsFunctionArg]==false)...
            &&funhandle.IsDeclared...
            &&funhandle.IsDefined;


            if funs(funIdx).Annotations.Size>0
                annotations=funs(funIdx).Annotations.toArray;
                for aIdx=1:numel(annotations)
                    if isa(annotations(aIdx),'internal.cxxfe.ast.codeinsight.FunInfo')
                        if(annotations(aIdx).CalledFuns.Size>0)
                            funhandle.CalledFuns=arrayfun(@(x)(codeInfo.addFunction(x.Name)),annotations(aIdx).CalledFuns.toArray);
                        end
                        if(annotations(aIdx).ReadVars.Size>0)
                            funhandle.ReadVars=arrayfun(@(x)(addVariableAccess(codeInfo,x.Name,true)),annotations(aIdx).ReadVars.toArray);
                        end
                        if(annotations(aIdx).WrittenVars.Size>0)
                            funhandle.WrittenVars=arrayfun(@(x)(addVariableAccess(codeInfo,x.Name,false)),annotations(aIdx).WrittenVars.toArray);
                        end
                    end
                end
            end
            codeInfo.Functions(funIdx)=funhandle;
        end
    end


    vars=compilationUnit.Vars.toArray;
    nVars=numel(vars);
    if nVars>0
        codeInfo.Variables(1,nVars)=polyspace.internal.codeinsight.parser.VarInfo;
        for vIdx=1:nVars
            varhandle=codeInfo.addVariable(vars(vIdx).Name);
            varhandle.Name=vars(vIdx).Name;
            varhandle.Type=processAndStoreType(codeInfo,vars(vIdx).Type);
            varhandle.TypeName=internal.cxxfe.ast.types.Type.generateTypeName(vars(vIdx).Type,vars(vIdx).Name);
            if~isempty(vars(vIdx).DefPos)


                if vars(vIdx).StorageClass~=internal.cxxfe.ast.StorageClassKind.Extern...
                    ||~vars(vIdx).DefPos.File.IsInclude
                    varhandle.IsDefined=true;
                    varhandle.DefinitionFile=codeInfo.addFile(string(vars(vIdx).DefPos.File.Path));
                    varhandle.DefinitionBlock.File=varhandle.DefinitionFile;
                    varhandle.DefinitionBlock.StartLine=vars(vIdx).DefPos.Line;

                    varhandle.DefinitionBlock.EndLine=varhandle.DefinitionBlock.StartLine;
                end


                if vars(vIdx).StorageClass~=internal.cxxfe.ast.StorageClassKind.Extern...
                    &&vars(vIdx).DefPos.File.IsInclude
                    varhandle.IsDeclared=true;
                    varhandle.DeclarationFile=varhandle.DefinitionFile;
                    varhandle.DeclarationLine=vars(vIdx).DefPos.Line;
                end
            end
            if~isempty(vars(vIdx).DeclPos)

                if(vars(vIdx).DeclPos.Size>0)
                    varhandle.IsDeclared=true;





                    declPos=vars(vIdx).DeclPos.toArray;
                    varhandle.DeclarationFile=unique(arrayfun(@(x)(codeInfo.addFile(string(x.File.Path))),declPos));
                    varhandle.DeclarationLine=[declPos.Line];
                end
            end
            varhandle.IsImportCompliant=...
            varhandle.Type.IsImportCompliant...
            &&varhandle.IsDefined...
            &&varhandle.IsDeclared;
            codeInfo.Variables(vIdx)=varhandle;
        end
    end


    macroList=compilationUnit.Macros.toArray;
    macroList=macroList([macroList.IsCmdDef]==0&[macroList.IsPreDef]==0);
    for maIdx=1:numel(macroList)
        current=macroList(maIdx);
        if~isempty(current.DefPos)
            [mhandle,exists]=codeInfo.addMacro(current.Name);
            if~exists
                codeInfo.Macros(maIdx)=mhandle;
            end
            mhandle.Name=string(current.Name);
            if current.IsUndef
                mhandle.Text="";
            else
                mhandle.Text=string(current.Text);
            end
            mhandle.Location.File=codeInfo.addFile(current.DefPos.File.Path);
            mhandle.Location.StartLine=current.DefPos.Line;
            mhandle.Location.StartCol=current.DefPos.Col;

        end
    end
end

function vhandle=addVariableAccess(codeInfo,name,isRead)
    vhandle=codeInfo.addVariable(name);
    if isRead
        vhandle.IsRead=true;
    else
        vhandle.IsWritten=true;
    end
end

function addHeaderDependency(modelInfo,fhandle,includes)
    if isempty(includes)
        return
    end
    nIncludes=numel(includes);
    fhandle.Includes(1,nIncludes)=polyspace.internal.codeinsight.parser.FileInfo;
    for iIdx=1:nIncludes
        [fhandle.Includes(iIdx),exists]=modelInfo.addFile(includes(iIdx).Path);
        if~exists
            fhandle.Includes(iIdx).Path=includes(iIdx).Path;
            if includes(iIdx).IncludedFiles.Size>0
                addHeaderDependency(modelInfo,fhandle.Includes(iIdx),includes(iIdx).IncludedFiles.toArray);
            end
        end
    end
end

function kind=getTypeKind(type)
    s=split(class(type),'.');
    kind=s{end};
end

function thandle=processAndStoreType(codeInfo,type)
    [thandle,exists]=codeInfo.addType(type.UUID);
    if~exists
        thandle=processType(codeInfo,type,thandle);
        codeInfo.Types(end+1)=thandle;
    end
end

function thandle=processType(codeInfo,type,thandle)
    sig=type.generateSignature();
    thandle.Name=type.Name;
    thandle.Signature=sig;
    thandle.StubTypeName=string(internal.cxxfe.ast.types.Type.generateTypeName(type,"$stubvar$"));
    thandle.Kind=getTypeKind(type);
    thandle.UnderlayingType=type.getUnderlyingType(type).Name;
    if~isempty(type.DefPos)&&~isempty(type.DefPos.File)




        if type.DefPos.File.IsInclude
            thandle.IsDeclared=true;
            thandle.DeclarationFile=thandle.DefinitionFile;
        end

        if(~(type.isAggregateType()&&type.IsIncomplete()))
            thandle.IsDefined=true;
            thandle.DefinitionFile=type.DefPos.File.Path;
        else
            thandle.IsDefined=false;
        end
    end

    if type.isBasedType()
        thandle.Type=processAndStoreType(codeInfo,type.Type);
    end

    if type.isStructType()
        thandle.Type=polyspace.internal.codeinsight.parser.TypeInfo.empty;
        members=type.Members.toArray;
        nMembers=numel(members);
        for mIdx=1:nMembers
            m=polyspace.internal.codeinsight.parser.MemberInfo;
            m.Name=members(mIdx).Name;
            m.Type=processAndStoreType(codeInfo,members(mIdx).Type);
            thandle.Members(mIdx)=m;
        end
    end

    [thandle.StubDefinition,thandle.StubDeclaration]=getTypeStubDefinition(type);
    thandle.IsImportCompliant=IsImportCompliant(type,thandle);
    thandle.IsImportCompliantAsFunctionArg=IsImportCompliantAsFunctionArg(type,thandle);
    thandle.IsImportCompliantAsFunctionReturn=IsImportCompliantAsFunctionReturn(type,thandle);
    thandle.IsImportCompliantAsAggregateField=IsImportCompliantInAggregateField(type,thandle);
end


function[def,decl]=getTypeStubDefinition(type,name)
    def="";
    decl="";
    if type.isTyperefType()
        if type.isQualifiedType()
            [def,decl]=getTypeStubDefinition(type.Type);
        end
        if type.isTypedefType()
            underlayingType=type.getUnderlyingType(type);
            if underlayingType.isStructType()
                if isempty(underlayingType.Name)
                    def="typedef struct {"+newline;
                    m=underlayingType.Members.toArray;
                    mMemberDefs=arrayfun(@(x)(string(internal.cxxfe.ast.types.Type.generateTypeName(x.Type,x.Name))),m);
                    mDef=join("  "+mMemberDefs+";",newline);
                    def=def+mDef+newline+"} "+type.Name+";"+newline;
                else
                    decl="typedef struct "+underlayingType.Name+" "+type.Name+";";
                end
            else
                if underlayingType.isEnumType()
                    if isempty(underlayingType.Name)
                        decl="typedef enum {"+newline;
                        tags=string(underlayingType.Strings.toArray);
                        values=string(underlayingType.Values.toArray);
                        tagDef=join(tags+" = "+values,","+newline);
                        decl=decl+tagDef+newline+"}"+type.Name+";"+newline;
                    else
                        decl="typedef enum "+underlayingType.Name+" "+type.Name+";";
                    end
                else
                    decl="typedef "+underlayingType.Name+" "+type.Name+";";
                end
            end
        end
    else
        if type.isPointerType()
            [def,decl]=getTypeStubDefinition(type.Type);
        end
    end
    if type.isStructType()
        if~isempty(type.Name)
            def="struct "+type.Name+"{"+newline;
            m=type.Members.toArray;
            mNames=arrayfun(@(x)(string(x.Name)),m);
            mTypes=arrayfun(@(x)(string(x.Type.generateSignature())),m);
            mDef=join("  "+mTypes+" "+mNames+";",newline);
            def=def+mDef+newline+"} "+type.Name+";"+newline;
            decl="struct "+type.Name+";"+newline;
        end
    else
        if type.isEnumType()
            if~isempty(type.Name)
                decl="enum "+type.Name+"{"+newline;
                tags=string(type.Strings.toArray);
                values=string(type.Values.toArray);
                tagDef=join(tags+" = "+values,","+newline);
                decl=decl+tagDef+newline+"};"+newline;
            end
        end
    end
end

function isCompliant=IsImportCompliant(type,thandle)
    if type.isVoidType()...
        ||type.isBooleanType()...
        ||type.isIntegerType()...
        ||type.isFloatType()...
        ||type.isEnumType()
        isCompliant=true;
        return;
    end
    if type.isUnionType()...
        ||type.isErrorType()...
        ||type.isOpaqueType()...
        ||type.isPointerToMemberType()...
        ||type.isUnionType()...
        ||type.isClassType()...
        ||type.isFunctionType()...
        ||type.isTemplateParamType()
        isCompliant=false;
        return;
    end


    if type.isIntegerType()
        if type.NumBits>64
            isCompliant=false;
            return;
        end
    end

    if type.isAggregateType()
        if type.IsIncomplete
            isCompliant=false;
            return;
        end

        if IsTMWComplex(type)
            isCompliant=false;
            return;
        end

        members=thandle.Members;
        mtypes=[members.Type];
        isCompliant=all([mtypes.IsImportCompliantAsAggregateField]);
        return;
    end

    if type.isBasedType()&&~isempty(thandle.Type)

        isCompliant=thandle.Type.IsImportCompliant;
        return;
    end

    isCompliant=false;
end

function isTMWComplex=IsTMWComplex(type)
    isTMWComplex=false;
    if~type.isStructType()
        return;
    end

    filePath=type.DefPos.File.Path;
    [~,name]=fileparts(filePath);
    if~strcmp(name,'tmwtypes')
        return;
    end

    members=type.Members.toArray;

    if length(members)==2&&strcmp(members(1).Name,"re")&&...
        strcmp(members(2).Name,"im")
        isTMWComplex=true;
        return;
    end

end

function isCompliant=IsImportCompliantInAggregateField(type,thandle)


    isCompliant=true;
    if~IsImportCompliant(type,thandle)
        isCompliant=false;
        return;
    end

    if type.isPointerType()
        isCompliant=false;
        return;
    end

    if type.isArrayType()
        dims=type.Dimensions.toArray;
        if length(dims)>1
            isCompliant=false;
            return;
        end
    end

    if type.isIntegerType()
        if type.NumBits>32
            isCompliant=false;
            return;
        end
    end

    if type.isBasedType()

        isCompliant=thandle.Type.IsImportCompliantAsAggregateField;
    end
end

function isCompliant=IsImportCompliantAsFunctionArg(type,thandle)

    isCompliant=true;
    if~IsImportCompliant(type,thandle)
        isCompliant=false;
        return;
    end

    if type.isPointerType()&&type.Type.isPointerType()
        isCompliant=false;
        return;
    end
end

function isCompliant=IsImportCompliantAsFunctionReturn(type,thandle)

    isCompliant=true;
    if~IsImportCompliant(type,thandle)
        isCompliant=false;
        return;
    end

    if type.isPointerType()
        isCompliant=false;
        return;
    end
end



