classdef(CaseInsensitiveProperties,Abstract)AbstractNyquistDesign<FilterDesignDialog.AbstractConstrainedDesign




    properties(SetObservable)

        TransitionWidth='.1';

        Astop='80';
    end

    properties(Dependent)



        FrequencyConstraints;



        MagnitudeConstraints;
    end

    properties(SetObservable,Hidden)



        privFrequencyConstraints='Unconstrained';



        privMagnitudeConstraints='Unconstrained';
    end

    properties(Constant,Hidden)

        FrequencyConstraintsSet={'Unconstrained','Transition width'};
        FrequencyConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('TW')};

        MagnitudeConstraintsSet={'Unconstrained','Stopband attenuation'};
        MagnitudeConstraintsEntries={FilterDesignDialog.message('unconstrained'),...
        FilterDesignDialog.message('Ast')};

    end

    methods
        function set.TransitionWidth(obj,value)

            validateattributes(value,{'char'},{'row'},'','TransitionWidth')
            obj.TransitionWidth=value;
        end

        function set.Astop(obj,value)

            validateattributes(value,{'char'},{'row'},'','Astop')
            obj.Astop=value;
        end

        function value=get.FrequencyConstraints(obj)
            value=lcl_get_frequencyconstraints(obj,obj.privFrequencyConstraints);
        end
        function set.FrequencyConstraints(obj,value)


            value=validatestring(value,obj.FrequencyConstraintsSet,'','FrequencyConstraints');
            obj.privFrequencyConstraints=value;
            set_frequencyconstraints(obj);
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

        function fspecs=getFrequencySpecsFrame(this)





            items=getConstraintsWidgets(this,'Frequency',1);

            items=getFrequencyUnitsWidgets(this,2,items);


            if strcmpi(this.FrequencyConstraints,'transition width')

                items=addConstraint(this,3,1,items,true,...
                'TransitionWidth',FilterDesignDialog.message('TWLabel'),'Transition width');
            else


                spacer.Name=' ';
                spacer.Type='text';
                spacer.ColSpan=[1,1];
                spacer.RowSpan=[3,3];
                spacer.Tag='Spacer';

                items={items{:},spacer};%#ok<CCAT>

                spacer.RowSpan=[3,3];

                items={items{:},spacer};%#ok<CCAT>
            end

            fspecs.Name=FilterDesignDialog.message('freqspecs');
            fspecs.Type='group';
            fspecs.Items=items;
            fspecs.LayoutGrid=[4,4];
            fspecs.RowStretch=[0,0,0,1];
            fspecs.ColStretch=[0,1,0,1];
            fspecs.Tag='FreqSpecsGroup';


        end


        function mspecs=getMagnitudeSpecsFrame(this)




            items=getConstraintsWidgets(this,'Magnitude',1);



            if strcmpi(this.MagnitudeConstraints,'stopband attenuation')

                items=getMagnitudeUnitsWidgets(this,2,items);

                items=addConstraint(this,3,1,items,true,...
                'Astop',FilterDesignDialog.message('Astop'),'Stopband attenuation');
            else


                spacer.Name=' ';
                spacer.Type='text';
                spacer.ColSpan=[1,1];
                spacer.RowSpan=[2,2];
                spacer.Tag='Spacer';

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




            if nargin<2
                laState=this;
            end

            if isminorder(this,laState)
                specification='tw,ast';
            else

                freqcons=laState.FrequencyConstraints;
                magcons=laState.MagnitudeConstraints;

                specification='n';

                if strcmpi(freqcons,'transition width')
                    specification=[specification,',tw'];
                end

                if strcmpi(magcons,'stopband attenuation')
                    specification=[specification,',ast'];
                end
            end


        end


        function validFreqConstraints=getValidFreqConstraints(this)





            validFreqConstraints=this.FrequencyConstraintsSet;


        end


        function availableconstraints=getValidMagConstraints(this,fconstraints)




            if isminorder(this)
                availableconstraints={'Stopband attenuation'};
                return;
            end

            if nargin<2
                fconstraints=get(this,'FrequencyConstraints');
            end

            switch lower(fconstraints)
            case 'unconstrained'
                availableconstraints={'Unconstrained','Stopband attenuation'};
            case 'transition width'
                availableconstraints={'Unconstrained'};
            end


        end


        function setGUI(this,Hd)




            abstractnyquist_setGUI(this,Hd);


        end


        function[success,msg]=setupFDesign(this,varargin)




            success=true;
            msg='';

            hd=this.FDesign;

            if isempty(hd)
                return;
            end

            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            spec=getSpecification(this,source);



            set(hd,'Specification',...
            validatestring(spec,hd.getAllowedStringValues('Specification')));

            setupFDesignTypes(this);

            try
                specs=getSpecs(this,source);

                if strncmpi(specs.FrequencyUnits,'normalized',10)
                    normalizefreq(hd);
                else
                    normalizefreq(hd,false,specs.InputSampleRate);
                end

                switch spec
                case 'tw,ast'
                    setspecs(hd,specs.Band{:},specs.TransitionWidth,...
                    specs.Astop,specs.MagnitudeUnits);
                case 'n,tw'
                    setspecs(hd,specs.Band{:},specs.Order,specs.TransitionWidth);
                case 'n'
                    setspecs(hd,specs.Band{:},specs.Order);
                case 'n,ast'
                    setspecs(hd,specs.Band{:},specs.Order,specs.Astop,specs.MagnitudeUnits);
                otherwise
                    fprintf('Finish %s\n',spec);
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function setupFDesignTypes(~)







        end


        function fc=lcl_get_frequencyconstraints(this,fc)

            if isminorder(this)
                fc='Transition width';
            end
        end


        function mc=lcl_get_magnitudeconstraints(this,mc)

            if isminorder(this)
                mc='Stopband attenuation';
            end
        end


        function set_ordermode(this)

            if strcmpi(this.OrderMode,'Specify')&&(any(strcmpi(this.OperatingMode,{'Simulink'})))
                this.FrequencyConstraints='Unconstrained';
                this.MagnitudeConstraints='Unconstrained';
            end

            updateMethod(this);
        end


    end


    methods(Hidden)

        function abstractnyquist_setGUI(this,Hd)




            hfdesign=getfdesign(Hd);
            switch lower(hfdesign.Specification)
            case 'tw,ast'
                set(this,...
                'TransitionWidth',num2str(hfdesign.TransitionWidth),...
                'Astop',num2str(hfdesign.Astop));
            case 'n'
                set(this,...
                'privFrequencyConstraints','unconstrained',...
                'privMagnitudeConstraints','unconstrained');
            case 'n,tw'
                set(this,...
                'privFrequencyConstraints','transition width',...
                'privMagnitudeConstraints','unconstrained',...
                'TransitionWidth',num2str(hfdesign.TransitionWidth));
            case 'n,ast'
                set(this,...
                'privFrequencyConstraints','unconstrained',...
                'privMagnitudeConstraints','Stopband attenuation',...
                'Astop',num2str(hfdesign.Astop));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:AbstractNyquistDesign:abstractnyquist_setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end

    end

end


