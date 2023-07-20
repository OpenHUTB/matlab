function y=getPropSet(this,varargin)









    if nargin<2

        y=this.prop_set_names;
    else
        y=this;
        for indx=1:length(varargin)
            name=varargin{indx};
            idx=y.getPropSetIdx(name);
            if isempty(idx)
                if~ischar(name),name='';end
                error(message('HDLShared:propset:faildFindProp',name));
            end
            y=y.prop_sets{idx};
        end
    end


