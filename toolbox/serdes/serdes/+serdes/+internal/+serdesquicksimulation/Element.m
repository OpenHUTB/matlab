classdef(Abstract)Element<serdes.internal.serdesquicksimulation.CircuitElement




    properties(Hidden)
        SerdesDesign=[]
        SerdesElement=[];
        NonSerdesElement=[];

ParameterNames
ParameterValues
ParameterWorkspaceValues
        PerformBackwardsCompatibilitySupport=true;

        isParameterWorkspaceValuesRestored=false;

amiParameters
    end

    properties(Hidden,Transient)
        Listener=[]
    end

    methods

        function obj=Element(varargin)

            narginchk(0,2)
            if nargin==2
                obj.Name=varargin{2};
            else
                obj.Name=obj.DefaultName;
            end

            isSerdesElement=true;
            if strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:AgcHdrDesc')))
                block=obj;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:FfeHdrDesc')))
                block=obj;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:VgaHdrDesc')))
                block=obj;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:SatAmpHdrDesc')))
                block=obj;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:DfeCdrHdrDesc')))
                block=obj;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:CdrHdrDesc')))
                block=obj;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:CtleHdrDesc')))
                block=obj;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:TransparentHdrDesc')))
                block=obj;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:AnalogOutHdrDesc')))
                block=obj;
                isSerdesElement=false;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:AnalogInHdrDesc')))
                block=obj;
                isSerdesElement=false;
            elseif strcmpi(obj.HeaderDescription,getString(message('serdes:serdesdesigner:ChannelHdrDesc')))
                block=obj;
                isSerdesElement=false;
            else
                block=[];
                isSerdesElement=false;
            end
            if~isempty(block)

                obj.ParameterNames=fieldnames(block);
                if~isempty(obj.ParameterNames)
                    for i=1:numel(obj.ParameterNames)
                        obj.ParameterValues{i}=block.(obj.ParameterNames{i});
                        obj.ParameterWorkspaceValues{i}='';
                    end
                end
                if~isSerdesElement

                    obj.NonSerdesElement=block;
                else

                    obj.SerdesElement=block;


                    obj.updateAmiParameterList();


                    if~isempty(obj.amiParameters)
                        for i=1:numel(obj.amiParameters)
                            for j=1:numel(obj.ParameterNames)
                                if isprop(obj.amiParameters{i},'CurrentValueDisplay')&&...
                                    (isprop(obj.amiParameters{i},'Name')&&strcmpi(obj.amiParameters{i}.Name,obj.ParameterNames{j})||...
                                    isprop(obj.amiParameters{i},'NodeName')&&strcmpi(obj.amiParameters{i}.NodeName,obj.ParameterNames{j}))
                                    obj.ParameterValues{j}=obj.amiParameters{i}.CurrentValueDisplay;
                                    break;
                                end
                            end
                        end
                    end
                end
            end
        end

        function set.SerdesDesign(obj,design)
            obj.SerdesDesign=design;
            obj.backwardsCompatibilitySupport();
        end
        function set.ParameterNames(obj,names)
            obj.ParameterNames=names;
            obj.backwardsCompatibilitySupport();
        end
        function set.ParameterValues(obj,values)
            obj.ParameterValues=values;
            obj.backwardsCompatibilitySupport();
        end
        function set.ParameterWorkspaceValues(obj,values)
            obj.ParameterWorkspaceValues=values;
            obj.backwardsCompatibilitySupport();
        end
        function backwardsCompatibilitySupport(obj)




            if obj.PerformBackwardsCompatibilitySupport&&~isempty(obj.SerdesDesign)
                if(isempty(obj.SerdesDesign.VersionWhenSaved)||...
                    strcmpi(obj.SerdesDesign.VersionWhenSaved,'2019a')||...
                    strcmpi(obj.SerdesDesign.VersionWhenSaved,'2019b'))&&...
                    ~isempty(obj.ParameterNames)&&~isempty(obj.ParameterValues)||...
                    ~isempty(obj.ParameterNames)&&~isempty(obj.ParameterValues)&&~isempty(obj.ParameterWorkspaceValues)
                    if~obj.isSameParameterNamesAndOrder()
                        obj.resetParameterVectors();
                    end
                    obj.PerformBackwardsCompatibilitySupport=false;
                end
            end
        end
        function isSame=isSameParameterNamesAndOrder(obj)




            paramNames=fieldnames(obj);
            if numel(paramNames)~=numel(obj.ParameterNames)
                isSame=false;
                return;
            end
            for i=1:numel(obj.ParameterNames)
                if~strcmpi(paramNames{i},obj.ParameterNames{i})
                    isSame=false;
                    return;
                end
            end
            isSame=true;
        end
        function resetParameterVectors(obj)








            paramNames=fieldnames(obj);
            paramValues=[];
            paramWorkspaceValues=[];
            if~isempty(paramNames)
                for i=1:numel(paramNames)
                    paramValues{i}=obj.(paramNames{i});
                    paramWorkspaceValues{i}='';
                end
            end

            if~isempty(obj.ParameterNames)&&~isempty(obj.ParameterValues)
                for i=1:numel(obj.ParameterNames)
                    for j=1:numel(paramNames)
                        if strcmpi(paramNames{j},obj.ParameterNames{i})
                            if numel(obj.ParameterValues)>=i
                                paramValues{j}=obj.ParameterValues{i};
                            end
                            if~isempty(obj.ParameterWorkspaceValues)&&numel(obj.ParameterWorkspaceValues)>=i
                                paramWorkspaceValues{j}=obj.ParameterWorkspaceValues{i};
                            end
                            break;
                        end
                    end
                end
            end
            obj.ParameterNames=paramNames;
            obj.ParameterValues=paramValues;
            obj.ParameterWorkspaceValues=paramWorkspaceValues;
        end


        function isWorkspaceVariable=isWorkspaceVariable(obj,paramValue)
            if~isempty(paramValue)&&~isnumeric(paramValue)&&~islogical(paramValue)
                w=evalin('base','whos');
                isWorkspaceVariable=ismember(paramValue,{w(:).name});
            else
                isWorkspaceVariable=false;
            end
        end


        function isNonBlankWorkspaceVariable=isNonBlankWorkspaceVariable(obj,paramValue)
            if~isempty(paramValue)&&~isnumeric(paramValue)
                w=evalin('base','whos');
                isNonBlankWorkspaceVariable=ismember(paramValue,{w(:).name})&&...
                ~isempty(evalin('base',paramValue));
            else
                isNonBlankWorkspaceVariable=false;
            end
        end


        function setWorkspaceVariableValue(obj,paramName,paramValue)
            if~isempty(paramName)&&~isempty(obj.ParameterNames)
                for i=1:length(obj.ParameterNames)
                    if strcmpi(obj.ParameterNames{i},paramName)
                        if obj.isWorkspaceVariable(paramValue)
                            obj.ParameterWorkspaceValues{i}=evalin('base',paramValue);
                        else
                            obj.ParameterWorkspaceValues{i}='';
                        end
                        return;
                    end
                end
            end
        end


        function workspaceValue=getWorkspaceVariableValue(obj,paramName)
            if~isempty(paramName)&&~isempty(obj.ParameterNames)
                for i=1:length(obj.ParameterNames)
                    if strcmpi(obj.ParameterNames{i},paramName)
                        workspaceValue=obj.ParameterWorkspaceValues{i};
                        return;
                    end
                end
            end
            workspaceValue='';
        end


        function updateAmiParameterList(obj)
            if~isempty(obj.SerdesElement)
                try
                    [obj.amiParameters,~]=obj.getAMIParameters();
                catch exception1
                    try
                        obj.amiParameters=obj.getAMIParameters();
                    catch exception2
                        obj.amiParameters=[];
                    end
                end
            end
        end


        function amiParameter=getAmiParameter(obj,name)
            if~isempty(name)&&~isempty(obj.amiParameters)
                for i=1:numel(obj.amiParameters)
                    mstest=isa(obj.amiParameters{i},'serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter');


                    if mstest&&strcmpi(name,obj.amiParameters{i}.NodeName)
                        amiParameter=obj.amiParameters{i};
                        return;
                    end
                end
            end
            amiParameter=[];
        end

        function out=getHeaderDescription(obj)
            out=obj.HeaderDescription;
        end

        function out=DefaultName(obj)
            out=obj.DefaultName;
        end
    end

end
