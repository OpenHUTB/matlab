function updateStf(hTgt)





    cs=hTgt.getConfigSet();
    if isempty(cs)
        return
    end


    oldStf=get_param(cs,'SystemTargetFile');
    switch(oldStf)
    case{'vdsplink_ert.tlc','vdsplink_grt.tlc'}
        adaptorName='Analog Devices VisualDSP++';
    case{'ccslink_ert.tlc','ccslink_grt.tlc'}
        adaptorName='Texas Instruments Code Composer Studio';
    case{'multilink_ert.tlc','multilink_grt.tlc'}
        adaptorName='Green Hills MULTI';
    otherwise
        return;
    end


    if strcmpi(hTgt.IsERTTarget,'on')
        stf='idelink_ert.tlc';
    else
        stf='idelink_grt.tlc';
    end


    origCs=cs.copy;


    set_param(cs,'SystemTargetFile',stf);
    set_param(cs,'buildFormat','Project');
    set_param(cs,'systemHeapSize',512);

    trg=linkfoundation.util.getTargetComponent(cs);
    trg.setAdaptor(adaptorName);


    settingsNotToRestore={...
    'TemplateMakefile',...
    'SystemTargetFile',...
    'IsERTTarget',...
    'ERTFirstTimeCompliant',...
    'buildFormat',...
    'systemHeapSize',...
    'GRTInterface',...
    'MultiInstanceERTCode'};
    for i=1:length(origCs.Component)
        restoreSettings(origCs,cs,origCs.Component(i).Name,settingsNotToRestore);
    end





    set_param(cs,'ProdEqTarget','on');


    if(ismethod(trg,'updateParametersForOldModels'))
        trg.updateParametersForOldModels();
    end



    function restoreSettings(origCS,cs,componentName,settingsNotToRestore)


        componentOrig=origCS.getComponent(componentName);
        componentNew=cs.getComponent(componentName);
        if isempty(componentOrig)||isempty(componentNew)
            return;
        end
        propsOrig=componentOrig.getProp;
        propsNew=componentNew.getProp;
        props=intersect(propsNew,propsOrig);
        props=setdiff(props,settingsNotToRestore);
        for i=1:length(props)
            prop=props{i};
            try
                val=get_param(componentOrig,prop);
                enabledState=componentOrig.getPropEnabled(prop);
                componentNew.setPropEnabled(prop,'on');
                set_param(componentNew,prop,val);
                componentNew.setPropEnabled(prop,enabledState);
            catch %#ok<CTCH>

            end
        end
