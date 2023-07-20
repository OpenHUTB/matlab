classdef HighpassFIRModel<signal.task.internal.designfilt.responsemodels.BaseLpHpModel





    methods
        function this=HighpassFIRModel()

            this.pFilterDesignerObj=...
            signal.task.internal.designfilt.filterDesignerObjFactory('highpassfir');
        end
    end

    methods(Access=protected)

        function fValuesSettings=getFrequencyValuesSettings(this)

            fValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);

            if string(fdesObj.OrderMode)=="Minimum"
                fValuesSettings.F1=ensureNumeric(this,specValues.Fstop);
                fValuesSettings.F1Name='Fstop';
                fValuesSettings.F2=ensureNumeric(this,specValues.Fpass);
                fValuesSettings.F2Name='Fpass';
            else

                s=getActiveFrequencyConstraints(this);







                if s.hasFstop
                    fValuesSettings.F1=ensureNumeric(this,specValues.Fstop);
                    fValuesSettings.F1Name='Fstop';
                    if s.hasFpass
                        fValuesSettings.F2=ensureNumeric(this,specValues.Fpass);
                        fValuesSettings.F2Name='Fpass';
                    end
                elseif s.hasF6db
                    fValuesSettings.F1=ensureNumeric(this,specValues.F6dB);
                    fValuesSettings.F1Name='F6dB';
                end
            end
        end

        function magValuesSettings=getMagnitudeValuesSettings(this)

            magValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);




            hasApass=contains(lower(fdesObj.MagnitudeConstraints),'passband ripple');
            hasAstop=contains(lower(fdesObj.MagnitudeConstraints),'stopband attenuation');




            if hasAstop
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Astop);
                magValuesSettings.Mag1Name='Astop';
                if hasApass
                    magValuesSettings.Mag2=ensureNumeric(this,specValues.Apass);
                    magValuesSettings.Mag2Name='Apass';
                end
            end
        end

        function restriction=getOrderRestriction(this)

            fdesObj=this.pFilterDesignerObj;
            restriction='none';
            freqConstraints=fdesObj.FrequencyConstraints;
            magConstraints=fdesObj.MagnitudeConstraints;

            if strcmp(freqConstraints,'6dB point')&&...
                strcmp(magConstraints,'Stopband attenuation and passband ripple')
                restriction='even';
            end
        end
    end
end

