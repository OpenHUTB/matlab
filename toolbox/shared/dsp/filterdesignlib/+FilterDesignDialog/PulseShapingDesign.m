classdef(CaseInsensitiveProperties)PulseShapingDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(SetObservable)

        OrderMode2='Minimum';

        PulseShape='Raised Cosine';

        SamplesPerSymbol='8';

        NumberOfSymbols='6';

        Beta='0.5';

        Astop='50';

        AstopSQRT='30';

        BT='.3';
    end

    properties(Dependent)



        FrequencyConstraints;




        MagnitudeConstraints;
    end

    properties(Hidden,SetObservable)



        privFrequencyConstraints='Rolloff Factor';




        privMagnitudeConstraints='Stopband attenuation';
    end

    properties(Hidden,Constant)

        FrequencyConstraintsSet=...
        {'Rolloff Factor','Bandwidth-Symbol TIme Product'};
        FrequencyConstraintsEntries={'Rolloff Factor',...
        'Bandwidth-Symbol TIme Product'};


        MagnitudeConstraintsSet=...
        {'Unconstrained','Passband ripple and stopband attenuation','Passband ripple','Stopband attenuation'};
        MagnitudeConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('ApAst'),...
        FilterDesignDialog.message('Ap'),...
        FilterDesignDialog.message('Ast')};


        PulseShapeSet=...
        {'Raised Cosine','Square Root Raised Cosine','Gaussian'};
        PulseShapeEntries={FilterDesignDialog.message('RaisedCosine'),...
        FilterDesignDialog.message('SquareRootRaisedCosine'),...
        FilterDesignDialog.message('Gaussian')};
    end


    methods
        function this=PulseShapingDesign(varargin)



            this.Order='48';
            this.VariableName=this.getOutputVarName('ps');
            if~isempty(varargin)
                set(this,varargin{:});
            end

            this.FDesign=fdesign.pulseshaping;
            this.DesignMethod='Window';


            this.Factor='8';


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);

        end

    end

    methods
        function value=get.OrderMode2(obj)
            value=get_ordermode2(obj,obj.OrderMode2);
        end
        function set.OrderMode2(obj,value)

            validateattributes(value,{'char'},{'row'},'','OrderMode2')
            obj.OrderMode2=value;

        end

        function set.PulseShape(obj,value)


            value=validatestring(value,obj.PulseShapeSet,'','PulseShape');
            obj.PulseShape=value;
        end

        function set.SamplesPerSymbol(obj,value)

            validateattributes(value,{'char'},{'row'},'','SamplesPerSymbol')
            obj.SamplesPerSymbol=value;
        end

        function set.NumberOfSymbols(obj,value)

            validateattributes(value,{'char'},{'row'},'','NumberOfSymbols')
            obj.NumberOfSymbols=value;
        end

        function set.Beta(obj,value)

            validateattributes(value,{'char'},{'row'},'','Beta')
            obj.Beta=value;
        end

        function set.Astop(obj,value)

            validateattributes(value,{'char'},{'row'},'','Astop')
            obj.Astop=value;
        end

        function set.AstopSQRT(obj,value)

            validateattributes(value,{'char'},{'row'},'','AstopSQRT')
            obj.AstopSQRT=value;
        end

        function set.BT(obj,value)

            validateattributes(value,{'char'},{'row'},'','BT')
            obj.BT=value;
        end

        function value=get.FrequencyConstraints(obj)
            value=lcl_get_frequencyconstraints(obj,obj.privFrequencyConstraints);
        end
        function set.FrequencyConstraints(obj,value)



            value=validatestring(value,obj.FrequencyConstraintsSet,'','FrequencyConstraints');
            obj.privFrequencyConstraints=value;

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
                dialogTitle=FilterDesignDialog.message('PulseShapingFilter');
            else
                dialogTitle=FilterDesignDialog.message('PulseShapingDesign');
            end


        end


        function fspecs=getFrequencySpecsFrame(this)



            if strcmpi(this.PulseShape,'gaussian')
                [bt_lbl,bt]=getWidgetSchema(this,'BT',...
                FilterDesignDialog.message('BT'),'edit',1,1);
                items={bt_lbl,bt};
            else
                [rolloff_lbl,rolloff]=getWidgetSchema(this,'Beta',...
                FilterDesignDialog.message('RolloffFactor'),'edit',1,1);
                items={rolloff_lbl,rolloff};
            end


            items=getFrequencyUnitsWidgets(this,2,items);

            fspecs.Name=FilterDesignDialog.message('freqspecs');
            fspecs.Type='group';
            fspecs.Items=items;
            fspecs.LayoutGrid=[2,4];
            fspecs.RowStretch=[0,1];
            fspecs.ColStretch=[0,1,0,1];
            fspecs.Tag='FreqSpecsGroup';


        end


        function headerFrame=getHeaderFrame(this)




            [irtype_lbl,irtype]=getWidgetSchema(this,'PulseShape',...
            FilterDesignDialog.message('PulseShape'),'combobox',1,1);
            irtype.Entries=getEntries(this.PulseShapeSet);


            indx=find(strcmp(this.PulseShapeSet,this.PulseShape));
            if~isempty(indx)
                irtype.Value=indx-1;
            end
            irtype.DialogRefresh=true;

            [ordermode_lbl,ordermode]=getWidgetSchema(this,'OrderMode2',...
            FilterDesignDialog.message('ordermode'),'combobox',2,1);
            if strcmpi(this.PulseShape,'gaussian')
                options={'Specify symbols'};
                ordermode.Entries=getEntries(options);
                ordermode.Enabled=false;
            else
                options={'Minimum','Specify order','Specify symbols'};
                ordermode.Entries=getEntries(options);

                indx=find(strcmp(options,this.OrderMode2));
                if~isempty(indx)
                    ordermode.Value=indx-1;
                end
            end
            ordermode.DialogRefresh=true;


            ordermode.ObjectMethod='selectComboboxEntry';
            ordermode.MethodArgs={'%dialog','%value','Ordermode2',...
            options};
            ordermode.ArgDataTypes={'handle','mxArray','string','mxArray'};



            ordermode.Mode=false;



            ordermode=rmfield(ordermode,'ObjectProperty');


            switch lower(this.OrderMode2)
            case 'minimum'
                [order_lbl,order]=getWidgetSchema(this,'Order',FilterDesignDialog.message('order'),'edit',2,3);
                order_lbl.Enabled=false;
                order.Enabled=false;
                order_lbl.Visible=false;
                order.Visible=false;
            case 'specify order'
                [order_lbl,order]=getWidgetSchema(this,'Order',FilterDesignDialog.message('order'),'edit',2,3);
                order_lbl.Enabled=true;
                order.Enabled=true;
                order_lbl.Visible=true;
                order.Visible=true;
            case 'specify symbols'
                [order_lbl,order]=getWidgetSchema(this,'NumberOfSymbols',...
                FilterDesignDialog.message('NumSymbols'),'edit',2,3);
                order_lbl.Enabled=true;
                order.Enabled=true;
                order_lbl.Visible=true;
                order.Visible=true;
            end

            [samples_lbl,samples]=getWidgetSchema(this,'SamplesPerSymbol',...
            FilterDesignDialog.message('SamplesPerSymbol'),'edit',3,1);

            if isfdtbxinstalled
                ftype_widgets=getFilterTypeWidgets(this,4);
            end

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');

            if isfdtbxinstalled
                headerFrame.Items=[{irtype_lbl,irtype,ordermode_lbl,ordermode,...
                order_lbl,order,samples_lbl,samples},ftype_widgets];
                headerFrame.LayoutGrid=[4,4];
            else
                headerFrame.Items={irtype_lbl,irtype,ordermode_lbl,ordermode,...
                order_lbl,order,samples_lbl,samples};
                headerFrame.LayoutGrid=[3,4];
            end

            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';
        end





        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('PulseShapingDesignHelpTxt');
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

            vars={'SPS'};
            vals={mat2str(specs.SamplesPerSymbol)};
            desc={'Samples per Symbol'};

            singleRateFlag=0;
            if strncmpi(this.FilterType,'single',6)
                vars=[vars,'PulseShape'];
                vals=[vals,sprintf('''%s''',this.PulseShape)];
                desc=[desc,'Pulse shape'];
                singleRateFlag=1;
            end
            spec=getSpecification(this);

            switch lower(spec)
            case 'ast,beta'
                specvars={'Astop','Beta'};
                vals=[vals,{mat2str(specs.Astop),mat2str(specs.Beta)}];
                desc=[desc,{'Stopband Attenuation','Rolloff Factor'}];
            case 'nsym,beta'
                specvars={'Nsym','Beta'};
                vals=[vals,{mat2str(specs.NumberOfSymbols),mat2str(specs.Beta)}];
                desc=[desc,{'Number of Symbols','Rolloff Factor'}];
            case 'n,beta'
                specvars={'N','Beta'};
                vals=[vals,{mat2str(specs.Order),mat2str(specs.Beta)}];
                desc=[desc,{'Filter Order','Rolloff Factor'}];
            case 'nsym,bt'
                specvars={'Nsym','BT'};
                vals=[vals,{mat2str(specs.NumberOfSymbols),mat2str(specs.BT)}];
                desc=[desc,{'Number of Symbols','Bandwidth-Time Product'}];
            otherwise
                fprintf('Finish %s',spec);
            end

            mCodeInfo.Variables=[vars,specvars];
            mCodeInfo.Values=vals;
            mCodeInfo.Descriptions=desc;
            if~singleRateFlag
                mCodeInfo.Inputs=[{'SPS',sprintf('''%s''',spec)},specvars];
            else
                mCodeInfo.Inputs=[{'SPS','PulseShape',sprintf('''%s''',spec)},specvars];
            end

        end


        function mspecs=getMagnitudeSpecsFrame(this)



            if isminorder(this)

                items=getMagnitudeUnitsWidgets(this,1);

                if strcmpi(this.PulseShape,'square root raised cosine')
                    items=addConstraint(this,2,1,items,true,...
                    'AstopSQRT',FilterDesignDialog.message('Astop'),'Stopband attenuation');
                else
                    items=addConstraint(this,2,1,items,true,...
                    'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');
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


        end


        function specification=getSpecification(this,laState)




            if nargin<2||isempty(laState)
                laState=this;
            end

            if strcmpi(laState.PulseShape,'gaussian')
                specification='nsym,bt';
            else
                switch lower(laState.OrderMode2)
                case 'minimum'
                    specification='ast,beta';
                case 'specify order'
                    specification='n,beta';
                case 'specify symbols'
                    specification='nsym,beta';
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
            if strcmpi(specs.FilterType,'sample-rate converter')
                specs.SecondFactor=evaluatevars(source.SecondFactor);
            end

            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');
            specs.SamplesPerSymbol=evaluatevars(source.SamplesPerSymbol);

            switch lower(getSpecification(this,source))
            case 'ast,beta'
                specs.Beta=evaluatevars(source.Beta);
                if strcmpi(this.PulseShape,'square root raised cosine')
                    specs.Astop=evaluatevars(source.AstopSQRT);
                else
                    specs.Astop=evaluatevars(source.Astop);
                end
                specs.MagnitudeUnits=source.MagnitudeUnits;
            case 'n,beta'
                specs.Order=evaluatevars(source.Order);
                specs.Beta=evaluatevars(source.Beta);
            case 'nsym,beta'
                specs.NumberOfSymbols=evaluatevars(source.NumberOfSymbols);
                specs.Beta=evaluatevars(source.Beta);
            case 'nsym,bt'
                specs.NumberOfSymbols=evaluatevars(source.NumberOfSymbols);
                specs.BT=evaluatevars(source.BT);
            otherwise
                fprintf('Finish %s\n',specs);
            end


        end


        function b=isminorder(this,laState)



            if nargin>1&&~isempty(laState)
                source=laState;
            else
                source=this;
            end

            b=strcmpi(source.OrderMode2,'minimum');


        end


        function b=setGUI(this,Hd)



            b=true;
            hfdesign=getfdesign(Hd);

            switch get(hfdesign,'Response')
            case 'Pulse Shaping'
                pulseShape=hfdesign.PulseShape;
            case{'Raised Cosine','Gaussian','Square Root Raised Cosine'}
                pulseShape=hfdesign.Response;
            otherwise
                b=false;
                return;
            end

            hfmethod=getfmethod(Hd);

            set(this,...
            'PulseShape',pulseShape,...
            'SamplesPerSymbol',num2str(hfdesign.SamplesPerSymbol),...
            'Structure',convertStructure(this,hfmethod.FilterStructure));

            astopProp='Astop';
            if strcmp(pulseShape,'Square Root Raised Cosine')
                astopProp='AstopSQRT';
            end

            switch hfdesign.Specification
            case 'Ast,Beta'
                set(this,...
                'OrderMode2','Minimum',...
                'Beta',num2str(hfdesign.RolloffFactor),...
                astopProp,num2str(hfdesign.Astop));
            case 'Nsym,Beta'
                set(this,...
                'OrderMode2','Specify symbols',...
                'NumberOfSymbols',num2str(hfdesign.NumberOfSymbols),...
                'Beta',num2str(hfdesign.RolloffFactor));
            case 'N,Beta'
                set(this,...
                'OrderMode2','Specify order',...
                'Order',num2str(hfdesign.FilterOrder),...
                'Beta',num2str(hfdesign.RolloffFactor));
            case 'Nsym,BT'
                set(this,...
                'OrderMode2','Specify symbols',...
                'NumberOfSymbols',num2str(hfdesign.NumberOfSymbols),...
                'BT',num2str(hfdesign.BT));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:PulseShapingDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function[success,msg]=setupFDesign(this,varargin)



            success=true;
            msg=false;

            hd=get(this,'FDesign');

            spec=getSpecification(this,varargin{:});
            set(hd,'PulseShape',this.PulseShape);


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
                case 'ast,beta'
                    setspecs(hd,specs.SamplesPerSymbol,specs.Astop,specs.Beta);
                case 'n,beta'
                    setspecs(hd,specs.SamplesPerSymbol,specs.Order,specs.Beta);
                case 'nsym,beta'
                    setspecs(hd,specs.SamplesPerSymbol,specs.NumberOfSymbols,specs.Beta);
                case 'nsym,bt'
                    setspecs(hd,specs.SamplesPerSymbol,specs.NumberOfSymbols,specs.BT);
                otherwise
                    fprintf('Finish %s\n',spec);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)



            this.OrderMode2=s.OrderMode2;
            this.PulseShape=s.PulseShape;
            this.SamplesPerSymbol=s.SamplesPerSymbol;
            this.NumberOfSymbols=s.NumberOfSymbols;
            this.Beta=s.Beta;
            this.Astop=s.Astop;
            this.AstopSQRT=s.AstopSQRT;
            this.BT=s.BT;
            this.FrequencyConstraints=s.FrequencyConstraints;
            this.MagnitudeConstraints=s.MagnitudeConstraints;


        end


        function s=thissaveobj(this,s)



            s.OrderMode2=this.OrderMode2;
            s.PulseShape=this.PulseShape;
            s.SamplesPerSymbol=this.SamplesPerSymbol;
            s.NumberOfSymbols=this.NumberOfSymbols;
            s.Beta=this.Beta;
            s.Astop=this.Astop;
            s.AstopSQRT=this.AstopSQRT;
            s.BT=this.BT;
            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;


        end


        function fc=lcl_get_frequencyconstraints(this,fc)

            if isminorder(this)
                fc='Rolloff Factor';
            elseif strcmpi(this.PulseShape,'gaussian')
                fc='Bandwidth-Symbol Time Product';
            end
        end



        function mc=lcl_get_magnitudeconstraints(this,mc)

            if isminorder(this)
                mc='Stopband attenuation';
            end
        end


    end


    methods(Hidden)

        function hfdesign=createMultiRateVersion(~,hfdesign,ftype,...
            factor,secondfactor)



            if strcmpi(ftype,'single-rate')||~isfdtbxinstalled
                return;
            end

            hfdesign=getPSObj(hfdesign);

            switch lower(ftype)
            case 'decimator'
                hfdesign=fdesign.decimator(factor,hfdesign);
            case 'interpolator'
                hfdesign=fdesign.interpolator(factor,hfdesign);
            case 'sample-rate converter'
                hfdesign=fdesign.rsrc(factor,secondfactor,hfdesign);
            end


        end

        function orderMode=get_ordermode2(this,orderMode)

            if strcmpi(this.PulseShape,'gaussian')
                orderMode='Specify symbols';
            end
        end

    end

end



function Entries=getEntries(originalEntries)
    Entries=originalEntries;

    for i=1:length(originalEntries)
        indx=find(isspace(originalEntries{i}));
        Entries{i}(indx+1)=upper(Entries{i}(indx+1));
        Entries{i}(indx)=[];
        Entries{i}=FilterDesignDialog.message(Entries{i});
    end
end


