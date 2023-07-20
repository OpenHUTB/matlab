classdef(Sealed)AttributeDefs<codergui.internal.type.AttributeDef




    enumeration
        Class('class','Class','MatlabClassName')
        Size('size','Size','Size','Value',codergui.internal.type.Size.scalar())
        IndexAddress('address','IndexAddress','IndexVector','Presenter',@presentCellArrays)
        FieldAddress('address','FieldAddress','MatlabIdentifier')
        PropertyAddress('address','PropertyAddress','MatlabIdentifier')
        Address('address','','MatlabIdentifier','Visible',false)
        Value('value','Value','Any','Validator',@mustBeSupportedValueType)
        InitValue('initialValue','InitValue','Any','Validator',@mustBeSupportedValueType,'Visible',false)
        ValueExpression('valueExpression','','MatlabCode','Visible',false,'Internal',true)
        Complex('complex','Complex','Boolean')
        Sparse('sparse','Sparse','Boolean','Validator',@sparseCannotBeGpu)
        Gpu('gpu','Gpu','Boolean','Validator',@gpuCannotBeSparse)
        Extern('extern','Extern','Boolean')
        HeaderFile('headerFile','HeaderFile','File')
        Alignment('alignment','Alignment','Integer','Value',-1,'AllowedValues',[-1,2.^(1:7)]),
        Homogeneous('homogeneous','Homogeneous','Boolean')
        TypeName('typeName','TypeName','Text')
        RedirectedClass('redirectedClass','RedirectedClass','MatlabClassName','Internal',true)
        FunctionName('functionName','FunctionName','MatlabFunctionName','Value','myFunctionName')
        OutputIndex('outputIndex','OutputIndex','PositiveInteger')


        StringSize('stringSize','StringSize','Integer','Value',0,'Min',0,'Validator',@mustBeValidStringSize,'Presenter',@presentStringSize)
        VarSize('varSize','VarSize','Boolean')
        Unbounded('unbounded','Unbounded','Boolean','Validator',@unboundedMustBeVarsize)
    end

    methods
        function this=AttributeDefs(key,msgToken,valueType,varargin)
            this@codergui.internal.type.AttributeDef(key,valueType,...
            'Name',getMessage(msgToken,'Name'),...
            'Description',getMessage(msgToken,'Desc'),...
            varargin{:});
        end
    end
end


function[displayValue,tags]=presentCellArrays(value)
    tags=[];
    if isnumeric(value)&&~isempty(value)
        if value==-1
            displayValue="{:}";
        else
            displayValue=sprintf("{%s}",strjoin(string(value),","));
        end
    else
        displayValue=codergui.internal.undefined();
    end
end


function[displayValue,tags]=presentStringSize(value)
    tags=[];
    if value==Inf
        displayValue="Inf";
    elseif value==-Inf
        displayValue="-Inf";
    else
        displayValue=codergui.internal.undefined();
    end
end


function value=mustBeSupportedValueType(value,node)

    coder.typeof(value);
    node.set('valueExpression','');
end


function value=mustBeValidStringSize(value,node)
    if strcmp(value,'Inf')
        value=Inf;
    end
    if value==Inf
        if~node.get('unbounded')
            node.set('unbounded',true);
        end
    else
        mustBeInteger(value);
        value=max(value,0);
        if value==0&&node.get('varSize')
            node.set('varSize',false);
        end
    end
end


function sparse=sparseCannotBeGpu(sparse,node)
    if sparse&&node.get('gpu')
        node.set('gpu',annotate(false,message('coderApp:typeMaker:sparseArrayCannotBeGpu')));
    end
end


function gpu=gpuCannotBeSparse(gpu,node)
    if gpu&&node.get('sparse')
        node.set('sparse',annotate(false,message('coderApp:typeMaker:gpuArrayCannotBeSparse')));
    end
end


function unbounded=unboundedMustBeVarsize(unbounded,node)
    node.set('varSize',unbounded||node.get('stringSize')~=0);
end


function annotated=annotate(value,annotation)
    annotated=codergui.internal.util.AnnotatedValue(value,annotation);
end


function msg=getMessage(msgToken,keyType)
    if isempty(msgToken)
        msg=msgToken;
        return
    end
    try
        msg=getString(message(sprintf('coderApp:metaTypes:attr%s%s',msgToken,keyType)));
    catch
        msg=msgToken;
    end
end