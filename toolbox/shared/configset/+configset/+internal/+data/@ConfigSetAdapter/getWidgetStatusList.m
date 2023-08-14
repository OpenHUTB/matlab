function statusList=getWidgetStatusList(obj,name,varargin)



    if nargin<3
        pd=obj.getParamData(name);
    else
        pd=varargin{1};
    end
    if isempty(pd)
        statusList={configset.internal.data.ParamStatus.Normal};
        return;
    end

    pStatus=obj.getParamWidgetStatus(name,pd);

    if isempty(pd.WidgetList)
        statusList={pStatus};
    else


        wStatus=zeros(1,length(pd.WidgetList),'like',configset.internal.data.ParamStatus.Normal);
        for i=1:length(pd.WidgetList)
            w=pd.WidgetList{i};
            wStatus(i)=w.getStatus(obj.Source);
        end
        statusList=num2cell(max(pStatus,wStatus));
    end

