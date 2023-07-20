classdef(CaseInsensitiveProperties)FracDelayDesign<FilterDesignDialog.AbstractDesign




    properties(AbortSet,SetObservable,GetObservable)

        FracDelay='0.5';
    end


    methods
        function this=FracDelayDesign(varargin)





            this.VariableName=uiservices.getVariableName('Hfd');
            if~isempty(varargin)
                set(this,varargin{:});
            end
            this.Order='3';
            this.OrderMode='specify';

            this.FDesign=fdesign.fracdelay;
            updateMethod(this);


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);


        end

    end

    methods
        function set.FracDelay(obj,value)

            validateattributes(value,{'char'},{'row'},'','FracDelay')
            obj.FracDelay=value;
        end

    end

    methods

        function dialogTitle=getDialogTitle(this)




            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('FracDelayFilter');
            else
                dialogTitle=FilterDesignDialog.message('FracDelayDesign');
            end


        end


        function headerFrame=getHeaderFrame(this)



            if~strcmpi(this.OperatingMode,'simulink')

                items=getFrequencyUnitsWidgets(this,1);

                [fracdelay_lbl,fracdelay]=getWidgetSchema(this,'FracDelay',...
                FilterDesignDialog.message('FracDelay'),'edit',2,1);

                items={items{:},fracdelay_lbl,fracdelay};%#ok<CCAT>
            else
                items={};
            end

            orderwidgets=getOrderWidgets(this,3,false);
            order=orderwidgets{2};
            order.Type='combobox';
            order.Entries={'1','2','3','4','5','6'};
            order.Editable=true;

            orderwidgets{2}=order;

            items=[items,orderwidgets];

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');
            headerFrame.Items=items;
            headerFrame.LayoutGrid=[4,4];
            headerFrame.RowStretch=[0,0,0,1];
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='MainGroup';

        end


        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('FracDelayDesignHelpTxt');
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

            mCodeInfo.Variables={'delay','N'};
            mCodeInfo.Values={num2str(specs.FracDelay),num2str(specs.Order)};
            mCodeInfo.Descriptions={'Fractional Delay',''};
            mCodeInfo.Inputs={'delay','''n''','N'};


        end


        function main=getMainFrame(this)



            header=getHeaderFrame(this);
            header.RowSpan=[1,1];
            header.ColSpan=[1,1];

            main.Type='panel';
            main.Tag='Main';
            if strcmpi(this.OperatingMode,'Simulink')
                implem=getImplementationFrame(this);
                implem.RowSpan=[2,2];
                implem.ColSpan=[1,1];
                main.Items={header,implem};
            else
                main.Items={header};
            end


        end


        function specification=getSpecification(~,~)




            specification='n';


        end


        function specs=getSpecs(this,varargin)



            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');
            specs.FracDelay=evaluatevars(source.FracDelay);
            specs.Order=evaluatevars(source.Order);


        end


        function b=setGUI(this,Hd)




            b=true;
            hfdesign=getfdesign(Hd);
            if~(strcmpi(get(hfdesign,'Response'),'farrow fractional delay')||...
                strcmpi(get(hfdesign,'Response'),'fractional delay'))
                b=false;
                return;
            end

            set(this,...
            'FracDelay',num2str(hfdesign.FracDelay),...
            'Order',num2str(hfdesign.FilterOrder));

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

            try
                specs=getSpecs(this,source);

                if strncmpi(specs.FrequencyUnits,'normalized',10)
                    normalizefreq(hd);
                else
                    normalizefreq(hd,false,specs.InputSampleRate);
                end

                set(hd,'FracDelay',specs.FracDelay,'FilterOrder',specs.Order);
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)




            set(this,'FracDelay',s.FracDelay);


        end


        function s=thissaveobj(this,s)




            s.FracDelay=this.FracDelay;


        end

    end


    methods(Hidden)

        function b=supportsAnalysis(this)





            b=any(strcmpi({'matlab','filterdesigner'},this.OperatingMode));


        end

    end

end

