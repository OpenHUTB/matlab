function hout=copy(h,varargin)








    hout=Simulink.TsArray;
    utdeepcopy(h,hout);

    if~isempty(hout.Members)
        for k=1:length(hout.Members)
            name=hout.Members(k).name;
            ts=h.(name).copy;
            p=schema.prop(hout,name,'handle');
            set(hout,name,ts);
        end
    end

    if nargin>1
        hout.Name=varargin{1};
    end
