function onMouseEnter(obj,src,evt)


    if feature('openMLFBInSimulink')
        data=evt.data;
        m=slmle.internal.slmlemgr.getInstance;
        try
            m.highlightBySid(data.sids,obj.studio);
        catch
        end
    end

