


function enterKeyPressed(blockHandle,~)
    if ischar(blockHandle)
        blockHandle=str2double(blockHandle);
    end
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if ismethod(dlgSrc,'getBlock')
            thisBlockHandle=get(dlgSrc.getBlock(),'handle');
            if thisBlockHandle==blockHandle
                hmiDlgs=dlgSrc.getOpenDialogs(true);
                for j=1:length(hmiDlgs)
                    if(hmiDlgs{j}.isStandAlone)
                        hmiDlgs{j}.delete;
                    end
                end
            end
        end
    end
end
