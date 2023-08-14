classdef DifferentiatorFIRModel<signal.task.internal.designfilt.responsemodels.BaseConstrainedResponseModel





    properties(Access=protected,Transient)
        StatePropNames={'OrderMode','Order','FrequencyConstraints',...
        'FrequencyUnits','InputSampleRate','MagnitudeConstraints',...
        'DesignMethod','Fpass','Fstop','Apass','Astop'};
    end

    methods
        function this=DifferentiatorFIRModel()

            this.pFilterDesignerObj=...
            signal.task.internal.designfilt.filterDesignerObjFactory('differentiatorfir');
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

        function specificationSettings=getSpecificationsSettings(this)




            specificationSettings.Order=ensureNumeric(this,this.pFilterDesignerObj.Order);
            specificationSettings.OrderRestriction=getOrderRestriction(this);
        end

        function fValuesSettings=getFrequencyValuesSettings(this)

            fValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);
            if strcmp(fdesObj.FrequencyConstraints,'Passband edge and stopband edge')
                fValuesSettings.F1=ensureNumeric(this,specValues.Fpass);
                fValuesSettings.F1Name='Fpass';
                fValuesSettings.F2=ensureNumeric(this,specValues.Fstop);
                fValuesSettings.F2Name='Fstop';
            end
        end

        function magConstraintsSettings=getMagnitudeConstraintsSettings(~)

            magConstraintsSettings=struct.empty;
        end

        function restriction=getOrderRestriction(this)
            fdesObj=this.pFilterDesignerObj;
            restriction='none';
            if strcmp(fdesObj.FrequencyConstraints,'Unconstrained')

                restriction='odd';
            elseif strcmp(fdesObj.FrequencyConstraints,'Passband edge and stopband edge')

                restriction='even';
            end
        end
    end
end

