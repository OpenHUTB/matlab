function wm=getActiveWebMapCanvas(name)











    if nargin==0
        wm=findHandleFromAppdata;
    else
        name=lower(char(name));
        name(isspace(name))=[];
        wm=getHandleFromAppdata(name);
    end
end


function wm=getHandleFromAppdata(name)


    if isappdata(0,'webmap')
        appdata=getappdata(0,'webmap');
        if~isempty(appdata)&&isvalid(appdata)&&isKey(appdata,name)
            wm=appdata(name);
            if~isvalid(wm)
                wm=[];
            end
        else
            wm=[];
        end
    else
        wm=[];
    end
end


function wm=findHandleFromAppdata


    wm=[];

    if isappdata(0,'webmap_active_browser_name')
        name=getappdata(0,'webmap_active_browser_name');
        wm=getHandleFromAppdata(name);
    end

    if isappdata(0,'webmap')&&isempty(wm)


        appdata=getappdata(0,'webmap');
        if~isempty(appdata)&&isvalid(appdata)
            values=appdata.values;
            wm=values{end};
            if~isvalid(wm)
                wm=[];
            end
        else
            wm=[];
        end
    end
end
