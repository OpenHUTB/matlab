


classdef SqrtIntermediateResultsDataTypeConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out=['The ''Intermediate results'' data type should be the'...
            ,'same as the input'];
        end

        function obj=SqrtIntermediateResultsDataTypeConstraint()
            obj.setEnum('SqrtIntermediateResultsDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');

            signalDataType=compiledPortDataTypes.Inport(1);

            intermediateResults=...
            aObj.ParentBlock().getParam('IntermediateResultsDataTypeStr');
            if~strcmpi(intermediateResults,signalDataType)...
                &&~strcmpi(intermediateResults,'Inherit: Inherit from input')...
                &&~strcmpi(intermediateResults,'Inherit: Inherit from output')...
                &&~strcmpi(intermediateResults,'Inherit: Inherit via internal rule')
                out=slci.compatibility.Incompatibility(aObj,...
                'SqrtIntermediateResultsDataType',...
                aObj.ParentBlock().getName());
                return;
            end

        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction']);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status]);
        end

    end
end
