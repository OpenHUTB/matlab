function cb_refreshDialog(h,src,evnt)

    dlgs=DAStudio.ToolRoot.getOpenDialogs(h);
    for i=1:length(dlgs)
        dlgs(i).refresh;
    end
end

