

function out=getAllStudio(input)
    out=[];
    src=slci.view.internal.getSource(input);
    modelH=src.modelH;
    st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    for i=1:length(st)
        s=st(i);
        h=bdroot(s.App.blockDiagramHandle);

        if h==modelH
            out=[out,s];%#ok
        end
    end
end
