function hit=hitLegendWithDefaultButtonDownFcn(evd)



    hit=~isempty(evd)&&...
    isprop(evd,'HitObject')&&...
    ~isempty(evd.HitObject)&&...
    ishghandle(evd.HitObject,'Legend')&&...
    strcmp(evd.HitObject.ButtonDownFcnMode,'auto');
