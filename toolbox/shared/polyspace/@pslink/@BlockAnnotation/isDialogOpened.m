




function flag=isDialogOpened(expectedBlockHandle)

    if ischar(expectedBlockHandle)
        expectedBlockHandle=get_param(expectedBlockHandle,'Handle');
    end

    toolRoot=DAStudio.ToolRoot;
    openDlgs=toolRoot.getOpenDialogs();

    flag=false;

    for ii=1:numel(openDlgs)
        obj=openDlgs(1).getDialogSource();
        if isa(obj,'pslink.BlockAnnotation')&&obj.Block==expectedBlockHandle
            flag=true;
            return
        end
    end


