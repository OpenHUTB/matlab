classdef(CaseInsensitiveProperties)DifferentiatorDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(AbortSet,SetObservable,GetObservable)

        Fpass='0.45';

        Fstop='0.55';

        Apass='1';

        Astop='60';
    end

    properties(AbortSet,SetObservable,GetObservable,Dependent)



        FrequencyConstraints;




        MagnitudeConstraints;
    end

    properties(AbortSet,SetObservable,GetObservable,Hidden)



        privFrequencyConstraints='Passband edge and stopband edge';




        privMagnitudeConstraints='Unconstrained';
    end

    properties(Constant,Hidden)

        FrequencyConstraintsSet={'Unconstrained','Passband edge and stopband edge'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('FpFst')};

        MagnitudeConstraintsSet=...
        {'Unconstrained','Passband ripple and stopband attenuation',...
        'Passband ripple','Stopband attenuation'};
        MagnitudeConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('ApAst'),...
        FilterDesignDialog.message('Ap'),...
        FilterDesignDialog.message('Ast')};
    end


    methods
        function this=DifferentiatorDesign(varargin)

            if~isempty(varargin)
                set(this,varargin{:});
            end
            this.VariableName=this.getOutputVarName('df');
            this.Order='31';

            if~isDSTMode(this)


                this.OrderMode='Specify';


                this.privFrequencyConstraints='Unconstrained';
            end

            this.FDesign=fdesign.differentiator;
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

        function set_specifydenominator(this,~)
            if~isDSTMode(this)

                this.FrequencyConstraints='3dB point';
            end
            updateMethod(this);
        end


        function set_frequencyconstraints(this)


            updateMagConstraints(this);

        end


        function dialogTitle=getDialogTitle(this)


            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('DifferentiatorFilter');
            else
                if isFilterDesignerMode(this)
                    dialogTitle=FilterDesignDialog.message(['DifferentiatorDesign',this.ImpulseResponse]);
                else
                    dialogTitle=FilterDesignDialog.message('DifferentiatorDesign');
                end
            end
        end


        function fspecs=getFrequencySpecsFrame(this)





            items=getConstraintsWidgets(this,'Frequency',1);



            items{1}.Tunable=false;
            items{2}.Tunable=false;


            items=getFrequencyUnitsWidgets(this,2,items);


            if~strcmpi(this.FrequencyConstraints,'unconstrained')
                [items,col]=addConstraint(this,3,1,items,true,...
                'Fpass',FilterDesignDialog.message('Fpass'),'Passband edge');
                items=addConstraint(this,3,col,items,true,...
                'Fstop',FilterDesignDialog.message('Fstop'),'Stopband edge');
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



            if isDSTMode(this)
                orderwidgets=getOrderWidgets(this,1,true);
                ftypewidgets=getFilterTypeWidgets(this,2);
            else
                orderwidgets=getOrderWidgets(this,1,false);
            end

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');
            if isDSTMode(this)
                headerFrame.Items={orderwidgets{:},ftypewidgets{:}};%#ok<CCAT>
                headerFrame.LayoutGrid=[2,4];
            else
                headerFrame.Items={orderwidgets{:}};%#ok<CCAT1>
                headerFrame.LayoutGrid=[1,4];
            end
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)



            helptext.Type='text';
            if isFilterDesignerMode(this)
                helptext.Name=FilterDesignDialog.message('FilterDesignAssistantHeader');
            else
                helptext.Name=FilterDesignDialog.message('DifferentiatorDesignHelpTxt');
            end
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function mspecs=getMagnitudeSpecsFrame(this)



            items=getConstraintsWidgets(this,'Magnitude',1);

            if isminorder(this)
                items=getMagnitudeUnitsWidgets(this,2,items);

                [items,col]=addConstraint(this,3,1,items,true,...
                'Apass',FilterDesignDialog.message('Apass'),'Passband ripple');
                items=addConstraint(this,3,col,items,true,...
                'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');
            elseif isDSTMode(this)

                hasapass=...
                contains(lower(this.MagnitudeConstraints),'passband ripple');
                hasastop=...
                contains(lower(this.MagnitudeConstraints),'stopband attenuation');

                if hasapass||hasastop
                    items=getMagnitudeUnitsWidgets(this,2,items);

                    [items,col]=addConstraint(this,3,1,items,hasapass,...
                    'Apass',FilterDesignDialog.message('Apass'),...
                    'Passband ripple');
                    items=addConstraint(this,3,col,items,hasastop,...
                    'Astop',FilterDesignDialog.message('Astop'),...
                    'Stopband attenuation');
                end
            else
                help=FilterDesignDialog.message('NoMagConstHelpTxt');
                helptext.Type='text';
                helptext.WordWrap=true;
                helptext.Name=help;
                helptext.RowSpan=[1,1];
                helptext.ColSpan=[1,4];

                items={helptext};
            end

            mspecs.Name=FilterDesignDialog.message('magspecs');
            mspecs.Type='group';
            mspecs.Items=items;
            mspecs.LayoutGrid=[4,4];
            mspecs.RowStretch=[0,0,0,1];
            mspecs.ColStretch=[0,1,0,1];
            mspecs.Tag='MagSpecsGroup';

            if isFilterDesignerMode(this)
                mspecs.Visible=false;
            end


        end


        function specification=getSpecification(this,laState)



            if nargin<2
                laState=this;
            end

            if isminorder(this,laState)
                specification='fp,fst,ap,ast';
            else

                freqcons=laState.FrequencyConstraints;

                specification='n';

                if contains(lower(freqcons),'passband edge')
                    specification=[specification,',fp'];
                end

                if contains(lower(freqcons),'stopband edge')
                    specification=[specification,',fst'];
                end

                magcons=laState.MagnitudeConstraints;

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
            specs.Factor=evaluateVariable(this,source.Factor);

            if strcmpi(this.FilterType,'sample-rate converter')
                specs.SecondFactor=evaluateVariable(this,source.SecondFactor);
            end

            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');

            switch lower(getSpecification(this,source))
            case 'fp,fst,ap,ast'
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'ap'
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,fp,fst'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Fstop=getnum(this,source,'Fstop');
            case 'n,fp,fst,ap'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,fp,fst,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n'
                specs.Order=evaluateVariable(this,source.Order);
            otherwise
                fprintf('Finish %s',specs);
            end


        end


        function validFreqConstraints=getValidFreqConstraints(this)




            validFreqConstraints=this.FrequencyConstraintsSet;


        end


        function availableconstraints=getValidMagConstraints(this,~)



            if isminorder(this)
                availableconstraints={'Passband ripple and stopband attenuation'};
            else
                availableconstraints={'Unconstrained'};
                if isDSTMode(this)&&...
                    strcmpi(this.FrequencyConstraints,'passband edge and stopband edge')
                    availableconstraints=...
                    [availableconstraints,{'Passband ripple','Stopband attenuation'}];
                end
            end


        end


        function b=setGUI(this,Hd)



            b=true;
            hfdesign=getfdesign(Hd);
            if~strcmpi(get(hfdesign,'Response'),'differentiator')
                b=false;
                return;
            end
            switch hfdesign.Specification
            case 'Fp,Fst,Ap,Ast'
                set(this,...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N'
                set(this,...
                'FrequencyConstraints','unconstrained',...
                'MagnitudeConstraints','unconstrained',...
                'Order',num2str(hfdesign.FilterOrder));
            case 'Ap'

            case 'N,Fp,Fst'
                set(this,...
                'FrequencyConstraints','Passband edge and stopband edge',...
                'MagnitudeConstraints','unconstrained',...
                'Order',num2str(hfdesign.FilterOrder),...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop));
            case 'N,Fp,Fst,Ap'
                set(this,...
                'FrequencyConstraints','Passband edge and stopband edge',...
                'MagnitudeConstraints','Passband ripple',...
                'Order',num2str(hfdesign.FilterOrder),...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop),...
                'Apass',num2str(hfdesign.Apass));
            case 'N,Fp,Fst,Ast'
                set(this,...
                'FrequencyConstraints','Passband edge and stopband edge',...
                'MagnitudeConstraints','Stopband attenuation',...
                'Order',num2str(hfdesign.FilterOrder),...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop),...
                'Astop',num2str(hfdesign.Astop));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:DifferentiatorDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function[success,msg]=setupFDesign(this,varargin)



            success=true;
            msg=false;

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

                if strncmpi(source.FrequencyUnits,'normalized',10)
                    normalizefreq(hd);
                else
                    normalizefreq(hd,false,specs.InputSampleRate);
                end

                switch spec
                case 'fp,fst,ap,ast'
                    setspecs(hd,specs.Fpass,specs.Fstop,specs.Apass,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n'
                    setspecs(hd,specs.Order);
                case 'n,fp,fst'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Fstop);
                case 'n,fp,fst,ap'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Fstop,...
                    specs.Apass,specs.MagnitudeUnits);
                case 'n,fp,fst,ast'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Fstop,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'ap'
                    setspecs(hd,specs.Apass,specs.MagnitudeUnits);
                otherwise
                    fprintf('Finish %s',spec);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)




            set(this,...
            'Fpass',s.Fpass,...
            'Fstop',s.Fstop,...
            'Apass',s.Apass,...
            'Astop',s.Astop,...
            'FrequencyConstraints',s.FrequencyConstraints,...
            'MagnitudeConstraints',s.MagnitudeConstraints);


        end


        function s=thissaveobj(this,s)




            s.Fpass=this.Fpass;
            s.Fstop=this.Fstop;
            s.Apass=this.Apass;
            s.Astop=this.Astop;
            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;


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

