function getExtensionUpdate(hObj,event)

    cs=hObj.getConfigSet();
    if isempty(cs),return;end
    model=cs.getModel();

    if any(strcmp(event,{'pre-activate'}))



        setValAndEnForce(cs,'TemplateMakefile','systemverilog_dpi_grt_default_tmf',false);

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
