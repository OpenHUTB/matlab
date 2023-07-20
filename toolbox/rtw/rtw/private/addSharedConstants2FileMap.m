function retVal=addSharedConstants2FileMap(model,sharedutils,objInfos,flushCache)













    if~iscell(objInfos)
        objInfos={objInfos};
    end

    persistent objInfoArray;
    persistent initStrSize;



    persistent pendingNames;

    fileName=fullfile(sharedutils,'filemap.mat');
    if exist(fileName,'file')==2



        load(fileName,'fileMap');
    else

        fileMap=containers.Map('KeyType','char','ValueType','any');
    end


    existingNames={};
    if~isempty(fileMap)
        existingNames=fileMap.keys;

    end

    if(isempty(initStrSize))
        initStrSize=0;
    end

    if isempty(pendingNames)
        if~isempty(objInfoArray)
            pendingNames={objInfoArray(:).name};
        else
            pendingNames={};
        end
    end

    if~isempty(objInfos{1})
        newEntries=cellfun(@(x){x.name},objInfos);
    else
        newEntries={};
    end


    [~,idx]=setdiff(newEntries,existingNames);
    newEntries=newEntries(idx);
    objInfos=objInfos(idx);


    [~,idx]=setdiff(newEntries,pendingNames);
    newEntries=newEntries(idx);
    objInfos=objInfos(idx);


    if~isempty(newEntries)
        pendingNames=[pendingNames,newEntries];
        retVal.hasNewConstants=true;
    else
        retVal.hasNewConstants=false;
    end

    if~isempty(objInfoArray)
        initStrSizeArray=cellfun(@(x)length(x.InitStr),objInfos);
    else
        initStrSizeArray=0;
    end



    if~flushCache
        initStrSize=initStrSize+sum(initStrSizeArray);
        if~isempty(objInfos)
            objInfoArray=[objInfoArray,objInfos];
        end
    end

    cacheSize=get_param(model,'SharedConstantsCachingThreshold')*1024;
    retVal.success=true;
    retVal.badName='';



    if(initStrSize>cacheSize||(flushCache&&~isempty(objInfoArray)))

        if~isempty(fileMap)
            existingNames=fileMap.keys;
        else
            existingNames={};

        end


        [~,idx]=setdiff(pendingNames,existingNames);
        objInfoArray=objInfoArray(idx);


        for i=1:length(objInfoArray)
            objInfoArray{i}.doUpdate=false;
            fileMap(objInfoArray{i}.name)=objInfoArray{i};
        end

        objInfoArray=[];
        pendingNames={};

        save(fileName,'fileMap');




        if(~slfeature('SharedTypesInIR'))
            add2FileMap(model,sharedutils,[],5,false);
        else
            masterDmrFile=[sharedutils,filesep,'shared_file.dmr'];
            add2FileMapSharedDataAndConstants(model,sharedutils,[],5,false,masterDmrFile);
        end

        initStrSize=0;
    end
end


