function bridgeToSaveVars(cs,vs)



    etm=configset.util.ExportToM(cs,'');

    if etm.containCustomCC
        vs.writeErrorAsWarning(DAStudio.message('Simulink:tools:MFileBridgeComponentNotSupported'));
        vs.writeMethodCall('set_param','Name',cs.get_param('Name'));
        vs.writeMethodCall('set_param','Description',cs.get_param('Description'));
    else
        result=etm.result;
        for i=1:length(result)
            r=result{i};
            method='set_param';
            if~isobject(r.value)
                vs.writeMethodCall(method,r.param,r.value);
            end
        end
    end

