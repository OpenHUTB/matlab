function jsonCell=convertClientJsonToServerJson(jsonStruct)




    jsonCell=cell(1,length(jsonStruct));


    for k=1:length(jsonStruct)





        if iscell(jsonStruct)
            itemStruct.Name=jsonStruct{k}.name;
            itemStruct.ParentName=jsonStruct{k}.ParentName;
            itemStruct.ParentID=jsonStruct{k}.ParentID;
            itemStruct.DataSource=jsonStruct{k}.DataSource;

            if isfield(jsonStruct{k},'FullDataSource')
                itemStruct.FullDataSource=jsonStruct{k}.FullDataSource;
            end

            itemStruct.Icon=jsonStruct{k}.IconFile;
            itemStruct.Type=jsonStruct{k}.Type;

            if isfield(jsonStruct{k},'isEnum')
                itemStruct.isEnum=jsonStruct{k}.isEnum;
            else
                itemStruct.isEnum=false;
            end

            if isfield(jsonStruct{k},'isString')
                itemStruct.isString=jsonStruct{k}.isString;
            else
                itemStruct.isString=false;
            end

            if isfield(jsonStruct{k},'MinTime')
                itemStruct.MinTime=jsonStruct{k}.MinTime;
            end
            if isfield(jsonStruct{k},'MaxTime')
                itemStruct.MaxTime=jsonStruct{k}.MaxTime;
            end
            if isfield(jsonStruct{k},'MinData')
                itemStruct.MinData=jsonStruct{k}.MinData;
            end
            if isfield(jsonStruct{k},'MaxData')
                itemStruct.MaxData=jsonStruct{k}.MaxData;
            end

            if isfield(jsonStruct{k},'Units')
                itemStruct.Units=jsonStruct{k}.Units;
            end

            if isfield(jsonStruct{k},'Interpolation')
                itemStruct.Interpolation=jsonStruct{k}.Interpolation;
            end

            if isfield(jsonStruct{k},'BlockPath')
                itemStruct.BlockPath=jsonStruct{k}.BlockPath;
            end

            itemStruct.TreeOrder=jsonStruct{k}.TreeOrder;
            itemStruct.ID=jsonStruct{k}.id;
        else

            itemStruct.Name=jsonStruct(k).name;
            itemStruct.ParentName=jsonStruct(k).ParentName;
            itemStruct.ParentID=jsonStruct(k).ParentID;
            itemStruct.DataSource=jsonStruct(k).DataSource;

            if isfield(jsonStruct(k),'FullDataSource')
                itemStruct.FullDataSource=jsonStruct(k).FullDataSource;
            else
                itemStruct.FullDataSource=which(jsonStruct(k).DataSource);
            end

            itemStruct.Icon=jsonStruct(k).IconFile;
            itemStruct.Type=jsonStruct(k).Type;

            if isfield(jsonStruct(k),'isEnum')
                itemStruct.isEnum=jsonStruct(k).isEnum;
            else
                itemStruct.isEnum=false;
            end

            if isfield(jsonStruct(k),'MinTime')
                itemStruct.MinTime=jsonStruct(k).MinTime;
            end

            if isfield(jsonStruct(k),'MaxTime')
                itemStruct.MaxTime=jsonStruct(k).MaxTime;
            end
            if isfield(jsonStruct(k),'MinData')
                itemStruct.MinData=jsonStruct(k).MinData;
            end
            if isfield(jsonStruct(k),'MaxData')
                itemStruct.MaxData=jsonStruct(k).MaxData;
            end

            if isfield(jsonStruct(k),'Units')
                itemStruct.Units=jsonStruct(k).Units;
            end

            if isfield(jsonStruct(k),'Interpolation')
                itemStruct.Interpolation=jsonStruct(k).Interpolation;
            end

            if isfield(jsonStruct(k),'BlockPath')
                itemStruct.BlockPath=jsonStruct(k).BlockPath;
            end

            itemStruct.TreeOrder=jsonStruct(k).TreeOrder;
            itemStruct.ID=jsonStruct(k).id;
        end

        jsonCell{k}=itemStruct;
    end
