classdef(CaseInsensitiveProperties)HalfbandDesign<FilterDesignDialog.AbstractNyquistDesign




    properties(AbortSet,SetObservable,GetObservable)

        Type='Lowpass';
    end

    properties(Hidden,Constant)
        TypeSet={'Lowpass','Highpass'};
        TypeEntries={FilterDesignDialog.message('lp'),...
        FilterDesignDialog.message('hp')}
    end


    methods
        function this=HalfbandDesign(varargin)





            this.VariableName=uiservices.getVariableName('Hhb');
            if~isempty(varargin)
                set(this,varargin{:});
            end

            set(this,'FDesign',fdesign.halfband);
            updateMethod(this);


            set(this,...
            'LastAppliedState',getState(this),...
            'LastAppliedSpecs',getSpecs(this),...
            'LastAppliedDesignOpts',getDesignOptions(this));


        end

    end

    methods
        function set.Type(obj,value)

            validateattributes(value,{'char'},{'row'},'','Type');
            obj.Type=set_type(obj,value);
        end

    end

    methods

        function dialogTitle=getDialogTitle(this)




            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle='Halfband Filter';
            else
                dialogTitle=FilterDesignDialog.message('HalfbandDesign');
            end


        end


        function headerFrame=getHeaderFrame(this)




            [irtype_lbl,irtype]=getWidgetSchema(this,'ImpulseResponse',...
            FilterDesignDialog.message('impresp'),'combobox',1,1);

            irtype.Entries=FilterDesignDialog.message({'fir','iir'});
            irtype.DialogRefresh=true;

            orderwidgets=getOrderWidgets(this,2,true);

            [type_lbl,type]=getWidgetSchema(this,'Type',FilterDesignDialog.message('ResponseType'),...
            'combobox',3,1);
            type.Entries=FilterDesignDialog.message({'lp','hp'});
            type.DialogRefresh=true;

            options={'Lowpass','Highpass'};
            type.ObjectMethod='selectComboboxEntry';
            type.MethodArgs={'%dialog','%value','Type',options};
            type.ArgDataTypes={'handle','mxArray','string','mxArray'};



            type.Mode=false;



            type=rmfield(type,'ObjectProperty');


            indx=find(strcmp(options,this.Type));
            if~isempty(indx)
                type.Value=indx-1;
            end

            [ftype_lbl,ftype]=getWidgetSchema(this,'FilterType',...
            FilterDesignDialog.message('FilterType'),...
            'combobox',4,1);

            if strcmpi(this.Type,'highpass')&&strcmpi(this.ImpulseResponse,'iir')
                ftype.Enabled=false;
                ftype_lbl.Enabled=false;
            end

            ftypes=this.FilterTypeSet;


            ftypes=strrep(ftypes,'-','_');

            ftype.Entries=FilterDesignDialog.message(strrep(ftypes(1:3),' ',''));
            ftype.DialogRefresh=true;

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('freqspecs');
            headerFrame.Items=[{irtype_lbl,irtype},orderwidgets,...
            {type_lbl,type,ftype_lbl,ftype}];
            headerFrame.LayoutGrid=[4,4];
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('HalfbandDesignHelpTxt');
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


            vars=cell(length(specCell),1);
            vals=vars;

            for indx=1:length(specCell)
                switch lower(specCell{indx})
                case 'tw'
                    vars{indx}='TW';
                    vals{indx}=num2str(specs.TransitionWidth);
                case 'n'
                    vars{indx}='N';
                    vals{indx}=num2str(specs.Order);
                case 'ast'
                    vars{indx}='Astop';
                    vals{indx}=num2str(specs.Astop);
                end
            end

            mCodeInfo.Variables=vars;
            mCodeInfo.Values=vals;
            mCodeInfo.Inputs={'''Type''',['''',this.Type,'''']...
            ,sprintf('''%s''',getSpecification(this,laState)),vars{:}};%#ok<CCAT>


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

            specs.Band={};
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


        function b=setGUI(this,Hd)




            b=true;
            hfdesign=getfdesign(Hd);
            if~strcmpi(get(hfdesign,'Response'),'halfband')
                b=false;
                return;
            end
            abstractnyquist_setGUI(this,Hd);


        end


        function set_impulseresponse(this,oldImpulseResponse)%#ok




            impulseresponse=get(this,'ImpulseResponse');


            if strcmpi(impulseresponse,'fir')&&strcmpi(this.MagnitudeUnits,'squared')
                this.MagnitudeUnits='db';
            elseif strcmpi(impulseresponse,'iir')&&strcmpi(this.MagnitudeUnits,'linear')
                this.MagnitudeUnits='db';
            end


            if strcmpi(impulseresponse,'iir')&&strcmpi(this.Type,'highpass')
                set(this,'FilterType','single-rate')
            end

            updateFreqConstraints(this);


        end


        function setupFDesignTypes(this)




            fd=get(this,'FDesign');
            if~isempty(fd)
                fd.Type=this.Type;
            end


        end


        function thisloadobj(this,s)




            this.TransitionWidth=s.TransitionWidth;
            this.Astop=s.Astop;
            this.FrequencyConstraints=s.FrequencyConstraints;
            this.MagnitudeConstraints=s.MagnitudeConstraints;
            if~isfield(s,'Type')
                this.Type='Lowpass';
            else
                this.Type=s.Type;
            end


        end


        function s=thissaveobj(this,s)




            s.TransitionWidth=this.TransitionWidth;
            s.Astop=this.Astop;
            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;
            s.Type=this.Type;

        end


        function type=set_type(this,type)

            if strcmpi(type,'highpass')&&strcmpi(this.ImpulseResponse,'iir')
                this.FilterType='single-rate';
            end
        end

    end

end

