classdef(Abstract)BaseConstrainedResponseModel<signal.task.internal.designfilt.responsemodels.BaseResponseModel



    properties(Access=protected,Transient)
        FrequencyPropertiesList=["Fpass","Fstop","F3dB","F6dB",...
        "Fpass1","Fstop1","F3dB1","F6dB1","Fpass2","Fstop2","F3dB2","F6dB2",...
        "TransitionWidth"];
    end

    methods
        function updateModel(this,whatChanged,evtData)

            fdesObj=this.pFilterDesignerObj;
            switch whatChanged
            case{'OrderMode','SpecifyDenominator',...
                'FrequencyConstraints',...
                'MagnitudeConstraints',...
                'DesignMethod'}
                fdesObj.(whatChanged)=evtData.Value;
                correctOrder(this);
            case{'Order','DenominatorOrder'}
                fdesObj.(whatChanged)=ensureString(this,evtData.Value);
                correctOrder(this);
            case{'FrequencyUnits'}




                val=evtData.Value;

                if~(strcmp(fdesObj.FrequencyUnits,'Hz')&&strcmp(val,'normalized')||...
                    strcmp(fdesObj.FrequencyUnits,'Normalized (0 to 1)')&&strcmp(val,'Hz'))
                    return;
                end

                oldFs=this.pPreviousSampleRateValue;

                if strcmp(val,'normalized')
                    newFs=2;
                else
                    newFs=this.pSampleRateValue;
                end
                if~isempty(newFs)
                    scaleFrequencyValues(this,newFs,oldFs);
                    this.pPreviousSampleRateValue=newFs;
                end
                fdesObj.(whatChanged)=val;

            case{'InputSampleRate'}
                oldFs=this.pPreviousSampleRateValue;


                if(isprop(evtData,'Edited')||isfield(evtData,'Edited'))&&evtData.Edited
                    this.pSampleRateSource='value';
                else
                    this.pSampleRateSource='workspaceVariable';
                end
                this.pSampleRateName=evtData.Source.Value;
                this.pSampleRateValue=evtData.Source.WorkspaceValue;
                if~isempty(this.pSampleRateValue)
                    fdesObj.InputSampleRate=ensureString(this,this.pSampleRateValue);




                    newFs=this.pSampleRateValue;
                    this.pPreviousSampleRateValue=newFs;
                    scaleFrequencyValues(this,newFs,oldFs);
                end
            case{'F1','F2','F3','F4'}
                updateFrequencyValues(this,whatChanged,evtData);
            case{'Mag1','Mag2','Mag3','Mag4'}
                updateMagnitudeValues(this,whatChanged,evtData);
            case{'Window','WindowParameter'}
                updateDesignOptionValues(this,whatChanged,evtData);
            otherwise
                if islogical(fdesObj.(whatChanged))
                    fdesObj.(whatChanged)=evtData.Value;
                else
                    fdesObj.(whatChanged)=ensureString(this,evtData.Value);
                end
            end
        end

        function viewSettings=getViewSettings(this,whatChanged,~)

            viewSettings=struct;
            switch whatChanged
            case{'response','OrderMode','Order','SpecifyDenominator','FrequencyConstraints'}


                viewSettings.specificationSettings=getSpecificationsSettings(this);
                viewSettings.frequencyConstraintsSettings=getFrequencyConstraintsSettings(this);
                viewSettings.magnitudeConstraintsSettings=getMagnitudeConstraintsSettings(this);
                viewSettings.algorithmSettings=getAlgorithmSettings(this);
                viewSettings.algorithmSettings.DesignOptionsUpdateOnly=false;
            case{'FrequencyUnits','InputSampleRate','F1','F2','F3','F4'}
                viewSettings.frequencyConstraintsSettings=getFrequencyConstraintsSettings(this);
            case 'MagnitudeConstraints'


                viewSettings.specificationSettings=getSpecificationsSettings(this);
                viewSettings.magnitudeConstraintsSettings=getMagnitudeConstraintsSettings(this);
                viewSettings.algorithmSettings=getAlgorithmSettings(this);
                viewSettings.algorithmSettings.DesignOptionsUpdateOnly=false;
            case{'DesignMethod'}
                viewSettings.algorithmSettings=getAlgorithmSettings(this);
                viewSettings.algorithmSettings.DesignOptionsUpdateOnly=false;
            case{'Window','WindowParameter'}
                viewSettings.algorithmSettings=getAlgorithmSettings(this);
                viewSettings.algorithmSettings.DesignOptionsUpdateOnly=true;
            end
            viewSettings.whatChanged=whatChanged;
        end

        function setState(this,modelState)


            fdesObj=this.pFilterDesignerObj;


            this.pSampleRateSource=modelState.SampleRateSource;
            this.pSampleRateName=modelState.SampleRateName;
            this.pSampleRateValue=modelState.SampleRateValue;
            this.pPreviousSampleRateValue=modelState.PreviousSampleRateValue;

            this.pKaiserWinPArameter=modelState.KaiserWinPArameter;
            this.pChebWinParameter=modelState.ChebWinParameter;


            propNames={'OrderMode','Order','SpecifyDenominator','DenominatorOrder',...
            'FrequencyConstraints','FrequencyUnits','InputSampleRate',...
            'MagnitudeConstraints','DesignMethod'};
            for idx=1:numel(propNames)
                fdesObj.(propNames{idx})=modelState.(propNames{idx});
            end


            designOpts=modelState.DesignOptions;
            setDesignOptionsState(this,designOpts);
        end

        function modelState=getState(this)

            fdesObj=this.pFilterDesignerObj;


            modelState.SampleRateSource=this.pSampleRateSource;
            modelState.SampleRateName=this.pSampleRateName;
            modelState.SampleRateValue=this.pSampleRateValue;
            modelState.PreviousSampleRateValue=this.pPreviousSampleRateValue;

            modelState.KaiserWinPArameter=this.pKaiserWinPArameter;
            modelState.ChebWinParameter=this.pChebWinParameter;


            propNames={'OrderMode','Order','SpecifyDenominator','DenominatorOrder',...
            'FrequencyConstraints','FrequencyUnits','InputSampleRate',...
            'MagnitudeConstraints','DesignMethod'};
            for idx=1:numel(propNames)
                modelState.(propNames{idx})=fdesObj.(propNames{idx});
            end


            modelState.DesignOptions=getDesignOptions(this);

        end
    end

    methods(Access=protected)

        function freqConstraintsSettings=getFrequencyConstraintsSettings(this)

            fdesObj=this.pFilterDesignerObj;


            freqConstraintsSettings.OrderMode=lower(string(fdesObj.OrderMode));


            freqConstraintsSettings.CurrentFrequencyConstraints=fdesObj.FrequencyConstraints;


            if string(fdesObj.OrderMode)=="Specify"
                validFreqConstraints=string(fdesObj.getValidFreqConstraints);
                freqConstraintSet=string(fdesObj.FrequencyConstraintsSet);
                freqConsttraintEntries=string(fdesObj.FrequencyConstraintsEntries);
                idx=ismember(freqConstraintSet,validFreqConstraints);

                freqConstraintsSettings.PopupItems=freqConsttraintEntries(idx);
                freqConstraintsSettings.PopupItemsData=freqConstraintSet(idx);
                freqConstraintsSettings.PopupValue=fdesObj.FrequencyConstraints;
            end


            fUnits=lower(string(fdesObj.FrequencyUnits));
            if contains(fUnits,'normalized')
                freqConstraintsSettings.FrequencyUnitsValue="normalized";
            else
                freqConstraintsSettings.FrequencyUnitsValue="Hz";
                freqConstraintsSettings.SampleRate=this.pSampleRateName;
                freqConstraintsSettings.SampleRateSource=this.pSampleRateSource;
                freqConstraintsSettings.SampleRateNumericValue=this.pSampleRateValue;
            end


            fValuesSettings=getFrequencyValuesSettings(this);
            freqConstraintsSettings=mergeStructures(freqConstraintsSettings,fValuesSettings);
        end

        function s=getFrequencyValuesSettings(~)

            s=struct;
        end

        function magConstraintsSettings=getMagnitudeConstraintsSettings(this)

            fdesObj=this.pFilterDesignerObj;

            magConstraintsSettings.OrderMode=lower(string(fdesObj.OrderMode));
            magConstraintsSettings.CurrentMagnitudeConstraints=fdesObj.MagnitudeConstraints;

            if string(fdesObj.OrderMode)=="Specify"
                validMagConstraints=string(fdesObj.getValidMagConstraints);
                magConstraintSet=string(fdesObj.MagnitudeConstraintsSet);
                magConsttraintEntries=string(fdesObj.MagnitudeConstraintsEntries);
                idx=ismember(magConstraintSet,validMagConstraints);

                magConstraintsSettings.PopupItems=magConsttraintEntries(idx);
                magConstraintsSettings.PopupItemsData=magConstraintSet(idx);
                magConstraintsSettings.PopupValue=fdesObj.MagnitudeConstraints;
            end


            magValuesSettings=getMagnitudeValuesSettings(this);
            magConstraintsSettings=mergeStructures(magConstraintsSettings,magValuesSettings);
        end

        function s=getMagnitudeValuesSettings(~)

            s=struct;
        end

        function scaleFrequencyValues(this,newFs,oldFs)
            fdesObj=this.pFilterDesignerObj;
            for idx=1:numel(this.FrequencyPropertiesList)
                propName=this.FrequencyPropertiesList{idx};
                if isprop(fdesObj,propName)
                    normalizedF=str2double(fdesObj.(propName))/(oldFs/2);
                    unNormalizedF=normalizedF*(newFs/2);
                    fdesObj.(propName)=ensureString(this,unNormalizedF);
                end
            end
        end

        function updateFrequencyValues(this,whatChanged,evtData)%#ok<INUSL>



            fdesObj=this.pFilterDesignerObj;
            fdesObj.(evtData.Source.UserData)=ensureString(this,evtData.Value);
        end

        function updateMagnitudeValues(this,whatChanged,evtData)%#ok<INUSL>


            fdesObj=this.pFilterDesignerObj;
            fdesObj.(evtData.Source.UserData)=ensureString(this,evtData.Value);
        end

        function correctOrder(this)



            correctFlag=false;
            fdesObj=this.pFilterDesignerObj;
            restriction=getOrderRestriction(this);
            switch restriction
            case 'odd'
                ord=str2double(fdesObj.Order);
                correctFlag=signalwavelet.internal.iseven(ord);
            case 'even'
                ord=str2double(fdesObj.Order);
                correctFlag=signalwavelet.internal.isodd(ord);
            end
            if correctFlag
                if ord==1
                    ord=ord+1;
                else
                    ord=ord-1;
                end
                fdesObj.Order=ensureString(this,ord);
            end
        end
    end
end

function s1=mergeStructures(s1,s2)

    s2Fields=fields(s2);
    for idx=1:numel(s2Fields)
        fieldName=s2Fields{idx};
        s1.(fieldName)=s2.(fieldName);
    end
end

