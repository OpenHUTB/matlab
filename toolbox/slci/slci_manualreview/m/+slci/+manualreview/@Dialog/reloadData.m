


function reloadData(obj)

    if~isempty(obj.getCurrentFile)
        [source_file,file]=obj.getManualReviewFile();


        [msgData,obj.fCurrentData]=readData(file);
        obj.fData(source_file)=obj.fCurrentData;

        if~isempty(obj.fCurrentData)

            obj.updateCodeViewAnnotation(obj.getCodeLanguage,obj.fCurrentData);
        end


        obj.sendData('reloadData',msgData);
    else

        obj.sendData('reloadData',{});
    end

end


function[msgData,fData]=readData(file)

    msgData={};
    fData=containers.Map('KeyType','char','ValueType','any');
    if exist(file,'file')
        try

            text=fileread(file);

            data=jsondecode(text);
        catch
            data=[];
        end

        if~isempty(data)&&isstruct(data)

            fnames=fieldnames(data);

            for i=1:numel(fnames)
                fData(fnames{i})=data.(fnames{i});
                msgData{i}=data.(fnames{i});%#ok
            end
        end
    end
end