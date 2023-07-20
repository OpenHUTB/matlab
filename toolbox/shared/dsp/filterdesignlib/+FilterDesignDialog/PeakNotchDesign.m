classdef(CaseInsensitiveProperties)PeakNotchDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(AbortSet,SetObservable,GetObservable)

        ResponseType='Peak';

        F0='0.5';

        Q='2.5';

        BW='0.2';

        Apass='1';

        Astop='60';
    end

    properties(AbortSet,SetObservable,GetObservable,Dependent)



        FrequencyConstraints;




        MagnitudeConstraints;
    end

    properties(Hidden,AbortSet,SetObservable,GetObservable)



        privFrequencyConstraints='Center frequency and quality factor';




        privMagnitudeConstraints='Unconstrained';
    end

    properties(Hidden,Constant)

        ResponseTypeSet={'Peak','Notch'};
        ResponseTypeEntries={FilterDesignDialog.message('peak'),...
        FilterDesignDialog.message('notch')};


        FrequencyConstraintsSet=...
        {'Center frequency and quality factor',...
        'Center frequency and bandwidth'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('F0andQ'),...
        FilterDesignDialog.message('F0andBW')};


        MagnitudeConstraintsSet=...
        {'Unconstrained',...
        'Passband ripple',...
        'Stopband attenuation',...
        'Passband ripple and stopband attenuation'};
        MagnitudeConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('Ap'),...
        FilterDesignDialog.message('Ast'),...
        FilterDesignDialog.message('ApAst')};

    end

    methods
        function this=PeakNotchDesign(varargin)


            this.VariableName=uiservices.getVariableName('Hpn');
            this.Order='6';...
            this.ImpulseResponse='IIR';
            this.OrderMode='specify';

            if~isempty(varargin)
                set(this,varargin{:});
            end

            this.FDesign=fdesign.peak;
            updateMethod(this);

            defSpecs=struct('FrequencyUnits','normalized (0 to 1)',...
            'InputSampleRate',2,...
            'Order',6,...
            'F0',0.5,...
            'Q',2.5);

            defOpts=cell(1,0);


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=defSpecs;
            this.LastAppliedDesignOpts=defOpts;


        end

    end

    methods
        function set.ResponseType(obj,value)

            value=validatestring(value,obj.ResponseTypeSet,'','ResponseType');
            obj.ResponseType=value;
        end

        function set.F0(obj,value)

            validateattributes(value,{'char'},{'row'},'','F0')
            obj.F0=value;
        end

        function set.Q(obj,value)

            validateattributes(value,{'char'},{'row'},'','Q')
            obj.Q=value;
        end

        function set.BW(obj,value)

            validateattributes(value,{'char'},{'row'},'','BW')
            obj.BW=value;
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
            value=obj.privFrequencyConstraints;
        end
        function set.FrequencyConstraints(obj,value)



            value=validatestring(value,obj.FrequencyConstraintsSet,'','FrequencyConstraints');
            oldFreqConstraints=obj.FrequencyConstraints;
            obj.privFrequencyConstraints=value;
            set_frequencyconstraints(obj,oldFreqConstraints);
        end

        function value=get.MagnitudeConstraints(obj)
            value=obj.privMagnitudeConstraints;
        end
        function set.MagnitudeConstraints(obj,value)

            oldMagConstraints=obj.privMagnitudeConstraints;
            obj.privMagnitudeConstraints=value;
            set_magnitudeconstraints(obj,oldMagConstraints)
        end

    end

    methods


        function set_frequencyconstraints(this,~)


            updateMagConstraints(this);

        end


        function set_magnitudeconstraints(this,~)


            updateMethod(this);

        end

        function dialogTitle=getDialogTitle(this)




            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('PeakNotchFilter');
            else
                dialogTitle=FilterDesignDialog.message('PeakNotchDesign');
            end


        end


        function[hfdesign,b,msg]=getFDesign(this,laState)




            if~isfdtbxinstalled
                hfdesign=[];
                b=true;
                msg='';
                return;
            end

            if nargin<2
                laState=this.LastAppliedState;
            end

            if isempty(laState)
                respType=this.ResponseType;
            else
                respType=laState.ResponseType;
            end

            switch lower(respType)
            case 'notch'
                hfdesign=fdesign.notch;
            case 'peak'
                hfdesign=fdesign.peak;
            end

            this.FDesign=hfdesign;


            [b,msg]=setupFDesign(this,laState);


        end


        function fspecs=getFrequencySpecsFrame(this)





            items=getConstraintsWidgets(this,'Frequency',1);


            items=getFrequencyUnitsWidgets(this,2,items);


            switch lower(this.FrequencyConstraints)
            case 'center frequency and quality factor'
                items=addConstraint(this,3,1,items,true,'F0',FilterDesignDialog.message('F0'));
                items=addConstraint(this,3,3,items,true,'Q',FilterDesignDialog.message('Q'),'Q');
            case 'center frequency and bandwidth'
                items=addConstraint(this,3,1,items,true,'F0',FilterDesignDialog.message('F0'));
                items=addConstraint(this,3,3,items,true,'BW',FilterDesignDialog.message('BW'));
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




            [rtype_lbl,rtype]=getWidgetSchema(this,'ResponseType',FilterDesignDialog.message('Response'),...
            'combobox',1,1);

            rtype_lbl.Tunable=true;
            rtype.Entries=FilterDesignDialog.message(lower({'Peak','Notch'}));
            rtype.DialogRefresh=true;
            rtype.Tunable=this.BuildUsingBasicElements;


            [order_lbl,order]=getOrderWidgets(this,2,false);

            order_lbl.RowSpan=[1,1];
            order_lbl.ColSpan=[3,3];
            order.RowSpan=[1,1];
            order.ColSpan=[4,4];

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');
            headerFrame.Items={rtype_lbl,rtype,order_lbl,order};
            headerFrame.LayoutGrid=[3,4];
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('PeakNotchDesignhelpTxt');
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

            if hasapass||hasastop

                items=getMagnitudeUnitsWidgets(this,2,items);

                [items,col]=addConstraint(this,3,1,items,hasapass,...
                'Apass',FilterDesignDialog.message('Apass'),'Passband ripple');
                items=addConstraint(this,3,col,items,hasastop,...
                'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');
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
            mspecs.LayoutGrid=[4,4];
            mspecs.RowStretch=[0,0,0,1];
            mspecs.ColStretch=[0,1,0,1];
            mspecs.Tag='MagSpecsGroup';


        end


        function specification=getSpecification(this,laState)




            if nargin>1&&~isempty(laState)
                freqcons=laState.FrequencyConstraints;
                magcons=laState.MagnitudeConstraints;
            else
                freqcons=get(this,'FrequencyConstraints');
                magcons=get(this,'MagnitudeConstraints');
            end

            specification='N';

            switch lower(freqcons)
            case 'center frequency and quality factor'
                specification=sprintf('%s,F0,Q',specification);
            case 'center frequency and bandwidth'
                specification=sprintf('%s,F0,BW',specification);
            end

            switch lower(magcons)
            case 'passband ripple'
                specification=sprintf('%s,Ap',specification);
            case 'stopband attenuation'
                specification=sprintf('%s,Ast',specification);
            case 'passband ripple and stopband attenuation'
                specification=sprintf('%s,Ap,Ast',specification);
            end


        end


        function specs=getSpecs(this,varargin)



            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            specs.Response=this.ResponseType;

            specs.Scale=strcmpi(this.Scale,'on');
            specs.ForceLeadingNumerator=strcmpi(this.ForceLeadingNumerator,'on');

            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');

            specs.Order=evaluatevars(source.Order);
            specs.F0=getnum(this,source,'F0');

            switch lower(getSpecification(this,source))
            case 'n,f0,q'
                specs.Q=evaluatevars(source.Q);
            case 'n,f0,q,ap'
                specs.Q=evaluatevars(source.Q);
                specs.Apass=evaluatevars(source.Apass);
            case 'n,f0,q,ast'
                specs.Q=evaluatevars(source.Q);
                specs.Astop=evaluatevars(source.Astop);
            case 'n,f0,q,ap,ast'
                specs.Q=evaluatevars(source.Q);
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
            case 'n,f0,bw'
                specs.BW=getnum(this,source,'BW');
            case 'n,f0,bw,ap'
                specs.BW=getnum(this,source,'BW');
                specs.Apass=evaluatevars(source.Apass);
            case 'n,f0,bw,ast'
                specs.BW=getnum(this,source,'BW');
                specs.Astop=evaluatevars(source.Astop);
            case 'n,f0,bw,ap,ast'
                specs.BW=getnum(this,source,'BW');
                specs.Apass=evaluatevars(source.Apass);
                specs.Astop=evaluatevars(source.Astop);
            otherwise
                fprintf('Finish %s',specs);
            end


        end


        function validFreqConstraints=getValidFreqConstraints(~)




            validFreqConstraints={'Center frequency and quality factor',...
            'Center frequency and bandwidth'};


        end


        function validMagConstraints=getValidMagConstraints(~)




            validMagConstraints={'Unconstrained','Passband ripple',...
            'Stopband attenuation','Passband ripple and stopband attenuation'};


        end


        function b=hasUnappliedChanges(this,~,s1,s2,fxpt1,fxpt2)




            oldSpecs=get(this,'LastAppliedState');
            actRespType=s1.ResponseType;
            s1=rmfield(s1,'ResponseType');
            s2=rmfield(s2,'ResponseType');

            b=true;
            if strcmp(actRespType,oldSpecs.ResponseType)&&...
                isequal(s1,s2)&&isequal(fxpt1,fxpt2)
                b=false;
            end



        end


        function b=setGUI(this,Hd)




            b=true;
            hfdesign=getfdesign(Hd);
            switch lower(get(hfdesign,'Response'))
            case 'peaking filter'
                set(this,'ResponseType','peak')
            case 'notching filter'
                set(this,'ResponseType','notch')
            otherwise
                b=false;
                return;
            end

            switch hfdesign.Specification
            case 'N,F0,Q'
                set(this,...
                'FrequencyConstraints','Center frequency and quality factor',...
                'MagnitudeConstraints','Unconstrained',...
                'F0',num2str(hfdesign.F0),...
                'Q',num2str(hfdesign.Q));
            case 'N,F0,Q,Ap'
                set(this,...
                'FrequencyConstraints','Center frequency and quality factor',...
                'MagnitudeConstraints','Passband ripple',...
                'F0',num2str(hfdesign.F0),...
                'Q',num2str(hfdesign.Q),...
                'Apass',num2str(hfdesign.Apass));
            case 'N,F0,Q,Ast'
                set(this,...
                'FrequencyConstraints','Center frequency and quality factor',...
                'MagnitudeConstraints','Stopband attenuation',...
                'F0',num2str(hfdesign.F0),...
                'Q',num2str(hfdesign.Q),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,F0,Q,Ap,Ast'
                set(this,...
                'FrequencyConstraints','Center frequency and quality factor',...
                'MagnitudeConstraints','Passband ripple and stopband attenuation',...
                'F0',num2str(hfdesign.F0),...
                'Q',num2str(hfdesign.Q),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,F0,BW'
                set(this,...
                'FrequencyConstraints','Center frequency and bandwidth',...
                'MagnitudeConstraints','Unconstrained',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW));
            case 'N,F0,BW,Ap'
                set(this,...
                'FrequencyConstraints','Center frequency and bandwidth',...
                'MagnitudeConstraints','Passband ripple',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'Apass',num2str(hfdesign.Apass));
            case 'N,F0,BW,Ast'
                set(this,...
                'FrequencyConstraints','Center frequency and bandwidth',...
                'MagnitudeConstraints','Stopband attenuation',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'Astop',num2str(hfdesign.Astop));
            case 'N,F0,BW,Ap,Ast'
                set(this,...
                'FrequencyConstraints','Center frequency and bandwidth',...
                'MagnitudeConstraints','Passband ripple and stopband attenuation',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'Apass',num2str(hfdesign.Apass),...
                'Astop',num2str(hfdesign.Astop));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:PeakNotchDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
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



            set(hd,'Specification',...
            validatestring(spec,hd.getAllowedStringValues('Specification')));



            try
                specs=getSpecs(this,source);

                if strncmpi(source.FrequencyUnits,'normalized',10)
                    normalizefreq(hd);
                else
                    normalizefreq(hd,false,specs.InputSampleRate);
                end

                switch lower(getSpecification(this,source))
                case 'n,f0,q'
                    setspecs(hd,specs.Order,specs.F0,specs.Q);
                case 'n,f0,q,ap'
                    setspecs(hd,specs.Order,specs.F0,specs.Q,specs.Apass);
                case 'n,f0,q,ast'
                    setspecs(hd,specs.Order,specs.F0,specs.Q,specs.Astop);
                case 'n,f0,q,ap,ast'
                    setspecs(hd,specs.Order,specs.F0,specs.Q,specs.Apass,specs.Astop);
                case 'n,f0,bw'
                    setspecs(hd,specs.Order,specs.F0,specs.BW);
                case 'n,f0,bw,ap'
                    setspecs(hd,specs.Order,specs.F0,specs.BW,specs.Apass);
                case 'n,f0,bw,ast'
                    setspecs(hd,specs.Order,specs.F0,specs.BW,specs.Astop);
                case 'n,f0,bw,ap,ast'
                    setspecs(hd,specs.Order,specs.F0,specs.BW,specs.Apass,specs.Astop);
                otherwise
                    fprintf('Finish %s\n',spec);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)




            if isfield(s,'ResponseType')

                this.ResponseType=s.ResponseType;
            end
            this.F0=s.F0;
            this.Q=s.Q;
            this.BW=s.BW;
            this.Apass=s.Apass;
            this.Astop=s.Astop;

            if isfield(s,'FrequencyConstraints')
                this.FrequencyConstraints=s.FrequencyConstraints;
                this.MagnitudeConstraints=s.MagnitudeConstraints;
            end


        end


        function s=thissaveobj(this,s)




            s.ResponseType=this.ResponseType;
            s.F0=this.F0;
            s.Q=this.Q;
            s.BW=this.BW;
            s.Apass=this.Apass;
            s.Astop=this.Astop;
            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;


        end

    end

end

