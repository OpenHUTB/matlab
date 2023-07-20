function status=getParamWidgetStatus(obj,name,varargin)












    if nargin<3
        pd=obj.getParamData(name);
    else
        pd=varargin{1};
    end

    cs=obj.getCS;

    if isempty(pd)
        if cs.isValidParam(name)
            status=0;
        else
            status=3;
        end
    else

        st(1)=0;

        isHDL=strcmp(pd.Component,'HDL Coder');
        if~isHDL&&~pd.DependencyOverride
            mcs=configset.internal.getConfigSetStaticData;
            mcc=mcs.getComponent(pd.Component);
            if~isempty(mcc)&&~isempty(mcc.Dependency)
                st(1)=mcc.Dependency.getStatus(cs,'');
            end
        end

        if st(1)==3
            status=st(1);
            return;
        end

        st(2)=pd.getStatus(cs);

        if isa(pd,'configset.internal.data.WidgetStaticData')
            st(3)=pd.Parameter.getStatus(cs);
        end

        status=max(st);
    end





