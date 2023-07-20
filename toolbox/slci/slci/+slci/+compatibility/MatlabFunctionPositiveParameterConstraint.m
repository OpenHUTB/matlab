



classdef MatlabFunctionPositiveParameterConstraint<slci.compatibility.MatlabFunctionParameterConstraint


    methods


        function out=getDescription(aObj)%#ok
            out='Check if MATLAB function parameter is a supported value';
        end


        function obj=MatlabFunctionPositiveParameterConstraint(isFatal,...
            aParameterName,...
            aParameterValue,...
            aDispParameterName,...
aDispParameterValue...
            )
            obj@slci.compatibility.MatlabFunctionParameterConstraint(isFatal,...
            aParameterName,...
            aParameterValue,...
            aDispParameterName,...
aDispParameterValue...
            );
            obj.setEnum('MatlabFunctionPositiveParameter');
        end


        function out=check(aObj)

            out=[];
            parameterName=aObj.fParameterName;
            chartUDD=aObj.ParentChart().getUDDObject();
            parameterValue=chartUDD.(parameterName);
            supportedValues=aObj.fParameterValues;
            for idx=1:numel(supportedValues)
                if isequal(parameterValue,supportedValues{idx})

                    return
                end
            end


            out=aObj.getIncompatibility();
        end

        function out=hasAutoFix(~)
            out=true;
        end


        function out=fix(aObj,~)
            out=false;
            try
                parameterName=aObj.fParameterName;
                supportedValues=aObj.fParameterValues;
                chartUDD=aObj.ParentChart().getUDDObject();

                chartUDD.(parameterName)=supportedValues{1};
                out=true;
            catch
            end

        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(...
            aObj,status,varargin)
            if~isempty(varargin)&&strcmp(varargin{1},'fix')

                [SubTitle,Information,~,~]=...
                getSpecificMAStrings@slci.compatibility.MatlabFunctionParameterConstraint(...
                aObj,status,varargin);
                StatusText=DAStudio.message(...
                'Slci:compatibility:MatlabFunctionPositiveParameterFix',...
                aObj.fParameterName,aObj.fParameterValues{1});
                RecAction='';
            else
                [SubTitle,Information,StatusText,RecAction]=...
                getSpecificMAStrings@slci.compatibility.MatlabFunctionParameterConstraint(...
                aObj,status,varargin);
            end
        end

    end
end
