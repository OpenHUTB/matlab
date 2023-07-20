function onMouseLeave(obj,src,evt)


    if feature('openMLFBInSimulink')
        m=slmle.internal.slmlemgr.getInstance;
        arr=m.MLFBEditorMap.values;
        for i=1:length(arr)
            brr=arr{i};
            for j=1:length(brr)
                ed=brr{j};
                ed.clearHighlight();
            end
        end
    end
