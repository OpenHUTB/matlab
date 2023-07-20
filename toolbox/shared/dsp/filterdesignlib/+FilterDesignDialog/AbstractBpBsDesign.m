classdef(CaseInsensitiveProperties)AbstractBpBsDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(AbortSet,SetObservable,GetObservable)

        SpecifyDenominator(1,1)logical=false;

        DenominatorOrder='20';
    end

    methods
        function value=get.SpecifyDenominator(obj)
            value=obj.SpecifyDenominator;
        end
        function set.SpecifyDenominator(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','SpecifyDenominator')
            value=logical(value);
            obj.SpecifyDenominator=value;
            set_specifydenominator(obj);
        end

        function value=get.DenominatorOrder(obj)
            value=obj.DenominatorOrder;
        end
        function set.DenominatorOrder(obj,value)

            validateattributes(value,{'char'},{'row'},'','DenominatorOrder')
            obj.DenominatorOrder=value;
        end

    end

    methods

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


            if~isfir(this)&&isDSTMode(this)
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


        function setConstrainedProperties(this,prop,val)



            set(this,prop,mat2str(val));


        end


        function set_ordermode(this,~)



            updateFreqConstraints(this);


        end

    end


    methods(Hidden)

        function[items,colindx]=addConstraintBands(this,rowindx,colindx,items,...
            has,constraintFlagProp,constraintValueProp,label,enableFlag,tooltip)




            if~has
                return;
            end

            if nargin<7
                label=interspace(prop);
                label=[label(1),lower(label(2:end))];
            end

            tunable=~isminorder(this)&&this.BuildUsingBasicElements;

            spec_lbl.Name=label;
            spec_lbl.Type='checkbox';
            spec_lbl.Source=this;
            spec_lbl.Mode=false;
            spec_lbl.DialogRefresh=true;
            spec_lbl.RowSpan=[rowindx,rowindx];
            spec_lbl.ColSpan=[colindx,colindx];
            spec_lbl.Enabled=true;
            spec_lbl.Value=strcmpi(this.(constraintFlagProp),'true');
            spec_lbl.Tag=constraintFlagProp;
            spec_lbl.Tunable=tunable;

            spec_lbl.ObjectMethod='setConstrainedProperties';
            spec_lbl.MethodArgs={constraintFlagProp,'%value'};
            spec_lbl.ArgDataTypes={'string','bool'};

            if nargin>7
                spec_lbl.ToolTip=tooltip;
            end

            items=[items,{spec_lbl}];
            colindx=colindx+1;


            spec.Type='edit';
            spec.RowSpan=[rowindx,rowindx];
            spec.ColSpan=[colindx,colindx];
            spec.ObjectProperty=constraintValueProp;
            spec.Source=this;
            spec.Mode=true;
            spec.Tag=constraintValueProp;
            spec.Tunable=tunable;
            spec.Enabled=enableFlag;

            colindx=colindx+1;

            items=[items,{spec}];


        end


        function set_specifydenominator(this,~)
            if isDSTMode(this)


                this.FrequencyConstraints='Passband and stopband edges';
                this.MagnitudeConstraints='Unconstrained';
            end
            updateMethod(this);
        end

    end

end

