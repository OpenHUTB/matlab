function buildMenu(fcnName,cbinfo)








    if~coder.internal.toolstrip.license.isMATLABCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','MATLAB Coder');
    end

    if strcmp(get_param(cbinfo.model.handle,'IsERTTarget'),'on')
        if~coder.internal.toolstrip.license.isEmbeddedCoder

            DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Embedded Coder');
        end
    else
        if~coder.internal.toolstrip.license.isSimulinkCoder

            DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Simulink Coder');
        end
    end

    fnc=str2func(fcnName);
    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        fnc(cbinfo);
    end
end

function ctrlB(cbinfo)







    editor=cbinfo.studio.App.getActiveEditor;
    cgr=coder.internal.toolstrip.util.getCodeGenRoot(editor);
    buildModel(cbinfo,cgr);




    if SLStudio.toolstrip.internal.areAnyHardwareTabsOpen(cbinfo)
        return;
    end
    studio=cbinfo.studio;



    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if cp.isAvailable(studio)
        if~simulinkcoder.internal.CodePerspective.isInPerspective(studio)
            cp=simulinkcoder.internal.CodePerspective.getInstance;
            cp.turnOnPerspective(studio,'nonblocking');


            cr=simulinkcoder.internal.Report.getInstance;


            codeReport=cp.getTask('CodeReport');
            if~isempty(codeReport)&&codeReport.isAutoOn(cbinfo.model.Handle)
                cr.show(studio);
                cr.focus(studio);
            end
        end
    end

end

function generateCode(cbinfo)







    if slfeature('SDPToolStrip')
        buildCodeGenRoot(cbinfo);
    else
        buildTopModel(cbinfo);
    end
end

function generateCodeAndBuild(cbinfo)









    if~bdIsLibrary(cbinfo.model.Handle)
        cs=getActiveConfigSet(cbinfo.model.Handle);
        if~isa(cs,'Simulink.ConfigSetRef')
            set_param(cbinfo.model.Handle,'GenCodeOnly',false);
        end
    end

    if slfeature('SDPToolStrip')
        buildCodeGenRoot(cbinfo);
    else
        buildTopModel(cbinfo);
    end
end

function generateCodeOnly(cbinfo)









    cs=getActiveConfigSet(cbinfo.model.Handle);
    if~isa(cs,'Simulink.ConfigSetRef')
        set_param(cbinfo.model.Handle,'GenCodeOnly',true);
    end

    if slfeature('SDPToolStrip')
        buildCodeGenRoot(cbinfo);
    else
        buildTopModel(cbinfo);
    end
end





function buildModel(cbinfo,h)


    cbinfo.domain.buildModel(h);
end

function buildTopModel(cbinfo)
    buildModel(cbinfo,cbinfo.studio.App.topLevelDiagram.handle);
end

function buildSelectedSystem(cbinfo)




    selectedSystem=coder.internal.toolstrip.util.getSelectedSystem(cbinfo);
    if isa(selectedSystem,'Simulink.SubSystem')
        subsystemBlock=SLM3I.SLDomain.handle2DiagramElement(selectedSystem.Handle);
        if SLStudio.Utils.objectIsValidSubsystemBlock(subsystemBlock)
            cbinfo.domain.buildSelectedSubsystem(subsystemBlock);
        end
    else

        buildModel(cbinfo,selectedSystem.Handle);
    end

end

function buildCodeGenRoot(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    root=coder.internal.toolstrip.util.getCodeGenRoot(editor);
    buildModel(cbinfo,root);
end


