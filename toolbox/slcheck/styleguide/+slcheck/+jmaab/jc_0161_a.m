classdef jc_0161_a<slcheck.subcheck

    methods
        function obj=jc_0161_a()
            obj.CompileMode='none';
            obj.Licenses={''};
            obj.ID='jc_0161_a';
        end

        function result=run(this)
            result=false;
            dataStoreMemory=this.getEntity();
            hObj=get_param(dataStoreMemory,'Object');
            hObj=hObj.DSReadWriteBlocks;
            readerWriterBlock=get_param({hObj.name},'Parent');
            passFlag=false;
            readerWriterBlockTemp=readerWriterBlock;

            [dataStoreMemoryPath,~]=fileparts(dataStoreMemory);

            if~isempty(readerWriterBlock)


                for readIdx=1:length(readerWriterBlock)






                    readerWriterBlock{readIdx}=strrep(readerWriterBlock{readIdx},dataStoreMemoryPath,'');





                    if~isempty(readerWriterBlock{readIdx})
                        idx=regexp(readerWriterBlock{readIdx}(2:end),'/','once');
                        if isempty(idx)
                            readerWriterBlockTemp{readIdx}=readerWriterBlock{readIdx}(1:end);
                        else
                            readerWriterBlockTemp{readIdx}=readerWriterBlock{readIdx}(1:idx);
                        end
                    else


                        passFlag=true;
                    end
                end




                if 1==length(unique(readerWriterBlockTemp))&&~passFlag


                    commonPath=getCommonPath(readerWriterBlock);
                    commonPath=[dataStoreMemoryPath,'/',strjoin(commonPath,'/')];

                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'Custom',...
                    DAStudio.message('ModelAdvisor:jmaab:jc_0161_BlockName'),...
                    Simulink.ID.getSID(dataStoreMemory),...
                    DAStudio.message('ModelAdvisor:jmaab:jc_0161_CurrentLoc'),...
                    dataStoreMemoryPath,...
                    DAStudio.message('ModelAdvisor:jmaab:jc_0161_ExpectedLoc'),...
                    commonPath);

                    result=this.setResult(vObj);
                end
            end
        end
    end
end



function commonPath=getCommonPath(file)
    tempFile=file;
    len=[];
    commonPath=[];







    for iFile=1:length(file)
        tempFile{iFile}=strsplit(file{iFile}(2:end),'/');
        len=[len,length(tempFile{iFile})];
    end




    for idx2=1:min(len)
        toCompare=[];
        for idx=1:length(tempFile)
            toCompare=[toCompare,tempFile{idx}(idx2)];
        end
        if 1==length(unique(toCompare))
            commonPath=[commonPath,tempFile{idx}(idx2)];
        else
            return
        end
    end
end




