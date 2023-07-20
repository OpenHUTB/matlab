





classdef CodeAnalyzer<handle

    properties(Constant=true,Hidden)
        AnalysisCombined='Combined'
        AnalysisInstance='Instance'
    end

    properties



Instances


Architecture


ModelName



AnalysisOptions


AnalysisMode


AnalysisVersion


        SimulationMode SlCov.CovMode=SlCov.CovMode.Normal
    end

    properties(Hidden=true)

        FullIR=[]


        FullLog=[]


        SummaryIR=[]


        SummaryLog=[]
    end

    methods



        function this=CodeAnalyzer(instances)
            if nargin<1
                instances=containers.Map('KeyType','char','ValueType','Any');
            end
            this.Architecture=computer('arch');
            this.Instances=instances;
            this.ModelName='';
            this.AnalysisOptions='';
            this.AnalysisMode='';
            this.AnalysisVersion=sldv.code.CodeAnalyzer.getCurrentVersion();
        end




        function that=shallowCopy(this)
            that=feval(class(this));
            that.Architecture=this.Architecture;
            that.ModelName=this.ModelName;
            that.AnalysisOptions=this.AnalysisOptions;
            that.AnalysisMode=this.AnalysisMode;
            that.SimulationMode=this.SimulationMode;
        end




        function setAnalysisOptions(this,options)

            analysisOptions={};

            if isfield(options,'defaultArraySize')
                analysisOptions{end+1}=sprintf('defaultArraySize=%d',options.defaultArraySize);
            end

            if isfield(options,'ignoreVolatile')
                if options.ignoreVolatile
                    ignoreVolatileString='true';
                else
                    ignoreVolatileString='false';
                end
                analysisOptions{end+1}=sprintf('ignoreVolatile=%s',ignoreVolatileString);
            end
            this.AnalysisOptions=strjoin(analysisOptions,',');

        end







        function addInstance(this,entryName,instanceInfo)
            if this.Instances.isKey(entryName)
                instances=this.Instances(entryName);
                this.Instances(entryName)=[instances,instanceInfo];
            else
                this.Instances(entryName)=instanceInfo;
            end
        end





        function empty=isempty(this)
            if~builtin('isempty',this)
                empty=this.Instances.isempty();
            else
                empty=true;
            end
        end





        function names=getEntriesNames(this)
            names=this.Instances.keys();
        end





        function instancesCount=getInstancesCount(this)
            instancesCount=0;
            entryNames=this.getEntriesNames();
            for ii=1:numel(entryNames)
                instances=this.getInstanceInfos(entryNames{ii});
                instancesCount=instancesCount+numel(instances);
            end
        end





        function instancePaths=getInstanceIds(this)

            instancePaths=cell(1,getInstancesCount(this));

            index=1;
            for it=this.getEntriesNames()
                instances=this.getInstanceInfos(it{1});

                for ii=1:numel(instances)
                    instance=instances(ii);
                    instancePaths{index}=instance.SID;
                    index=index+1;
                end
            end
        end




        function updateModelName(this,designModelName)
            analysisModel=this.ModelName;
            this.ModelName=designModelName;

            entryNames=this.getEntriesNames();
            for idx=1:numel(entryNames)
                instances=this.getInstanceInfos(entryNames{idx});

                for ii=1:numel(instances)
                    instance=instances(ii);
                    instance.updateModelName(analysisModel,designModelName);
                end
            end
        end





        function instanceInfos=getInstanceInfos(this,entryName)
            instanceInfos=[];
            if this.Instances.isKey(entryName)
                instanceInfos=this.Instances(entryName);
            end
        end





        function setInstanceInfos(this,entryName,instances)
            this.Instances(entryName)=instances;
        end




        function checksum=getStaticChecksum(this,entryName)
            checksum='';
            instances=this.Instances(entryName);
            if~isempty(instances)
                checksum=instances(1).StaticChecksum;
            end
        end





        function has=hasSummary(this)
            has=~isempty(this.SummaryIR);
        end




        function summariesLog=getSummaryLog(this)
            summariesLog=this.SummaryLog;
        end




        function fullLog=getFullIrLog(this)
            fullLog=this.FullLog;
        end





        function allCppInfo=getAllCppInfo(this)
            count=this.getInstancesCount();
            if count<=0
                allCppInfo=[];
            else
                entryNames=this.getEntriesNames();

                allCppInfo(count)=sldv.code.internal.CppInstanceInfo();
                index=1;

                for idx=1:numel(entryNames)
                    instances=this.getInstanceInfos(entryNames{idx});

                    for ii=1:numel(instances)
                        allCppInfo(index)=instances(ii).IRMapping;
                        index=index+1;
                    end
                end
            end
        end




        function has=hasFullInfo(this)
            has=~isempty(this.FullIR);
        end




        function analysisTypes=getAnalysisTypes(this)
            analysisTypes={};

            if this.hasFullInfo()
                analysisTypes{end+1}='Full';
            end
            if this.hasSummary()
                analysisTypes{end+1}='Summaries';
            end
        end







        function hasDifferent=hasDifferentChecksumForEntry(this,entryName,checksum)
            hasDifferent=false;
            if this.Instances.isKey(entryName)
                instances=this.Instances(entryName);
                if~isempty(instances)
                    prevChecksum=instances(1).StaticChecksum;
                    hasDifferent=~strcmp(prevChecksum,checksum);
                end
            end
        end






        function hasDifferent=hasDifferentChecksum(this,otherAnalysis)
            hasDifferent=false;
            if strcmp(this.Architecture,otherAnalysis.Architecture)
                for it=otherAnalysis.getEntriesNames()
                    entryName=it{1};
                    checksum=otherAnalysis.getStaticChecksum(entryName);
                    if this.hasDifferentChecksumForEntry(entryName,checksum)
                        hasDifferent=true;
                    end
                end
            end
        end






        function analysisInfo=keepInstance(this,instancePath)

            containerName=this.getInstanceContainerName(instancePath);
            sid=Simulink.ID.getSID(instancePath);

            analysisInfo=[];

            sfcnInstances=this.getInstanceInfos(containerName);
            if~isempty(sfcnInstances)
                instance=sfcnInstances(strcmp({sfcnInstances.SID},sid));
                if numel(instance)==1
                    analysisInfo=shallowCopy(this);
                    analysisInfo.setInstanceInfos(containerName,instance);
                end
            end
        end





        function analysisArray=splitInstances(this)
            entryNames=this.getEntriesNames();
            count=this.getInstancesCount();
            analysisArray(1:count)=this;
            index=1;

            for idx=1:numel(entryNames)
                entryName=entryNames{idx};
                instances=this.getInstanceInfos(entryName);

                for ii=1:numel(instances)
                    current=shallowCopy(this);
                    current.setInstanceInfos(entryName,instances(ii));

                    analysisArray(index)=current;
                    index=index+1;
                end
            end
        end





        function analysisArray=splitEntries(this)
            entryNames=this.getEntriesNames();
            analysisArray(1:numel(entryNames))=this;
            for ii=1:numel(entryNames)
                entryName=entryNames{ii};
                instances=this.getInstanceInfos(entryName);

                current=shallowCopy(this);
                current.setInstanceInfos(entryName,instances);

                analysisArray(ii)=current;
            end
        end





        function sameInfo=isExistingInfo(this,other,full,summary)
            sameInfo=false;
            if strcmp(other.Architecture,this.Architecture)&&...
                (other.SimulationMode==this.SimulationMode)&&...
                strcmp(other.AnalysisVersion,this.AnalysisVersion)&&...
                (~full||other.hasFullInfo())&&...
                (~summary||other.hasSummary())&&...
                strcmp(other.AnalysisOptions,this.AnalysisOptions)&&...
                (isempty(other.AnalysisMode)||strcmp(other.AnalysisMode,this.AnalysisMode))
                sfunctions=this.getEntriesNames();
                currentFunctions=other.getEntriesNames();

                if numel(sfunctions)==numel(currentFunctions)&&...
                    all(strcmp(sfunctions,currentFunctions))

                    for sf=1:numel(sfunctions)
                        if~this.compareEntries(sfunctions{sf},other)
                            return
                        end
                    end

                    sameInfo=true;
                end
            end
        end


















        function[hasInfo,index]=hasExistingInfo(this,analysisArray,full,summary)
            index=0;
            hasInfo=false;

            for ii=1:numel(analysisArray)
                current=analysisArray{ii};

                if this.isExistingInfo(current,full,summary)
                    hasInfo=true;
                    index=ii;
                    return
                end
            end
        end




        function[descriptor,paramCount]=getDescriptorFor(this,entryName,instanceInfo,analysisMode,simMode)
            if nargin<5
                simMode='Normal';
            end
            if nargin<4
                analysisMode='';
            end
            descriptor=[];
            paramCount=-1;

            if(isempty(analysisMode)||strcmp(this.AnalysisMode,analysisMode))&&...
                (this.SimulationMode==simMode)
                instances=this.getInstanceInfos(entryName);
                for ii=1:numel(instances)
                    current=instances(ii);

                    if isempty(current.SID)||strcmp(current.SID,instanceInfo.SID)
                        [compatible,currentParamCount]=current.isValidDescriptionFor(instanceInfo);

                        if compatible
                            if~isempty(current.SID)

                                descriptor=current;
                                paramCount=currentParamCount;
                            elseif currentParamCount>paramCount
                                paramCount=currentParamCount;
                                descriptor=current;
                            end
                        end
                    end
                end
            end
        end




        function print(this,fid)
            if nargin<2
                fid=1;
            end

            analysisTypes=this.getAnalysisTypes();

            fprintf(fid,'%s: %s (%s): %s\n',class(this),this.ModelName,...
            this.Architecture,strjoin(analysisTypes,', '));

            for it=this.Instances.keys()
                entryName=it{1};

                instances=this.Instances(entryName);
                if~isempty(instances)
                    fprintf('  %s (%s)\n',entryName,instances(1).StaticChecksum);

                    for ii=1:numel(instances)
                        instance=instances(ii);
                        fprintf('    %s\n',instance.SID);
                    end
                end
            end
        end
    end

    methods(Abstract)






        removed=removeUnsupported(this)





        containerName=getInstanceContainerName(this,instancePath)





        fullOk=runSldvAnalysis(this,options,varargin)
    end

    methods(Access=protected)



        function setFullIR(this,ir,shared)
            this.FullIR=sldv.code.internal.IRInfo();
            this.FullIR.IR=ir;
            this.FullIR.Shared=shared;
        end




        function sameIndex=getSameIndex(~,instance,instanceArray)
            sameIndex=-1;
            for ii=1:numel(instanceArray)
                other=instanceArray(ii);
                if strcmp(instance.SID,other.SID)&&...
                    instance.isEquivalentDescriptor(other)
                    sameIndex=ii;
                    return
                end
            end
        end





        function same=compareEntries(this,entryName,otherAnalysis)
            instances=this.getInstanceInfos(entryName);
            otherInstances=otherAnalysis.getInstanceInfos(entryName);

            if numel(instances)==numel(otherInstances)
                same=true;
                for ii=1:numel(instances)
                    sameIndex=this.getSameIndex(instances(ii),otherInstances);
                    if sameIndex>0


                        otherInstances(sameIndex)=[];
                    else

                        same=false;
                        return
                    end
                end
            else
                same=false;
            end
        end
    end

    methods(Static=true,Access=public,Hidden)



        function targetType=getTargetType(feInfo,type)
            typeSize=0;
            if type(1)=='u'
                signPrefix='u';
            else
                signPrefix='s';
            end

            switch type
            case{'long','ulong'}
                typeSize=feInfo.LongNumBits;
            case{'int','uint'}
                typeSize=feInfo.IntNumBits;
            case{'longlong','ulonglong'}
                typeSize=feInfo.LongLongNumBits;
            case{'short','ushort'}
                typeSize=feInfo.ShortNumBits;
            case{'char','uchar','schar'}
                typeSize=feInfo.CharNumBits;
            end
            targetType=sprintf('%s%d',signPrefix,typeSize);
        end







        function targetTypes=getTargetTypes(sInfo)
            if isa(sInfo,'internal.cxxfe.FrontEndOptions')
                targetTypes.SizeType=sldv.code.CodeAnalyzer.getTargetType(sInfo.Target,sInfo.Language.SizeTypeKind);
                targetTypes.WcharType=sldv.code.CodeAnalyzer.getTargetType(sInfo.Target,sInfo.Language.WcharTypeKind);
                targetTypes.PtrDiffType=sldv.code.CodeAnalyzer.getTargetType(sInfo.Target,sInfo.Language.PtrDiffTypeKind);
            else
                targetTypes.SizeType=sldv.code.CodeAnalyzer.getTargetType(sInfo.FrontEndOptions,sInfo.FrontEndOptions.SizeTypeKind);
                targetTypes.WcharType=sldv.code.CodeAnalyzer.getTargetType(sInfo.FrontEndOptions,sInfo.FrontEndOptions.WcharTypeKind);
                targetTypes.PtrDiffType=sldv.code.CodeAnalyzer.getTargetType(sInfo.FrontEndOptions,sInfo.FrontEndOptions.PtrDiffTypeKind);
            end
        end
    end

    methods(Static=true)



        function analysisVersion=getCurrentVersion()
            persistent currentVersion;
            if isempty(currentVersion)
                currentVersion=version('-release');
            end

            analysisVersion=currentVersion;
        end




        function analysisMode=getAnalysisModeFromOptions(sldvOptions)
            if strcmp(sldvOptions.Mode,'TestGeneration')||...
                strcmp(sldvOptions.Mode,'DesignErrorDetection')
                analysisMode=sldv.code.CodeAnalyzer.AnalysisInstance;
            else
                analysisMode=sldv.code.CodeAnalyzer.AnalysisCombined;
            end
        end
    end
end


