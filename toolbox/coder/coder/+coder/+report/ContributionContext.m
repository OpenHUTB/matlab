


classdef(Sealed)ContributionContext<handle

    properties(Constant)
        MANIFEST_FILENAME=codergui.ReportServices.MANIFEST_FILENAME
    end


    properties(SetAccess=immutable)
ReportContext
ReportType
IncludedFunctionIds
IncludedScriptIds
LineMaps
LineStarts
Filtered
DryRun
PrintDebugInfo
ValidationMode
VirtualMode
IsContainerFile
    end


    properties(Dependent,SetAccess=private)
Report
    end


    properties(Hidden,SetAccess=immutable)
DataSets
EmbeddedArtifacts
ExternalArtifacts
ManifestProperties
Partitions
DefaultPartition
    end


    properties(Hidden)
Contributions
EmbeddedArtifactList
VirtualMatFiles
    end

    properties(Access=private)
Properties
LockedDataGroups
LockedArtifactGroups
LockedManifestProps
CurrentContributorId
GlobalArtifactIdCounter
    end

    methods
        function this=ContributionContext(reportContext,reportType,includedFunctionIds,includedScriptIds,varargin)
            this.ReportContext=reportContext;
            this.ReportType=reportType;
            this.IncludedFunctionIds=includedFunctionIds;
            this.IncludedScriptIds=includedScriptIds;

            ip=inputParser();
            ip.addParameter('DryRun',false);
            ip.addParameter('Properties',containers.Map());
            ip.addParameter('PrintDebugInfo',false);
            ip.addParameter('ValidationMode',false);
            ip.addParameter('IsContainerFile',false);
            ip.addParameter('VirtualMode',false);
            ip.parse(varargin{:});

            this.DryRun=ip.Results.DryRun;
            this.Properties=ip.Results.Properties;
            this.PrintDebugInfo=ip.Results.PrintDebugInfo;
            this.ValidationMode=ip.Results.ValidationMode;
            this.IsContainerFile=ip.Results.IsContainerFile;
            this.VirtualMode=ip.Results.VirtualMode;

            if this.VirtualMode
                this.VirtualMatFiles=containers.Map();
            end

            report=reportContext.Report;
            this.Filtered=isfield(report,'inference')&&~isempty(report.inference)&&isprop(report.inference,'Functions')&&...
            numel(includedFunctionIds)~=numel(report.inference.Functions);
            [this.LineMaps,this.LineStarts]=codergui.evalprivate('reportToLineMaps',report,this.IncludedScriptIds);
            this.GlobalArtifactIdCounter=0;
            this.DataSets=containers.Map();
            this.EmbeddedArtifacts=containers.Map();
            this.ExternalArtifacts=containers.Map();
            this.EmbeddedArtifactList={};
            this.LockedDataGroups={};
            this.LockedArtifactGroups={};
            this.LockedManifestProps={};
            this.ManifestProperties=containers.Map();
            this.Partitions=containers.Map();
            this.DefaultPartition=coder.report.PartitionDefinition('',true);

            this.Contributions=cell2struct(cell(0,4),{...
            'ContributorId','DataSetIds','EmbeddedArtifactSetIds',...
            'ExternalArtifactSetIds'},2);
        end

        function addData(this,groupKey,dataKey,data,flatten)
            dataMap=this.getOrCreateSubMap(this.DataSets,groupKey,...
            this.LockedDataGroups,'DataSetIds');
            validateattributes(dataKey,{'char'},{'nonempty','scalartext'});

            if exist('flatten','var')&&flatten
                data=codergui.internal.flattenForJson(data);
            end

            if this.ValidationMode
                try
                    jsonencode(data);
                catch me
                    error('Dataset ''%s/%s'' is not serializable to JSON: \n\t%s',...
                    groupKey,dataKey,me.message);
                end
            end

            dataMap(dataKey)=data;%#ok<NASGU>
        end

        function embedArtifact(this,groupKey,artifactKey,varargin)
            descriptor=this.parseArtifactDescriptor(artifactKey,varargin,false);
            if descriptor.external
                rootMap=this.ExternalArtifacts;
            else
                rootMap=this.EmbeddedArtifacts;
            end
            this.EmbeddedArtifactList{end+1}=rmfield(descriptor,'content');
            this.EmbeddedArtifactList{end}.artifactSet=groupKey;
            this.doAddArtifact(groupKey,rootMap,'EmbeddedArtifactSetIds',descriptor);
        end

        function linkArtifact(this,groupKey,artifactKey,varargin)
            descriptor=this.parseArtifactDescriptor(artifactKey,varargin,true);
            this.doAddArtifact(groupKey,this.ExternalArtifacts,'ExternalArtifactSetIds',descriptor);
        end

        function setManifestProperty(this,propKey,propVal)
            assert(~ismember(propKey,this.LockedManifestProps),...
            'Property ''%s'' has already been locked.',propKey);
            this.ManifestProperties(propKey)=codergui.internal.flattenForJson(propVal);
        end

        function setFileForArtifacts(this,groupKey,customFilename)
            this.doSpecifyStorage(groupKey,customFilename,'appendArtifactSet');
        end

        function setFileForData(this,groupKey,customFilename)
            this.doSpecifyStorage(groupKey,customFilename,'appendDataSet');
        end

        function saveMatFile(this,matPath,contentVar)
            if this.VirtualMode
                if startsWith(matPath,this.ReportContext.ReportDirectory)
                    matPath=matPath((numel(this.ReportContext.ReportDirectory)+2):end);
                end
                matPath=strrep(matPath,'\','/');
                this.VirtualMatFiles(matPath)=struct(contentVar,...
                evalin('caller',sprintf('%s;',contentVar)));
            else
                matPath=strrep(matPath,'''','''''');
                evalin('caller',sprintf('save(''%s'',''%s'');',matPath,contentVar));
            end
        end

        function propVal=getProperty(this,propKey)


            if this.Properties.isKey(propKey)
                propVal=this.Properties(propKey);
            else
                propVal=[];
            end
        end

        function report=get.Report(this)
            report=this.ReportContext.Report;
        end

        function lineNum=positionToLine(this,scriptId,position)

            lineNum=zeros(size(position));
            lineMap=this.LineMaps{scriptId};
            if~isempty(lineMap)
                for i=1:length(position)
                    if position(i)<=numel(lineMap)
                        lineNum(i)=lineMap(position(i));
                    else
                        lineNum(i)=numel(lineMap);
                    end
                end
            end
        end

        function debugExec(this,fh)
            if~this.PrintDebugInfo
                return;
            end
            validateattributes(fh,{'function_handle'},{});
            fh();
        end

        function debugPrint(this,arg,varargin)
            if~this.PrintDebugInfo
                return;
            end

            if ischar(arg)
                if this.ReportContext.IsGui
                    coder.internal.gui.asyncDebugPrint(sprintf(arg,varargin{:}));
                else
                    fprintf([arg,'\n'],varargin{:});
                end
            else
                disp(arg);
            end
        end
    end

    methods(Access=private)
        function doAddArtifact(this,groupKey,rootMap,recordField,descriptor)
            artifactMap=this.getOrCreateSubMap(rootMap,groupKey,this.LockedArtifactGroups,recordField);
            artifactMap(descriptor.id)=descriptor;%#ok<NASGU>   
        end

        function doSpecifyStorage(this,groupKey,customFilename,appendMethod)
            assert(~isempty(this.CurrentContributorId));
            validateattributes(groupKey,{'char'},{'scalartext'});

            if exist('customFilename','var')
                validateattributes(customFilename,{'char'},{'scalartext'});
                customFile=this.normalizeFilename(customFilename);
            else
                customFile=this.generateFilename();
            end
            assert(~strcmp(customFile,this.MANIFEST_FILENAME),'"%s" is a reserved file name',customFilename);

            if this.Partitions.isKey(customFile)
                partition=this.Partitions(customFile);
            else
                partition=coder.report.PartitionDefinition(customFile);
                this.Partitions(customFile)=partition;
            end
            feval(appendMethod,partition,groupKey);
        end

        function subMap=getOrCreateSubMap(this,topMap,groupKey,lockedKeys,recordField)
            validateattributes(groupKey,{'char'},{'nonempty','scalartext'});
            assert(~ismember(groupKey,lockedKeys),...
            'Group "%s" has already been locked.',groupKey);

            if topMap.isKey(groupKey)
                subMap=topMap(groupKey);
            else
                subMap=containers.Map();
                topMap(groupKey)=subMap;%#ok<NASGU>  

                if~isempty(this.CurrentContributorId)&&...
                    ~ismember(groupKey,this.Contributions(end).(recordField))
                    this.Contributions(end).(recordField){end+1}=groupKey;
                end
            end
        end

        function generated=generateFilename(this)
            generated='data.json';
            counter=1;
            usedFilenames=this.Partitions.keys();
            while ismember(generated,usedFilenames)
                generated=sprintf('data%d.json',counter);
                counter=counter+1;
            end
        end

        function result=parseArtifactDescriptor(this,artifactKey,args,forceExternal)
            validateattributes(artifactKey,{'char'},{'scalartext'});
            ip=inputParser();
            ip.FunctionName='addArtifact';
            ip.addParameter('Content','',@ischar);
            ip.addParameter('ContentType','',@ischar);
            ip.addParameter('File','',@ischar);
            ip.addParameter('External',false,@islogical);
            ip.addParameter('Encoding','',@ischar);
            ip.parse(args{:});

            parsed=ip.Results;
            external=forceExternal||parsed.External;

            parsed.ArtifactId=artifactKey;
            if external
                assert(~isempty(parsed.File),'External artifacts should be linked to a file');
                assert(isempty(parsed.Content),'External artifacts should not specify content');
            else
                assert(isempty(parsed.Encoding),...
                'Encoding attribute only available for external artifacts');
            end

            if isempty(parsed.ContentType)
                assert(~isempty(parsed.File),...
                'Either an explicit content type or a filename must be specified');
                [~,~,ext]=fileparts(parsed.File);
                if length(ext)>1
                    ext=lower(ext(2:end));
                    if ismember(ext,{'c','h'})
                        parsed.ContentType='c';
                    elseif ismember(ext,{'cpp','hpp'})
                        parsed.ContentType='cpp';
                    elseif strcmp(ext,'m')
                        parsed.ContentType='matlab';
                    elseif ismember(ext,{'html','htm'})
                        parsed.ContentType='html';
                    else
                        parsed.ContentType=ext;
                    end
                else
                    parsed.ContentType='text';
                end
            end

            this.GlobalArtifactIdCounter=this.GlobalArtifactIdCounter+1;

            result=struct(...
            'id',artifactKey,...
            'globalId',['a',num2str(this.GlobalArtifactIdCounter)],...
            'content',parsed.Content,...
            'contentType',parsed.ContentType,...
            'encoding',parsed.Encoding,...
            'external',external);
            if~isempty(parsed.File)
                result.file=parsed.File;
            end
        end
    end

    methods(Hidden)
        function setCurrentContributorId(this,contributorId)
            this.CurrentContributorId=contributorId;
            if~isempty(contributorId)
                this.Contributions(end+1).ContributorId=contributorId;
                this.Contributions(end).EmbeddedArtifactSetIds={};
                this.Contributions(end).ExternalArtifactSetIds={};
                this.Contributions(end).DataSetIds={};
            end
        end

        function lockExistingGroups(this)
            this.LockedDataGroups=this.DataSets.keys();
            this.LockedManifestProps=this.ManifestProperties.keys();
            this.LockedArtifactGroups=unique([this.EmbeddedArtifacts.keys()...
            ,this.ExternalArtifacts.keys()]);
        end

        function postProcess(this)
            allPartitions=this.Partitions.values();


            processUnpartitionedGroups('DataSetIds',this.DataSets,'appendDataSet');
            processUnpartitionedGroups('ArtifactSetIds',this.EmbeddedArtifacts,'appendArtifactSet');

            this.DefaultPartition.File=this.generateFilename();
            this.Partitions(this.DefaultPartition.File)=this.DefaultPartition;

            function processUnpartitionedGroups(idField,groupMap,appendMethodName)
                partitionedKeys={};
                for i=1:numel(allPartitions)
                    partitionedKeys=[partitionedKeys,allPartitions{i}.(idField){:}];%#ok<AGROW>
                end
                unpartitionedKeys=setdiff(groupMap.keys(),partitionedKeys);
                for i=1:numel(unpartitionedKeys)
                    feval(appendMethodName,this.DefaultPartition,unpartitionedKeys{i});
                end
            end
        end
    end

    methods(Static,Access=private)
        function normalized=normalizeFilename(filename)
            assert(~any(strncmp(filename,{'/','\'},1)),'Filename "%s" is not a relative path');
            normalized=strrep(filename,'\','/');
            if~endsWith(normalized,'.json')
                normalized=[normalized,'.json'];
            end
        end
    end
end