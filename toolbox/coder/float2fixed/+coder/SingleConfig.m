
classdef SingleConfig<coder.FixPtConfig

    methods
        function this=SingleConfig()
            this=this@coder.FixPtConfig(true);

            this.HighlightPotentialDataTypeIssues=true;
            this.IndexType='int32';


            this.DoNotRunConversionYet=false;
            this.ConverterInstance=[];


            this.EnableMEXLogging=false;
        end
    end

    methods(Hidden)
        function disp(this)
            generalList={'CodegenDirectory'...
            ,'TestBenchName'};

            simulationRangeAnalysisList={'ComputeSimulationRanges'...
            ,'ComputeCodeCoverage'};

            derivedRangeAnalysisList={'ComputeDerivedRanges'...
            ,'StaticAnalysisTimeoutMinutes'...
            ,'StaticAnalysisQuickMode'};


            fixedPtConvList={'OutputFileNameSuffix'...
            ,'HighlightPotentialDataTypeIssues'};

            fixedPtVerificationList={'TestNumerics'...
            ,'LogIOForComparisonPlotting'...
            ,'PlotFunction'...
            ,'PlotWithSimulationDataInspector'};


            list={generalList{:},simulationRangeAnalysisList{:},derivedRangeAnalysisList{:},fixedPtConvList{:},fixedPtVerificationList{:}};%#ok<CCAT>

            paddedList=rightPad(list);

            generalList=paddedList(1:length(generalList));
            paddedList(1:length(generalList))=[];

            simulationRangeAnalysisList=paddedList(1:length(simulationRangeAnalysisList));
            paddedList(1:length(simulationRangeAnalysisList))=[];

            derivedRangeAnalysisList=paddedList(1:length(derivedRangeAnalysisList));
            paddedList(1:length(derivedRangeAnalysisList))=[];

            fixedPtConvList=paddedList(1:length(fixedPtConvList));
            paddedList(1:length(fixedPtConvList))=[];






            fixedPtVerificationList=paddedList(1:length(fixedPtVerificationList));
            paddedList(1:length(fixedPtVerificationList))=[];%#ok<NASGU>

            disp('Description: ''class SingleConfig: Single Precision configuration object.''');
            disp('Name: ''SingleConfig''');
            disp(' ');

            disp('-------------------------------- General ------------------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,generalList);
            disp(' ');

            disp('---------------------- Simulation Range Analysis ----------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,simulationRangeAnalysisList);
            disp(' ');

            disp('---------------------- Double To Single Conversion --------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,fixedPtConvList);
            disp(' ');










            disp('----------------------- Single Verification ----------------------');
            disp(' ');
            cellfun(@(prop)printProperty(prop)...
            ,fixedPtVerificationList);

            disp(' ');

            function printProperty(propName)
                propVal=this.(strtrim(propName));
                strPropVal=to_str(propVal);
                if ischar(propVal)
                    strPropVal=['''',strPropVal,''''];
                elseif isempty(propVal)
                    strPropVal='[]';
                end
                disp([propName,': ',strPropVal]);

                function res=to_str(val)
                    if iscell(val)
                        strCellVals=cellfun(@(v)to_str(v)...
                        ,val...
                        ,'UniformOutput',false);
                        res=strjoin(strCellVals,' ,');
                    elseif isnumeric(val)
                        res=num2str(val);
                    elseif ischar(val)
                        res=val;
                    elseif isa(val,'function_handle')
                        res=['@',func2str(val)];
                    elseif this.isReallyLogical(val)
                        res=logical2str(val);
                    else
                        error('unknown type');
                    end
                end

                function ret=logical2str(val)
                    if islogical(val)
                        if val
                            ret='true';
                        else
                            ret='false';
                        end
                    else
                        error('expecting logical input');
                    end
                end
            end

            function paddedList=rightPad(strList)
                paddedList=cell(1,length(strList));
                maxLength=max(cellfun(@(str)length(str),strList));
                for ii=1:length(strList)
                    str=strList{ii};
                    paddedList{ii}=[repmat(' ',1,maxLength-length(str)),str];
                end
            end
        end
    end


    methods(Hidden)

        addApproximation(~)
        addDesignRangeSpecification(~)
        addTypeSpecification(~)
        clearApproximations(~)
        clearDesignRangeSpecifications(~)
        clearTypeSpecifications(~)
        getDesignRangeSpecification(~)
        getTypeSpecification(~)
        hasDesignRangeSpecification(~)
        hasTypeSpecification(~)
        removeDesignRangeSpecification(~)
        removeTypeSpecification(~)
    end

    methods(Hidden)
        function dialog(this)

        end

        function fld=getRelativeBuildDirectory(~)
            fld='single';
        end
    end

    methods(Hidden)
        function varargout=properties(this)
            props={
'TestBenchName'
'ComputeSimulationRanges'
'ComputeCodeCoverage'
'OutputFileNameSuffix'
'HighlightPotentialDataTypeIssues'
'TestNumerics'
'LogIOForComparisonPlotting'
'PlotFunction'
'PlotWithSimulationDataInspector'
            };
            if nargout==0
                disp(' ');
                disp(getString(message('Coder:FXPCONV:DTS_SingleConfigPropertiesHeader')));
                disp(' ');
                for ii=1:numel(props)
                    disp(['    ',props{ii}]);
                end
                disp(' ');
            end

            if nargout==1
                varargout{1}=props;
            end
        end
    end

    methods(Hidden)
        function f=fields(this)
            f=properties(this);
        end

        function f=fieldnames(this)
            f=properties(this);
        end
    end


    properties(Hidden)
        FeatureInferIndexVariables=true;
IndexType


DoNotRunConversionYet
ConverterInstance
    end

    methods
        function set.IndexType(this,value)
            propName='IndexType';
            if isempty(value)
                this.(propName)='';
                return;
            end
            if~ischar(value)
                throwError(this,propName,class(value),{class('')});
            end
            if isempty(value)
                this.(propName)=value;
            else
                legal={'int8','int16','int32','int64',...
                'uint8','uint16','uint32','uint64'};
                switch value
                case legal,
                otherwise,
                    error(message('Coder:FXPCONV:IntegerDataTypeRequired',value));
                end
                this.(propName)=value;
            end
        end

        function t=get.FeatureInferIndexVariables(this)
            if isempty(this.IndexType)
                t=false;
            else
                t=this.('FeatureInferIndexVariables');
            end
        end
    end
end
