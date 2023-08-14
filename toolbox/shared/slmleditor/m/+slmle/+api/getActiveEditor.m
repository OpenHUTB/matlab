function editor=getActiveEditor(studio)



    editor=[];

    if nargin==0
        sts=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        if isempty(sts)
            return;
        end
        studio=sts(1);
    end
    ed=studio.App.getActiveEditor;

    m=slmle.internal.slmlemgr.getInstance;
    arr=m.MLFBEditorMap.values;
    for i=1:length(arr)
        brr=arr{i};
        for j=1:length(brr)
            e=brr{j};
            if e.studio==studio&&e.ed==ed
                editor=e;
                return;
            end
        end
    end


