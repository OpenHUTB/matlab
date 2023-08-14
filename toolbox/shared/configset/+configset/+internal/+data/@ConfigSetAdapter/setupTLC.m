function setupTLC(obj,cs)






    if obj.tlcCreated
        return;
    end
    obj.tlcCreated=true;

    m=containers.Map;
    obj.tlcInfo=m;
    obj.tlcCategory={};


    if isempty(cs.getComponent('Code Generation'))||...
        isempty(cs.getComponent('Code Generation').getComponent('Target'))
        return;
    end




    owner=cs.getComponent('Code Generation').getComponent('Target');
    if configset.htmlview.custom_functions.getComponentData([],class(owner))
        return;
    end


    tlcBase=cs.getProp('SystemTargetFile');
    try
        [tlcOptions,settings]=coder.internal.getSTFInfo([],'SystemTargetFile',tlcBase);
        tlcOptions=num2cell(tlcOptions);
    catch
        return;
    end


    mcs=configset.internal.getConfigSetStaticData;
    parent=owner;
    while isfield(settings,'DerivedFrom')&&~isempty(settings.DerivedFrom)


        if~isempty(parent.Components)
            parent=parent.Components(1);
            if~isa(parent,'Simulink.STFCustomTargetCC')
                break;
            end
        end

        tlcBase=settings.DerivedFrom;
        tlcName=strtok(settings.DerivedFrom,'.');
        if~isempty(mcs.getComponent(tlcName))
            break;
        end
        try
            [parentTlcOptions,settings]=coder.internal.getSTFInfo([],'SystemTargetFile',settings.DerivedFrom);
        catch
            tlcOptions=[];
            parentTlcOptions=[];
            settings.DerivedFrom='';
        end
        if~isempty(parentTlcOptions)
            tlcOptions=[num2cell(parentTlcOptions),tlcOptions];%#ok<AGROW>
        end

    end



    if isa(cs,'Simulink.ConfigSet')
        rtw=cs.getComponent('Code Generation');
        tgt=rtw.getComponent('Target');
    end


    cat={};
    for i=1:length(tlcOptions)
        tlcOpt=tlcOptions{i};
        if strcmp(tlcOpt.type,'Category')
            cat{end+1}=loc_addCSH(tlcOpt,tlcBase);%#ok
        else
            name=tlcOpt.tlcvariable;
            if isempty(name)


                name=tlcOpt.makevariable;
            end
            if~isempty(name)&&tgt.isValidParam(name)&&cs.isValidParam(name)

                if tgt.getPropOwner(name)==cs.getPropOwner(name)
                    p=configset.internal.data.ParamStaticData(tlcOpt,owner);
                    m(name)=p;
                    cat{end+1}=p;%#ok<AGROW>
                end
            elseif strcmp(tlcOpt.type,'Pushbutton')
                cat{end+1}=tlcOpt;%#ok<AGROW>
            end
        end
    end

    obj.tlcInfo=m;
    obj.tlcCategory=cat;

    function info=loc_addCSH(info,tlc)

        switch(tlc)
        case 'autosar.tlc'
            info.cshpath='ecoder/csh/configparams/Simulink.ConfigSet@Tag_ConfigSet_RTW_AUTOSAR_Code_Generation_Options.map';
        case 'rtwsfcn.tlc'
            info.cshpath='rtw/csh/configparams/Simulink.ConfigSet@Tag_ConfigSet_RTW_S_Function_Target.map';
        end

