function params=hideImplParams(~,~,~)




    params={'usematrixtypesinhdl'};


    if strcmp(hdlfeature('EnableFlattenSFComp'),'off')
        params=[params,{'flattenhierarchy'}];
    end
end