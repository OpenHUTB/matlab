function result=onCheckBoxSelectionChange(this,~,~,bindableMetaData,isChecked)















    port=get_param(bindableMetaData.blockPathStr,'PortHandles');

    if strfind(bindableMetaData.name,'enable')
        portHandle=port.Enable;
    elseif strfind(bindableMetaData.name,'trigger')
        portHandle=port.Trigger;
    else
        portHandle=port.Inport(bindableMetaData.portNumber);
    end

    if isChecked

        operationToPerform='AddSelection';
    else

        operationToPerform='RemoveSelection';
    end


    try

        Function='sigandscopemgr';
        feval(Function,operationToPerform,this.sourceElementHandle,...
        1,portHandle);




        if~isempty(this.UpdateCallback)
            this.UpdateCallback();
        end

        result=1;


    catch ex
        result.error=true;
        if isa(ex,'MException')
            result.faultMessage=ex.message
        end
    end


end




function out=i_LinkedToSignalAndScopeMgr(block)
    out=~strcmp(get_param(block,'IOType'),'none');
end



