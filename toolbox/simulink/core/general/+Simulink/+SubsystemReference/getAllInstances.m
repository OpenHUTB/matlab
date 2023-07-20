function result=getAllInstances(input)










    handle=get_param(input,'Handle');
    if~strcmp(get_param(handle,'Type'),'block_diagram')
        error(message('Simulink:SubsystemReference:InputMustBeBD'));
    end

    block_sids=transpose(slInternal('getAllSSRefBlocksOfBD',handle));
    if isempty(block_sids)
        result=block_sids;
        return;
    end

    result=get_param(block_sids,'Handle');
    if ishandle(input)
        return;
    end



    [m,n]=size(result);
    if(m==1&&n==1)
        result={getfullname(result{1,1})};
    else
        result=getfullname(result);
    end
end
