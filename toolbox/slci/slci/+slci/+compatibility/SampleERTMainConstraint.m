



classdef SampleERTMainConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='For a multirate model generate an extra function that calls the step function.';
        end


        function obj=SampleERTMainConstraint()
            obj.setEnum('SampleERTMain');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];





            model=aObj.getOwner;
            mdl_handle=model.getHandle();
            compiledSampleTime=slci.internal.getModelSampleTimes(mdl_handle);
            isMultirate=slci.internal.isMultipleSampleTimes(compiledSampleTime);
            paramValue=get_param(mdl_handle,'GenerateSampleERTMain');
            if isMultirate&&isequal(paramValue,'off')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            RecAction=DAStudio.message('Slci:compatibility:SampleERTMainConstraintRecAction',aObj.ParentModel().getName);
            SubTitle=DAStudio.message('Slci:compatibility:SampleERTMainConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:SampleERTMainConstraintInfo');
            if status
                StatusText=DAStudio.message('Slci:compatibility:SampleERTMainConstraintPass');
            else
                StatusText=DAStudio.message('Slci:compatibility:SampleERTMainConstraintWarn',aObj.ParentModel().getName);
            end
        end

    end
end