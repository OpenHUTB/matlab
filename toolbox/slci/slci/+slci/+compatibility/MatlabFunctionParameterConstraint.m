



classdef MatlabFunctionParameterConstraint<slci.compatibility.Constraint

    properties(Access=protected)

        fParameterName='';
        fParameterValues={};
        fDispParameterName='';
        fDispParameterValues={};

    end

    methods(Access=protected)


        function setParameterName(aObj,aParameterName)
            aObj.fParameterName=aParameterName;
        end


        function setParameterValues(aObj,aParameterValues)
            if iscell(aParameterValues)
                aObj.fParameterValues=aParameterValues;
            else
                aObj.fParameterValues={aParameterValues};
            end
        end


        function setDispParameterName(aObj,aDispParameterName)
            aObj.fDispParameterName=aDispParameterName;
        end


        function setDispParameterValues(aObj,aDispParameterValues)
            if iscell(aDispParameterValues)
                aObj.fDispParameterValues=aDispParameterValues;
            else
                aObj.fDispParameterValues={aDispParameterValues};
            end
        end

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,...
            aObj.getEnum(),...
            aObj.ParentChart.getName(),...
            aObj.fDispParameterName,...
            aObj.getListOfStrings(aObj.fDispParameterValues,false));
        end

    end

    methods


        function out=getID(aObj)



            out=aObj.fParameterName;
        end


        function obj=MatlabFunctionParameterConstraint(aFatal,...
            aParameterName,...
            aParameterValue,...
            aDispParameterName,...
aDispParameterValue...
            )
            obj.setFatal(aFatal);
            obj.setParameterName(aParameterName);
            obj.setParameterValues(aParameterValue);
            obj.setDispParameterName(aDispParameterName);
            obj.setDispParameterValues(aDispParameterValue);
            obj.setCompileNeeded(0);

        end


        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,varargin)

            constraintKey=[aObj.getEnum,'Constraint'];

            parameterValuesStr=aObj.getListOfStrings(aObj.fDispParameterValues,true);
            if isempty(parameterValuesStr)
                parameterValuesStr='''''';
            end

            parameterNameStr=aObj.fDispParameterName;

            SubTitle=DAStudio.message(...
            ['Slci:compatibility:',constraintKey,'SubTitle'],...
            parameterNameStr,parameterValuesStr);

            Information=DAStudio.message(...
            ['Slci:compatibility:',constraintKey,'Info'],...
            parameterNameStr,parameterValuesStr);

            status=varargin{1};
            if status
                status='Pass';
            else
                status='Warn';
            end
            StatusText=DAStudio.message(...
            ['Slci:compatibility:',constraintKey,status],...
            parameterNameStr,parameterValuesStr);

            RecAction=DAStudio.message(...
            ['Slci:compatibility:',constraintKey,'RecAction'],...
            parameterNameStr,parameterValuesStr);


        end


    end

    methods(Abstract=true)

        out=check(aObj);
    end

end
