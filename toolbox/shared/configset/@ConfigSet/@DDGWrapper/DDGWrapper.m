function h=DDGWrapper(dlg,varargin)



    h=ConfigSet.DDGWrapper;
    h.dialog=dlg;

    if nargin>=2
        msg=varargin{1};

        fs=intersect(fields(h),fields(msg));
        for i=1:length(fs)
            f=fs{i};
            h.(f)=msg.(f);
        end
    end


    h.customized.disabled={};
    h.customized.hidden={};
