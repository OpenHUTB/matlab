function launchCodePerspective(cbinfo)





    if~coder.internal.toolstrip.license.isSimulinkCoder&&~coder.internal.toolstrip.license.isEmbeddedCoder

        return;
    end

    mdlH=cbinfo.model.Handle;


    if~simulinkcoder.internal.CodePerspective.isInPerspective(mdlH)
        cp=simulinkcoder.internal.CodePerspective.getInstance;
        cp.turnOnPerspective(mdlH);
    end
end