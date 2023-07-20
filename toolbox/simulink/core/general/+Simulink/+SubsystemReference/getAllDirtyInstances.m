function result=getAllDirtyInstances(input)











    if~strcmp(get_param(input,'Type'),'block_diagram')
        error(message('Simulink:SubsystemReference:InputMustBeBD'));
    end

    handle=get_param(input,'Handle');
    result=slInternal('getAllDirtySSRefBDs',handle);
    if isempty(result)
        return;
    end

    if ishandle(input)


        result=num2cell(result);
        return;
    end

    result=getfullname(result);
end

