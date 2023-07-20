classdef(CaseInsensitiveProperties)BandpassDesign<FilterDesignDialog.AbstractBpBsDesign




    properties(AbortSet,SetObservable,GetObservable)

        Fstop1='0.35';

        F6dB1='0.4';

        F3dB1='0.4';

        Fpass1='0.45';

        Fpass2='0.55';

        F3dB2='0.6';

        F6dB2='0.6';

        Fstop2='0.65';

        BWpass='0.15';

        BWstop='0.25';

        Astop1='60';

        Apass='1';

        Astop2='60';

        Stopband1Constrained='false';

        PassbandConstrained='false';

        Stopband2Constrained='false';
    end

    properties(AbortSet,SetObservable,GetObservable,Dependent)





        FrequencyConstraints;





        MagnitudeConstraints;
    end

    properties(AbortSet,SetObservable,GetObservable,Hidden)





        privFrequencyConstraints='Passband and stopband edges';





        privMagnitudeConstraints='Unconstrained';
    end

    properties(Constant,Hidden)

        FrequencyConstraintsSet={'Passband and stopband edges','Passband edges',...
        'Stopband edges','6dB points','3dB points',...
        '3dB points and stopband width','3dB points and passband width'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('Fst1Fp1Fp2Fst2'),...
        FilterDesignDialog.message('Fp1Fp2'),...
        FilterDesignDialog.message('Fst1Fst2'),...
        FilterDesignDialog.message('Fc1Fc2'),...
        FilterDesignDialog.message('F3dB1F3dB2'),...
        FilterDesignDialog.message('F3dB1F3dB2BWst'),...
        FilterDesignDialog.message('F3dB1F3dB2BWp')};

        MagnitudeConstraintsSet={'Unconstrained','Passband ripple and stopband attenuations',...
        'Passband ripple','Stopband attenuation','Constrained bands'};
        MagnitudeConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('ApAst1Ast2'),...
        FilterDesignDialog.message('Ap'),...
        FilterDesignDialog.message('Ast'),...
        FilterDesignDialog.message('constrainedbands')};
    end

    methods
        function this=BandpassDesign(varargin)

            if~isempty(varargin)
                set(this,varargin{:});
            end
            this.VariableName=this.getOutputVarName('bp');

            this.FDesign=fdesign.bandpass;
            this.DesignMethod='Equiripple';


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);

        end

    end

    methods
        function set.Fstop1(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fstop1')
            obj.Fstop1=value;
        end

        function set.F6dB1(obj,value)

            validateattributes(value,{'char'},{'row'},'','F6dB1')
            obj.F6dB1=value;
        end

        function set.F3dB1(obj,value)

            validateattributes(value,{'char'},{'row'},'','F3dB1')
            obj.F3dB1=value;
        end

        function set.Fpass1(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fpass1')
            obj.Fpass1=value;
        end

        function set.Fpass2(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fpass2')
            obj.Fpass2=value;
        end

        function set.F3dB2(obj,value)

            validateattributes(value,{'char'},{'row'},'','F3dB2')
            obj.F3dB2=value;
        end

        function set.F6dB2(obj,value)

            validateattributes(value,{'char'},{'row'},'','F6dB2')
            obj.F6dB2=value;
        end

        function set.Fstop2(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fstop2')
            obj.Fstop2=value;
        end

        function set.BWpass(obj,value)

            validateattributes(value,{'char'},{'row'},'','BWpass')
            obj.BWpass=value;
        end

        function set.BWstop(obj,value)

            validateattributes(value,{'char'},{'row'},'','BWstop')
            obj.BWstop=value;
        end

        function set.Astop1(obj,value)

            validateattributes(value,{'char'},{'row'},'','Astop1')
            obj.Astop1=value;
        end

        function set.Apass(obj,value)

            validateattributes(value,{'char'},{'row'},'','Apass')
            obj.Apass=value;
        end

        function set.Astop2(obj,value)

            validateattributes(value,{'char'},{'row'},'','Astop2')
            obj.Astop2=value;
        end

        function set.Stopband1Constrained(obj,value)

            validateattributes(value,{'char'},{'row'},'','Stopband1Constrained')
            obj.Stopband1Constrained=value;
        end

        function set.PassbandConstrained(obj,value)

            validateattributes(value,{'char'},{'row'},'','PassbandConstrained')
            obj.PassbandConstrained=value;
        end

        function set.Stopband2Constrained(obj,value)

            validateattributes(value,{'char'},{'row'},'','Stopband2Constrained')
            obj.Stopband2Constrained=value;
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



            laState=this.LastAppliedState;
            specs=getSpecs(this,laState);
            spec=getSpecification(this,laState);

            if strcmp(spec,'n,fst1,fp1,fp2,fst2,c')
                inputs.Variables(end)=[];
                inputs.Values(end)=[];
                inputs.Descriptions(end)=[];

                inputs.Variables{end+1}='Stopband1Constrained';
                inputs.Values{end+1}=mat2str(specs.Stopband1Constrained);
                inputs.Descriptions{end+1}='';
                if specs.Stopband1Constrained
                    inputs.Variables{end+1}='Astop1';
                    inputs.Values{end+1}=mat2str(specs.Astop1);
                    inputs.Descriptions{end+1}='';
                end

                inputs.Variables{end+1}='PassbandConstrained';
                inputs.Values{end+1}=mat2str(specs.PassbandConstrained);
                inputs.Descriptions{end+1}='';
                if specs.PassbandConstrained
                    inputs.Variables{end+1}='Apass';
                    inputs.Values{end+1}=mat2str(specs.Apass);
                    inputs.Descriptions{end+1}='';
                end

                inputs.Variables{end+1}='Stopband2Constrained';
                inputs.Values{end+1}=mat2str(specs.Stopband2Constrained);
                inputs.Descriptions{end+1}='';
                if specs.Stopband2Constrained
                    inputs.Variables{end+1}='Astop2';
                    inputs.Values{end+1}=mat2str(specs.Astop2);
                    inputs.Descriptions{end+1}='';
                end

            end

        end


        function dialogTitle=getDialogTitle(this)



            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('BandpassFilter');
            else
                if isFilterDesignerMode(this)
                    dialogTitle=FilterDesignDialog.message(['BandpassDesign',this.ImpulseResponse]);
                else
                    dialogTitle=FilterDesignDialog.message('BandpassDesign');
                end
            end


        end


        function fspecs=getFrequencySpecsFrame(this)





            items=getConstraintsWidgets(this,'Frequency',1);

            items=getFrequencyUnitsWidgets(this,2,items);

            switch lower(this.FrequencyConstraints)
            case 'passband edges'
                [items,col]=addConstraint(this,3,1,items,true,...
                'Fpass1',FilterDesignDialog.message('Fpass1'),'First passband edge');
                items=addConstraint(this,3,col,items,true,...
                'Fpass2',FilterDesignDialog.message('Fpass2'),'Second passband edge');
            case 'stopband edges'
                [items,col]=addConstraint(this,3,1,items,true,...
                'Fstop1',FilterDesignDialog.message('Fstop1'),'First stopband edge');
                items=addConstraint(this,3,col,items,true,...
                'Fstop2',FilterDesignDialog.message('Fstop2'),'Second stopband edge');
            case 'passband and stopband edges'
                [items,col]=addConstraint(this,3,1,items,true,...
                'Fstop1',FilterDesignDialog.message('Fstop1'),'First stopband edge');
                items=addConstraint(this,3,col,items,true,...
                'Fpass1',FilterDesignDialog.message('Fpass1'),'First passband edge');
                [items,col]=addConstraint(this,4,1,items,true,...
                'Fpass2',FilterDesignDialog.message('Fpass2'),'Second passband edge');
                items=addConstraint(this,4,col,items,true,...
                'Fstop2',FilterDesignDialog.message('Fstop2'),'Second stopband edge');
            case '3db points'
                [items,col]=addConstraint(this,3,1,items,true,...
                'F3dB1',FilterDesignDialog.message('freq3dB1'),'First 3dB point');
                items=addConstraint(this,3,col,items,true,...
                'F3dB2',FilterDesignDialog.message('freq3dB2'),'Second 3dB point');
            case '6db points'
                [items,col]=addConstraint(this,3,1,items,true,...
                'F6dB1',FilterDesignDialog.message('freq6dB1'),'First 6dB point');
                items=addConstraint(this,3,col,items,true,...
                'F6dB2',FilterDesignDialog.message('freq6dB2'),'Second 6dB point');
            case '3db points and stopband width'
                [items,col]=addConstraint(this,3,1,items,true,...
                'F3dB1',FilterDesignDialog.message('freq3dB1'),'First 3dB point');
                items=addConstraint(this,3,col,items,true,...
                'F3dB2',FilterDesignDialog.message('freq3dB2'),'Second 3dB point');
                items=addConstraint(this,4,1,items,true,...
                'BWstop',FilterDesignDialog.message('BWstop'));
            case '3db points and passband width'
                [items,col]=addConstraint(this,3,1,items,true,...
                'F3dB1',FilterDesignDialog.message('freq3dB1'),'First 3dB point');
                items=addConstraint(this,3,col,items,true,...
                'F3dB2',FilterDesignDialog.message('freq3dB2'),'Second 3dB point');
                items=addConstraint(this,4,1,items,true,...
                'BWpass',FilterDesignDialog.message('BWpass'));
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
                helptext.Name=FilterDesignDialog.message('BandpassDesignHelpTxt');
            end
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function helptext=getHelpText(~)




            helptext.Type='text';
            helptext.Name='We need to add help here';
            helptext.Tag='HelpText';


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
                    'Apass',FilterDesignDialog.message('Apass'),'Passband ripple');
                case 'stopband attenuation'
                    items=addConstraint(this,3,1,items,true,...
                    'Astop1',FilterDesignDialog.message('Astop'),'Stopband attenuation');
                case 'passband ripple and stopband attenuations'
                    [items,col]=addConstraint(this,3,1,items,true,...
                    'Astop1',FilterDesignDialog.message('Astop1'),'First stopband attenuation');
                    items=addConstraint(this,3,col,items,true,...
                    'Apass',FilterDesignDialog.message('Apass'),'Passband ripple');
                    items=addConstraint(this,4,1,items,true,...
                    'Astop2',FilterDesignDialog.message('Astop2'),'Second stopband attenuation');
                case 'constrained bands'
                    [items,col]=addConstraintBands(this,3,1,items,true,...
                    'Stopband1Constrained','Astop1',...
                    FilterDesignDialog.message('Astop1'),...
                    strcmpi(this.Stopband1Constrained,'true'),...
                    'First stopband attenuation');
                    items=addConstraintBands(this,3,col,items,true,...
                    'PassbandConstrained','Apass',...
                    FilterDesignDialog.message('Apass'),...
                    strcmpi(this.PassbandConstrained,'true'),...
                    'Passband ripple');
                    items=addConstraintBands(this,4,1,items,true,...
                    'Stopband2Constrained','Astop2',...
                    FilterDesignDialog.message('Astop2'),...
                    strcmpi(this.Stopband2Constrained,'true'),...
                    'Second stopband attenuation');
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
                specification='fst1,fp1,fp2,fst2,ast1,ap,ast2';
            elseif isDSTMode(this)&&strcmpi(laState.ImpulseResponse,'iir')&&laState.SpecifyDenominator
                specification='nb,na,fst1,fp1,fp2,fst2';
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
                    specification=[specification,',fst1,fp1,fp2,fst2'];
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
                case 'passband ripple and stopband attenuations'
                    specification=[specification,',ast1,ap,ast2'];
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
            case 'fst1,fp1,fp2,fst2,ast1,ap,ast2'
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Astop1=evaluateVariable(this,source.Astop1);
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.Astop2=evaluateVariable(this,source.Astop2);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,f3db1,f3db2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
            case 'n,f3db1,f3db2,ap'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,f3db1,f3db2,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
                specs.Astop=evaluateVariable(this,source.Astop1);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,f3db1,f3db2,ast1,ap,ast2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB1=getnum(this,source,'F3dB1');
                specs.F3dB2=getnum(this,source,'F3dB2');
                specs.Astop1=evaluateVariable(this,source.Astop1);
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.Astop2=evaluateVariable(this,source.Astop2);
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
            case 'n,fc1,fc2,ast1,ap,ast2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F6dB1=getnum(this,source,'F6dB1');
                specs.F6dB2=getnum(this,source,'F6dB2');
                specs.Astop1=evaluateVariable(this,source.Astop1);
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.Astop2=evaluateVariable(this,source.Astop2);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fp1,fp2,ap'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fp1,fp2,ast1,ap,ast2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Astop1=evaluateVariable(this,source.Astop1);
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.Astop2=evaluateVariable(this,source.Astop2);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fst1,fp1,fp2,fst2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Fstop2=getnum(this,source,'Fstop2');
            case 'n,fst1,fp1,fp2,fst2,c'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Stopband1Constrained=strcmpi(source.Stopband1Constrained,'true');
                specs.PassbandConstrained=strcmpi(source.PassbandConstrained,'true');
                specs.Stopband2Constrained=strcmpi(source.Stopband2Constrained,'true');
                specs.MagnitudeUnits=this.MagnitudeUnits;
                if specs.Stopband1Constrained
                    specs.Astop1=evaluateVariable(this,source.Astop1);
                end
                if specs.PassbandConstrained
                    specs.Apass=evaluateVariable(this,source.Apass);
                end
                if specs.Stopband2Constrained
                    specs.Astop2=evaluateVariable(this,source.Astop2);
                end
            case 'n,fst1,fp1,fp2,fst2,ap'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fst1,fst2,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fstop2=getnum(this,source,'Fstop2');
                specs.Astop=evaluateVariable(this,source.Astop1);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'nb,na,fst1,fp1,fp2,fst2'
                specs.Order=evaluateVariable(this,source.Order);
                specs.DenominatorOrder=evaluateVariable(this,source.DenominatorOrder);
                specs.Fstop1=getnum(this,source,'Fstop1');
                specs.Fpass1=getnum(this,source,'Fpass1');
                specs.Fpass2=getnum(this,source,'Fpass2');
                specs.Fstop2=getnum(this,source,'Fstop2');
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
                availableconstraints={'Passband ripple and stopband attenuations'};
                return;
            end

            if isDSTMode(this)&&strcmpi(this.ImpulseResponse,'iir')&&...
                this.SpecifyDenominator
                availableconstraints={'Unconstrained'};
                return;
            end

            if nargin<2
                fconstraints=get(this,'FrequencyConstraints');
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
                    if isDSTMode(this)
                        availableconstraints={'Passband ripple',...
                        'Unconstrained'};
                    else
                        availableconstraints={'Unconstrained'};
                    end
                end
            case 'passband edges'

                availableconstraints={'Passband ripple',...
                'Passband ripple and stopband attenuations'};
            case 'stopband edges'

                availableconstraints={'Stopband attenuation'};
            case '6db points'
                availableconstraints={'Unconstrained',...
                'Passband ripple and stopband attenuations'};
            case '3db points'
                if isDSTMode(this)
                    availableconstraints={'Passband ripple','Stopband attenuation',...
                    'Passband ripple and stopband attenuations','Unconstrained'};
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
            if~strcmpi(get(hfdesign,'Response'),'bandpass')
                b=false;
                return;
            end

            switch lower(hfdesign.Specification)
            case 'fst1,fp1,fp2,fst2,ast1,ap,ast2'
                set(this,...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Astop1',num2str(hfdesign.Astop1),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop2',num2str(hfdesign.Astop2));
            case 'n,f3db1,f3db2'
                set(this,...
                'privFrequencyConstraints','3dB points',...
                'privMagnitudeConstraints','unconstrained',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2));
            case 'n,f3db1,f3db2,ap'
                set(this,...
                'privFrequencyConstraints','3dB points',...
                'privMagnitudeConstraints','passband ripple',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'Apass',num2str(hfdesign.Apass));
            case 'n,f3db1,f3db2,ast'
                set(this,...
                'privFrequencyConstraints','3dB points',...
                'privMagnitudeConstraints','stopband attenuation',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'Astop1',num2str(hfdesign.Astop));
            case 'n,f3db1,f3db2,ast1,ap,ast2'
                set(this,...
                'privFrequencyConstraints','3dB points',...
                'privMagnitudeConstraints','passband ripple and stopband attenuations',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'Astop1',num2str(hfdesign.Astop1),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop2',num2str(hfdesign.Astop2));
            case 'n,f3db1,f3db2,bwp'
                set(this,...
                'privFrequencyConstraints','3dB points and passband width',...
                'privMagnitudeConstraints','unconstrained',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'BWpass',num2str(hfdesign.BWpass));
            case 'n,f3db1,f3db2,bwst'
                set(this,...
                'privFrequencyConstraints','3dB points and stopband width',...
                'privMagnitudeConstraints','unconstrained',...
                'F3dB1',num2str(hfdesign.F3dB1),...
                'F3dB2',num2str(hfdesign.F3dB2),...
                'BWstop',num2str(hfdesign.BWstop));
            case 'n,fc1,fc2'
                set(this,...
                'privFrequencyConstraints','6dB points',...
                'privMagnitudeConstraints','unconstrained',...
                'F6dB1',num2str(hfdesign.Fcutoff1),...
                'F6dB2',num2str(hfdesign.Fcutoff2));
            case 'n,fc1,fc2,ast1,ap,ast2'
                set(this,...
                'privFrequencyConstraints','6dB points',...
                'privMagnitudeConstraints','passband ripple and stopband attenuations',...
                'F6dB1',num2str(hfdesign.Fcutoff1),...
                'F6dB2',num2str(hfdesign.Fcutoff2),...
                'Astop1',num2str(hfdesign.Astop1),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop2',num2str(hfdesign.Astop2));
            case 'n,fp1,fp2,ap'
                set(this,...
                'privFrequencyConstraints','passband edges',...
                'privMagnitudeConstraints','passband ripple',...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Apass',num2str(hfdesign.Apass));
            case 'n,fp1,fp2,ast1,ap,ast2'
                set(this,...
                'privFrequencyConstraints','passband edges',...
                'privMagnitudeConstraints','passband ripple and stopband attenuations',...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Astop1',num2str(hfdesign.Astop1),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop2',num2str(hfdesign.Astop2));
            case 'n,fst1,fp1,fp2,fst2'
                set(this,...
                'privFrequencyConstraints','passband and stopband edges',...
                'privMagnitudeConstraints','unconstrained',...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Fstop2',num2str(hfdesign.Fstop2));
            case 'n,fst1,fp1,fp2,fst2,c'
                set(this,...
                'privFrequencyConstraints','passband and stopband edges',...
                'privMagnitudeConstraints','constrained bands',...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Stopband1Constrained',mat2str(hfdesign.Stopband1Constrained),...
                'PassbandConstrained',mat2str(hfdesign.PassbandConstrained),...
                'Stopband2Constrained',mat2str(hfdesign.Stopband2Constrained));
                if hfdesign.Stopband1Constrained
                    set(this,'Astop1',num2str(hfdesign.Astop1));
                end
                if hfdesign.PassbandConstrained
                    set(this,'Apass',num2str(hfdesign.Apass));
                end
                if hfdesign.Stopband2Constrained
                    set(this,'Astop2',num2str(hfdesign.Astop2));
                end
            case 'n,fst1,fp1,fp2,fst2,ap'
                set(this,...
                'privFrequencyConstraints','passband and stopband edges',...
                'privMagnitudeConstraints','passband ripple',...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Apass',num2str(hfdesign.Apass));
            case 'n,fst1,fst2,ast'
                set(this,...
                'privFrequencyConstraints','stopband edges',...
                'privMagnitudeConstraints','stopband attenuation',...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fstop2',num2str(hfdesign.Fstop2),...
                'Astop1',num2str(hfdesign.Astop));
            case 'nb,na,fst1,fp1,fp2,fst2'
                set(this,...
                'privFrequencyConstraints','passband and stopband edges',...
                'privMagnitudeConstraints','unconstrained',...
                'Fstop1',num2str(hfdesign.Fstop1),...
                'Fpass1',num2str(hfdesign.Fpass1),...
                'Fpass2',num2str(hfdesign.Fpass2),...
                'Fstop2',num2str(hfdesign.Fstop2));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:BandpassDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function[success,msg]=setupFDesign(this,varargin)



            success=true;
            msg='';

            hd=get(this,'FDesign');

            spec=getSpecification(this,varargin{:});



            setSpecsSafely(this,hd,spec);

            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end



            try
                specs=getSpecs(this,source);

                if strncmpi(specs.FrequencyUnits,'normalized',10)
                    normalizefreq(hd);
                else
                    normalizefreq(hd,false,specs.InputSampleRate);
                end

                switch spec
                case 'fst1,fp1,fp2,fst2,ast1,ap,ast2'
                    setspecs(hd,specs.Fstop1,specs.Fpass1,specs.Fpass2,specs.Fstop2,...
                    specs.Astop1,specs.Apass,specs.Astop2,specs.MagnitudeUnits);
                case 'n,f3db1,f3db2'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2);
                case 'n,f3db1,f3db2,ap'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,...
                    specs.Apass,specs.MagnitudeUnits);
                case 'n,f3db1,f3db2,ast'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,f3db1,f3db2,ast1,ap,ast2'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,specs.Astop1,...
                    specs.Apass,specs.Astop2,specs.MagnitudeUnits);
                case 'n,f3db1,f3db2,bwp'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,specs.BWpass);
                case 'n,f3db1,f3db2,bwst'
                    setspecs(hd,specs.Order,specs.F3dB1,specs.F3dB2,specs.BWstop);
                case 'n,fc1,fc2'
                    setspecs(hd,specs.Order,specs.F6dB1,specs.F6dB2);
                case 'n,fc1,fc2,ast1,ap,ast2'
                    setspecs(hd,specs.Order,specs.F6dB1,specs.F6dB2,specs.Astop1,...
                    specs.Apass,specs.Astop2);
                case 'n,fp1,fp2,ap'
                    setspecs(hd,specs.Order,specs.Fpass1,specs.Fpass2,...
                    specs.Apass,specs.MagnitudeUnits);
                case 'n,fp1,fp2,ast1,ap,ast2'
                    setspecs(hd,specs.Order,specs.Fpass1,specs.Fpass2,specs.Astop1,...
                    specs.Apass,specs.Astop2,specs.MagnitudeUnits);
                case 'n,fst1,fp1,fp2,fst2'
                    setspecs(hd,specs.Order,specs.Fstop1,specs.Fpass1,...
                    specs.Fpass2,specs.Fstop2);
                case 'n,fst1,fp1,fp2,fst2,c'
                    setspecs(hd,specs.Order,specs.Fstop1,specs.Fpass1,...
                    specs.Fpass2,specs.Fstop2,specs.Stopband1Constrained,...
                    specs.PassbandConstrained,specs.Stopband2Constrained);
                    isLinearMagUnits=strcmpi(specs.MagnitudeUnits,'linear');
                    if hd.Stopband1Constrained
                        if isLinearMagUnits
                            specs.Astop1=convertmagunits(specs.Astop1,'linear','db','stop');
                        end
                        hd.Astop1=specs.Astop1;
                    end
                    if hd.PassbandConstrained
                        if isLinearMagUnits
                            specs.Apass=convertmagunits(specs.Apass,'linear','db','pass');
                        end
                        hd.Apass=specs.Apass;
                    end
                    if hd.Stopband2Constrained
                        if isLinearMagUnits
                            specs.Astop2=convertmagunits(specs.Astop2,'linear','db','stop');
                        end
                        hd.Astop2=specs.Astop2;
                    end
                case 'n,fst1,fp1,fp2,fst2,ap'
                    setspecs(hd,specs.Order,specs.Fstop1,specs.Fpass1,specs.Fpass2,...
                    specs.Fstop2,specs.Apass,specs.MagnitudeUnits);
                case 'n,fst1,fst2,ast'
                    setspecs(hd,specs.Order,specs.Fstop1,specs.Fstop2,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'nb,na,fst1,fp1,fp2,fst2'
                    setspecs(hd,specs.Order,specs.DenominatorOrder,specs.Fstop1,...
                    specs.Fpass1,specs.Fpass2,specs.Fstop2);
                otherwise
                    fprintf('Finish %s',spec);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)



            this.Fstop1=s.Fstop1;
            this.F6dB1=s.F6dB1;
            this.F3dB1=s.F3dB1;
            this.Fpass1=s.Fpass1;
            this.Fpass2=s.Fpass2;
            this.F3dB2=s.F3dB2;
            this.F6dB2=s.F6dB2;
            this.Fstop2=s.Fstop2;
            this.BWpass=s.BWpass;
            this.BWstop=s.BWstop;
            this.Astop1=s.Astop1;
            this.Apass=s.Apass;
            this.Astop2=s.Astop2;
            this.FrequencyConstraints=s.FrequencyConstraints;
            this.MagnitudeConstraints=s.MagnitudeConstraints;



            if~isfield(s,'Stopband1Constrained')
                this.Stopband1Constrained='false';
            else
                this.Stopband1Constrained=s.Stopband1Constrained;
            end

            if~isfield(s,'PassbandConstrained')
                this.PassbandConstrained='false';
            else
                this.PassbandConstrained=s.PassbandConstrained;
            end

            if~isfield(s,'Stopband2Constrained')
                this.Stopband2Constrained='false';
            else
                this.Stopband2Constrained=s.Stopband2Constrained;
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



            s.Fstop1=this.Fstop1;
            s.F6dB1=this.F6dB1;
            s.F3dB1=this.F3dB1;
            s.Fpass1=this.Fpass1;
            s.Fpass2=this.Fpass2;
            s.F3dB2=this.F3dB2;
            s.F6dB2=this.F6dB2;
            s.Fstop2=this.Fstop2;
            s.BWpass=this.BWpass;
            s.BWstop=this.BWstop;
            s.Astop1=this.Astop1;
            s.Apass=this.Apass;
            s.Astop2=this.Astop2;
            s.MagnitudeConstraints=this.MagnitudeConstraints;
            s.FrequencyConstraints=this.FrequencyConstraints;

            s.Stopband1Constrained=this.Stopband1Constrained;
            s.PassbandConstrained=this.PassbandConstrained;
            s.Stopband2Constrained=this.Stopband2Constrained;
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
                mc='Passband ripple and stopband attenuations';
            end
        end

    end

end

