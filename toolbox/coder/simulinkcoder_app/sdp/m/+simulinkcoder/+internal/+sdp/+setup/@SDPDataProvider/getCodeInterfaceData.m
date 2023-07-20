function[data,meta]=getCodeInterfaceData(obj,id,role)

    df=message('ToolstripCoderApp:sdpsetuptool:DataFunctions').getString;
    dfIcon=connector.getBaseUrl('toolbox/coder/simulinkcoder_app/toolstrip/icons/Coder_Dictionary_Data_and_Functions_16.png');

    ss=message('ToolstripCoderApp:sdpsetuptool:Services').getString;
    ssIcon=connector.getBaseUrl('toolbox/coder/simulinkcoder_app/toolstrip/icons/Coder_Dictionary_Services_16.png');

    ci=df;
    icon=dfIcon;

    data=mdom.Data;
    if role>0
        dict=obj.dataModel.getCoderDictionary(id);
        type=simulinkcoder.internal.sdp.util.getCodeInterfaceType(dict);
        if type==2
            ci=ss;
            icon=ssIcon;
        end
        data.setProp('label',ci);
        data.setProp('iconUri',icon);
    end

    meta=mdom.MetaData;


