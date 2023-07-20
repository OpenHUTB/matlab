function props=getPublicProperties(obj,inclusionFlags,defaultValues)

























    allOptions={'Default','Constant','Inactive','Hidden',...
    'Dependent','Transient','Nonsettable','State'};

    if nargin>1

        if~iscellstr(inclusionFlags)
            matlab.system.internal.error('MATLAB:system:invalidGetPublicPropertiesArgs');
        end
    else
        inclusionFlags={};
    end

    if nargin<3
        defaultValueCheckFcn=@(mp)isDefaultProperty(obj,mp);
    else
        defaultValueCheckFcn=@(mp)isDefaultValueWithReference(mp,obj,defaultValues);
    end


    optionVals(1:numel(allOptions),1)={false};
    optionVals(ismember(allOptions,inclusionFlags))={true};
    [getDefault,getConstant,getInactive,getHidden,getDependent,...
    getTransient,allGettable,getState]=optionVals{:};


    filterFcn=@(mp)publicPropertyFilter(mp,obj,getDefault,getConstant,getInactive,...
    getHidden,getDependent,getTransient,allGettable,getState,defaultValueCheckFcn);

    props=scanProperties(obj,filterFcn);
    props=props(:);

end



function keep=publicPropertyFilter(mp,obj,getDefault,getConstant,getInactive,...
    getHidden,getDependent,getTransient,allGettable,getState,defaultValueCheckFcn)
    dep=mp.Dependent;
    cmp=isa(mp,'matlab.system.CustomMetaProp');
    name=mp.Name;

    if...
        ~mp.Abstract&&...
...
        (getConstant||~mp.Constant)&&...
...
        (allGettable||(~iscell(mp.SetAccess)&&strcmp(mp.SetAccess,'public')&&...
        ~(dep&&isempty(mp.SetMethod))))&&...
...
        (getState||~(cmp&&(mp.DiscreteState||mp.ContinuousState)))&&...
...
        (~iscell(mp.GetAccess)&&strcmp(mp.GetAccess,'public')&&...
        ~(dep&&isempty(mp.GetMethod)))&&...
...
        (getTransient||~mp.Transient)&&...
...
        (getHidden||~mp.Hidden)&&...
...
        (getDependent||~dep)&&...
...
        (getInactive||~isInactiveProperty(obj,name))&&...
...
        (getDefault||~defaultValueCheckFcn(mp))
        keep=true;
    else
        keep=false;
    end
end

function isDefault=isDefaultValueWithReference(mp,obj,defaultValues)
    name=mp.Name;
    if~isempty(defaultValues)...
        &&((isobject(defaultValues)&&isprop(defaultValues,name))...
        ||(isstruct(defaultValues)&&isfield(defaultValues,name)))
        isDefault=isequal(obj.(name),defaultValues.(name));
    else
        isDefault=isDefaultProperty(obj,mp);
    end
end

function isDefault=isDefaultProperty(obj,mp)
    if mp.HasDefault
        defaultValue=mp.DefaultValue;
    else
        defaultValue=[];
    end
    objValue=obj.(mp.Name);
    isDefault=defaultValueComparison(objValue,defaultValue);
end

function flag=defaultValueComparison(a,b)
    flag=strcmp(class(a),class(b))&&isequal(a,b);
end

function props=scanProperties(obj,filterFcn)












    m=metaclass(obj);
    mpList=m.PropertyList;


    includeProperty=false(size(mpList));
    for n=1:numel(mpList)
        includeProperty(n)=filterFcn(mpList(n));
    end
    props={mpList(includeProperty).Name};
end

