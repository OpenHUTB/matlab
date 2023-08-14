function dtObj=getDataTypeObjIfFixpt(obj,varargin)
    if(slfeature('EnableStoredIntMinMax')==0)
        dtObj='';
        return;
    end
    narginchk(1,3);
    if(~isobject(obj))
        dtObj=[];
        return;
    end
    if(nargin==1)
        context=[];
    else
        context=varargin{1};
        if(nargin==3)
            obj=obj.(varargin{2});
        end
    end

    dt=obj.DataType;

    dtObj=l_evaluateDataTypeInContext(dt,context);

    if isa(dtObj,'Simulink.AliasType')
        dtObj=l_evaluateDataTypeInContext(dtObj.BaseType,context);
    end
    if((isa(dtObj,'Simulink.NumericType')||isnumerictype(dtObj))&&dtObj.isfixed&&~dtObj.isscalingunspecified)
        return;
    else
        dtObj=[];
    end
end

function dtObj=l_evaluateDataTypeInContext(dt,context)



    dtObj=[];
    if(sl('sldtype_is_builtin',dt)||...
        strncmp(dt,'Enum:',4)||...
        strncmp(dt,'Bus:',3)||...
        strcmp(dt,'struct')||...
        strcmp(dt,'auto')||...
        strcmp(dt,'string'))
        return;
    end
    dtObj=Simulink.data.evaluateExpressionInContext(dt,context);
end