function out=evalJS(obj,js)



    dlg=obj.dialog;
    imd=DAStudio.imDialog.getIMWidgets(dlg);
    wb_hdl=imd.find('tag','Tag_ConfigSet_Web_Widget');

    jsstr=sprintf('JSON.stringify(%s)',js);
    str=wb_hdl.evalJS(jsstr);
    if(isempty(str))
        out={};
    else
        out=jsondecode(str);
    end


