function[url,view]=entryPoint(src)



    if isa(src,'Simulink.ConfigSet')
        DAStudio.error('SimulinkCoderApp:core:InvalidBackendName','Simulink.ConfigSet');
    end

    if isnumeric(src)
        params=getModelParameters();
        try
            [url,view]=simulinkcoder.internal.app.start(src,params{:});
        catch me
            diag=MSLException([],me);
            sldiagviewer.reportError(diag);
        end
    else
        [url,view]=simulinkcoder.internal.app.start(src);
    end


end

function params=getModelParameters()
    if slsvTestingHook('CoderDataUIReturnURL')>0
        params={'launchType','returnurl'};
    else
        params={};
    end
end

