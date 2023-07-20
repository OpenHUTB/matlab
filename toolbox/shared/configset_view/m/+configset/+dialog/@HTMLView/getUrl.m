function url=getUrl(obj)




    csh=DAStudio.CSHManager;
    cm=sl_customization_manager;
    adminMode=csh.adminMode||cm.showWidgetIdAsToolTip;
    channel=configset.dialog.Connector.channel;
    query=sprintf('?channel=%s&id=%s&style=%d&adminMode=%d',channel,obj.ID,1,adminMode);


    query=[query,sprintf('&keyboard=%d',slf_feature('get','ConfigSetKeyboard'))];

    cs=obj.Source.getConfigSetRoot;
    if isa(cs,'Simulink.ConfigSetRef')
        csref=sprintf('&csref=%d',slf_feature('get','ConfigSetRefOverride'));
        query=[query,csref];
    end


    inBat=configset.internal.util.isInBat();
    query=[query,sprintf('&inBat=%d',inBat)];



    query=[query,'&ts=',obj.ts];


    path='toolbox/shared/configset_view/web';

    if obj.debugMode
        file='index-debug.html';
    else
        file='index.html';
    end

    url=connector.getUrl(sprintf('/%s/%s%s',path,file,query));

    if slf_feature('get','ConfigSetToolstrip')==1
        url=[url,'&ConfigSetToolstrip=1'];
    end


    if slf_feature('get','ConfigSetDDUX')==1
        url=[url,'&ConfigSetDDUX=1'];
    end


