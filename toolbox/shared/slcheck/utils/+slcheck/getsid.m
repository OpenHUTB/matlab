function sid=getsid(item)
    object=item;
    sid='';
    try
        if isa(object,'Stateflow.Chart')||isa(object,'Stateflow.EMChart')
            sid=fetchsid(object.path);
        elseif contains(class(object),'Stateflow')
            sid=fetchsid(object);
        elseif contains(class(object),'Simulink')
            sid=fetchsid(object.handle,true);
        elseif ishandle(object)
            sid=fetchsid(object,true);
        else
            sid=fetchsid(item);
        end
    catch ME


        sid='';
    end
end

function sid=fetchsid(item,isSimulink)
    if nargin==1
        isSimulink=false;
    end

    try
        temp=Simulink.ID.getSID(item);
        if iscell(temp)||isempty(temp)
            if isSimulink
                sid=Simulink.ID.getSID(get_param(item,'Parent'));
            else
                sid='';
            end
        else
            sid=temp;
        end
    catch E
        sid=item;
    end
end
