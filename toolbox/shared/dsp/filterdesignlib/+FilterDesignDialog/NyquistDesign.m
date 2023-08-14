classdef(CaseInsensitiveProperties)NyquistDesign<FilterDesignDialog.AbstractNyquistDesign




    properties(AbortSet,SetObservable,GetObservable)

        Band='2';
    end

    methods
        function this=NyquistDesign(varargin)





            this.VariableName=uiservices.getVariableName('Hnyq');
            if~isempty(varargin)
                set(this,varargin{:});
            end
            this.Band='2';
            this.FDesign=fdesign.nyquist;
            this.DesignMethod='Kaiser window';



            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);


        end

    end

    methods
        function value=get.Band(obj)
            value=obj.Band;
        end
        function set.Band(obj,value)

            validateattributes(value,{'char'},{'row'},'','Band')
            oldValue=obj.Band;
            obj.Band=value;
            set_band(obj,oldValue);
        end

    end

    methods

        function dialogTitle=getDialogTitle(this)




            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('NyquistFilter');
            else
                dialogTitle=FilterDesignDialog.message('NyquistDesign');
            end

        end


        function headerFrame=getHeaderFrame(this)




            [band_lbl,band]=getWidgetSchema(this,'Band',FilterDesignDialog.message('Band'),'edit',1,1);

            band.DialogRefresh=true;

            [irtype_lbl,irtype]=getWidgetSchema(this,'ImpulseResponse',...
            FilterDesignDialog.message('impresp'),'combobox',2,1);

            try
                bandvalue=evaluatevars(this.Band);
            catch %#ok<CTCH>




                bandvalue=3;
            end

            irtype.Entries=FilterDesignDialog.message({'fir','iir'});
            irtype.DialogRefresh=true;

            if bandvalue==2
                irtype.Enabled=true;
            else
                irtype.Enabled=false;
            end

            [ordermode_lbl,ordermode]=getWidgetSchema(this,'OrderMode',...
            FilterDesignDialog.message('FiltOrderMode'),'combobox',3,1);

            ordermode.DialogRefresh=true;
            ordermode.Entries=FilterDesignDialog.message({'Minimum','Specify'});

            [order_lbl,order]=getWidgetSchema(this,'Order',FilterDesignDialog.message('order'),'edit',3,3);

            if isminorder(this)
                order_lbl.Visible=false;
                order.Visible=false;
            end

            ftype_widgets=getFilterTypeWidgets(this,4);
            if(strcmpi(this.FilterType,'decimator')||...
                strcmpi(this.FilterType,'interpolator'))&&...
                strcmpi(this.ImpulseResponse,'iir')
                this.Factor='2';
                ftype_widgets{4}.Enabled=false;
            end

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');
            headerFrame.Items={band_lbl,band,irtype_lbl,irtype,ordermode_lbl,...
            ordermode,order_lbl,order,ftype_widgets{:}};%#ok<CCAT>
            headerFrame.LayoutGrid=[5,4];
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('NyquistDesignHelpTxt');
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


            vars=cell(length(specCell)+1,1);
            vals=vars;

            vars{1}='B';
            vals{1}=num2str(specs.Band{1});

            for indx=1:length(specCell)
                switch lower(specCell{indx})
                case 'tw'
                    vars{indx+1}='TW';
                    vals{indx+1}=num2str(specs.TransitionWidth);
                case 'n'
                    vars{indx+1}='N';
                    vals{indx+1}=num2str(specs.Order);
                case 'ast'
                    vars{indx+1}='Astop';
                    vals{indx+1}=num2str(specs.Astop);
                end
            end

            mCodeInfo.Variables=vars;
            mCodeInfo.Values=vals;
            mCodeInfo.Inputs={vars{1},...
            sprintf('''%s''',getSpecification(this,laState)),vars{2:end}};


        end


        function specs=getSpecs(this,varargin)



            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            specs.FilterType=source.FilterType;
            specs.Factor=evaluatevars(source.Factor);
            if strcmpi(specs.FilterType,'sample-rate converter')
                specs.SecondFactor=evaluatevars(source.SecondFactor);
            end
            specs.Scale=strcmpi(this.Scale,'on');
            specs.ForceLeadingNumerator=strcmpi(this.ForceLeadingNumerator,'on');

            specs.Band={evaluatevars(source.Band)};
            specs.MagnitudeUnits=this.MagnitudeUnits;

            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');

            spec=lower(getSpecification(this,source));

            switch spec
            case 'tw,ast'
                specs.TransitionWidth=getnum(this,source,'TransitionWidth');
                specs.Astop=evaluatevars(source.Astop);
            case 'n,tw'
                specs.Order=evaluatevars(source.Order);
                specs.TransitionWidth=getnum(this,source,'TransitionWidth');
            case 'n'
                specs.Order=evaluatevars(source.Order);
            case 'n,ast'
                specs.Order=evaluatevars(source.Order);
                specs.Astop=evaluatevars(source.Astop);
            otherwise
                fprintf('Finish %s',spec);
            end


        end


        function validMethods=getValidMethods(this,varargin)




            hfdesign=get(this,'FDesign');

            try
                bandvalue=evaluatevars(this.Band);
            catch




                bandvalue=3;
            end

            set(hfdesign,'Specification',getSpecification(this),'Band',bandvalue);

            if nargin>1


                validMethods=designmethods(hfdesign,this.ImpulseResponse);
            else

                validMethods=designmethods(hfdesign,this.ImpulseResponse,'full');
            end


            validMethods=validMethods(:)';


        end


        function impulseresponse=get_impulseresponse(this,impulseresponse)




            try
                bandvalue=evaluatevars(this.Band);
            catch e %#ok<NASGU>
                bandvalue=3;
            end

            if bandvalue==2
                if isempty(impulseresponse)
                    impulseresponse='FIR';
                end
            else
                impulseresponse='FIR';
            end


        end


        function b=setGUI(this,Hd)




            b=true;
            hfdesign=getfdesign(Hd);
            if~strcmpi(get(hfdesign,'Response'),'nyquist')
                b=false;
                return;
            end
            set(this,'Band',num2str(hfdesign.Band));

            abstractnyquist_setGUI(this,Hd);


        end


        function set_band(this,oldValue)




            try
                val=evaluatevars(this.Band);
                successEval=true;
            catch

                successEval=false;
            end

            if successEval&&(val<2||(ceil(val)~=val)||~isreal(val))



                this.Band=oldValue;
                dp=DAStudio.DialogProvider;
                msg=FilterDesignDialog.message('InvalidNyquistBand');
                dp.errordlg(msg,'Filterbuilder',true);
            end


            updateMethod(this);


        end


        function thisloadobj(this,s)




            this.TransitionWidth=s.TransitionWidth;
            this.Astop=s.Astop;
            this.Band=s.Band;
            this.FrequencyConstraints=s.FrequencyConstraints;
            this.MagnitudeConstraints=s.MagnitudeConstraints;


        end


        function s=thissaveobj(this,s)




            s.TransitionWidth=this.TransitionWidth;
            s.Astop=this.Astop;
            s.Band=this.Band;
            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;


        end

    end

end

