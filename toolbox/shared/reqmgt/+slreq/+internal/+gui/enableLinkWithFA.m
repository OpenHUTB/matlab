function r=enableLinkWithFA()
    r=struct('name',getString(message('Slvnv:slreq:LinkWithSelectedFaultObj')),...
    'tag','','callback','','accel','','enabled',false,'visible',true,'me',[]);

    if~rmifa.isFaultLinkingEnabled()
        return;
    end

    if dig.isProductInstalled('Simulink')&&is_simulink_loaded
        r.enabled=rmifa.isFaultTableSelectionValid();
    end
end
