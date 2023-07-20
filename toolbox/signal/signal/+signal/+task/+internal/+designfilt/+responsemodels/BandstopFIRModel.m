classdef BandstopFIRModel<signal.task.internal.designfilt.responsemodels.BaseBpBsModel





    methods
        function this=BandstopFIRModel()

            this.pFilterDesignerObj=...
            signal.task.internal.designfilt.filterDesignerObjFactory('bandstopfir');
        end

        function updateModel(this,whatChanged,evtData)



            fdesObj=this.pFilterDesignerObj;
            if strcmp(whatChanged,'PassbandOffset1')
                oldPassbandOffset=eval(fdesObj.PassbandOffset);
                newPassbandOffset=mat2str([evtData.Value,oldPassbandOffset(2)]);
                fdesObj.PassbandOffset=newPassbandOffset;
            elseif strcmp(whatChanged,'PassbandOffset2')
                oldPassbandOffset=eval(fdesObj.PassbandOffset);
                newPassbandOffset=mat2str([oldPassbandOffset(1),evtData.Value]);
                fdesObj.PassbandOffset=newPassbandOffset;
            else
                updateModel@signal.task.internal.designfilt.responsemodels.BaseConstrainedResponseModel(this,whatChanged,evtData);
            end
        end
    end

    methods(Access=protected)

        function algorithmSettings=getAlgorithmSettings(this)

            fdesObj=this.pFilterDesignerObj;
            algorithmSettings.MethodPopupItems=fdesObj.getValidMethods;
            algorithmSettings.MethodPopupItemsData=fdesObj.getValidMethods;
            algorithmSettings.MethodPopupValue=fdesObj.DesignMethod;

            designOpts=getDesignOptions(this);
            passBandOffsetIdx=find(strcmp(designOpts(1:2:end),'PassbandOffset'));
            if~isempty(passBandOffsetIdx)
                passbandOffsetVect=designOpts{2*passBandOffsetIdx};
                designOpts{2*passBandOffsetIdx-1}='PassbandOffset1';
                designOpts{2*passBandOffsetIdx}=passbandOffsetVect(1);

                if numel(designOpts)==2*passBandOffsetIdx
                    designOpts=[designOpts(1:2*passBandOffsetIdx),...
                    {'PassbandOffset2',passbandOffsetVect(2)}];
                else
                    designOpts=[designOpts(1:2*passBandOffsetIdx),...
                    {'PassbandOffset2',passbandOffsetVect(2)},...
                    designOpts(2*passBandOffsetIdx+1:end)];
                end
            end
            designOpts=string(designOpts);
            if~isempty(designOpts)


                filtStructIdx=find(ismember(designOpts,'FilterStructure'));
                if~isempty(filtStructIdx)
                    designOpts([filtStructIdx,filtStructIdx+1])=[];
                end
            end
            algorithmSettings.DesignOptions=designOpts;
        end

        function fValuesSettings=getFrequencyValuesSettings(this)

            fValuesSettings=struct;
            fdesObj=this.pFilterDesignerObj;
            specValues=getSpecs(fdesObj);

            if string(fdesObj.OrderMode)=="Minimum"
                fValuesSettings.F1=ensureNumeric(this,specValues.Fpass1);
                fValuesSettings.F1Name='Fpass1';
                fValuesSettings.F2=ensureNumeric(this,specValues.Fstop1);
                fValuesSettings.F2Name='Fstop1';
                fValuesSettings.F3=ensureNumeric(this,specValues.Fstop2);
                fValuesSettings.F3Name='Fstop2';
                fValuesSettings.F4=ensureNumeric(this,specValues.Fpass2);
                fValuesSettings.F4Name='Fpass2';
            else






                switch fdesObj.FrequencyConstraints
                case 'Passband and stopband edges'
                    fValuesSettings.F1=ensureNumeric(this,specValues.Fpass1);
                    fValuesSettings.F1Name='Fpass1';
                    fValuesSettings.F2=ensureNumeric(this,specValues.Fstop1);
                    fValuesSettings.F2Name='Fstop1';
                    fValuesSettings.F3=ensureNumeric(this,specValues.Fstop2);
                    fValuesSettings.F3Name='Fstop2';
                    fValuesSettings.F4=ensureNumeric(this,specValues.Fpass2);
                    fValuesSettings.F4Name='Fpass2';
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
            case 'Passband ripples and stopband attenuation'
                magValuesSettings.Mag1=ensureNumeric(this,specValues.Apass1);
                magValuesSettings.Mag1Name='Apass1';
                magValuesSettings.Mag2=ensureNumeric(this,specValues.Astop);
                magValuesSettings.Mag2Name='Astop';
                magValuesSettings.Mag3=ensureNumeric(this,specValues.Apass2);
                magValuesSettings.Mag3Name='Apass2';
            end
        end

        function setDesignOptionsState(this,designOpts)
            fdesObj=this.pFilterDesignerObj;
            for idx=1:numel(designOpts)/2
                name=designOpts{2*idx-1};
                if strcmp(name,'FilterStructure')
                    name="Structure";
                    val=designOpts{2*idx};
                    fdesObj.(name)=convertStructure(fdesObj,val);
                elseif strcmp(name,'PassbandOffset')
                    data=struct;
                    val=designOpts{2*idx};
                    data.Value=val(1);
                    updateModel(this,'PassbandOffset1',data);
                    data.Value=val(2);
                    updateModel(this,'PassbandOffset2',data);
                else
                    val=designOpts{2*idx};
                    if islogical(val)
                        fdesObj.(name)=val;
                    else
                        fdesObj.(name)=ensureString(this,val);
                    end
                end
            end
        end

        function restriction=getOrderRestriction(this)

            fdesObj=this.pFilterDesignerObj;
            restriction='none';
            freqConstraints=fdesObj.FrequencyConstraints;
            magConstraints=fdesObj.MagnitudeConstraints;

            if(strcmp(freqConstraints,'Passband and stopband edges')&&...
                strcmp(magConstraints,'Unconstrained'))||...
                (strcmp(freqConstraints,'6dB points')&&...
                strcmp(magConstraints,'Passband ripples and stopband attenuation'))
                restriction='even';
            end
        end
    end
end

