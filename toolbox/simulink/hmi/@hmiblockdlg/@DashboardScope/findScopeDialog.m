


function dlg=findScopeDialog(hBlk)
    dlg=[];
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if ismethod(dlgSrc,'getBlock')
            thisBlockHandle=get(dlgSrc.getBlock(),'handle');
            if thisBlockHandle==hBlk
                dlg=dlgSrc;
                return
            end
        end
    end
end
