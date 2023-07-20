classdef(Sealed)SampleTimeSpecification


%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>



    properties(SetAccess=protected)
        Type='Inherited'
        SampleTime=-1
        OffsetTime=0
        TickTime=-1
        AlternatePropagation=''
        AllowPropagation=''
        ErrorOnPropagation=''
        Disallow=''
    end


    properties(Constant,Access=public)
        SampleTimePropOptions={'Constant','Controllable','Continuous','<missing>'};
        SampleTimeOptions={'Discrete','Controllable','Inherited','Fixed In Minor Step','<missing>'};
    end


    methods

        function obj=SampleTimeSpecification(varargin)
            coder.allowpcode('plain');
            coder.extrinsic('matlab.system.coder.SampleTimeSpecification.parseNameValuePairs')
            coder.extrinsic('matlab.system.coder.SampleTimeSpecification.parseAll')
            coder.extrinsic('matlab.system.coder.SampleTimeSpecification.parseType')

            typeResults=matlab.system.coder.SampleTimeSpecification.parseType(...
            class(obj),varargin{:});
            lResults=matlab.system.coder.SampleTimeSpecification.parseAll(...
            class(obj),obj.SampleTimeOptions,typeResults,varargin{:});

            cResults=coder.const(lResults);
            numFields=coder.const(eml_numfields(cResults));
            for idx=coder.unroll(1:numFields)
                propName=eml_getfieldname(cResults,idx-1);
                if strcmp(propName,"AlternatePropagation")
                elseif strcmp(propName,"Disallow")
                    if strcmp(cResults.AlternatePropagation,"<missing>")

                        obj.AlternatePropagation=cResults.(propName);
                    end
                else
                    obj.(propName)=cResults.(propName);
                end
            end
        end
    end

    methods(Hidden,Static)
        function lResults=parseAll(classname,possibleTypes,typeResults,varargin)
            coder.extrinsic('parseNameValuePairs')
            nonNegIntValidationFcn=@(x)validateattributes(x,{'numeric'},{'scalar','real','nonnegative'});
            posIntValidationFcn=@(x)validateattributes(x,{'single','double'},{'scalar','real','positive'});
            strStringValidationFcn=@(x)validateattributes(x,{'char','string'},{'scalartext'});
            strCellValidationFcn=@(x)validateattributes(x,{'cell','char','string'},{'row'});
            p=inputParser;
            try %#ok<EMTC>  This is an extrinsic method
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
                    p.addParameter('SampleTime',0,posIntValidationFcn);
                    p.addParameter('OffsetTime',0,nonNegIntValidationFcn);
                case 'Controllable'
                    p.addParameter('TickTime',0,posIntValidationFcn);
                case 'Inherited'
                    p.addParameter('Disallow','<missing>',strCellValidationFcn);
                    p.addParameter('AlternatePropagation','<missing>',strCellValidationFcn);
                    p.addParameter('AllowPropagation','<missing>',strCellValidationFcn);
                    p.addParameter('ErrorOnPropagation','<missing>',strCellValidationFcn);
                case 'Fixed In Minor Step'
                otherwise
                    error(message('MATLAB:system:badSampleTimeSpecTypeValue',typeResults.Type));
                end
                lResults=matlab.system.coder.SampleTimeSpecification.parseNameValuePairs(...
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
                    matlab.system.coder.SampleTimeSpecification.checkLegacyNewDisallowOpts(classname,lResults);
                    stOptionName='AlternatePropagation';
                    lResults.AlternatePropagation=matlab.system.SampleTimeSpecification.validateOptions(classname,lResults.AlternatePropagation,...
                    matlab.system.coder.SampleTimeSpecification.SampleTimePropOptions);
                    stOptionName='AllowPropagation';
                    lResults.AllowPropagation=matlab.system.SampleTimeSpecification.validateOptions(classname,lResults.AllowPropagation,...
                    matlab.system.coder.SampleTimeSpecification.SampleTimePropOptions);
                    stOptionName='ErrorOnPropagation';
                    lResults.ErrorOnPropagation=matlab.system.SampleTimeSpecification.validateOptions(classname,lResults.ErrorOnPropagation,...
                    matlab.system.coder.SampleTimeSpecification.SampleTimePropOptions);
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
            elseif validType=="Fixed In Minor Step"
                lResults.SampleTime=0;
                lResults.OffsetTime=1;
            end
        end



        function lResults=checkLegacyNewDisallowOpts(~,lResults)

            if~strcmp(lResults.Disallow,'<missing>')
                if~strcmp(lResults.AlternatePropagation,'<missing>')
                    error(message('MATLAB:system:duplicatedSampleTimeOption'));
                else
                    lResults.AlternatePropagation=lResults.Disallow;
                    lResults.Disallow='<missing>';
                end
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
            lResults=matlab.system.coder.SampleTimeSpecification.parseNameValuePairs(...
            classname,p,varargin{idxType:idxType+1});
        end

        function lResults=parseNameValuePairs(~,p,varargin)
            p.parse(varargin{:});
            lResults=p.Results;


            names=fieldnames(lResults)';
            for n=1:numel(names)
                if isstring(lResults.(names{n}))
                    lResults.(names{n})=char(lResults.(names{n}));
                end
            end
        end
    end

    methods(Static)
        function props=matlabCodegenNontunableProperties(~)
            props={'Type','SampleTime','OffsetTime','TickTime','AllowPropagation','AlternatePropagation','ErrorOnPropagation'};
        end
    end
end
