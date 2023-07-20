function h=ProxyModelComp(mcosObj,uiParent)




    if nargin<2
        uiParent=[];
    end

    h=feval(mfilename('class'));

    h.uiParent=uiParent;

    h.coreObj=mcosObj;


    h.label=mcosObj.label;
    h.iconPath=mcosObj.iconPath;



    h.add_property_listeners(mcosObj,'label',false);
    h.add_property_listeners(mcosObj,'iconPath',false);

end

