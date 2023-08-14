




classdef SFData<slci.common.ChartData

    properties(Access=protected)
        fInitializeMethod='';
        fInitialValue=[];
    end

    methods


        function aObj=SFData(aDataUDDObj,aParent)
            aObj=aObj@slci.common.ChartData(aDataUDDObj,aParent);
            aObj.fInitializeMethod=aDataUDDObj.InitializeMethod;
            aObj.addConstraints();
        end


        function out=getQualifiedName(aObj)
            out=[aObj.fParent.getSID,':',aObj.getName(),':',num2str(aObj.getSfId())];
        end

        function out=getParentName(aObj)
            if isa(aObj.fParent,'slci.stateflow.Chart')
                out=aObj.fParent.getName();
            else
                out=slci.internal.getFullSFObjectName(aObj.fParent.getSID());
            end
        end

        function out=getInitializeMethod(aObj)
            out=aObj.fInitializeMethod;
        end

        function out=getInitialValue(aObj)
            if isempty(aObj.fInitialValue)
                chartSLHandle=aObj.ParentBlock.getHandle;
                dpi=sf('DataParsedInfo',aObj.fSfId,chartSLHandle);
                assert(~isempty(dpi));
                aObj.fInitialValue=dpi.initialval;
            end
            dblValue=slci.internal.convertDataToDouble(aObj.fInitialValue);



            out=dblValue;
        end

        function out=ParentChart(aObj)
            if isa(aObj.fParent,'slci.stateflow.Chart')
                out=aObj.fParent;
            else
                out=aObj.fParent.ParentChart();
            end
        end

    end

    methods(Access=protected)


        function addConstraints(aObj)


            aObj.addConstraint(slci.compatibility.StateflowRealDataConstraint);


            aObj.addConstraint(slci.compatibility.StateflowDatatypeConstraint);


            aObj.addConstraint(slci.compatibility.StateflowDataParentConstraint);



            aObj.addConstraint(slci.compatibility.StateflowDataInitializeMethodConstraint);


            aObj.addConstraint(slci.compatibility.StateflowConstantDataConstraint);


            aObj.addConstraint(slci.compatibility.StateflowParameterDataWSVarSizeConstraint);


            aObj.addConstraint(slci.compatibility.StateflowFirstIndexConstraint);

        end
    end
end


