classdef(Sealed)SampleTimeSpecification<matlab.mixin.CustomDisplay&...
    matlab.mixin.internal.Scalar



































    properties(SetAccess=protected)
        Type(1,:)char='Inherited'
        SampleTime=-1
        OffsetTime=0
        TickTime=-1
        AlternatePropagation(1,:)
        AllowPropagation(1,:)
        ErrorOnPropagation(1,:)
    end

    properties(Constant,Access=private)
        SampleTimePropOptions={'Constant','Controllable','Continuous','<missing>'};
        SampleTimeOptions={'Discrete','Controllable','Inherited','Fixed In Minor Step','<missing>'};
    end



    methods(Access=private,Static)
        function name=matlabCodegenRedirect(~)
            name='matlab.system.coder.SampleTimeSpecification';
        end
    end

    methods

        function obj=SampleTimeSpecification(varargin)

            typeResults=matlab.system.SampleTimeSpecification.parseType(...
            class(obj),varargin{:});
            lResults=matlab.system.SampleTimeSpecification.parseAll(...
            class(obj),typeResults,matlab.system.SampleTimeSpecification.SampleTimeOptions,varargin{:});
            obj=obj.copyFromParserToInstance(lResults);


            switch obj.Type
            case 'Discrete'
                if obj.SampleTime==-1
                    errID='MATLAB:system:badSampleTimeSpecUninitVar';
                    ME=MException(errID,getString(message(errID,...
                    'SampleTime',obj.Type)));
                    throwAsCaller(ME);

                end
            case 'Controllable'
                if obj.TickTime==-1
                    errID='MATLAB:system:badSampleTimeSpecUninitVar';
                    ME=MException(errID,getString(message(errID,...
                    'TickTime',obj.Type)));
                    throwAsCaller(ME);
                end
            otherwise
            end


            if~strcmp(class(obj.SampleTime),class(obj.OffsetTime))
                error(message('MATLAB:system:badSampleTimeSpecParamDataType'));
            end
        end
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(obj)
            obj.Type=validatestring(obj.Type,matlab.system.SampleTimeSpecification.SampleTimeOptions);
            switch char(obj.Type)
            case 'Discrete'
                propList=struct('Type',obj.Type,...
                'SampleTime',obj.SampleTime,...
                'OffsetTime',obj.OffsetTime);
            case 'Controllable'
                propList=struct('Type',obj.Type,...
                'TickTime',obj.TickTime);
            case{'Fixed In Minor Step','Inherited','Constant'}
                propList=struct('Type',obj.Type);
            end

            propList=getOptionsGroups(obj,propList,'AlternatePropagation');
            propList=getOptionsGroups(obj,propList,'AllowPropagation');
            propList=getOptionsGroups(obj,propList,'ErrorOnPropagation');
            propgrp=matlab.mixin.util.PropertyGroup(propList);
        end
        function propList=getOptionsGroups(obj,propList,propName)
            optionString=string(obj.(propName));
            if~any(strcmp(optionString,'<missing>'))&&length(optionString)>0&&...
                isstring(optionString)&&any(strlength(optionString)>0)
                propList.(propName)=obj.(propName);
            end
        end
        function obj=copyFromParserToInstance(obj,lResults)

            propNames=fieldnames(lResults);
            if~isempty(propNames)
                szProp=size(propNames);
                for idx=1:szProp(1)
                    if strcmp(propNames{idx},"Disallow")
                        if strcmp(obj.AlternatePropagation,"<missing>")

                            obj.AlternatePropagation=lResults.(propNames{idx});
                        end
                    else
                        obj.(propNames{idx})=lResults.(propNames{idx});
                    end
                end
            end
        end
    end

    methods(Hidden,Static)
        function lResults=parseAll(classname,typeResults,possibleTypes,varargin)
            nonNegIntValidationFcn=@(x)validateattributes(x,{'single','double'},{'scalar','real','nonnegative'});
            posIntValidationFcn=@(x)validateattributes(x,{'single','double'},{'scalar','real','positive'});
            strStringValidationFcn=@(x)validateattributes(x,{'char','string'},{'scalartext'});
            strCellValidationFcn=@(x)validateattributes(x,{'cell','char','string'},{'row'});
            p=inputParser;
            try
                p.addParameter('Type','Inherited',strStringValidationFcn);
                validType=validatestring(typeResults.Type,possibleTypes);
            catch E
                if strcmp(E.identifier,'MATLAB:unrecognizedStringChoice')
                    s=string(E.message);
                    token=s.extractBetween('The input, ''',''', did not match');
                    errID='MATLAB:system:badSampleTimeSpecTypeValue';
                    ME=MException(errID,getString(message(errID,...
                    char(token))));
                    throwAsCaller(ME);
                else
                    throwAsCaller(E);
                end
            end
            try
                switch char(validType)
                case 'Discrete'
                    p.addParameter('SampleTime',-1,posIntValidationFcn);
                    p.addParameter('OffsetTime',0,nonNegIntValidationFcn);
                case 'Controllable'
                    p.addParameter('TickTime',-1,posIntValidationFcn);
                case 'Inherited'
                    p.addParameter('Disallow','<missing>',strCellValidationFcn);
                    p.addParameter('AlternatePropagation','<missing>',strCellValidationFcn);
                    p.addParameter('AllowPropagation','<missing>',strCellValidationFcn);
                    p.addParameter('ErrorOnPropagation','<missing>',strCellValidationFcn);
                case 'Fixed In Minor Step'
                otherwise
                    error(message('MATLAB:system:badSampleTimeSpecTypeValue',typeResults.Type));
                end
                lResults=matlab.system.SampleTimeSpecification.parseNameValuePairs(...
                classname,p,varargin{:});
            catch E
                if strcmp(E.identifier,'MATLAB:InputParser:UnmatchedParameter')
                    token=strtok(E.message,'''''');
                    errID='MATLAB:system:badSampleTimeSpecParamName';
                    ME=MException(errID,getString(message(errID,...
                    token,'Type',p.Results.Type)));
                    throwAsCaller(ME);
                else
                    throwAsCaller(E);
                end
            end
            lResults.Type=validType;
            if validType=="Inherited"
                try
                    stOptionName='Disallow';
                    lResults.Disallow=matlab.system.SampleTimeSpecification.validateOptions(classname,lResults.Disallow,matlab.system.SampleTimeSpecification.SampleTimePropOptions);
                    stOptionName='AlternatePropagation';
                    lResults.AlternatePropagation=matlab.system.SampleTimeSpecification.validateOptions(classname,lResults.AlternatePropagation,matlab.system.SampleTimeSpecification.SampleTimePropOptions);
                    stOptionName='AllowPropagation';
                    lResults.AllowPropagation=matlab.system.SampleTimeSpecification.validateOptions(classname,lResults.AllowPropagation,matlab.system.SampleTimeSpecification.SampleTimePropOptions);
                    stOptionName='ErrorOnPropagation';
                    lResults.ErrorOnPropagation=matlab.system.SampleTimeSpecification.validateOptions(classname,lResults.ErrorOnPropagation,matlab.system.SampleTimeSpecification.SampleTimePropOptions);
                catch E
                    if strcmp(E.identifier,'MATLAB:unrecognizedStringChoice')
                        s=string(E.message);
                        token=s.extractBetween('The input, ''',''', did not match');
                        errID='MATLAB:system:badSampleTimeSpecPropOptionValue';
                        ME=MException(errID,getString(message(errID,...
                        char(token),stOptionName)));
                        throwAsCaller(ME);
                    else
                        throwAsCaller(E);
                    end
                end
                matlab.system.SampleTimeSpecification.checkforDups(classname,lResults.AlternatePropagation,lResults.AllowPropagation,lResults.ErrorOnPropagation);
                matlab.system.SampleTimeSpecification.checkforDups(classname,lResults.Disallow,lResults.AllowPropagation,lResults.ErrorOnPropagation);
            elseif validType=="Fixed In Minor Step"
                lResults.SampleTime=0;
                lResults.OffsetTime=1;
            end
        end

        function optsVal=validateOptions(~,options,OptionsString)
            if iscell(options)||(isstring(options)&&length(options)>1)
                len=length(options);
                optsVal=cell(1,len);
                for i=1:len
                    optsVal{i}=validatestring(string(options{i}),OptionsString);
                end
            else
                optsVal=validatestring(string(options),OptionsString);
            end

        end

        function checkforDups(~,disallowOpt,allowOpt,errorOpt)
            if any(contains(string(disallowOpt),string(allowOpt)))&&all(~strcmp(disallowOpt,'<missing>'))
                error(message('MATLAB:system:duplicatedSampleTimeOption'));
            end
            if any(contains(string(disallowOpt),string(errorOpt)))&&all(~strcmp(disallowOpt,'<missing>'))
                error(message('MATLAB:system:duplicatedSampleTimeOption'));
            end
            if any(contains(string(errorOpt),string(allowOpt)))&&all(~strcmp(errorOpt,'<missing>'))
                error(message('MATLAB:system:duplicatedSampleTimeOption'));
            end
        end

        function lResults=parseType(classname,varargin)
            strTypeValidationFcn=@(x)validateattributes(x,{'char','string'},{'scalartext'});


            idxType=[];
            for n=1:2:numel(varargin)
                if(ischar(varargin{n})||isstring(varargin{n}))&&...
                    strncmpi(varargin{n},"Type",length(char(varargin{n})))
                    idxType=n;
                    break;
                end
            end

            p=inputParser;
            p.addParameter('Type','Inherited',strTypeValidationFcn);
            lResults=matlab.system.SampleTimeSpecification.parseNameValuePairs(...
            classname,p,varargin{idxType:idxType+1});
        end

        function lResults=parseNameValuePairs(~,p,varargin)
            if isempty(varargin)
                p.parse;
            else
                p.parse(varargin{:});
            end
            lResults=p.Results;
        end
    end
end









