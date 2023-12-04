function selectOutput(data,cbInfo)

    if~cbInfo.EventData
        return;
    end
    refresher=coder.internal.toolstrip.util.Refresher(cbInfo.studio);%#ok<NASGU>

    if slfeature('SDPToolStrip')
        mdl=cbInfo.studio.App.getActiveEditor.blockDiagramHandle;
    else
        mdl=cbInfo.model.handle;
    end

    if slfeature('SDPToolStrip')
        ok=coder.internal.toolstrip.util.changePlatformWarningDlg(mdl,'',...
        coder.internal.toolstrip.util.getOutputText(data));
        if~ok
            return;
        end
    end

    csOrRef=getActiveConfigSet(mdl);
    isCsRef=isa(csOrRef,'Simulink.ConfigSetRef');
    if isCsRef
        cs=csOrRef.getRefConfigSet;
    else
        cs=csOrRef;
    end

    if strcmp(data,'cpp')
        locSwitchTargetIfNecessary(mdl,cs,'ert.tlc');
        cs.set_param('EmbeddedCoderDictionary','');
        cs.set_param('TargetLang','C++');
        cs.set_param('CodeInterfacePackaging','C++ class');
    elseif strcmp(data,'ert')
        locSwitchTargetIfNecessary(mdl,cs,'ert.tlc');
        cs.set_param('TargetLang','C');
    elseif strcmp(data,'grt_cpp')
        locSwitchTargetIfNecessary(mdl,cs,'grt.tlc');
        cs.set_param('EmbeddedCoderDictionary','');
        cs.set_param('TargetLang','C++');
        cs.set_param('CodeInterfacePackaging','C++ class');
    elseif strcmp(data,'autosar')
        locSwitchTargetIfNecessary(mdl,cs,'autosar.tlc');

        simulinkcoder.internal.util.createMappingAndInitDictIfNecessary(mdl,false);
    elseif strcmp(data,'autosar_adaptive')
        locSwitchTargetIfNecessary(mdl,cs,'autosar_adaptive.tlc');

        simulinkcoder.internal.util.createMappingAndInitDictIfNecessary(mdl,false);
    elseif strcmp(data,'dds')
        locSwitchTargetIfNecessary(mdl,cs,'ert.tlc');
        cs.set_param('EmbeddedCoderDictionary','');
        cs.set_param('TargetLang','C++');
        cs.set_param('CodeInterfacePackaging','C++ class');
    elseif strcmp(data,'grt')
        locSwitchTargetIfNecessary(mdl,cs,'grt.tlc');
        cs.set_param('TargetLang','C');
    else
        try
            cs.set_param('TargetLang','C');
        catch
        end
        target=[data,'.tlc'];
        cs.switchTarget(target,[]);
    end

    if isCsRef
        if strcmp(csOrRef.SourceLocation,'Data Dictionary')

            dd=Simulink.dd.open(csOrRef.DDName);
            dd.setEntry(['Configurations.',cs.Name],cs);
        end
    end

    function locSwitchTargetIfNecessary(mdl,cs,finalTarget)
        currentTarget=get_param(mdl,'SystemTargetFile');
        if~strcmp(currentTarget,finalTarget)
            cs.switchTarget(finalTarget,[]);
        end

