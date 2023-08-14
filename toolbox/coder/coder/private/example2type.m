


function ty=example2type(ex,ec)

    theClass=class(ex);
    switch theClass
    case 'emlcoder.Example'
        if isscalar(ex)
            switch ex.Type
            case 'CONST'
                ty=const2type(ex,ec);
            case 'SIZE'
                ty=size2type(ex,ec);
            end
        else
            error(message('Coder:common:RequireScalarExample',ec));
        end
    case 'struct'
        ty=struct2type(ex,ec);
    otherwise
        if isa(ex,'matlab.system.SystemImpl')
            error(message('Coder:common:ExampleSysObjNotSupported',ec));
        elseif isa(ex,'coder.Type')
            error(message('Coder:common:ExampleCoderTypeNotSupported',ec));
        end

        try
            ty=coder.typeof(ex);
        catch me
            example2typeError(me,ec);
        end
    end
end

function example2typeError(me,ec)
    x=coderprivate.msgSafeException('Coder:common:IllegalExampleInput',ec,me.message);
    x=coderprivate.transferCauses(me,x);
    x.throwAsCaller();







end

function ty=const2type(ex,ec)
    v=ex.Value2;
    try
        ty=coder.newtype('constant',v);
    catch me
        example2typeError(me,ec);
    end
end

function ty=size2type(ex,ec)
    v=ex.Value2;
    if isempty(v)
        error(message('Coder:common:ExampleSizeEmpty',ec));
    end
    ty=example2type(v,[ec,'(:)']);

    if isempty(ex.Value1)
        sz=size(v);
    elseif isscalar(ex.Value1)
        sz=ones(size(size(v)));
        sz(1)=ex.Value1;
    else
        sz=ex.Value1;
    end

    if isempty(ex.Value3)
        vd=sz~=1;
    else
        vd=ex.Value3;
    end

    for i=1:min(numel(vd),numel(sz))
        if vd(i)&&sz(i)==0
            warning(message('Coder:common:ExampleSizeDynamicEmpty',ec));
            vd(i)=false;
        end
    end

    try
        ty=coder.resize(ty,sz,vd,'recursive',false,'uniform',true);
    catch me
        example2typeError(me,ec);
    end
end

function ty=struct2type(ex,ec)
    function ty=struct2typehelper(ind)
        fldNames=fieldnames(ex(ind));
        if isempty(fldNames)
            tfields=struct();
        else
            tfields=cell2struct(cell(size(fldNames)),fldNames);
            for j=1:numel(fldNames)
                fldName=fldNames{j};
                fldVal=ex(ind).(fldName);
                if isscalar(ex)
                    ec2=[ec,'.',fldName];
                else
                    ec2=[ec,'(',num2str(ind),').',fldName];
                end
                fldType=example2type(fldVal,ec2);
                tfields.(fldName)=fldType;
            end
        end
        try
            ty=coder.newtype('struct',tfields,size(ex),[]);
        catch me
            example2typeError(me,ec);
        end
    end

    if isempty(ex)
        error(message('Coder:common:ExampleSizeEmpty',ec));
    end
    ty=struct2typehelper(1);
    for i=2:numel(ex)
        ty_i=struct2typehelper(i);
        if~isequal(ty,ty_i)
            reportTypeMismatch(ty,[ec,'(1)'],ty_i,[ec,'(',num2str(i),')']);
        end
    end
end

function reportTypeMismatch(ty1,ec1,ty2,ec2)

    if~strcmp(ty1.ClassName,ty2.ClassName)
        error(message('Coder:common:ExampleUnequalClasses',ec1,ty1.ClassName,ec2,ty2.ClassName));
    else
        if isa(ty1,'coder.Constant')
            if~isequal(ty1.Value,ty2.Value)
                error(message('Coder:common:ExampleUnequalConstants',ec1,ec2));
            end
        else
            if~isequal(ty1.SizeVector,ty2.SizeVector)||~isequal(ty1.VariableDims,ty2.VariableDims)
                error(message('Coder:common:ExampleUnequalSizes',ec1,ec2));
            end
            switch class(ty1)
            case 'coder.PrimitiveType'
                if ty1.Complex~=ty2.Complex
                    error(message('Coder:common:ExampleUnequalComplexity',ec1,ec2));
                end
                if ty1.Sparse~=ty2.Sparse
                    error(message('Coder:common:ExampleUnequalSparse',ec1,ec2));
                end
            case 'coder.FiType'
                if ty1.Complex~=ty2.Complex
                    error(message('Coder:common:ExampleUnequalComplexity',ec1,ec2));
                end
                if~isequal(ty1.NumericType,ty2.NumericType)
                    error(message('Coder:common:ExampleUnequalNumerictype',ec1,ec2));
                end
                if isempty(ty1.Fimath)~=isempty(ty2.Fimath)
                    error(message('Coder:common:ExampleUnequalFimath',ec1,ec2));
                elseif~isempty(ty1.Fimath)&&~isequal(ty1.Fimath,ty2.Fimath)
                    error(message('Coder:common:ExampleUnequalFimath',ec1,ec2));
                end
            case 'coder.EnumType'
                if~strcmp(ty1.ClassName,ty2.ClassName)
                    error(message('Coder:common:ExampleUnequalEnum',ec1,ty1.ClassName,ec2,ty2.ClassName));
                end
            case 'coder.StructType'
                reportStructTypeMismatch(ty1,ec1,ty2,ec2);
            otherwise
                assert(false);
            end
        end
    end
end

function reportStructTypeMismatch(ty1,ec1,ty2,ec2)
    s1=ty1.Fields;
    s2=ty2.Fields;
    fldNames=fieldnames(s1);

    for i=1:numel(fldNames)
        fldName=fldNames{i};
        if~isfield(s2,fldName)
            error(message('Coder:common:ExampleUnequalFieldName',ec1,fldName,ec2));
        end
        reportTypeMismatch(s1.(fldName),[ec1,'.',fldName],s2.(fldName),[ec2,'.',fldName]);
    end
end


