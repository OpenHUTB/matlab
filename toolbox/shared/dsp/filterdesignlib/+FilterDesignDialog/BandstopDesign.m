classdef(CaseInsensitiveProperties)BandstopDesign<FilterDesignDialog.AbstractBpBsDesign




    properties(AbortSet,SetObservable,GetObservable)

        Fpass1='0.35';

        F3dB1='0.4';

        F6dB1='0.4';

        Fstop1='0.45';

        Fstop2='0.55';

        F6dB2='0.6';

        F3dB2='0.6';

        Fpass2='0.65';

        BWpass='0.25';

        BWstop='0.15';

        Apass1='1';

        Astop='60';

        Apass2='1';

        Passband1Constrained='false';

        StopbandConstrained='false';

        Passband2Constrained='false';

    end

    properties(AbortSet,SetObservable,GetObservable,Dependent)





        FrequencyConstraints;




        MagnitudeConstraints;
    end

    properties(AbortSet,SetObservable,GetObservable,Hidden)





        privFrequencyConstraints='Passband and stopband edges';




        privMagnitudeConstraints='Unconstrained';
    end

    properties(Hidden,Constant)

        FrequencyConstraintsSet={'Passband and stopband edges','Passband edges','Stopband edges',...
        '6dB points','3dB points','3dB points and stopband width',...
        '3dB points and passband width'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('Fst1Fp1Fp2Fst2'),...
        FilterDesignDialog.message('Fp1Fp2'),...
        FilterDesignDialog.message('Fst1Fst2'),...
        FilterDesignDialog.message('Fc1Fc2'),...
        FilterDesignDialog.message('F3dB1F3dB2'),...
        FilterDesignDialog.message('F3dB1F3dB2BWst'),...
        FilterDesignDialog.message('F3dB1F3dB2BWp')};

        MagnitudeConstraintsSet={'Unconstrained','Passband ripples and stopband attenuation',...
        'Passband ripple','Stopband attenuation','Constrained bands'};
        MagnitudeConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('Ap1Ap2Ast'),...
        FilterDesignDialog.message('Ap'),...
        FilterDesignDialog.message('Ast'),...
        FilterDesignDialog.message('constrainedbands')};

    end

    methods
        function this=BandstopDesign(varargin)

            if~isempty(varargin)
                set(this,varargin{:});
            end
            this.VariableName=this.getOutputVarName('bs');

            this.FDesign=fdesign.bandstop;
            this.DesignMethod='Equiripple';


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);
        end
    end

    methods
        function set.Fpass1(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fpass1')
            obj.Fpass1=value;
        end

        function set.F3dB1(obj,value)

            validateattributes(value,{'char'},{'row'},'','F3dB1')
            obj.F3dB1=value;
        end

        function set.F6dB1(obj,value)

            validateattributes(value,{'char'},{'row'},'','F6dB1')
            obj.F6dB1=value;
        end

        function set.Fstop1(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fstop1')
            obj.Fstop1=value;
        end

        function set.Fstop2(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fstop2')
            obj.Fstop2=value;
        end

        function set.F6dB2(obj,value)

            validateattributes(value,{'char'},{'row'},'','F6dB2')
            obj.F6dB2=value;
        end

        function set.F3dB2(obj,value)

            validateattributes(value,{'char'},{'row'},'','F3dB2')
            obj.F3dB2=value;
        end

        function set.Fpass2(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fpass2')
            obj.Fpass2=value;
        end

        function set.BWpass(obj,value)

            validateattributes(value,{'char'},{'row'},'','BWpass')
            obj.BWpass=value;
        end

        function set.BWstop(obj,value)

            validateattributes(value,{'char'},{'row'},'','BWstop')
            obj.BWstop=value;
        end

        function set.Apass1(obj,value)

            validateattributes(value,{'char'},{'row'},'','Apass1')
            obj.Apass1=value;
        end

        function set.Astop(obj,value)

            validateattributes(value,{'char'},{'row'},'','Astop')
            obj.Astop=value;
        end

        function set.Apass2(obj,value)

            validateattributes(value,{'char'},{'row'},'','Apass2')
            obj.Apass2=value;
        end

        function set.Passband1Constrained(obj,value)

            validateattributes(value,{'char'},{'row'},'','Passband1Constrained')
            obj.Passband1Constrained=value;
        end

        function set.StopbandConstrained(obj,value)

            validateattributes(value,{'char'},{'row'},'','StopbandConstrained')
            obj.StopbandConstrained=value;
        end

        function set.Passband2Constrained(obj,value)

            validateattributes(value,{'char'},{'row'},'','Passband2Constrained')
            obj.Passband2Constrained=value;
        end

        function value=get.FrequencyConstraints(obj)
            value=lcl_get_frequencyconstraints(obj,obj.privFrequencyConstraints);
        end
        function set.FrequencyConstraints(obj,value)




            value=validatestring(value,obj.FrequencyConstraintsSet,'','FrequencyConstraints');
            obj.privFrequencyConstraints=value;
            set_frequencyconstraints(obj);
        end
        function set.privFrequencyConstraints(obj,value)
            value=validatestring(value,obj.FrequencyConstraintsSet,'','privFrequencyConstraints');
            obj.privFrequencyConstraints=value;
        end

        function value=get.MagnitudeConstraints(obj)
            value=lcl_get_magnitudeconstraints(obj,obj.privMagnitudeConstraints);
        end
        function set.MagnitudeConstraints(obj,value)




            value=validatestring(value,obj.MagnitudeConstraintsSet,'','MagnitudeConstraints');
            obj.privMagnitudeConstraints=value;
            set_magnitudeconstraints(obj);
        end
        function set.privMagnitudeConstraints(obj,value)
            value=validatestring(value,obj.MagnitudeConstraintsSet,'','privMagnitudeConstraints');
            obj.privMagnitudeConstraints=value;
        end
    end

    methods


        function set_frequencyconstraints(this)


            updateMagConstraints(this);

        end


        function set_magnitudeconstraints(this,~)


            updateMethod(this);

        end


        function inputs=formatCodeInfo(this,inputs)



            laState=get(this,'LastAppliedState');
            specs=getSpecs(this,laState);
            spec=getSpecification(this,laState);

            if strcmp(spec,'n,fp1,fst1,fst2,fp2,c')
                inputs.Variables(end)=[];
                inputs.Values(end)=[];
                inputs.Descriptions(end)=[];

                inputs.Variables{end+1}='Passband1Constrained';
                inputs.Values{end+1}=mat2str(specs.Passband1Constrained);
                inputs.Descriptions{end+1}='';
                if specs.Passband1Constrained
                    inputs.Variables{end+1}='Apass1';
                    inputs.Values{end+1}=mat2str(specs.Apass1);
                    inputs.Descriptions{end+1}='';
                end

                inputs.Variables{end+1}='StopbandConstrained';
                inputs.Values{end+1}=mat2str(specs.StopbandConstrained);
                inputs.Descriptions{end+1}='';
                if specs.StopbandConstrained
                    inputs.Variables{end+1}='Astop';
                    inputs.Values{end+1}=mat2str(specs.Astop);
                    inputs.Descriptions{end+1}='';
                end

                inputs.Variables{end+1}='Passband2Constrained';
                inputs.Values{end+1}=mat2str(specs.Passband2Constrained);
                inputs.Descriptions{end+1}='';
                if specs.Passband2Constrained
                    inputs.Variables{end+1}='Apass2';
                    inputs.Values{end+1}=mat2str(specs.Apass2);
                    inputs.Descriptions{end+1}='';
                end

            end

        end


        function dialogTitle=getDialogTitle(this)



            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('BandstopFilter');
            else
                if isFilterDesignerMode(this)
                    dialogTitle=FilterDesignDialog.message(['BandstopDesign',this.ImpulseResponse]);
                else
                    dialogTitle=FilterDesignDialog.message('BandstopDesign');
                end
            end


        end


        function fspecs=getFrequencySpecsFrame(this)





            items=getConstraintsWidgets(this,'Frequency',1);

            items=getFrequencyUnitsWidgets(this,2,items);

            switch lower(this.FrequencyConstraints)
            case 'passband edges'
                [items,colindx]=addConstraint(this,3,1,items,true,...
                'Fpass1',FilterDesignDialog.message('Fpass1'),'First passband edge');
                items=addConstraint(this,3,colindx,items,true,...
                'Fpass2',FilterDesignDialog.message('Fpass2'),'Second passband edge');
            case 'stopband edges'
                [items,colindx]=addConstraint(this,3,1,items,true,...
                'Fstop1',FilterDesignDialog.message('Fstop1'),'First stopband edge');
                items=addConstraint(this,3,colindx,items,true,...
                'Fstop2',FilterDesignDialog.message('Fstop2'),'Second stopband edge');
            case 'passband and stopband edges'
                [items,colindx]=addConstraint(this,3,1,items,true,...
                'Fpass1',FilterDesignDialog.message('Fpass1'),'First passband edge');
                items=addConstraint(this,3,colindx,items,true,...
                'Fstop1',FilterDesignDialog.message('Fstop1'),'First stopband edge');
                [items,colindx]=addConstraint(this,4,1,items,true,...
                'Fstop2',FilterDesignDialog.message('Fstop2'),'Second stopband edge');
                items=addConstraint(this,4,colindx,items,true,...
                'Fpass2',FilterDesignDialog.message('Fpass2'),'Second passband edge');
            case '3db points'
                [items,colindx]=addConstraint(this,3,1,items,true,...
                'F3dB1',FilterDesignDialog.message('freq3dB1'),'First 3dB point');
                items=addConstraint(this,3,colindx,items,true,...
                'F3dB2',FilterDesignDialog.message('freq3dB2'),'Second 3dB point');
            case '6db points'
                [items,colindx]=addConstraint(this,3,1,items,true,...
                'F6dB1',FilterDesignDialog.message('freq6dB1'),'First 6dB point');
                items=addConstraint(this,3,colindx,items,true,...
                'F6dB2',FilterDesignDialog.message('freq6dB2'),'Second 6dB point');
            case '3db points and stopband width'
                [items,colindx]=addConstraint(this,3,1,items,true,...
                'F3dB1',FilterDesignDialog.message('freq3dB1'),'First 3dB point');
                items=addConstraint(this,3,colindx,items,true,...
                'F3dB2',FilterDesignDialog.message('freq3dB2'),'Second 3dB point');
                items=addConstraint(this,4,1,items,true,...
                'BWstop',FilterDesignDialog.message('BWstop'),'Stopband width');
            case '3db points and passband width'
                [items,colindx]=addConstraint(this,3,1,items,true,...
                'F3dB1',FilterDesignDialog.message('freq3dB1'),'First 3dB point');
                items=addConstraint(this,3,colindx,items,true,...
                'F3dB2',FilterDesignDialog.message('freq3dB2'),'Second 3dB point');
                items=addConstraint(this,4,1,items,true,...
                'BWpass',FilterDesignDialog.message('BWpass'),'Passband width');
            end

            fspecs.Name=FilterDesignDialog.message('freqspecs');
            fspecs.Type='group';
            fspecs.Items=items;
            fspecs.LayoutGrid=[5,4];
            fspecs.RowStretch=[0,0,0,0,1];
            fspecs.ColStretch=[0,1,0,1];
            fspecs.Tag='FreqSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)



            helptext.Type='text';
            if isFilterDesignerMode(this)
                helptext.Name=FilterDesignDialog.message('FilterDesignAssistantHeader');
            else
                helptext.Name=FilterDesignDialog.message('BandstopDesignHelpTxt');
            end
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function mspecs=getMagnitudeSpecsFrame(this)



            spacer.Name=' ';
            spacer.Type='text';
            spacer.RowSpan=[1,1];
            spacer.ColSpan=[1,1];
            spacer.Tag='Spacer';

            items=getConstraintsWidgets(this,'Magnitude',1);

            if~strcmpi(this.MagnitudeConstraints,'unconstrained')

                items=getMagnitudeUnitsWidgets(this,2,items);

                if isFilterDesignerMode(this)
                    items{end}.Enabled=false;
                end

                switch lower(this.MagnitudeConstraints)
                case 'passband ripple'
                    items=addConstraint(this,3,1,items,true,...
                    'Apass1',FilterDesignDialog.message('Apass'),'Passband ripple');
                case 'stopband attenuation'
                    items=addConstraint(this,3,1,items,true,...
                    'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');
                case 'passband ripples and stopband attenuation'
                    if any(strcmpi(this.FrequencyConstraints,{'3db points','passband edges'}))
                        [items,col]=addConstraint(this,3,1,items,true,...
                        'Apass1',FilterDesignDialog.message('Apass'),'Passband ripple');
                        items=addConstraint(this,3,col,items,true,...
                        'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');
                    else
                        [items,col]=addConstraint(this,3,1,items,true,...
                        'Apass1',FilterDesignDialog.message('Apass1'),'First passband ripple');
                        items=addConstraint(this,3,col,items,true,...
                        'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');
                        items=addConstraint(this,4,1,items,true,...
                        'Apass2',FilterDesignDialog.message('Apass2'),'Second passband ripple');
                    end
                case 'constrained bands'
                    [items,col]=addConstraintBands(this,3,1,items,true,...
                    'Passband1Constrained','Apass1',...
                    FilterDesignDialog.message('Apass1'),...
                    strcmpi(this.Passband1Constrained,'true'),...
                    'First passband ripple');
                    items=addConstraintBands(this,3,col,items,true,...
                    'StopbandConstrained','Astop',...
                    FilterDesignDialog.message('Astop'),...
                    strcmpi(this.StopbandConstrained,'true'),...
                    'Stopband attenuation');
                    items=addConstraintBands(this,4,1,items,true,...
                    'Passband2Constrained','Apass2',...
                    FilterDesignDialog.message('Apass2'),...
                    strcmpi(this.Passband2Constrained,'true'),...
                    'Second passband ripple');
                end
            else


                spacer.RowSpan=[2,2];
                spacer.Tag='Spacer2';

                items={items{:},spacer};%#ok<CCAT>

                spacer.RowSpan=[3,3];

                items={items{:},spacer};%#ok<CCAT>
            end

            mspecs.Name=FilterDesignDialog.message('magspecs');
            mspecs.Type='group';
            mspecs.Items=items;
            mspecs.LayoutGrid=[5,4];
            mspecs.RowStretch=[0,0,0,0,1];
            mspecs.ColStretch=[0,1,0,1];
            mspecs.Tag='MagSpecsGroup';


        end


        function specification=getSpecification(this,laState)



            if nargin<2
                laState=this;
            end

            if isminorder(this,laState)
                specification='fp1,fst1,fst2,fp2,ap1,ast,ap2';
            elseif isDSTMode(this)&&strcmpi(laState.ImpulseResponse,'iir')...
                &&laState.SpecifyDenominator
                specification='nb,na,fp1,fst1,fst2,fp2';
            else
                freqcons=laState.FrequencyConstraints;
                magcons=laState.MagnitudeConstraints;

                specification='n';

                switch lower(freqcons)
                case 'passband edges'
                    specification=[specification,',fp1,fp2'];
                case 'stopband edges'
                    specification=[specification,',fst1,fst2'];
                case 'passband and stopband edges'
                    specification=[specification,',fp1,fst1,fst2,fp2'];
                case '3db points'
                    specification=[specification,',f3db1,f3db2'];
                case '6db points'
                    specification=[specification,',fc1,fc2'];
                case '3db points and stopband width'
                    specification=[specification,',f3db1,f3db2,bwst'];
                case '3db points and passband width'
                    specification=[specification,',f3db1,f3db2,bwp'];
                end

                switch lower(magcons)
                case 'passband ripple'
                    specification=[specification,',ap'];
                case 'stopband attenuation'
                    specification=[specification,',ast'];
                case 'passband ripples and stopband attenuation'
                    if any(strcmpi(freqcons,{'3db points','passband edges'}))
                        specification=[specification,',ap,ast'];
                    else
                        specification=[specification,',ap1,ast,ap2'];
                    end
                case 'constrained bands'
                    specification=[specification,',c'];
                end
            end


        end


        function specs=getSpecs(this,varargin)



            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            specs.FilterType=source.FilterType;
            specs.Factor=evaluateVariable(this,source.Factor);
            specs.Scale=this.Scale;
            specs.ForceLeadingNumerator=strcmpi(this.ForceLeadingNumerator,'on');

            if strcmpi(this.FilterType,'sample-rate converter')
                specs.SecondFactor=evaluateVariable(this,source.SecondFactor);
            end

            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');

            spec=getSpecification(this,source);

            switch lower(spec)
            case 'fp1,fst1,fst2,fp2,ap1,ast,ap2'
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Apass1=evaluateVariable(this,source.Apass1);
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.Apass2=evaluateVariable(this,source.Apass2);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,f3db1,f3db2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
            case 'n,f3db1,f3db2,ap'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
                specs.Apass=evaluateVariable(this,source.Apass1);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,f3db1,f3db2,ap,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
                specs.Apass=evaluateVariable(this,source.Apass1);
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,f3db1,f3db2,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,f3db1,f3db2,bwp'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
                specs.BWpass=getnum(this,source,'BWpass');
            case 'n,f3db1,f3db2,bwst'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
                specs.BWstop=getnum(this,source,'BWstop');
            case 'n,fc1,fc2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F6dB1=getnum(this,source,'F6dB1');
                specs.F6dB2=getnum(this,source,'F6dB2');
            case 'n,fc1,fc2,ap1,ast,ap2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F6dB1=getnum(this,source,'F6dB1');
                specs.F6dB2=getnum(this,source,'F6dB2');
                specs.Apass1=evaluateVariable(this,source.Apass1);
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.Apass2=evaluateVariable(this,source.Apass2);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fp1,fp2,ap'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Apass=evaluateVariable(this,source.Apass1);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fp1,fp2,ap,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Apass=evaluateVariable(this,source.Apass1);
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fp1,fst1,fst2,fp2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Fpass2=getnum(this,source,'Fpass2');
            case 'n,fp1,fst1,fst2,fp2,c'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Passband1Constrained=strcmpi(source.Passband1Constrained,'true');
                specs.StopbandConstrained=strcmpi(source.StopbandConstrained,'true');
                specs.Passband2Constrained=strcmpi(source.Passband2Constrained,'true');
                specs.MagnitudeUnits=this.MagnitudeUnits;
                if specs.Passband1Constrained
                    specs.Apass1=evaluateVariable(this,source.Apass1);
                end
                if specs.StopbandConstrained
                    specs.Astop=evaluateVariable(this,source.Astop);
                end
                if specs.Passband2Constrained
                    specs.Apass2=evaluateVariable(this,source.Apass2);
                end
            case 'n,fp1,fst1,fst2,fp2,ap'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Apass=evaluateVariable(this,source.Apass1);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fst1,fst2,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'nb,na,fp1,fst1,fst2,fp2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.DenominatorOrder=evaluateVariable(this,source.DenominatorOrder);
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Fpass2=getnum(this,source,'Fpass2');
            otherwise
                fprintf('Finish %s',spec);
            end


        end


        function validFreqConstraints=getValidFreqConstraints(this)



            validFreqConstraints=this.FrequencyConstraintsSet;

            if strcmpi(this.ImpulseResponse,'fir')
                validFreqConstraints=validFreqConstraints([1,4]);
            else
                if isDSTMode(this)
                    if strcmpi(this.ImpulseResponse,'iir')&&this.SpecifyDenominator
                        validFreqConstraints=validFreqConstraints(1);
                    else
                        validFreqConstraints=validFreqConstraints([1:3,5:7]);
                    end
                else
                    validFreqConstraints=validFreqConstraints([2,3,5]);
                end
            end



        end


        function availableconstraints=getValidMagConstraints(this,fconstraints)



            if isminorder(this)
                availableconstraints={'Passband ripples and stopband attenuation'};
                return;
            end

            if isDSTMode(this)&&strcmpi(this.ImpulseResponse,'iir')&&...
                this.SpecifyDenominator
                availableconstraints={'Unconstrained'};
                return;
            end

            if nargin<2
                fconstraints=this.FrequencyConstraints;
            end

            switch lower(fconstraints)
            case 'passband and stopband edges'
                if isfir(this)
                    availableconstraints={'Unconstrained'};
                    if isDSTMode(this)
                        availableconstraints=...
                        [availableconstraints,{'Constrained bands'}];
                    end
                else
                    availableconstraints={'Passband ripple',...
                    'Unconstrained'};
                end
            case 'passband edges'

                availableconstraints={'Passband ripple',...
                'Passband ripples and stopband attenuation'};
            case 'stopband edges'

                availableconstraints={'Stopband attenuation'};
            case '6db points'
                availableconstraints={'Unconstrained',...
                'Passband ripples and stopband attenuation'};
            case '3db points'
                if isDSTMode(this)
                    availableconstraints={'Passband ripple','Stopband attenuation',...
                    'Passband ripples and stopband attenuation','Unconstrained'};
                else
                    availableconstraints={'Unconstrained'};
                end
            case{'3db points and stopband width','3db points and passband width'}
                availableconstraints={'Unconstrained'};
            end


        end


        function b=setGUI(this,Hd)



            b=true;
            hfdesign=getfdesign(Hd);
            if~strcmpi(get(hfdesign,'Response'),'bandstop')
                b=false;
                return;
            end

            switch lower(hfdesign.Specification)
            case 'fp1,fst1,fst2,fp2,ap1,ast,ap2'
                set(this,...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Apass1',num2str(hfdesign.Apass1),...
                'Astop',num2str(hfdesign.Astop),...
                'Apass1',num2str(hfdesign.Apass2));
            case 'n,f3db1,f3db2'
                set(this,...
                'privFrequencyConstraints','3db points',...
                'privMagnitudeConstraints','unconstrained',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2));
            case 'n,f3db1,f3db2,ap'
                set(this,...
                'privFrequencyConstraints','3db points',...
                'privMagnitudeConstraints','Passband ripple',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'Apass1',num2str(hfdesign.Apass));
            case 'n,f3db1,f3db2,ast'
                set(this,...
                'privFrequencyConstraints','3db points',...
                'privMagnitudeConstraints','Stopband attenuation',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'Astop',num2str(hfdesign.Astop));
            case 'n,f3db1,f3db2,ap,ast'
                set(this,...
                'privFrequencyConstraints','3dB points',...
                'privMagnitudeConstraints','passband ripples and stopband attenuation',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'Apass1',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'n,f3db1,f3db2,bwp'
                set(this,...
                'privFrequencyConstraints','3db points and passband width',...
                'privMagnitudeConstraints','unconstrained',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'BWpass',num2str(hfdesign.BWpass));
            case 'n,f3db1,f3db2,bwst'
                set(this,...
                'privFrequencyConstraints','3db points and stopband width',...
                'privMagnitudeConstraints','unconstrained',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'BWstop',num2str(hfdesign.BWstop));
            case 'n,fc1,fc2'
                set(this,...
                'privFrequencyConstraints','6db points',...
                'privMagnitudeConstraints','unconstrained',...
                'F6dB1',num2str(hfdesign.Fcutoff1),...
                'F6dB2',num2str(hfdesign.Fcutoff2));
            case 'n,fc1,fc2,ap1,ast,ap2'
                set(this,...
                'privFrequencyConstraints','6dB points',...
                'privMagnitudeConstraints','passband ripples and stopband attenuation',...
                'F6dB1',num2str(hfdesign.Fcutoff1),...
                'F6dB2',num2str(hfdesign.Fcutoff2),...
                'Apass1',num2str(hfdesign.Apass1),...
                'Astop',num2str(hfdesign.Astop),...
                'Apass2',num2str(hfdesign.Apass2));
            case 'n,fp1,fp2,ap'
                set(this,...
                'privFrequencyConstraints','passband edges',...
                'privMagnitudeConstraints','Passband ripple',...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Apass1',num2str(hfdesign.Apass));
            case 'n,fp1,fp2,ap,ast'
                set(this,...
                'privFrequencyConstraints','passband edges',...
                'privMagnitudeConstraints','Passband ripples and stopband attenuation',...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Astop',num2str(hfdesign.Astop));
            case 'n,fp1,fst1,fst2,fp2'
                set(this,...
                'privFrequencyConstraints','passband and stopband edges',...
                'privMagnitudeConstraints','unconstrained',...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Fpass2',num2str(hfdesign.Fpass2));
            case 'n,fp1,fst1,fst2,fp2,c'
                set(this,...
                'privFrequencyConstraints','passband and stopband edges',...
                'privMagnitudeConstraints','constrained bands',...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Passband1Constrained',mat2str(hfdesign.Passband1Constrained),...
                'StopbandConstrained',mat2str(hfdesign.StopbandConstrained),...
                'Passband2Constrained',mat2str(hfdesign.Passband2Constrained));
                if hfdesign.Passband1Constrained
                    set(this,'Apass1',num2str(hfdesign.Apass1));
                end
                if hfdesign.StopbandConstrained
                    set(this,'Astop',num2str(hfdesign.Astop));
                end
                if hfdesign.Passband2Constrained
                    set(this,'Apass2',num2str(hfdesign.Apass2));
                end
            case 'n,fp1,fst1,fst2,fp2,ap'
                set(this,...
                'privFrequencyConstraints','passband and stopband edges',...
                'privMagnitudeConstraints','Passband ripple',...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Apass1',num2str(hfdesign.Apass));
            case 'n,fst1,fst2,ast'
                set(this,...
                'privFrequencyConstraints','stopband edges',...
                'privMagnitudeConstraints','stopband attenuation',...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Astop',num2str(hfdesign.Astop));
            case 'nb,na,fp1,fst1,fst2,fp2'
                set(this,...
                'privFrequencyConstraints','passband and stopband edges',...
                'privMagnitudeConstraints','unconstrained',...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Fpass2',num2str(hfdesign.Fpass2));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:BandstopDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function[success,msg]=setupFDesign(this,varargin)



            success=true;
            msg='';

            hd=get(this,'FDesign');

            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            spec=getSpecification(this,source);



            setSpecsSafely(this,hd,spec);



            try
                specs=getSpecs(this,source);

                if strncmpi(specs.FrequencyUnits,'normalized',10)
                    normalizefreq(hd);
                else
                    normalizefreq(hd,false,specs.InputSampleRate);
                end

                switch spec
                case 'fp1,fst1,fst2,fp2,ap1,ast,ap2'
                    setspecs(hd,specs.Fpass1,specs.Fstop1,specs.Fstop2,specs.Fpass2,...
                    specs.Apass1,specs.Astop,specs.Apass2,specs.MagnitudeUnits);
                case 'n,f3db1,f3db2'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2);
                case 'n,f3db1,f3db2,ap'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,...
                    specs.Apass,specs.MagnitudeUnits);
                case 'n,f3db1,f3db2,ap,ast'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,...
                    specs.Apass,specs.Astop,specs.MagnitudeUnits);
                case 'n,f3db1,f3db2,ast'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,f3db1,f3db2,bwp'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,specs.BWpass);
                case 'n,f3db1,f3db2,bwst'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,specs.BWstop);
                case 'n,fc1,fc2'
                    setspecs(hd,specs.Order,specs.F6dB1,specs.F6dB2);
                case 'n,fc1,fc2,ap1,ast,ap2'
                    setspecs(hd,specs.Order,specs.F6dB1,specs.F6dB2,specs.Apass1,...
                    specs.Astop,specs.Apass2);
                case 'n,fp1,fp2,ap'
                    setspecs(hd,specs.Order,specs.Fpass1,specs.Fpass2,...
                    specs.Apass,specs.MagnitudeUnits);
                case 'n,fp1,fp2,ap,ast'
                    setspecs(hd,specs.Order,specs.Fpass1,specs.Fpass2,...
                    specs.Apass,specs.Astop,specs.MagnitudeUnits);
                case 'n,fp1,fst1,fst2,fp2'
                    setspecs(hd,specs.Order,specs.Fpass1,specs.Fstop1,...
                    specs.Fstop2,specs.Fpass2);
                case 'n,fp1,fst1,fst2,fp2,c'
                    setspecs(hd,specs.Order,specs.Fpass1,specs.Fstop1,...
                    specs.Fstop2,specs.Fpass2,specs.Passband1Constrained,...
                    specs.StopbandConstrained,specs.Passband2Constrained);
                    isLinearMagUnits=strcmpi(specs.MagnitudeUnits,'linear');
                    if hd.Passband1Constrained
                        if isLinearMagUnits
                            specs.Apass1=convertmagunits(specs.Apass1,'linear','db','pass');
                        end
                        hd.Apass1=specs.Apass1;
                    end
                    if hd.StopbandConstrained
                        if isLinearMagUnits
                            specs.Astop=convertmagunits(specs.Astop,'linear','db','stop');
                        end
                        hd.Astop=specs.Astop;
                    end
                    if hd.Passband2Constrained
                        if isLinearMagUnits
                            specs.Apass2=convertmagunits(specs.Apass2,'linear','db','pass');
                        end
                        hd.Apass2=specs.Apass2;
                    end
                case 'n,fp1,fst1,fst2,fp2,ap'
                    setspecs(hd,specs.Order,specs.Fpass1,specs.Fstop1,specs.Fstop2,...
                    specs.Fpass2,specs.Apass,specs.MagnitudeUnits);
                case 'n,fst1,fst2,ast'
                    setspecs(hd,specs.Order,specs.Fstop1,specs.Fstop2,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'nb,na,fp1,fst1,fst2,fp2'
                    setspecs(hd,specs.Order,specs.DenominatorOrder,specs.Fpass1,...
                    specs.Fstop1,specs.Fstop2,specs.Fpass2);
                otherwise
                    fprintf('Finish %s',spec);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)

            this.Fpass1=s.Fpass1;
            this.F3dB1=s.F3dB1;
            this.F6dB1=s.F6dB1;
            this.Fstop1=s.Fstop1;
            this.Fstop2=s.Fstop2;
            this.F6dB2=s.F6dB2;
            this.F3dB2=s.F3dB2;
            this.Fpass2=s.Fpass2;
            this.BWpass=s.BWpass;
            this.BWstop=s.BWstop;
            this.Apass1=s.Apass1;
            this.Astop=s.Astop;
            this.Apass2=s.Apass2;
            this.FrequencyConstraints=s.FrequencyConstraints;
            this.MagnitudeConstraints=s.MagnitudeConstraints;



            if~isfield(s,'Passband1Constrained')
                this.Passband1Constrained='false';
            else
                this.Passband1Constrained=s.Passband1Constrained;
            end

            if~isfield(s,'StopbandConstrained')
                this.StopbandConstrained='false';
            else
                this.StopbandConstrained=s.StopbandConstrained;
            end

            if~isfield(s,'Passband2Constrained')
                this.Passband2Constrained='false';
            else
                this.Passband2Constrained=s.Passband2Constrained;
            end

            if~isfield(s,'SpecifyDenominator')
                this.SpecifyDenominator=false;
            else
                this.SpecifyDenominator=s.SpecifyDenominator;
            end

            if~isfield(s,'DenominatorOrder')
                this.DenominatorOrder='20';
            else
                this.DenominatorOrder=s.DenominatorOrder;
            end

            if~isfield(this.LastAppliedState,'SpecifyDenominator')
                this.LastAppliedState.SpecifyDenominator=false;
            end


        end


        function s=thissaveobj(this,s)

            s.Fpass1=this.Fpass1;
            s.F3dB1=this.F3dB1;
            s.F6dB1=this.F6dB1;
            s.Fstop1=this.Fstop1;
            s.Fstop2=this.Fstop2;
            s.F6dB2=this.F6dB2;
            s.F3dB2=this.F3dB2;
            s.Fpass2=this.Fpass2;
            s.BWpass=this.BWpass;
            s.BWstop=this.BWstop;
            s.Apass1=this.Apass1;
            s.Astop=this.Astop;
            s.Apass2=this.Apass2;
            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;

            s.Passband1Constrained=this.Passband1Constrained;
            s.StopbandConstrained=this.StopbandConstrained;
            s.Passband2Constrained=this.Passband2Constrained;
            s.SpecifyDenominator=this.SpecifyDenominator;
            s.DenominatorOrder=this.DenominatorOrder;
        end


        function fc=lcl_get_frequencyconstraints(this,fc)

            if isminorder(this)
                fc='Passband and stopband edges';
            end
        end


        function mc=lcl_get_magnitudeconstraints(this,mc)

            if isminorder(this)
                mc='Passband ripples and stopband attenuation';
            end
        end

    end
end

