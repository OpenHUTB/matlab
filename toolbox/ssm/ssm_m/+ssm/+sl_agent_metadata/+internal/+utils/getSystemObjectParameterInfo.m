function ret=getSystemObjectParameterInfo(sysObjectName)




    ret={};
    if isempty(sysObjectName)||(exist(sysObjectName,'file')~=2)
        return
    end

    sysObj=feval(sysObjectName);
    metaSysObj=metaclass(sysObj);

    ptyList=metaSysObj.PropertyList;
    if isempty(ptyList);return;end


    for idx=numel(ptyList):-1:1
        pty=ptyList(idx);


        if~strcmpi(pty.GetAccess,'public')||pty.Hidden||pty.Nontunable
            continue
        end

        mdlArg=getDefaultModelArgumentStruct;


        mdlArg.Name=string(pty.Name);
        mdlArg.Value=pty.DefaultValue;
        mdlArg.DataType=string(class(pty.DefaultValue));
        mdlArg.Dimensions=size(pty.DefaultValue);
        if isreal(pty.DefaultValue);mdlArg.Complexity="real";end

        ret{idx}=mdlArg;
    end


    ret=ret(~cellfun('isempty',ret));
end

function ret=getDefaultModelArgumentStruct()

    ret=struct(...
    'Name',"var_array",...
    'Value',[],...
    'DataType',"double",...
    'Dimensions',[],...
    'Complexity',"",...
    'Min',[],...
    'Max',[],...
    'Unit',"",...
    'Type',"Variable",...
    'MaskInfo',[]...
    );
end
