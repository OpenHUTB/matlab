function t=typeof(V,varargin)



































    try
        p=inputParser();
        p.KeepUnmatched=true;
        p.addRequired('V');
        p.addOptional('SizeVector',[]);
        p.addOptional('VariableDims',[]);
        p.addParameter('Gpu',false,@islogical);






        p.addParameter('MakeCategoricalCategoryNamesHomogeneous',true,@islogical);
        p.parse(V,varargin{:});
        res=p.Results;

        v=res.V;
        gpuParam.isGpu=res.Gpu;
        gpuParam.isDefault=any(contains(p.UsingDefaults,'Gpu'));

        makeCategoricalCategoryNamesHomogeneous=res.MakeCategoricalCategoryNamesHomogeneous;

        t=miscUnion({v},gpuParam,makeCategoricalCategoryNamesHomogeneous);

        if~any(strcmp(p.UsingDefaults,'SizeVector'))||~any(strcmp(p.UsingDefaults,'VariableDims'))
            if isa(t,'coder.ClassType')
                coder.internal.assert(coder.internal.classSupportsCoderResize(t.ClassName),...
                'Coder:common:ClassTypeOfWithSizeVector');
            elseif isa(t,'coder.type.Base')
                coder.internal.assert(t.supportsCoderResize().supported,...
                'Coder:common:ClassTypeOfWithSizeVector');
            end



            t=coder.resize(t,varargin{:});
        else
            if isa(t,'coder.PrimitiveType')&&t.Gpu==true&&all(t.SizeVector==1)
                t=coder.resize(t,[1,1]);
            end
        end

    catch me
        if isa(me,'coder.internal.PathException')
            err=me.exportError();
            errPath=me.exportErrorPath();

            if isempty(errPath)
                x=err;
            else
                x=coderprivate.msgSafeException('Coder:common:TypeConversion',errPath);
                x=coderprivate.transferCauses(me,x);
            end
        else
            x=me;
        end
        x.throwAsCaller();
    end
end



function b=isCoderType(v)
    b=~isnumeric(v)&&~isstruct(v)&&(isa(v,'coder.Type')||isa(v,'coder.type.Base'));
end



function actualInd=getActualIndex(origInd,isaInfo)
    for actualInd=1:numel(isaInfo)
        if isaInfo(actualInd)
            origInd=origInd-1;
        end
        if origInd==0
            break;
        end
    end
end



function t=miscUnion(args,gpuParam,makeCategoricalCategoryNamesHomogeneous)
    if isempty(args)
        isType=[];
        values=[];
        types=[];
    else
        nargs=numel(args);
        isType=false(1,nargs);
        for k=1:nargs
            isType(k)=isCoderType(args{k});
        end
        values=args(~isType);
        types=args(isType);
    end


    if~isempty(values)
        try
            t=miscUnionValues(values,gpuParam,makeCategoricalCategoryNamesHomogeneous);
        catch me
            if isa(me,'coder.internal.PathException')
                me.arrayInd=getActualIndex(me.arrayInd,~isType);
            else
                me=coder.internal.PathException(me,0,'');
            end
            me.throw();
        end
    else
        t=[];
    end


    if~isempty(types)

        if~gpuParam.isDefault
            pathError(0,'Coder:common:UnsupportedGpuCoderTypeofSyntax');
        end

        if isempty(t)
            t=types{1}(1);
        end

        for i=1:numel(types)
            v=types{i};
            if isscalar(v)
                try
                    t=t.union(v);
                catch me
                    if isa(me,'coder.internal.PathException')
                        me.arrayInd=getActualIndex(me.arrayInd,isType);
                    else
                        me=coder.internal.PathException(me,getActualIndex(i,isType),'');
                    end
                    me.throw();
                end
            else
                pathError(getActualIndex(i,isType),'Coder:common:TypeOfArrayOfTypes');
            end
        end
    end
end



function t=miscUnionValues(values,gpuParam,makeCategoricalCategoryNamesHomogeneous)
    [cls,isMcosObject]=miscUnionClassName(values);

    [sz,vd]=miscUnionSizeSpec(values,isMcosObject);

    switch cls
    case{'uint8','int8','uint16','int16','uint32','int32','uint64','int64',...
        'double','single','half','logical','char'}
        t=miscUnionPrimitive(cls,sz,vd,values,gpuParam);
    case{'embedded.fi','fixed.BinaryScaling','fixed.fi'}
        t=miscUnionFi(sz,vd,values,gpuParam);
    case 'string'
        if gpuParam.isGpu
            pathError(0,'Coder:common:UnsupportedGpuInputType');
        end
        t=miscUnionString(sz,vd,values{1});
    case 'struct'
        t=miscUnionStruct(sz,vd,values,gpuParam,makeCategoricalCategoryNamesHomogeneous);
    case 'cell'
        t=miscUnionCell(sz,vd,values,gpuParam,makeCategoricalCategoryNamesHomogeneous);
    case{'embedded.numerictype','embedded.fimath'}



        pathError(0,'Coder:common:TypeSpecUnknownClass',cls);
    case 'coder.opaque'
        t=miscUnionOpaque(cls,sz,vd,values);
    otherwise
        if isMcosObject
            t=miscUnionClass(cls,sz,vd,values,gpuParam,makeCategoricalCategoryNamesHomogeneous);
        else


            if gpuParam.isGpu
                pathError(0,'Coder:common:UnsupportedGpuInputType');
            end
            t=coder.EnumType(cls,sz,vd);
        end
    end
end



function pathError(arrayInd,msgId,varargin)
    me=coderprivate.msgSafeException(msgId,varargin{:});
    pe=coder.internal.PathException(me,arrayInd,'');
    pe.throw();
end



function[b,msg]=supportedClassButNotMCOS(cls)
    msg=[];
    switch cls
    case{'double','single','half',...
        'uint8','int8','uint16','int16','uint32','int32','uint64','int64',...
        'logical','char','embedded.fi','fixed.BinaryScaling','fixed.fi','struct','cell'}
        b=true;
    otherwise
        mc=meta.class.fromName(cls);
        if isscalar(mc)&&~isempty(mc.EnumerationMemberList)
            allowEnumsInPackages=true;
            [b,msg]=coder.internal.isSupportedEnumClass(mc,allowEnumsInPackages);
        else
            b=false;
        end
    end
end



function out=builtin_size(isMcosObject,varargin)


    if isMcosObject&&~isstring(varargin{1})
        out=builtin('size',varargin{:});
    else
        out=size(varargin{:});
    end
end



function out=builtin_ndims(isMcosObject,arg)
    if isMcosObject
        nargs=numel(arg);
        out=zeros(1,nargs);
        for k=1:nargs
            out(k)=builtin('ndims',arg{k});
        end
    else
        nargs=numel(arg);
        out=zeros(1,nargs);
        for k=1:nargs
            out(k)=ndims(arg{k});
        end
    end
end



function[cls,isMcosObject]=miscUnionClassName(args)
    cls=getClass(args{1});
    clsString=string(cls);
    isMcosObject=false;
    nargs=numel(args);
    matchResult=false(1,nargs);
    for k=1:nargs
        matchResult(k)=getClass(args{k})==clsString;
    end
    if~all(matchResult)
        errInd=find(matchResult==false);
        badarg=args{errInd(1)};
        pathError(errInd,'Coder:common:UnionClassName',cls,getClass(badarg));
    end

    [b,msg]=supportedClassButNotMCOS(cls);
    if b
        return;
    end
    if~isempty(msg)
        pathError(0,msg);
    end

    if isobject(args{1})
        if isa(args{1},'handle')
            pathError(0,'Coder:common:TypeSpecHandleClassNotSupported',cls);
        elseif~isequal(builtin_size(true,args{1}),[1,1])


            pathError(0,'Coder:common:TypeSpecMCOSArrayNotSupported',cls);
        else
            isMcosObject=true;
            return
        end
    else
        pathError(0,'Coder:common:TypeSpecUnknownClass',cls);
    end
end



function[sz,vd]=unionDimSizeNotMcos(args,i)
    baseS=size(args{1},i);
    nargs=numel(args);
    sz=zeros(1,nargs);
    vd=false(1,nargs);
    for k=1:nargs
        arg=args{k};
        sz(k)=size(arg,i);
        vd(k)=baseS~=sz(k);
    end
end



function[sz,vd]=unionDimSizeMcos(args,i)
    baseS=builtin_size(true,args{1},i);
    nargs=numel(args);
    sz=zeros(1,nargs);
    vd=false(1,nargs);
    for k=1:nargs
        arg=args{k};
        sz(k)=builtin_size(true,arg,i);
        vd(k)=baseS~=sz(k);
    end
end



function[sz,vd]=unionDimSize(args,i,isMcosObject)
    if isMcosObject
        [sz,vd]=unionDimSizeMcos(args,i);
    else
        [sz,vd]=unionDimSizeNotMcos(args,i);
    end
end



function[sz,vd]=miscUnionSizeSpec(args,isMcosObject)
    ndims_s=builtin_ndims(isMcosObject,args);
    ndimsv=max(ndims_s);
    sz=zeros(1,ndimsv);
    vd=false(1,ndimsv);
    for i=1:ndimsv
        [sz_i,vd_i]=unionDimSize(args,i,isMcosObject);
        sz(i)=max(sz_i);
        vd(i)=any(vd_i);
    end
end



function t=miscUnionPrimitive(cls,sz,vd,args,gpuParam)
    nargs=numel(args);
    c=false(1,nargs);
    s=false(1,nargs);
    for k=1:nargs
        arg=args{k};
        c(k)=~isreal(arg);
        s(k)=issparse(arg);
    end
    c=any(c);
    if any(s~=any(s))
        b=any(s);
        ind=find(s~=b,1);
        pathError(ind,'Coder:common:UnionSparse');
    end

    t=coder.PrimitiveType(cls,s(1),c,sz,vd,gpuParam.isGpu);
end



function t=miscUnionString(sz,vd,val)


    coder.internal.errorIf(ismissing(val),'Coder:toolbox:StringNoMissing');




    variableStringLength=false;
    t=coder.StringType(sz,vd,strlength(val),variableStringLength);
end



function t=miscUnionOpaque(~,~,~,args)
    nargs=numel(args);
    firstE=args{1};
    if~firstE.supportEntryPointIO
        pathError(0,'Coder:common:OpaqueTypesEntryMustSupportEntryPointIO');
    end

    for i=2:nargs
        nextE=args{i};
        if~firstE.equals(nextE)
            pathError(i,'Coder:common:OpaqueTypesDoNotMatch');
        end
    end
    t=coder.OpaqueType(firstE.name,firstE.size,firstE.headerFile,firstE.isPointer,firstE.supportEntryPointIO);
end



function t=miscUnionFi(sz,vd,args,gpuParam)
    if gpuParam.isGpu
        pathError(0,'Coder:common:UnsupportedGpuInputType');
    end
    base_v=args{1};
    nt=numerictype(base_v);
    if isfimathlocal(base_v)
        fm=fimath(base_v);
    else
        fm=[];
    end

    nargs=numel(args);
    same_nts=false(1,nargs);
    same_fms=false(1,nargs);
    c_s=false(1,nargs);
    for k=1:nargs
        arg=args{k};
        same_nts(k)=isequal(nt,numerictype(arg));
        if~isfimathlocal(arg)
            same_fms(k)=isempty(fm);
        else
            same_fms(k)=~isempty(fm)&&isequal(fm,fimath(arg));
        end
        c_s(k)=~isreal(arg);
    end
    if~all(same_nts)
        errInd=find(same_nts==false,1);
        pathError(errInd,'Coder:common:UnionNumericTypes');
    end

    if~all(same_fms)
        errInd=find(same_fms==false,1);
        if isempty(fm)~=isempty(fimath(args{errInd}))
            pathError(errInd,'Coder:common:UnionLocalFiMath');
        else
            pathError(errInd,'Coder:common:UnionFiMath');
        end
    end
    t=coder.FiType(nt,fm,any(c_s),sz,vd);
end



function t=miscUnionCell(sz,vd,args,gpuParam,makeCategoricalCategoryNamesHomogeneous)
    cellarray=args{1};
    for i=1:numel(cellarray)
        cellarray{i}=miscUnion(cellarray(i),gpuParam,makeCategoricalCategoryNamesHomogeneous);
    end
    t=coder.CellType(cellarray,sz,vd);
end



function t=miscUnionClass(className,sz,vd,args,gpuParam,makeCategoricalCategoryNamesHomogeneous)
    if strcmpi(className,'gpuarray')
        t=CreateTypeFromGpuArray(args{1});
    elseif strcmpi(className,'griddedInterpolant')
        pathError(1,'Coder:toolbox:griddedInterpolantCannotBeEntryPoint');
    else
        redirectedClassName=coder.internal.getRedirectedClassName(className);
        instance=args{1};

        tfields=getFlattenedFields(args,gpuParam,makeCategoricalCategoryNamesHomogeneous);

        t=coder.ClassType(...
        className,...
        redirectedClassName,...
        tfields,...
        sz,...
        vd);


        if(isequal(className,'table')||isequal(className,'timetable'))&&all(vd==0)...
            &&coder.type.Base.isEnabled('CLI')...
            &&coder.type.Base.hasCustomCoderType(className)
            t.Properties.rowDim.Properties.length=coder.Constant(height(instance));
        end

        t=coder.type.Base.applyCustomCoderType(t);


        if isa(t,'coder.type.Base')
            t=t.applyConstantAnnotations(instance);
        end

        if makeCategoricalCategoryNamesHomogeneous
            if isa(t,'coder.type.Base')
                t=t.homogenize();
            elseif t.ClassName=="categorical"&&isfield(t.Properties,'categoryNames')


                try
                    t.Properties.categoryNames=t.Properties.categoryNames.makeHomogeneous();
                catch
                end
            end
        end
    end
end



function t=miscUnionStruct(sz,vd,args,varargin)
    tfields=getFlattenedFields(args,varargin{:});
    t=coder.StructType(struct('Fields',tfields),sz,vd);
end



function result=getMxArrayNontunablePropertyNames(arg)
    result=struct();
    if isobject(arg)
        className=getClass(arg);
        if coder.internal.hasPublicStaticMethod(className,'matlabCodegenMxArrayNontunableProperties')
            f=str2func([className,'.matlabCodegenMxArrayNontunableProperties']);
            propertyNames=f(className);
            if~iscell(propertyNames)
                propertyNames={propertyNames};
            end
            for j=1:numel(propertyNames)
                result.(propertyNames{j})=[];
            end
        end
    end
end



function result=getNontunablePropertyNames(arg)
    result=struct();
    if isobject(arg)
        className=getClass(arg);
        if coder.internal.hasPublicStaticMethod(className,'matlabCodegenNontunableProperties')
            f=str2func([className,'.matlabCodegenNontunableProperties']);
            propertyNames=f(className);
            if~iscell(propertyNames)
                propertyNames={propertyNames};
            end
            for j=1:numel(propertyNames)
                result.(propertyNames{j})=[];
            end
        end
    end
end



function fds=flattenField(args,structTypeArgs,fldname,mxArrayNontunablePropertyNames,nontunablePropertyNames)
    n=numel(structTypeArgs);
    fds=cell(1,n);
    for i=1:n
        structTypeArg=structTypeArgs{i};
        if~isfield(structTypeArg,fldname)
            origType=args{i};
            if isstruct(origType)
                pathError(i,'Coder:common:UnionStructFields');
            else

                pathError(i,'Coder:common:UnionClassProperties');
            end
        end
        fields={structTypeArg.(fldname)};
        if isfield(mxArrayNontunablePropertyNames{i},fldname)
            for j=1:numel(fields)
                field=fields{j};
                if~isa(field,'coder.MxArrayConstant')
                    fields{j}=coder.internal.MxArrayConstant(field);
                end
            end
        elseif isfield(nontunablePropertyNames{i},fldname)
            for j=1:numel(fields)
                field=fields{j};
                if~isa(field,'coder.Type')
                    fields{j}=coder.Constant(field);
                end
            end
        end
        fds{i}=fields;
    end
end



function[i,j]=decomposeErrIndex(args,ind)
    if ind==0
        i=0;
        j=0;
    else
        n=0;
        for i=1:numel(args)
            for j=1:numel(args{i})
                n=n+1;
                if n==ind
                    return;
                end
            end
        end
    end
end



function tfields=getFlattenedFields(args,varargin)
    firstArg=args{1};
    mxArrayNontunablePropertyNames=cell(size(args));
    nontunablePropertyNames=cell(size(args));
    if builtin('isstruct',firstArg)
        structTypeArgs=args;
    else




        structTypeArgs=args;
        for k=1:numel(args)
            obj=coder.internal.toRedirected(args{k});
            mxArrayNontunablePropertyNames{k}=getMxArrayNontunablePropertyNames(obj);
            nontunablePropertyNames{k}=getNontunablePropertyNames(obj);
            objStruct=coder.internal.Project.getPropValueList(obj);
            structTypeArgs{k}=objStruct;
        end
        firstArg=structTypeArgs{1};
    end

    fldnames=fieldnames(firstArg);
    tfields=cell2struct(cell(size(fldnames)),fldnames);
    for j=1:numel(fldnames)
        fldname=fldnames{j};
        allFlds=flattenField(...
        args,...
        structTypeArgs,...
        fldname,...
        mxArrayNontunablePropertyNames,...
        nontunablePropertyNames);
        try
            flds=[allFlds{:}];
            if isempty(flds)

                pathError(1,'Coder:common:UnionEmptyStructArray');
            end
            fld=miscUnion(flds,varargin{:});
            tfields.(fldname)=fld;
        catch me
            assert(isa(me,'coder.internal.PathException'));
            ind=me.arrayInd;
            [indOut,indIn]=decomposeErrIndex(args,ind);
            if(indIn==0)
                errPath=['(:).',fldname,me.errPath];
            else
                errPath=['(',num2str(indIn),').',fldname,me.errPath];
            end
            me.arrayInd=indOut;
            me.errPath=errPath;
            me.rethrow();
        end
    end


    fields=fieldnames(tfields);
    for i=1:numel(fields)
        if isa(tfields.(fields{i}),'coder.type.Base')
            tfields.(fields{i})=tfields.(fields{i}).getCoderType();
        end
    end
end



function t=CreateTypeFromGpuArray(in)
    numDims=ndims(in);
    vd=zeros(1,numDims,'logical');
    sz=size(in);
    cls=classUnderlying(in);
    isGpuSparse=issparse(in);
    isGpuComplex=~isreal(in);
    isGpu=true;

    t=coder.PrimitiveType(cls,isGpuSparse,isGpuComplex,sz,vd,isGpu);
end



function className=getClass(arg)
    if isobject(arg)
        className=builtin('class',arg);
    else
        className=class(arg);
    end
end



