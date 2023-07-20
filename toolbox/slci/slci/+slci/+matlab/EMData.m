



classdef EMData<slci.common.ChartData

    properties(Access=private)
        fIsTunableParam=false;
        fSize=[];
    end

    methods


        function aObj=EMData(aDataUDDObj,aParent)
            aObj@slci.common.ChartData(aDataUDDObj,aParent);
            aObj.setIsTunable(aDataUDDObj);
            aObj.addConstraints();
        end


        function isTunable=getIsTunable(aObj)
            isTunable=aObj.fIsTunableParam;
        end


        function size=getSize(aObj)
            if isempty(aObj.fSize)
                chartSLHandle=aObj.ParentBlock.getHandle;
                dpi=sf('DataParsedInfo',aObj.fSfId,chartSLHandle);


                assert(~isempty(dpi));
                assert(~isempty(dpi.compiled.size));
                aObj.fSize=str2num(dpi.compiled.size);%#ok<ST2NM>
            end
            size=aObj.fSize;
        end

    end

    methods(Access=private)


        function setIsTunable(aObj,aDataUDDObj)
            if strcmpi(aObj.getScope(),'Parameter')&&aDataUDDObj.Tunable
                aObj.fIsTunableParam=true;
            end
        end

    end

    methods(Access=protected)


        function addConstraints(aObj)
            aObj.addConstraint(slci.compatibility.MatlabFunctionDatatypeConstraint);
            aObj.addConstraint(...
            slci.compatibility.MatlabFunctionDimConstraint(...
            {'Scalar','Vector','Matrix'}));
            aObj.addConstraint(slci.compatibility.MatlabFunctionRealDataConstraint);
        end

    end


end

