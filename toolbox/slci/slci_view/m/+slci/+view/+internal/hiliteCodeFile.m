


function hiliteCodeFile(aFileName,aMdlName)
    try
        sts=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        currentStudio=sts(1);

        cbinfo=[];
        cbinfo.studio=currentStudio;
        slci.toolstrip.callback.toggleCodeView(cbinfo);

        data={
        struct('file',aFileName,'line',1)
        };

        input.title='';
        input.data=data;
        simulinkcoder.internal.util.highlightInCode(aMdlName,input);
    catch me %#ok

    end
end