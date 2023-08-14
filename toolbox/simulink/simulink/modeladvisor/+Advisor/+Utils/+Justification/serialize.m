function serialize(model)



    justificationFile=getJustificationFile(model);


    firstJustification=~isfile(justificationFile);

    manager=slcheck.getAdvisorJustificationManager(model);
    manager.save(true);


    if firstJustification
        createSimulinkBanner(model,justificationFile)
    end
end

function justificationFilePath=getJustificationFile(model)

    justificationFilePath=[pwd,'/',model,'_justifications.json'];
end


function createSimulinkBanner(model,fileName)
    editor=GLUE2.Util.findAllEditors(model);
    if~isempty(editor)
        editor.deliverWarnNotification('slcheck:filtercatalog:JustificationWarningNotification',...
        DAStudio.message('slcheck:filtercatalog:JustificationFileCreationSuccess',fileName));
    end
end
