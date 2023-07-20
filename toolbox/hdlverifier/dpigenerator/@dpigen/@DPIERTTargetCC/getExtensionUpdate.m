function getExtensionUpdate(hObj,event)

    cs=hObj.getConfigSet();

    if any(strcmp(event,{'attach','pre-attach'}))
        setProp(hObj,'UseToolchainInfoCompliant','on');
    end

    if isempty(cs),return;end

    switch(event)
    case{'pre-activate'}



        setValAndEnForce(cs,'TemplateMakefile','systemverilog_dpi_ert_default_tmf',false);
    case{'switch_target','activate'}

        setParamAndEn(cs,'CodeInterfacePackaging','Reusable function',false);
        setValAndEnForce(cs,'RootIOFormat','Part of model data structure',false);
        setValAndEnForce(cs,'GenerateAllocFcn','on',false)
        setValAndEnForce(cs,'IncludeMdlTerminateFcn','on',true);

        setValAndEn(cs,'EnableUserReplacementTypes','off',false);
        setValAndEnForce(cs,'ERTCustomFileTemplate','example_file_process.tlc',true);

    end

    dpinmspc.private.UtilTargetCC.getExtensionUpdate(hObj,event);

end

function setValAndEn(cs,prop,val,en)
    if(cs.getPropEnabled(prop))
        cs.setProp(prop,val);
        cs.setPropEnabled(prop,en);
    else
        assert(en==false);
    end
end
function setValAndEnForce(cs,prop,val,en)
    cs.setPropEnabled(prop,true);
    setValAndEn(cs,prop,val,en);
end
function setParamAndEn(cs,prop,val,en)
    if(cs.getPropEnabled(prop))
        cs.set_param(prop,val);
        cs.setPropEnabled(prop,en);
    else
        assert(en==false);
    end
end
