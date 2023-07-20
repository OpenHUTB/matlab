function update(hSrc,event)




    event=convertStringsToChars(event);

    cs=hSrc.getConfigSet;
    if strcmp(event,'attach')


        registerPropList(hSrc,'NoDuplicate','All',[]);
    elseif strcmp(event,'switch_target')

        setTIDependentOptionStatus(cs);
        setLinkDependentOptionEnable(cs);


    elseif strcmp(event,'activate')

        setLinkDependentOptionEnable(cs);
        linkfoundation.pjtgenerator.updateStf(hSrc);


    end



    function setTIDependentOptionStatus(cs)

        if~isempty(cs)
            cs.setProp('ProdEqTarget','on');
            cs.setProp('GenerateSampleERTMain','off');
            cs.setProp('GenCodeOnly','on');
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
            end
