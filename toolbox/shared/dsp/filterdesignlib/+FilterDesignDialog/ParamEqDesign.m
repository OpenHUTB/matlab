classdef(CaseInsensitiveProperties)ParamEqDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(AbortSet,SetObservable,GetObservable)

        F0='0.5';

        BW='0.3';

        BWpass='0.2';

        BWstop='0.4';

        Flow='0.4';

        Fhigh='0.6';

        Gref='-10';

        G0='0';

        GBW='db(sqrt(.5))';

        Gpass='-1';

        Gstop='-9';

        Gbc='10';

        Qa='10';

        S='2';

        Fc='0.25';

        ShelfType='lowpass';
    end

    properties(AbortSet,SetObservable,GetObservable,Dependent)







        FrequencyConstraints;






        MagnitudeConstraints;
    end

    properties(Hidden,AbortSet,SetObservable,GetObservable)







        privFrequencyConstraints='Center frequency, bandwidth, passband width';






        privMagnitudeConstraints='Reference, center frequency, bandwidth, passband';
    end

    properties(Hidden,Constant)

        FrequencyConstraintsSet=...
        {'Center frequency, bandwidth, passband width',...
        'Center frequency, bandwidth, stopband width',...
        'Center frequency, bandwidth',...
        'Center frequency, quality factor',...
        'Shelf type, cutoff frequency, quality factor',...
        'Shelf type, cutoff frequency, shelf slope parameter',...
        'Low frequency, high frequency'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('F0BWBWpass'),...
        FilterDesignDialog.message('F0BWBWstop'),...
        FilterDesignDialog.message('F0BW'),...
        FilterDesignDialog.message('F0Qa'),...
        FilterDesignDialog.message('ShelfFcQa'),...
        FilterDesignDialog.message('ShelfFcS'),...
        FilterDesignDialog.message('FlowFhigh')};


        MagnitudeConstraintsSet=...
        {'Reference, center frequency, bandwidth, passband',...
        'Reference, center frequency, bandwidth, stopband',...
        'Reference, center frequency, bandwidth, passband, stopband',...
        'Reference, center frequency, bandwidth',...
        'Reference, center frequency',...
        'Boost/cut'}
        MagnitudeConstraintsEntries={FilterDesignDialog.message('GrefG0GBWGpGst'),...
        FilterDesignDialog.message('GrefG0GWGst'),...
        FilterDesignDialog.message('GrefG0GBWGpGst'),...
        FilterDesignDialog.message('GrefG0GBW'),...
        FilterDesignDialog.message('GrefG0'),...
        FilterDesignDialog.message('Gbc')};

    end


    methods
        function this=ParamEqDesign(varargin)

            w=warning('off','dsp:fdesign:basecatalog:parameq_NotSupported');
            restoreWarn=onCleanup(@()warning(w));
            this.VariableName=uiservices.getVariableName('Hpe');
            this.Order='10';
            this.ImpulseResponse='IIR';

            if~isempty(varargin)
                set(this,varargin{:});
            end

            set(this,'FDesign',fdesign.parameq);
            updateMethod(this);


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);
        end
    end

    methods
        function set.F0(obj,value)

            validateattributes(value,{'char'},{'row'},'','F0')
            obj.F0=value;
        end

        function set.BW(obj,value)

            validateattributes(value,{'char'},{'row'},'','BW')
            obj.BW=value;
        end

        function set.BWpass(obj,value)

            validateattributes(value,{'char'},{'row'},'','BWpass')
            obj.BWpass=value;
        end

        function set.BWstop(obj,value)

            validateattributes(value,{'char'},{'row'},'','BWstop')
            obj.BWstop=value;
        end

        function set.Flow(obj,value)

            validateattributes(value,{'char'},{'row'},'','Flow')
            obj.Flow=value;
        end

        function set.Fhigh(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fhigh')
            obj.Fhigh=value;
        end

        function set.Gref(obj,value)

            validateattributes(value,{'char'},{'row'},'','Gref')
            obj.Gref=value;
        end

        function set.G0(obj,value)

            validateattributes(value,{'char'},{'row'},'','G0')
            obj.G0=value;
        end

        function set.GBW(obj,value)

            validateattributes(value,{'char'},{'row'},'','GBW')
            obj.GBW=value;
        end

        function set.Gpass(obj,value)

            validateattributes(value,{'char'},{'row'},'','Gpass')
            obj.Gpass=value;
        end

        function set.Gstop(obj,value)

            validateattributes(value,{'char'},{'row'},'','Gstop')
            obj.Gstop=value;
        end

        function set.Gbc(obj,value)

            validateattributes(value,{'char'},{'row'},'','Gbc')
            obj.Gbc=value;
        end

        function set.Qa(obj,value)

            validateattributes(value,{'char'},{'row'},'','Qa')
            obj.Qa=value;
        end

        function set.S(obj,value)

            validateattributes(value,{'char'},{'row'},'','S')
            obj.S=value;
        end

        function set.Fc(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fc')
            obj.Fc=value;
        end

        function set.ShelfType(obj,value)

            validateattributes(value,{'char'},{'row'},'','ShelfType')
            obj.ShelfType=value;
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






            value=validatestring(value,obj.MagnitudeConstraintsSet,'','MagnitudeConstraints');
            oldMagConstraints=obj.privMagnitudeConstraints;
            obj.privMagnitudeConstraints=value;
            set_magnitudeconstraints(obj,oldMagConstraints)
        end
    end

    methods


        function set_frequencyconstraints(this,oldFreqConstraints)









            if strncmp(oldFreqConstraints,'Shelf type',10)&&...
                ~strncmp(this.FrequencyConstraints,'Shelf type',10)
                this.FDesign.F0=.5;
            end

            updateMagConstraints(this);

        end


        function set_magnitudeconstraints(this,~)


            updateMethod(this);

        end


        function dialogTitle=getDialogTitle(~)

            dialogTitle=FilterDesignDialog.message('ParamEq');
        end


        function fspecs=getFrequencySpecsFrame(this)



            items=getConstraintsWidgets(this,'Frequency',1);
            items{1}.Visible=true;
            items{2}.Visible=true;


            items=getFrequencyUnitsWidgets(this,2,items);


            switch lower(this.FrequencyConstraints)
            case 'center frequency, bandwidth, passband width'
                items=addConstraint(this,3,1,items,true,'F0',FilterDesignDialog.message('F0'));
                items=addConstraint(this,3,3,items,true,'BW',FilterDesignDialog.message('BW'));
                items=addConstraint(this,4,1,items,true,'BWpass',FilterDesignDialog.message('BWpass'));
            case 'center frequency, bandwidth, stopband width'
                items=addConstraint(this,3,1,items,true,'F0',FilterDesignDialog.message('F0'));
                items=addConstraint(this,3,3,items,true,'BW',FilterDesignDialog.message('BW'));
                items=addConstraint(this,4,1,items,true,'BWstop',FilterDesignDialog.message('BWstop'));
            case 'center frequency, bandwidth'
                items=addConstraint(this,3,1,items,true,'F0',FilterDesignDialog.message('F0'));
                items=addConstraint(this,3,3,items,true,'BW',FilterDesignDialog.message('BW'));
            case 'center frequency, quality factor'
                items=addConstraint(this,3,1,items,true,'F0',FilterDesignDialog.message('F0'));
                items=addConstraint(this,3,3,items,true,'Qa',FilterDesignDialog.message('Q'));
            case 'shelf type, cutoff frequency, quality factor'


                items=getShelfTypeWidget(this,items,3,1);
                items=addConstraint(this,3,3,items,true,'Qa',FilterDesignDialog.message('Q'));
                items=addConstraint(this,4,1,items,true,'Fc',FilterDesignDialog.message('Fcutoff'));
            case 'shelf type, cutoff frequency, shelf slope parameter'


                items=getShelfTypeWidget(this,items,3,1);

                items=addConstraint(this,3,3,items,true,'S',FilterDesignDialog.message('S'));
                items=addConstraint(this,4,1,items,true,'Fc',FilterDesignDialog.message('Fcutoff'));
            case 'low frequency, high frequency'
                items=addConstraint(this,3,1,items,true,'Flow',FilterDesignDialog.message('Flow'));
                items=addConstraint(this,3,3,items,true,'Fhigh',FilterDesignDialog.message('Fhigh'));
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




            items=getOrderWidgets(this,2,true);

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');
            headerFrame.Items=items;
            headerFrame.LayoutGrid=[3,4];
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('ParamEqDesignHelpTxt');
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function mspecs=getMagnitudeSpecsFrame(this)



            items=getConstraintsWidgets(this,'Magnitude',1);
            items{1}.Name=FilterDesignDialog.message('gainconstraints');
            items{1}.Visible=true;
            items{2}.Visible=true;


            [mag_lbl,mag]=getWidgetSchema(this,'MagnitudeUnits',...
            FilterDesignDialog.message('gainunits'),'combobox',2,1);
            mag_lbl.Tunable=true;
            mag.DialogRefresh=true;
            mag.Entries=FilterDesignDialog.message({'dB'});
            mag.Tunable=true;
            items={items{:},mag_lbl,mag};%#ok<CCAT>


            switch lower(this.MagnitudeConstraints)
            case 'reference, center frequency, bandwidth, passband'
                items=addConstraint(this,3,1,items,true,'Gref',FilterDesignDialog.message('Gref'));
                items=addConstraint(this,3,3,items,true,'G0',FilterDesignDialog.message('G0'));
                items=addConstraint(this,4,1,items,true,'GBW',FilterDesignDialog.message('GBW'));
                items=addConstraint(this,4,3,items,true,'Gpass',FilterDesignDialog.message('Gpass'));
            case 'reference, center frequency, bandwidth, stopband'
                items=addConstraint(this,3,1,items,true,'Gref',FilterDesignDialog.message('Gref'));
                items=addConstraint(this,3,3,items,true,'G0',FilterDesignDialog.message('G0'));
                items=addConstraint(this,4,1,items,true,'GBW',FilterDesignDialog.message('GBW'));
                items=addConstraint(this,4,3,items,true,'Gstop',FilterDesignDialog.message('Gstop'));
            case 'reference, center frequency, bandwidth, passband, stopband'
                items=addConstraint(this,3,1,items,true,'Gref',FilterDesignDialog.message('Gref'));
                items=addConstraint(this,3,3,items,true,'G0',FilterDesignDialog.message('G0'));
                items=addConstraint(this,4,1,items,true,'GBW',FilterDesignDialog.message('GBW'));
                items=addConstraint(this,4,3,items,true,'Gpass',FilterDesignDialog.message('Gpass'));
                items=addConstraint(this,5,1,items,true,'Gstop',FilterDesignDialog.message('Gstop'));
            case 'reference, center frequency, bandwidth'
                items=addConstraint(this,3,1,items,true,'Gref',FilterDesignDialog.message('Gref'));
                items=addConstraint(this,3,3,items,true,'G0',FilterDesignDialog.message('G0'));
                items=addConstraint(this,4,1,items,true,'GBW',FilterDesignDialog.message('GBW'));
            case 'reference, center frequency'
                items=addConstraint(this,3,1,items,true,'Gref',FilterDesignDialog.message('Gref'));
                items=addConstraint(this,3,3,items,true,'G0',FilterDesignDialog.message('G0'));
            case 'boost/cut'

                items=addConstraint(this,3,1,items,true,'Gbc',FilterDesignDialog.message('Gboostcut'));
            end

            mspecs.Name=FilterDesignDialog.message('gainspecs');
            mspecs.Type='group';
            mspecs.Items=items;
            mspecs.LayoutGrid=[6,4];
            mspecs.RowStretch=[0,0,0,0,0,1];
            mspecs.ColStretch=[0,1,0,1];
            mspecs.Tag='MagSpecsGroup';


        end


        function specification=getSpecification(this,laState)



            if nargin>1&&~isempty(laState)
                freqcons=laState.FrequencyConstraints;
                magcons=laState.MagnitudeConstraints;
            else
                freqcons=this.FrequencyConstraints;
                magcons=this.MagnitudeConstraints;
            end

            switch lower(freqcons)
            case 'center frequency, bandwidth, passband width'
                specification='F0,BW,BWp';
            case 'center frequency, bandwidth, stopband width'
                specification='F0,BW,BWst';
            case 'center frequency, bandwidth'
                specification='N,F0,BW';
            case 'center frequency, quality factor'
                specification='N,F0,Qa';
            case 'shelf type, cutoff frequency, quality factor'
                specification='N,F0,Fc,Qa';
            case 'shelf type, cutoff frequency, shelf slope parameter'
                specification='N,F0,Fc,S';
            case 'low frequency, high frequency'
                specification='N,Flow,Fhigh';
            end

            switch lower(magcons)
            case 'reference, center frequency, bandwidth, passband'
                specification=sprintf('%s,Gref,G0,GBW,Gp',specification);
            case 'reference, center frequency, bandwidth, stopband'
                specification=sprintf('%s,Gref,G0,GBW,Gst',specification);
            case 'reference, center frequency, bandwidth, passband, stopband'
                specification=sprintf('%s,Gref,G0,GBW,Gp,Gst',specification);
            case 'reference, center frequency, bandwidth'
                specification=sprintf('%s,Gref,G0,GBW',specification);
            case 'reference, center frequency'
                specification=sprintf('%s,Gref,G0',specification);
            case 'boost/cut'
                specification=sprintf('%s,G0',specification);
            end


        end


        function specs=getSpecs(this,varargin)



            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            specs.Scale=this.Scale;
            specs.ForceLeadingNumerator=strcmpi(this.ForceLeadingNumerator,'on');

            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');

            specs.Gref=evaluatevars(source.Gref);
            specs.G0=evaluatevars(source.G0);
            specs.GBW=evaluatevars(source.GBW);

            spec=getSpecification(this,source);

            switch lower(spec)
            case 'f0,bw,bwp,gref,g0,gbw,gp'
                specs.F0=getnum(this,source,'F0');
                specs.BW=getnum(this,source,'BW');
                specs.BWpass=getnum(this,source,'BWpass');
                specs.Gpass=evaluatevars(source.Gpass);
            case 'f0,bw,bwst,gref,g0,gbw,gst'
                specs.F0=getnum(this,source,'F0');
                specs.BW=getnum(this,source,'BW');
                specs.BWstop=getnum(this,source,'BWstop');
                specs.Gstop=evaluatevars(source.Gstop);
            case 'f0,bw,bwp,gref,g0,gbw,gp,gst'
                specs.F0=getnum(this,source,'F0');
                specs.BW=getnum(this,source,'BW');
                specs.BWpass=getnum(this,source,'BWpass');
                specs.Gpass=evaluatevars(source.Gpass);
                specs.Gstop=evaluatevars(source.Gstop);
            case 'n,f0,bw,gref,g0,gbw'
                specs.Order=evaluatevars(source.Order);
                specs.F0=getnum(this,source,'F0');
                specs.BW=getnum(this,source,'BW');
            case 'n,f0,bw,gref,g0,gbw,gp'
                specs.Order=evaluatevars(source.Order);
                specs.F0=getnum(this,source,'F0');
                specs.BW=getnum(this,source,'BW');
                specs.Gpass=evaluatevars(source.Gpass);
            case 'n,f0,bw,gref,g0,gbw,gst'
                specs.Order=evaluatevars(source.Order);
                specs.F0=getnum(this,source,'F0');
                specs.BW=getnum(this,source,'BW');
                specs.Gpass=evaluatevars(source.Gpass);
                specs.Gstop=evaluatevars(source.Gstop);
            case 'n,f0,bw,gref,g0,gbw,gp,gst'
                specs.Order=evaluatevars(source.Order);
                specs.F0=getnum(this,source,'F0');
                specs.BW=getnum(this,source,'BW');
                specs.Gpass=evaluatevars(source.Gpass);
                specs.Gstop=evaluatevars(source.Gstop);
            case 'n,f0,qa,gref,g0'
                specs.Order=evaluatevars(source.Order);
                specs.F0=getnum(this,source,'F0');
                specs.Qa=evaluatevars(source.Qa);
            case 'n,f0,fc,qa,g0'


                if strcmpi(source.ShelfType,'lowpass')
                    specs.F0=0;
                else
                    specs.F0=specs.InputSampleRate/2;
                end
                specs.Order=evaluatevars(source.Order);
                specs.Fc=getnum(this,source,'Fc');
                specs.Qa=evaluatevars(source.Qa);

                specs.G0=evaluatevars(source.Gbc);
            case 'n,f0,fc,s,g0'


                if strcmpi(source.ShelfType,'lowpass')
                    specs.F0=0;
                else
                    specs.F0=specs.InputSampleRate/2;
                end
                specs.Order=evaluatevars(source.Order);
                specs.Fc=getnum(this,source,'Fc');
                specs.S=evaluatevars(source.S);

                specs.G0=evaluatevars(source.Gbc);
            case 'n,flow,fhigh,gref,g0,gbw'
                specs.Order=evaluatevars(source.Order);
                specs.Flow=getnum(this,source,'Flow');
                specs.Fhigh=getnum(this,source,'Fhigh');
            case 'n,flow,fhigh,gref,g0,gbw,gp'
                specs.Order=evaluatevars(source.Order);
                specs.Flow=getnum(this,source,'Flow');
                specs.Fhigh=getnum(this,source,'Fhigh');
                specs.Gpass=evaluatevars(source.Gpass);
            case 'n,flow,fhigh,gref,g0,gbw,gst'
                specs.Order=evaluatevars(source.Order);
                specs.Flow=getnum(this,source,'Flow');
                specs.Fhigh=getnum(this,source,'Fhigh');
                specs.Gstop=evaluatevars(source.Gstop);
            case 'n,flow,fhigh,gref,g0,gbw,gp,gst'
                specs.Order=evaluatevars(source.Order);
                specs.Flow=getnum(this,source,'Flow');
                specs.Fhigh=getnum(this,source,'Fhigh');
                specs.Gpass=evaluatevars(source.Gpass);
                specs.Gstop=evaluatevars(source.Gstop);
            otherwise
                fprintf('Finish %s',spec);
            end


        end


        function validFreqConstraints=getValidFreqConstraints(this)



            validFreqConstraints=this.FrequencyConstraintsSet;

            if isminorder(this)
                validFreqConstraints=validFreqConstraints(1:2);
            else
                validFreqConstraints=validFreqConstraints(3:7);
            end


        end


        function validMagConstraints=getValidMagConstraints(this)



            validMagConstraints=this.MagnitudeConstraintsSet;

            switch lower(this.FrequencyConstraints)
            case 'center frequency, bandwidth, passband width'
                validMagConstraints=validMagConstraints([1,3]);
            case 'center frequency, bandwidth, stopband width'
                validMagConstraints=validMagConstraints(2);
            case 'center frequency, bandwidth'
                validMagConstraints=validMagConstraints([1,2,3,4]);
            case 'low frequency, high frequency'
                validMagConstraints=validMagConstraints([1,2,3,4]);
            case 'center frequency, quality factor'
                validMagConstraints=validMagConstraints(5);
            case 'shelf type, cutoff frequency, quality factor'
                validMagConstraints=validMagConstraints(6);
            case 'shelf type, cutoff frequency, shelf slope parameter'
                validMagConstraints=validMagConstraints(6);
            end


        end


        function b=setGUI(this,Hd)



            b=true;
            hfdesign=getfdesign(Hd);
            if~strcmpi(get(hfdesign,'Response'),'parametric equalizer')
                b=false;
                return;
            end

            switch hfdesign.Specification
            case 'F0,BW,BWp,Gref,G0,GBW,Gp'
                set(this,...
                'FrequencyConstraints','Center frequency, bandwidth, passband width',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth, passband',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'BWpass',num2str(hfdesign.BWpass),...
                'Gref',num2str(hfdesign.Gref),...
                'G0',num2str(hfdesign.G0),...
                'GBW',num2str(hfdesign.GBW),...
                'Gpass',num2str(hfdesign.Gpass));
            case 'F0,BW,BWst,Gref,G0,GBW,Gst'
                set(this,...
                'FrequencyConstraints','Center frequency, bandwidth, stopband width',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth, stopband',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'BWstop',num2str(hfdesign.BWstop),...
                'Gref',num2str(hfdesign.Gref),...
                'G0',num2str(hfdesign.G0),...
                'GBW',num2str(hfdesign.GBW),...
                'Gstop',num2str(hfdesign.Gstop));
            case 'F0,BW,BWp,Gref,G0,GBW,Gp,Gst'
                set(this,...
                'FrequencyConstraints','Center frequency, bandwidth, passband width',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth, passband, stopband',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'BWpass',num2str(hfdesign.BWpass),...
                'Gref',num2str(hfdesign.Gref),...
                'G0',num2str(hfdesign.G0),...
                'GBW',num2str(hfdesign.GBW),...
                'Gpass',num2str(hfdesign.Gpass),...
                'Gstop',num2str(hfdesign.Gstop));
            case 'N,F0,BW,Gref,G0,GBW'
                set(this,...
                'FrequencyConstraints','Center frequency, bandwidth',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'Gref',num2str(hfdesign.Gref),...
                'G0',num2str(hfdesign.G0),...
                'GBW',num2str(hfdesign.GBW));
            case 'N,F0,BW,Gref,G0,GBW,Gp'
                set(this,...
                'FrequencyConstraints','Center frequency, bandwidth',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth, passband',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'Gref',num2str(hfdesign.Gref),...
                'G0',num2str(hfdesign.G0),...
                'GBW',num2str(hfdesign.GBW),...
                'Gpass',num2str(hfdesign.Gpass));
            case 'N,F0,BW,Gref,G0,GBW,Gst'
                set(this,...
                'FrequencyConstraints','Center frequency, bandwidth',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth, stopband',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'Gref',num2str(hfdesign.Gref),...
                'G0',num2str(hfdesign.G0),...
                'GBW',num2str(hfdesign.GBW),...
                'Gstop',num2str(hfdesign.Gstop));
            case 'N,F0,BW,Gref,G0,GBW,Gp,Gst'
                set(this,...
                'FrequencyConstraints','Center frequency, bandwidth',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth, passband, stopband',...
                'F0',num2str(hfdesign.F0),...
                'BW',num2str(hfdesign.BW),...
                'Gref',num2str(hfdesign.Gref),...
                'G0',num2str(hfdesign.G0),...
                'GBW',num2str(hfdesign.GBW),...
                'Gpass',num2str(hfdesign.Gpass),...
                'Gstop',num2str(hfdesign.Gstop));
            case 'N,F0,Qa,Gref,G0'
                set(this,...
                'FrequencyConstraints','Center frequency, quality factor',...
                'MagnitudeConstraints','Reference, center frequency',...
                'F0',num2str(hfdesign.F0),...
                'Qa',num2str(hfdesign.Qa),...
                'Gref',num2str(hfdesign.Gref),...
                'G0',num2str(hfdesign.G0));
            case 'N,F0,Fc,Qa,G0'
                if isequal(hfdesign.F0,0)
                    st='Lowpass';
                else
                    st='Highpass';
                end
                set(this,...
                'FrequencyConstraints','Shelf type, cutoff frequency, quality factor',...
                'MagnitudeConstraints','Boost/cut',...
                'ShelfType',st,...
                'Fc',num2str(hfdesign.Fc),...
                'Qa',num2str(hfdesign.Qa),...
                'Gbc',num2str(hfdesign.G0));
            case 'N,F0,Fc,S,G0'
                if isequal(hfdesign.F0,0)
                    st='Lowpass';
                else
                    st='Highpass';
                end
                set(this,...
                'FrequencyConstraints','Shelf type, cutoff frequency, shelf slope parameter',...
                'MagnitudeConstraints','Boost/cut',...
                'ShelfType',st,...
                'Fc',num2str(hfdesign.Fc),...
                'S',num2str(hfdesign.S),...
                'Gbc',num2str(hfdesign.G0));
            case 'N,Flow,Fhigh,Gref,G0,GBW'
                set(this,...
                'FrequencyConstraints','Low frequency, high frequency',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth',...
                'Flow',num2str(hfdesign.Flow),...
                'Fhigh',num2str(hfdesign.Fhigh));
            case 'N,Flow,Fhigh,Gref,G0,GBW,Gp'
                set(this,...
                'FrequencyConstraints','Low frequency, high frequency',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth, passband',...
                'Flow',num2str(hfdesign.Flow),...
                'Fhigh',num2str(hfdesign.Fhigh),...
                'Gpass',num2str(hfdesign.Gpass));
            case 'N,Flow,Fhigh,Gref,G0,GBW,Gst'
                set(this,...
                'FrequencyConstraints','Low frequency, high frequency',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth, stopband',...
                'Flow',num2str(hfdesign.Flow),...
                'Fhigh',num2str(hfdesign.Fhigh),...
                'Gstop',num2str(hfdesign.Gstop));
            case 'N,Flow,Fhigh,Gref,G0,GBW,Gp,Gst'
                set(this,...
                'FrequencyConstraints','Low frequency, high frequency',...
                'MagnitudeConstraints','Reference, center frequency, bandwidth, passband, stopband',...
                'Flow',num2str(hfdesign.Flow),...
                'Fhigh',num2str(hfdesign.Fhigh),...
                'Gpass',num2str(hfdesign.Gpass),...
                'Gstop',num2str(hfdesign.Gstop));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:ParamEqDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function set_ordermode(this)




            updateFreqConstraints(this);


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
                case 'f0,bw,bwp,gref,g0,gbw,gp'
                    setspecs(hd,specs.F0,specs.BW,specs.BWpass,specs.Gref,...
                    specs.G0,specs.GBW,specs.Gpass);
                case 'f0,bw,bwst,gref,g0,gbw,gst'
                    setspecs(hd,specs.F0,specs.BW,specs.BWstop,specs.Gref,...
                    specs.G0,specs.GBW,specs.Gstop);
                case 'f0,bw,bwp,gref,g0,gbw,gp,gst'
                    setspecs(hd,specs.F0,specs.BW,specs.BWpass,specs.Gref,...
                    specs.G0,specs.GBW,specs.Gpass,specs.Gstop);
                case 'n,f0,bw,gref,g0,gbw'
                    setspecs(hd,specs.Order,specs.F0,specs.BW,specs.Gref,...
                    specs.G0,specs.GBW);
                case 'n,f0,bw,gref,g0,gbw,gp'
                    setspecs(hd,specs.Order,specs.F0,specs.BW,specs.Gref,...
                    specs.G0,specs.GBW,specs.Gpass);
                case 'n,f0,bw,gref,g0,gbw,gst'
                    setspecs(hd,specs.Order,specs.F0,specs.BW,specs.Gref,...
                    specs.G0,specs.GBW,specs.Gstop);
                case 'n,f0,bw,gref,g0,gbw,gp,gst'
                    setspecs(hd,specs.Order,specs.F0,specs.BW,specs.Gref,...
                    specs.G0,specs.GBW,specs.Gpass,specs.Gstop);
                case 'n,f0,qa,gref,g0'
                    setspecs(hd,specs.Order,specs.F0,specs.Qa,specs.Gref,...
                    specs.G0);
                case 'n,f0,fc,qa,g0'
                    setspecs(hd,specs.Order,specs.F0,specs.Fc,specs.Qa,...
                    specs.G0);
                case 'n,f0,fc,s,g0'
                    setspecs(hd,specs.Order,specs.F0,specs.Fc,specs.S,...
                    specs.G0);
                case 'n,flow,fhigh,gref,g0,gbw'
                    setspecs(hd,specs.Order,specs.Flow,specs.Fhigh,specs.Gref,...
                    specs.G0,specs.GBW);
                case 'n,flow,fhigh,gref,g0,gbw,gp'
                    setspecs(hd,specs.Order,specs.Flow,specs.Fhigh,specs.Gref,...
                    specs.G0,specs.GBW,specs.Gpass);
                case 'n,flow,fhigh,gref,g0,gbw,gst'
                    setspecs(hd,specs.Order,specs.Flow,specs.Fhigh,specs.Gref,...
                    specs.G0,specs.GBW,specs.Gstop);
                case 'n,flow,fhigh,gref,g0,gbw,gp,gst'
                    setspecs(hd,specs.Order,specs.Flow,specs.Fhigh,specs.Gref,...
                    specs.G0,specs.GBW,specs.Gpass,specs.Gstop);
                otherwise
                    fprintf('Finish %s\n',spec);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)




            this.F0=s.F0;
            this.BW=s.BW;
            this.BWpass=s.BWpass;
            this.BWstop=s.BWstop;
            this.Flow=s.Flow;
            this.Fhigh=s.Fhigh;
            this.Gref=s.Gref;
            this.G0=s.G0;
            this.GBW=s.GBW;
            this.Gpass=s.Gpass;
            this.Gstop=s.Gstop;

            if isfield(s,'FrequencyConstraints')
                this.FrequencyConstraints=s.FrequencyConstraints;
                this.MagnitudeConstraints=s.MagnitudeConstraints;

                if~isfield(s,'ShelfType')
                    if strncmp(s.FrequencyConstraints,'Shelf type',10)
                        this.ShelfType='Lowpass';
                    end
                else
                    this.ShelfType=s.ShelfType;
                end
            end


        end


        function s=thissaveobj(this,s)




            s.F0=this.F0;
            s.BW=this.BW;
            s.BWpass=this.BWpass;
            s.BWstop=this.BWstop;
            s.Flow=this.Flow;
            s.Fhigh=this.Fhigh;
            s.Gref=this.Gref;
            s.G0=this.G0;
            s.GBW=this.GBW;
            s.Gpass=this.Gpass;
            s.Gstop=this.Gstop;

            s.FrequencyConstraints=this.FrequencyConstraints;
            s.MagnitudeConstraints=this.MagnitudeConstraints;

            s.ShelfType=this.ShelfType;


        end


        function items=getShelfTypeWidget(this,items,row,col)

            [shelf_lbl,shelf]=getWidgetSchema(this,'ShelfType',...
            FilterDesignDialog.message('ShelfType'),'combobox',row,col);
            shelf_lbl.Tunable=true;
            shelf.DialogRefresh=true;
            options={'Lowpass','Highpass'};
            shelf.Entries=FilterDesignDialog.message({'lp','hp'});
            shelf.Tunable=true;


            indx=find(strcmpi(options,this.ShelfType));
            if~isempty(indx)
                shelf.Value=indx-1;
            end
            shelf.ObjectMethod='selectComboboxEntry';
            shelf.MethodArgs={'%dialog','%value','ShelfType',options};
            shelf.ArgDataTypes={'handle','mxArray','string','mxArray'};



            shelf.Mode=false;



            shelf=rmfield(shelf,'ObjectProperty');

            items={items{:},shelf_lbl,shelf};%#ok<CCAT>
        end

    end

end



