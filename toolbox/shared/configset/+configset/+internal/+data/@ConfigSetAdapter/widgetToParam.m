function pName=widgetToParam(obj,wName,varargin)



    tlc=obj.tlcInfo;
    if~isempty(tlc)
        if tlc.isKey(wName)
            pName=wName;
            return;
        end
    end


    if nargin==2
        mcs=configset.internal.getConfigSetStaticData;
    else
        mcs=varargin{1};
    end

    pName=mcs.WidgetNameMap(wName);




