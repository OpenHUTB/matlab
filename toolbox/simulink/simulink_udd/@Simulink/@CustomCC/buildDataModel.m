function buildDataModel(obj)





    id=class(obj);
    path=fileparts(which(id));
    xml=fullfile(path,'params.xml');

    if exist(xml,'file')
        c=configset.internal.data.Component;
        c.parse(xml);
        c.setup;
        mat=fullfile(path,'params.mat');
        save(mat,'c');
    end
