function t=newtype(cls,varargin)



































































    t=[];
    try
        if nargin<1
            error(message('Coder:common:NotEnoughInputs'));
        end


        if(~(ischar(cls)&&isrow(cls))&&~(isstring(cls)&&isscalar(cls)))||isequal(cls,"")
            error(message('Coder:common:TypeSpecClassName'));
        end

        switch lower(cls)
        case coder.PrimitiveType.validClasses()
            t=newPrimitive(cls,varargin{:});
        case 'struct'
            t=newStruct(varargin{:});
        case 'cell'
            t=newCell(varargin{:});
        case{'fi','embedded.fi'}
            t=newFi(varargin{:});
        case 'constant'
            t=newConstant(varargin{:});
        case 'string'
            t=newString();
        case 'griddedinterpolant'
            error(message('Coder:toolbox:griddedInterpolantCannotBeEntryPoint'));
        otherwise
            mc=meta.class.fromName(cls);

            if isempty(mc)
                error(message('Coder:common:ClassDefNotFound',cls));
            end
            if~isscalar(mc)||~isa(mc,'meta.class')
                error(message('Coder:common:TypeSpecUnknownClass',cls));
            end
            if~isempty(mc.EnumerationMemberList)
                t=newEnum(cls,mc,varargin{:});
            else
                t=newClass(mc.Name,varargin{:});
            end
        end
    catch me
        me.throwAsCaller();
    end
end



function t=newPrimitive(cls,varargin)
    p=createInputParser();
    p.addParameter('Complex',false);
    p.addParameter('Sparse',false);
    p.addParameter('Gpu',false);

    addSizeParsing(p);

    p.parse(varargin{:});
    r=p.Results;

    s=makeScalarLogical('Sparse',r.Sparse);
    c=makeScalarLogical('Complex',r.Complex);
    g=makeScalarLogical('Gpu',r.Gpu);
    t=coder.PrimitiveType(cls,s,c,r.SizeVector,normvd(r.VariableDims),g);
end



function t=newStruct(varargin)
    p=createInputParser();
    p.addRequired('Fields');
    addSizeParsing(p);

    p.parse(varargin{:});
    t=p.Results;

    t=coder.StructType(struct('Fields',t.Fields),t.SizeVector,normvd(t.VariableDims));
end



function t=newCell(varargin)
    p=createInputParser();
    p.addRequired('Cells');
    if nargin>0
        p.addOptional('SizeVector',size(varargin{1}));
        p.addOptional('VariableDims',logical([]));
    end

    p.parse(varargin{:});
    t=p.Results;

    t=coder.CellType(t.Cells,t.SizeVector,normvd(t.VariableDims));
end



function r=newFi(varargin)
    p=createInputParser();
    p.addRequired('NumericType');
    p.addParameter('Fimath',[]);
    p.addParameter('Complex',false);
    addSizeParsing(p);

    p.parse(varargin{:});
    t=p.Results;
    r=coder.FiType(t.NumericType,t.Fimath,t.Complex,t.SizeVector,normvd(t.VariableDims));
end



function r=newEnum(cls,mc,varargin)
    allowEnumsInPackages=true;
    [r,msg]=coder.internal.isSupportedEnumClass(mc,allowEnumsInPackages);
    if~r
        error(msg);
    end

    p=createInputParser();
    addSizeParsing(p);

    p.parse(varargin{:});
    t=p.Results;
    r=coder.EnumType(cls,t.SizeVector,normvd(t.VariableDims));
end

function r=newClass(className,varargin)
    redirectedClassName=coder.internal.getRedirectedClassName(className);

    if coder.type.Base.hasCustomCoderType(redirectedClassName)


        try

            instance=str2func(className);
            blankInstance=instance();
        catch
            error(message('Coder:common:CoderTypeNoDefaultConstructor',className));
        end

        r=coder.typeof(blankInstance);
    else
        size=[1,1];
        vardim=[false,false];
        r=coder.ClassType(...
        className,...
        redirectedClassName,...
        struct(),...
        size,...
        vardim);
    end
end



function r=newConstant(varargin)
    p=createInputParser();
    p.addRequired('Value');
    p.parse(varargin{:});
    t=p.Results;
    r=coder.Constant(t.Value);
end



function r=newString()
    stringLength=0;
    variableStringLength=false;
    r=coder.StringType([1,1],[false,false],stringLength,variableStringLength);
end


function p=createInputParser
    p=inputParser();
    p.FunctionName='coder.newtype';
end


function addSizeParsing(p)
    p.addOptional('SizeVector',[1,1]);
    p.addOptional('VariableDims',logical([]));
end


function v=makeScalarLogical(name,v)
    if isnumeric(v)
        v=logical(v);
    end

    if isscalar(v)&&islogical(v)
        v=logical(v);
    else
        error(message('Coder:common:RequireScalarLogicalProperty',name));
    end
end

function vd=normvd(vd)
    if isempty(vd)
        vd=logical(vd);
    else
        if~islogical(vd)
            if~isnumeric(vd)||any(isnan(vd(:)))
                error(message('Coder:common:VariableDimsLogical'));
            end

            if~isreal(vd)
                error(message('Coder:common:VariableDimsReal'));
            end

            vd=logical(vd);
        end

        if~isvector(vd)
            error(message('Coder:common:VariableDimsVector'));
        end
    end
end
