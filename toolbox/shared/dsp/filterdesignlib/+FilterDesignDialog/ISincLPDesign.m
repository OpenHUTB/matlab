classdef(CaseInsensitiveProperties)ISincLPDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(AbortSet,SetObservable,GetObservable)

        Fpass='0.45';

        F6dB='0.5';

        Fstop='0.55';

        Apass='1';

        Astop='60';
    end

    properties(AbortSet,SetObservable,GetObservable,Dependent)

        Type;




        FrequencyConstraints;




        MagnitudeConstraints;
    end

    properties(Hidden,AbortSet,SetObservable,GetObservable)

        privType='Lowpass';




        privFrequencyConstraints='Passband edge and stopband edge';




        privMagnitudeConstraints='Unconstrained';
    end

    properties(Constant,Hidden)

        FrequencyConstraintsSet=...
        {'Passband edge and stopband edge','Stopband edge and passband edge',...
        'Passband edge','Stopband edge','6dB point'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('FpFst'),...
        FilterDesignDialog.message('FstFp'),...
        FilterDesignDialog.message('Fp'),...
        FilterDesignDialog.message('Fst'),...
        FilterDesignDialog.message('Fc')};

        MagnitudeConstraintsSet=...
        {'Unconstrained','Passband ripple and stopband attenuation',...
        'Stopband attenuation and passband ripple'};
        MagnitudeConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('ApAst'),...
        FilterDesignDialog.message('AstAp')};
    end

    methods
        function this=ISincLPDesign(varargin)






            this.VariableName=uiservices.getVariableName('Hisinc');
            if~isempty(varargin)
                set(this,varargin{:});
            end

            if isLowpass(this)
                this.FDesign=fdesign.isinclp;
            else
                this.FDesign=fdesign.isinchp('Fst,Fp,Ast,Ap',.45,.55,60,1);
                this.Fstop='0.45';
                this.Fpass='0.55';
            end
            updateMethod(this);


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

        function value=get.Type(obj)
            value=obj.privType;

        end
        function set.Type(obj,value)

            validateattributes(value,{'char'},{'row'},'','Type')
            obj.privType=value;
            set_type(obj);
        end
        function set.privType(obj,value)

            validateattributes(value,{'char'},{'row'},'','privType')
            obj.privType=value;
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


        function dialogTitle=getDialogTitle(this)



            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('ISincFilter');
            else
                dialogTitle=FilterDesignDialog.message('ISincDesign');
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

            if isLowpass(this)
                [items,col]=addConstraint(this,3,col,items,hasfpass,...
                'Fpass',FilterDesignDialog.message('Fpass'),'Passband edge');

                items=addConstraint(this,3,col,items,hasfstop,...
                'Fstop',FilterDesignDialog.message('Fstop'),'Stopband edge');
            else
                [items,col]=addConstraint(this,3,col,items,hasfstop,...
                'Fstop',FilterDesignDialog.message('Fstop'),'Stopband edge');

                items=addConstraint(this,3,col,items,hasfpass,...
                'Fpass',FilterDesignDialog.message('Fpass'),'Passband edge');
            end

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


            [type_lbl,type]=getWidgetSchema(this,'Type',FilterDesignDialog.message('ResponseType'),...
            'combobox',2,1);
            type.Entries=FilterDesignDialog.message({'lp','hp'});
            type.DialogRefresh=true;

            options={'Lowpass','Highpass'};
            type.ObjectMethod='selectComboboxEntryType';
            type.MethodArgs={'%dialog','%value','Type',options};
            type.ArgDataTypes={'handle','mxArray','string','mxArray'};



            type.Mode=false;



            type=rmfield(type,'ObjectProperty');


            indx=find(strcmp(options,this.Type));
            if~isempty(indx)
                type.Value=indx-1;
            end


            ftypewidgets=getFilterTypeWidgets(this,3);

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');
            headerFrame.Items={orderwidgets{:},type_lbl,type,ftypewidgets{:}};%#ok<CCAT>
            headerFrame.LayoutGrid=[4,4];
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)



            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('ISincDesignHelpTxt');
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

            if strcmpi(this.MagnitudeConstraints,'unconstrained')


                spacer.RowSpan=[2,2];
                spacer.Tag='Spacer2';

                items={items{:},spacer};%#ok<CCAT>

                spacer.RowSpan=[3,3];

                items={items{:},spacer};%#ok<CCAT>

            else
                items=getMagnitudeUnitsWidgets(this,2,items);

                if isLowpass(this)
                    [items,col]=addConstraint(this,3,1,items,true,...
                    'Apass',FilterDesignDialog.message('Apass'),'Passband ripple');

                    items=addConstraint(this,3,col,items,true,...
                    'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');
                else
                    [items,col]=addConstraint(this,3,1,items,true,...
                    'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');

                    items=addConstraint(this,3,col,items,true,...
                    'Apass',FilterDesignDialog.message('Apass'),'Passband ripple');
                end
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
                if isLowpass(this)
                    specification='fp,fst,ap,ast';
                else
                    specification='fst,fp,ast,ap';
                end
            else

                freqcons=laState.FrequencyConstraints;
                magcons=laState.MagnitudeConstraints;

                specification='n';

                if contains(lower(freqcons),'6db point')
                    specification=[specification,',fc'];
                end

                if isLowpass(this)
                    if contains(lower(freqcons),'passband edge')
                        specification=[specification,',fp'];
                    end

                    if contains(lower(freqcons),'stopband edge')
                        specification=[specification,',fst'];
                    end
                else
                    if contains(lower(freqcons),'stopband edge')
                        specification=[specification,',fst'];
                    end

                    if contains(lower(freqcons),'passband edge')
                        specification=[specification,',fp'];
                    end
                end


                if isLowpass(this)
                    if contains(lower(magcons),'passband ripple')
                        specification=[specification,',ap'];
                    end

                    if contains(lower(magcons),'stopband attenuation')
                        specification=[specification,',ast'];
                    end
                else
                    if contains(lower(magcons),'stopband attenuation')
                        specification=[specification,',ast'];
                    end

                    if contains(lower(magcons),'passband ripple')
                        specification=[specification,',ap'];
                    end
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

            spec=lower(getSpecification(this,source));

            switch spec
            case{'fp,fst,ap,ast','fst,fp,ast,ap'}
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case{'n,fc,ap,ast','n,fc,ast,ap'}
                specs.Order=evaluatevars(source.Order);
                specs.F6dB=getnum(this,source,'F6dB');
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case{'n,fp,ap,ast','n,fp,ast,ap'}
                specs.Order=evaluatevars(source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            case{'n,fp,fst','n,fst,fp'}
                specs.Order=evaluatevars(source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Fstop=getnum(this,source,'Fstop');
            case{'n,fst,ap,ast','n,fst,ast,ap'}
                specs.Order=evaluatevars(source.Order);
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
                specs.MagnitudeUnits=this.MagnitudeUnits;
            otherwise
                fprintf('Finish %s',spec);
            end


        end


        function validFreqConstraints=getValidFreqConstraints(this)



            validFreqConstraints=this.FrequencyConstraintsSet;

            if isminorder(this)
                if isLowpass(this)
                    validFreqConstraints=validFreqConstraints(1);
                else
                    validFreqConstraints=validFreqConstraints(2);
                end
                return
            end

            if isLowpass(this)
                validFreqConstraints=validFreqConstraints([1,3:5]);
            else
                validFreqConstraints=validFreqConstraints(2:5);
            end

        end


        function availableconstraints=getValidMagConstraints(this,fconstraints)



            if isminorder(this)
                if isLowpass(this)
                    availableconstraints={'Passband ripple and stopband attenuation'};
                else
                    availableconstraints={'Stopband attenuation and passband ripple'};
                end
                return;
            end

            if nargin<2
                fconstraints=this.FrequencyConstraints;
            end

            switch lower(fconstraints)
            case{'passband edge and stopband edge','stopband edge and passband edge'}
                availableconstraints={'Unconstrained'};
            otherwise
                if isLowpass(this)
                    availableconstraints={'Passband ripple and stopband attenuation'};
                else
                    availableconstraints={'Stopband attenuation and passband ripple'};
                end
            end


        end


        function selectComboboxEntryType(this,hdlg,indx,prop,options)



            set(this,prop,options{indx+1});



            if isLowpass(this)
                if evaluatevars(this.Fpass)>evaluatevars(this.Fstop)
                    fpass=this.Fpass;
                    this.Fpass=this.Fstop;
                    this.Fstop=fpass;
                end
            else
                if evaluatevars(this.Fpass)<evaluatevars(this.Fstop)
                    fpass=this.Fpass;
                    this.Fpass=this.Fstop;
                    this.Fstop=fpass;
                end
            end



            restoreFromSchema(hdlg);



        end


        function b=setGUI(this,Hd)



            b=true;
            hfdesign=getfdesign(Hd);
            if~strncmpi(get(hfdesign,'Response'),'inverse-sinc',12)
                b=false;
                return;
            end

            if strcmpi(get(hfdesign,'Response'),'inverse-sinc lowpass')
                lowpassFlag=true;
                magConstraints='Passband ripple and stopband attenuation';
                freqConstraints='Passband edge and stopband edge';
            else
                lowpassFlag=false;
                magConstraints='Stopband attenuation and passband ripple';
                freqConstraints='Stopband edge and passband edge';
            end

            switch hfdesign.Specification
            case{'Fp,Fst,Ap,Ast','Fst,Fp,Ast,Ap'}
                set(this,...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case{'N,Fc,Ap,Ast','N,Fc,Ast,Ap'}
                set(this,...
                'privFrequencyConstraints','6dB point',...
                'privMagnitudeConstraints',magConstraints,...
                'F6dB',num2str(hfdesign.Fcutoff),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case{'N,Fp,Ap,Ast','N,Fp,Ast,Ap'}
                set(this,...
                'privFrequencyConstraints','Passband edge',...
                'privMagnitudeConstraints',magConstraints,...
                'Fpass',num2str(hfdesign.Fpass),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case{'N,Fst,Ap,Ast','N,Fst,Ast,Ap'}
                set(this,...
                'privFrequencyConstraints','Stopband edge',...
                'privMagnitudeConstraints',magConstraints,...
                'Fstop',num2str(hfdesign.Fstop),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case{'N,Fp,Fst','N,Fst,Fp'}
                set(this,...
                'privFrequencyConstraints',freqConstraints,...
                'privMagnitudeConstraints','Unconstrained',...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:ISincLPDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end




            if lowpassFlag
                fmOld=getfmethod(Hd);
                if~contains(class(fmOld),'wparams')

                    dOpts=thisdesignopts(fmOld,get(fmOld));
                    dOpts=rmfield(dOpts,'DesignAlgorithm');
                    if isfield(dOpts,'SystemObject')
                        dOpts=rmfield(dOpts,'SystemObject');
                    end


                    fmNew=feval([class(fmOld),'wparams']);
                    set(fmNew,dOpts);

                    if isa(Hd,'dsp.internal.FilterAnalysis')
                        setMetaData(Hd,hfdesign,fmNew)
                    else
                        setfmethod(Hd,fmNew)
                    end
                end
            end

            abstract_setGUI(this,Hd);


        end


        function set_type(this,~)



            if strcmpi(this.Type,'highpass')
                set(this,'FDesign',fdesign.isinchp);
                this.FilterType='single-rate';
                if isminorder(this)
                    this.FrequencyConstraints='Stopband edge and passband edge';
                    this.MagnitudeConstraints='Stopband attenuation and passband ripple';
                elseif any(strcmpi(this.FrequencyConstraints,{'passband edge and stopband edge','stopband edge and passband edge'}))
                    this.FrequencyConstraints='Stopband edge and passband edge';
                else
                    this.MagnitudeConstraints='Stopband attenuation and passband ripple';
                end
            else
                set(this,'FDesign',fdesign.isinclp);
                if isminorder(this)
                    this.FrequencyConstraints='Passband edge and stopband edge';
                    this.MagnitudeConstraints='Passband ripple and stopband attenuation';
                elseif any(strcmpi(this.FrequencyConstraints,{'passband edge and stopband edge','stopband edge and passband edge'}))
                    this.FrequencyConstraints='Passband edge and stopband edge';
                else
                    this.MagnitudeConstraints='Passband ripple and stopband attenuation';
                end
            end

        end


        function[success,msg]=setupFDesign(this,varargin)



            success=true;
            msg='';

            hd=get(this,'FDesign');

            spec=getSpecification(this,varargin{:});



            set(hd,'Specification',...
            validatestring(spec,hd.getAllowedStringValues('Specification')));

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
                case 'fp,fst,ap,ast'
                    setspecs(hd,specs.Fpass,specs.Fstop,specs.Apass,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,fc,ap,ast'
                    setspecs(hd,specs.Order,specs.F6dB,specs.Apass,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,fp,ap,ast'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Apass,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,fp,fst'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Fstop);
                case 'n,fst,ap,ast'
                    setspecs(hd,specs.Order,specs.Fstop,specs.Apass,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,fst,ast'
                    setspecs(hd,specs.Order,specs.Fstop,specs.Astop,specs.MagnitudeUnits);
                case 'fst,fp,ast,ap'
                    setspecs(hd,specs.Fstop,specs.Fpass,specs.Astop,...
                    specs.Apass,specs.MagnitudeUnits);
                case 'n,fc,ast,ap'
                    setspecs(hd,specs.Order,specs.F6dB,specs.Astop,...
                    specs.Apass,specs.MagnitudeUnits);
                case 'n,fp,ast,ap'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Astop,...
                    specs.Apass,specs.MagnitudeUnits);
                case 'n,fst,fp'
                    setspecs(hd,specs.Order,specs.Fstop,specs.Fpass);
                case 'n,fst,ast,ap'
                    setspecs(hd,specs.Order,specs.Fstop,specs.Astop,...
                    specs.Apass,specs.MagnitudeUnits);
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
            this.FrequencyConstraints=s.FrequencyConstraints;
            this.MagnitudeConstraints=s.MagnitudeConstraints;


            if isfield(s,'Type')
                this.Type=s.Type;
            else
                this.Type='Lowpass';
            end


        end


        function s=thissaveobj(this,s)



            s.Fpass=this.Fpass;
            s.F6dB=this.F6dB;
            s.Fstop=this.Fstop;
            s.Apass=this.Apass;
            s.Astop=this.Astop;
            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;


            s.Type=this.Type;


        end

        function fc=lcl_get_frequencyconstraints(this,fc)

            if isminorder(this)
                if isLowpass(this)
                    fc='Passband edge and stopband edge';
                else
                    fc='Stopband edge and passband edge';
                end
            end
        end



        function mc=lcl_get_magnitudeconstraints(this,mc)

            if isminorder(this)
                if isLowpass(this)
                    mc='Passband ripple and stopband attenuation';
                else
                    mc='Stopband attenuation and passband ripple';
                end
            end
        end


    end


    methods(Hidden)

        function flag=isLowpass(this)



            flag=strcmpi(this.Type,'lowpass');

        end

    end

end



