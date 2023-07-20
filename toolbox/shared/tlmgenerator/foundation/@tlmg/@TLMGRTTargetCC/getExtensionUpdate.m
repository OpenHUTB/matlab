function getExtensionUpdate(hObj,event)

    cs=hObj.getConfigSet();
    if isempty(cs),return;end
    model=cs.getModel();

    switch(event)

    case{'switch_target','activate'}

    end

    tlmg.private.UtilTargetCC.getExtensionUpdate(hObj,event);

end

function setValAndEn(cs,prop,val,en)
    if(cs.getPropEnabled(prop))
        cs.setProp(prop,val);
        cs.setPropEnabled(prop,en);
    else
        assert(en==false);
    end
end
