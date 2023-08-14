classdef(CaseInsensitiveProperties)AbstractDesign<FilterDesignDialog.AbstractEditor


































































































































    properties(AbortSet,SetObservable,GetObservable)

        VariableName='';

        Order='20';

        Factor='2';

        SecondFactor='3';

        MagnitudeUnits='dB';

        Scale(1,1)logical=true;

        ForceLeadingNumerator='on';

        LaunchFixedPointAnalysisWarning=true;

        DialogClosed=false;

        OutputCode='';

        CorrectCodeMode='AddCodeToCommandLine';

        DfiltDesign=false;

        OutputVarName='';

        PropertyNames=[];

        PropertyValues=[];

        PropertyValueNames=[];


        InputProcessing='columnsaschannels';


        RateOption='enforcesinglerate';

        isCoefficientsNameEnabled=false;

        isNumeratorNameEnabled=false;

        isDenominatorNameEnabled=false;

        isScaleValuesNameEnabled=false;

        CoefficientsName='Coeffs';

        NumeratorName='Num';

        DenominatorName='Den';

        ScaleValuesName='g';

        BuildUsingBasicElements(1,1)logical=false;

        UseSymbolicNames(1,1)logical=false;

        OptimizeZeros(1,1)logical=false;

        OptimizeOnes(1,1)logical=false;

        OptimizeNegOnes(1,1)logical=false;

        OptimizeDelays(1,1)logical=false

        OptimizeUnitScaleValues(1,1)logical=false

        FilteringCodegenFlag=false;

        Path='';

        FDesign=[];
    end

    properties(AbortSet,Access=protected)

        isSystemObjectDesignFailed=false;

        LastAppliedFilter=[];

        LastAppliedSpecs=[];

        LastAppliedDesignOpts=[];

        FVTool=[];

        HDLDialog=[];

        HDLObj=[];

        DSPFWIZ=[];

        DesignOptionsCache=[];
    end

    properties(AbortSet,SetAccess=protected)

        OperatingMode='Test';

        LastAppliedState=[];

        LastAppliedImplementationOpts=[];
    end

    properties(AbortSet,Dependent)

        ImpulseResponse;

        OrderMode;



        FilterType;

        InputSampleRate;

        FrequencyUnits;

        Structure;

        DesignMethod;

        SystemObject(1,1)logical;
    end

    properties(AbortSet,SetObservable,Hidden)

        privImpulseResponse='FIR';

        privOrderMode='Minimum';

        privFilterType='Single-rate';

        privInputSampleRate='2';

        privFrequencyUnits='Normalized (0 to 1)';

        privStructure;

        privDesignMethod;

        privSystemObject(1,1)logical=false;
    end

    properties(Constant,Hidden)

        FrequencyUnitsSet={'Normalized (0 to 1)','Hz','kHz','MHz','GHz'};
        FrequencyUnitsEntries={FilterDesignDialog.message('norm'),...
        FilterDesignDialog.message('hz'),...
        FilterDesignDialog.message('khz'),...
        FilterDesignDialog.message('mhz'),...
        FilterDesignDialog.message('ghz')};

        OperatingModeSet={'Test','MATLAB','Simulink','FilterDesigner'};

        ImpulseResponseSet={'FIR','IIR'};
        ImpulseResponseEntries={FilterDesignDialog.message('fir'),...
        FilterDesignDialog.message('iir')};

        OrderModeSet={'Minimum','Specify'};
        OrderModeEntries={FilterDesignDialog.message('Minimum'),...
        FilterDesignDialog.message('Specify')};

        FilterTypeSet={'Single-rate','Decimator',...
        'Interpolator','Sample-rate converter'};
        FilterTypeEntries={FilterDesignDialog.message('Single_rate'),...
        FilterDesignDialog.message('Decimator'),...
        FilterDesignDialog.message('Interpolator'),...
        FilterDesignDialog.message('Sample_rateconverter')};

        MagnitudeUnitsSet={'dB','Linear','Squared'};
        MagnitudeUnitsEntries={FilterDesignDialog.message('dB'),...
        FilterDesignDialog.message('Linear'),...
        FilterDesignDialog.message('Squared')};


        InputProcessingSet={'columnsaschannels','elementsaschannels'};


        RateOptionSet={'enforcesinglerate','allowmultirate'};
    end




    methods
        function set.OperatingMode(obj,value)
            value=validatestring(value,obj.OperatingModeSet,'','OperatingMode');
            obj.OperatingMode=value;
        end

        function set.VariableName(obj,value)
            obj.VariableName=value;
        end

        function value=get.ImpulseResponse(obj)
            value=obj.privImpulseResponse;
        end
        function set.ImpulseResponse(obj,value)
            value=validatestring(value,obj.ImpulseResponseSet,'','ImpulseResponse');
            oldValue=obj.ImpulseResponse;
            if strcmpi(oldValue,value)
                return;
            end
            obj.privImpulseResponse=value;
            set_impulseresponse(obj,oldValue);
        end

        function set.privImpulseResponse(obj,value)
            value=validatestring(value,obj.ImpulseResponseSet,'','privImpulseResponse');
            obj.privImpulseResponse=value;
        end

        function value=get.OrderMode(obj)
            value=obj.privOrderMode;
        end
        function set.OrderMode(obj,value)
            value=validatestring(value,obj.OrderModeSet,'','OrderMode');
            obj.privOrderMode=value;
            set_ordermode(obj);
        end
        function set.privOrderMode(obj,value)
            value=validatestring(value,obj.OrderModeSet,'','privOrderMode');
            obj.privOrderMode=value;
        end

        function value=get.Order(obj)
            value=obj.Order;
        end
        function set.Order(obj,value)
            validateattributes(value,{'char'},{'row'},'','Order');
            obj.Order=value;
        end

        function value=get.FilterType(obj)
            value=obj.privFilterType;
        end
        function set.FilterType(obj,value)



            value=validatestring(value,obj.FilterTypeSet,'','FilterType');
            obj.privFilterType=value;
            set_filtertype(obj);
        end
        function set.privFilterType(obj,value)



            value=validatestring(value,obj.FilterTypeSet,'','privFilterType');
            obj.privFilterType=value;
        end

        function set.Factor(obj,value)

            validateattributes(value,{'char'},{'row'},'','Factor');
            obj.Factor=value;
        end

        function set.SecondFactor(obj,value)

            validateattributes(value,{'char'},{'row'},'','SecondFactor');
            obj.SecondFactor=value;
        end

        function value=get.InputSampleRate(obj)
            value=obj.privInputSampleRate;
        end
        function set.InputSampleRate(obj,value)

            validateattributes(value,{'char'},{'row'},'','InputSampleRate');
            obj.privInputSampleRate=value;
            set_inputsamplerate(obj);
        end
        function set.privInputSampleRate(obj,value)

            validateattributes(value,{'char'},{'row'},'','privInputSampleRate');
            obj.privInputSampleRate=value;
        end

        function value=get.FrequencyUnits(obj)
            value=obj.privFrequencyUnits;
        end
        function set.FrequencyUnits(obj,value)


            value=validatestring(value,obj.FrequencyUnitsSet,'','FrequencyUnits');
            obj.privFrequencyUnits=value;
            set_frequencyunits(obj);
        end
        function set.privFrequencyUnits(obj,value)


            value=validatestring(value,obj.FrequencyUnitsSet,'','privFrequencyUnits');
            obj.privFrequencyUnits=value;

        end

        function set.MagnitudeUnits(obj,value)


            value=validatestring(value,{'dB','Linear','Squared'},'','MagnitudeUnits');
            obj.MagnitudeUnits=value;
        end

        function value=get.Structure(obj)
            value=obj.privStructure;
        end
        function set.Structure(obj,value)

            validateattributes(value,{'char'},{'row'},'','Structure');
            obj.privStructure=value;
            set_structure(obj);
        end
        function set.privStructure(obj,value)

            validateattributes(value,{'char'},{'row'},'','privStructure');
            obj.privStructure=value;
        end

        function value=get.DesignMethod(obj)
            value=obj.privDesignMethod;
        end
        function set.DesignMethod(obj,value)

            validateattributes(value,{'char'},{'row'},'','DesignMethod');
            obj.privDesignMethod=value;
            set_designmethod(obj);
        end
        function set.privDesignMethod(obj,value)

            validateattributes(value,{'char'},{'row'},'','privDesignMethod');
            obj.privDesignMethod=value;
        end

        function set.Scale(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','Scale');
            value=logical(value);
            obj.Scale=value;
        end

        function set.ForceLeadingNumerator(obj,value)

            value=validatestring(value,{'on','off'},'','ForceLeadingNumerator');
            obj.ForceLeadingNumerator=value;
        end

        function value=get.SystemObject(obj)
            value=obj.privSystemObject;
        end
        function set.SystemObject(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','SystemObject');
            value=logical(value);
            obj.privSystemObject=value;
            set_systemobject(obj);
        end
        function set.privSystemObject(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','privSystemObject');
            value=logical(value);
            obj.privSystemObject=value;
        end

        function set.isSystemObjectDesignFailed(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','isSystemObjectDesignFailed');
            value=logical(value);
            obj.isSystemObjectDesignFailed=value;
        end

        function set.LaunchFixedPointAnalysisWarning(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','LaunchFixedPointAnalysisWarning');
            value=logical(value);
            obj.LaunchFixedPointAnalysisWarning=value;
        end

        function set.DialogClosed(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','DialogClosed');
            value=logical(value);
            obj.DialogClosed=value;
        end

        function set.OutputCode(obj,value)

            validateattributes(value,{'char'},{'row'},'','OutputCode');
            obj.OutputCode=value;
        end

        function set.CorrectCodeMode(obj,value)

            validateattributes(value,{'char'},{'row'},'','CorrectCodeMode');
            obj.CorrectCodeMode=value;
        end

        function set.OutputVarName(obj,value)


            obj.OutputVarName=value;
        end

        function set.InputProcessing(obj,value)


            value=validatestring(value,{'columnsaschannels','elementsaschannels'},'','InputProcessing');
            obj.InputProcessing=value;
        end

        function set.RateOption(obj,value)


            value=validatestring(value,{'enforcesinglerate','allowmultirate'},'','RateOption');
            obj.RateOption=value;
        end

        function set.isCoefficientsNameEnabled(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','isCoefficientsNameEnabled');
            value=logical(value);
            obj.isCoefficientsNameEnabled=value;
        end

        function set.isNumeratorNameEnabled(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','isNumeratorNameEnabled');
            value=logical(value);
            obj.isNumeratorNameEnabled=value;
        end

        function set.isDenominatorNameEnabled(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','isDenominatorNameEnabled');
            value=logical(value);
            obj.isDenominatorNameEnabled=value;
        end

        function set.isScaleValuesNameEnabled(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','isScaleValuesNameEnabled');
            value=logical(value);
            obj.isScaleValuesNameEnabled=value;
        end

        function set.CoefficientsName(obj,value)

            validateattributes(value,{'char'},{'row'},'','CoefficientsName');
            obj.CoefficientsName=value;
        end

        function set.NumeratorName(obj,value)

            validateattributes(value,{'char'},{'row'},'','NumeratorName');
            obj.NumeratorName=value;
        end

        function set.DenominatorName(obj,value)

            validateattributes(value,{'char'},{'row'},'','DenominatorName');
            obj.DenominatorName=value;
        end

        function set.ScaleValuesName(obj,value)

            validateattributes(value,{'char'},{'row'},'','ScaleValuesName')
            obj.ScaleValuesName=value;
        end

        function set.BuildUsingBasicElements(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','BuildUsingBasicElements');
            value=logical(value);
            obj.BuildUsingBasicElements=value;
        end

        function set.UseSymbolicNames(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','UseSymbolicNames');
            value=logical(value);
            obj.UseSymbolicNames=value;
        end

        function set.OptimizeZeros(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','OptimizeZeros');
            value=logical(value);
            obj.OptimizeZeros=value;
        end

        function set.OptimizeOnes(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','OptimizeOnes');
            value=logical(value);
            obj.OptimizeOnes=value;
        end

        function set.OptimizeNegOnes(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','OptimizeNegOnes');
            value=logical(value);
            obj.OptimizeNegOnes=value;
        end

        function set.OptimizeDelays(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','OptimizeDelays');
            value=logical(value);
            obj.OptimizeDelays=value;
        end

        function set.OptimizeUnitScaleValues(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','OptimizeUnitScaleValues');
            value=logical(value);
            obj.OptimizeUnitScaleValues=value;
        end

        function set.FilteringCodegenFlag(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','FilteringCodegenFlag');
            value=logical(value);
            obj.FilteringCodegenFlag=value;
        end

        function set.HDLDialog(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','HDLDialog');
            obj.HDLDialog=value;
        end

        function set.HDLObj(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','HDLObj');
            obj.HDLObj=value;
        end

        function set.DSPFWIZ(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','DSPFWIZ');
            obj.DSPFWIZ=value;
        end

    end



    methods

        function abstract_setGUI(this,Hd)



            hfdesign=getfdesign(Hd);
            hfmethod=getfmethod(Hd);

            if isFilterDesignerMode(this)
                changeNumBandsFlag=false;


                if isa(this,'FilterDesignDialog.ArbMagDesign')&&strcmp(hfdesign.Specification,'N,B,F,A')
                    idx=strcmp(this.PropertyNames,'NumBands');
                    if any(idx)&&~isempty(this.PropertyValues{idx})
                        nb=str2double(this.PropertyValues{idx});
                        if hfdesign.NBands~=nb
                            hfdesign.NBands=nb;
                            this.NumberOfBands=nb-1;
                            changeNumBandsFlag=true;
                        end
                    end
                end
            end

            spec=hfdesign.Specification;



            if isfir(hfmethod)
                this.ImpulseResponse='FIR';
            else
                this.ImpulseResponse='IIR';
            end


            if strncmp(spec,'Nb,',3)
                Nb=get(hfdesign,'NumOrder');
                Na=get(hfdesign,'DenOrder');
                if isprop(this,'DenominatorOrder')&&isprop(this,'SpecifyDenominator')
                    this.SpecifyDenominator=true;
                    this.OrderMode='specify';
                    this.Order=num2str(Nb);
                    this.DenominatorOrder=num2str(Na);
                elseif Nb==Na
                    this.OrderMode='specify';
                    this.Order=num2str(Nb);
                else
                    error(message('FilterDesignLib:filterbuilder:CannotImport'));
                end

            elseif strncmp(spec,'N,',2)||isequal(spec,'N')
                this.OrderMode='specify';
                this.Order=num2str(hfdesign.FilterOrder);
            else
                this.OrderMode='minimum';
            end

            if isa(hfdesign,'fdesign.decimator')
                this.FilterType='decimator';
                this.Factor=num2str(hfdesign.DecimationFactor);
            elseif isa(hfdesign,'fdesign.interpolator')
                this.FilterType='interpolator';
                this.Factor=num2str(hfdesign.InterpolationFactor);
            elseif isa(hfdesign,'fdesign.rsrc')
                this.FilterType='sample-rate converter';
                this.Factor=num2str(hfdesign.InterpolationFactor);
                this.SecondFactor=num2str(hfdesign.DecimationFactor);

            end

            if hfdesign.NormalizedFrequency
                this.FrequencyUnits='normalized';
            else


                fs=hfdesign.Fs;
                this.FrequencyUnits='Hz';
                this.InputSampleRate=num2str(fs);
            end




            if isFilterDesignerMode(this)
                if changeNumBandsFlag
                    setSpecificationsFromPropertyValues(this,hfdesign);
                else
                    setSpecificationsFromPropertyValues(this,Hd);
                end
            end


            set(this,'DesignMethod',matchCase(get(hfmethod,'DesignAlgorithm'),...
            getValidMethods(this)));

            updateDesignOptions(this);

            if isFilterDesignerMode(this)
                dopts=designopts(hfdesign,this.getSimpleMethod,'signalonly');
            else
                dopts=designopts(hfdesign,this.getSimpleMethod);
            end

            if isfield(dopts,'SystemObject')
                dopts=rmfield(dopts,'SystemObject');
            end

            if isfield(dopts,'MinPhase')&&isfield(dopts,'MaxPhase')
                if hfmethod.MinPhase
                    this.PhaseConstraint='Minimum';
                elseif hfmethod.MaxPhase
                    this.PhaseConstraint='Maximum';
                else
                    this.PhaseConstraint='Linear';
                end
                dopts=rmfield(dopts,{'MinPhase','MaxPhase'});
            end




            if strcmpi(hfmethod.DesignAlgorithm,'multistage equiripple')||...
                any(strcmpi(hfmethod.FilterStructure,{'cascadeallpass','cascadewdfallpass'}))
                cls=hfmethod.FilterStructure;
            else
                cls=getClassName(Hd);
            end
            structure=convertStructure(this,cls);
            this.Structure=structure;


            fn=setdiff(fieldnames(dopts),...
            {'FilterStructure','DesignAlgorithm','SOSScaleNorm','SOSScaleOpts','Window'});
            for indx=1:length(fn)
                value=[];
                if isprop(hfmethod,fn{indx})
                    value=hfmethod.(fn{indx});
                end
                if~isempty(value)
                    if isnumeric(value)&&~islogical(value)
                        value=num2str(value);
                        if isempty(value)
                            value='[]';
                        end
                    elseif isa(value,'function_handle')
                        value=func2str(value);
                    elseif iscell(value)

                        if isa(value{1},'function_handle')
                            value{1}=func2str(value{1});
                        end

                        if length(value)>1
                            if isnumeric(value{2})
                                value{2}=mat2str(value{2});
                            end

                            value=sprintf('{''%s'', %s}',value{:});
                        else
                            value=sprintf('{''%s''}',value{1});
                        end
                    elseif ischar(value)
                        value(1)=upper(value(1));
                    end
                    if isprop(this,fn{indx})
                        set(this,fn{indx},value);
                    end
                end
            end


            if isfield(dopts,'Window')
                value=hfmethod.Window;
                if ischar(value)
                    value=mat2str(value);
                elseif iscell(value)
                    if ischar(value{1})
                        fcn=sprintf('{%s',mat2str(value{1}));
                    else
                        fcn=sprintf('{%s',lclFuncToStr(value{1}));
                    end
                    for indx=2:length(value)
                        fcn=sprintf('%s, %s',fcn,mat2str(value{indx}));
                    end
                    fcn=sprintf('%s}',fcn);
                    value=fcn;
                elseif isempty(value)
                    value='';
                else

                    value=lclFuncToStr(value);
                end
                set(this,'Window',value);
            end


            if isFilterDesignerMode(this)
                fn=setdiff(fieldnames(dopts),...
                {'FilterStructure','DesignAlgorithm','SOSScaleNorm','SOSScaleOpts'});

                for indx=1:length(fn)
                    desOpt=signal.internal.DesignfiltProcessCheck.convertdesignoptnames(fn{indx},'fdesignToDesignfilt');
                    pIdx=strcmpi(this.PropertyNames,desOpt);
                    if any(pIdx)
                        if~isempty(this.PropertyValueNames{pIdx})
                            value=this.PropertyValueNames{pIdx};


                            if any(strcmp(desOpt,{'ScalePassband','ZeroPhase'}))
                                value=this.PropertyValues{pIdx};
                                if ischar(value)
                                    value=strcmp(value,'true');
                                end
                            end



                            if strcmp(desOpt,'MatchExactly')
                                if strcmpi(value,'stopband')
                                    value='Stopband';
                                elseif strcmpi(value,'passband')
                                    value='Passband';
                                elseif strcmpi(value,'both')
                                    value='Both';
                                end
                            end
                        else
                            value=this.PropertyValues{pIdx};
                        end
                        if isprop(this,fn{indx})&&~isempty(value)
                            set(this,fn{indx},value);
                        end
                    end
                end
            end

            if isfield(dopts,'SOSScaleNorm')&&isempty(hfmethod.SOSScaleNorm)
                this.Scale=false;
            end

            if isfield(dopts,'SOSScaleOpts')&&isempty(hfmethod.SOSScaleOpts)
                this.Scale=false;
            end


            if~isempty(this.FixedPoint)
                if isa(Hd,'dsp.internal.FilterAnalysis')
                    this.FixedPoint.SystemObject=true;
                end
                updateSettings(this.FixedPoint,Hd);
            end

            this.LastAppliedFilter=Hd;
            this.LastAppliedState=this;
        end


        function addSetSpecificationLines(this,variables,values,hBuffer)%#ok<*INUSD>






        end


        function captureState(this)



            laState=getState(this);

            set(this,'LastAppliedState',laState);

            if~isempty(this.FixedPoint)
                captureState(this.FixedPoint);
            end


        end


        function close(this)

            this.DialogClosed=true;
        end


        function longstruct=convertStructure(this,shortstruct)

            if nargin<2
                shortstruct=this.Structure;
            end

            switch lower(shortstruct)
            case 'iirdecim'
                longstruct='IIR polyphase decimator';
            case 'iirinterp'
                longstruct='IIR polyphase interpolator';
            case 'firdecim'
                longstruct='Direct-form FIR polyphase decimator';
            case 'firinterp'
                longstruct='Direct-form FIR polyphase interpolator';
            case 'firtdecim'
                longstruct='Direct-form transposed FIR polyphase decimator';
            case 'fftfirinterp'
                longstruct='Overlap-add FIR polyphase interpolator';
            case 'dffir'
                longstruct='Direct-form FIR';
            case 'dffirt'
                longstruct='Direct-form FIR transposed';
            case 'dfsymfir'
                longstruct='Direct-form symmetric FIR';
            case 'dfasymfir'
                longstruct='Direct-form antisymmetric FIR';
            case 'df1'
                longstruct='Direct-form I';
            case 'df2'
                longstruct='Direct-form II';
            case 'df1t'
                longstruct='Direct-form I transposed';
            case 'df2t'
                longstruct='Direct-form II transposed';
            case 'df1sos'
                longstruct='Direct-form I SOS';
            case 'df2sos'
                longstruct='Direct-form II SOS';
            case 'df1tsos'
                longstruct='Direct-form I transposed SOS';
            case 'df2tsos'
                longstruct='Direct-form II transposed SOS';
            case 'fftfir'
                longstruct='Overlap-add FIR';
            case 'cascadeallpass'
                longstruct='Cascade minimum-multiplier allpass';
            case 'cascade minimum-multiplier allpass'
                longstruct='cascadeallpass';
            case 'cascadewdfallpass'
                longstruct='Cascade wave digital filter allpass';
            case 'cascade wave digital filter allpass'
                longstruct='cascadewdfallpass';
            case 'iirwdfdecim'
                longstruct='IIR wave digital filter polyphase decimator';
            case 'iir wave digital filter polyphase decimator'
                longstruct='iirwdfdecim';
            case 'iirwdfinterp'
                longstruct='IIR wave digital filter polyphase interpolator';
            case 'iir wave digital filter polyphase interpolator'
                longstruct='iirwdfinterp';
            case 'direct-form fir polyphase decimator'
                longstruct='firdecim';
            case 'direct-form fir polyphase interpolator'
                longstruct='firinterp';
            case 'direct-form transposed fir polyphase decimator'
                longstruct='firtdecim';
            case 'overlap-add fir polyphase interpolator'
                longstruct='fftfirinterp';
            case 'iir polyphase decimator'
                longstruct='iirdecim';
            case 'iir polyphase interpolator'
                longstruct='iirinterp';
            case 'direct-form fir'
                longstruct='dffir';
            case 'direct-form fir transposed'
                longstruct='dffirt';
            case 'direct-form symmetric fir'
                longstruct='dfsymfir';
            case 'direct-form antisymmetric fir'
                longstruct='dfasymfir';
            case 'direct-form i'
                longstruct='df1';
            case 'direct-form ii'
                longstruct='df2';
            case 'direct-form i transposed'
                longstruct='df1t';
            case 'direct-form ii transposed'
                longstruct='df2t';
            case 'direct-form i sos'
                longstruct='df1sos';
            case 'direct-form ii sos'
                longstruct='df2sos';
            case 'direct-form i transposed sos'
                longstruct='df1tsos';
            case 'direct-form ii transposed sos'
                longstruct='df2tsos';
            case 'overlap-add fir'
                longstruct='fftfir';
            case{'cicdecim','cicinterp'}
                longstruct=shortstruct;
            case 'fd'
                longstruct='Fractional delay';
            case 'fractional delay'
                longstruct='farrowfd';
            case 'farrowfd'
                longstruct='Farrow fractional delay';
            case 'farrow fractional delay'
                longstruct='farrowfd';
            case 'firsrc'
                longstruct='Direct-form FIR polyphase sample-rate converter';
            case 'direct-form fir polyphase sample-rate converter'
                longstruct='firsrc';
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:AbstractDesign:convertStructure:InternalError',shortstruct));
            end


        end


        function[Hd,same]=design(this)



            same=false;




            laState=this.LastAppliedState;

            if isempty(laState)
                captureState(this);
                laState=this.LastAppliedState;
            end



            specs=getSpecs(this,laState);
            oldSpecs=this.LastAppliedSpecs;


            designOpts=getDesignOptions(this,laState);
            oldDesignOpts=this.LastAppliedDesignOpts;

            oldDesignOpts=fixupOldDesignOpts(oldDesignOpts);



            if isequal(specs,oldSpecs)&&isequal(designOpts,oldDesignOpts)


                same=true;

                Hd=this.LastAppliedFilter;



                if~isempty(Hd)
                    if~isempty(this.FixedPoint)
                        applySettings(this.FixedPoint,Hd);
                    end
                    return;
                end
            end

            this.LastAppliedSpecs=specs;
            this.LastAppliedDesignOpts=designOpts;

            [hfdesign,b,msg]=getFDesign(this,laState);


            if~b
                error(message('FilterDesignLib:FilterDesignDialog:AbstractDesign:design:designFailed',msg));
            end


            method=getSimpleMethod(this,laState);



            wSignal=warning('off','signal:fdesign:basecatalog:UseSystemObjectForMultirateDesigns');
            restoreWarnSignal=onCleanup(@()warning(wSignal));
            wDsp=warning('off','dsp:fdesign:basecatalog:UseSystemObjectForMultirateDesigns');
            restoreWarnDsp=onCleanup(@()warning(wDsp));
            wMultistage=warning('off','dsp:fdesign:basecatalog:UseFunctionForMultistageDesigns');
            restoreWarnMultistage=onCleanup(@()warning(wMultistage));

            if isFilterDesignerMode(this)

                cs=getcurrentspecs(hfdesign);
                if isprop(cs,'FromFilterDesigner')
                    cs.FromFilterDesigner=true;
                end
            end



            setSystemObjectDesignFailed(this,false);
            if isSystemObjectDesign(this)



                try
                    Hd=design(hfdesign,method,designOpts{:},SystemObject=true,UseLegacyBiquadFilter=true);
                catch err
                    if strcmp(err.identifier,'signal:dfilt:basecatalog:SysobjNotSupported')...
                        &&isSystemObjectMandatory(this)


                        setSystemObjectDesignFailed(this,true);
                    elseif strcmp(err.identifier,'signal:dfilt:basecatalog:SysobjNotSupported')...
                        &&isa(Hd,'dfilt.parallel')
                        error(message('FilterDesignLib:FilterDesignDialog:AbstractDesign:design:parallelSystemObject'));
                    else
                        throw(err);
                    end
                end
            else




                allowLegacyFilt=strcmpi(this.OperatingMode,'Simulink')||isSystemObjectMandatory(this);
                Hd=design(hfdesign,method,designOpts{:},...
                AllowLegacyFilters=allowLegacyFilt,...
                UseLegacyBiquadFilter=true);
            end

            if~isempty(this.FixedPoint)
                applySettings(this.FixedPoint,Hd);
            end

            this.LastAppliedFilter=Hd;
        end


        function[value,errMsg]=evaluateVariable(~,value)


            errMsg='';
            value=evaluatevars(value);

        end


        function export(this,hdlg,method,warnflag,warnstr,varargin)







            if this.FilteringCodegenFlag&&strcmp(method,'mcode')
                method='mcodefiltering';
            end
            fileName='';

            if isa(hdlg,'DAStudio.Dialog')



                if warnflag==true&&lclHasUnappliedChanges(this,hdlg)

                    yes=FilterDesignDialog.message('Yes');
                    no=FilterDesignDialog.message('No');
                    cancel=FilterDesignDialog.message('Cancel');
                    qOptions={yes,no,cancel};
                    unappliedchanges=FilterDesignDialog.message('UnappliedChanges');
                    Hd=this.LastAppliedFilter;

                    if isSystemObjectDesign(this)&&...
                        any(strcmp({'mcode','mcodefiltering'},method))
                        if~isa(Hd,'dsp.internal.FilterAnalysis')
                            unappliedchanges=FilterDesignDialog.message('MustBeASystemObject');
                            qOptions(2)=[];
                        end
                    elseif~isSystemObjectDesign(this)&&...
                        isa(Hd,'dsp.internal.FilterAnalysis')&&...
                        any(strcmp({'hdl','mcode','mcodefiltering','block'},method))
                        unappliedchanges=FilterDesignDialog.message('MustBeADFILTObject');
                        qOptions(2)=[];
                    end

                    question=sprintf(unappliedchanges,warnstr);
                    choice=questdlg(question,getDialogTitle(this),qOptions{:},yes);

                    switch choice
                    case yes
                        hdlg.apply;
                    case{cancel,[]}
                        return;
                    end
                end
            elseif~isempty(varargin)
                fileName=varargin{1};
            end


            if isempty(fileName)

                feval(method,this);%#ok<FVAL>
            else
                feval(method,this,fileName);%#ok<FVAL>
            end
        end


        function inputs=formatCodeInfo(~,inputs)









        end


        function inputs=formatConstructorInputs(~,inputs)









        end


        function generateModel(h,hBlk,Hd)







            blkName='Generated Filter Block';
            sysName=sprintf('%s/%s',get(hBlk,'Path'),get(hBlk,'Name'));


            w=warning('off');

            try
                if isa(Hd,'dfilt.abstractsos')
                    if h.OptimizeUnitScaleValues
                        set(Hd,'OptimizeScaleValues',true);
                    else
                        set(Hd,'OptimizeScaleValues',false);
                    end
                end



                buildusingbasicblocks=h.BuildUsingBasicElements;
                usesymbolicnames=h.UseSymbolicNames;

                if h.isCoefficientsNameEnabled
                    coeffNames={h.CoefficientsName};
                else
                    if h.isNumeratorNameEnabled
                        coeffNames={h.NumeratorName};
                    end
                    if h.isDenominatorNameEnabled
                        coeffNames=[coeffNames,{h.DenominatorName}];
                    end
                    if h.isScaleValuesNameEnabled
                        coeffNames=[coeffNames,{h.ScaleValuesName}];
                    end
                end

                try
                    if buildusingbasicblocks
                        if usesymbolicnames
                            realizemdl(Hd,'OverwriteBlock','on',...
                            'OptimizeZeros',h.OptimizeZeros,...
                            'OptimizeOnes',h.OptimizeOnes,...
                            'OptimizeDelayChains',h.OptimizeDelays,...
                            'OptimizeNegOnes',h.OptimizeNegOnes,...
                            'MapCoeffsToPorts','on',...
                            'CoeffNames',coeffNames,...
                            'Destination',sysName,...
                            'BlockName',blkName,...
                            'InputProcessing',h.InputProcessing,...
                            'RateOption',h.RateOption);
                        else

                            realizemdl(Hd,'OverwriteBlock','on',...
                            'OptimizeZeros',h.OptimizeZeros,...
                            'OptimizeOnes',h.OptimizeOnes,...
                            'OptimizeDelayChains',h.OptimizeDelays,...
                            'OptimizeNegOnes',h.OptimizeNegOnes,...
                            'Destination',sysName,...
                            'BlockName',blkName,...
                            'InputProcessing',h.InputProcessing,...
                            'RateOption',h.RateOption);
                        end
                    elseif usesymbolicnames
                        block(Hd,'OverwriteBlock','on',...
                        'MapCoeffsToPorts','on',...
                        'CoeffNames',coeffNames,...
                        'Destination',sysName,...
                        'BlockName',blkName,...
                        'InputProcessing',h.InputProcessing,...
                        'RateOption',h.RateOption);
                    else
                        block(Hd,'OverwriteBlock','on',...
                        'Destination',sysName,...
                        'BlockName',blkName,...
                        'InputProcessing',h.InputProcessing,...
                        'RateOption',h.RateOption);
                    end

                    impl=getImplementationOptions(h);
                    set(h,'LastAppliedImplementationOpts',impl);

                catch e1
                    warning(w);
                    rethrow(e1);
                end

                warning(w);
            catch eb
                rethrow(eb);
            end

        end


        function items=getBottomWidgets(this,startrow,items)



            if nargin<3
                items={};
                if nargin<2
                    startrow=1;
                end
            end

            if any(strcmpi({'matlab','filterdesigner'},this.OperatingMode))
                varname.Type='edit';
                varname.RowSpan=[startrow,startrow];
                varname.ColSpan=[1,1];
                varname.ObjectProperty='VariableName';
                varname.Tag='VariableName';
                varname.Source=this;
                varname.Mode=true;
                varname.Enabled=true;

                if strcmpi('matlab',this.OperatingMode)
                    varname.Name=FilterDesignDialog.message('SaveVariableAs');
                else
                    varname.Name=FilterDesignDialog.message('FilterDesignAssistantOutputVar');
                end

                varname.Visible=true;

                if isFilterDesignerMode(this)
                    if strcmp(this.CorrectCodeMode,'EditDigitalFilter')
                        varname.Visible=isempty(this.OutputVarName);
                    elseif~strcmpi(this.CorrectCodeMode,'AddCodeToCommandLine')


                        varname.Visible=false;
                    end
                end

                items={items{:},varname};%#ok<CCAT>
            end

            if supportsAnalysis(this)&&~isFilterDesignerMode(this)
                fvtool.Type='pushbutton';
                fvtool.Name=FilterDesignDialog.message('ViewFilterResponse');
                fvtool.RowSpan=[startrow,startrow];
                fvtool.ColSpan=[3,3];
                fvtool.ObjectMethod='export';
                fvtool.Tag='fvtool';
                fvtool.MethodArgs={'%dialog','launchfvtool',true,FilterDesignDialog.message('VisualizingTheDesign'),''};
                fvtool.ArgDataTypes={'handle','string','bool','string','string'};
                fvtool.Source=this;
                fvtool.ToolTip=FilterDesignDialog.message('LaunchFVTOOLToolTipTxt');
                fvtool.Enabled=true;

                items={items{:},fvtool};%#ok<CCAT>
            end


        end


        function design=getDesignMethodFrame(this)



            row=[1,1];

            tunable=~isminorder(this)&&this.BuildUsingBasicElements;


            [method_lbl,method]=getWidgetSchema(this,'DesignMethod',...
            FilterDesignDialog.message('designmethod'),...
            'combobox',row,1);

            method_lbl.Tunable=tunable;
            method.Tunable=tunable;


            method.Entries=FilterDesignDialog.message(getValidMethods(this,'short'));

            validMethods=getValidMethods(this);

            indx=find(strcmp(validMethods,this.DesignMethod));
            if~isempty(indx)
                method.Value=indx-1;
            end

            method.ObjectMethod='selectComboboxEntry';
            method.MethodArgs={'%dialog','%value','DesignMethod',validMethods};
            method.ArgDataTypes={'handle','mxArray','string','mxArray'};
            method.Mode=true;
            method.DialogRefresh=true;



            method=rmfield(method,'ObjectProperty');

            items={method_lbl,method};


            if any(strcmpi(this.Structure,{'direct-form i sos','direct-form ii sos',...
                'direct-form i transposed sos','direct-form ii transposed sos'}))
                if isDSTMode(this)

                    row=row+1;

                    scale.Name=FilterDesignDialog.message('scalesos');
                    scale.Type='checkbox';
                    scale.Source=this;
                    scale.ObjectProperty='Scale';
                    scale.Mode=true;
                    scale.Tag='Scale';
                    scale.RowSpan=[row,row];
                    scale.ColSpan=[1,2];
                    scale.Enabled=true;

                    scale.Mode=false;
                    scale.ObjectMethod='setCheckboxValue';
                    scale.MethodArgs={'Scale','%value'};
                    scale.ArgDataTypes={'string','bool'};

                    items={items{:},scale};%#ok<CCAT>
                end
            end

            options=getOptions(this,row(1)+1);

            if~isempty(options)
                items={items{:},options};%#ok<CCAT>
            end

            design.Type='group';
            design.Name=FilterDesignDialog.message('algorithm');
            design.Items=items;
            design.LayoutGrid=[4,2];
            design.ColStretch=[0,1];
            design.RowStretch=[0,0,0,1];
            design.Tag='DesignMethodGroup';
        end


        function designOptions=getDesignOptions(this,varargin)





            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            if numel(varargin)<2
                evaluateValsFlag=true;
            else
                evaluateValsFlag=varargin{2};
            end

            designOptions={};



            hFDesign=getFDesign(this,source);
            if isempty(hFDesign)
                return;
            end


            methodEntries=getValidMethods(this,'short');
            method=getSimpleMethod(this,source);
            if~any(strcmpi(method,methodEntries))
                return
            end

            optstruct=thisDesignOptions(this,hFDesign,method);


            optDefaults=optstruct;

            optstruct=rmfield(optstruct,{'FilterStructure','DefaultFilterStructure'});

            if isfield(optstruct,'SOSScaleOpts')
                optstruct=rmfield(optstruct,{'SOSScaleOpts','DefaultSOSScaleOpts'});
            end
            isSOSScale=false;
            if isfield(optstruct,'SOSScaleNorm')
                isSOSScale=true;
                optstruct=rmfield(optstruct,{'SOSScaleNorm','DefaultSOSScaleNorm'});
            end
            isminmaxphase=false;
            if isfield(optstruct,'MinPhase')&&isfield(optstruct,'MaxPhase')
                isminmaxphase=true;
                optstruct=rmfield(optstruct,{'MinPhase','MaxPhase'});
                optstruct=rmfield(optstruct,{'DefaultMinPhase','DefaultMaxPhase'});
            end

            isuniformgrid=false;
            if isfield(optstruct,'UniformGrid')
                isuniformgrid=true;
                optstruct=rmfield(optstruct,{'UniformGrid','DefaultUniformGrid'});
            end

            isdecay=false;
            if isfield(optstruct,'StopbandDecay')
                isdecay=true;
                optstruct=rmfield(optstruct,{'StopbandDecay','DefaultStopbandDecay'});
            end

            fn=fieldnames(optstruct);


            indx=find(strcmpi(fn,'FilterStructure'));
            fn([indx,indx+length(fn)/2])=[];

            designOptions=cell(1,length(fn)+2);

            fstruct=source.Structure;

            designOptions(1:2)={'FilterStructure',convertStructure(this,fstruct)};

            for indx=1:length(fn)/2

                designOptions{2*indx+1}=fn{indx};

                if(isstruct(source)&&isfield(source,fn{indx}))||...
                    (isa(source,'FilterDesignDialog.AbstractDesign')...
                    &&isprop(source,fn{indx}))
                    value=source.(fn{indx});
                else



                    key=strcat('Default',fn{indx});
                    value=optDefaults.(key);
                end

                vvals=optstruct.(fn{indx});
                if~iscell(vvals)&&any(strcmp(vvals,...
                    {'int','double','posdouble','double_vector'}))&&...
                    ~any(strcmp(class(value),{'int','double','posdouble','double_vector'}))
                    if evaluateValsFlag
                        value=evaluatevars(value);
                    end
                elseif~isstring(vvals)&&~iscellstr(vvals)&&any(strcmpi(vvals,{'mxArray','MATLAB array'}))&&evaluateValsFlag

                    try




                        tempvalue=evaluatevars(value);
                        if isnumeric(tempvalue)
                            value=tempvalue;
                        end
                    catch ME %#ok<NASGU>

                        try
                            value=evalin('base',value);
                        catch ME %#ok<NASGU>

                        end
                    end
                elseif strcmpi(fn{indx},'halfbanddesignmethod')
                    value=getSimpleMethod(this,struct('DesignMethod',value));
                end

                designOptions{2*indx+2}=value;
            end

            if isminmaxphase
                if strcmpi(this.PhaseConstraint,'Minimum')
                    designOptions{2*indx+3}='MinPhase';
                    designOptions{2*indx+4}=true;
                end
                if strcmpi(this.PhaseConstraint,'Maximum')
                    designOptions{2*indx+3}='MaxPhase';
                    designOptions{2*indx+4}=true;
                end
            end

            if isuniformgrid&&...
                (~isfield(optstruct,'MinOrder')||strcmp(this.MinOrder,'Any'))&&...
                (~isfield(optstruct,'StopbandShape')||strcmp(this.StopbandShape,'Flat'))&&...
                (~isminmaxphase||strcmp(this.PhaseConstraint,'Linear'))
                designOptions=[designOptions,{'UniformGrid',this.UniformGrid}];
            end

            if isdecay&&~strcmp(this.StopbandShape,'Flat')
                designOptions=[designOptions,{'StopbandDecay',evalin('base',this.StopbandDecay)}];
            end

            if any(strcmpi(convertStructure(this),...
                {'df1sos','df1tsos','df2sos','df2tsos'}))
                if isDSTMode(this)
                    if this.Scale&&isSOSScale
                        designOptions=[designOptions,{'SOSScaleNorm','Linf'}];
                    else
                        designOptions=[designOptions,{'SOSScaleNorm',''}];
                    end
                end
            end

        end


        function dlg=getDialogSchema(this,mode)




            helpframe=getHelpFrame(this);
            helpframe.RowSpan=[1,1];
            helpframe.ColSpan=[1,3];

            main=getMainFrame(this);

            if(strcmpi(this.OperatingMode,'simulink')&&~supportsSLFixedPoint(this))...
                ||isFilterDesignerMode(this)

                main.RowSpan=[3,3];
                main.ColSpan=[1,3];
                items=getBottomWidgets(this,2,{helpframe,main});
            else
                if isDSTMode(this)
                    fixpt=getFixedPointTab(this);
                end

                maintab.Items={main};
                maintab.Name=FilterDesignDialog.message('MainTabName');
                maintab.Tag='MainTab';

                if strcmpi(this.OperatingMode,'simulink')
                    items={maintab,fixpt};
                else
                    codegen=getCodeGenTab(this);
                    if isDSTMode(this)
                        items={maintab,fixpt,codegen};
                    else
                        items={maintab,codegen};
                    end
                end

                tab.Type='tab';
                tab.Tabs=items;
                tab.RowSpan=[3,3];
                tab.ColSpan=[1,3];
                tab.Tag='TabPanel';
                tab.ActiveTab=this.ActiveTab;
                tab.TabChangedCallback='FilterDesignDialog.TabChangedCallback';

                items=getBottomWidgets(this,2,{helpframe,tab});
            end

            if isFilterDesignerMode(this)
                dlg.DialogTitle=FilterDesignDialog.message('FilterDesignAssistantTitle');
            else
                dlg.DialogTitle=getDialogTitle(this);
            end
            dlg.DisplayIcon='toolbox\shared\dastudio\resources\MatlabIcon.png';
            dlg.Items=items;
            dlg.LayoutGrid=[5,3];
            dlg.RowStretch=[0,0,0,0,3];
            dlg.ColStretch=[2,1,0];
            dlg.PreApplyMethod='preApply';
            dlg.PostApplyMethod='postApply';
            dlg.CloseMethod='close';
            dlg.HelpMethod='eval';
            dlg.HelpArgs={'doc(''Filter Builder'');'};

            if isFilterDesignerMode(this)
                dlg.StandaloneButtonSet={'Ok','Cancel','Help'};
                dlg.HelpArgs={'doc(''designfilt'');'};
            end
        end


        function s=getDisplayIcon(~)




            s='\toolbox\shared\dastudio\resources\MatlabIcon.png';


        end


        function[hfdesign,b,msg]=getFDesign(this,laState)




            if nargin<2
                laState=this.LastAppliedState;
            end


            hfdesign=this.FDesign;
            if isempty(hfdesign)
                b=true;
                msg='';
                return;
            end


            [b,msg]=setupFDesign(this,laState);
            hfdesign=this.FDesign;

            if~isempty(laState)
                factor=laState.Factor;
                ftype=laState.FilterType;




                if isfield(laState,'SecondFactor')
                    secondfactor=laState.SecondFactor;
                else
                    secondfactor='1';
                end
            else
                factor=this.Factor;
                secondfactor=this.SecondFactor;
                ftype=this.FilterType;
            end


            hfdesign=createMultiRateVersion(this,hfdesign,ftype,...
            evaluatevars(factor),evaluatevars(secondfactor));


        end


        function filterTypeWidgets=getFilterTypeWidgets(this,row)




            [ftype_lbl,ftype]=getWidgetSchema(this,'FilterType',...
            FilterDesignDialog.message('filttype'),...
            'combobox',row,1);

            ftypes=this.FilterTypeSet;
            if strcmpi(this.ImpulseResponse,'iir')
                ftypes(end)=[];
            end


            ftypes=strrep(ftypes,' ','');
            ftypes=strrep(ftypes,'-','_');


            ftype.Entries=FilterDesignDialog.message(ftypes);
            ftype.DialogRefresh=true;

            if~allowsMultirate(this)
                ftype.Enabled=false;
            end


            switch lower(this.FilterType)
            case{'decimator','interpolator'}
                str=lower(this.FilterType);
                str=[str(1:5),'f'];
                [factor_lbl,factor]=getWidgetSchema(this,...
                'Factor',FilterDesignDialog.message(str),'edit',row,3);
                filterTypeWidgets={ftype_lbl,ftype,factor_lbl,factor};
            case{'sample-rate converter'}
                [ifactor_lbl,ifactor]=getWidgetSchema(this,...
                'Factor',FilterDesignDialog.message('interf'),'edit',row,3);
                [dfactor_lbl,dfactor]=getWidgetSchema(this,...
                'SecondFactor',FilterDesignDialog.message('decimf'),'edit',row+1,3);
                filterTypeWidgets={ftype_lbl,ftype,...
                ifactor_lbl,ifactor,dfactor_lbl,dfactor};
            otherwise
                filterTypeWidgets={ftype_lbl,ftype};
            end


        end


        function items=getFrequencyUnitsWidgets(this,startrow,items)



            if nargin<3
                items={};
                if nargin<2
                    startrow=1;
                end
            end

            tunable=~isminorder(this)&&this.BuildUsingBasicElements;

            [fsunits_lbl,fsunits]=getWidgetSchema(this,'FrequencyUnits',...
            FilterDesignDialog.message('frequnits'),...
            'combobox',startrow,1);

            fsunits_lbl.Tunable=tunable;

            fsunits.DialogRefresh=true;
            options=this.FrequencyUnitsSet;

            if~isempty(options)&&isFilterDesignerMode(this)
                idx=strcmp(options,'Normalized (0 to 1)');
                idx=idx|strcmp(options,'Hz');
                options=options(idx);
            end

            for i=1:length(options)
                if numel(options{i})>4
                    options{i}=options{i}(1:4);
                end
                options{i}=FilterDesignDialog.message(lower(options{i}));
            end
            fsunits.Entries=options;


            defaultindx=find(strcmpi(this.FrequencyUnitsSet,...
            this.FrequencyUnits));
            if~isempty(defaultindx)
                fsunits.Value=defaultindx-1;
            end

            fsunits.Tunable=tunable;
            if strcmpi(this.FilterType,'Interpolator')
                str='outFs';
            else
                str='inpFs';
            end

            [fs_lbl,fs]=getWidgetSchema(this,'InputSampleRate',...
            FilterDesignDialog.message(str),'edit',...
            startrow,3);

            fs_lbl.ToolTip=FilterDesignDialog.message('InputFsToolTipTxt');
            fs_lbl.Tunable=tunable;

            fs.Editable=true;
            fs.Tunable=tunable;
            fs.ObjectProperty=fs.Tag;


            if strncmpi(this.FrequencyUnits,'normalized',10)
                fs.Enabled=false;
                fs.Visible=false;
                fs_lbl.Enabled=false;
                fs_lbl.Visible=false;
            else
                fs.Enabled=true;
                fs.Visible=true;
                fs_lbl.Enabled=true;
                fs_lbl.Visible=true;
            end

            items=[items,{fsunits_lbl,fsunits,fs_lbl,fs}];


        end


        function Frame=getImplementationFrame(this)





            [items,type,idx]=addStructureComboxboxAndLabel(this);

            if strcmpi(this.OperatingMode,'Simulink')



                [build,idx]=addBuildUsingBasicElementsCheckbox(this,idx);


                if this.BuildUsingBasicElements
                    [optim,idx]=addOptimizationsTogglePanel(this,type,idx);
                    items=[items,{build,optim}];
                elseif type.issos

                    [optimunitsv,idx]=addScaleValuesOptimizationCheckbox(this,idx);
                    items=[items,{build,optimunitsv}];
                else
                    items=[items,{build}];
                end


                [items,idx]=addFrameProcessing(this,idx,items);


                [items,idx]=addRateOptions(this,idx,items);






                if~((~strncmpi(this.FilterType,'Single',6)&&~this.BuildUsingBasicElements)||...
                    strncmpi(this.DesignMethod,'interpolated',12)||...
                    strncmpi(this.DesignMethod,'multistage',10)||...
                    type.iscascadeallpass)
                    tune=addTunabilityWidgets(this,type,idx);
                    items=[items,tune];
                end
                layoutGrid=[5,4];
            else

                sysobj_chkbox=getSystemObjectWidget(this,idx+1);
                if~isempty(sysobj_chkbox)
                    items=[items,{sysobj_chkbox}];
                end
                layoutGrid=[3,4];
            end


            Frame.Type='group';
            Frame.Name=FilterDesignDialog.message('implementation');
            Frame.Items=items;
            Frame.LayoutGrid=layoutGrid;
            Frame.ColStretch=[0,1,0,0];
            Frame.Tag='ImplementationGroup';
        end


        function implementationOptions=getImplementationOptions(this,varargin)





            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=get(this);
            end

            implementationOptions='';
            if isfield(source,'InputProcessing')
                implementationOptions={...
                source.InputProcessing,...
                source.RateOption,...
                source.UseSymbolicNames,...
                source.CoefficientsName,...
                source.NumeratorName,...
                source.DenominatorName,...
                source.ScaleValuesName,...
                source.BuildUsingBasicElements,...
                source.OptimizeZeros,...
                source.OptimizeOnes,...
                source.OptimizeNegOnes,...
                source.OptimizeDelays,...
                source.OptimizeUnitScaleValues,...
                source.isCoefficientsNameEnabled,...
                source.isNumeratorNameEnabled,...
                source.isDenominatorNameEnabled,...
                source.isScaleValuesNameEnabled};
            end


        end


        function[inProcmode_lbl,inProcmode]=getInputProcessingFrame(this,row)




            [inProcmode_lbl,inProcmode]=getWidgetSchema(this,'InputProcessing',...
            FilterDesignDialog.message('inputprocessing'),...
            'combobox',row,1);
            inprocvalidOps=this.InputProcessingSet;


            if this.BuildUsingBasicElements

                if(strcmp(this.ImpulseResponse,'IIR')||...
                    strcmpi(this.FilterType,'sample-rate converter')||...
                    strcmp(this.FilterType,'Interpolator'))


                    inprocvalidOps=inprocvalidOps(2);
                    if strcmp(this.InputProcessing,'columnsaschannels')


                        this.InputProcessing='elementsaschannels';
                    end
                end
            else

                if strcmpi(this.FilterType,'Sample-Rate Converter')

                    inprocvalidOps=inprocvalidOps(1);
                    this.InputProcessing='columnsaschannels';
                else

                    inprocvalidOps=inprocvalidOps(1:2);
                end
            end

            inProcmode=setcombobox(inProcmode,inprocvalidOps,'InputProcessing',this.InputProcessing);
            inProcmode.DialogRefresh=true;
        end


        function hBuffer=getMCodeBuffer(this,flag,inputBuffer)




            fdesignOnlyFlag=false;
            if nargin==3
                fdesignOnlyFlag=flag;
            end

            laState=get(this,'LastAppliedState');
            spec=getSpecification(this,laState);


            mCodeInfo=getMCodeInfo(this);


            mCodeInfo=formatCodeInfo(this,mCodeInfo);

            variables=mCodeInfo.Variables;
            values=mCodeInfo.Values;

            if isfield(mCodeInfo,'Descriptions')
                descriptions=mCodeInfo.Descriptions;
            else
                descriptions=repmat({''},size(variables));
            end

            if isfield(mCodeInfo,'Inputs')
                inputs=mCodeInfo.Inputs;
            else

                [nr,~]=size(variables);
                if nr>1
                    inputs=[{sprintf('''%s''',spec)};variables];
                else
                    inputs=[{sprintf('''%s''',spec)},variables];
                end
            end

            if~strcmpi(laState.FrequencyUnits,'normalized (0 to 1)')
                variables{end+1}='Fs';
                values{end+1}=num2str(convertfrequnits(laState.InputSampleRate,...
                laState.FrequencyUnits,'hz'));
                descriptions{end+1}='';
                inputs{end+1}='Fs';
            end

            if nargin==3
                hBuffer=inputBuffer;
            else
                hBuffer=sigcodegen.mcodebuffer;
            end


            hBuffer.addcr(hBuffer.formatparams(variables,values,descriptions));
            hBuffer.cr;

            hfdesign=getFDesign(this);


            inputs=formatConstructorInputs(this,inputs);


            if strcmpi(laState.FilterType,'single-rate')
                hBuffer.add('h = %s(',class(hfdesign));
            else

                specs=getSpecs(this,laState);

                hBuffer.add('h = fdesign.');

                if strcmpi(laState.FilterType,'sample-rate converter')
                    hBuffer.add('rsrc(%d, %d',specs.Factor,specs.SecondFactor);
                else
                    hBuffer.add('%s(%d',lower(laState.FilterType),specs.Factor);
                end

                hBuffer.add(', ''%s'', ',get(hfdesign,'Response'));
            end


            if~strcmpi(laState.MagnitudeUnits,'db')
                inputs{end+1}=sprintf('''%s''',laState.MagnitudeUnits);
            end


            hBuffer.add('%s',inputs{1});
            for indx=2:length(inputs)
                hBuffer.add(', %s',inputs{indx});
            end

            hBuffer.addcr(');');



            addSetSpecificationLines(this,variables,values,hBuffer);


            hBuffer.cr;

            laDOpts=getDesignOptions(this,get(this,'LastAppliedState'));

            methodName=getSimpleMethod(this,laState);

            hBuffer.add('Hd = design(h, ''%s''',methodName);

            set(hfdesign,'Specification',spec);
            defaultDOpts=designopts(hfdesign,methodName);

            if isSystemObjectDesign(this)
                laDOpts=[laDOpts,{'SystemObject',true}];
            else
                if isfield(defaultDOpts,'SystemObject')
                    defaultDOpts=rmfield(defaultDOpts,'SystemObject');
                end
            end

            for indx=1:2:length(laDOpts)



                if isequal(defaultDOpts.(laDOpts{indx}),laDOpts{indx+1})
                    continue;
                end
                hBuffer.addcr(', ...');
                if isnumeric(laDOpts{indx+1})
                    if length(laDOpts{indx+1})==1
                        laDOpts{indx+1}=num2str(laDOpts{indx+1});
                    else
                        laDOpts{indx+1}=mat2str(laDOpts{indx+1});
                    end
                elseif islogical(laDOpts{indx+1})
                    if laDOpts{indx+1}
                        laDOpts{indx+1}='true';
                    else
                        laDOpts{indx+1}='false';
                    end
                elseif isa(laDOpts{indx+1},'function_handle')
                    laDOpts{indx+1}=['@',func2str(laDOpts{indx+1})];
                else
                    if ischar(laDOpts{indx+1})
                        laDOpts{indx+1}=['''',laDOpts{indx+1},''''];
                        if~strcmpi(laDOpts{indx},'sosscalenorm')
                            laDOpts{indx+1}=lower(laDOpts{indx+1});
                        end
                    else



                        if iscell(laDOpts{indx+1})
                            temp=laDOpts{indx+1};
                            aux='{';
                            for i=1:length(temp)
                                if isnumeric(temp{i})
                                    temp{i}=num2str(temp{i});
                                elseif ischar(temp{i})
                                    temp{i}=['''',temp{i},''''];
                                elseif strcmpi(class(temp{i}),'function_handle')
                                    temp{i}=['@',char(temp{i})];
                                end
                                aux=[aux,temp{i},','];
                            end
                            laDOpts{indx+1}=[aux(1:end-1),'}'];
                        end
                    end
                end
                hBuffer.add('    ''%s'', %s',laDOpts{indx},laDOpts{indx+1});
            end



            dd=design(this);
            if isa(dd,'dsp.BiquadFilter')
                hBuffer.addcr(',...');
                hBuffer.add('     UseLegacyBiquadFilter=true');
            end

            hBuffer.add(');');

            if~fdesignOnlyFlag

                if~isempty(this.FixedPoint)
                    hBuffer.cr;
                    hBuffer.cr;
                    if isempty(this.LastAppliedFilter)
                        design(this);
                    end
                    hBuffer.add(getMCodeBuffer(this.FixedPoint,this.LastAppliedFilter));
                end
            end

        end


        function hBuffer=getMCodeBufferDesObj(this,flag,inputBuffer)



            fdesignOnlyFlag=false;
            if nargin==3
                fdesignOnlyFlag=flag;
            end

            laState=get(this,'LastAppliedState');
            spec=getSpecification(this,laState);


            mCodeInfo=getMCodeInfo(this);


            mCodeInfo=formatCodeInfo(this,mCodeInfo);

            variables=mCodeInfo.Variables;
            values=mCodeInfo.Values;

            if strcmpi(this.MagnitudeUnits,'linear')
                [variables,values]=convertMagPropsTodB(this,variables,values);
            end

            if isfield(mCodeInfo,'Descriptions')
                descriptions=mCodeInfo.Descriptions;
            else
                descriptions=repmat({''},size(variables));
            end

            propNames=signal.internal.filterdesigner.convertpropnames(variables);
            if isfield(mCodeInfo,'Inputs')
                inputs=mCodeInfo.Inputs;
            else

                inputs=['''Specification''';{sprintf('''%s''',spec)}];
                for idx=1:length(variables)
                    inputs=[inputs;['''',propNames{idx},''''];variables{idx}];
                end
            end

            addSampleRateInputs=false;
            if~strcmpi(laState.FrequencyUnits,'normalized (0 to 1)')
                variables{end+1}='Fs';
                values{end+1}=num2str(convertfrequnits(laState.InputSampleRate,...
                laState.FrequencyUnits,'hz'));
                descriptions{end+1}='';
                addSampleRateInputs=true;
            end

            if nargin==3
                hBuffer=inputBuffer;
            else
                hBuffer=sigcodegen.mcodebuffer;
            end


            hBuffer.addcr(hBuffer.formatparams(variables,values,descriptions));
            hBuffer.cr;

            hfdesign=getFDesign(this);


            inputs=formatConstructorInputs(this,inputs);


            hBuffer.add('h = %s(',convertClassName(this,class(hfdesign)));

            methodName=getSimpleMethod(this,laState);

            methodNameStr=signal.internal.filterdesigner.convertdesignmethodnames(methodName,this.isfir,'short2long');
            inputs=[inputs;'''DesignMethod''';['''',methodNameStr,'''']];

            if addSampleRateInputs
                inputs{end+1}='''SampleRate''';
                inputs{end+1}='Fs';
            end


            hBuffer.add('%s',inputs{1});
            for indx=2:length(inputs)
                hBuffer.add(', %s',inputs{indx});
            end

            hBuffer.addcr(');');



            addSetSpecificationLines(this,variables,values,hBuffer);


            hBuffer.cr;

            laDOpts=getDesignOptions(this,get(this,'LastAppliedState'));


            idx=find(strcmp(laDOpts,'FilterStructure'));
            laDOpts([idx,idx+1])=[];

            if this.isfir
                outputVarName='B';
            else
                outputVarName='SOS';
            end

            hBuffer.add([outputVarName,' = design(h']);

            set(hfdesign,'Specification',spec);
            defaultDOpts=designopts(hfdesign,methodName);

            for indx=1:2:length(laDOpts)



                if isequal(defaultDOpts.(laDOpts{indx}),laDOpts{indx+1})
                    continue;
                end
                hBuffer.addcr(', ...');
                if isnumeric(laDOpts{indx+1})
                    if length(laDOpts{indx+1})==1
                        laDOpts{indx+1}=num2str(laDOpts{indx+1});
                    else
                        laDOpts{indx+1}=mat2str(laDOpts{indx+1});
                    end
                elseif islogical(laDOpts{indx+1})
                    if laDOpts{indx+1}
                        laDOpts{indx+1}='true';
                    else
                        laDOpts{indx+1}='false';
                    end
                else
                    if ischar(laDOpts{indx+1})
                        laDOpts{indx+1}=['''',laDOpts{indx+1},''''];
                        if~strcmpi(laDOpts{indx},'sosscalenorm')
                            laDOpts{indx+1}=lower(laDOpts{indx+1});
                        end
                    else



                        if iscell(laDOpts{indx+1})
                            temp=laDOpts{indx+1};
                            aux='{';
                            for i=1:length(temp)
                                if isnumeric(temp{i})
                                    temp{i}=num2str(temp{i});
                                elseif ischar(temp{i})
                                    temp{i}=['''',temp{i},''''];
                                elseif strcmpi(class(temp{i}),'function_handle')
                                    temp{i}=['@',char(temp{i})];
                                end
                                aux=[aux,temp{i},','];
                            end
                            laDOpts{indx+1}=[aux(1:end-1),'}'];
                        end
                    end
                end
                laDOpts{indx}=signal.internal.filterdesigner.convertdesignoptnames(laDOpts{indx});
                hBuffer.add('    ''%s'', %s',laDOpts{indx},laDOpts{indx+1});
            end
            hBuffer.add(');');

            if~fdesignOnlyFlag
                if isSystemObjectDesign(this)&&isSystemObjectInputProc(this)&&...
                    strcmp(this.InputProcessing,'elementsaschannels')
                    hBuffer.cr;
                    hBuffer.cr;
                    hBuffer.add('set(Hd,''FrameBasedProcessing'',false);')
                end

                if~isempty(this.FixedPoint)
                    hBuffer.cr;
                    hBuffer.cr;
                    if isempty(this.LastAppliedFilter)
                        design(this);
                    end
                    hBuffer.add(getMCodeBuffer(this.FixedPoint,this.LastAppliedFilter));
                end
            end
        end


        function hBuffer=getMCodeBufferFilterDesigner(this,~,inputBuffer)




%#ok<*AGROW>

            if nargin==3
                hBuffer=inputBuffer;
            else
                hBuffer=sigcodegen.mcodebuffer;
            end

            laState=get(this,'LastAppliedState');
            spec=getSpecification(this,laState);


            mCodeInfo=getMCodeInfo(this);


            mCodeInfo=formatCodeInfo(this,mCodeInfo);

            variables=mCodeInfo.Variables;



            values=getSpecificationsFromDialog(this,variables);

            propNames=signal.internal.DesignfiltProcessCheck.convertpropnames(variables,'fdesignToDesignfilt');
            if isfield(mCodeInfo,'Inputs')
                inputs=mCodeInfo.Inputs;
            else

                response=lower(class(getFDesign(this)));
                response=[response(9:end),lower(this.ImpulseResponse)];

                inputs={sprintf('''%s''',response)};
            end


            if~strcmpi(laState.FrequencyUnits,'normalized (0 to 1)')
                propNames{end+1}='SampleRate';
                values{end+1}=num2str(convertfrequnits(laState.InputSampleRate,laState.FrequencyUnits,'hz'));
            end


            hfdesign=getFDesign(this);





            methodName=getSimpleMethod(this,laState);
            designfiltActualname=signal.internal.DesignfiltProcessCheck.convertdesignmethodnames(methodName,this.isfir,'fdesignToDesignfilt');

            mIdx=strcmpi(this.PropertyNames,'DesignMethod');
            if any(mIdx)


                inputDesignMethod=this.PropertyValues{mIdx};
                if strcmp(inputDesignMethod,designfiltActualname)&&~isempty(this.PropertyValueNames{mIdx})



                    propNames{end+1}='DesignMethod';
                    values{end+1}=['''',this.PropertyValueNames{mIdx},''''];
                else



                    propNames{end+1}='DesignMethod';
                    values{end+1}=['''',designfiltActualname,''''];
                end
            else


                if this.isfir
                    allMethods=designmethods(hfdesign,'fir','signalonly');
                    if any(strcmp(allMethods,'freqsamp'))
                        defaultMethod='freqsamp';
                    elseif numel(allMethods)==1
                        defaultMethod=allMethods{1};
                    else
                        defaultMethod='equiripple';
                    end
                else
                    allMethods=designmethods(hfdesign,'iir','signalonly');
                    if numel(allMethods)==1
                        defaultMethod=allMethods{1};
                    else
                        defaultMethod='butter';
                    end
                end

                if~strcmpi(defaultMethod,methodName)
                    propNames{end+1}='DesignMethod';
                    values{end+1}=['''',designfiltActualname,''''];
                end
            end


            laDOpts=getDesignOptions(this,get(this,'LastAppliedState'));
            idx=find(strcmpi(laDOpts,'FilterStructure')==true);
            if~isempty(idx)
                laDOpts([idx,idx+1])=[];
            end
            set(hfdesign,'Specification',spec);
            defaultDOpts=designopts(hfdesign,methodName,'signalonly');

            for indx=1:2:length(laDOpts)





                if~any(strcmpi(this.PropertyNames,laDOpts{indx}))
                    if ischar(defaultDOpts.(laDOpts{indx}))&&ischar(laDOpts{indx+1})&&strcmpi(defaultDOpts.(laDOpts{indx}),laDOpts{indx+1})
                        continue;
                    elseif isequal(defaultDOpts.(laDOpts{indx}),laDOpts{indx+1})
                        continue;
                    end
                end

                if isnumeric(defaultDOpts.(laDOpts{indx}))||ischar(defaultDOpts.(laDOpts{indx}))||isempty(defaultDOpts.(laDOpts{indx}))
                    sV=getSpecificationsFromDialog(this,laDOpts(indx));
                    if ischar(defaultDOpts.(laDOpts{indx}))||isempty(defaultDOpts.(laDOpts{indx}))
                        if strcmpi(laDOpts{indx},'window')&&(strncmp(sV{:},'@',1)||strncmp(sV{:},'{',1)||~isaWindowName(sV{:}))

                            sV=sV{:};
                        else
                            sV=strrep(sV{:},'''','');
                            sV=['''',sV,''''];
                        end
                        laDOpts{indx+1}=sV;
                    else
                        laDOpts{indx+1}=sV{:};
                    end
                elseif islogical(defaultDOpts.(laDOpts{indx}))
                    if laDOpts{indx+1}
                        laDOpts{indx+1}='true';
                    else
                        laDOpts{indx+1}='false';
                    end
                elseif isa(laDOpts{indx+1},'function_handle')
                    laDOpts{indx+1}=['@',func2str(laDOpts{indx+1})];
                elseif iscell(laDOpts{indx+1})



                    temp=laDOpts{indx+1};
                    aux='{';
                    for i=1:length(temp)
                        if isnumeric(temp{i})
                            temp{i}=num2str(temp{i});
                        elseif ischar(temp{i})
                            temp{i}=['''',temp{i},''''];
                        elseif strcmpi(class(temp{i}),'function_handle')
                            temp{i}=['@',char(temp{i})];
                        end
                        aux=[aux,temp{i},','];
                    end
                    laDOpts{indx+1}=[aux(1:end-1),'}'];
                end


                laDOpts{indx}=signal.internal.DesignfiltProcessCheck.convertdesignoptnames(laDOpts{indx},'fdesignToDesignfilt');
                propNames=[propNames;laDOpts(indx)];
                values=[values;laDOpts(indx+1)];
            end


            for idx=1:length(propNames)
                inputs=[inputs;{['''',propNames{idx},'''']};values{idx}];
            end



            hBuffer.Wrap='off';
            if strcmpi(this.CorrectCodeMode,'AddCodeToCommandLine')

                hBuffer.add([this.VariableName,' = designfilt(']);
            elseif strcmpi(this.CorrectCodeMode,'None')


                if isempty(this.OutputVarName)
                    hBuffer.add('designfilt(');
                else
                    hBuffer.add([this.OutputVarName,' = designfilt(']);
                end
            elseif strcmpi(this.CorrectCodeMode,'EditDigitalFilter')


                if isempty(this.OutputVarName)
                    hBuffer.add([this.VariableName,' = designfilt(']);
                else
                    hBuffer.add([this.OutputVarName,' = designfilt(']);
                    this.VariableName=this.OutputVarName;
                end
            end

            hBuffer.add('%s',inputs{1});
            for indx=2:length(inputs)
                hBuffer.add(',%s',inputs{indx});
            end
            hBuffer.add(');');
        end


        function hBuffer=getMCodeBufferSysObj(this,inputBuffer,varargin)




            varNames={};

            if~isempty(varargin)


                Hd=varargin{1};
                if length(varargin)>1
                    varNames=varargin{2};
                end
            else
                Hd=this.LastAppliedFilter;
            end

            if nargin>1&&~isempty(inputBuffer)
                hBuffer=inputBuffer;
            else
                hBuffer=sigcodegen.mcodebuffer;
            end

            hBuffer.add(['Hd = ',class(Hd),'(']);

            propNames=getActiveProps(Hd,'all');

            if isempty(varNames)
                propNames=removeDefaultSysObjProps(this,Hd,propNames,false);
            else
                propNames=removeDefaultSysObjProps(this,Hd,propNames,true);
            end

            flag=false;

            idx=strcmp(propNames,'Structure');
            if any(idx)&&~isa(Hd,'dsp.IIRHalfbandInterpolator')&&~isa(Hd,'dsp.IIRHalfbandDecimator')
                propNames(idx)=[];
                propNames=[{'Structure'},propNames];
            end

            idx=strcmp(propNames,'FullPrecisionOverride');
            if any(idx)
                propNames(idx)=[];
                propNames=[{'FullPrecisionOverride'},propNames];
            end

            idx=strcmp(propNames,'FixedPointDataType');
            if any(idx)
                propNames(idx)=[];
                propNames=[{'FixedPointDataType'},propNames];
            end

            idx=strcmp(propNames,'RoundingMethod');
            if any(idx)
                propNames(idx)=[];
                propNames=[propNames,{'RoundingMethod'}];
            end

            idx=strcmp(propNames,'OverflowAction');
            if any(idx)
                propNames(idx)=[];
                propNames=[propNames,{'OverflowAction'}];
            end

            varNamesLgth=length(varNames);

            for idx=1:length(propNames)
                if idx>1
                    flag=true;
                end
                quoteCharFlag=true;

                prop=propNames{idx};

                setPropToObjectValue=false;

                if any(strcmpi({'Numerator','SOSMatrix'},prop))&&~isempty(varNames)
                    if isa(Hd,'dsp.FIRDecimator')||isa(Hd,'dsp.FIRInterpolator')
                        if varNamesLgth>1&&~isempty(varNames{2})
                            propValue=varNames{2};
                        else
                            setPropToObjectValue=true;
                        end
                    elseif isa(Hd,'dsp.FIRRateConverter')
                        if varNamesLgth>2&&~isempty(varNames{3})
                            propValue=varNames{3};
                        else
                            setPropToObjectValue=true;
                        end
                    elseif isa(Hd,'dsp.BiquadFilter')
                        if~isempty(varNames{1})
                            propValue=varNames{1};
                        else
                            setPropToObjectValue=true;
                        end
                    else
                        propValue=varNames{1};
                    end
                    quoteCharFlag=false;
                elseif any(strcmpi({'Denominator','ScaleValues'},prop))&&~isempty(varNames)

                    if varNamesLgth>1&&~isempty(varNames{2})
                        propValue=varNames{2};
                    else
                        setPropToObjectValue=true;
                    end
                    quoteCharFlag=false;
                elseif strcmpi('DecimationFactor',prop)&&~isempty(varNames)
                    if isa(Hd,'dsp.FIRDecimator')||isa(Hd,'dsp.CICDecimator')
                        propValue=varNames{1};
                    else
                        if varNamesLgth>1&&~isempty(varNames{2})
                            propValue=varNames{2};
                        else
                            setPropToObjectValue=true;
                        end
                    end
                    quoteCharFlag=false;
                elseif strcmpi('ReflectionCoefficients',prop)&&~isempty(varNames)
                    propValue=varNames{1};
                    quoteCharFlag=false;
                elseif strcmpi('InterpolationFactor',prop)&&~isempty(varNames)
                    propValue=varNames{1};
                    quoteCharFlag=false;
                elseif strcmpi('DifferentialDelay',prop)&&~isempty(varNames)
                    if varNamesLgth>1&&~isempty(varNames{2})
                        propValue=varNames{2};
                    else
                        setPropToObjectValue=true;
                    end
                    quoteCharFlag=false;
                elseif strcmpi('NumSections',prop)&&~isempty(varNames)
                    if varNamesLgth>2&&~isempty(varNames{3})
                        propValue=varNames{3};
                    else
                        setPropToObjectValue=true;
                    end
                    quoteCharFlag=false;
                elseif isa(Hd.(prop),'embedded.numerictype')
                    propValue=getNumericTypeString(this,Hd.(prop));
                else
                    setPropToObjectValue=true;
                end
                if setPropToObjectValue
                    propValue=Hd.(prop);
                    quoteCharFlag=true;
                end
                addPair(hBuffer,prop,propValue,flag,quoteCharFlag);
            end

            hBuffer.add(');');
        end


        function hBuffer=getMCodeBufferSysObjCascade(~,thisFDATool,inputBuffer,Hd)







            hBuffer=inputBuffer;


            hBuffer.remove('cascade','partial');


            if~isempty(hBuffer.find('ifir(','partial'))
                hBuffer.craddcr(sprintf(['Hcascade = cascade(dsp.FIRFilter(''Numerator'', h), ',...
                'dsp.FIRFilter(''Numerator'', g));']));
                return
            end






            hBuffer.remove('addstage','partial');


            hfilt=getfilter(thisFDATool);

            for idx=1:getNumStages(Hd)
                dmfiltIdx=hBuffer.find({'dfilt.','mfilt.'},'partial');
                dmfiltIdx=min([min(dmfiltIdx{1}),min(dmfiltIdx{2})]);
                hBufferStage=copy(hBuffer);
                hBufferStage.remove(dmfiltIdx+1:hBuffer.lines);
                hBufferStage=getMCodeBufferSysObjCascadeStage(thisFDATool,hBufferStage,hfilt.Stage(idx));
                if idx==1
                    hBufferStage.craddcr('Hcascade = dsp.FilterCascade(Hd);');
                else
                    hBufferStage.craddcr('addStage(Hcascade, Hd);');
                end
                hBuffer.remove(1:dmfiltIdx);
                if hBuffer.lines>0
                    hBuffer.insert(1,hBufferStage.buffer);
                else
                    hBuffer.add(hBufferStage.buffer);
                end
            end



            arithStartIdx=min(hBuffer.find('Arithmetic','partial'));
            while~isempty(arithStartIdx)
                hBuffer=removeArithmeticCode(hBuffer,min(arithStartIdx));
                arithStartIdx=min(hBuffer.find('Arithmetic','partial'));
            end
        end


        function mCodeInfo=getMCodeInfo(this)




            laState=get(this,'LastAppliedState');
            specs=getSpecs(this,laState);


            spec=getSpecification(this,laState);
            specCell=textscan(spec,'%s','delimiter',',');
            specCell=specCell{1};


            vars=cell(size(specCell));
            vals=vars;
            descs=vars;
            for indx=1:length(specCell)
                descs{indx}='';
                switch lower(specCell{indx})
                case 'q'
                    vars{indx}='Q';
                    vals{indx}=num2str(specs.Q);
                case 'qa'
                    vars{indx}='Qa';
                    vals{indx}=num2str(specs.Qa);
                    descs{indx}='Quality factor (audio)';
                case 's'
                    vars{indx}='S';
                    vals{indx}=num2str(specs.S);
                    descs{indx}='Shelf slope parameter';
                case 'tw'
                    vars{indx}='TW';
                    vals{indx}=num2str(specs.TransitionWidth);
                case 'n'
                    vars{indx}='N';
                    vals{indx}=num2str(specs.Order);
                case 'nb'
                    vars{indx}='Nb';
                    vals{indx}=num2str(specs.Order);
                case 'na'
                    vars{indx}='Na';
                    vals{indx}=num2str(specs.DenominatorOrder);
                case 'fp'
                    vars{indx}='Fpass';
                    vals{indx}=num2str(specs.Fpass);
                case 'fp1'
                    vars{indx}='Fpass1';
                    vals{indx}=num2str(specs.Fpass1);
                case 'fp2'
                    vars{indx}='Fpass2';
                    vals{indx}=num2str(specs.Fpass2);
                case 'fst'
                    vars{indx}='Fstop';
                    vals{indx}=num2str(specs.Fstop);
                case 'fst1'
                    vars{indx}='Fstop1';
                    vals{indx}=num2str(specs.Fstop1);
                case 'fst2'
                    vars{indx}='Fstop2';
                    vals{indx}=num2str(specs.Fstop2);
                case 'f3db'
                    vars{indx}='F3dB';
                    vals{indx}=num2str(specs.F3dB);
                case 'f3db1'
                    vars{indx}='F3dB1';
                    vals{indx}=num2str(specs.F3dB1);
                case 'f3db2'
                    vars{indx}='F3dB2';
                    vals{indx}=num2str(specs.F3dB2);
                case 'fc'
                    if isfield(specs,'Fc')
                        vars{indx}='Fc';
                        vals{indx}=num2str(specs.Fc);
                        descs{indx}='Cutoff frequency';
                    else
                        vars{indx}='F6dB';
                        vals{indx}=num2str(specs.F6dB);
                    end
                case 'fc1'
                    vars{indx}='F6dB1';
                    vals{indx}=num2str(specs.F6dB1);
                case 'fc2'
                    vars{indx}='F6dB2';
                    vals{indx}=num2str(specs.F6dB2);
                case 'ap'
                    vars{indx}='Apass';
                    vals{indx}=num2str(specs.Apass);
                case 'ap1'
                    vars{indx}='Apass1';
                    vals{indx}=num2str(specs.Apass1);
                case 'ap2'
                    vars{indx}='Apass2';
                    vals{indx}=num2str(specs.Apass2);
                case 'ast'
                    vars{indx}='Astop';
                    vals{indx}=num2str(specs.Astop);
                case 'ast1'
                    vars{indx}='Astop1';
                    vals{indx}=num2str(specs.Astop1);
                case 'ast2'
                    vars{indx}='Astop2';
                    vals{indx}=num2str(specs.Astop2);
                case 'f0'
                    vars{indx}='F0';
                    if isfield(specs,'F0')
                        vals{indx}=num2str(specs.F0);
                    else
                        vals{indx}=num2str(specs.CenterFreq);
                    end
                    descs{indx}='Center frequency';
                case 'bw'
                    vars{indx}='BW';
                    vals{indx}=num2str(specs.BW);
                    descs{indx}='Bandwidth';
                case 'bwp'
                    vars{indx}='BWpass';
                    vals{indx}=num2str(specs.BWpass);
                    descs{indx}='Passband width';
                case 'bwst'
                    vars{indx}='BWstop';
                    vals{indx}=num2str(specs.BWstop);
                    descs{indx}='Stopband width';
                case 'gref'
                    vars{indx}='Gref';
                    vals{indx}=num2str(specs.Gref);
                    descs{indx}='Reference gain';
                case 'g0'
                    vars{indx}='G0';
                    vals{indx}=num2str(specs.G0);
                    descs{indx}='Center frequency gain';
                case 'gbw'
                    vars{indx}='GBW';
                    vals{indx}=num2str(specs.GBW);
                    descs{indx}='Bandwidth gain';
                case 'gp'
                    vars{indx}='Gpass';
                    vals{indx}=num2str(specs.Gpass);
                    descs{indx}='Passband gain';
                case 'gst'
                    vars{indx}='Gstop';
                    vals{indx}=num2str(specs.Gstop);
                    descs{indx}='Stopband gain';
                case 'flow'
                    vars{indx}='Flow';
                    vals{indx}=num2str(specs.Flow);
                    descs{indx}='Low frequency';
                case 'fhigh'
                    vars{indx}='Fhigh';
                    vals{indx}=num2str(specs.Fhigh);
                    descs{indx}='High frequency';
                case 'beta'
                    vars{indx}='Beta';
                    vals{indx}=num2str(specs.Beta);
                    descs{indx}='Rolloff factor';
                case 'bt'
                    vars{indx}='BT';
                    vals{indx}=num2str(specs.BT);
                    descs{indx}='Bandwidth-symbol time product';
                case 'nsym'
                    vars{indx}='Nsym';
                    vals{indx}=num2str(specs.NumberOfSymbols);
                    descs{indx}='Number of symbols';
                case 'c'

                otherwise
                    error(message('FilterDesignLib:FilterDesignDialog:AbstractDesign:getMCodeInfo:InternalError',specCell{indx}));
                end
            end

            mCodeInfo.Variables=vars;
            mCodeInfo.Values=vals;
            mCodeInfo.Descriptions=descs;


        end


        function items=getMagnitudeUnitsWidgets(this,startrow,items)




            if nargin<3
                items={};
                if nargin<2
                    startrow=2;
                end
            end

            tunable=~isminorder(this)&&this.BuildUsingBasicElements;


            [units_lbl,units]=getWidgetSchema(this,'MagnitudeUnits',...
            FilterDesignDialog.message('magunits'),...
            'combobox',startrow,1);


            units_lbl.Tunable=tunable;
            units.Tunable=tunable;



            if strcmpi(this.ImpulseResponse,'fir')

                unitEntries={'dB','Linear'};
                options=FilterDesignDialog.message(unitEntries);
                units.Entries=options;
            else

                unitEntries={'dB','Squared'};
                options=FilterDesignDialog.message(unitEntries);
                units.Entries=options;
            end

            defaultindx=find(strcmpi(unitEntries,this.MagnitudeUnits));
            if~isempty(defaultindx)
                units.Value=defaultindx-1;
            end
            units.ObjectMethod='selectComboboxEntry';
            units.MethodArgs={'%dialog','%value','MagnitudeUnits',unitEntries};
            units.ArgDataTypes={'handle','mxArray','string','mxArray'};



            units.Mode=false;




            units=rmfield(units,'ObjectProperty');
            items={items{:},units_lbl,units};%#ok<CCAT>


        end


        function varargout=getOrderWidgets(this,row,allowsMinOrd)



            if nargin<3
                allowsMinOrd=true;
            end

            col=1;


            if allowsMinOrd


                [ordermode_lbl,ordermode]=getWidgetSchema(this,'OrderMode',...
                FilterDesignDialog.message('ordermode'),'combobox',row,col);


                ordermode.DialogRefresh=true;
                orderMode=this.OrderModeSet;
                ordermode.Entries=FilterDesignDialog.message(orderMode);

                col=col+2;
                orderWidgets={ordermode_lbl,ordermode};
            else
                orderWidgets={};
            end


            [order_lbl,order]=getWidgetSchema(this,'Order',...
            FilterDesignDialog.message('order'),...
            'edit',row,col);


            if allowsMinOrd&&isminorder(this)
                order_lbl.Enabled=false;
                order.Enabled=false;
                order_lbl.Visible=false;
                order.Visible=false;
            else
                order_lbl.Enabled=true;
                order.Enabled=true;
                order_lbl.Visible=true;
                order.Visible=true;
            end

            orderWidgets={orderWidgets{:},order_lbl,order};%#ok<CCAT>



            if nargout>1
                varargout=orderWidgets;
            else
                varargout={orderWidgets};
            end


        end


        function varargout=getOrderWidgetsWithNum(this,row,allowsMinOrd)




            if nargin<3
                allowsMinOrd=true;
            end

            col=1;


            if allowsMinOrd


                [ordermode_lbl,ordermode]=getWidgetSchema(this,'OrderMode',...
                FilterDesignDialog.message('ordermode'),'combobox',row,col);


                ordermode.DialogRefresh=true;
                orderMode=this.OrderModeSet;
                ordermode.Entries=FilterDesignDialog.message(orderMode);

                row=row+1;

                orderWidgets={ordermode_lbl,ordermode};
            else
                orderWidgets={};
            end


            if~isfir(this)&&~isminorder(this)&&this.SpecifyDenominator
                widgetName=FilterDesignDialog.message('NumOrder');
            else
                widgetName=FilterDesignDialog.message('order');
            end

            [order_lbl,order]=getWidgetSchema(this,'Order',...
            widgetName,...
            'edit',row,col);


            if allowsMinOrd&&isminorder(this)
                order_lbl.Enabled=false;
                order_lbl.Visible=false;
                order.Enabled=false;
                order.Visible=false;
            end

            orderWidgets={orderWidgets{:},order_lbl,order};%#ok<CCAT>



            if nargout>1
                varargout=orderWidgets;
            else
                varargout={orderWidgets};
            end


        end


        function outputVarName=getOutputVarName(this,suffix)



            if isFilterDesignerMode(this)
                outputVarName=uiservices.getVariableName(suffix);
            else
                outputVarName=uiservices.getVariableName(['H',suffix]);
            end


        end


        function[ratemode_lbl,ratemode]=getRateOptionFrame(this,row)




            [ratemode_lbl,ratemode]=getWidgetSchema(this,'RateOption',...
            FilterDesignDialog.message('rateoption'),...
            'combobox',row,1);
            ratevalidOps=this.RateOptionSet;





            if strcmpi(this.FilterType,'decimator')||strcmpi(this.FilterType,'interpolator')
                if~strcmpi(this.InputProcessing,'columnsaschannels')

                    this.RateOption='allowmultirate';
                    ratevalidOps=ratevalidOps(2);
                end
            elseif strcmpi(this.FilterType,'sample-rate converter')
                if this.BuildUsingBasicElements

                    this.RateOption='allowmultirate';
                    ratevalidOps=ratevalidOps(2);
                else

                    this.RateOption='enforcesinglerate';
                    ratevalidOps=ratevalidOps(1);
                end
            else

                ratevalidOps=ratevalidOps(1);
                this.RateOption='enforcesinglerate';
            end
            ratemode=setcombobox(ratemode,ratevalidOps,'RateOption',this.RateOption);
            ratemode.DialogRefresh=true;
        end


        function simpleMethod=getSimpleMethod(this,laState)



            if nargin>1&&~isempty(laState)
                dm=laState.DesignMethod;
            else
                dm=this.DesignMethod;
            end

            simpleMethod=lower(dm);

            switch simpleMethod
            case 'chebyshev type i'
                simpleMethod='cheby1';
            case 'chebyshev type ii'
                simpleMethod='cheby2';
            case 'butterworth'
                simpleMethod='butter';
            case 'elliptic'
                simpleMethod='ellip';
            case 'fir least-squares'
                simpleMethod='firls';
            case 'fir constrained least-squares'
                simpleMethod='fircls';
            case 'maximally flat'
                simpleMethod='maxflat';
            case 'iir least-squares'
                simpleMethod='iirls';
            case 'window'
                simpleMethod='window';
            case 'kaiser window'
                simpleMethod='kaiserwin';
            case 'iir least p-norm'
                simpleMethod='iirlpnorm';
            case 'interpolated fir'
                simpleMethod='ifir';
            case 'multistage equiripple'
                simpleMethod='multistage';
            case 'iir quasi-linear phase'
                simpleMethod='iirlinphase';
            case 'lagrange interpolation'
                simpleMethod='lagrange';
            case 'frequency sampling'
                simpleMethod='freqsamp';
            case 'ansi s1.42 weighting'
                simpleMethod='ansis142';
            case 'c-message bell 41009 weighting'
                simpleMethod='bell41009';
            end


        end


        function state=getState(this)




            state=get(this);
            state=rmfield(state,{'Path','ActiveTab','FixedPoint'});


        end


        function sysobj_chkbox=getSystemObjectWidget(this,idx)



            sysobj_chkbox=[];

            if isSystemObjectSupported(this)&&isDSTMode(this)
                sysobj_chkbox.Name=FilterDesignDialog.message('sysobj');
                sysobj_chkbox.Type='checkbox';
                sysobj_chkbox.Source=this;

                sysobj_chkbox.DialogRefresh=true;
                sysobj_chkbox.RowSpan=[idx,idx];
                sysobj_chkbox.ColSpan=[1,2];



                sysobj_chkbox.Mode=false;
                sysobj_chkbox.ObjectMethod='setCheckboxValue';
                sysobj_chkbox.MethodArgs={'SystemObject','%value'};
                sysobj_chkbox.ArgDataTypes={'string','bool'};

                if isSystemObjectEnabled(this)&&isSystemObjectMandatory(this)


                    sysobj_chkbox.Tag='SystemObjectMandatory';
                    sysobj_chkbox.Value=true;
                    sysobj_chkbox.Enabled=false;
                    sysobj_chkbox.Visible=false;
                elseif isSystemObjectEnabled(this)
                    sysobj_chkbox.Tag='SystemObject';
                    sysobj_chkbox.ObjectProperty='SystemObject';
                    sysobj_chkbox.Enabled=true;
                    sysobj_chkbox.Visible=true;
                else
                    sysobj_chkbox.Tag='SystemObjectNoProperty';
                    sysobj_chkbox.Enabled=false;
                    sysobj_chkbox.Visible=true;
                end
            end

        end


        function validMethods=getValidMethods(this,varargin)





            validMethods=[];
            hfdesign=getFDesign(this,this);
            s=getSpecification(this);
            if isempty(hfdesign)
                sEntries=[];
            else
                sEntries=set(hfdesign,'Specification');
            end

            if any(strcmpi(s,sEntries))




                set(hfdesign,'Specification',...
                validatestring(s,hfdesign.getAllowedStringValues('Specification')));
                if nargin>1


                    if isFilterDesignerMode(this)
                        validMethods=designmethods(hfdesign,this.ImpulseResponse,'signalonly');
                    else
                        validMethods=designmethods(hfdesign,this.ImpulseResponse);
                    end
                else

                    if isFilterDesignerMode(this)
                        validMethods=designmethods(hfdesign,this.ImpulseResponse,'full','signalonly');
                    else
                        validMethods=designmethods(hfdesign,this.ImpulseResponse,'full');
                    end
                end


                validMethods=validMethods(:)';
            end



        end


        function[validStructures,defaultStructure]=getValidStructures(this,flag)



            validStructures={};
            defaultStructure='';


            setupFDesign(this);



            hd=this.FDesign;
            setSpecsSafely(this,hd,getSpecification(this));


            hd=createMultiRateVersion(this,hd,this.FilterType,...
            evaluatevars(this.Factor),evaluatevars(this.SecondFactor));


            methodEntries=getValidMethods(this,'short');
            method=getSimpleMethod(this);
            if any(strcmpi(method,methodEntries))
                dopts=thisDesignOptions(this,hd,method);
                validStructures=dopts.FilterStructure;
                defaultStructure=dopts.DefaultFilterStructure;


                if strcmpi(this.OperatingMode,'Simulink')
                    validStructures=setdiff(validStructures,{'fftfir','fftfirinterp','fd'});
                end

                if nargin>1&&strcmpi(flag,'full')
                    for indx=1:length(validStructures)
                        validStructures{indx}=convertStructure(this,validStructures{indx});
                    end
                    defaultStructure=convertStructure(this,defaultStructure);
                end
            end



        end


        function[labelSchema,widgetSchema]=getWidgetSchema(this,varargin)





            [labelSchema,widgetSchema]=uiservices.getWidgetSchema(this,varargin{:});


        end


        function impulseresponse=get_impulseresponse(~,impulseresponse)







        end


        function value=getnum(~,source,prop)



            value=source.(prop);
            funits=source.FrequencyUnits;
            isNormalized=strncmpi(funits,'normalized',10);



            if strcmpi(prop,'InputSampleRate')&&isempty(value)&&isNormalized
                return;
            end

            value=evaluatevars(value);

            if~isNormalized
                value=convertfrequnits(value,funits,'Hz');
            end

        end


        function b=hasUnappliedChanges(~,b,s1,s2,fxpt1,fxpt2)







        end


        function b=isDSTMode(this)






            b=isfdtbxinstalled&&~isFilterDesignerMode(this);


        end


        function flag=isFilterDesignerMode(this)



            flag=strcmpi(this.OperatingMode,'FilterDesigner');


        end


        function flag=isSystemObjectDesign(this)




            if~isDSTMode(this)
                flag=false;
                return;
            end

            flag=this.isSystemObjectEnabled&&(isSystemObjectMandatory(this)||this.SystemObject);

        end


        function flag=isSystemObjectEnabled(this)



            if~isDSTMode(this)
                flag=false;
                return;
            end

            currentStructure=convertStructure(this);
            validStructures=fdesign.getsysobjsupportedstructs;
            flag=any(strcmpi(validStructures,currentStructure));




        end


        function flag=isSystemObjectInputProc(this)



            structList={'dffir','dffirt','dfsymfir','dfasymfir',...
            'df1sos','df1tsos','df2sos','df2tsos',...
            'df1','df1t','df2','df2t'};

            flag=any(strcmp(structList,convertStructure(this,this.Structure)));



        end


        function flag=isSystemObjectMandatory(this)





            if~isDSTMode(this)||strcmpi(this.OperatingMode,'Simulink')||this.isSystemObjectDesignFailed
                flag=false;
                return;
            end

            currentStructure=convertStructure(this);
            validStructures=fdesign.getsysobjsupportedstructs('multirate');
            flag=any(strcmpi(validStructures,currentStructure));

        end


        function flag=isSystemObjectSupported(~)





            flag=true;
        end


        function b=isfir(this)


            b=strcmpi(this.ImpulseResponse,'fir');

        end


        function b=isminorder(this,laState)


            if nargin>1&&~isempty(laState)
                source=laState;
            else
                source=this;
            end

            b=strcmpi(source.OrderMode,'minimum');


        end


        function[b,str]=postApply(this)



            b=true;
            str='';

            if~any(strcmpi(this.OperatingMode,{'matlab','FilterDesigner'}))


                captureState(this);
            end

            notify(this,'DialogApplied',event.EventData);




        end


        function s=saveobj(this)



            s.class=class(this);

            s.OperatingMode=this.OperatingMode;
            s.VariableName=this.VariableName;
            s.ImpulseResponse=this.ImpulseResponse;
            s.OrderMode=this.OrderMode;
            s.Order=this.Order;
            s.FilterType=this.FilterType;
            s.Factor=this.Factor;
            s.SecondFactor=this.SecondFactor;
            s.FrequencyUnits=this.FrequencyUnits;
            s.InputSampleRate=this.InputSampleRate;
            s.MagnitudeUnits=this.MagnitudeUnits;
            s.LastAppliedState=this.LastAppliedState;
            s.LastAppliedSpecs=this.LastAppliedSpecs;
            s.LastAppliedDesignOpts=this.LastAppliedDesignOpts;
            s.LastAppliedImplementationOpts=this.LastAppliedImplementationOpts;
            if~isempty(s.LastAppliedImplementationOpts)

                if s.LastAppliedImplementationOpts{3}
                    s.LastAppliedImplementationOpts{3}='on';
                else
                    s.LastAppliedImplementationOpts{3}='off';
                end


                if s.LastAppliedImplementationOpts{8}
                    s.LastAppliedImplementationOpts{8}='on';
                else
                    s.LastAppliedImplementationOpts{8}='off';
                end


                if s.LastAppliedImplementationOpts{9}
                    s.LastAppliedImplementationOpts{9}='on';
                else
                    s.LastAppliedImplementationOpts{9}='off';
                end


                if s.LastAppliedImplementationOpts{10}
                    s.LastAppliedImplementationOpts{10}='on';
                else
                    s.LastAppliedImplementationOpts{10}='off';
                end


                if s.LastAppliedImplementationOpts{11}
                    s.LastAppliedImplementationOpts{11}='on';
                else
                    s.LastAppliedImplementationOpts{11}='off';
                end


                if s.LastAppliedImplementationOpts{12}
                    s.LastAppliedImplementationOpts{12}='on';
                else
                    s.LastAppliedImplementationOpts{12}='off';
                end


                if s.LastAppliedImplementationOpts{13}
                    s.LastAppliedImplementationOpts{13}='on';
                else
                    s.LastAppliedImplementationOpts{13}='off';
                end
            end
            s.InputProcessing=this.InputProcessing;
            s.RateOption=this.RateOption;
            if this.UseSymbolicNames
                s.UseSymbolicNames='on';
            else
                s.UseSymbolicNames='off';
            end
            s.CoefficientsName=this.CoefficientsName;
            s.NumeratorName=this.NumeratorName;
            s.DenominatorName=this.DenominatorName;
            s.ScaleValuesName=this.ScaleValuesName;

            if this.BuildUsingBasicElements
                s.BuildUsingBasicElements='on';
            else
                s.BuildUsingBasicElements='off';
            end

            if this.OptimizeZeros
                s.OptimizeZeros='on';
            else
                s.OptimizeZeros='off';
            end

            if this.OptimizeOnes
                s.OptimizeOnes='on';
            else
                s.OptimizeOnes='off';
            end

            if this.OptimizeNegOnes
                s.OptimizeNegOnes='on';
            else
                s.OptimizeNegOnes='off';
            end

            if this.OptimizeDelays
                s.OptimizeDelays='on';
            else
                s.OptimizeDelays='off';
            end

            if this.OptimizeUnitScaleValues
                s.OptimizeUnitScaleValues='on';
            else
                s.OptimizeUnitScaleValues='off';
            end

            s.isCoefficientsNameEnabled=this.isCoefficientsNameEnabled;
            s.isNumeratorNameEnabled=this.isNumeratorNameEnabled;
            s.isDenominatorNameEnabled=this.isDenominatorNameEnabled;
            s.isScaleValuesNameEnabled=this.isScaleValuesNameEnabled;
            s.SystemObject=this.SystemObject;

            s=thissaveobj(this,s);


            s.DesignMethod=this.DesignMethod;
            s.Structure=this.Structure;

            if this.Scale
                s.Scale='on';
            else
                s.Scale='off';
            end

            s.DesignOptionsCache=saveDesignOptions(this);

            s.FixedPoint=this.FixedPoint;
        end


        function selectComboboxEntry(this,hdlg,indx,prop,options)



            set(this,prop,options{indx+1});


        end


        function setCheckboxValue(this,prop,val)

            set(this,prop,val);
        end


        function setSpecsSafely(~,fdesignobj,spec)





            entries=set(fdesignobj,'Specification');
            if any(strcmpi(spec,entries))



                set(fdesignobj,'Specification',...
                validatestring(spec,fdesignobj.getAllowedStringValues('Specification')));
            end


        end


        function set_FilteringCodegenFlag(this,value)



            if value
                this.FilteringCodegenFlag=true;
            else
                this.FilteringCodegenFlag=false;
            end
        end


        function set_designmethod(this,oldDesignMethod)

            updateDesignOptions(this);
            updateStructure(this);
        end


        function frequnits=set_frequencyunits(~,frequnits)






        end


        function set_impulseresponse(this,oldImpulseResponse)




            impulseresponse=this.ImpulseResponse;


            if strcmpi(impulseresponse,'fir')&&strcmpi(this.MagnitudeUnits,'squared')
                this.MagnitudeUnits='db';
            elseif strcmpi(impulseresponse,'iir')&&strcmpi(this.MagnitudeUnits,'linear')
                this.MagnitudeUnits='db';
            end


            if strcmpi(impulseresponse,'iir')&&...
                ~strcmpi(this.FilterType,'single-rate')&&...
                ~allowsMultirate(this)
                set(this,'FilterType','single-rate')
            end


        end


        function inputsamplerate=set_inputsamplerate(~,inputsamplerate)




        end


        function set_structure(this,~)
            updateFixedPoint(this);
        end


        function set_filtertype(this,~)
            updateMethod(this);
            updateStructure(this);
        end


        function set_ordermode(this,oldordermode)

            updateMethod(this);
        end


        function set_systemobject(this,~)

            updateFixedPoint(this)
        end


        function b=supportsSLFixedPoint(~)




            b=false;


        end


        function dopts=thisDesignOptions(this,hd,method)



            if isFilterDesignerMode(this)
                dopts=designoptions(hd,method,'signalonly');
            else
                dopts=designoptions(hd,method);
            end

            if isfield(dopts,'SystemObject')
                dopts=rmfield(dopts,{'SystemObject','DefaultSystemObject'});
            end

        end


        function updateDesignOptions(this)



            hd=getFDesign(this,this);

            if isempty(hd)
                return;
            end


            methodEntries=getValidMethods(this,'short');
            method=getSimpleMethod(this);
            if~any(strcmpi(method,methodEntries))
                return
            end

            dopts=thisDesignOptions(this,hd,method);

            if isfield(dopts,'MinPhase')&&isfield(dopts,'MaxPhase')
                dopts=rmfield(dopts,{'MinPhase','MaxPhase'});
                dopts=rmfield(dopts,{'DefaultMinPhase','DefaultMaxPhase'});
                N=length(fieldnames(dopts));
                dopts.PhaseConstraint={'Linear','Minimum','Maximum'};
                dopts=orderfields(dopts,[1,N+1,2:N]);
                dopts.DefaultPhaseConstraint='Linear';
                dopts=orderfields(dopts,[1:N/2+2,N+2,N/2+3:N+1]);
            end

            fn=fieldnames(dopts);
            for indx=1:length(fn)/2

                if~any(strcmpi(fn{indx},...
                    {'FilterStructure','SOSScaleNorm','SOSScaleOpts'}))



                    p=findprop(this,fn{indx});



                    if isempty(p)
                        p=this.addprop(sprintf('Default%s',fn{indx}));
                        p.Hidden=true;

                        p=this.addprop(fn{indx});
                    end
                    p.AbortSet=true;

                    if iscell(dopts.(fn{indx}))
                        if strcmpi(fn{indx},'halfbanddesignmethod')
                            p.SetMethod=@set_halfbanddesignmethod;
                            dv='Equiripple';
                        else
                            dv=sentencecase(dopts.(sprintf('Default%s',fn{indx})));
                        end
                    elseif strcmpi(dopts.(fn{indx}),'bool')
                        dv=dopts.(sprintf('Default%s',fn{indx}));
                    else
                        dv=dopts.(sprintf('Default%s',fn{indx}));
                        if ischar(dv)
                            dv=['''',dv,''''];
                        else
                            dv=mat2str(dv);
                        end
                    end

                    if isequal(this.(sprintf('Default%s',fn{indx})),this.(fn{indx}))


                        if iscell(dv)
                            this.(fn{indx})=dv{:};
                            this.(sprintf('Default%s',fn{indx}))=dv{:};
                        else
                            this.(fn{indx})=dv;
                            this.(sprintf('Default%s',fn{indx}))=dv;
                        end
                    end

                    if strcmp(fn{indx},'MatchExactly')&&~strcmp(method,'ellip')&&...
                        (strcmpi(this.(fn{indx}),'both')||strcmpi(this.(sprintf('Default%s',fn{indx})),'both'))
                        if strcmp(method,'butter')
                            this.(fn{indx})='Stopband';
                            this.(sprintf('Default%s',fn{indx}))='Stopband';
                        elseif strcmp(method,'cheby1')
                            this.(fn{indx})='Passband';
                            this.(sprintf('Default%s',fn{indx}))='Passband';
                        elseif strcmp(method,'cheby2')
                            this.(fn{indx})='Stopband';
                            this.(sprintf('Default%s',fn{indx}))='Stopband';
                        end
                    end
                end
            end
        end

        function set_UniformGrid(this,value)
            value=logical(value);
            this.UniformGrid=value;
        end
        function value=get_UniformGrid(this)
            value=this.UniformGrid;
        end

        function set_JointOptimization(this,value)
            value=logical(value);
            this.JointOptimization=value;
        end
        function value=get_JointOptimization(this)
            value=this.JointOptimization;
        end


        function updateFixedPoint(this,~)



            if any(strcmpi(this.OperatingMode,{'Simulink','FilterDesigner'}))
                return;
            end

            if isempty(this.FixedPoint)
                this.FixedPoint=FilterDesignDialog.FixedPoint;
            end

            set(this.FixedPoint,'Structure',convertStructure(this,this.Structure));
            set(this.FixedPoint,'SystemObject',isSystemObjectDesign(this));


        end


        function updateMethod(this)




            if isempty(this.FDesign)
                return;
            end

            methods=getValidMethods(this);
            if isempty(methods)
                return
            end
            if isempty(find(strcmpi(this.DesignMethod,methods),1))
                this.DesignMethod=methods{1};
            else
                updateDesignOptions(this);
            end


        end


        function updateStructure(this)



            if isempty(this.FDesign)
                return;
            end

            [validStructures,defaultStructure]=getValidStructures(this,'full');

            if~isempty(validStructures)
                if~any(strcmp(this.Structure,validStructures))
                    this.Structure=defaultStructure;
                end
            end


        end

        function setPropValue(this,propName,propValue)
            if any(strcmpi(propName,{'SystemObject','SpecifyDenominator','Scale','UseSymbolicNames',...
                'OptimizeZeros','OptimizeOnes','OptimizeNegOnes',...
                'OptimizeDelays',...
                'OptimizeUnitScaleValues',...
                'BuildUsingBasicElements'}))&&ischar(propValue)
                if strcmpi(propValue,'1')
                    propValue=true;
                else
                    propValue=false;
                end
                if all((propValue~=this.(propName)))
                    this.(propName)=propValue;
                end
            elseif any(strcmpi(propName,{'FrequencyUnits','ImpulseResponse','OrderMode','FilterType',...
                'MagnitudeUnits','FrequencyConstraints','MagnitudeConstraints','ResponseType',...
                'Type','OrderMode2','CombType','PulseShape','Structure'}))
                entry_idx=find(contains(this.([propName,'Entries']),propValue));
                propValue=this.([propName,'Set']){entry_idx};%#ok<FNDSB>
                DAStudio.Protocol.setPropValue(this,propName,propValue);
            elseif strcmpi(propName,'VariableName')
                this.(propName)=propValue;
            else
                DAStudio.Protocol.setPropValue(this,propName,propValue);
            end

        end

        function value=getPropValue(this,propName)
            if any(strcmpi(propName,{'SystemObject','SpecifyDenominator','Scale','UseSymbolicNames',...
                'OptimizeZeros','OptimizeOnes','OptimizeNegOnes',...
                'OptimizeDelays',...
                'OptimizeUnitScaleValues',...
                'BuildUsingBasicElements'}))
                if this.(propName)
                    value='1';
                else
                    value='0';
                end
            elseif any(strcmpi(propName,{'FrequencyUnits','ImpulseResponse','OrderMode','FilterType',...
                'MagnitudeUnits','FrequencyConstraints','MagnitudeConstraints','ResponseType',...
                'Type','OrderMode2','CombType','PulseShape','Structure'}))
                value=DAStudio.Protocol.getPropValue(this,propName);
                set_idx=find(contains(this.([propName,'Set']),value));
                value=this.([propName,'Entries']){set_idx};%#ok<FNDSB>
            elseif strcmpi(propName,'VariableName')
                value=this.(propName);
            else
                value=DAStudio.Protocol.getPropValue(this,propName);
            end
        end

        function value=getPropDataType(~,propName)
            switch propName
            case{'SystemObject','SpecifyDenominator','UniformGrid','Scale',...
                'UseHalfbands','JointOptimization','ScalePassband',...
                'MinPhase','Zerophase','SpecifyCICRateChangeFactor','ZeroPhase',...
                'UseSymbolicNames','OptimizeZeros','OptimizeOnes','OptimizeNegOnes',...
                'OptimizeDelays',...
                'OptimizeUnitScaleValues',...
                'BuildUsingBasicElements'}
                value='bool';
            case{'ImpulseResponse','Order','InputSampleRate','Fpass','Fstop',...
                'Apass','Astop','DensityFactor','StopbandDecay',...
                'DenominatorOrder','Wpass','Wstop','F6dB','F3dB','Window',...
                'FrequencyConstraints','MagnitudeConstraints','OrderMode',...
                'DesignMethod','FrequencyUnits','MagnitudeUnits',...
                'MinOrder','Structure','StopbandShape','MatchExactly',...
                'PassbandOffset','MaxPoleRadius','UpsamplingFactor',...
                'NStages','Norm','InitNorm','InitNum','InitDen','Factor','SecondFactor',...
                'FilterType','Fstop1','Fstop2','Fpass1','Fpass2',...
                'Astop1','Astop2','F6dB1','F6dB2','F3dB1','F3dB2',...
                'BWpass','BWstop','Wstop1','Wstop2','Apass1','Apass2',...
                'Wpass1','Wpass2','NumNotches','Q','CombType','OrderMode2',...
                'BW','GBW','ShelvingFilterOrder','NumPeaksOrNotches',...
                'F0','DifferentialDelay','NumberOfSections','CICRateChangeFactor',...
                'WeightingClass','TransitionWidth','TW','Band','FracDelay',...
                'SincFrequencyFactor','SincPower','PulseShape',...
                'SamplesPerSymbol','NumberOfSymbols','Beta','AstopSQRT',...
                'BT','BandsPerOctave','Flow','Fhigh','Gref','G0','Gpass',...
                'Gstop','Gbc','Qa','S','Fc','ShelfType','ResponseType',...
                'InitOrder','Weights','B1Weights','B2Weights','B3Weights',...
                'B4Weights','B5Weights','B6Weights','B7Weights','B8Weights',...
                'B9Weights','B10Weights','B1ForcedFrequencyPoints',...
                'B2ForcedFrequencyPoints',...
                'B3ForcedFrequencyPoints',...
                'B4ForcedFrequencyPoints',...
                'B5ForcedFrequencyPoints',...
                'B6ForcedFrequencyPoints',...
                'B7ForcedFrequencyPoints',...
                'B8ForcedFrequencyPoints',...
                'B9ForcedFrequencyPoints',...
                'B10ForcedFrequencyPoints',...
                'InputWordLength','InputFractionLength1','InputProcessing','RateOption',...
                'NumeratorName','DenominatorName','ScaleValuesName',...
                }
                value='string';
            case{'NumberOfBands','NBands'}
                value='double';
            case 'VariableName'
                value='ustring';
            otherwise
                error(['Property ''',propName,''' must be added to the method getPropDataType in AbstractDesign Class.']);
            end
        end

    end












    methods(Static)

        function this=load(s)




            this=feval(s.class,'OperatingMode',s.OperatingMode);

            this.VariableName=s.VariableName;
            this.ImpulseResponse=s.ImpulseResponse;
            this.OrderMode=s.OrderMode;
            this.Order=s.Order;
            this.FilterType=s.FilterType;
            this.Factor=s.Factor;
            this.FrequencyUnits=s.FrequencyUnits;
            this.InputSampleRate=s.InputSampleRate;
            this.MagnitudeUnits=s.MagnitudeUnits;
            this.LastAppliedState=s.LastAppliedState;
            this.LastAppliedSpecs=s.LastAppliedSpecs;
            this.LastAppliedDesignOpts=s.LastAppliedDesignOpts;

            if isfield(s,'SystemObject')
                this.SystemObject=s.SystemObject;
            else
                this.SystemObject=false;
            end



            if isfield(s,'SecondFactor')
                this.SecondFactor=s.SecondFactor;
            end

            if isfield(s,'LastAppliedImplementationOpts')
                this.LastAppliedImplementationOpts=s.LastAppliedImplementationOpts;
                if strcmp(s.InputProcessing,'inherited')
                    if strcmp(s.BuildUsingBasicElements,'on')
                        s.InputProcessing='elementsaschannels';
                    else
                        s.InputProcessing='columnsaschannels';
                    end
                end
                this.InputProcessing=s.InputProcessing;
                this.RateOption=s.RateOption;
                if ischar(s.UseSymbolicNames)
                    this.UseSymbolicNames=strcmpi(s.UseSymbolicNames,'on');
                else
                    this.UseSymbolicNames=s.UseSymbolicNames;
                end
                this.CoefficientsName=s.CoefficientsName;
                this.NumeratorName=s.NumeratorName;
                this.DenominatorName=s.DenominatorName;
                this.ScaleValuesName=s.ScaleValuesName;
                if ischar(s.BuildUsingBasicElements)
                    this.BuildUsingBasicElements=strcmpi(s.BuildUsingBasicElements,'on');
                else
                    this.BuildUsingBasicElements=s.BuildUsingBasicElements;
                end

                if ischar(s.OptimizeZeros)
                    this.OptimizeZeros=strcmpi(s.OptimizeZeros,'on');
                else
                    this.OptimizeZeros=s.OptimizeZeros;
                end

                if ischar(s.OptimizeOnes)
                    this.OptimizeOnes=strcmpi(s.OptimizeOnes,'on');
                else
                    this.OptimizeOnes=s.OptimizeOnes;
                end

                if ischar(s.OptimizeNegOnes)
                    this.OptimizeNegOnes=strcmpi(s.OptimizeNegOnes,'on');
                else
                    this.OptimizeNegOnes=s.OptimizeNegOnes;
                end

                if ischar(s.OptimizeDelays)
                    this.OptimizeDelays=strcmpi(s.OptimizeDelays,'on');
                else
                    this.OptimizeDelays=s.OptimizeDelays;
                end

                if ischar(s.OptimizeUnitScaleValues)
                    this.OptimizeUnitScaleValues=strcmpi(s.OptimizeUnitScaleValues,'on');
                else
                    this.OptimizeUnitScaleValues=s.OptimizeUnitScaleValues;
                end

                this.isCoefficientsNameEnabled=s.isCoefficientsNameEnabled;
                this.isNumeratorNameEnabled=s.isNumeratorNameEnabled;
                this.isDenominatorNameEnabled=s.isDenominatorNameEnabled;
                this.isScaleValuesNameEnabled=s.isScaleValuesNameEnabled;
            else


                this.InputProcessing='columnsaschannels';
                this.RateOption='allowmultirate';
                this.BuildUsingBasicElements=true;
                this.OptimizeZeros=false;
                this.OptimizeOnes=false;
                this.OptimizeNegOnes=false;
                this.OptimizeDelays=false;
                this.OptimizeUnitScaleValues=false;
                this.UseSymbolicNames=false;
            end

            this.thisloadobj(s);



            this.DesignMethod=s.DesignMethod;
            this.Structure=s.Structure;
            if ischar(s.Scale)
                this.Scale=strcmpi(s.Scale,'on');
            else
                this.Scale=s.Scale;
            end

            if isprop(this,'UniformGrid')&&~isfield(s.DesignOptionsCache,'UniformGrid')
                s.DesignOptionsCache.UniformGrid=false;
            end

            loadDesignOptions(this,s);

            if~isFilterDesignerMode(this)...
                &&(supportsSLFixedPoint(this)||~strcmpi(this.OperatingMode,'simulink'))
                hFixedPoint=s.FixedPoint;
                if ishandle(s)
                    hFixedPoint=copy(hFixedPoint);
                end
                this.FixedPoint=hFixedPoint;
            end
        end


        function this=loadobj(s)






            this=feval([s.class,'.load'],s);

        end
    end



    methods(Hidden)

        function b=allowsMultirate(this)



            if strcmpi(this.ImpulseResponse,'fir')
                b=true;
            else
                if isempty(this.FDesign)
                    b=false;
                else
                    state=getState(this);
                    if strcmpi(state.FilterType,'single-rate')
                        state.FilterType='Decimator';
                    end
                    try
                        hfdesign=getFDesign(this,state);
                        b=~isempty(designmethods(hfdesign,'iir'));
                    catch %#ok<CTCH>
                        b=false;
                    end
                end
            end


        end


        function hfdesign=createMultiRateVersion(this,hfdesign,ftype,...
            factor,secondfactor)



            if~isDSTMode(this)
                return
            end

            switch lower(ftype)
            case 'decimator'
                hfdesign=fdesign.decimator(factor,hfdesign);
            case 'interpolator'
                hfdesign=fdesign.interpolator(factor,hfdesign);
            case 'sample-rate converter'
                hfdesign=fdesign.rsrc(factor,secondfactor,hfdesign);
            end


        end


        function dOrderWidgets=getDenOrderWidgets(this,row,col)



            dorder_chkbox.Name=FilterDesignDialog.message('DenOrder');
            dorder_chkbox.Type='checkbox';
            dorder_chkbox.Source=this;
            dorder_chkbox.Mode=true;
            dorder_chkbox.DialogRefresh=true;
            dorder_chkbox.RowSpan=[row,row];
            dorder_chkbox.ColSpan=[col,col];
            dorder_chkbox.Enabled=true;
            dorder_chkbox.Tag='SpecifyDenominator';
            dorder_chkbox.ObjectProperty='SpecifyDenominator';

            dorder.Type='edit';
            dorder.Source=this;
            dorder.Mode=true;
            dorder.DialogRefresh=true;
            dorder.RowSpan=[row,row];
            dorder.ColSpan=[col+1,col+1];
            dorder.Enabled=true;
            dorder.Tag='DenominatorOrder';
            dorder.ObjectProperty='DenominatorOrder';

            if isminorder(this)||~this.SpecifyDenominator
                dorder.Enabled=false;
            end

            if isminorder(this)
                dorder_chkbox.Enabled=false;
                dorder_chkbox.Visible=false;
                dorder.Visible=false;
            end

            dOrderWidgets={dorder_chkbox,dorder};

        end


        function specValues=getSpecificationsFromDialog(this,fdesPropNames)





            specValues=cell(size(fdesPropNames));

            for idx=1:numel(fdesPropNames)

                fdesPropName=fdesPropNames{idx};

                if strcmpi(fdesPropName,'B')
                    specValues{idx}=mat2str(this.NumberOfBands+1);

                elseif strncmpi(fdesPropName,'F',1)&&length(fdesPropName)==2
                    bandPropName=sprintf('Band%s',fdesPropName(end));
                    specValues{idx}=this.(bandPropName).Frequencies;

                elseif strncmpi(fdesPropName,'A',1)&&length(fdesPropName)==2
                    bandPropName=sprintf('Band%s',fdesPropName(end));
                    specValues{idx}=this.(bandPropName).Amplitudes;

                elseif strcmpi(fdesPropName,'F')
                    specValues{idx}=this.Band1.Frequencies;

                elseif strcmpi(fdesPropName,'A')
                    specValues{idx}=this.Band1.Amplitudes;

                elseif strcmpi(fdesPropName,'MatchExactly')
                    specValues{idx}=lower(this.MatchExactly);

                else


                    name=getFilterDesignDialogPropName(this,fdesPropName);
                    specValues{idx}=this.(name);
                end
            end
        end


        function flag=isBuildOptionEnabled(this)



            validStructuresFull=getValidStructures(this,'full');
            indx=strcmpi(validStructuresFull,this.Structure);
            validStructures=getValidStructures(this);
            classname=validStructures{indx};

            if strcmpi(classname(end-2:end),'src')||...
                (length(classname)>4&&...
                (strcmpi(classname(end-4:end),'decim')||strcmpi(classname(end-4:end),'nterp')))
                pkgname='mfilt';
            else
                pkgname='dfilt';
            end




            constructstr=dsp.internal.mfilt.mapInternalmfilt([pkgname,'.',classname]);
            H=feval(constructstr);

            flag=isblockable(H);


        end

        function successFlag=generateCodeForLiveTask(this)

            successFlag=true;
            try
                captureState(this);
                this.LastAppliedFilter=[];
                hBuffer=getMCodeBufferFilterDesigner(this);
                str=string(hBuffer);
                this.OutputCode=str;



            catch
                successFlag=false;
            end
        end


        function[b,str]=preApply(this)



            b=true;
            str='';

            variableName=get(this,'VariableName');



            if~isvarname(variableName)
                b=false;
                if any(variableName(:)>256)
                    str=getString(message('FilterDesignLib:FilterDesignDialog:fbMustBeAsciiVarName'));
                else
                    str=getString(message('FilterDesignLib:FilterDesignDialog:fbMustBeValidVarName'));
                end
                return;
            end



            captureState(this);



            this.LastAppliedFilter=[];





            try
                if isFilterDesignerMode(this)


                    w=warning('off');
                end
                [Hd,same]=design(this);
                if isFilterDesignerMode(this)
                    warning(w);
                end
            catch e
                if isFilterDesignerMode(this)
                    warning(w);
                end
                b=false;
                str=cleanerrormsg(e.message);
                return;
            end


            if strcmpi(this.OperatingMode,'matlab')
                assignin('base',variableName,Hd);
                fprintf('%s\n',getString(message('FilterDesignLib:FilterDesignDialog:fbVariableExportToWorkspace',variableName)));
            elseif isFilterDesignerMode(this)

                hBuffer=getMCodeBufferFilterDesigner(this);
                str=string(hBuffer);
                this.OutputCode=str;

                if strcmpi(this.CorrectCodeMode,'AddCodeToCommandLine')
                    disp(str);
                    evalin('base',str);
                else
                    this.DfiltDesign=Hd;
                end
            elseif~same

                this.LastAppliedSpecs=[];
                this.LastAppliedDesignOpts=[];
            end
        end


        function setSpecificationsFromPropertyValues(this,inputObj)









            if isa(inputObj,'dfilt.basefilter')
                fdesObj=getfdesign(inputObj);
            else
                fdesObj=inputObj;
            end
            fdesignNames=signal.internal.DesignfiltProcessCheck.getSpecPropertiesFromFdesign(fdesObj,true);
            designfiltNames=signal.internal.DesignfiltProcessCheck.getSpecPropertiesFromFdesign(fdesObj);

            for idx=1:numel(designfiltNames)

                desFilterPropName=designfiltNames{idx};
                propIdx=strcmp(this.PropertyNames,desFilterPropName);

                if any(propIdx)



                    userPropValue=getUserPropValue(this,propIdx);

                    if strcmpi(desFilterPropName,'FilterOrder')
                        this.OrderMode='specify';
                        this.Order=userPropValue;

                    elseif strcmpi(desFilterPropName,'DenominatorOrder')
                        this.SpecifyDenominator=true;
                        this.OrderMode='specify';
                        this.DenominatorOrder=userPropValue;

                    elseif strcmpi(desFilterPropName,'NumeratorOrder')
                        this.SpecifyDenominator=true;
                        this.OrderMode='specify';
                        this.Order=userPropValue;

                    elseif strcmpi(desFilterPropName,'NumBands')




                    elseif strncmpi(desFilterPropName,'BandFrequencies',length('BandFrequencies'))
                        bandPropName=sprintf('Band%s',desFilterPropName(end));
                        this.(bandPropName).Frequencies=userPropValue;

                    elseif strncmpi(desFilterPropName,'BandAmplitudes',length('BandAmplitudes'))
                        bandPropName=sprintf('Band%s',desFilterPropName(end));
                        this.(bandPropName).Amplitudes=userPropValue;

                    elseif strcmpi(desFilterPropName,'Frequencies')
                        this.Band1.Frequencies=userPropValue;

                    elseif strcmpi(desFilterPropName,'Amplitudes')
                        this.Band1.Amplitudes=userPropValue;

                    else


                        name=getFilterDesignDialogPropName(this,fdesignNames{idx});
                        this.(name)=userPropValue;
                    end
                end
            end


            propIdx=strcmpi(this.PropertyNames,'SampleRate');
            if any(propIdx)
                userPropValue=getUserPropValue(this,propIdx);
                set(this,'FrequencyUnits','Hz','InputSampleRate',userPropValue);
            end
        end


        function setSystemObjectDesignFailed(this,flag)





            this.isSystemObjectDesignFailed=flag;
        end


        function b=supportsAnalysis(~)



            b=true;


        end

        function s=saveDesignOptions(this)

            hfd=get(this,'FDesign');


            methodEntries=getValidMethods(this,'short');
            method=getSimpleMethod(this);
            if any(strcmpi(method,methodEntries))
                optstruct=thisDesignOptions(this,hfd,method);
                if isfield(optstruct,'MinPhase')&&isfield(optstruct,'MaxPhase')
                    optstruct=rmfield(optstruct,{'MinPhase','MaxPhase'});
                    optstruct=rmfield(optstruct,{'DefaultMinPhase','DefaultMaxPhase'});
                    N=length(fieldnames(optstruct));
                    optstruct.PhaseConstraint={'Linear','Minimum','Maximum'};
                    optstruct=orderfields(optstruct,[1,N+1,2:N]);
                    optstruct.DefaultPhaseConstraint='Linear';
                    optstruct=orderfields(optstruct,[1:N/2+2,N+2,N/2+3:N+1]);
                end
                fn=fieldnames(optstruct);


                fn=fn(1:length(fn)/2);

                s=[];

                for indx=1:length(fn)

                    if~isempty(setdiff(fn{indx},{'FilterStructure','SOSScaleNorm','SOSScaleOpts'}))
                        s.(fn{indx})=this.(fn{indx});
                    end
                end
            else
                s=this.DesignOptionsCache;
            end
        end


        function userPropValue=getUserPropValue(this,propIdx)


            if~isempty(this.PropertyValueNames{propIdx})
                userPropValue=this.PropertyValueNames{propIdx};
            else
                userPropValue=this.PropertyValues{propIdx};
            end
        end

        function e=set_halfbanddesignmethod(this,e)

            switch lower(e)
            case 'equiripple'
                e='Equiripple';
            case 'kaiserwin'
                e='Kaiser window';
            case 'butterworth'
                e='Butterworth';
            case 'ellip'
                e='Elliptic';
            case 'iirlinphase'
                e='IIR quasi-linear phase';
            otherwise
                if~any(strcmpi(e,{'Equiripple','Kaiser window','Butterworth',...
                    'Elliptic','IIR quasi-linear phase'}))
                    error(message('FilterDesignLib:FilterDesignDialog:AbstractDesign:updateDesignOptions:InvalidEnum1'));
                end
            end
            this.HalfbandDesignMethod=e;
        end


        function launchfvtool(this)

            hfvt=this.FVTool;
            if~isempty(hfvt)&&isa(hfvt,'sigtools.fvtool')&&isvalid(hfvt)
                figure(hfvt);
                return
            end

            Hd=this.LastAppliedFilter;
            if isempty(Hd)

                Hd=design(this);
            end

            normFlag=get(Hd.getfdesign,'NormalizedFrequency');
            if normFlag
                normFlag='on';
            else
                normFlag='off';
            end

            if isSystemObjectDesign(this)
                this.LaunchFixedPointAnalysisWarning=true;
                wId1='dsp:dsp:private:FilterSystemObjectBase:DefaultCoeffDataTypeFIR';
                wId2='dsp:dsp:private:FilterSystemObjectBase:DefaultCoeffDataTypeSOS';
                wState1=warning('QUERY',wId1);
                wState2=warning('QUERY',wId2);
                c=onCleanup(@()restoreWarningState(this,wState1,wState2));
                warning('off',wId1);
                warning('off',wId2);

                idx=strfind(this.FixedPoint.Arithmetic,' ');
                arith=this.FixedPoint.Arithmetic(1:idx-1);
                if~isCICFilter(Hd)&&strcmpi(arith,'fixed')&&...
                    strcmpi(this.FixedPoint.CoeffMode,'same word length as input')
                    warndlg(FilterDesignDialog.message('WarnDefaultCoeffDataType'),...
                    getDialogTitle(this));

                    this.LaunchFixedPointAnalysisWarning=false;
                end
                hfvt=fvtool(Hd,'Arithmetic',arith,'NormalizedFrequency',normFlag);
                warning(wState1)
                warning(wState2)
            else
                hfvt=fvtool(Hd,'NormalizedFrequency',normFlag);
            end


            l=event.listener(this,'DialogApplied',@(h,ed)refresh_fvtool(this,hfvt));
            setappdata(hfvt,'DialogAppliedListener',l);

            this.FVTool=hfvt;
        end


        function refresh_fvtool(this,hfvt)

            Hd=this.LastAppliedFilter;
            if~isempty(Hd)&&isprop(hfvt,'NormalizedFrequency')
                normFlag=get(Hd.getfdesign,'NormalizedFrequency');
                if normFlag
                    normFlag='on';
                else
                    normFlag='off';
                end
                hfvt.NormalizedFrequency=normFlag;
            end

            d=design(this);

            if isSystemObjectDesign(this)
                wId1='dsp:dsp:private:FilterSystemObjectBase:DefaultCoeffDataTypeFIR';
                wId2='dsp:dsp:private:FilterSystemObjectBase:DefaultCoeffDataTypeSOS';
                wState1=warning('QUERY',wId1);
                wState2=warning('QUERY',wId2);
                c=onCleanup(@()restoreWarningState(this,wState1,wState2));
                warning('off',wId1);
                warning('off',wId2);

                idx=strfind(this.FixedPoint.Arithmetic,' ');
                arith=this.FixedPoint.Arithmetic(1:idx-1);

                if this.LaunchFixedPointAnalysisWarning&&~isCICFilter(d)&&...
                    strcmpi(arith,'fixed')&&...
                    strcmpi(this.FixedPoint.CoeffMode,'same word length as input')
                    warndlg(FilterDesignDialog.message('WarnDefaultCoeffDataType'),...
                    getDialogTitle(this));

                    this.LaunchFixedPointAnalysisWarning=false;
                end

                d=todfilt(Hd,arith);

                warning(wState1)
                warning(wState2)
            end

            d.FromFilterBuilderFlag=true;
            c1=onCleanup(@()resetFromFilterBuilderFlag(this,d));
            hfvt.Filters=d;

            d.FromFilterBuilderFlag=false;
        end


        function hdl(this)

            hHdl=this.HDLObj;
            hDlg=this.HDLDialog;

            if isempty(hDlg)
                Hd=this.LastAppliedFilter;
                if isempty(Hd)

                    Hd=design(this);
                end
                [cando,~,errObj]=ishdlable(Hd);
                if cando&&isSystemObjectDesign(this)
                    Hd=getDfiltObject(this.FixedPoint,Hd);
                    [cando,~,errObj]=ishdlable(Hd);
                end

                if~cando
                    error(errObj);
                    return;
                end


                hHdl=fdhdlcoderui.fdhdltooldlg(Hd);
                hHdl.setfiltername(this.VariableName);
                hDlg=DAStudio.Dialog(hHdl);
                this.HDLDialog=hDlg;
                this.HDLObj=hHdl;
            elseif~ishandle(hDlg)
                hDlg=DAStudio.Dialog(hHdl);
                this.HDLDialog=hDlg;
            end
            l=event.listener(this,'DialogApplied',...
            @(h,ed)refresh_hdldlg(this,hHdl,hDlg));
            setappdata(hHdl,'Listeners',l);
        end


        function mcode(this,varargin)


            if~isempty(varargin)


                file=varargin{1};
                if~contains(file,'.')
                    file=[file,'.m'];
                end
                [~,funcName]=fileparts(file);
            else
                funcName='getFilter';
            end


            strBuff=StringWriter;


            if isSystemObjectDesign(this)
                H1MsgId='ReturnsADiscreteTimeFilterSystemObject';
            else
                H1MsgId='ReturnsADiscreteTimeFilterObject';
            end
            outputArgs='Hd';
            strBuff.addcr('function %s = %s',outputArgs,funcName);
            strBuff.addcr('%%%s %s',upper(funcName),FilterDesignDialog.message(H1MsgId));
            if~isempty(license('inuse','Signal_Blocks'))
                tbox='dsp';
            else
                tbox='signal';
            end
            strBuff.craddcr('%s',sptfileheader('MATLAB Code',tbox));
            strBuff.addcr;


            mcodebuffer=getMCodeBuffer(this);
            strBuff.addcr(mcodebuffer.string);
            strBuff.indentCode('matlab');


            if~isempty(varargin)
                strBuff.write(file);
            else
                matlab.desktop.editor.newDocument(string(strBuff));
            end
        end


        function mcodefiltering(this,varargin)


            if~isempty(varargin)

                file=varargin{1};
                if~contains(file,'.')
                    file=[file,'.m'];
                end
                [~,funcName]=fileparts(file);
            else
                funcName='doFilter';
            end

            mcodebuffer=sigcodegen.mcodebuffer;



            supportsCodegenFlag=...
            ~(strcmpi('Decimator',this.FilterType)&&...
            strcmpi(this.Structure,'Direct-form transposed FIR polyphase decimator'));

            supportsCodegenFlag=supportsCodegenFlag&&...
            ~strcmp('Cascade minimum-multiplier allpass',this.Structure)&&...
            ~strcmp('Cascade wave digital filter allpass',this.Structure);

            if isSystemObjectDesign(this)&&supportsCodegenFlag

                mcodebuffer.addcr(['  % ',FilterDesignDialog.message('CCodegenCommandLineHelp')]);
                mcodebuffer.addcr;
            end

            Hd=this.LastAppliedFilter;
            isFilterCascade=isa(Hd,'dsp.FilterCascade');
            if~isFilterCascade
                mcodebuffer.addcr('persistent Hd;');
                mcodebuffer.addcr;
                mcodebuffer.addcr('if isempty(Hd)');
            end
            mcodebuffer.addcr;
            commentedLinesOffset=lines(mcodebuffer);

            if isSystemObjectDesign(this)

                mcodebuffer.addcr(FilterDesignDialog.message('FDESIGNComments'));
                mcodebuffer.addcr;
            end


            getMCodeBuffer(this,isSystemObjectDesign(this),mcodebuffer);

            if isSystemObjectDesign(this)

                mcodebuffer.MaxWidth=mcodebuffer.MaxWidth+2;
                commentlines(mcodebuffer,commentedLinesOffset,'end')
                mcodebuffer.addcr;
                mcodebuffer.addcr;


                if~isFilterCascade
                    getMCodeBufferSysObj(this,mcodebuffer);
                else
                    mcodebuffer.addcr(getConstructionString(Hd));
                end
            else

                mcodebuffer.addcr;
                mcodebuffer.addcr;
                mcodebuffer.addcr('set(Hd,''PersistentMemory'',true);')
            end

            if~isFilterCascade
                mcodebuffer.addcr;
                mcodebuffer.addcr('end');
                mcodebuffer.addcr;
            end

            if isSystemObjectDesign(this)
                DT=this.FixedPoint.Arithmetic;
                if strcmp(DT,'Fixed point')
                    SG='1';
                    WL=this.FixedPoint.InputWordLength;
                    FL=this.FixedPoint.InputFracLength1;

                    if isFilterCascade
                        mcodebuffer.addcr(getStepString(Hd,DT,SG,WL,FL));
                    else
                        mcodebuffer.addcr(sprintf('s = fi(x,%s,%s,%s,''RoundingMethod'', ''Round'', ''OverflowAction'', ''Saturate'');',SG,WL,FL));
                        mcodebuffer.addcr('y = step(Hd,s);');
                    end
                elseif isFilterCascade

                    mcodebuffer.addcr(getStepString(Hd,DT));
                else

                    if strcmp(DT,'Single precision')
                        mcodebuffer.addcr('s = single(x);');
                    else
                        mcodebuffer.addcr('s = double(x);');
                    end
                    mcodebuffer.addcr('y = step(Hd,s);');
                end
                if supportsCodegenFlag

                    mcodebuffer.insert(1,sprintf('%s \n','%#codegen'));
                end
            else

                mcodebuffer.addcr('y = filter(Hd,x);');
            end


            strBuff=StringWriter;


            H1=FilterDesignDialog.message('ReturnsFilteredData');
            strBuff.addcr('function y = %s(x)',funcName);
            strBuff.addcr('%%%s %s',upper(funcName),H1);
            if~isempty(license('inuse','Signal_Blocks'))
                tbox='dsp';
            else
                tbox='signal';
            end
            strBuff.craddcr('%s',sptfileheader('MATLAB Code',tbox));
            strBuff.addcr;


            strBuff.addcr(mcodebuffer.string);
            strBuff.indentCode('matlab');


            if~isempty(varargin)
                strBuff.write(file);
            else
                matlab.desktop.editor.newDocument(string(strBuff));
            end
        end


        function block(this)

            hdsp=this.DSPFWIZ;
            if isempty(hdsp)||~isa(hdsp,'siggui.dspfwiz')

                Hd=this.LastAppliedFilter;

                if isempty(Hd)

                    Hd=design(this);
                end


                Hd=getDfiltObject(this.FixedPoint,Hd);

                if strcmp(this.Structure,'Overlap-add FIR')
                    blocksetup(Hd);
                end

                hdsp=siggui.dspfwiz(Hd);





                hdsp.BlockName=this.VariableName;
                this.DSPFWIZ=hdsp;
            else
                refresh_dspfwizdlg(this,hdsp);
            end


            dialog(hdsp);







            l=event.listener(this,'DialogApplied',@(h,ed)refresh_dspfwizdlg(this,hdsp));

            setappdata(hdsp.FigureHandle,'Listeners',l);
        end


        function refresh_dspfwizdlg(this,hdsp)

            Hd=design(this);
            Hd=getDfiltObject(this.FixedPoint,Hd);

            if strcmp(this.Structure,'Overlap-add FIR')
                blocksetup(Hd);
            end

            hdsp.Filter=Hd;
        end


        function refresh_hdldlg(this,hhdl,hhdldlg)

            Hd=design(this);


            [cando,errmsg,~]=ishdlable(Hd);
            if cando&&isSystemObjectDesign(this)

                Hd=getDfiltObject(this.FixedPoint,Hd);
                [cando,errmsg,~]=ishdlable(Hd);
            end

            if~cando
                errordlg(errmsg,'Filter HDL coder');
                return;
            end


            hhdl.setfilter(Hd);
            hhdl.setfiltername(this.VariableName);
            if~isempty(hhdldlg)&&ishandle(hhdldlg)
                hhdldlg.refresh;
            end
        end


        function b=lclHasUnappliedChanges(this,hdlg)


            if isempty(hdlg)
                b=false;
            else

                b=hdlg.hasUnappliedChanges;
                if b

                    fl={'ActiveTab','OperatingMode','FixedPoint'};
                    s1=rmfield(get(this),fl);
                    that=eval(class(this));
                    s2=rmfield(get(that),fl);
                    fxpt1=get(this.FixedPoint);
                    fxpt2=get(that.FixedPoint);
                    if isequal(s1,s2)&&isequal(fxpt1,fxpt2)
                        b=false;
                    end



                    b=hasUnappliedChanges(this,b,s1,s2,fxpt1,fxpt2);
                end
            end
        end


        function options=getOptionsStatic(this,startrow)


            opts=get(this,'DesignOptionsCache');

            if isempty(opts)
                options=[];
                return;
            end

            fn=fieldnames(opts);
            items={};
            for indx=1:length(fn)
                text=[];
                v=opts.(fn{indx});
                if islogical(v)
                    text.Type='checkbox';
                    haslabel=false;
                else
                    text.Type='text';
                    haslabel=true;
                end

                col=[0,0];
                row=[indx,indx];
                name=FilterDesignDialog.message(fn{indx});

                if haslabel
                    label.RowSpan=row;
                    label.ColSpan=col+1;
                    label.Type='text';
                    label.Name=name;
                    label.Tag=sprintf('%sLabel',fn{indx});
                    label.Tunable=1;

                    text.ColSpan=col+2;
                    text.Name=opts.(fn{indx});
                else
                    text.Name=name;
                    text.Value=opts.(fn{indx});
                    text.ColSpan=col+[1,2];
                end

                text.RowSpan=row;
                text.Tag=fn{indx};
                text.Enabled=false;
                switch lower(fn{indx})
                case 'halfbanddesignmethod'
                    if isfield(opts,'UseHalfbands')&&~this.UseHalfbands
                        text.Visible=false;
                        label.Visible=false;
                    end
                end
                if haslabel
                    items={items{:},label};%#ok<CCAT>
                end
                items={items{:},text};%#ok<CCAT>
            end

            if isempty(items)
                options=[];
            else
                options.Type='togglepanel';
                options.Name=FilterDesignDialog.message('DesignOpts');
                options.Items=items;
                options.Tag='DesignOptionsToggle';
                options.LayoutGrid=[length(fn),2];
                options.ColStretch=[0,1];
                options.RowSpan=[startrow,startrow];
                options.ColSpan=[1,2];
            end
        end


        function options=getOptions(this,startrow)

            options=[];

            hd=this.FDesign;
            setSpecsSafely(this,hd,getSpecification(this));


            methodEntries=getValidMethods(this,'short');
            method=getSimpleMethod(this);
            if~any(strcmpi(method,methodEntries))
                return
            end

            dopts=thisDesignOptions(this,hd,method);

            dopts=rmfield(dopts,{'FilterStructure','DefaultFilterStructure'});
            if isfield(dopts,'SOSScaleOpts')
                dopts=rmfield(dopts,{'SOSScaleOpts','DefaultSOSScaleOpts'});
            end
            if isfield(dopts,'SOSScaleNorm')
                dopts=rmfield(dopts,{'SOSScaleNorm','DefaultSOSScaleNorm'});
            end
            if isfield(dopts,'MinPhase')&&isfield(dopts,'MaxPhase')
                dopts=rmfield(dopts,{'MinPhase','MaxPhase'});
                dopts=rmfield(dopts,{'DefaultMinPhase','DefaultMaxPhase'});
                N=length(fieldnames(dopts));
                dopts.PhaseConstraint={'Linear','Minimum','Maximum'};
                dopts=orderfields(dopts,[1,N+1,2:N]);
                dopts.DefaultPhaseConstraint='Linear';
                dopts=orderfields(dopts,[1:N/2+2,N+2,N/2+3:N+1]);
            end

            fn=fieldnames(dopts);

            items={};


            tunable=~isminorder(this)&&this.BuildUsingBasicElements;

            for indx=1:length(fn)/2
                edit=[];
                v=dopts.(fn{indx});
                if iscell(v)
                    edit.Type='combobox';
                    edit.Editable=false;





                    Options=FilterDesignDialog.message(strrep(v,'/','_'));
                    edit.Entries=Options;
                    haslabel=true;
                elseif strcmpi(v,'bool')
                    edit.Type='checkbox';
                    haslabel=false;
                else
                    edit.Type='edit';
                    haslabel=true;
                end

                col=[0,0];
                row=[indx,indx];
                name=FilterDesignDialog.message(fn{indx});

                if haslabel
                    label.RowSpan=row;
                    label.ColSpan=col+1;
                    label.Type='text';
                    label.Name=name;
                    label.Tag=sprintf('%sLabel',fn{indx});
                    label.Tunable=tunable;

                    edit.ColSpan=col+2;
                    edit.Name='';
                else
                    edit.Name=name;
                    edit.ColSpan=col+[1,2];
                end

                edit.Source=this;
                edit.ObjectProperty=fn{indx};
                edit.RowSpan=row;
                edit.Tag=fn{indx};
                edit.Mode=true;
                edit.Tunable=tunable;

                if strcmpi(edit.Type,'combobox')

                    edit.ObjectMethod='selectComboboxEntry';
                    if strcmpi(fn{indx},'HalfbandDesignMethod')
                        op={'Equiripple','Kaiser window',...
                        'Butterworth','Elliptic','IIR quasi-linear phase'};
                        edit.MethodArgs={'%dialog','%value','HalfbandDesignMethod',op};


                        defaultindx=find(strcmp(op,this.(fn{indx})));
                        if~isempty(defaultindx)
                            edit.Value=defaultindx-1;
                        end
                    else
                        edit.MethodArgs={'%dialog','%value',fn{indx},sentencecase(v)};


                        defaultindx=find(strcmp(sentencecase(v),this.(fn{indx})));
                        if~isempty(defaultindx)
                            edit.Value=defaultindx-1;
                        end
                    end
                    edit.ArgDataTypes={'handle','mxArray','string','mxArray'};




                    edit.Mode=false;




                    edit=rmfield(edit,'ObjectProperty');

                end
                switch lower(fn{indx})
                case 'usehalfbands'
                    edit.DialogRefresh=true;
                case 'halfbanddesignmethod'
                    if isfield(dopts,'UseHalfbands')&&~this.UseHalfbands
                        edit.Visible=false;
                        label.Visible=false;
                    else


                        Options={'equiripple','kaiserwin',...
                        'butter','ellip','iirlinphase'};
                        Options=FilterDesignDialog.message(Options);
                        edit.Entries=Options;
                    end
                end

                if haslabel
                    items={items{:},label};%#ok<CCAT>
                end

                items={items{:},edit};%#ok<CCAT>
            end



            if isempty(items)
                options=[];
            else
                options.Type='togglepanel';
                options.Name=FilterDesignDialog.message('DesignOpts');
                options.Items=items;
                options.Tag='DesignOptionsToggle';
                options.LayoutGrid=[length(fn)/2,2];
                options.ColStretch=[0,1];
                options.RowSpan=[startrow,startrow];
                options.ColSpan=[1,2];
            end
        end


        function codegen=getCodeGenTab(this)

            mcode_label.Type='text';
            mcode_label.Name=FilterDesignDialog.message('McodePanelTxt');
            mcode_label.RowSpan=[1,1];
            mcode_label.ColSpan=[1,2];
            mcode_label.WordWrap=true;

            mcoderadiobutton.Type='radiobutton';
            mcoderadiobutton.Entries={FilterDesignDialog.message('FilteringCodegenRadioButtonTxt'),FilterDesignDialog.message('McodeRadioButtonTxt')};
            mcoderadiobutton.ObjectMethod='set_FilteringCodegenFlag';
            mcoderadiobutton.MethodArgs={'%value'};
            mcoderadiobutton.ArgDataTypes={'mxArray'};
            mcoderadiobutton.Enabled=true;
            mcoderadiobutton.RowSpan=[2,2];
            mcoderadiobutton.ColSpan=[1,2];
            mcoderadiobutton.Values=[0,1];
            mcoderadiobutton.Mode=true;
            mcoderadiobutton.Graphical=true;

            if this.FilteringCodegenFlag
                mcoderadiobutton.Value=1;
            else
                mcoderadiobutton.Value=0;
            end

            mcodepanel.Items={mcode_label,mcoderadiobutton};

            mcode.Type='pushbutton';
            mcode.Name=FilterDesignDialog.message('McodePushbuttonTxt');
            mcode.ObjectMethod='export';
            mcode.Tag='mcode';
            mcode.MethodArgs={'%dialog','mcode',true,FilterDesignDialog.message('GeneratingMATLABCode'),''};
            mcode.ArgDataTypes={'handle','string','bool','string','string'};
            mcode.Source=this;
            mcode.ToolTip=FilterDesignDialog.message('WriteMATLABFileToolTipTxt');
            mcode.Enabled=true;
            mcode.RowSpan=[3,3];
            mcode.ColSpan=[2,2];

            mcodepanel.Name=FilterDesignDialog.message('McodePanelName');
            mcodepanel.Type='group';
            mcodepanel.RowSpan=[2,2];
            mcodepanel.ColSpan=[1,1];
            mcodepanel.ColStretch=[1,0];
            mcodepanel.LayoutGrid=[1,2];
            mcodepanel.Items=[mcodepanel.Items,{mcode}];

            items={mcodepanel};

            sysObjDesign=isSystemObjectDesign(this);

            issingle=strcmpi(this.FixedPoint.Arithmetic,'Single precision');

            if isfdhdlcinstalled&&~(sysObjDesign&&issingle)

                hdl_label.Type='text';
                hdl_label.Name=FilterDesignDialog.message('HDLPanelTxt');
                hdl_label.RowSpan=[1,1];
                hdl_label.ColSpan=[1,2];
                hdl_label.WordWrap=true;

                hdl.Type='pushbutton';
                hdl.Name=FilterDesignDialog.message('HDLPushbuttonTxt');
                hdl.ObjectMethod='export';
                hdl.Tag='hdl';
                hdl.MethodArgs={'%dialog','hdl',true,FilterDesignDialog.message('GeneratingHDL'),''};
                hdl.ArgDataTypes={'handle','string','bool','string','string'};
                hdl.Source=this;
                hdl.ToolTip=FilterDesignDialog.message('HDLToolTipTxt');
                hdl.Enabled=true;
                hdl.RowSpan=[2,2];
                hdl.ColSpan=[2,2];

                hdlpanel.Name=FilterDesignDialog.message('HDLPanelName');
                hdlpanel.Type='group';
                hdlpanel.Items={hdl_label,hdl};
                hdlpanel.RowSpan=[1,1];
                hdlpanel.ColSpan=[1,1];
                hdlpanel.ColStretch=[1,0];
                hdlpanel.LayoutGrid=[1,2];
                items={items{:},hdlpanel};%#ok<CCAT>
            end

            enableGenerateModelButton=true;
            if sysObjDesign&&isprop(this.FixedPoint,'Arithmetic')&&...
                strcmpi(this.FixedPoint.Arithmetic,'fixed point')
                currentStructure=convertStructure(this);
                validStructures=fdesign.getsysobjsupportedstructs('ModelGenerationWithFixedPoint');
                enableGenerateModelButton=any(strcmpi(validStructures,currentStructure));
            end

            if issimulinkinstalled

                simulink_label.Type='text';
                simulink_label.Name=FilterDesignDialog.message('SimulinkPanelTxt');
                simulink_label.RowSpan=[1,1];
                simulink_label.ColSpan=[1,2];

                block.Type='pushbutton';
                block.Name=FilterDesignDialog.message('SimulinkPushbuttonTxt');
                block.ObjectMethod='export';
                block.Tag='block';
                block.MethodArgs={'%dialog','block',true,FilterDesignDialog.message('GeneratingModel'),''};
                block.ArgDataTypes={'handle','string','bool','string','string'};
                block.Source=this;
                block.ToolTip=FilterDesignDialog.message('LaunchExportSimulinDialogToolTip');
                block.Enabled=enableGenerateModelButton;
                block.RowSpan=[2,2];
                block.ColSpan=[2,2];

                simulinkpanel.Name=FilterDesignDialog.message('SimulinkPanelName');
                simulinkpanel.Type='group';
                simulinkpanel.Items={simulink_label,block};
                simulinkpanel.RowSpan=[3,3];
                simulinkpanel.ColSpan=[1,1];
                simulinkpanel.ColStretch=[1,0];
                simulinkpanel.LayoutGrid=[2,2];

                items={items{:},simulinkpanel};%#ok<CCAT>
            end

            codegen.Name=FilterDesignDialog.message('CodegenTabName');
            codegen.Items=items;
            codegen.Tag='CodeGenerationTab';
            codegen.RowStretch=[0,0,0,0,1];
            codegen.LayoutGrid=[5,1];
        end


        function fixpt=getFixedPointTab(this)

            h=this.FixedPoint;

            items={getDialogSchemaStruct(h)};

            fixpt.Name=FilterDesignDialog.message('DataTypeTabName');
            fixpt.Items=items;
            fixpt.Tag='FixedPointTab';
        end


        function[items,type,idx]=addStructureComboxboxAndLabel(this)


            idx=[1,1];
            [structure_lbl,structure]=getWidgetSchema(this,'Structure',...
            FilterDesignDialog.message('structure'),...
            'combobox',idx,1);

            structure.DialogRefresh=true;
            structure.Enabled=true;

            issos=false;
            isfarrow=false;
            isdtfiir=false;
            iscascadeallpass=false;
            isiirmultirate=false;


            validStructures=getValidStructures(this);

            structure.Entries=FilterDesignDialog.message(validStructures);
            validStructuresFull=getValidStructures(this,'full');

            indx=find(strcmpi(validStructuresFull,this.Structure));
            if isempty(indx)
                indx=1;
            end
            classname=validStructures{indx};
            if strcmpi(this.ImpulseResponse,'FIR')
                if length(classname)>6&&strncmpi(classname(1:6),'farrow',6)
                    isfarrow=true;
                end
            else
                if strcmpi(classname(end-2:end),'sos')
                    issos=true;
                elseif any(strcmp(classname,{'df1','df2','df1t','df2t'}))
                    isdtfiir=true;
                elseif length(classname)>7&&strncmpi(classname(1:7),'cascade',7)
                    iscascadeallpass=true;
                elseif any(strcmp(classname,{'iirdecim','iirinterp','iirwdfdecim','iirwdfinterp'}))
                    isiirmultirate=true;
                end
            end
            if~isempty(indx)
                structure.Value=indx-1;
            end
            structure.ObjectMethod='selectComboboxEntry';
            structure.MethodArgs={'%dialog','%value','Structure',...
            validStructuresFull};
            structure.ArgDataTypes={'handle','mxArray','string','mxArray'};



            structure.Mode=false;



            structure=rmfield(structure,'ObjectProperty');

            items={structure_lbl,structure};

            type.issos=issos;
            type.isfarrow=isfarrow;
            type.isdtfiir=isdtfiir;
            type.iscascadeallpass=iscascadeallpass;
            type.isiirmultirate=isiirmultirate;
        end


        function[items,idx]=addFrameProcessing(this,idx,items)


            idx=idx+1;
            [inProcmode_lbl,inProcmode]=getInputProcessingFrame(this,idx);
            items=[items,{inProcmode_lbl,inProcmode}];
        end


        function[items,idx]=addRateOptions(this,idx,items)

            idx=idx+1;
            [rate_lbl,rate]=getRateOptionFrame(this,idx);

            if strcmpi(this.Impulseresponse,'fir')
                if~strcmpi(this.FilterType,'single-rate')
                    items=[items,{rate_lbl,rate}];
                end
            end
        end


        function[items,idx]=addTunabilityWidgets(this,type,idx)


            idx=idx+1;
            str='map';
            tune.Name=FilterDesignDialog.message(str);
            tune.Type='checkbox';
            tune.Source=this;
            tune.ObjectProperty='UseSymbolicNames';
            tune.Mode=false;
            tune.ObjectMethod='setCheckboxValue';
            tune.MethodArgs={'UseSymbolicNames','%value'};
            tune.ArgDataTypes={'string','bool'};
            tune.Tag='UseSymbolicNames';
            tune.RowSpan=idx;
            tune.ColSpan=[1,2];
            tune.Value=false;
            tune.Enabled=true;
            tune.DialogRefresh=true;

            items={tune};

            this.isCoefficientsNameEnabled=false;
            this.isNumeratorNameEnabled=false;
            this.isDenominatorNameEnabled=false;
            this.isScaleValuesNameEnabled=false;

            if this.UseSymbolicNames

                if type.isfarrow
                    this.isCoefficientsNameEnabled=true;
                    str='CoefficientsName';
                    idx=idx+1;
                    CoefficientsNameStruct.Name=FilterDesignDialog.message(str);
                    CoefficientsNameStruct.Type='edit';
                    CoefficientsNameStruct.Source=this;
                    CoefficientsNameStruct.ObjectProperty=str;
                    CoefficientsNameStruct.Mode=true;
                    CoefficientsNameStruct.Tag=str;
                    CoefficientsNameStruct.RowSpan=idx;
                    CoefficientsNameStruct.ColSpan=[1,4];
                    CoefficientsNameStruct.Enabled=true;
                    items=[items,{CoefficientsNameStruct}];
                else
                    this.isNumeratorNameEnabled=true;
                    str='NumeratorName';
                    idx=idx+1;
                    NumeratorNameStruct.Name=FilterDesignDialog.message(str);
                    NumeratorNameStruct.Type='edit';
                    NumeratorNameStruct.Source=this;
                    NumeratorNameStruct.ObjectProperty=str;
                    NumeratorNameStruct.Mode=true;
                    NumeratorNameStruct.Tag=str;
                    NumeratorNameStruct.RowSpan=idx;
                    NumeratorNameStruct.ColSpan=[1,4];
                    NumeratorNameStruct.Enabled=true;
                    items=[items,{NumeratorNameStruct}];
                    if type.isdtfiir||type.issos
                        this.isDenominatorNameEnabled=true;
                        str='DenominatorName';
                        idx=idx+1;
                        DenominatorNameStruct.Name=FilterDesignDialog.message(str);
                        DenominatorNameStruct.Type='edit';
                        DenominatorNameStruct.Source=this;
                        DenominatorNameStruct.ObjectProperty=str;
                        DenominatorNameStruct.Mode=true;
                        DenominatorNameStruct.Tag=str;
                        DenominatorNameStruct.RowSpan=idx;
                        DenominatorNameStruct.ColSpan=[1,4];
                        DenominatorNameStruct.Enabled=true;
                        items=[items,{DenominatorNameStruct}];
                        if type.issos
                            this.isScaleValuesNameEnabled=true;
                            str='ScaleValuesName';
                            idx=idx+1;
                            ScaleValuesNameStruct.Name=FilterDesignDialog.message(str);
                            ScaleValuesNameStruct.Type='edit';
                            ScaleValuesNameStruct.Source=this;
                            ScaleValuesNameStruct.ObjectProperty=str;
                            ScaleValuesNameStruct.Mode=true;
                            ScaleValuesNameStruct.Tag=str;
                            ScaleValuesNameStruct.RowSpan=idx;
                            ScaleValuesNameStruct.ColSpan=[1,4];
                            ScaleValuesNameStruct.Enabled=true;
                            items=[items,{ScaleValuesNameStruct}];
                        end
                    end
                end
            end
        end


        function[build,idx]=addBuildUsingBasicElementsCheckbox(this,idx)


            blockenabled=isBuildOptionEnabled(this);

            str='build';
            idx=idx+1;
            build.Name=FilterDesignDialog.message(str);
            build.Type='checkbox';
            build.Source=this;
            build.Tag='BuildUsingBasicElements';
            build.RowSpan=idx;
            build.ColSpan=[1,2];
            build.Value=this.BuildUsingBasicElements;
            build.DialogRefresh=true;
            build.Enabled=blockenabled;

            if blockenabled


                build.Mode=false;
                build.ObjectMethod='setCheckboxValue';
                build.MethodArgs={'BuildUsingBasicElements','%value'};
                build.ArgDataTypes={'string','bool'};
            else
                build.Mode=true;
                build.ObjectProperty='BuildUsingBasicElements';
                this.BuildUsingBasicElements=true;
                build.Visible=false;
            end
        end


        function[optimunitsv,idx]=addScaleValuesOptimizationCheckbox(this,idx)


            str='optimunitsv';
            idx=idx+1;
            optimunitsv.Name=FilterDesignDialog.message(str);
            optimunitsv.Type='checkbox';
            optimunitsv.Source=this;
            optimunitsv.ObjectProperty='OptimizeUnitScaleValues';
            optimunitsv.Mode=false;
            optimunitsv.ObjectMethod='setCheckboxValue';
            optimunitsv.MethodArgs={'OptimizeUnitScaleValues','%value'};
            optimunitsv.ArgDataTypes={'string','bool'};
            optimunitsv.Tag='OptimizeUnitScaleValues';
            optimunitsv.RowSpan=idx;
            optimunitsv.ColSpan=[1,2];
            optimunitsv.Value=false;
            optimunitsv.Enabled=true;
        end


        function[optim,idx]=addOptimizationsTogglePanel(this,type,idx)



            str='optimzeros';
            optimzeros.Name=FilterDesignDialog.message(str);
            optimzeros.Type='checkbox';
            optimzeros.Source=this;
            optimzeros.ObjectProperty='OptimizeZeros';
            optimzeros.Mode=false;
            optimzeros.ObjectMethod='setCheckboxValue';
            optimzeros.MethodArgs={'OptimizeZeros','%value'};
            optimzeros.ArgDataTypes={'string','bool'};
            optimzeros.Tag='OptimizeZeros';
            optimzeros.RowSpan=[1,1];
            optimzeros.ColSpan=[1,2];
            optimzeros.Value=false;
            optimzeros.Enabled=true;


            str='optimones';
            optimones.Name=FilterDesignDialog.message(str);
            optimones.Type='checkbox';
            optimones.Source=this;
            optimones.ObjectProperty='OptimizeOnes';
            optimones.Mode=false;
            optimones.ObjectMethod='setCheckboxValue';
            optimones.MethodArgs={'OptimizeOnes','%value'};
            optimones.ArgDataTypes={'string','bool'};
            optimones.Tag='OptimizeOnes';
            optimones.RowSpan=[2,2];
            optimones.ColSpan=[1,2];
            optimones.Value=false;
            optimones.Enabled=true;


            str='optimnegones';
            optimnegones.Name=FilterDesignDialog.message(str);
            optimnegones.Type='checkbox';
            optimnegones.Source=this;
            optimnegones.ObjectProperty='OptimizeNegOnes';
            optimnegones.Mode=false;
            optimnegones.ObjectMethod='setCheckboxValue';
            optimnegones.MethodArgs={'OptimizeNegOnes','%value'};
            optimnegones.ArgDataTypes={'string','bool'};
            optimnegones.Tag='OptimizeNegOnes';
            optimnegones.RowSpan=[2,2];
            optimnegones.ColSpan=[3,4];
            optimnegones.Value=false;
            optimnegones.Enabled=true;


            str='optimdelays';
            optimdelays.Name=FilterDesignDialog.message(str);
            optimdelays.Type='checkbox';
            optimdelays.Source=this;
            optimdelays.ObjectProperty='OptimizeDelays';
            optimdelays.Mode=false;
            optimdelays.ObjectMethod='setCheckboxValue';
            optimdelays.MethodArgs={'OptimizeDelays','%value'};
            optimdelays.ArgDataTypes={'string','bool'};
            optimdelays.Tag='OptimizeDelays';
            optimdelays.RowSpan=[1,1];
            optimdelays.ColSpan=[3,4];
            optimdelays.Enabled=true;


            if type.issos
                [optimunitsv,idx]=addScaleValuesOptimizationCheckbox(this,idx);
                items={optimzeros,optimones,optimnegones,optimdelays,optimunitsv};
            else
                items={optimzeros,optimones,optimnegones,optimdelays};
            end


            optim.Type='togglepanel';
            optim.Name=FilterDesignDialog.message('optim');
            optim.Items=items;
            optim.Tag='OptimizationsToggle';
            optim.LayoutGrid=[4,2];
            optim.ColStretch=[0,1];
            idx=idx+1;
            optim.RowSpan=idx;
            optim.ColSpan=[1,2];
        end


        function[variables,values]=convertMagPropsTodB(this,variables,values)
            hfdesign=getFDesign(this);

            fspecs=getcurrentspecs(hfdesign);
            [pass,stop]=magprops(fspecs);
            propNames=[pass,stop];


            for indx=1:length(propNames)
                magIdx=strcmp(variables,propNames{indx});
                if any(magIdx)
                    values{magIdx}=num2str(fspecs.(propNames{indx}));
                end
            end
        end


        function className=convertClassName(this,className)

            className=strrep(className,'fdesign.','');
            if this.isfir
                className=[className,'fir'];
            else
                className=[className,'iir'];
            end
        end


        function propNames=removeDefaultSysObjProps(this,Hd,propNames,exceptionFlag)

            wId='MATLAB:system:nonRelevantProperty';
            wState=warning('QUERY',wId);
            c=onCleanup(@()restoreWarningState(this,wState));
            warning('off',wId);


            HdDefault=feval(class(Hd));

            exceptionList={};
            if exceptionFlag
                exceptionList={'Numerator','Denominator','ReflectionCoefficients',...
                'DecimationFactor','InterpolationFactor','SOSMatrix','ScaleValues',...
                'DifferentialDelay','NumSections'};
            end

            removeIdx=[];
            for idx=1:length(propNames)
                prop=propNames{idx};
                if~isa(Hd.(prop),'embedded.numerictype')
                    if isprop(HdDefault,prop)&&isequal(Hd.(prop),HdDefault.(prop))&&~any(strcmp(exceptionList,prop))
                        removeIdx=[removeIdx,idx];
                    end
                end
            end
            propNames(removeIdx)=[];
        end


        function outputName=getFilterDesignDialogPropName(this,inputName)

            switch lower(inputName)
            case{'n','nb'}
                outputName='Order';
            case 'na'
                outputName='DenominatorOrder';
            case 'fcutoff'
                outputName='F6dB';
            case 'fcutoff1'
                outputName='F6dB1';
            case 'fcutoff2'
                outputName='F6dB2';
            case 'apass'
                if isa(this,'FilterDesignDialog.BandstopDesign')
                    outputName='Apass1';
                else
                    outputName='Apass';
                end
            case 'astop'
                if isa(this,'FilterDesignDialog.BandpassDesign')
                    outputName='Astop1';
                else
                    outputName='Astop';
                end
            case 'tw'
                outputName='TransitionWidth';
            otherwise
                outputName=inputName;
            end
        end


        function loadDesignOptions(this,s)

            s=s.DesignOptionsCache;
            if isempty(s),return;end
            fn=fieldnames(s);
            for indx=1:length(fn)


                if isprop(this,fn{indx})
                    this.(fn{indx})=s.(fn{indx});
                else
                    this.DesignOptionsCache=s;
                end
            end
        end
    end

end





function str=lclFuncToStr(fcn)

    info=functions(fcn);
    if strcmp(info.type,'anonymous')

        str=sprintf('%s',func2str(fcn));
    else
        str=sprintf('@%s',func2str(fcn));
    end
end


function str=matchCase(str,allStrs)

    idx=find(strcmpi(str,allStrs));
    if isempty(idx)
        str=allStrs{1};
    else
        str=allStrs{idx};
    end
end


function cls=getClassName(Hd)

    if isa(Hd,'dsp.internal.FilterAnalysis')
        switch class(Hd)
        case 'dsp.FIRFilter'
            switch Hd.Structure
            case 'Direct form'
                cls='dffir';
            case 'Direct form symmetric'
                cls='dfsymfir';
            case 'Direct form antisymmetric'
                cls='dfasymfir';
            case 'Direct form transposed'
                cls='dffirt';
            otherwise
                error(FilterDesignDialog.message('StructureNotSupported'))
            end
        case 'dsp.FIRDecimator'
            if strcmp(Hd.Structure,'Direct form')
                cls='firdecim';
            else
                cls='firtdecim';
            end
        case 'dsp.FIRInterpolator'
            cls='firinterp';
        case 'dsp.FIRRateConverter'
            cls='firsrc';
        case 'dsp.BiquadFilter'
            switch Hd.Structure
            case 'Direct form I'
                cls='df1sos';
            case 'Direct form I transposed'
                cls='df1tsos';
            case 'Direct form II'
                cls='df2sos';
            case 'Direct form II transposed'
                cls='df2tsos';
            end
        case 'dsp.IIRFilter'
            switch Hd.Structure
            case 'Direct form I'
                cls='df1';
            case 'Direct form I transposed'
                cls='df1t';
            case 'Direct form II'
                cls='df2';
            case 'Direct form II transposed'
                cls='df2t';
            end
        case 'dsp.CICDecimator'
            cls='cicdecim';
        case 'dsp.CICInterpolator'
            cls='cicinterp';
        case 'dsp.IIRHalfbandDecimator'
            switch Hd.Structure
            case 'Minimum multiplier'
                cls='iirdecim';
            case 'Wave Digital Filter'
                cls='iirwdfdecim';
            end
        case 'dsp.IIRHalfbandInterpolator'
            switch Hd.Structure
            case 'Minimum multiplier'
                cls='iirinterp';
            case 'Wave Digital Filter'
                cls='iirwdfinterp';
            end
        case 'dsp.FilterCascade'
            for indx=1:getNumStages(Hd)
                cls=getClassName(Hd.(sprintf('Stage%d',indx)));
                if~isempty(cls)
                    return;
                end
            end
        otherwise
            error(FilterDesignDialog.message('StructureNotSupported'))
        end
    else
        cls=class(Hd);
        cls=strsplit(cls,'.');
        cls=cls{end};

        switch cls
        case{'cascade','parallel'}
            for indx=1:nstages(Hd)
                cls=getClassName(Hd.Stage(indx));
                if~isempty(cls)
                    return;
                end
            end

        case 'scalar'
            cls='';
        end
    end
end


function designOpts=fixupOldDesignOpts(designOpts)




    indx=find(strcmp(designOpts,'StopbandShape'));
    if~isempty(indx)&&strcmpi(designOpts{indx+1},'flat')
        indx=find(strcmp(designOpts,'StopbandDecay'));
        if~isempty(indx)
            designOpts(indx:indx+1)=[];
        end
    end
end


function notification_listener(hSrc,ed)


    if strcmpi(ed.NotificationType,'ErrorOccurred')
        error(hSrc,getString(message('FilterDesignLib:FilterDesignDialog:AbstractDesign:export:filterBuilder')),ed.Data.ErrorString);
    end
end


function restoreWarningState(~,varargin)

    for idx=1:numel(varargin)
        warning(varargin{idx})
    end
end


function resetFromFilterBuilderFlag(~,d)
    d.FromFilterBuilderFlag=false;
end


function str=sentencecase(str)

    str=cellstr(str);

    for indx=1:length(str)
        str{indx}=[upper(str{indx}(1)),lower(str{indx}(2:end))];
    end
end


function propmode=setcombobox(propmode,propvalidOps,prop,thisprop)
    propmode.Entries=FilterDesignDialog.message(propvalidOps);
    propmode.Value=find(strcmpi(propvalidOps,thisprop))-1;
    propmode.ObjectMethod='selectComboboxEntry';
    propmode.MethodArgs={'%dialog','%value',prop,propvalidOps};
    propmode.ArgDataTypes={'handle','mxArray','string','mxArray'};



    propmode.Mode=false;



    propmode=rmfield(propmode,'ObjectProperty');
end


function flag=isaWindowName(w)

    windowList={'barthannwin','bartlett','blackman','blackmanharris',...
    'bohmanwin','chebwin','flattopwin','gausswin','hamming','hann','kaiser',...
    'nuttallwin','parzenwin','rectwin','taylorwin','triang','tukeywin'};

    idx=find(strcmpi(windowList,w),1);
    flag=~isempty(idx);
end


function addPair(hBuffer,property,value,flag,quoteCharFlag)

    if ischar(value)
        if~strncmp(value,'numerictype(',12)
            if quoteCharFlag
                value=['''',value,''''];
            end
        end
    elseif iscell(value)



        value=cell2str2D(value);
    else
        value=mat2str(value);


        value=strrep(value,';','; ');
        value=strrep(value,',',', ');
    end
    if flag
        hBuffer.add(', ...\n    ''%s'', %s',property,value);
    else
        hBuffer.add(' ...\n    ''%s'', %s',property,value);
    end
end


function str=getNumericTypeString(~,ntObj)

    switch ntObj.Signedness
    case 'Auto'
        ntSign='[]';
    case 'Signed'
        ntSign='true';
    case 'Unsigned'
        ntSign='false';
    end

    wl=mat2str(ntObj.WordLength);

    fl=[];
    if isbinarypointscalingset(ntObj)
        fl=mat2str(ntObj.FractionLength);
    end

    str=['numerictype(',ntSign,',',wl];
    if~isempty(fl)
        str=[str,',',fl];
    end
    str=[str,')'];
end


function value=cell2str2D(value)


    value=appendToCharBufferFor2DCell('',value);
end


function buf=appendToCharBufferFor2DCell(buf,value)







    if(iscell(value))


        assert(numel(size(buf))<=2,['Only dimensions up to 2D ',...
        'supported for cell arrays as public properties of filter ',...
        'objects'])

        csz=size(value);
        buf=[buf,'{'];
        for kr=1:csz(1)
            for kc=1:csz(2)
                buf=appendToCharBufferFor2DCell(buf,value{kr,kc});
                if(kc<csz(2))
                    buf=[buf,','];
                end
            end
            if(kr<csz(1))
                buf=[buf,';'];
            end
        end
        buf=[buf,'}'];
    else
        buf=[buf,mat2str(value)];
    end
end


function hBuffer=getMCodeBufferSysObjCascadeStage(thisFDATool,hBuffer,HfiltStage)



    thisTemp=copy(thisFDATool);
    setfilter(thisTemp,HfiltStage);

    hBuffer=genmcodesysobj(thisTemp,'',1,0,hBuffer);

end


function hBuffer=removeArithmeticCode(hBuffer,arithStartIdx)

    hBuffer2=copy(hBuffer);
    hBuffer2.remove(1:arithStartIdx-1);
    arithEndIdx=min(hBuffer2.find(');','partial'));
    hBuffer.remove(arithStartIdx:arithStartIdx+arithEndIdx-1);

end


function str=convertCodeCellTochar(strCell)




    str='';
    for idx=1:numel(strCell)
        if~isempty(strCell{idx})
            if isempty(str)
                str=strCell{idx};
            else
                str=sprintf('%s\n%s',str,strCell{idx});
            end
        end
    end
end
