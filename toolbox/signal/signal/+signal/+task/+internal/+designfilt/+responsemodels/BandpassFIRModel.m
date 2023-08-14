classdef BandpassFIRModel<signal.task.internal.designfilt.responsemodels.BaseBpBsModel





    methods
        function this=BandpassFIRModel()

            this.pFilterDesignerObj=...
            signal.task.internal.designfilt.filterDesignerObjFactory('bandpassfir');
        end
    end

    methods(Access=protected)

        function fValuesSettings=getFrequencyValuesSettings(this)

            fValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);

            if string(fdesObj.OrderMode)=="Minimum"
                fValuesSettings.F1=ensureNumeric(this,specValues.Fstop1);
                fValuesSettings.F1Name='Fstop1';
                fValuesSettings.F2=ensureNumeric(this,specValues.Fpass1);
                fValuesSettings.F2Name='Fpass1';
                fValuesSettings.F3=ensureNumeric(this,specValues.Fpass2);
                fValuesSettings.F3Name='Fpass2';
                fValuesSettings.F4=ensureNumeric(this,specValues.Fstop2);
                fValuesSettings.F4Name='Fstop2';
            else






                switch fdesObj.FrequencyConstraints
                case 'Passband and stopband edges'
                    fValuesSettings.F1=ensureNumeric(this,specValues.Fstop1);
                    fValuesSettings.F1Name='Fstop1';
                    fValuesSettings.F2=ensureNumeric(this,specValues.Fpass1);
                    fValuesSettings.F2Name='Fpass1';
                    fValuesSettings.F3=ensureNumeric(this,specValues.Fpass2);
                    fValuesSettings.F3Name='Fpass2';
                    fValuesSettings.F4=ensureNumeric(this,specValues.Fstop2);
                    fValuesSettings.F4Name='Fstop2';
                case '6dB points'
                    fValuesSettings.F1=ensureNumeric(this,specValues.F6dB1);
                    fValuesSettings.F1Name='F6dB1';
                    fValuesSettings.F2=ensureNumeric(this,specValues.F6dB2);
                    fValuesSettings.F2Name='F6dB2';
                end
            end
        end

        function magValuesSettings=getMagnitudeValuesSettings(this)

            magValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);




            switch fdesObj.MagnitudeConstraints
            case 'Passband ripple and stopband attenuations'
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Astop1);
                magValuesSettings.Mag1Name='Astop1';
                magValuesSettings.Mag2=ensureNumeric(this,specValues.Apass);
                magValuesSettings.Mag2Name='Apass';
                magValuesSettings.Mag3=ensureNumeric(this,specValues.Astop2);
                magValuesSettings.Mag3Name='Astop2';
            end
        end
    end
end

