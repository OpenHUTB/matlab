classdef CDFX<handle&matlab.mixin.CustomDisplay&matlab.mixin.SetGet












    properties(SetAccess=private,GetAccess=public)

        Name string

        Path string

        Version string
    end

    properties(Hidden,Transient)

Systems

FullSystemTable

FullInstanceTable

Model

Parser

Writer
    end

    methods
        function obj=CDFX(file)



            if isempty(builtin('license','inuse','Vehicle_Network_Toolbox'))


                if~builtin('license','checkout','Vehicle_Network_Toolbox')

                    error(message('asam_cdfx:CDFX:LicenseNotFound'));
                end
            end


            [obj.Name,obj.Path]=asam.CDFX.getFilePathDetails(file);



            obj.Parser=cdfx.io.CDFParser;
            try
                obj.Model=obj.Parser.parseFile(obj.Path);
            catch ME
                switch ME.identifier
                case 'mf0:io:UnderlyingParserProblem'
                    switch ME.message
                    case 'Failed to parse: unknown encoding'
                        error(message('asam_cdfx:CDFX:InvalidSchemaReference'));
                    otherwise
                        rethrow(ME);
                    end
                case 'MATLAB:structRefFromNonStruct'
                    error(message('asam_cdfx:CDFX:MissingExpectedElement'));
                otherwise
                    rethrow(ME);
                end
            end



            obj.Version=obj.Model.topLevelElements.CATEGORY.elementValue;


            swSystemArray=obj.Model.topLevelElements.SW_SYSTEMS.SW_SYSTEM.toArray;


            numSystems=numel(swSystemArray);
            numInstances=0;


            for idx=1:numSystems
                obj.Systems=[obj.Systems,asam.cdfx.SWSystem(obj,swSystemArray(idx))];
                numInstances=numInstances+obj.Systems(idx).NumInstances;
            end


            obj.FullSystemTable=obj.buildFullSystemTable();


            obj.FullInstanceTable=obj.buildFullInstanceTable(numInstances);

        end

        function write(obj,varargin)










            try

                narginchk(1,2);


                if isempty(varargin)

                    file=obj.Path;
                else

                    file=convertCharsToStrings(varargin{1});
                    [fileFullName,fileFullPath,~]=asam.CDFX.validateFilePath(file);


                    obj.Path=string(fileFullPath);
                    obj.Name=strcat(fileFullName(1),fileFullName(2));


                    file=obj.Path;
                end


                obj.Writer=cdfx.io.CDFSerializer;
                try
                    obj.Writer.serializeToFile(obj.Model,file);
                catch ME
                    error(message('asam_cdfx:CDFX:InvalidWriteLocation'));
                end

            catch ME

                throwAsCaller(ME);
            end
        end

        function instList=instanceList(obj,varargin)




















            try

                narginchk(1,5);


                varargin=convertCharsToStrings(varargin);


                p=inputParser;
                p.addOptional("instanceName","",@(x)validateattributes(x,{'string','char'},{'scalartext'},'instanceList','INSTANCENAME'));
                p.addOptional("systemName","",@(x)validateattributes(x,{'string','char'},{'scalartext'},'instanceList','SYSTEMNAME'));
                p.addParameter("ExactMatch",false,@(x)validateattributes(x,{'logical'},{}));
                p.parse(varargin{:});


                instanceName=p.Results.instanceName;
                systemName=p.Results.systemName;
                exactMatch=p.Results.ExactMatch;


                reducedInstanceList=obj.FullInstanceTable(:,1:6);


                if exactMatch

                    instList=reducedInstanceList(strcmp(reducedInstanceList.ShortName,instanceName),:);


                    if~any(strcmp('systemName',p.UsingDefaults))
                        instList=instList(strcmp(instList.System,systemName),:);
                    end
                    return;
                end



                instList=reducedInstanceList(contains(reducedInstanceList.ShortName,instanceName),:);
                instList=instList(contains(instList.System,systemName),:);

            catch ME

                throwAsCaller(ME);
            end
        end

        function sysList=systemList(obj,varargin)












            try

                narginchk(1,4);


                varargin=convertCharsToStrings(varargin);


                p=inputParser;
                p.addOptional("systemName","",@(x)validateattributes(x,{'string','char'},{'scalartext'},'systemList','SYSTEMNAME'));
                p.addParameter("ExactMatch",false,@(x)validateattributes(x,{'logical'},{}));
                p.parse(varargin{:});


                systemName=p.Results.systemName;
                exactMatch=p.Results.ExactMatch;


                reducedSystemTable=obj.FullSystemTable(:,1:3);


                if exactMatch

                    sysList=reducedSystemTable(strcmp(obj.FullSystemTable.ShortName,systemName),:);
                else

                    sysList=reducedSystemTable(contains(obj.FullSystemTable.ShortName,systemName),:);
                end
            catch ME

                throwAsCaller(ME);
            end
        end
    end

    methods(Access=public)
        function val=getValue(obj,instanceName,varargin)












            try

                narginchk(2,3);


                instanceName=convertCharsToStrings(instanceName);


                validateattributes(instanceName,{'string'},{'scalartext'},'getValue','INSTANCENAME',1);


                if~any(strcmp(instanceName,obj.FullInstanceTable.ShortName))

                    error(message('asam_cdfx:CDFX:InstanceNameNotFound'));
                end


                instList=obj.FullInstanceTable;
                indexMatches=find(strcmp(instanceName,obj.FullInstanceTable.ShortName));
                if numel(indexMatches)>1
                    if isempty(varargin)

                        error(message('asam_cdfx:CDFX:InstanceNameNotUnique'));
                    end


                    systemNameQuery=convertCharsToStrings(varargin{1});
                    validateattributes(systemNameQuery,{'string'},{'scalartext'},'getValue','SYSTEMNAME',1);


                    if~any(strcmp(systemNameQuery,obj.FullSystemTable.ShortName))

                        error(message('asam_cdfx:CDFX:SystemNameNotFound'));
                    end

                    instList=obj.instanceList(instanceName,systemNameQuery,'ExactMatch',true);


                    if height(instList)==0

                        error(message('asam_cdfx:CDFX:InstanceNameNotFound'));
                    end
                    indexMatches=1;


                elseif nargin==3

                    systemNameQuery=convertCharsToStrings(varargin{1});
                    validateattributes(systemNameQuery,{'string'},{'scalartext'},'getValue','SYSTEMNAME',1);
                    if~any(strcmp(systemNameQuery,obj.FullSystemTable.ShortName))

                        error(message('asam_cdfx:CDFX:SystemNameNotFound'));
                    end
                end


                val=instList.Value{indexMatches};

            catch ME

                throwAsCaller(ME);
            end
        end

        function setValue(obj,instName,varargin)












            try

                narginchk(2,4);

                if nargin==2
                    instanceTable=instName;
                    if~istable(instanceTable)
                        validateattributes(instanceTable,{'table'},{},'setValue','INSTANCETABLE')
                    end


                    for idx=1:height(instanceTable)
                        try
                            obj.setValue(instanceTable.ShortName(idx),instanceTable.System(idx),instanceTable.Value{idx});
                        catch ME
                            rethrow(ME);
                        end
                    end

                    return;
                elseif nargin==3

                    instanceIndexMatches=strcmpi(instName,obj.FullInstanceTable.ShortName);
                    if numel(find(instanceIndexMatches))>1

                        error(message('asam_cdfx:CDFX:InstanceNameNotUnique'));
                    elseif numel(find(instanceIndexMatches))==0

                        error(message('asam_cdfx:CDFX:InstanceNameNotFound'));
                    end


                    systemName=obj.FullInstanceTable.System{instanceIndexMatches};


                    newVal=varargin{1};

                elseif nargin==4

                    systemName=varargin{1};


                    instanceIndexMatches=strcmpi(systemName,obj.FullInstanceTable.System);


                    if~any(instanceIndexMatches)

                        error(message('asam_cdfx:CDFX:SystemNameNotFound'));
                    end


                    instanceIndexMatches=strcmpi(instName,obj.FullInstanceTable.ShortName)&strcmpi(systemName,obj.FullInstanceTable.System);


                    if~any(instanceIndexMatches)

                        error(message('asam_cdfx:CDFX:InstanceNameNotFound'));
                    end


                    newVal=varargin{2};
                end



                systemIndexMatches=strcmpi(systemName,obj.FullSystemTable.ShortName);
                systemObj=obj.Systems(systemIndexMatches);


                instanceIndexInSystem=strcmpi(instName,systemObj.InstanceNames);
                instanceObj=systemObj.Instances(instanceIndexInSystem);


                newVal=convertCharsToStrings(newVal);
                instanceObj.setValue(newVal,false);


                obj.FullInstanceTable.Value{instanceIndexMatches}=instanceObj.Value;

            catch ME

                throwAsCaller(ME);
            end
        end
    end

    methods(Static,Hidden)
        function obj=loadobj(obj)



            try
                obj=cdfx(obj.Path);
            catch
                obj.Name="";
                obj.Path="";
                obj.Version="";
                obj.Systems=[];
                obj.FullSystemTable=[];
                obj.FullInstanceTable=[];
                obj.Model=[];
                warning(message('asam_cdfx:CDFX:UnableToLoadFromMATFile'));
            end

        end
    end
    methods(Static,Access=private)

        function[name,path]=getFilePathDetails(file)



            [~,fileName,fileExt]=fileparts(file);


            if isempty(fileExt)||strcmp(fileExt,"")
                error(message('asam_cdfx:CDFX:FileExtensionNotSpecified'));
            end


            if~any(strcmpi(fileExt,{'.cdfx','.xml','.cdf'}))
                error(message('asam_cdfx:CDFX:FileNotACDFFile'));
            end


            fileFullPath=asam.CDFX.findFullFilePath(file);
            if strcmp(fileFullPath,'')


                fileFullPath=asam.CDFX.findFullFilePath(strcat(fileName,fileExt));
            end


            if isempty(fileFullPath)
                error(message('asam_cdfx:CDFX:FileNotFound'));
            end


            name=strcat(fileName,fileExt);
            path=fileFullPath;
        end

        function fullFilePath=findFullFilePath(file)









            fullFilePath=which(file);
            if~strcmp(fullFilePath,'')

                return;
            end


            [status,info]=fileattrib(file);
            if status

                fullFilePath=info.Name;
            end
        end

        function shortnames=getShortNames(elementList)




            shortnames=strings(1,numel(elementList));


            for idx=1:numel(elementList)
                shortnames(idx)=string(elementList(idx).ShortName);
            end


            shortnames=string(shortnames);
        end

        function[fileFullName,fileFullPath,isNewFile]=validateFilePath(file)









            [~,fileName,fileExt]=fileparts(file);


            if isempty(fileExt)||strcmp(fileExt,"")
                error(message('asam_cdfx:CDFX:FileExtensionNotSpecified'));
            end


            if~any(strcmpi(fileExt,{'.cdfx','.xml','.cdf'}))
                error(message('asam_cdfx:CDFX:FileNotACDFFile'));
            end


            fileFullName=[fileName,fileExt];


            fileFullPath=asam.CDFX.findFullFilePath(file);



            isNewFile=false;
            if isempty(fileFullPath)
                isNewFile=true;


                file(file=='/')=filesep;
                file(file=='\')=filesep;


                if asam.CDFX.isAbsoluteFilePath(file)
                    fileFullPath=file;
                else

                    fileFullPath=fullfile(pwd,file);
                end
            end
        end

        function isAbsolutePath=isAbsoluteFilePath(file)




            isLinuxorUNCPath=startsWith(file,["\\","/"]);


            isDrivePath=~isempty(regexpi(file,'^[a-zA-Z]:\\'));


            isAbsolutePath=isLinuxorUNCPath||isDrivePath;
        end
    end

    methods(Access=private)
        function sysTable=buildFullSystemTable(obj)




            sysNames=asam.CDFX.getShortNames(obj.Systems)';


            instNames=cell(numel(sysNames),1);


            metadata=strings(numel(sysNames),1);


            for idx=1:numel(sysNames)
                instNames{idx}=asam.CDFX.getShortNames(obj.Systems(idx).Instances);
                metadata(idx)="NO_VCD";
                if obj.Systems(idx).HasVariantProps
                    metadata(idx)="VCD";
                end
            end


            sysTable=table(sysNames,instNames,metadata,obj.Systems','VariableNames',{'ShortName','Instances','Metadata','SystemHandles'});
        end

        function instTable=buildFullInstanceTable(obj,numInstances)




            shortNames=strings(numInstances,1);
            sysNames=strings(numInstances,1);
            instCategories=strings(numInstances,1);
            values=cell(numInstances,1);
            units=strings(numInstances,1);
            featureRefs=strings(numInstances,1);
            objectHandles=cell(numInstances,1);


            instanceCount=1;
            for idx=1:numel(obj.Systems)
                for jdx=1:numel(obj.Systems(idx).Instances)

                    shortNames(instanceCount)=obj.Systems(idx).Instances(jdx).ShortName;
                    sysNames(instanceCount)=obj.Systems(idx).ShortName;
                    instCategories(instanceCount)=obj.Systems(idx).Instances(jdx).Category;
                    values{instanceCount}=obj.Systems(idx).Instances(jdx).Value;
                    units(instanceCount)=obj.Systems(idx).Instances(jdx).Units;
                    featureRefs(instanceCount)=obj.Systems(idx).Instances(jdx).FeatureReference;
                    objectHandles{instanceCount}=obj.Systems(idx).Instances(jdx);
                    instanceCount=instanceCount+1;
                end
            end


            instTable=table(shortNames,sysNames,instCategories,values,units,featureRefs,objectHandles,'VariableNames',{'ShortName','System','Category','Value','Units','FeatureReference','ObjectHandles'});

        end
    end

    methods(Hidden)
        function setValueInternal(obj,instName,systemName,newVal)









            instanceIndexMatches=strcmpi(instName,obj.FullInstanceTable.ShortName)&strcmpi(systemName,obj.FullInstanceTable.System);


            if~any(instanceIndexMatches)

                error(message('asam_cdfx:CDFX:SystemNameNotFound'));
            end



            systemIndexMatches=strcmpi(systemName,obj.FullSystemTable.ShortName);
            systemObj=obj.Systems(systemIndexMatches);


            instanceIndexInSystem=strcmpi(instName,systemObj.InstanceNames);
            instanceObj=systemObj.Instances(instanceIndexInSystem);




            instanceObj.setValue(newVal,true);


            obj.FullInstanceTable.Value{instanceIndexMatches}=instanceObj.Value;

        end
    end
end


