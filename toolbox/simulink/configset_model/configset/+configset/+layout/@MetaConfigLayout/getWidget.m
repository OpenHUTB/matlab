function[wObject,index]=getWidget(obj,name,adp,cs,varargin)





    wObject=[];
    [group,index]=obj.getWidgetGroup(name,false);
    if length(group)>1


        group=[];
        pdata=adp.getParamData(name,obj.MetaCS,cs,false);
        if~isempty(pdata)


            [group,index]=obj.getWidgetGroup(pdata.FullName,true);


            if~isempty(group)&&nargin>=5
                groupName=varargin{1};
                if~isempty(groupName)&&~strcmp(groupName,group.Name)
                    return;
                end
            end
        end
        if isempty(group)
            return;
        end
    end

    wObject=group.Children{index};
    if ischar(wObject)
        wObject=obj.MetaCS.findWidget(wObject,adp,cs);
        if isempty(wObject)
            return;
        end
    else




        if~cs.isConfigSetParam(wObject.getParamName)&&~strcmp(wObject.Component,'HDL Coder')
            wObject=[];
        end
    end

