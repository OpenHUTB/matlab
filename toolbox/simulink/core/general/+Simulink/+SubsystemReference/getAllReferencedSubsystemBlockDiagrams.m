function result=getAllReferencedSubsystemBlockDiagrams(input)













    if~strcmp(get_param(input,'Type'),'block_diagram')
        error(message('Simulink:SubsystemReference:InputMustBeBD'));
    end

    handle=get_param(input,'Handle');
    result=slInternal('getChildSubsystemBDs',handle);
    if isempty(result)
        return;
    end


    if ishandle(input)


        result=num2cell(result);
    else
        result=getfullname(result);
    end
end
