classdef(Sealed)DataTypeSet<matlab.system.internal.ConstrainedSet




    properties(SetAccess=private)




        HasDesignMinimum(1,1)logical





        HasDesignMaximum(1,1)logical







ValuePropertyName
    end

    properties(Hidden,SetAccess=private)









        Compatibility{compatabilityCheck}='None'




DataTypeRules




CustomDataType
    end

    methods
        function obj=DataTypeSet(values,varargin)
            p=inputParser;
            p.addRequired('Values',@(x)iscell(x)||isstring(x));
            p.addParameter('HasDesignMinimum',false);
            p.addParameter('HasDesignMaximum',false);
            isScalarText=@(x)(ischar(x)&&isrow(x))||isStringScalar(x);
            p.addParameter('ValuePropertyName','',isScalarText);
            p.addParameter('Compatibility','None',isScalarText);
            p.parse(values,varargin{:});
            pResults=p.Results;


            values=values(:);
            if iscell(values)
                ruleIdx=cellfun(@(x)ischar(x)||isstring(x),values);

                textEntries=values(ruleIdx);
                if~iscellstr(textEntries)


                    dataTypeRules=string(textEntries);
                else
                    dataTypeRules=textEntries;
                end

                customDataType=values(~ruleIdx);
            else
                dataTypeRules=values;
                customDataType={};
            end

            validateSetValues(dataTypeRules,customDataType);

            obj.DataTypeRules=dataTypeRules;

            if~isempty(customDataType)
                obj.CustomDataType=customDataType{1};
            end


            obj.ValuePropertyName=pResults.ValuePropertyName;
            obj.HasDesignMinimum=pResults.HasDesignMinimum;
            obj.HasDesignMaximum=pResults.HasDesignMaximum;
            obj.Compatibility=pResults.Compatibility;
        end

        function match=findMatch(obj,value,propName)
            try
                dataTypeRules=obj.DataTypeRules;
                customDataType=obj.CustomDataType;
                if ischar(value)||isStringScalar(value)
                    ind=find(strcmpi(value,dataTypeRules));
                    if isempty(ind)
                        matlab.system.internal.error('MATLAB:system:DataTypeSet:UnsupportedRule',...
                        propName,value,obj.getAllowedValuesMessage);
                    elseif isstring(dataTypeRules)
                        match=dataTypeRules(ind);
                    else
                        match=dataTypeRules{ind};
                    end
                elseif isa(value,'embedded.numerictype')&&~strcmp(obj.Compatibility,'Legacy')
                    if isempty(customDataType)
                        matlab.system.internal.error('MATLAB:system:DataTypeSet:UnsupportedCustomDataType',...
                        propName,obj.getAllowedValuesMessage);
                    else
                        match=customDataType.findNumerictypeMatch(value,propName);
                    end
                else
                    matlab.system.internal.error('MATLAB:system:DataTypeSet:UnsupportedClass',...
                    propName,class(value),obj.getAllowedValuesMessage);
                end
            catch e
                e.throwAsCaller;
            end
        end

        function values=getAllowedValues(obj)
            values=obj.DataTypeRules;
        end

        function validateCustomDataType(obj,propName,value)
            matlab.system.internal.CustomDataType.validateCustomDataType(...
            obj.CustomDataType,propName,value);
        end

        function disp(obj)
            if isempty(obj.CustomDataType)
                disp('System object data type set for data type rules:')
                disp(obj.DataTypeRules);
            elseif isempty(obj.DataTypeRules)
                disp('System object data type set for numerictype object')
            else
                disp('System object data type set for numerictype object and data type rules:')
                disp(obj.DataTypeRules);
            end
        end
    end

    methods(Access=private)
        function msg=getAllowedValuesMessage(obj)
            dataTypeRules=obj.DataTypeRules;
            customDataType=obj.CustomDataType;
            if isempty(dataTypeRules)
                msg=message('MATLAB:system:DataTypeSet:MustSpecifyCustomDataType').getString;
            elseif isempty(customDataType)||strcmp(obj.Compatibility,'Legacy')
                switch numel(dataTypeRules)
                case 1
                    msg=message('MATLAB:system:DataTypeSet:MustSpecifyRule',dataTypeRules{1}).getString;
                case 2
                    msg=message('MATLAB:system:DataTypeSet:MustSpecifyRulesAllowTwo',...
                    dataTypeRules{1},dataTypeRules{2}).getString;
                otherwise
                    rulesStr='';
                    for ind=1:numel(dataTypeRules)-1
                        rulesStr=[rulesStr,message('MATLAB:system:DataTypeSet:RuleWithConjunction',...
                        dataTypeRules{ind}).getString,' '];%#ok<AGROW>
                    end
                    msg=message('MATLAB:system:DataTypeSet:MustSpecifyRulesAllowMany',...
                    rulesStr,dataTypeRules{end}).getString;
                end
            else
                switch numel(dataTypeRules)
                case 1
                    msg=message('MATLAB:system:DataTypeSet:MustSpecifyRuleOrCustomDataType',...
                    dataTypeRules{1}).getString;
                otherwise
                    rulesStr='';
                    for ind=1:numel(dataTypeRules)
                        rulesStr=[rulesStr,message('MATLAB:system:DataTypeSet:RuleWithConjunction',...
                        dataTypeRules{ind}).getString,' '];%#ok<AGROW>
                    end
                    msg=message('MATLAB:system:DataTypeSet:MustSpecifyRulesOrCustomDataType',rulesStr).getString;
                end

            end
        end
    end
end

function validateSetValues(dataTypeRules,customDataType)


    if isempty(dataTypeRules)&&isempty(customDataType)
        matlab.system.internal.error('MATLAB:system:DataTypeSet:Empty');
    end

    if numel(customDataType)>1
        matlab.system.internal.error('MATLAB:system:DataTypeSet:MultipleCustomDataType');
    end

    if any(strcmp('',dataTypeRules))
        matlab.system.internal.error('MATLAB:system:DataTypeSet:EmptyRule');
    end

    if length(dataTypeRules)~=length(unique(lower(dataTypeRules)))
        matlab.system.internal.error('MATLAB:system:DataTypeSet:DuplicateRule');
    end

    if~isempty(customDataType)
        if~isa(customDataType{1},'matlab.system.internal.CustomDataType')
            matlab.system.internal.error('MATLAB:system:DataTypeSet:InvalidRule');
        end
    end
end

function compatabilityCheck(v)
    if~ismember(v,{'None','Legacy'})
        matlab.system.internal.error('MATLAB:system:DataTypeSet:InvalidCompatibility');
    end
end
