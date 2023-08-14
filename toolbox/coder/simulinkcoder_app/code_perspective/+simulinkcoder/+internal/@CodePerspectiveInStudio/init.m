function init(obj)



    studio=obj.studio;
    obj.data=containers.Map;


    cp=simulinkcoder.internal.CodePerspective.getInstance;
    mdl=studio.App.blockDiagramHandle;
    [obj.app,~,obj.appLang]=cp.getInfo(mdl);


    editor=studio.App.getActiveEditor;
    obj.preModel=editor.blockDiagramHandle;


    c=studio.getService('GLUE2:ActiveEditorChanged');
    obj.registerCallbackId=c.registerServiceCallback(@obj.handleEditorChanged);


    obj.setupModelListeners();




