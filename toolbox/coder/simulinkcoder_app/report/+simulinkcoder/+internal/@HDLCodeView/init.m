function init(obj)


    id=simulinkcoder.internal.CodeViewBase.incrementAndGetCid();

    obj.cid=sprintf('hcv%d',id);
    st=obj.studio;


    cr=simulinkcoder.internal.Report.getInstance;
    obj.codeListener=event.listener(cr,'CodeViewEvent',@obj.callback);

    if~isempty(st)

        editor=st.App.getActiveEditor;
        hId=editor.getHierarchyId;
        path=GLUE2.HierarchyService.getPaths(hId);
        obj.preSub=path{1};


        sn=simulinkcoder.internal.util.SelectedSidNotifier(st);
        obj.canvasListener=event.listener(sn,'SelectedSidsChanged',@obj.onSelect);


        c=st.getService('GLUE2:ActiveEditorChanged');
        obj.registerCallbackId=c.registerServiceCallback(@obj.handleEditorChanged);


        m=slmle.internal.slmlemgr.getInstance;
        obj.mlfbListener=event.listener(m,'EVENT',@obj.mlfbCallback);

    end