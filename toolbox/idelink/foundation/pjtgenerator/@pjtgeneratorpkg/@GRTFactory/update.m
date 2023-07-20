function update(hSrc,event)




    event=convertStringsToChars(event);

    cs=hSrc.getConfigSet;
    if strcmp(event,'attach')


        registerPropList(hSrc,'NoDuplicate','All',[]);
    elseif strcmp(event,'switch_target')
        if~exist('registertic2000.m','file')&&...
            ~exist('registerxilinxise.m','file')
            return;
        end

        setTIDependentOptionStatus(cs);
        setLinkDependentOptionEnable(cs);
        linkfoundation.util.addTargetHardwareResourceComponent(hSrc,-1,'switch');
        trg=linkfoundation.util.getTargetComponent(cs);
        if cs.isValidParam('AdaptorName')&&~isempty(get_param(cs,'AdaptorName'))
            trg.setAdaptor(get_param(cs,'AdaptorName'));
        end
        set_param(cs,'TargetLangStandard','C89/C90 (ANSI)');


    elseif strcmp(event,'activate')

        setLinkDependentOptionEnable(cs);


        hSrc.AdaptorName=strrep(hSrc.AdaptorName,'TI Code Composer','Texas Instruments Code Composer');
        hSrc.AdaptorName=strrep(hSrc.AdaptorName,'ADI VisualDSP','Analog Devices VisualDSP');
        hSrc.AdaptorName=strrep(hSrc.AdaptorName,'GHS MULTI','Green Hills MULTI');

        linkfoundation.util.addTargetHardwareResourceComponent(hSrc,-1,'activate');
    elseif strcmp(event,'deselect_target')


        cs=hSrc.getConfigSet();
        cs.setPropEnabled('MaxStackSize','on');
        if~cs.isHierarchyBuilding


            if~isempty(cs.getComponent('Target Hardware Resources'))&&...
                isempty(find_system(cs.getModel(),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Target Preferences'))

                cs.detachComponent('Target Hardware Resources');
            end
        end
    end



    function setTIDependentOptionStatus(cs)

        if~isempty(cs)
            cs.setProp('ProdEqTarget','on');
            cs.setProp('GenerateSampleERTMain','off');
            cs.setProp('GenCodeOnly','off');
            cs.setProp('GenerateMakefile','off');
        end



        function setLinkDependentOptionEnable(cs)
            if~isempty(cs)
                cs.setPropEnabled('ProdEqTarget','on');
                cs.setPropEnabled('GenCodeOnly','on');
                cs.setProp('GenCodeOnly','off');
                cs.setPropEnabled('GenCodeOnly','off');
                cs.setPropEnabled('GenerateSampleERTMain','off');
                cs.setPropEnabled('GenerateMakefile','off');
                cs.setProp('MaxStackSize','Inherit from target');
                cs.setPropEnabled('MaxStackSize','off');
                cs.setProp('GRTInterface','on');
                cs.setPropEnabled('GRTInterface','off');
                cs.setProp('MultiInstanceErrorCode','Error');
            end
