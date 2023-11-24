function openElement(absoluteFilePath,artifact,blockDiagramName)


    a_bd=artifact.ParentArtifact;
    alm.internal.sl.openElement(absoluteFilePath,a_bd,blockDiagramName);
    isBd=strcmp(blockDiagramName,artifact.Address)&&...
    artifact.isElement()&&artifact.IsNamespace;

    if~isBd
        sid=blockDiagramName+":"+artifact.Address;

        h=Simulink.ID.getHandle(sid);


        if isnumeric(h)
            open_system(sid);
        else
            sf('Select',h.Chart.Id,h.Id)
            h.fitToView;
        end
    end
end
