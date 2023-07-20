classdef HilbertFIRModel<signal.task.internal.designfilt.responsemodels.BaseConstrainedResponseModel





    properties(Access=protected,Transient)
        StatePropNames={'OrderMode','Order',...
        'FrequencyUnits','InputSampleRate','DesignMethod','TransitionWidth','Apass'};
    end

    methods
        function this=HilbertFIRModel()

            this.pFilterDesignerObj=...
            signal.task.internal.designfilt.filterDesignerObjFactory('hilbertfir');
        end

        function modelState=getState(this)

            fdesObj=this.pFilterDesignerObj;


            modelState.SampleRateSource=this.pSampleRateSource;
            modelState.SampleRateName=this.pSampleRateName;
            modelState.SampleRateValue=this.pSampleRateValue;
            modelState.PreviousSampleRateValue=this.pPreviousSampleRateValue;

            propNames=this.StatePropNames;
            for idx=1:numel(propNames)
                modelState.(propNames{idx})=fdesObj.(propNames{idx});
            end

            modelState.DesignOptions=getDesignOptions(this);
        end

        function setState(this,modelState)

            fdesObj=this.pFilterDesignerObj;


            this.pSampleRateSource=modelState.SampleRateSource;
            this.pSampleRateName=modelState.SampleRateName;
            this.pSampleRateValue=modelState.SampleRateValue;
            this.pPreviousSampleRateValue=modelState.PreviousSampleRateValue;


            propNames=this.StatePropNames;
            for idx=1:numel(propNames)
                fdesObj.(propNames{idx})=modelState.(propNames{idx});
            end


            designOpts=modelState.DesignOptions;
            setDesignOptionsState(this,designOpts);
        end
    end

    methods(Access=protected)

        function freqConstraintsSettings=getFrequencyConstraintsSettings(this)

            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);

            fUnits=lower(string(fdesObj.FrequencyUnits));
            if contains(fUnits,'normalized')
                freqConstraintsSettings.FrequencyUnitsValue="normalized";
            else
                freqConstraintsSettings.FrequencyUnitsValue="Hz";
                freqConstraintsSettings.SampleRate=this.pSampleRateName;
                freqConstraintsSettings.SampleRateSource=this.pSampleRateSource;
                freqConstraintsSettings.SampleRateNumericValue=this.pSampleRateValue;
            end

            freqConstraintsSettings.F1=ensureNumeric(this,specValues.TransitionWidth);
            freqConstraintsSettings.F1Name='TransitionWidth';
        end

        function magConstraintsSettings=getMagnitudeConstraintsSettings(~)

            magConstraintsSettings=struct.empty;
        end
    end
end

