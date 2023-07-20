function colInfo=getColumnInfo(obj,colList)
    colInfo=mdom.ColumnInfo(colList);


    col=0;
    meta=mdom.MetaData;
    meta.setProp('renderer','IconLabelRenderer');
    meta.setProp('label',message('ToolstripCoderApp:sdpsetuptool:Model').getString);
    widthMeta=mdom.MetaData;
    widthMeta.setProp('unit','%');
    widthMeta.setProp('value',30);
    meta.setProp('width',widthMeta);
    colInfo.fillMetaData(col,meta);


    col=col+1;
    meta=mdom.MetaData;
    meta.setProp('renderer','IconLabelRenderer');
    meta.setProp('label',message('ToolstripCoderApp:sdpsetuptool:Deployable').getString);
    widthMeta=mdom.MetaData;
    widthMeta.setProp('unit','%');
    widthMeta.setProp('value',10);
    meta.setProp('width',widthMeta);
    colInfo.fillMetaData(col,meta);

    if slfeature('FCPlatform')

        col=col+1;
        meta=mdom.MetaData;
        meta.setProp('renderer','IconLabelRenderer');
        meta.setProp('label',message('ToolstripCoderApp:sdpsetuptool:CoderDictionary').getString);
        widthMeta=mdom.MetaData;
        widthMeta.setProp('unit','%');
        widthMeta.setProp('value',20);
        meta.setProp('width',widthMeta);
        colInfo.fillMetaData(col,meta);


        col=col+1;
        meta=mdom.MetaData;
        meta.setProp('renderer','IconLabelRenderer');
        meta.setProp('label',message('ToolstripCoderApp:sdpsetuptool:CodeInterface').getString);
        widthMeta=mdom.MetaData;
        widthMeta.setProp('unit','%');
        widthMeta.setProp('value',20);
        meta.setProp('width',widthMeta);
        colInfo.fillMetaData(col,meta);
    end


    col=col+1;
    meta=mdom.MetaData;
    meta.setProp('renderer','IconLabelRenderer');
    meta.setProp('label',message('ToolstripCoderApp:sdpsetuptool:DeploymentType').getString);
    widthMeta=mdom.MetaData;
    widthMeta.setProp('unit','%');
    if slfeature('FCPlatform')
        widthMeta.setProp('value',20);
    else
        widthMeta.setProp('value',60);
    end
    meta.setProp('width',widthMeta);
    colInfo.fillMetaData(col,meta);
