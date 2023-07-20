classdef Result<handle







    properties(SetAccess=private,Hidden=true)
FPTSignal
TimeSeriesID
Alert
    end

    properties(SetAccess=private)
ResultName
SpecifiedDataType
CompiledDataType
ProposedDataType
Wraps
Saturations
WholeNumber
SimMin
SimMax
DerivedMin
DerivedMax
RunName
Comments
DesignMin
DesignMax
    end

    methods

        function this=Result(FPTSignal)
            this.FPTSignal=FPTSignal;

        end

        function v=get.ResultName(this)
            v=this.FPTSignal.getUniqueIdentifier.getDisplayName;
        end

        function v=get.Wraps(this)
            v=this.FPTSignal.getOverflowWrap;
        end

        function v=get.Saturations(this)
            v=this.FPTSignal.getOverflowSaturation;
        end

        function v=get.SimMin(this)
            v=this.FPTSignal.SimMin;
        end

        function v=get.SimMax(this)
            v=this.FPTSignal.SimMax;
        end

        function v=get.DerivedMin(this)
            v=this.FPTSignal.DerivedMin;
        end

        function v=get.DerivedMax(this)
            v=this.FPTSignal.DerivedMax;
        end

        function v=get.DesignMin(this)
            v=this.FPTSignal.DesignMin;
        end

        function v=get.DesignMax(this)
            v=this.FPTSignal.DesignMax;
        end

        function v=get.RunName(this)
            v=this.FPTSignal.getRunName;
        end

        function v=get.SpecifiedDataType(this)
            v=this.FPTSignal.getPropValue('SpecifiedDT');
        end

        function v=get.CompiledDataType(this)
            v=this.FPTSignal.getPropValue('CompiledDT');
        end

        function v=get.ProposedDataType(this)
            v=this.FPTSignal.getPropValue('ProposedDT');
        end

        function v=get.Comments(this)
            commentGen=SimulinkFixedPoint.CommentGenerator();
            v=commentGen.getComments(this.FPTSignal);
        end

        function v=get.TimeSeriesID(this)
            v=unique(this.FPTSignal.getTimeSeriesID);
        end

        function v=get.WholeNumber(this)
            v=this.FPTSignal.WholeNumber;
        end

        function v=get.Alert(this)
            v=this.FPTSignal.getAlert;
        end
    end

    methods(Hidden,Access={?DataTypeWorkflow.Converter})
        function FPTSignal=getFPTSignal(this)
            FPTSignal=this.FPTSignal;
        end
    end

end

