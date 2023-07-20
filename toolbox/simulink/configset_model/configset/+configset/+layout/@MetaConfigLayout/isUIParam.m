









function out=isUIParam(obj,param,cs,varargin)
    includeButtons=false;
    if nargin<3
        error('MetaConfigLayout:ConfigsetRequired','configset.layout.MetaConfigLayout.isUIParam requires a configset object as a second parameter.');
    elseif nargin==3


        adp=configset.internal.getConfigSetAdapter(cs,true);
    else


        adp=varargin{1};
        if nargin>4
            includeButtons=varargin{2};
        end
    end

    if ischar(param)
        pData=adp.getParamData(param);
        if isempty(pData)
            out=false;
            return;
        end
    else
        pData=param;
    end


    if strcmp(pData.Component,'Simulink.STFCustomTargetCC')
        out=true;
        return;
    end

    pName=pData.FullName;
    status=adp.getParamWidgetStatus(pName,pData);
    if status==configset.internal.data.ParamStatus.UnAvailable
        out=false;
    elseif~isempty(obj.getWidgetGroup(pName))&&~obj.isAdvanced(pName)


        group=obj.getParamGroup(pName);
        comps=group.Components;
        allComps=adp.getComponentList();
        out=~isempty(intersect(comps,allComps));
    else
        out=false;
        for i=1:length(pData.WidgetList)
            name=pData.WidgetList{i}.FullName;
            if~isempty(obj.getWidgetGroup(name))&&~obj.isAdvanced(name)


                w=obj.getWidget(name,adp,cs);
                if includeButtons||~strcmp(w.WidgetType,'pushbutton')
                    out=true;
                    return;
                end
            end

        end
    end



