function info=ec_get_mp_data(modelName,fileName,typeList,codeTemplate)




    info=[];
    configSetHandle=getActiveConfigSet(modelName);

    if~exist(get_param(configSetHandle,'ERTSrcFileBannerTemplate'),'file')||...
        ~exist(get_param(configSetHandle,'ERTHdrFileBannerTemplate'),'file')||...
        ~exist(get_param(configSetHandle,'ERTDataSrcFileTemplate'),'file')||...
        ~exist(get_param(configSetHandle,'ERTDataHdrFileTemplate'),'file')
        info.state=0;

        return
    end

    baseSymbol{1}='Includes';
    baseSymbol{2}='Defines';
    baseSymbol{3}='IntrinsicTypes';
    baseSymbol{4}='PrimitiveTypedefs';
    baseSymbol{5}='UserTop';
    baseSymbol{6}='Typedefs';
    baseSymbol{7}='Enums';
    baseSymbol{8}='Definitions';
    baseSymbol{9}='ExternData';
    baseSymbol{10}='ExternFcns';
    baseSymbol{11}='FcnPrototypes';
    baseSymbol{12}='Declarations';
    baseSymbol{13}='Functions';
    baseSymbol{14}='CompilerErrors';
    baseSymbol{15}='CompilerWarnings';
    baseSymbol{16}='Documentation';
    baseSymbol{17}='UserBottom';










    try

        init_symbol_db;


        buffer=ec_global_doc_buffer(modelName);


        symbolTemplateDB=rtwprivate('rtwattic','AtticData','symbolTemplateDB');

        expandInfo.expandSymbol=[];
        expandInfo.expandNameList=[];
        symbolList=[];


        for i=1:length(symbolTemplateDB)
            symbolList{i}=symbolTemplateDB{i}.symbolName;
            if isempty(symbolTemplateDB{i}.symbolExpand)==0
                expandInfo.expandSymbol{end+1}=symbolTemplateDB{i};
                expandInfo.expandNameList{end+1}=symbolTemplateDB{i}.symbolName;
            end
        end
        expandInfo.symbolList=symbolList;
        expandInfo.symbolTemplateDB=symbolTemplateDB;






        templateInfo=[];
        tIndex=1;
        templateName=get_param(configSetHandle,'ERTSrcFileBannerTemplate');
        templateInfo{tIndex}=load_single_template(templateName);
        templateInfo{tIndex}.symreg=get_symbols(templateName,symbolList,baseSymbol);
        templateInfo{tIndex}.templateSpecificBuffer=setup_buffer(buffer,templateInfo{tIndex}.symbol.name);
        templateInfo{tIndex}.templateName=templateName;
        templateList{tIndex}=templateName;

        tIndex=tIndex+1;
        templateName=get_param(configSetHandle,'ERTHdrFileBannerTemplate');
        templateInfo{tIndex}=load_single_template(templateName);
        templateInfo{tIndex}.symreg=get_symbols(templateName,symbolList,baseSymbol);
        templateInfo{tIndex}.templateSpecificBuffer=setup_buffer(buffer,templateInfo{tIndex}.symbol.name);
        templateInfo{tIndex}.templateName=templateName;
        templateList{tIndex}=templateName;

        tIndex=tIndex+1;
        templateName=get_param(configSetHandle,'ERTDataSrcFileTemplate');
        templateInfo{tIndex}=load_single_template(templateName);
        templateInfo{tIndex}.symreg=get_symbols(templateName,symbolList,baseSymbol);
        templateInfo{tIndex}.templateSpecificBuffer=setup_buffer(buffer,templateInfo{tIndex}.symbol.name);
        templateInfo{tIndex}.templateName=templateName;
        templateList{tIndex}=templateName;

        tIndex=tIndex+1;
        templateName=get_param(configSetHandle,'ERTDataHdrFileTemplate');
        templateInfo{tIndex}=load_single_template(templateName);
        templateInfo{tIndex}.symreg=get_symbols(templateName,symbolList,baseSymbol);
        templateInfo{tIndex}.templateSpecificBuffer=setup_buffer(buffer,templateInfo{tIndex}.symbol.name);
        templateInfo{tIndex}.templateName=templateName;
        templateList{tIndex}=templateName;


        customTemplates=get_custom_templates(modelName);










        if isempty(customTemplates)==0
            for i=1:length(customTemplates)
                templateName=customTemplates{i}.templateName;
                if exist(templateName,'file')
                    tIndex=tIndex+1;
                    templateInfo{tIndex}=load_single_template(templateName);
                    templateInfo{tIndex}.symreg=get_symbols(templateName,symbolList,baseSymbol);
                    templateInfo{tIndex}.templateSpecificBuffer=setup_buffer(buffer,templateInfo{tIndex}.symbol.name);
                    templateInfo{tIndex}.templateName=templateName;
                    templateList{tIndex}=templateName;
                end
            end
        end
        index=0;
        [len,wid]=size(fileName);

        fIndex=1;
        templateOverwrite=get_template_overwrites(modelName);
        for j=1:len
            fileNameList{j}=deblank(fileName(j,1:end));
            fileTypeList{j}=deblank(typeList(j,1:end));
            fileTemplateList{j}=deblank(codeTemplate(j,1:end));
            for k=1:length(templateOverwrite)
                if strcmp(fileNameList{j},templateOverwrite{k}.fileName)&&...
                    strcmp(fileTypeList{j},templateOverwrite{k}.fileType)
                    fileTemplateList{j}=templateOverwrite{k}.template;
                end
            end
        end


        filesToGenerate=ec_get_extra_files_to_gen(modelName,...
        fileNameList,fileTemplateList,fileTypeList,configSetHandle);

        fileNameList=filesToGenerate.fileNameList;
        fileTemplateList=filesToGenerate.fileTemplateList;
        fileTypeList=filesToGenerate.fileTypeList;
        fileBuffer=filesToGenerate.sym;
        for i=1:length(fileNameList)
            [templateName,fileType]=strtok(fileTemplateList{i},'.');
            if isempty(fileType)==0
                invalidTemplate=1;
                nullC=0;
                findNull=find(fileType==nullC);
                if isempty(findNull)==0
                    fileType=fileType(1:findNull-1);
                end

                switch(fileType)
                case '.cgt'
                    templateFileName=[templateName,fileType];
                    invalidTemplate=0;
                case '.tlc'


                    if length(templateName)>4
                        if strcmp(templateName(end-3:end),'_cgt')
                            templateFileName=[templateName(1:end-4),'.cgt'];
                            invalidTemplate=0;
                        end
                    end
                otherwise
                end
                if invalidTemplate==0
                    tIndex=find(strcmp(templateFileName,templateList));
                    if isempty(tIndex)==0
                        tIndex=tIndex(1);
                        name=fileNameList{i};
                        type=fileTypeList{i};
                        info.fileBuf{fIndex}.templateFileName=templateFileName;
                        info.fileBuf{fIndex}.fileName=name;
                        info.fileBuf{fIndex}.fileType=type;
                        info.fileBuf{fIndex}.buffer=templateInfo{tIndex}.templateSpecificBuffer;
                        info.fileBuf{fIndex}.symreg=templateInfo{tIndex}.symreg;
                        [extraBuffer,extraSymReg]=symbol_expansion(modelName,name,expandInfo,templateInfo{tIndex});
                        info.fileBuf{fIndex}.buffer=[info.fileBuf{fIndex}.buffer,extraBuffer];
                        info.fileBuf{fIndex}.symreg=[info.fileBuf{fIndex}.symreg,extraSymReg];
                        if isempty(fileBuffer{i}.buffer{1}.bufferName)==0
                            info.fileBuf{fIndex}.buffer=[info.fileBuf{fIndex}.buffer,fileBuffer{i}.buffer];
                        end
                        fIndex=fIndex+1;
                    end
                end
            end
        end

        if isempty(info)==1
            info.state=0;
        else
            info.state=1;
        end
    catch merr
        info.state=0;
        MSLDiagnostic('RTW:mpt:GetMPdataErr',merr.message).reportAsWarning;
    end
    return

    function templateSpecificList=get_symbols(templateName,symbolList,baseSymbol)

        symbolTemplateDB=rtwprivate('rtwattic','AtticData','symbolTemplateDB');
        info=load_single_template(templateName);





        templateSpecificList=[];
        for i=1:length(info.symbol.name)


            if isempty(find(strcmp(info.symbol.name{i},baseSymbol)))==1
                index=find(strcmp(info.symbol.name{i},symbolList));
                if isempty(index)==0
                    templateSpecificList{end+1}=symbolTemplateDB{index};
                end
            end
        end

        function templateSpecificBuffer=setup_buffer(buffer,templateSpecificList)





            templateSpecificBuffer=[];
            foundList(length(templateSpecificList))=0;
            for i=1:length(buffer)
                index=find(strcmp(buffer{i}.bufferName,templateSpecificList));
                if isempty(index)==0
                    if foundList(index)==1
                        buffer{i}.bufferContent=[sprintf('\n'),buffer{i}.bufferContent];
                    else
                        foundList(index)=1;
                    end
                    encoding=get_param(0,'CharacterEncoding');
                    buffer{i}.bufferContent=...
                    native2unicode(...
                    slsvInternal('slsvEscapeServices',...
                    'unicode2native',...
                    buffer{i}.bufferContent,...
                    encoding),encoding);
                    templateSpecificBuffer{end+1}=buffer{i};
                end
            end
            function customTemplates=get_custom_templates(modelName)

                customTemplates=rtwprivate('rtwattic','AtticData','mptCustomTemplates');

                function templateOverwrite=get_template_overwrites(modelName)

                    templateOverwrite=rtwprivate('rtwattic','AtticData','mptTemplateOverwrite');

                    function[extraBuffer,extraSymReg]=symbol_expansion(modelName,fileName,expandInfo,templateInfo)
                        extraBuffer=[];
                        extraSymReg=[];
                        totalSym=expandInfo.symbolList;
                        templateSymName=templateInfo.symbol.name;
                        expandSymName=expandInfo.expandNameList;
                        [aa,bb]=intersect(templateSymName,expandSymName);
                        if isempty(aa)==0
                            for i=1:length(aa)
                                try
                                    index=find(strcmp(aa{i},totalSym));
                                    if isempty(index)==0
                                        expand=expandInfo.symbolTemplateDB{index}.symbolExpand;
                                        if exist([expand,'.m'],'file')
                                            data.fileName=fileName;
                                            data.modelName=modelName;
                                            data.symbolName=aa{i};
                                            result=eval([expand,'(data)']);
                                        end
                                    end
                                catch
                                    result='';
                                end
                                extraSymReg{i}=expandInfo.symbolTemplateDB{index};
                                extraBuffer{i}.bufferName=aa{i};
                                extraBuffer{i}.bufferContent=result;
                                extraBuffer{i}.customFlag=1;
                            end
                        end








                        function filesToGenerate=ec_get_extra_files_to_gen(modelName,...
                            fileNameList,fileTemplateList,fileTypeList,configSetHandle)
                            cr=sprintf('\n');


                            filesToGenerate.fileNameList=fileNameList;
                            filesToGenerate.fileTemplateList=fileTemplateList;
                            filesToGenerate.fileTypeList=fileTypeList;
                            filesToGenerate.buffer=[];

                            bufferEmpty.bufferName=[];
                            bufferEmpty.bufferContent=[];
                            bufferEmpty.customFlag=[];
                            for i=1:length(fileNameList)
                                filesToGenerate.sym{i}.buffer{1}=bufferEmpty;
                            end
                            info.modelName=modelName;
                            info.filesToGenerate=filesToGenerate;
                            info.bufferEmpty=bufferEmpty;
                            info.configSetHandle=configSetHandle;



