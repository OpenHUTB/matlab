



classdef InstanceDb<handle

    properties(Constant=true,Access=protected,Hidden=true)
        FullILSuffix='full'
        SummarySuffix='summary'
    end

    properties(SetAccess=protected,GetAccess=public,Hidden)
Analyzers
    end

    methods



        function this=InstanceDb()
            this.Analyzers={};
        end




        function info=hasInfo(this)
            info=~isempty(this.Analyzers);
        end








        function changed=removeIf(this,removePredicate)

            changed=false;

            insertIdx=1;
            elementCount=numel(this.Analyzers);
            for ii=1:elementCount
                current=this.Analyzers{ii};
                removeIt=removePredicate(current);

                if~removeIt
                    this.Analyzers{insertIdx}=current;
                    insertIdx=insertIdx+1;
                end
            end

            if insertIdx<=elementCount
                changed=true;
                this.Analyzers=this.Analyzers(1:insertIdx-1);
            end
        end




        function changed=clearInstances(this,codeAnalysis)
            changed=false;

            codeNames=codeAnalysis.getEntriesNames();
            ids=codeAnalysis.getInstanceIds();
            idMap=containers.Map(ids,ids);

            insertIdx=1;
            elementCount=numel(this.Analyzers);
            for ii=1:elementCount
                current=this.Analyzers{ii};

                removeIt=false;
                if strcmp(current.Architecture,codeAnalysis.Architecture)&&...
                    strcmp(current.ModelName,codeAnalysis.ModelName)&&...
                    strcmp(current.AnalysisMode,codeAnalysis.AnalysisMode)&&...
                    (current.SimulationMode==codeAnalysis.SimulationMode)&&...
                    all(current.Instances.isKey(codeNames))
                    removeIt=true;
                    for sf=1:numel(codeNames)
                        codeName=codeNames{sf};
                        instances=current.getInstanceInfos(codeName);
                        if~all(idMap.isKey({instances.SID}))
                            removeIt=false;
                        end
                    end
                end

                if~removeIt
                    this.Analyzers{insertIdx}=current;
                    insertIdx=insertIdx+1;
                end
            end

            if insertIdx<=elementCount
                changed=true;
                this.Analyzers=this.Analyzers(1:insertIdx-1);
            end
        end




        function addAnalysis(this,codeAnalysis)
            this.Analyzers{end+1}=codeAnalysis;
        end




        function[hasInfo,info]=hasExistingInfo(this,codeAnalysis,full,summary)
            [hasInfo,index]=codeAnalysis.hasExistingInfo(this.Analyzers,full,summary);
            info=[];
            if index>0
                info=this.Analyzers{index};
            end
        end






        function changed=clearEntries(this,codeAnalysis)

            codeNames=codeAnalysis.getEntriesNames();

            changed=this.removeIf(@(current)strcmp(current.Architecture,codeAnalysis.Architecture)&&...
            strcmp(current.ModelName,codeAnalysis.ModelName)&&...
            strcmp(current.AnalysisMode,codeAnalysis.AnalysisMode)&&...
            (current.SimulationMode==codeAnalysis.SimulationMode)&&...
            all(current.Instances.isKey(codeNames)));
        end






        function changed=clearModelName(this,codeAnalysis)

            changed=false;

            if~isempty(codeAnalysis.ModelName)
                changed=this.removeIf(@(current)strcmp(current.Architecture,codeAnalysis.Architecture)&&...
                strcmp(current.ModelName,codeAnalysis.ModelName));
            end
        end






        function changed=clearOtherStaticChecksums(this,codeAnalysis)
            changed=this.removeIf(@(current)current.hasDifferentChecksum(codeAnalysis));
        end
    end

    methods(Abstract)
























        [analysis,info]=getAnalysisInfo(this,entryName,entryInfo,analysisMode,varargin)
    end

    methods(Hidden=true)



        function writeCgelFile(~,outputFile,cgelContent,key)
            cgelHex=sprintf('%02X',cgelContent);

            cipher=polyspace.internal.polyspaceObfuscation(key);
            cgel=cipher.decrypt(cgelHex);

            fid=fopen(outputFile,'w','n','utf-8');
            fprintf(fid,'%s',cgel);
            fclose(fid);
        end




        function encryptedContent=readCgelFile(~,inputFile,key)
            fid=fopen(inputFile,'r','n','utf-8');
            cgel=fread(fid,'*char');
            fclose(fid);

            cipher=polyspace.internal.polyspaceObfuscation(key);
            cgelHex=cipher.encrypt(cgel');

            encryptedContent=transpose(uint8(sscanf(cgelHex,'%02x')));
        end





        function extractIr(this,key,outputDirectory)

            if nargin<3
                outputDirectory=pwd;
            end

            for ii=1:numel(this.Analyzers)
                current=this.Analyzers{ii};
                modelName=current.ModelName;

                full=current.FullIR;
                if~isempty(full)
                    fullLog=current.FullLog;
                    if fullLog.isVvirIl()
                        outputFile=this.getCgelFilePath(outputDirectory,modelName,ii,...
                        this.FullILSuffix,'.vvir');
                        fid=fopen(outputFile,'w','n','utf-8');
                        fwrite(fid,full.IR,'*uint8');
                        fclose(fid);
                    else
                        outputFile=this.getCgelFilePath(outputDirectory,modelName,ii,...
                        this.FullILSuffix);
                        this.writeCgelFile(outputFile,full.IR,key);
                    end
                end

                summary=current.SummaryIR;
                if~isempty(summary)
                    outputFile=this.getCgelFilePath(outputDirectory,modelName,ii,...
                    this.SummarySuffix);
                    this.writeCgelFile(outputFile,summary.IR,key);
                end
            end
        end






        function changed=updateIr(this,key,directory)

            if nargin<3
                directory=pwd;
            end

            changed=false;

            for ii=1:numel(this.Analyzers)
                current=this.Analyzers{ii};
                modelName=current.ModelName;

                full=current.FullIR;
                fullFile=this.getCgelFilePath(directory,modelName,ii,...
                this.FullILSuffix);
                if isfile(fullFile)
                    fileContent=this.readCgelFile(fullFile,key);
                    changed=true;

                    if isempty(full)
                        full=sldv.code.internal.IRInfo();
                        full.Shared=current.getInstanceCount()>1;
                    end
                    full.IR=fileContent;
                end

                summary=current.SummaryIR;
                summaryFile=this.getCgelFilePath(directory,modelName,ii,...
                this.SummarySuffix);
                if isfile(summaryFile)
                    fileContent=this.readCgelFile(summaryFile,key);
                    changed=true;
                    if isempty(summary)
                        summary=sldv.code.internal.IRInfo();
                        summary.Shared=current.getInstanceCount()>1;
                    end
                    summary.IR=fileContent;
                end
            end
        end




        function filePath=getCgelFilePath(~,directory,modelName,index,suffix,ext)
            if nargin<6
                ext='.cgel';
            end
            if isempty(modelName)
                baseName=sprintf('%d',index);
            else
                baseName=sprintf('%d_%s',index,modelName);
            end

            fileName=sprintf('%s_%s%s',baseName,suffix,ext);
            filePath=fullfile(directory,fileName);
        end
    end
end


