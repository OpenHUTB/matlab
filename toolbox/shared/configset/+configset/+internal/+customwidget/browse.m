function updateDeps=browse(cs,paramName,type,dialogPrompt)




    updateDeps=false;
    cs=cs.getConfigSet;

    mcs=configset.internal.getConfigSetStaticData;
    pName=mcs.WidgetNameMap(paramName);
    val=cs.getProp(pName);
    if nargin<4
        p=configset.getParameterInfo(cs,pName);
        action=p.getDescription;
    else
        action=dialogPrompt;
    end

    currFile='';
    if~isempty(val)
        currFile=which(val);
        if strncmp(currFile,'built-in',8)||strcmp(currFile,'variable')
            currFile='';
        end
    end

    [filename,pathname]=uigetfile(...
    type,...
    action,currFile);

    if~isequal(filename,0)&&~isequal(pathname,0)&&~strcmp(filename,val)
        configset.internal.util.setWidgetValue(cs.getDialogHandle,pName,filename);
        if slfeature('ConfigsetDDUX')==1
            dH=cs.getDialogHandle;
            if(isa(dH,'DAStudio.Dialog'))
                htmlView=dH.getDialogSource;
                data=struct;
                data.paramName=paramName;
                data.paramValue=filename;
                data.widgetType='browse';
                htmlView.publish('sendToDDUX',data);
            end
        end
    end
