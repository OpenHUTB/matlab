classdef(CaseInsensitiveProperties)HilbertDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(AbortSet,SetObservable,GetObservable)

        TransitionWidth='0.1';

        Apass='1';
    end


    methods
        function this=HilbertDesign(varargin)

            if~isempty(varargin)
                set(this,varargin{:});
            end
            this.VariableName=this.getOutputVarName('hilb');
            this.Order='31';

            if~isDSTMode(this)


                this.OrderMode='Specify';
            end

            this.FDesign=fdesign.hilbert;
            this.DesignMethod='Equiripple';



            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);

        end

    end

    methods
        function set.TransitionWidth(obj,value)

            validateattributes(value,{'char'},{'row'},'','TransitionWidth')
            obj.TransitionWidth=value;
        end

        function set.Apass(obj,value)

            validateattributes(value,{'char'},{'row'},'','Apass')
            obj.Apass=value;
        end

    end

    methods

        function dialogTitle=getDialogTitle(this)



            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('HilbertFilter');
            else
                if isFilterDesignerMode(this)
                    dialogTitle=FilterDesignDialog.message(['HilbertDesign',this.ImpulseResponse]);
                else
                    dialogTitle=FilterDesignDialog.message('HilbertDesign');
                end
            end


        end


        function fspecs=getFrequencySpecsFrame(this)





            items=getFrequencyUnitsWidgets(this,1);

            items=addConstraint(this,2,1,items,true,...
            'TransitionWidth',FilterDesignDialog.message('TW'),'Transition width');

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
                [irtype_lbl,irtype]=getWidgetSchema(this,'ImpulseResponse',...
                FilterDesignDialog.message('impresp'),'combobox',1,1);

                irtype.Entries=FilterDesignDialog.message({'fir','iir'});
                irtype.DialogRefresh=true;

                orderwidgets=getOrderWidgets(this,2,true);
                ftypewidgets=getFilterTypeWidgets(this,3);
            else
                orderwidgets=getOrderWidgets(this,2,false);
            end

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');

            if isDSTMode(this)
                headerFrame.Items={irtype_lbl,irtype,orderwidgets{:},ftypewidgets{:}};%#ok<CCAT>
                headerFrame.LayoutGrid=[3,4];
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
                helptext.Name=FilterDesignDialog.message('HilbertDesignHelpTxt');
            end
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function mspecs=getMagnitudeSpecsFrame(this)




            if isminorder(this)

                items=getMagnitudeUnitsWidgets(this,1);

                items=addConstraint(this,2,1,items,true,...
                'Apass',FilterDesignDialog.message('Apass'),'Passband ripple');
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


        function specification=getSpecification(this,varargin)




            if isminorder(this,varargin{:})
                specification='TW,Ap';
            else
                specification='N,TW';
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
            case 'n,tw'
                specs.Order=evaluateVariable(this,source.Order);
                specs.TransitionWidth=getnum(this,source,'TransitionWidth');
            case 'tw,ap'
                specs.TransitionWidth=getnum(this,source,'TransitionWidth');
                specs.Apass=evaluateVariable(this,source.Apass);
                specs.MagnitudeUnits=source.MagnitudeUnits;
            end


        end


        function b=setGUI(this,Hd)




            b=true;
            hfdesign=getfdesign(Hd);
            if~any(strcmpi(get(hfdesign,'Response'),{'hilbert','hilbert transformer'}))
                b=false;
                return;
            end

            switch hfdesign.Specification
            case 'N,TW'
                set(this,'TransitionWidth',num2str(hfdesign.TransitionWidth));
            case 'TW,Ap'
                set(this,...
                'TransitionWidth',num2str(hfdesign.TransitionWidth),...
                'Apass',num2str(hfdesign.Apass));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:HilbertDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function set_impulseresponse(this,~)




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

            updateMethod(this);


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

                switch lower(spec)
                case 'n,tw'
                    setspecs(hd,specs.Order,specs.TransitionWidth);
                case 'tw,ap'
                    setspecs(hd,specs.TransitionWidth,specs.Apass,specs.MagnitudeUnits);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end

        end


        function thisloadobj(this,s)




            set(this,'TransitionWidth',s.TransitionWidth,'Apass',s.Apass);


        end


        function s=thissaveobj(this,s)




            s.TransitionWidth=this.TransitionWidth;
            s.Apass=this.Apass;


        end

    end

end

