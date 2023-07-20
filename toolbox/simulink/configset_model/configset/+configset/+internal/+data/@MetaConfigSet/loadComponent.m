function[dm,loadNeeded]=loadComponent(obj,id,componentPath)





    if obj.ComponentMap.isKey(id)
        dm=obj.ComponentMap(id);
        loadNeeded=false;
    else
        if isempty(componentPath)

            mat=[fullfile(matlabroot,obj.DataPath,'CustomCC',id),'.mat'];
        else

            mat=[fullfile(matlabroot,componentPath,id),'.mat'];
        end
        loadNeeded=true;

        if exist(mat,'file')
            a=load(mat);
            dm=a.componentDataModel;
            obj.addComponent(dm);
        else
            dm=[];
        end
    end



