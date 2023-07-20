classdef OutputDimensionConstraint<matlab.system.DimensionConstraintBase&...
    matlab.mixin.internal.Scalar&...
    matlab.mixin.CustomDisplay

    methods
        function obj=OutputDimensionConstraint(argType,varargin)
            if~ischar(argType)&&~isstring(argType)
                error(message('MATLAB:system:notCharOrStringArg','Type'));
            end
            lResults=matlab.system.OutputDimensionConstraint.parseAll(...
            class(obj),argType,varargin{:});
            obj.Type=argType;

            propNames=fieldnames(lResults);
            if~isempty(propNames)
                szProp=size(propNames,1);
                for idx=1:szProp
                    obj.(propNames{idx})=lResults.(propNames{idx});
                end
            end
        end
    end


    methods(Hidden,Static)
        function lResults=parseAll(classname,argType,varargin)
            nonNegIntValidationFcn=@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'});
            p=inputParser;
            try
                switch argType
                case{'MinimumSize'}
                    p.addRequired('Size',nonNegIntValidationFcn);
                case{'Unknown'}
                end
                if isempty(varargin)
                    p.parse;
                else
                    p.parse(varargin{:});
                end
                lResults=p.Results;

            catch E

                if strcmp(E.identifier,'MATLAB:InputParser:UnmatchedParameter')
                    if strcmp(argType,'Unknown')
                        errID='MATLAB:system:badExtraConstraintParamName';
                        ME=MException(errID,getString(message(errID,...
                        'outputDimensionConstraint',...
                        'matlab.system.OutputDimensionConstraint',...
                        'Type',argType,'Type',argType)));
                    else
                        token=strtok(E.message,'''''');
                        errID='MATLAB:system:badConstraintParamName';
                        ME=MException(errID,getString(message(errID,...
                        token,...
                        'outputDimensionConstraint',...
                        'matlab.system.OutputDimensionConstraint',...
                        'Type',argType)));
                    end
                    throwAsCaller(ME);

                elseif strcmp(E.identifier,'MATLAB:InputParser:notEnoughInputs')
                    token='Size';
                    errID='MATLAB:system:missingConstraintParamName';
                    ME=MException(errID,getString(message(errID,...
                    token,...
                    'outputDimensionConstraint',...
                    'matlab.system.OutputDimensionConstraint',...
                    'Type',argType)));
                    throwAsCaller(ME);
                elseif strcmp(E.identifier,'MATLAB:InputParser:ParamMustBeChar')
                    if strcmp(argType,'Unknown')
                        errID='MATLAB:system:badExtraConstraintParamName';
                        ME=MException(errID,getString(message(errID,...
                        'outputDimensionConstraint',...
                        'matlab.system.OutputDimensionConstraint',...
                        'Type',argType,'Type',argType)));
                    else
                        token='Size';
                        errID='MATLAB:system:missingConstraintParamName';
                        ME=MException(errID,getString(message(errID,...
                        token,...
                        'outputDimensionConstraint',...
                        'matlab.system.OutputDimensionConstraint',...
                        'Type',argType)));
                    end
                    throwAsCaller(ME);
                else
                    throwAsCaller(E);
                end
            end
        end
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(obj)
            switch obj.Type
            case{'MinimumSize'}
                propList=struct('Type',obj.Type,...
                'Size',obj.Size);
            case{'Unknown'}
                propList=struct('Type',obj.Type);
            end
            propgrp=matlab.mixin.util.PropertyGroup(propList);
        end
    end
end
