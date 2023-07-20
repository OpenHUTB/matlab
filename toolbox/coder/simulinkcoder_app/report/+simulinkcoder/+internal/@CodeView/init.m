function init(obj)


    id=simulinkcoder.internal.CodeViewBase.incrementAndGetCid();

    obj.cid=sprintf('cv%d',id);
    st=obj.studio;


    cr=simulinkcoder.internal.Report.getInstance;
    obj.codeListener{end+1}=event.listener(cr,'CodeViewEvent',@obj.callback);
    obj.codeListener{end+1}=event.listener(cr,'MouseEnter',@obj.onMouseEnter);
    obj.codeListener{end+1}=event.listener(cr,'MouseLeave',@obj.onMouseLeave);


    if~isempty(st)
        obj.preModel=st.App.blockDiagramHandle;


        sn=simulinkcoder.internal.util.SelectedSidNotifier(st);
        obj.canvasListener=event.listener(sn,'SelectedSidsChanged',@obj.onSelect);


        c=st.getService('GLUE2:ActiveEditorChanged');
        obj.registerCallbackId=c.registerServiceCallback(@obj.handleEditorChanged);


        m=slmle.internal.slmlemgr.getInstance;
        obj.mlfbListener=event.listener(m,'EVENT',@obj.mlfbCallback);

    end