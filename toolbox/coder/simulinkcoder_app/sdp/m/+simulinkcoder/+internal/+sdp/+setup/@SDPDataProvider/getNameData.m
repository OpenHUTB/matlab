function[data,meta]=getNameData(obj,id,role)

    list=strsplit(id,'/');
    mdlName=list{end};

    data=mdom.Data;
    data.setProp('label',mdlName);
    icon=connector.getBaseUrl('toolbox/shared/dastudio/resources/SimulinkModelIcon.png');
    data.setProp('iconUri',icon);

    meta=mdom.MetaData;