classdef(CaseInsensitiveProperties)CICCompDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(SetObservable)

        Fpass='0.45';

        F6dB='0.5';

        Fstop='0.55';

        Apass='1';

        Astop='60';

        NumberOfSections='2';

        DifferentialDelay='1';

        CICRateChangeFactor='1';

        SpecifyCICRateChangeFactor(1,1)logical=false;

    end

    properties(Dependent)




        FrequencyConstraints;



        MagnitudeConstraints;
    end

    properties(SetObservable,Hidden)




        privFrequencyConstraints='Passband edge and stopband edge';



        privMagnitudeConstraints='Unconstrained';
    end

    properties(Constant,Hidden)

        FrequencyConstraintsSet=...
        {'Passband edge and stopband edge','Passband edge','Stopband edge','6dB point'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('FpFst'),...
        FilterDesignDialog.message('Fp'),...
        FilterDesignDialog.message('Fst'),...
        FilterDesignDialog.message('Fc')}

        MagnitudeConstraintsSet={...
        'Unconstrained','Passband ripple and stopband attenuation'};
        MagnitudeConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('ApAst')};

    end


    methods
        function this=CICCompDesign(varargin)


            this.VariableName=uiservices.getVariableName('Hciccomp');
            if~isempty(varargin)
                set(this,varargin{:});
            end

            this.FDesign=fdesign.ciccomp;
            updateMethod(this);
            this.DesignMethod='Equiripple';

            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);


        end

    end

    methods
        function set.Fpass(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fpass')
            obj.Fpass=value;
        end

        function set.F6dB(obj,value)

            validateattributes(value,{'char'},{'row'},'','F6dB')
            obj.F6dB=value;
        end

        function set.Fstop(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fstop')
            obj.Fstop=value;
        end

        function set.Apass(obj,value)

            validateattributes(value,{'char'},{'row'},'','Apass')
            obj.Apass=value;
        end

        function set.Astop(obj,value)

            validateattributes(value,{'char'},{'row'},'','Astop')
            obj.Astop=value;
        end

        function set.NumberOfSections(obj,value)

            validateattributes(value,{'char'},{'row'},'','NumberOfSections')
            obj.NumberOfSections=value;
        end

        function set.DifferentialDelay(obj,value)

            validateattributes(value,{'char'},{'row'},'','DifferentialDelay')
            obj.DifferentialDelay=value;
        end

        function set.CICRateChangeFactor(obj,value)

            validateattributes(value,{'char'},{'row'},'','CICRateChangeFactor')
            obj.CICRateChangeFactor=value;
        end

        function set.SpecifyCICRateChangeFactor(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','SpecifyCICRateChangeFactor')
            value=logical(value);
            obj.SpecifyCICRateChangeFactor=value;
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

        function set_ordermode(this)

            if strcmpi(this.OrderMode,'Specify')&&(any(strcmpi(this.OperatingMode,{'Simulink'})))
                this.FrequencyConstraints='Passband edge and stopband edge';
                this.MagnitudeConstraints='Unconstrained';
            end

            updateMethod(this);
        end


        function set_frequencyconstraints(this)


            updateMagConstraints(this);

        end


        function set_magnitudeconstraints(this,~)


            updateMethod(this);

        end


        function dialogTitle=getDialogTitle(this)




            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('CICCompensator');
            else
                dialogTitle=FilterDesignDialog.message('CICCompensatorDesign');
            end


        end


        function fspecs=getFrequencySpecsFrame(this)





            items=getConstraintsWidgets(this,'Frequency',1);


            items=getFrequencyUnitsWidgets(this,2,items);


            hasfpass=contains(lower(this.FrequencyConstraints),'passband edge');
            hasfstop=contains(lower(this.FrequencyConstraints),'stopband edge');
            hasf6db=contains(lower(this.FrequencyConstraints),'6db point');

            [items,col]=addConstraint(this,3,1,items,hasf6db,...
            'F6dB',FilterDesignDialog.message('Fc'),'6dB point');
            [items,col]=addConstraint(this,3,col,items,hasfpass,...
            'Fpass',FilterDesignDialog.message('Fpass'),'Passband edge');
            items=addConstraint(this,3,col,items,hasfstop,...
            'Fstop',FilterDesignDialog.message('Fstop'),'Stopband edge');

            fspecs.Name=FilterDesignDialog.message('freqspecs');
            fspecs.Type='group';
            fspecs.Items=items;
            fspecs.LayoutGrid=[4,4];
            fspecs.RowStretch=[0,0,0,1];
            fspecs.ColStretch=[0,1,0,1];
            fspecs.Tag='FreqSpecsGroup';


        end


        function headerFrame=getHeaderFrame(this)



            orderwidgets=getOrderWidgets(this,1,true);
            ftypewidgets=getFilterTypeWidgets(this,2);

            [nsecs_lbl,nsecs]=getWidgetSchema(this,'NumberOfSections',...
            FilterDesignDialog.message('NumCICSections'),'combobox',4,1);

            tunable=~isminorder(this)&&this.BuildUsingBasicElements;

            nsecs_lbl.Tunable=tunable;

            nsecs.Editable=true;
            nsecs.Entries={'1','2','3','4','5','6','7','8'};
            nsecs.Tunable=tunable;

            [diffdelay_lbl,diffdelay]=getWidgetSchema(this,'DifferentialDelay',...
            FilterDesignDialog.message('DifferentialDelay'),'combobox',4,3);

            diffdelay_lbl.Tunable=tunable;

            diffdelay.Editable=true;
            diffdelay.Entries={'1','2'};
            diffdelay.Tunable=tunable;

            CICRCF_lbl.Name=FilterDesignDialog.message('CICRCF');
            CICRCF_lbl.Type='checkbox';
            CICRCF_lbl.Source=this;
            CICRCF_lbl.Mode=true;
            CICRCF_lbl.DialogRefresh=true;
            CICRCF_lbl.RowSpan=[5,5];
            CICRCF_lbl.ColSpan=[1,1];
            CICRCF_lbl.Enabled=true;
            CICRCF_lbl.Tag='SpecifyCICRateChangeFactor';
            CICRCF_lbl.ObjectProperty='SpecifyCICRateChangeFactor';

            CICRCF.Type='edit';
            CICRCF.Source=this;
            CICRCF.Mode=true;
            CICRCF.DialogRefresh=true;
            CICRCF.RowSpan=[5,5];
            CICRCF.ColSpan=[2,2];
            CICRCF.Enabled=true;
            CICRCF.Tag='CICRateChangeFactor';
            CICRCF.ObjectProperty='CICRateChangeFactor';



            CICRCEmpty.Type='edit';
            CICRCEmpty.Source=this;
            CICRCEmpty.Mode=true;
            CICRCEmpty.DialogRefresh=true;
            CICRCEmpty.RowSpan=[5,5];
            CICRCEmpty.ColSpan=[2,2];
            CICRCEmpty.Enabled=false;
            CICRCEmpty.Value='';
            CICRCEmpty.Tag='CICRateChangeFactorFake';

            if this.SpecifyCICRateChangeFactor
                CICRCF.Enabled=true;
                CICRCF.Visible=true;
                CICRCEmpty.Visible=false;
            else
                CICRCF.Enabled=false;
                CICRCF.Visible=false;
                CICRCEmpty.Visible=true;
            end

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');
            headerFrame.Items={orderwidgets{:},ftypewidgets{:},nsecs_lbl,nsecs,...
            diffdelay_lbl,diffdelay,CICRCF_lbl,CICRCF,CICRCEmpty};%#ok<CCAT>
            headerFrame.LayoutGrid=[5,4];
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('CICCompensatorDesignHelpTxt');
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function mCodeInfo=getMCodeInfo(this)




            laState=get(this,'LastAppliedState');
            specs=getSpecs(this,laState);


            spec=getSpecification(this,laState);
            specCell=textscan(spec,'%s','delimiter',',');
            specCell=specCell{1};


            offset=2;
            if specs.CICRateChangeFactor>1
                offset=3;
            end

            vars=cell(length(specCell)+offset,1);
            vals=vars;
            descs=vars;

            vars{1}='delay';
            vals{1}=num2str(specs.DifferentialDelay);
            descs{1}='Differential Delay';

            vars{2}='NSecs';
            vals{2}=num2str(specs.NumberOfSections);
            descs{2}='Number of Sections';

            if specs.CICRateChangeFactor>1
                vars{3}='CICRCF';
                vals{3}=num2str(specs.CICRateChangeFactor);
                descs{3}='CIC Rate Change Factor';
            end

            for indx=1:length(specCell)
                switch lower(specCell{indx})
                case 'n'
                    vars{indx+offset}='N';
                    vals{indx+offset}=num2str(specs.Order);
                case 'ast'
                    vars{indx+offset}='Astop';
                    vals{indx+offset}=num2str(specs.Astop);
                case 'fp'
                    vars{indx+offset}='Fpass';
                    vals{indx+offset}=num2str(specs.Fpass);
                case 'fst'
                    vars{indx+offset}='Fstop';
                    vals{indx+offset}=num2str(specs.Fstop);
                case 'fc'
                    vars{indx+offset}='F6dB';
                    vals{indx+offset}=num2str(specs.F6dB);
                case 'ap'
                    vars{indx+offset}='Apass';
                    vals{indx+offset}=num2str(specs.Apass);
                end
            end

            mCodeInfo.Variables=vars;
            mCodeInfo.Values=vals;
            mCodeInfo.Inputs={vars{1:offset},...
            sprintf('''%s''',getSpecification(this,laState)),vars{offset+1:end}};
            mCodeInfo.Descriptions=descs;


        end


        function mspecs=getMagnitudeSpecsFrame(this)




            spacer.Name=' ';
            spacer.Type='text';
            spacer.RowSpan=[1,1];
            spacer.ColSpan=[1,1];
            spacer.Tag='Spacer';

            items=getConstraintsWidgets(this,'Magnitude',1);

            if strcmpi(this.MagnitudeConstraints,'unconstrained')


                spacer.RowSpan=[2,2];
                spacer.Tag='Spacer2';

                items={items{:},spacer};%#ok<CCAT>

                spacer.RowSpan=[3,3];

                items={items{:},spacer};%#ok<CCAT>

            else
                items=getMagnitudeUnitsWidgets(this,2,items);

                [items,col]=addConstraint(this,3,1,items,true,...
                'Apass',FilterDesignDialog.message('Apass'),'Passband ripple');
                items=addConstraint(this,3,col,items,true,...
                'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');

            end

            mspecs.Name=FilterDesignDialog.message('magspecs');
            mspecs.Type='group';
            mspecs.Items=items;
            mspecs.LayoutGrid=[4,4];
            mspecs.RowStretch=[0,0,0,1];
            mspecs.ColStretch=[0,1,0,1];
            mspecs.Tag='MagSpecsGroup';



        end


        function specification=getSpecification(this,laState)




            if nargin<2
                laState=this;
            end

            if isminorder(this,laState)
                specification='fp,fst,ap,ast';
            else

                freqcons=laState.FrequencyConstraints;
                magcons=laState.MagnitudeConstraints;

                specification='n';

                if contains(lower(freqcons),'passband edge')
                    specification=[specification,',fp'];
                end

                if contains(lower(freqcons),'6db point')
                    specification=[specification,',fc'];
                end

                if contains(lower(freqcons),'stopband edge')
                    specification=[specification,',fst'];
                end


                if contains(lower(magcons),'passband ripple')
                    specification=[specification,',ap'];
                end

                if contains(lower(magcons),'stopband attenuation')
                    specification=[specification,',ast'];
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
            specs.Factor=evaluatevars(source.Factor);

            if strcmpi(this.FilterType,'sample-rate converter')
                specs.SecondFactor=evaluatevars(source.SecondFactor);
            end

            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');

            specs.NumberOfSections=evaluatevars(this.NumberOfSections);
            specs.DifferentialDelay=evaluatevars(this.DifferentialDelay);
            specs.CICRateChangeFactor=evaluatevars(this.CICRateChangeFactor);

            spec=lower(getSpecification(this,source));

            switch spec
            case 'fp,fst,ap,ast'
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fc,ap,ast'
                specs.Order=evaluatevars(source.Order);
                specs.F6dB=getnum(this,source,'F6dB');
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fp,ap,ast'
                specs.Order=evaluatevars(source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fp,fst'
                specs.Order=evaluatevars(source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Fstop=getnum(this,source,'Fstop');
            case 'n,fst,ap,ast'
                specs.Order=evaluatevars(source.Order);
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case 'n,fst,ast'
                specs.Order=evaluatevars(source.Order);
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Astop=evaluatevars(source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            otherwise
                fprintf('Finish %s',spec);
            end


        end


        function validFreqConstraints=getValidFreqConstraints(this)




            validFreqConstraints=this.FrequencyConstraintsSet;

            if isminorder(this)
                validFreqConstraints=validFreqConstraints(1);
            end


        end


        function availableconstraints=getValidMagConstraints(this,fconstraints)




            if isminorder(this)
                availableconstraints={'Passband ripple and stopband attenuation'};
                return;
            end

            if nargin<2
                fconstraints=this.FrequencyConstraints;
            end

            switch lower(fconstraints)
            case 'passband edge and stopband edge'
                availableconstraints={'Unconstrained'};
            otherwise
                availableconstraints={'Passband ripple and stopband attenuation'};
            end


        end


        function b=setGUI(this,Hd)



            b=true;
            hfdesign=getfdesign(Hd);
            if~strcmpi(get(hfdesign,'Response'),'cic compensator')
                b=false;
                return;
            end

            this.NumberOfSections=num2str(hfdesign.NumberOfSections);
            this.DifferentialDelay=num2str(hfdesign.DifferentialDelay);
            this.CICRateChangeFactor=num2str(hfdesign.CICRateChangeFactor);

            if hfdesign.CICRateChangeFactor>1
                this.SpecifyCICRateChangeFactor=true;
            else
                this.SpecifyCICRateChangeFactor=false;
            end

            switch hfdesign.Specification
            case 'Fp,Fst,Ap,Ast'
                set(this,...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,Fc,Ap,Ast'
                set(this,...
                'FrequencyConstraints','6dB point',...
                'MagnitudeConstraints','Passband ripple and stopband attenuation',...
                'F6dB',num2str(hfdesign.Fcutoff),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,Fp,Ap,Ast'
                set(this,...
                'FrequencyConstraints','Passband edge',...
                'MagnitudeConstraints','Passband ripple and stopband attenuation',...
                'Fpass',num2str(hfdesign.Fpass),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,Fst,Ap,Ast'
                set(this,...
                'FrequencyConstraints','Stopband edge',...
                'MagnitudeConstraints','Passband ripple and stopband attenuation',...
                'Fstop',num2str(hfdesign.Fstop),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,Fp,Fst'
                set(this,...
                'FrequencyConstraints','Passband edge and stopband edge',...
                'MagnitudeConstraints','Unconstrained',...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:CICCompDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function[success,msg]=setupFDesign(this,varargin)



            success=true;
            msg='';

            hd=this.FDesign;

            spec=getSpecification(this,varargin{:});



            hd.Specification=validatestring(spec,hd.getAllowedStringValues('Specification'));

            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end



            try
                specs=getSpecs(this,source);

                if strncmpi(specs.FrequencyUnits,'normalized',10)
                    normalizefreq(hd);
                    normalizedFlag=true;
                else
                    normalizefreq(hd,false,specs.InputSampleRate);
                    normalizedFlag=false;
                end

                M=specs.DifferentialDelay;
                N=specs.NumberOfSections;
                if this.SpecifyCICRateChangeFactor
                    CICRCF=specs.CICRateChangeFactor;
                else
                    CICRCF=1;
                end

                switch spec
                case 'fp,fst,ap,ast'
                    if normalizedFlag
                        setspecs(hd,M,N,specs.Fpass,specs.Fstop,specs.Apass,...
                        specs.Astop,specs.MagnitudeUnits);
                        hd.CICRateChangeFactor=CICRCF;
                    else
                        setspecs(hd,M,N,CICRCF,specs.Fpass,specs.Fstop,specs.Apass,...
                        specs.Astop,specs.InputSampleRate,specs.MagnitudeUnits);
                    end
                case 'n,fc,ap,ast'
                    if normalizedFlag
                        setspecs(hd,M,N,specs.Order,specs.F6dB,specs.Apass,...
                        specs.Astop,specs.MagnitudeUnits);
                        hd.CICRateChangeFactor=CICRCF;
                    else
                        setspecs(hd,M,N,CICRCF,specs.Order,specs.F6dB,specs.Apass,...
                        specs.Astop,specs.InputSampleRate,specs.MagnitudeUnits);
                    end
                case 'n,fp,ap,ast'
                    if normalizedFlag
                        setspecs(hd,M,N,specs.Order,specs.Fpass,specs.Apass,...
                        specs.Astop,specs.MagnitudeUnits);
                        hd.CICRateChangeFactor=CICRCF;
                    else
                        setspecs(hd,M,N,CICRCF,specs.Order,specs.Fpass,specs.Apass,...
                        specs.Astop,specs.InputSampleRate,specs.MagnitudeUnits);
                    end
                case 'n,fp,fst'
                    if normalizedFlag
                        setspecs(hd,M,N,specs.Order,specs.Fpass,specs.Fstop);
                        hd.CICRateChangeFactor=CICRCF;
                    else
                        setspecs(hd,M,N,CICRCF,specs.Order,specs.Fpass,specs.Fstop,...
                        specs.InputSampleRate);
                    end
                case 'n,fst,ap,ast'
                    if normalizedFlag
                        setspecs(hd,M,N,specs.Order,specs.Fstop,specs.Apass,...
                        specs.Astop,specs.MagnitudeUnits);
                        hd.CICRateChangeFactor=CICRCF;
                    else
                        setspecs(hd,M,N,CICRCF,specs.Order,specs.Fstop,specs.Apass,...
                        specs.Astop,specs.InputSampleRate,specs.MagnitudeUnits);
                    end
                case 'n,fst,ast'
                    if normalizedFlag
                        setspecs(hd,M,N,specs.Order,specs.Fstop,specs.Astop,...
                        specs.MagnitudeUnits);
                        hd.CICRateChangeFactor=CICRCF;
                    else
                        setspecs(hd,M,N,CICRCF,specs.Order,specs.Fstop,specs.Astop,...
                        specs.InputSampleRate,specs.MagnitudeUnits);
                    end
                otherwise
                    fprintf('Finish %s',spec);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)



            this.Fpass=s.Fpass;
            this.F6dB=s.F6dB;
            this.Fstop=s.Fstop;
            this.Apass=s.Apass;
            this.Astop=s.Astop;
            this.NumberOfSections=s.NumberOfSections;
            this.DifferentialDelay=s.DifferentialDelay;
            this.FrequencyConstraints=s.FrequencyConstraints;
            this.MagnitudeConstraints=s.MagnitudeConstraints;


            if isfield(s,'SpecifyCICRateChangeFactor')
                this.SpecifyCICRateChangeFactor=s.SpecifyCICRateChangeFactor;
            else
                this.SpecifyCICRateChangeFactor=false;
            end

            if isfield(s,'CICRateChangeFactor')
                this.CICRateChangeFactor=s.CICRateChangeFactor;
            else
                this.CICRateChangeFactor='2';
            end


        end


        function s=thissaveobj(this,s)



            s.Fpass=this.Fpass;
            s.F6dB=this.F6dB;
            s.Fstop=this.Fstop;
            s.Apass=this.Apass;
            s.Astop=this.Astop;
            s.NumberOfSections=this.NumberOfSections;
            s.DifferentialDelay=this.DifferentialDelay;
            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;


            s.CICRateChangeFactor=this.CICRateChangeFactor;
            s.SpecifyCICRateChangeFactor=this.SpecifyCICRateChangeFactor;


        end


        function fc=lcl_get_frequencyconstraints(this,fc)

            if isminorder(this)
                fc='Passband edge and stopband edge';
            end
        end


        function mc=lcl_get_magnitudeconstraints(this,mc)

            if isminorder(this)
                mc='Passband ripple and stopband attenuation';
            end
        end

    end

end

