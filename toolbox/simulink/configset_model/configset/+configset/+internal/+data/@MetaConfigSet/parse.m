function parse(obj)





    disp('parsing ConfigSet Data Model ...');

    obj.ComponentMap=containers.Map('KeyType','char','ValueType','any');
    obj.ComponentList={};
    obj.WidgetNameMap=containers.Map('KeyType','char','ValueType','char');

    xmlFolder=fullfile(matlabroot,obj.DataPath);

    base=obj.getBaseXmls;
    for i=1:length(base)
        xmlFile=fullfile(xmlFolder,base{i});
        cp=configset.internal.data.MetaConfigSet.parseComponentXml(xmlFile);
        cp.Type='Base';
        obj.addComponent(cp);
    end





    grtFile=fullfile(xmlFolder,'Target','grt.xml');
    grt=configset.internal.data.MetaConfigSet.parseComponentXml(grtFile);
    ertFile=fullfile(xmlFolder,'Target','ert.xml');
    ert=configset.internal.data.MetaConfigSet.parseComponentXml(ertFile);


    target=obj.getTargetXmls;
    for i=1:length(target)
        switch target{i}
        case 'grt.xml'
            cp=grt;
        case 'ert.xml'
            cp=ert;
        otherwise
            xmlFile=fullfile(xmlFolder,'Target',target{i});
            cp=configset.internal.data.MetaConfigSet.parseComponentXml(xmlFile,grt,ert);
        end
        cp.Type='Target';
        obj.addComponent(cp);
    end








    custom=obj.getCustomXmls;
    for i=1:length(custom)
        customCCFolder=fullfile(xmlFolder,'CustomCC');
        xmlFile=fullfile(customCCFolder,custom{i});
        configset.internal.data.MetaConfigSet.buildComponentXml(xmlFile,'Custom',customCCFolder);
    end
