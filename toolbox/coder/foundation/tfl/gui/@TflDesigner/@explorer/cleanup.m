function cleanup(h,e)%#ok





    h.hide;
    clear global loadedTbl;
    rt=h.getRoot;
    rt.unpopulate;
    if~isempty(rt.uiclipboard)&&ishandle(rt.uiclipboard)
        rt.uiclipboard.clear;
        delete(rt.uiclipboard);
    end;
    delete(rt);

    delete(h.imme);
    delete(h);
    munlock crtool;

