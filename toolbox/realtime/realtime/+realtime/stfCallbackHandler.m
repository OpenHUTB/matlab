function stfCallbackHandler(action,hSrc,hDlg)





    switch(action)
    case 'SelectCallback'

        slConfigUISetVal(hDlg,hSrc,'ModelReferenceCompliant','on');
        slConfigUISetEnabled(hDlg,hSrc,'ModelReferenceCompliant',false);

        slConfigUISetVal(hDlg,hSrc,'ProdEqTarget','on');

        slConfigUISetVal(hDlg,hSrc,'ProdHWDeviceType',realtime.getDevice);

        slConfigUISetVal(hDlg,hSrc,'TargetLang','C');
        slConfigUISetEnabled(hDlg,hSrc,'TargetLang',0);

        slConfigUISetVal(hDlg,hSrc,'TargetLibSuffix','.a');

        slConfigUISetVal(hDlg,hSrc,'ERTCustomFileTemplate','realtime_file_process.tlc');

        slConfigUISetVal(hDlg,hSrc,'GenerateMakefile','off');

        slConfigUISetVal(hDlg,hSrc,'RTWVerbose','off');

        slConfigUISetVal(hDlg,hSrc,'InlineParams','off');

        slConfigUISetVal(hDlg,hSrc,'TargetLangStandard','C89/C90 (ANSI)');
        i_updateConfigSet(hSrc);
    case 'ActivateCallback'
        i_updateConfigSet(hSrc);
    case 'DeselectCallback'

        if~isempty(hSrc.getConfigSet)
            cs=hSrc.getConfigSet;
            if~cs.isHierarchyBuilding
                if~isempty(cs.getComponent('Run on Hardware'))

                    cs.detachComponent('Run on Hardware');
                end
            end
        end
    end

end


function i_updateConfigSet(hSrc)
    if~isempty(hSrc)
        cs=hSrc.getConfigSet;
        if~isempty(cs.getComponent('Real-Time Toolbox'))
            cs.Name='Run on Hardware Configuration';
            rttcc=cs.getComponent('Real-Time Toolbox');
            rttcc.Name='Run on Hardware';
            rttcc.Description='Run on Hardware Dialog';
            model=hSrc.getConfigSet.getModel;
            if isempty(getConfigSet(model,'Configuration'))
                newcs=Simulink.ConfigSet;
                attachConfigSet(cs,newcs);
            end
        elseif isempty(cs.getComponent('Run on Hardware'))

            cc=RealTime.SettingsController;

            if~isempty(realtime.getRegisteredTargets)
                targets=realtime.getRegisteredTargets;


                if isequal(length(targets),1)&&isequal(slfeature('OnTargetOneClick'),0)
                    cc.TargetExtensionPlatform=targets{end};
                    realtime.setModelForPlatform(cs,targets{end});
                else


                    cc.TargetExtensionPlatform='None';
                end
            end

            cs.attachComponent(cc);
            if~isequal(cc.TargetExtensionPlatform,'None')
                info=realtime.getParameterTemplate(cs);
                realtime.initializeData(cs,info);
            end
        elseif~isempty(cs.getComponent('Run on Hardware'))
            cc=cs.getComponent('Run on Hardware');
            deprecationObj=realtime.internal.TargetHardware.getTargetHardwareDeprecationInfo(cc.TargetExtensionPlatform);
            if~isempty(deprecationObj)
                deprecationObj.run(cs);
            end
        end
    end
end



