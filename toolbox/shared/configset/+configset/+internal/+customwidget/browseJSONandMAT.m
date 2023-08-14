function updateDeps=browseJSONandMAT(cs,msg)


    updateDeps=false;
    type={'*.json; *.mat','JSON-files (*.json) and MAT-files (*.mat)';};
    browse(cs,msg.name,type);



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
            newVal=[pathname,filename];
            try
                cs.set_param(pName,newVal);
            catch ME
                throw(configset.internal.util.MSLValueException(newVal,ME.identifier,ME.message));
            end
            dlg=cs.getDialogHandle;
            if~isempty(dlg)
                w=dlg.getDialogSource;
                w.enableApplyButton(true);
            end
        end
