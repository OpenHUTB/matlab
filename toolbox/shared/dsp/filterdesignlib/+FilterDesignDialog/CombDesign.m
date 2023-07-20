classdef(CaseInsensitiveProperties)CombDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(AbortSet,SetObservable,GetObservable)

        CombType='Notch';

        Q='16';

        BW='0.125';

        GBW=mat2str(db(sqrt(.5)));

        NumPeaksOrNotches='10';

        ShelvingFilterOrder='1';
    end

    properties(AbortSet,SetObservable,GetObservable,Dependent)



        FrequencyConstraints;


OrderMode2
    end

    properties(AbortSet,SetObservable,GetObservable,Hidden)



        privFrequencyConstraints='Quality Factor';


        privOrderMode2='Order';
    end

    properties(Hidden,Constant)
        OrderMode2Set={'Order','Number of Peaks','Number of Notches'};
        OrderMode2Entries={FilterDesignDialog.message('Order'),...
        FilterDesignDialog.message('NumPeaks'),...
        FilterDesignDialog.message('NumNotches')};

        FrequencyConstraintsSet={'Quality Factor','Bandwidth'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('Q'),...
        FilterDesignDialog.message('BW')};

        CombTypeSet={'Notch','Peak'};
        CombTypeEntries={FilterDesignDialog.message('notch'),...
        FilterDesignDialog.message('peak')};
    end


    methods
        function this=CombDesign(varargin)







            this.ImpulseResponse='IIR';
            this.OrderMode='specify';
            this.Order='10';
            this.VariableName=uiservices.getVariableName('Hcomb');
            if~isempty(varargin)
                set(this,varargin{:});
            end

            this.FDesign=fdesign.comb;
            updateMethod(this);


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);


        end

    end

    methods
        function set.CombType(obj,value)

            value=validatestring(value,obj.CombTypeSet,'','CombType');
            obj.CombType=value;
        end

        function value=get.OrderMode2(obj)
            value=obj.privOrderMode2;
        end
        function set.OrderMode2(obj,value)




            value=validatestring(value,obj.OrderMode2Set,'','OrderMode2');
            obj.privOrderMode2=value;
            updateFreqConstraints(obj);
        end

        function set.FrequencyConstraints(obj,value)

            value=validatestring(value,obj.FrequencyConstraintsSet,'','FrequencyConstraints');
            obj.privFrequencyConstraints=value;
        end

        function value=get.FrequencyConstraints(obj)
            value=obj.privFrequencyConstraints;
        end

        function set.Q(obj,value)

            validateattributes(value,{'char'},{'row'},'','Q')
            obj.Q=value;
        end

        function set.BW(obj,value)

            validateattributes(value,{'char'},{'row'},'','BW')
            obj.BW=value;
        end

        function set.GBW(obj,value)

            validateattributes(value,{'char'},{'row'},'','GBW')
            obj.GBW=value;
        end

        function set.NumPeaksOrNotches(obj,value)

            validateattributes(value,{'char'},{'row'},'','NumPeaksOrNotches')
            obj.NumPeaksOrNotches=value;
        end

        function set.ShelvingFilterOrder(obj,value)

            validateattributes(value,{'char'},{'row'},'','ShelvingFilterOrder')
            obj.ShelvingFilterOrder=value;
        end

    end

    methods

        function dialogTitle=getDialogTitle(this)




            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('CombFilter');
            else
                dialogTitle=FilterDesignDialog.message('CombDesign');
            end


        end


        function headerFrame=getHeaderFrame(this)




            [combtype_lbl,combtype]=getWidgetSchema(this,'CombType',FilterDesignDialog.message('CombType'),'combobox',1,1);
            combtype.DialogRefresh=true;
            combtype.Entries=FilterDesignDialog.message({'notch','peak'});
            combtype.Mode=true;


            [ordermode_lbl,ordermode,order_lbl,order]=getOrderWidgets(this,2,true);
            if strcmp(this.CombType,'Peak')
                numStringID='NumPeaks';
            else
                numStringID='NumNotches';
            end
            ordermode.Entries=FilterDesignDialog.message({'Order',numStringID});
            ordermode.ObjectProperty='OrderMode2';



            order.DialogRefresh=true;
            order.Mode=true;
            if any(strcmp(this.OrderMode2,{'Number of Notches','Number of Peaks'}))
                order.ObjectProperty='NumPeaksOrNotches';
                order_lbl.Name=FilterDesignDialog.message(numStringID);



                [nsh_lbl,nsh]=getWidgetSchema(this,'ShelvingFilterOrder',...
                FilterDesignDialog.message('ShelvingFilterOrder'),'edit',3,1);
                items={combtype_lbl,combtype,ordermode_lbl,ordermode,...
                order_lbl,order,nsh_lbl,nsh};
            else
                items={combtype_lbl,combtype,ordermode_lbl,ordermode,order_lbl,order};
            end

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');
            headerFrame.Items=items;
            headerFrame.LayoutGrid=[3,4];
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('CombDesignHelpTxt');
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function mCodeInfo=getMCodeInfo(this)



            laState=this.LastAppliedState;
            specs=getSpecs(this,laState);


            spec=getSpecification(this,laState);
            specCell=textscan(spec,'%s','delimiter',',');
            specCell=specCell{1};


            vars=cell(length(specCell),1);
            vals=vars;

            for indx=1:length(specCell)
                switch lower(specCell{indx})
                case 'n'
                    vars{indx}='N';
                    vals{indx}=num2str(specs.Order);
                case 'q'
                    vars{indx}='Q';
                    vals{indx}=num2str(specs.Q);
                case 'bw'
                    vars{indx}='BW';
                    vals{indx}=num2str(specs.BW);
                case 'gbw'
                    vars{indx}='GBW';
                    vals{indx}=num2str(specs.GBW);
                case 'l'
                    vars{indx}='L';
                    vals{indx}=num2str(specs.NumPeaksOrNotches);
                case 'nsh'
                    vars{indx}='Nsh';
                    vals{indx}=num2str(specs.ShelvingFilterOrder);

                end
            end

            mCodeInfo.Variables=vars;
            mCodeInfo.Values=vals;
            mCodeInfo.Inputs={['''',this.CombType,'''']...
            ,sprintf('''%s''',getSpecification(this,laState)),vars{:}};%#ok<CCAT>


        end


        function mspecs=getMagnitudeSpecsFrame(this)



            if strcmp(this.OrderMode2,'Order')

                help=FilterDesignDialog.message('NoMagConstHelpTxt');

                helptext.Type='text';
                helptext.WordWrap=true;
                helptext.Name=help;
                helptext.RowSpan=[1,1];
                helptext.ColSpan=[1,4];

                items={helptext};

            else
                items=getMagnitudeUnitsWidgets(this,1);

                [gbw_lbl,gbw]=getWidgetSchema(this,'GBW',FilterDesignDialog.message('GBW'),'edit',2,1);

                items=[items,{gbw_lbl,gbw}];

            end

            mspecs.Name=FilterDesignDialog.message('magspecs');
            mspecs.Type='group';
            mspecs.Items=items;
            mspecs.LayoutGrid=[3,4];
            mspecs.RowStretch=[0,0,1];
            mspecs.ColStretch=[0,1,0,1];
            mspecs.Tag='MagSpecsGroup';


        end


        function specification=getSpecification(this,laState)




            if nargin<2
                laState=this;
            end

            if strcmp(laState.OrderMode2,'Order')
                if strcmp(laState.FrequencyConstraints,'Bandwidth')
                    specification='N,BW';
                else
                    specification='N,Q';
                end
            else
                specification='L,BW,GBW,Nsh';
            end


        end


        function specs=getSpecs(this,varargin)



            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            specs.CombType=source.CombType;
            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');

            switch lower(getSpecification(this,source))
            case 'l,bw,gbw,nsh'
                specs.NumPeaksOrNotches=evaluatevars(source.NumPeaksOrNotches);
                specs.BW=getnum(this,source,'BW');
                specs.GBW=evaluatevars(source.GBW);
                specs.ShelvingFilterOrder=evaluatevars(source.ShelvingFilterOrder);
            case 'n,q'
                specs.Order=evaluatevars(source.Order);
                specs.Q=evaluatevars(source.Q);
            case 'n,bw'
                specs.Order=evaluatevars(source.Order);
                specs.BW=getnum(this,source,'BW');
            otherwise
                fprintf('Finish %s',specs);
            end


        end


        function validFreqConstraints=getValidFreqConstraints(this)




            if strcmp(this.OrderMode2,'Order')
                validFreqConstraints={'Quality Factor','Bandwidth'};
            else
                validFreqConstraints={'Bandwidth'};
            end


        end


        function b=setGUI(this,Hd)




            b=true;
            hfdesign=getfdesign(Hd);
            if~strcmpi(get(hfdesign,'Response'),'comb filter')
                b=false;
                return;
            end
            switch hfdesign.Specification
            case 'N,BW'
                set(this,...
                'FrequencyConstraints','Quality Factor',...
                'BW',num2str(hfdesign.BW));
            case 'N,Q'
                set(this,...
                'FrequencyConstraints','Quality Factor',...
                'Q',num2str(hfdesign.Q));
            case 'L,BW,GBW,Nsh'
                if strcmp(this.CombType,'Peak')
                    set(this,'OrderMode2','Number of Peaks');
                else
                    set(this,'OrderMode2','Number of Notches');
                end
                set(this,...
                'NumPeaksOrNotches',num2str(hfdesign.NumPeaksOrNotches),...
                'BW',num2str(hfdesign.BW),...
                'GBW',num2str(hfdesign.GBW),...
                'ShelvingFilterOrder',num2str(hfdesign.ShelvingFilterOrder));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:CombDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);

            set(this,'OrderMode','specify');


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

                switch lower(spec)
                case 'n,bw'
                    setspecs(hd,specs.CombType,specs.Order,specs.BW);
                case 'n,q'
                    setspecs(hd,specs.CombType,specs.Order,specs.Q);
                case 'l,bw,gbw,nsh'
                    setspecs(hd,specs.CombType,specs.NumPeaksOrNotches,specs.BW,...
                    specs.GBW,specs.ShelvingFilterOrder);
                otherwise
                    fprintf('Finish %s',spec);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)




            this.CombType=s.CombType;
            this.OrderMode2=s.OrderMode2;
            this.FrequencyConstraints=s.FrequencyConstraints;
            this.BW=s.BW;
            this.Q=s.Q;
            this.GBW=s.GBW;
            this.NumPeaksOrNotches=s.NumPeaksOrNotches;
            this.ShelvingFilterOrder=s.ShelvingFilterOrder;


        end


        function s=thissaveobj(this,s)




            s.CombType=this.CombType;
            s.BW=this.BW;
            s.Q=this.Q;
            s.GBW=this.GBW;
            s.OrderMode2=this.OrderMode2;
            s.NumPeaksOrNotches=this.NumPeaksOrNotches;
            s.ShelvingFilterOrder=this.ShelvingFilterOrder;
            s.FrequencyConstraints=this.FrequencyConstraints;


        end


        function updateFreqConstraints(this)


            validConstraints=getValidFreqConstraints(this);




            if~any(strcmpi(this.FrequencyConstraints,validConstraints))
                set(this,'FrequencyConstraints',validConstraints{1});
            end

        end

    end


    methods(Hidden)


        function fspecs=getFrequencySpecsFrame(this)





            items=getConstraintsWidgets(this,'Frequency',1);



            if strcmp(this.FrequencyConstraints,'Quality Factor')
                [q_lbl,q]=getWidgetSchema(this,'Q',FilterDesignDialog.message('QLabel'),'edit',2,1);
                items=[items,{q_lbl,q}];
                row=3;
            else
                [bw_lbl,bw]=getWidgetSchema(this,'BW',FilterDesignDialog.message('BWLabel'),'edit',3,1);
                items=[items,{bw_lbl,bw}];
                row=2;
            end


            items=getFrequencyUnitsWidgets(this,row,items);
            items{end}.DialogRefresh=true;
            freqs_lbl.Name=FilterDesignDialog.message([this.CombType,'Frequencies']);
            freqs_lbl.Type='text';
            freqs_lbl.RowSpan=[4,4];
            freqs_lbl.ColSpan=[1,1];
            freqs_lbl.Tag='FrequenciesLabel';

            freqString=getFrequencyString(this);

            freqs.Name=freqString;
            freqs.Type='text';
            freqs.RowSpan=[4,4];
            freqs.ColSpan=[2,4];
            freqs.Tag='Frequencies';

            items=[items,{freqs_lbl,freqs}];

            fspecs.Name=FilterDesignDialog.message('freqspecs');
            fspecs.Type='group';
            fspecs.Items=items;
            fspecs.LayoutGrid=[4,4];
            fspecs.RowStretch=[0,0,0,1];
            fspecs.ColStretch=[0,1,0,1];
            fspecs.Tag='FreqSpecsGroup';
        end




        function freqString=getFrequencyString(this)


            hd=getFDesign(this,this);
            if isempty(hd)
                freqString='Cannot calculate without DSP System Toolbox.';
            else
                freqValues=hd.([this.CombType,'Frequencies']);
                if~strcmp(this.FrequencyUnits,'Normalized (0 to 1)')
                    freqValues=convertfrequnits(freqValues,'hz',this.FrequencyUnits);
                end
                precision=5;
                freqString=mat2str(freqValues,precision);





                indx=length(freqValues)-2;
                while length(freqString)>58&&indx>2
                    freqString=mat2str(freqValues(1:indx),precision);
                    freqString=sprintf('%s ... %s]',freqString(1:end-1),...
                    mat2str(freqValues(end),precision));
                    indx=indx-1;
                end
            end
        end

    end

end




