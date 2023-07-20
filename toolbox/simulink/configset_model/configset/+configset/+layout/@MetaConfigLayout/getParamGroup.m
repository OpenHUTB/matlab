function out=getParamGroup(obj,name,varargin)
    p=obj.getParam(name);
    if iscell(p)
        p=p{1};
    end
    if isempty(p.WidgetList)
        names={p.FullName};
    else
        names=cellfun(@(x)x.FullName,p.WidgetList,'UniformOutput',false);
        names{end+1}=p.FullName;
    end

    if nargin==3&&strcmp(p.Component,'Target')
        cs=varargin{1};
        try
            stf=strtok(cs.get_param('SystemTargetFile'),'.');
            namesSTF=strrep(names,'Target:',[stf,':']);
            ind=find(cellfun(@(x)obj.WidgetGroupMap.isKey(x),namesSTF),1);
        catch
            ind=[];
        end
    else
        ind=[];
    end

    if isempty(ind)
        ind=find(cellfun(@(x)~isempty(obj.getWidgetGroup(x)),names),1);
    else
        names=namesSTF;
    end

    if isempty(ind)
        out=[];
    else
        out=obj.getWidgetGroup(names{ind},false);
    end

