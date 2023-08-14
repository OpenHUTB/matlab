


function init(obj,st)
    obj.fStudio=st;
    obj.fModelHandle=obj.fStudio.App.blockDiagramHandle;




    obj.cv_c=simulinkcoder.internal.CodeView_C(obj.fStudio);

    obj.fListeners{end+1}=event.listener(obj.cv_c,'CodeViewEvent',@obj.onCodeViewEventC);


    obj.cv_hdl=simulinkcoder.internal.CodeView_HDL(obj.fStudio);

    obj.fListeners{end+1}=event.listener(obj.cv_hdl,'CodeViewEvent',@obj.onCodeViewEventHDL);

end