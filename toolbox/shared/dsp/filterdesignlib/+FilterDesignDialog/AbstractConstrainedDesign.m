classdef(CaseInsensitiveProperties)AbstractConstrainedDesign<FilterDesignDialog.AbstractDesign




    methods

        function constraintsID=getConstraintsID(this,longConstraint)%#ok<INUSL>



            switch lower(longConstraint)

            case 'passband edge and stopband edge'
                constraintsID='FpFst';

            case 'stopband edge and passband edge'
                constraintsID='FstFp';

            case 'passband and stopband edges'
                constraintsID='Fst1Fp1Fp2Fst2';

            case 'passband edge'
                constraintsID='Fp';

            case 'passband edges'
                constraintsID='Fp1Fp2';

            case 'passband edge and 3db point'
                constraintsID='FpF3dB';

            case 'stopband edge and 3db point'
                constraintsID='FstF3dB';

            case 'stopband edge'
                constraintsID='Fst';

            case 'stopband edges'
                constraintsID='Fst1Fst2';

            case '6db point'
                constraintsID='Fc';

            case '6db points'
                constraintsID='Fc1Fc2';

            case '3db point'
                constraintsID='F3dB';

            case '3db points'
                constraintsID='F3dB1F3dB2';

            case '3db point and stopband edge'
                constraintsID='F3dBFst';

            case '3db points and stopband width'
                constraintsID='F3dB1F3dB2BWst';

            case '3db point and passband edge'
                constraintsID='F3dBFp';

            case '3db points and passband width'
                constraintsID='F3dB1F3dB2BWp';

            case 'transition width'
                constraintsID='TW';

            case 'center frequency and quality factor'
                constraintsID='F0andQ';

            case 'center frequency and bandwidth'
                constraintsID='F0andBW';

            case 'center frequency, bandwidth, passband width'
                constraintsID='F0BWBWpass';

            case 'center frequency, bandwidth, stopband width'
                constraintsID='F0BWBWstop';

            case 'center frequency, bandwidth'
                constraintsID='F0BW';

            case 'center frequency, quality factor'
                constraintsID='F0Qa';

            case 'shelf type, cutoff frequency, quality factor'
                constraintsID='ShelfFcQa';

            case 'shelf type, cutoff frequency, shelf slope parameter'
                constraintsID='ShelfFcS';

            case 'low frequency, high frequency'
                constraintsID='FlowFhigh';

            case 'quality factor'
                constraintsID='Q';

            case 'bandwidth'
                constraintsID='BW';



            case 'unconstrained'
                constraintsID='unconstrained';

            case 'constrained bands'
                constraintsID='constrainedbands';

            case 'passband ripple and stopband attenuation'
                constraintsID='ApAst';

            case 'passband ripple and stopband attenuations'
                constraintsID='ApAst1Ast2';

            case 'passband ripples and stopband attenuation'
                constraintsID='Ap1Ap2Ast';

            case 'stopband attenuation and passband ripple'
                constraintsID='AstAp';

            case 'passband ripple'
                constraintsID='Ap';

            case 'stopband attenuation'
                constraintsID='Ast';

            case 'reference, center frequency, bandwidth, passband'
                constraintsID='GrefG0GBWGp';

            case 'reference, center frequency, bandwidth, stopband'
                constraintsID='GrefG0GWGst';

            case 'reference, center frequency, bandwidth, passband, stopband'
                constraintsID='GrefG0GBWGpGst';

            case 'reference, center frequency, bandwidth'
                constraintsID='GrefG0GBW';

            case 'reference, center frequency'
                constraintsID='GrefG0';

            case 'boost/cut'
                constraintsID='Gbc';


            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:AbstractConstrainedDesign:getConstraintsID:InternalError'));
            end




        end


        function items=getConstraintsWidgets(this,type,row)



            [constraints_lbl,constraints]=getWidgetSchema(this,...
            sprintf('%sConstraints',type),FilterDesignDialog.message([lower(type),'consts']),...
            'combobox',row,1);
            constraints.ColSpan=[2,4];
            constraints.DialogRefresh=true;
            if strcmpi(type,'Frequency')

                Freq=getValidFreqConstraints(this);
                FreqEntries=cell(1,length(Freq));

                for i=1:length(Freq)
                    FreqEntries{i}=FilterDesignDialog.message(getConstraintsID(this,Freq{i}));
                end

                constraints.Entries=FreqEntries;


                defaultindx=find(strcmpi(Freq,this.FrequencyConstraints));
                if~isempty(defaultindx)
                    constraints.Value=defaultindx-1;
                end

                constraints.ObjectMethod='selectComboboxEntry';
                constraints.MethodArgs={'%dialog','%value','FrequencyConstraints',Freq};
                constraints.ArgDataTypes={'handle','mxArray','string','mxArray'};



                constraints=rmfield(constraints,'ObjectProperty');
            else
                availableconstraints=getValidMagConstraints(this);
                MagEntries=cell(1,length(availableconstraints));

                for i=1:length(availableconstraints)
                    MagEntries{i}=FilterDesignDialog.message(...
                    getConstraintsID(this,availableconstraints{i}));
                end

                constraints.Entries=MagEntries;


                defaultindx=find(strcmpi(availableconstraints,this.MagnitudeConstraints));
                if~isempty(defaultindx)
                    constraints.Value=defaultindx-1;
                end
                constraints.ObjectMethod='selectComboboxEntry';
                constraints.MethodArgs={'%dialog','%value','MagnitudeConstraints',availableconstraints};
                constraints.ArgDataTypes={'handle','mxArray','string','mxArray'};



                constraints=rmfield(constraints,'ObjectProperty');
            end

            if isminorder(this)
                constraints_lbl.Visible=false;
                constraints.Visible=false;
            else
                constraints_lbl.Tunable=true;
                constraints.Tunable=true;
            end

            if~this.BuildUsingBasicElements
                constraints_lbl.Tunable=false;
                constraints.Tunable=false;
            end


            items={constraints_lbl,constraints};


        end


        function headerFrame=getHeaderFrame(this)



            [irtype_lbl,irtype]=getWidgetSchema(this,'ImpulseResponse',...
            FilterDesignDialog.message('impresp'),'combobox',1,1);
            irtype.Entries={...
            FilterDesignDialog.message('fir'),...
            FilterDesignDialog.message('iir')};
            irtype.DialogRefresh=true;
            irtype.Mode=true;

            orderwidgets=getOrderWidgets(this,2,true);

            if isDSTMode(this)
                ftypewidgets=getFilterTypeWidgets(this,3);
            end

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');

            if isDSTMode(this)
                headerFrame.Items={irtype_lbl,irtype,orderwidgets{:},ftypewidgets{:}};%#ok<CCAT>
                headerFrame.LayoutGrid=[3,4];
            else
                headerFrame.Items={irtype_lbl,irtype,orderwidgets{:}};%#ok<CCAT>
                headerFrame.LayoutGrid=[2,4];
            end
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function main=getMainFrame(this)




            header=getHeaderFrame(this);
            header.RowSpan=[1,1];
            header.ColSpan=[1,1];

            fspecs=getFrequencySpecsFrame(this);
            fspecs.RowSpan=[2,2];
            fspecs.ColSpan=[1,1];

            mspecs=getMagnitudeSpecsFrame(this);
            mspecs.RowSpan=[3,3];
            mspecs.ColSpan=[1,1];

            design=getDesignMethodFrame(this);
            design.RowSpan=[4,4];
            design.ColSpan=[1,1];

            if isFilterDesignerMode(this)
                main.Items={header,fspecs,mspecs,design};
                gridIdx=5;
                rowStretch=[0,0,0,0,3];
            else
                implem=getImplementationFrame(this);
                implem.RowSpan=[5,5];
                implem.ColSpan=[1,1];
                gridIdx=6;
                rowStretch=[0,0,0,0,0,3];
                main.Items={header,fspecs,mspecs,design,implem};
            end

            main.Type='panel';
            main.LayoutGrid=[gridIdx,1];
            main.RowStretch=rowStretch;
            main.Tag='MainPanel';


        end


        function set_frequencyconstraints(this,~)




            updateMagConstraints(this);


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
                this.FilterType='single-rate';
            end

            updateFreqConstraints(this);


        end


        function set_magnitudeconstraints(this,~)




            updateMethod(this);


        end


        function updateMagConstraints(this)




            validMagConstraints=getValidMagConstraints(this);



            if~any(strcmpi(this.MagnitudeConstraints,validMagConstraints))
                this.MagnitudeConstraints=validMagConstraints{1};
            else
                updateMethod(this);
            end


        end

    end


    methods(Hidden)

        function[items,colindx]=addConstraint(this,rowindx,colindx,items,...
            has,prop,label,tooltip)




            if~has
                return;
            end

            if nargin<7
                label=interspace(prop);
                label=[label(1),lower(label(2:end))];
            end

            tunable=~isminorder(this)&&this.BuildUsingBasicElements;

            spec_lbl.Name=label;
            spec_lbl.Type='text';
            spec_lbl.RowSpan=[rowindx,rowindx];
            spec_lbl.ColSpan=[colindx,colindx];
            spec_lbl.Tag=[prop,'Label'];
            spec_lbl.Tunable=tunable;

            if nargin>7
                spec_lbl.ToolTip=tooltip;
            end

            items=[items,{spec_lbl}];
            colindx=colindx+1;


            spec.Type='edit';
            spec.RowSpan=[rowindx,rowindx];
            spec.ColSpan=[colindx,colindx];
            spec.ObjectProperty=prop;
            spec.Source=this;
            spec.Mode=true;
            spec.Tag=prop;
            spec.Tunable=tunable;

            colindx=colindx+1;

            items=[items,{spec}];


        end


        function updateFreqConstraints(this)




            validConstraints=getValidFreqConstraints(this);




            if~any(strcmpi(this.FrequencyConstraints,validConstraints))&&...
                ~any(strcmpi(this.privFrequencyConstraints,validConstraints))
                this.FrequencyConstraints=validConstraints{1};
            else
                updateMagConstraints(this);
            end
        end

    end

end

