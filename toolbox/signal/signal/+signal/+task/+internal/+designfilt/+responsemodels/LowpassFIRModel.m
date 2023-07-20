classdef LowpassFIRModel<signal.task.internal.designfilt.responsemodels.BaseLpHpModel





    methods
        function this=LowpassFIRModel()

            this.pFilterDesignerObj=...
            signal.task.internal.designfilt.filterDesignerObjFactory('lowpassfir');
        end
    end

    methods(Access=protected)

        function fValuesSettings=getFrequencyValuesSettings(this)

            fValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);

            if string(fdesObj.OrderMode)=="Minimum"
                fValuesSettings.F1=ensureNumeric(this,specValues.Fpass);
                fValuesSettings.F1Name='Fpass';
                fValuesSettings.F2=ensureNumeric(this,specValues.Fstop);
                fValuesSettings.F2Name='Fstop';
            else

                s=getActiveFrequencyConstraints(this);







                if s.hasFpass
                    fValuesSettings.F1=ensureNumeric(this,specValues.Fpass);
                    fValuesSettings.F1Name='Fpass';
                    if s.hasFstop
                        fValuesSettings.F2=ensureNumeric(this,specValues.Fstop);
                        fValuesSettings.F2Name='Fstop';
                    end
                elseif s.hasF3db
                    fValuesSettings.F1=ensureNumeric(this,specValues.F3dB);
                    fValuesSettings.F1Name='F3dB';
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




            if hasApass
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Apass);
                magValuesSettings.Mag1Name='Apass';
                if hasAstop
                    magValuesSettings.Mag2=ensureNumeric(this,specValues.Astop);
                    magValuesSettings.Mag2Name='Astop';
                end
            elseif hasAstop
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Astop);
                magValuesSettings.Mag1Name='Astop';
            end
        end

        function restriction=getOrderRestriction(this)

            fdesObj=this.pFilterDesignerObj;
            restriction='none';
            freqConstraints=fdesObj.FrequencyConstraints;
            magConstraints=fdesObj.MagnitudeConstraints;

            if strcmp(freqConstraints,'3dB point')&&strcmp(magConstraints,'Unconstrained')
                restriction='even';
            end
        end
    end
end

