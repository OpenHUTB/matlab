function updateCallback(obj,~)




    if~isempty(obj.params)
        params=obj.params;
        obj.params={};

        n=length(params);
        data=cell(1,n);
        for i=1:n
            name=params{i};
            try
                data{i}=obj.getData(name);
                obj.removeError(name,[]);
            catch
            end
        end

        obj.publish('update',data);
    end

