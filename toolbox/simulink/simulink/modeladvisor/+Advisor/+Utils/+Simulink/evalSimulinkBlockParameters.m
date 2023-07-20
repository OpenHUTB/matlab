












function values=evalSimulinkBlockParameters(slObjects,parameter)


    if ischar(slObjects)
        slObjects={slObjects};
    end

    values=cell(1,length(slObjects));

    for n=1:length(slObjects)

        if iscell(slObjects(n))
            tempSlObject=slObjects{n};
        else
            tempSlObject=slObjects(n);
        end


        if isa(tempSlObject,'Simulink.Block')
            objectHandle=tempSlObject.Handle;
        elseif ischar(tempSlObject)
            objectHandle=get_param(tempSlObject,'Handle');
        elseif isnumeric(tempSlObject)&&ishandle(tempSlObject)
            objectHandle=tempSlObject;
        else

            DAStudio.error('Advisor:engine:invalidInputArgs','Advisor.Utils.evalSimulinkBlockParameters');
        end

        try
            values{n}=slResolve(get_param(objectHandle,parameter),...
            objectHandle);
        catch err


            if strcmp(err.identifier,'Simulink:Data:SlResolveNotResolved')
                DAStudio.error('Advisor:engine:SLBlockParameterResolveError',...
                parameter,...
                getfullname(objectHandle));
            end


            rethrow(err);
        end
    end
end