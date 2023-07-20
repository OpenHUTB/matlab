





classdef TargetObject<handle
    properties
cgModelObject
slcgFileRepository
cgtObject
simulinkTokenRepository
        buildDir;
    end

    properties(Hidden=true)
        isModelObjectAvailable;
    end

    methods
        function obj=TargetObject(buildDir)


            obj.buildDir=buildDir;
            obj.cgtObject=coder.SimulinkCoderTemplate(get_param(bdroot,'ERTSrcFileBannerTemplate'));
        end

        function setModelObject(obj)
            obj.cgModelObject=get_param(bdroot,'cgModel');
            if~isempty(obj.cgModelObject)
                obj.isModelObjectAvailable=true;
            end
            obj.simulinkTokenRepository=coder.SimulinkTokenRepository(obj.cgModelObject);
        end

        function setFileRepository(obj)
            obj.slcgFileRepository=get_param(bdroot,'SLCGFileRepository');
        end

        function emitFiles(obj,usingTimerService)
            fileList=obj.slcgFileRepository.FileList;
            for k=1:length(fileList)
                file=fileList(k);


                fid=fopen(fullfile(obj.buildDir,file.Name),'w+','n','Latin1');
                c=onCleanup(@()fclose(fid));
                obj.simulinkTokenRepository.setCurrentFileName(file.Name);

                for i=1:length(obj.cgtObject.orderedSectionHeaders)



                    sectionName=obj.cgtObject.orderedSectionHeaders{i};
                    if strcmp(sectionName,'Functions')&&...
                        file.hasSection('FUNCTIONS_SECTION')
                        banner='FunctionBanner';
                        fcnSection=file.getFunctionsSection;
                        for j=1:fcnSection.getNumberOfFunctions()
                            fcnName=fcnSection.getFunctionName(j);
                            obj.simulinkTokenRepository.setCurrentFunctionName(fcnName);
                            sectionString=obj.cgtObject.createAndEmitSection(banner,obj.simulinkTokenRepository);
                            if~isempty(sectionString)&&~isempty(fcnSection.getFunction(j))
                                fprintf(fid,'\n');
                                fprintf(fid,'%s \n',slsvInternal('slsvEscapeServices','unicode2native',sectionString));
                            end
                            fprintf(fid,'%s\n',slsvInternal('slsvEscapeServices','unicode2native',deblank(fcnSection.getFunction(j))));
                        end
                    elseif strcmp(sectionName,'FileBanner')||strcmp(sectionName,'FileTrailer')
                        sectionString=obj.cgtObject.createAndEmitSection(sectionName,obj.simulinkTokenRepository);

                        if~isempty(sectionString)
                            fprintf(fid,'%s\n',slsvInternal('slsvEscapeServices','unicode2native',sectionString));
                        end
                    elseif strcmp(sectionName,'Includes')&&...
                        file.hasSection('INCLUDES_SECTION')

                        includes=file.getIncludesSection.getContent;
                        if~isempty(includes)

                            sectionString=obj.cgtObject.createAndEmitSection(sectionName,obj.simulinkTokenRepository);
                            if~isempty(sectionString)
                                fprintf(fid,'%s\n',slsvInternal('slsvEscapeServices','unicode2native',sectionString));
                            end
                            fprintf(fid,'%s\n',slsvInternal('slsvEscapeServices','unicode2native',includes));
                        end
                    elseif strcmp(sectionName,'Types')&&...
                        file.hasSection('TYPEDEFS_SECTION')

                        typedefs=file.getFileSection('TYPEDEFS_SECTION').getContent;
                        if~isempty(typedefs)

                            sectionString=obj.cgtObject.createAndEmitSection(sectionName,obj.simulinkTokenRepository);
                            if~isempty(sectionString)
                                fprintf(fid,'%s\n',slsvInternal('slsvEscapeServices','unicode2native',sectionString));
                            end
                            fprintf(fid,'%s\n',slsvInternal('slsvEscapeServices','unicode2native',typedefs));
                        end
                    elseif strcmp(sectionName,'Documentation')&&...
                        file.hasSection('DOCUMENTATION_SECTION')

                        documentation=file.getFileSection('DOCUMENTATION_SECTION').getContent;
                        if~isempty(documentation)
                            sectionString=obj.cgtObject.createAndEmitSection(sectionName,obj.simulinkTokenRepository);
                            if~isempty(sectionString)
                                fprintf(fid,'%s\n',slsvInternal('slsvEscapeServices','unicode2native',sectionString));
                            end
                            fprintf(fid,'%s\n',slsvInternal('slsvEscapeServices','unicode2native',documentation));
                        end
                    end

                end
            end
            obj.generateRTWTypes(usingTimerService);

        end

        function generateRTWTypes(obj,usingTimerService)

            genTimingBridge=obj.cgModelObject.IsModelReferenceTarget&&obj.cgModelObject.NumModelReferenceBlocks>0;




            hasSLMessages=false;



            needHalfPrecisionType=false;


            fixedWidthIntHeader='';
            booleanHeader='';

            coder.internal.wrapGenRTWTYPESDOTH(bdroot,...
            obj.buildDir,...
            obj.cgModelObject.IsGeneratingToSharedLocation,...
            obj.cgModelObject.MaxMultiWordBits,...
            genTimingBridge,...
            false,...
            obj.cgModelObject.IsHostBasedSimulationTarget,...
            hasSLMessages,needHalfPrecisionType,usingTimerService,...
            fixedWidthIntHeader,booleanHeader);
            obj.wrapBannerAndTrailer('rtwtypes.h');







            coder.internal.genZcTypesHeader(fullfile(obj.buildDir,...
            'zero_crossing_types.h'),'rtwtypes.h','uint8_T');
        end


    end

    methods(Access=private)
        function wrapBannerAndTrailer(obj,fileName)

            obj.simulinkTokenRepository.setCurrentFileName(fileName);
            bannerSectionString=obj.cgtObject.createAndEmitSection(...
            'FileBanner',obj.simulinkTokenRepository);
            trailerSectionString=obj.cgtObject.createAndEmitSection(...
            'FileTrailer',obj.simulinkTokenRepository);

            fr=fopen(fullfile(obj.buildDir,fileName),'rt');
            fw=fopen(fullfile(obj.buildDir,'tempfile.txt'),'wt');

            fwrite(fw,sprintf('%s\n',bannerSectionString));
            while feof(fr)==0
                fwrite(fw,sprintf('%s\n',fgetl(fr)));
            end

            fwrite(fw,sprintf('%s\n',trailerSectionString));
            fclose(fr);
            fclose(fw);
            copyfile(fullfile(obj.buildDir,'tempfile.txt'),...
            fullfile(obj.buildDir,fileName),'f');
            delete(fullfile(obj.buildDir,'tempfile.txt'));

        end





    end

end




