function prop=getIDEConfigSetSettings(h)





    stf=get_param(h.mConfigSet,'SystemTargetFile');

    if~isequal(stf,'idelink_ert.tlc')&&~isequal(stf,'idelink_grt.tlc')
        if ecoderinstalled()
            stf='ert.tlc';
        else
            stf='grt.tlc';
        end
        stf=['idelink_',stf];
    end

    adaptor=h.getIDEName();

    Fields={'Name','Method','Value'};
    Settings={...
    '','switchTarget',stf;...
    'AdaptorName','AdaptorName',adaptor;...
    'SaveOutput','setProp','off';...
    'SaveTime','setProp','off';...
    'SaveState','setProp','off';...
    'SaveFinalState','setProp','off';...
    'ERTFirstTimeCompliant','setProp','on';...
    'IncludeERTFirstTime','setProp','off';...
    };
    prop=cell2struct(Settings,Fields,2);
end
