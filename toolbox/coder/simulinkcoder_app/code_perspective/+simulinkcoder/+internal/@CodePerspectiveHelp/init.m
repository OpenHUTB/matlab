function init(obj)



    path='/toolbox/coder/simulinkcoder_app/code_perspective/ui/';
    obj.Url=[path,'index.html'];
    obj.debugUrl=[path,'index-debug.html'];


    obj.subscribe=message.subscribe(['/',obj.channel],@obj.callback);


    overlay=simulinkcoder.internal.CodePerspectiveOverlay;
    addlistener(overlay,'DialogClosed',@obj.onOverlayClosed);
    obj.overlay=overlay;