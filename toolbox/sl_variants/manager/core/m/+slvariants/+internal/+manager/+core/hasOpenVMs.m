function flag=hasOpenVMs()








    flag=hasOpenModelVMs()||hasOpenStandaloneVMs();
end

function flag=hasOpenModelVMs()
    flag=false;

    uiTitlePrefix=[message('Simulink:VariantManagerUI:FrameTitlevm').getString(),': '];

    allOpenWins=gleeTestInternal.GLWindow2.findThisType();
    for winIdx=1:numel(allOpenWins)
        if contains(allOpenWins(winIdx).getTitle,uiTitlePrefix)
            flag=true;
            break;
        end
    end

end

function flag=hasOpenStandaloneVMs()
    flag=false;

    vmDlgTag=getString(message('Simulink:VariantManagerUI:FrameDialogTag'));

    allDlgs=DAStudio.ToolRoot.getOpenDialogs;
    for dlgIdx=1:numel(allDlgs)
        if contains(allDlgs(dlgIdx).dialogTag,vmDlgTag)
            flag=true;
            break;
        end
    end

end


