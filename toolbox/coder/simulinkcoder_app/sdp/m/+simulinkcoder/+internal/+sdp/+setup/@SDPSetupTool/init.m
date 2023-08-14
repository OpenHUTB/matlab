function init(obj)

    app=mdom.App;


    app.beginTransaction();

    obj.dataProvider=simulinkcoder.internal.sdp.setup.SDPDataProvider(obj.topModel);
    obj.dataModel=mdom.DataModel(obj.dataProvider);



















    w=[];
    w.tag='Title';
    w.text=message('ToolstripCoderApp:sdpsetuptool:Header').getString;
    title=app.createWidget('mdom.Text',w);

    w=[];
    w.tag='SDPTT';
    w.dataModel=obj.dataModel.getID;
    w.selectionMode=mdom.SelectionMode.None;
    tt=app.createWidget('mdom.TreeTable',w);
    obj.tt=tt;



































    w=[];
    w.tag='SDPMain';
    w.title=message('ToolstripCoderApp:sdpsetuptool:DialogTitle').getString;
    w.mode=mdom.WindowMode.Embedded;
    main=app.createWidget('mdom.Dialog',w);
    main.layout=app.createWidget('mdom.BoxLayout',struct('direction',mdom.Direction.Vertical));

    main.layout.addItem(title,1,0);
    main.layout.addItem(tt,2,1);


    app.endTransaction();
    app.start();

    if slfeature('FCPlatform')
        obj.dataModel.columnChanged(5,{});
    else
        obj.dataModel.columnChanged(3,{});
    end
    obj.dataModel.rowChanged('',1,{});

    obj.app=app;



