function data=getCodeData(obj,reportPath,modelName,isRef)




    data=[];


    [data.current,data.files,traceStyle,error]=simulinkcoder.internal.HDLCodeView.getGeneratedHDLFiles(reportPath,modelName,isRef);
    if~isempty(error)
        if~isempty(error.generatedBlks)
            data.xil=error.generatedBlks;
        end
        data.message=error.message;
        return;
    end


    obj.traceStyleForLastBuild=traceStyle;



    [fileFolder,~]=fileparts(reportPath);

    if~isfolder(fileFolder)
        sprintf('Error: The following folder does not exist:\n%s',fileFolder);
        return;
    end

    if isRef
        traceFileName=fullfile(fileFolder,modelName,'html',modelName,'traceInfo.mat');
    else
        traceFileName=fullfile(fileFolder,'html',modelName,'traceInfo.mat');
    end


    if~isfile(traceFileName)
        data.blocks=[];
        return;
    end


    load(traceFileName,'infoStruct');
    ti=infoStruct.traceInfo;


    blockinfo=cell(1,length(ti));
    j=1;

    for i=1:length(ti)
        blk=ti(i).rtwname;
        sid=ti(i).sid;

        if~isempty(blk)&&~isempty(sid)
            item.blk=blk;
            item.sid=sid;

            if strcmpi(traceStyle,'Line Level')
                item.loc=ti(i).location;
            else
                item.loc={};
            end
            blockinfo{j}=item;
            j=j+1;
        end
    end


    blockinfo=blockinfo(~cellfun(@isempty,blockinfo));

    data.blocks=blockinfo;
    data.traceStyle=traceStyle;



