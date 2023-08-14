classdef(CaseInsensitiveProperties)LowpassDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(AbortSet,SetObservable,GetObservable)

        Fpass='0.45';

        F3dB='0.5';

        F6dB='0.5';

        Fstop='0.55';

        Apass='1';

        Astop='60';

        DenominatorOrder='20';
    end

    properties(Dependent,AbortSet)

        SpecifyDenominator(1,1)logical;





        FrequencyConstraints;




        MagnitudeConstraints;
    end

    properties(AbortSet,SetObservable,GetObservable,Hidden)

        privSpecifyDenominator(1,1)logical=false;





        privFrequencyConstraints='Passband edge and stopband edge';




        privMagnitudeConstraints='Unconstrained';
    end

    properties(Constant,Hidden)

        FrequencyConstraintsSet={'Passband edge and stopband edge','Passband edge',...
        'Passband edge and 3dB point','Stopband edge','6dB point',...
        '3dB point','3dB point and stopband edge'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('FpFst'),...
        FilterDesignDialog.message('Fp'),...
        FilterDesignDialog.message('FpF3dB'),...
        FilterDesignDialog.message('Fst'),...
        FilterDesignDialog.message('Fc'),...
        FilterDesignDialog.message('F3dB'),...
        FilterDesignDialog.message('F3dBFst')};

        MagnitudeConstraintsSet=...
        {'Unconstrained','Passband ripple and stopband attenuation',...
        'Passband ripple','Stopband attenuation'};
        MagnitudeConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('ApAst'),...
        FilterDesignDialog.message('Ap'),...
        FilterDesignDialog.message('Ast')};
    end


    methods
        function this=LowpassDesign(varargin)


            if~isempty(varargin)
                set(this,varargin{:});
            end
            this.VariableName=this.getOutputVarName('lp');

            this.FDesign=fdesign.lowpass;

            this.DesignMethod='Equiripple';
            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);

        end

    end

    methods
        function set.Fpass(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fpass');
            obj.Fpass=value;
        end

        function set.F3dB(obj,value)

            validateattributes(value,{'char'},{'row'},'','F3dB');
            obj.F3dB=value;
        end

        function set.F6dB(obj,value)

            validateattributes(value,{'char'},{'row'},'','F6dB');
            obj.F6dB=value;
        end

        function set.Fstop(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fstop');
            obj.Fstop=value;
        end

        function set.Apass(obj,value)

            validateattributes(value,{'char'},{'row'},'','Apass');
            obj.Apass=value;
        end

        function set.Astop(obj,value)

            validateattributes(value,{'char'},{'row'},'','Astop')
            obj.Astop=value;
        end

        function value=get.SpecifyDenominator(obj)
            value=obj.privSpecifyDenominator;
        end
        function set.SpecifyDenominator(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','SpecifyDenominator');
            obj.privSpecifyDenominator=value;
            set_specifydenominator(obj);
        end

        function set.privSpecifyDenominator(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','privSpecifyDenominator');
            obj.privSpecifyDenominator=value;
        end

        function set.DenominatorOrder(obj,value)

            validateattributes(value,{'char'},{'row'},'','DenominatorOrder');
            obj.DenominatorOrder=value;
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


        function set_magnitudeconstraints(this,~)


            updateMethod(this);

        end


        function dialogTitle=getDialogTitle(this)



            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle='Lowpass Filter';
            else
                if isFilterDesignerMode(this)
                    dialogTitle=FilterDesignDialog.message(['LowpassDesign',this.ImpulseResponse]);
                else
                    dialogTitle=FilterDesignDialog.message('LowpassDesign');
                end
            end


        end


        function fspecs=getFrequencySpecsFrame(this)



            items=getConstraintsWidgets(this,'Frequency',1);


            items=getFrequencyUnitsWidgets(this,2,items);


            hasfpass=contains(lower(this.FrequencyConstraints),'passband edge');
            hasfstop=contains(lower(this.FrequencyConstraints),'stopband edge');
            hasf3db=contains(lower(this.FrequencyConstraints),'3db point');
            hasf6db=contains(lower(this.FrequencyConstraints),'6db point');

            [items,col]=addConstraint(this,3,1,items,hasf3db,...
            'F3dB',FilterDesignDialog.message('freq3dB'),'3dB point');
            [items,col]=addConstraint(this,3,col,items,hasf6db,...
            'F6dB',FilterDesignDialog.message('freq6dB'),'6dB point');
            [items,col]=addConstraint(this,3,col,items,hasfpass,...
            'Fpass',FilterDesignDialog.message('Fpass'),...
            'Passband edge');
            items=addConstraint(this,3,col,items,hasfstop,...
            'Fstop',FilterDesignDialog.message('Fstop'),...
            'Stopband edge');

            fspecs.Name=FilterDesignDialog.message('freqspecs');
            fspecs.Type='group';
            fspecs.Items=items;
            fspecs.LayoutGrid=[4,4];
            fspecs.RowStretch=[0,0,0,1];
            fspecs.ColStretch=[0,1,0,1];
            fspecs.Tag='FreqSpecsGroup';


        end


        function headerFrame=getHeaderFrame(this)


            [irtype_lbl,irtype]=getWidgetSchema(this,'ImpulseResponse',...
            FilterDesignDialog.message('impresp'),'combobox',1,1);
            irtype.Entries={...
            FilterDesignDialog.message('fir'),...
            FilterDesignDialog.message('iir')};
            irtype.DialogRefresh=true;

            if isFilterDesignerMode(this)
                irtype_lbl.Visible=false;
                irtype.Visible=false;
            else
                irtype_lbl.Visible=true;
                irtype.Visible=true;
            end
            irtype.Mode=true;

            orderwidgets=getOrderWidgetsWithNum(this,2,true);


            if~isfir(this)
                dOrderWidgets=getDenOrderWidgets(this,3,3);
            else
                dOrderWidgets={};
            end

            if isDSTMode(this)
                ftypewidgets=getFilterTypeWidgets(this,4);
            end

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');

            if isDSTMode(this)
                headerFrame.Items={irtype_lbl,irtype,orderwidgets{:},...
                dOrderWidgets{:},ftypewidgets{:}};%#ok<*CCAT>
                headerFrame.LayoutGrid=[5,4];
            else
                headerFrame.Items={irtype_lbl,irtype,orderwidgets{:},...
                dOrderWidgets{:}};
                headerFrame.LayoutGrid=[4,4];
            end
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)



            helptext.Type='text';
            if isFilterDesignerMode(this)
                helptext.Name=FilterDesignDialog.message('FilterDesignAssistantHeader');
            else
                helptext.Name=FilterDesignDialog.message('LowpassDesignHelpTxt');
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


            hasapass=contains(lower(this.MagnitudeConstraints),'passband ripple');
            hasastop=contains(lower(this.MagnitudeConstraints),'stopband attenuation');

            addConstraintsFlag=isminorder(this)||isfir(this)||~this.SpecifyDenominator;

            if(hasapass||hasastop)&&addConstraintsFlag

                items=getMagnitudeUnitsWidgets(this,2,items);

                if isFilterDesignerMode(this)
                    items{end}.Enabled=false;
                end

                [items,col]=addConstraint(this,3,1,items,hasapass,...
                'Apass',FilterDesignDialog.message('Apass'),...
                'Passband ripple');
                items=addConstraint(this,3,col,items,hasastop,...
                'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');
            else


                spacer.RowSpan=[2,2];
                spacer.Tag='Spacer2';

                items={items{:},spacer};

                spacer.RowSpan=[3,3];

                items={items{:},spacer};
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

            elseif strcmpi(laState.ImpulseResponse,'iir')&&laState.SpecifyDenominator

                freqcons=laState.FrequencyConstraints;

                specification='nb,na';
                if contains(lower(freqcons),'3db point')
                    specification=[specification,',f3db'];
                else
                    specification=[specification,',fp,fst'];
                end
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

                if contains(lower(freqcons),'3db point')
                    specification=[specification,',f3db'];
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
            specs.Factor=evaluateVariable(this,source.Factor);
            specs.Scale=this.Scale;
            specs.ForceLeadingNumerator=strcmpi(this.ForceLeadingNumerator,'on');

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
            case 'n,f3db'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB=getnum(this,source,'F3dB');
            case 'n,f3db,ap'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB=getnum(this,source,'F3dB');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,f3db,ap,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB=getnum(this,source,'F3dB');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,f3db,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB=getnum(this,source,'F3dB');
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,f3db,fst'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F3dB=getnum(this,source,'F3dB');
                specs.Fstop=getnum(this,source,'Fstop');
            case 'n,fc'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F6dB=getnum(this,source,'F6dB');
            case 'n,fc,ap,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.F6dB=getnum(this,source,'F6dB');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,fp,ap'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,fp,ap,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,fp,f3db'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.F3dB=getnum(this,source,'F3dB');
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
            case 'n,fst,ap,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,fst,ast'
                specs.Order=evaluateVariable(this,source.Order);
                specs.Fstop=getnum(this,source,'Fstop');
                specs.Astop=evaluateVariable(this,source.Astop);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'nb,na,fp,fst'
                specs.Order=evaluateVariable(this,source.Order);
                specs.DenominatorOrder=evaluateVariable(this,source.DenominatorOrder);
                specs.Fpass=getnum(this,source,'Fpass');
                specs.Fstop=getnum(this,source,'Fstop');
            case 'nb,na,f3db'
                specs.Order=evaluateVariable(this,source.Order);
                specs.DenominatorOrder=evaluateVariable(this,source.DenominatorOrder);
                specs.F3dB=getnum(this,source,'F3dB');
            otherwise
                fprintf('Finish %s',specs);
            end


        end


        function validFreqConstraints=getValidFreqConstraints(this)



            validFreqConstraints=this.FrequencyConstraintsSet;

            if strcmpi(this.ImpulseResponse,'fir')
                if isDSTMode(this)
                    validFreqConstraints=validFreqConstraints([1,2,4,5,6]);
                else
                    validFreqConstraints=validFreqConstraints([1,5,6]);
                end
            else
                if isDSTMode(this)
                    if this.SpecifyDenominator&&~isminorder(this)
                        validFreqConstraints=validFreqConstraints([1,6]);
                    else
                        validFreqConstraints=validFreqConstraints([1:4,6:7]);
                    end
                else
                    if this.SpecifyDenominator&&~isminorder(this)
                        validFreqConstraints=validFreqConstraints(6);
                    else
                        validFreqConstraints=validFreqConstraints([2,4,6]);
                    end
                end
            end



        end


        function availableconstraints=getValidMagConstraints(this,fconstraints)



            if isminorder(this)
                availableconstraints={'Passband ripple and stopband attenuation'};
                return;
            end

            if~isfir(this)&&this.SpecifyDenominator
                availableconstraints={'Unconstrained'};
                return;
            end

            if nargin<2
                fconstraints=this.FrequencyConstraints;
            end

            switch lower(fconstraints)
            case 'passband edge and stopband edge'
                if isfir(this)
                    if isDSTMode(this)
                        availableconstraints={'Passband ripple',...
                        'Stopband attenuation','Unconstrained'};
                    else
                        availableconstraints={'Unconstrained'};
                    end
                else
                    if isDSTMode(this)
                        availableconstraints={'Passband ripple',...
                        'Unconstrained'};
                    else
                        availableconstraints={'Unconstrained'};
                    end
                end
            case 'passband edge'
                if isfir(this)
                    availableconstraints={'Passband ripple and stopband attenuation'};
                else
                    availableconstraints={'Passband ripple',...
                    'Passband ripple and stopband attenuation'};
                end
            case 'stopband edge'
                if isfir(this)
                    availableconstraints={'Passband ripple and stopband attenuation'};
                else
                    availableconstraints={'Stopband attenuation'};
                end
            case '6db point'
                availableconstraints={'Passband ripple and stopband attenuation','Unconstrained'};
            case '3db point'
                if isfir(this)
                    availableconstraints={'Unconstrained'};
                else
                    if isDSTMode(this)
                        availableconstraints={'Passband ripple','Stopband attenuation',...
                        'Passband ripple and stopband attenuation','Unconstrained'};
                    else
                        availableconstraints={'Unconstrained'};
                    end
                end
            case '3db point and stopband edge'
                availableconstraints={'Unconstrained'};
            case 'passband edge and 3db point'
                availableconstraints={'Unconstrained'};
            end


        end


        function b=setGUI(this,Hd)



            b=true;
            hfdesign=getfdesign(Hd);
            if~strcmpi(get(hfdesign,'Response'),'lowpass')
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
            case 'N,F3dB'
                set(this,...
                'privFrequencyConstraints','3dB point',...
                'privMagnitudeConstraints','unconstrained',...
                'F3dB',num2str(hfdesign.F3dB));
            case 'N,F3dB,Ap'
                set(this,...
                'privFrequencyConstraints','3dB point',...
                'privMagnitudeConstraints','Passband ripple',...
                'F3dB',num2str(hfdesign.F3dB),...
                'Apass',num2str(hfdesign.Apass));
            case 'N,F3dB,Ap,Ast'
                set(this,...
                'privFrequencyConstraints','3dB point',...
                'privMagnitudeConstraints','Passband ripple and stopband attenuation',...
                'F3dB',num2str(hfdesign.F3dB),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,F3dB,Ast'
                set(this,...
                'privFrequencyConstraints','3dB point',...
                'privMagnitudeConstraints','Stopband attenuation',...
                'F3dB',num2str(hfdesign.F3dB),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,F3dB,Fst'
                set(this,...
                'privFrequencyConstraints','3dB point and stopband edge',...
                'privMagnitudeConstraints','unconstrained',...
                'F3dB',num2str(hfdesign.F3dB),...
                'Fstop',num2str(hfdesign.Fstop));
            case 'N,Fc'
                set(this,...
                'privFrequencyConstraints','6dB point',...
                'privMagnitudeConstraints','unconstrained',...
                'F6dB',num2str(hfdesign.Fcutoff));
            case 'N,Fc,Ap,Ast'
                set(this,...
                'privFrequencyConstraints','6dB point',...
                'privMagnitudeConstraints','Passband ripple and stopband attenuation',...
                'F6dB',num2str(hfdesign.Fcutoff),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,Fp,Ap'
                set(this,...
                'privFrequencyConstraints','Passband edge',...
                'privMagnitudeConstraints','Passband ripple',...
                'Fpass',num2str(hfdesign.Fpass),...
                'Apass',num2str(hfdesign.Apass));
            case 'N,Fp,Ap,Ast'
                set(this,...
                'privFrequencyConstraints','Passband edge',...
                'privMagnitudeConstraints','Passband ripple and stopband attenuation',...
                'Fpass',num2str(hfdesign.Fpass),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,Fp,F3dB'
                set(this,...
                'privFrequencyConstraints','Passband edge and 3dB point',...
                'privMagnitudeConstraints','unconstrained',...
                'Fpass',num2str(hfdesign.Fpass),...
                'F3dB',num2str(hfdesign.F3dB));
            case 'N,Fp,Fst'
                set(this,...
                'privFrequencyConstraints','Passband edge and stopband edge',...
                'privMagnitudeConstraints','unconstrained',...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop));
            case 'N,Fp,Fst,Ap'
                set(this,...
                'privFrequencyConstraints','Passband edge and stopband edge',...
                'privMagnitudeConstraints','Passband ripple',...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop),...
                'Apass',num2str(hfdesign.Apass));
            case 'N,Fp,Fst,Ast'
                set(this,...
                'privFrequencyConstraints','Passband edge and stopband edge',...
                'privMagnitudeConstraints','Stopband attenuation',...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,Fst,Ap,Ast'
                set(this,...
                'privFrequencyConstraints','Stopband edge',...
                'privMagnitudeConstraints','Passband ripple and stopband attenuation',...
                'Fstop',num2str(hfdesign.Fstop),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,Fst,Ast'
                set(this,...
                'privFrequencyConstraints','Stopband edge',...
                'privMagnitudeConstraints','Stopband attenuation',...
                'Fstop',num2str(hfdesign.Fstop),...
                'Astop',num2str(hfdesign.Astop));
            case 'Nb,Na,Fp,Fst'
                set(this,...
                'privFrequencyConstraints','Passband edge and stopband edge',...
                'privMagnitudeConstraints','unconstrained',...
                'Fpass',num2str(hfdesign.Fpass),...
                'Fstop',num2str(hfdesign.Fstop));
            case 'Nb,Na,F3dB'
                set(this,...
                'privFrequencyConstraints','3dB point',...
                'privMagnitudeConstraints','unconstrained',...
                'F3dB',num2str(hfdesign.F3dB));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:LowpassDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function set_ordermode(this,~)



            updateFreqConstraints(this);


        end


        function[success,msg]=setupFDesign(this,varargin)



            success=true;
            msg='';

            hd=this.FDesign;

            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            spec=getSpecification(this,source);



            setSpecsSafely(this,hd,spec);



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
                case 'n,f3db'
                    setspecs(hd,specs.Order,specs.F3dB);
                case 'n,f3db,ap'
                    setspecs(hd,specs.Order,specs.F3dB,specs.Apass,specs.MagnitudeUnits);
                case 'n,f3db,ap,ast'
                    setspecs(hd,specs.Order,specs.F3dB,specs.Apass,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,f3db,ast'
                    setspecs(hd,specs.Order,specs.F3dB,specs.Astop,specs.MagnitudeUnits);
                case 'n,f3db,fst'
                    setspecs(hd,specs.Order,specs.F3dB,specs.Fstop);
                case 'n,fc'
                    setspecs(hd,specs.Order,specs.F6dB);
                case 'n,fc,ap,ast'
                    setspecs(hd,specs.Order,specs.F6dB,specs.Apass,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,fp,ap'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Apass,specs.MagnitudeUnits);
                case 'n,fp,ap,ast'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Apass,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,fp,f3db'
                    setspecs(hd,specs.Order,specs.Fpass,specs.F3dB);
                case 'n,fp,fst'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Fstop);
                case 'n,fp,fst,ap'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Fstop,...
                    specs.Apass,specs.MagnitudeUnits);
                case 'n,fp,fst,ast'
                    setspecs(hd,specs.Order,specs.Fpass,specs.Fstop,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,fst,ap,ast'
                    setspecs(hd,specs.Order,specs.Fstop,specs.Apass,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,fst,ast'
                    setspecs(hd,specs.Order,specs.Fstop,specs.Astop,specs.MagnitudeUnits);
                case 'nb,na,fp,fst'
                    setspecs(hd,specs.Order,specs.DenominatorOrder,specs.Fpass,specs.Fstop);
                case 'nb,na,f3db'
                    setspecs(hd,specs.Order,specs.DenominatorOrder,specs.F3dB);
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
            this.F3dB=s.F3dB;
            this.F6dB=s.F6dB;
            this.Fstop=s.Fstop;
            this.Apass=s.Apass;
            this.Astop=s.Astop;
            this.FrequencyConstraints=s.FrequencyConstraints;
            this.MagnitudeConstraints=s.MagnitudeConstraints;


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

            s.Fpass=this.Fpass;
            s.F3dB=this.F3dB;
            s.F6dB=this.F6dB;
            s.Fstop=this.Fstop;
            s.Apass=this.Apass;
            s.Astop=this.Astop;
            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;


            s.SpecifyDenominator=this.SpecifyDenominator;
            s.DenominatorOrder=this.DenominatorOrder;


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

