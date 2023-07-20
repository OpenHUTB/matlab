classdef(CaseInsensitiveProperties)ArbMagDesign<FilterDesignDialog.AbstractDesign




    properties(AbortSet,SetObservable,GetObservable)

        SpecifyDenominator(1,1)logical;

        DenominatorOrder='20';



        ResponseType='Amplitudes';

        Band1=[];

        Band2=[];

        Band3=[];

        Band4=[];

        Band5=[];

        Band6=[];

        Band7=[];

        Band8=[];

        Band9=[];

        Band10=[];
    end

    properties(AbortSet,SetObservable,GetObservable,Dependent)

        NumberOfBands;
    end

    properties(Hidden,AbortSet,SetObservable,GetObservable)

        privNumberOfBands=0;
    end

    properties(Constant,Hidden)

        ResponseTypeSet={'Amplitudes','Magnitudes and phases',...
        'Frequency response','Group delay'};
        ResponseTypeEntries={FilterDesignDialog.message('Amplitudes'),...
        FilterDesignDialog.message('magn'),...
        FilterDesignDialog.message('freq'),...
        FilterDesignDialog.message('GroupDelay')};
    end


    methods
        function this=ArbMagDesign(varargin)


            f='linspace(0, 1, 30)';
            a='[ones(1, 7) zeros(1,8) ones(1,8) zeros(1,7)]';
            m='ones(1, 30)';
            p='angle(exp(-12*j*pi*linspace(0, 1, 30)))';
            h='exp(-12*j*pi*linspace(0, 1, 30))';
            g='[10*ones(1,15) linspace(10,1,15)]';
            r='0.2';
            c='false';

            this.OrderMode='specify';
            this.VariableName=this.getOutputVarName('am');
            this.Band1=FilterDesignDialog.ArbMagBand(f,a,m,p,h,g,r,c);
            if~isempty(varargin)
                set(this,varargin{:});
            end



            if strcmpi(this.ResponseType,'group delay')
                this.ImpulseResponse='IIR';
                this.FDesign=fdesign.arbgrpdelay(20,eval(f),eval(g));
                this.DesignMethod='IIR least p-norm';
            else
                this.FDesign=fdesign.arbmag(20,eval(f),eval(a));
                this.DesignMethod='Frequency sampling';
                this.LastAppliedDesignOpts={'Window',''};
            end

            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedState=getState(this);


        end

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

        function set.DenominatorOrder(obj,value)

            validateattributes(value,{'char'},{'row'},'','DenominatorOrder')
            obj.DenominatorOrder=value;
        end

        function value=get.NumberOfBands(obj)
            value=get_numberofbands(obj,obj.privNumberOfBands);
        end
        function set.NumberOfBands(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','NumberOfBands')
            set_numberofbands(obj,value);
        end

        function value=get.ResponseType(obj)
            value=obj.ResponseType;
        end
        function set.ResponseType(obj,value)



            value=validatestring(value,obj.ResponseTypeSet,'','ResponseType');
            obj.ResponseType=value;
            set_responsetype(obj);
        end

        function set.Band1(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band1')
            obj.Band1=value;
        end

        function set.Band2(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band2')
            obj.Band2=value;
        end

        function set.Band3(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band3')
            obj.Band3=value;
        end

        function set.Band4(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band4')
            obj.Band4=value;
        end

        function set.Band5(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band5')
            obj.Band5=value;
        end

        function set.Band6(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band6')
            obj.Band6=value;
        end

        function set.Band7(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band7')
            obj.Band7=value;
        end

        function set.Band8(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band8')
            obj.Band8=value;
        end

        function set.Band9(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band9')
            obj.Band9=value;
        end

        function set.Band10(obj,value)

            validateattributes(value,{'FilterDesignDialog.ArbMagBand'},{'scalar'},'','Band10')
            obj.Band10=value;
        end

    end

    methods

        function addSetSpecificationLines(this,variables,~,hBuffer)







            hfdesign=getFDesign(this);

            if strcmp(hfdesign.Specification,'N,B,F,A,C')
                idx=strncmp('Rp',variables,2);
                rippleVariables=variables(idx);


                for idx=1:length(rippleVariables)
                    hBuffer.cr;
                    rpStr=['B',rippleVariables{idx}(3),'Ripple'];
                    hBuffer.addcr(['h.',rpStr,' = ',rippleVariables{idx},';']);
                end
            end


        end


        function inputs=formatConstructorInputs(this,inputs)



            hfdesign=getFDesign(this);

            if strcmp(hfdesign.Specification,'N,B,F,A,C')




                rpIdx=strncmp('Rp',inputs,2);
                inputs(rpIdx)=[];
            end


        end


        function dialogTitle=getDialogTitle(this)



            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('ArbMagFilter');
            else
                if isFilterDesignerMode(this)
                    dialogTitle=FilterDesignDialog.message(['ArbMagDesign',this.ImpulseResponse]);
                else
                    dialogTitle=FilterDesignDialog.message('ArbMagDesign');
                end
            end


        end


        function helpFrame=getHelpFrame(this)



            helptext.Type='text';
            if isFilterDesignerMode(this)
                helptext.Name=FilterDesignDialog.message('FilterDesignAssistantHeader');
            else
                helptext.Name=FilterDesignDialog.message('ArbMagDesignHelpTxt');
            end
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

            switch lower(getSpecification(this,laState))
            case 'n,f,a'
                vars={'N','F','A'};
                vals={num2str(specs.Order),mat2str(specs.Band1.Frequencies),...
                mat2str(specs.Band1.Amplitudes)};
            case 'f,a,r'
                vars={'F','A','Rp'};
                vals={mat2str(specs.Band1.Frequencies),...
                mat2str(specs.Band1.Amplitudes),mat2str(specs.Band1.Ripple)};
            case 'nb,na,f,a'
                vars={'Nb','Na','F','A'};
                vals={num2str(specs.Order),num2str(specs.DenominatorOrder),...
                mat2str(specs.Band1.Frequencies),mat2str(specs.Band1.Amplitudes)};
            case 'n,b,f,a'

                vars=cell(2+specs.NumberOfBands*2,1);
                vals=vars;

                vars(1:2)={'N','B'};
                vals(1:2)={num2str(specs.Order),num2str(specs.NumberOfBands)};

                for indx=1:specs.NumberOfBands
                    band=specs.(sprintf('Band%d',indx));
                    vars{2+2*indx-1}=sprintf('F%d',indx);
                    vars{2+2*indx}=sprintf('A%d',indx);
                    vals{2+2*indx-1}=mat2str(band.Frequencies);
                    vals{2+2*indx}=mat2str(band.Amplitudes);
                end

            case 'n,b,f,a,c'

                vars=cell(2+specs.NumberOfBands*3,1);
                vals=vars;

                vars(1:2)={'N','B'};
                vals(1:2)={num2str(specs.Order),num2str(specs.NumberOfBands)};

                for indx=1:specs.NumberOfBands
                    band=specs.(sprintf('Band%d',indx));
                    vars{3*indx}=sprintf('F%d',indx);
                    vars{3*indx+1}=sprintf('A%d',indx);
                    vars{3*indx+2}=sprintf('C%d',indx);
                    vals{3*indx}=mat2str(band.Frequencies);
                    vals{3*indx+1}=mat2str(band.Amplitudes);
                    vals{3*indx+2}=mat2str(band.Constrained);
                end

                for indx=1:specs.NumberOfBands
                    band=specs.(sprintf('Band%d',indx));
                    if band.Constrained
                        vars{end+1}=sprintf('Rp%d',indx);%#ok<*AGROW>
                        vals{end+1}=mat2str(band.Ripple);
                    end
                end

            case 'b,f,a,r'

                vars=cell(1+specs.NumberOfBands*3,1);
                vals=vars;

                vars(1)={'B'};
                vals(1)={num2str(specs.NumberOfBands)};

                for indx=1:specs.NumberOfBands
                    band=specs.(sprintf('Band%d',indx));
                    vars{3*indx-1}=sprintf('F%d',indx);
                    vars{3*indx}=sprintf('A%d',indx);
                    vars{3*indx+1}=sprintf('Rp%d',indx);
                    vals{3*indx-1}=mat2str(band.Frequencies);
                    vals{3*indx}=mat2str(band.Amplitudes);
                    vals{3*indx+1}=mat2str(band.Ripple);
                end

            case 'nb,na,b,f,a'
                vars=cell(3+specs.NumberOfBands*2,1);
                vals=vars;

                vars(1:3)={'Nb','Na','B'};
                vals(1:3)={num2str(specs.Order),num2str(specs.DenominatorOrder),...
                num2str(specs.NumberOfBands)};

                for indx=1:specs.NumberOfBands
                    band=specs.(sprintf('Band%d',indx));
                    vars{3+2*indx-1}=sprintf('F%d',indx);
                    vars{3+2*indx}=sprintf('A%d',indx);
                    vals{3+2*indx-1}=mat2str(band.Frequencies);
                    vals{3+2*indx}=mat2str(band.Amplitudes);
                end
            case 'n,f,h'
                vars={'N','F','H'};
                vals={num2str(specs.Order),mat2str(specs.Band1.Frequencies),...
                mat2str(specs.Band1.FreqResp)};

            case 'nb,na,f,h'
                vars={'NB','Na','F','H'};
                vals={num2str(specs.Order),num2str(specs.DenominatorOrder),...
                mat2str(specs.Band1.Frequencies),mat2str(specs.Band1.FreqResp)};
            case 'n,b,f,h'
                vars=cell(2+specs.NumberOfBands*2,1);
                vals=vars;

                vars(1:2)={'N','B'};
                vals(1:2)={num2str(specs.Order),num2str(specs.NumberOfBands)};

                for indx=1:specs.NumberOfBands
                    band=specs.(sprintf('Band%d',indx));

                    vars{2+2*indx-1}=sprintf('F%d',indx);
                    vals{2+2*indx-1}=mat2str(band.Frequencies);

                    vars{2+2*indx}=sprintf('H%d',indx);
                    vals{2+2*indx}=mat2str(band.FreqResp);
                end
            case 'n,f,gd'
                vars={'N','F','Gd'};
                vals={num2str(specs.Order),mat2str(specs.Band1.Frequencies),...
                mat2str(specs.Band1.GroupDelay)};
            case 'n,b,f,gd'

                vars=cell(2+specs.NumberOfBands*2,1);
                vals=vars;

                vars(1:2)={'N','B'};
                vals(1:2)={num2str(specs.Order),num2str(specs.NumberOfBands)};

                for indx=1:specs.NumberOfBands
                    band=specs.(sprintf('Band%d',indx));
                    vars{2+2*indx-1}=sprintf('F%d',indx);
                    vars{2+2*indx}=sprintf('Gd%d',indx);
                    vals{2+2*indx-1}=mat2str(band.Frequencies);
                    vals{2+2*indx}=mat2str(band.GroupDelay);
                end

            end

            mCodeInfo.Variables=vars(:);
            mCodeInfo.Values=vals(:);


        end


        function mainFrame=getMainFrame(this)



            header=getHeaderFrame(this);
            header.RowSpan=[1,1];
            header.ColSpan=[1,1];

            filtresp=getFilterRespFrame(this);
            filtresp.RowSpan=[2,2];
            filtresp.ColSpan=[1,1];

            design=getDesignMethodFrame(this);
            design.RowSpan=[3,3];
            design.ColSpan=[1,1];

            if isFilterDesignerMode(this)
                mainFrame.Items={header,filtresp,design};
                gridIdx=4;
                rowStretch=[0,0,0,3];
            else
                implem=getImplementationFrame(this);
                implem.RowSpan=[4,4];
                implem.ColSpan=[1,1];
                gridIdx=5;
                rowStretch=[0,0,0,0,3];
                mainFrame.Items={header,filtresp,design,implem};
            end

            mainFrame.Type='panel';
            mainFrame.LayoutGrid=[gridIdx,1];
            mainFrame.RowStretch=rowStretch;
            mainFrame.Tag='Main';
        end


        function specification=getSpecification(this,laState)



            if nargin>1
                source=laState;
            else
                source=this;
            end

            completeSpecStringFlag=true;

            flag=true;
            if strcmpi(source.ResponseType,'Magnitudes and phases')||...
                strcmpi(source.ResponseType,'Frequency response')

                if strcmpi(source.ImpulseResponse,'iir')
                    flag=false;
                end
            end

            if source.NumberOfBands>0||(isFirstBand(source)&&flag)

                if strcmpi(source.ImpulseResponse,'iir')
                    if source.SpecifyDenominator
                        specification='Nb,Na,B,F,';
                    else
                        specification='N,B,F,';
                    end
                else
                    if strcmpi(source.OrderMode,'specify')
                        if isDSTMode(this)&&strcmpi(source.ResponseType,'Amplitudes')&&isconstrained(this,source)
                            specification='N,B,F,A,C';
                            completeSpecStringFlag=false;
                        else
                            specification='N,B,F,';
                        end
                    else

                        specification='B,F,A,R';
                        completeSpecStringFlag=false;
                    end
                end
            else

                if strcmpi(source.ImpulseResponse,'iir')
                    if source.SpecifyDenominator
                        specification='Nb,Na,F,';
                    else
                        specification='N,F,';
                    end
                else
                    if strcmpi(source.OrderMode,'specify')
                        specification='N,F,';
                    else

                        specification='F,A,R';
                        completeSpecStringFlag=false;
                    end
                end
            end

            if completeSpecStringFlag
                if strcmpi(this.ResponseType,'amplitudes')
                    specification=sprintf('%sA',specification);
                elseif strcmpi(this.ResponseType,'group delay')
                    specification=sprintf('%sGd',specification');
                else
                    specification=sprintf('%sH',specification');
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
            specs.Factor=evaluateVariable(this,source.Factor);
            specs.Scale=strcmpi(this.Scale,'on');
            specs.ForceLeadingNumerator=strcmpi(this.ForceLeadingNumerator,'on');

            if strcmpi(this.FilterType,'sample-rate converter')
                specs.SecondFactor=evaluateVariable(this,source.SecondFactor);
            end

            specs.FrequencyUnits=source.FrequencyUnits;

            specs.InputSampleRate=getnum(this,source,'InputSampleRate');
            specs.Order=evaluateVariable(this,source.Order);

            spec=lower(getSpecification(this,source));

            switch spec
            case 'n,f,a'
                specs.Band1.Frequencies=thisgetnum(this,source,'Band1','Frequencies');
                specs.Band1.Amplitudes=evaluateVariable(this,source.Band1.Amplitudes);
            case 'f,a,r'
                specs.Band1.Frequencies=thisgetnum(this,source,'Band1','Frequencies');
                specs.Band1.Amplitudes=evaluateVariable(this,source.Band1.Amplitudes);
                specs.Band1.Ripple=evaluateVariable(this,source.Band1.Ripple);
            case 'n,b,f,a'
                specs.NumberOfBands=this.NumberOfBands+1;
                for indx=1:specs.NumberOfBands
                    band_str=sprintf('Band%d',indx);
                    specs.(band_str).Frequencies=thisgetnum(this,source,band_str,'Frequencies');
                    specs.(band_str).Amplitudes=evaluateVariable(this,source.(band_str).Amplitudes);
                end
            case 'n,b,f,a,c'
                specs.NumberOfBands=this.NumberOfBands+1;
                for indx=1:specs.NumberOfBands
                    band_str=sprintf('Band%d',indx);
                    specs.(band_str).Frequencies=thisgetnum(this,source,band_str,'Frequencies');
                    specs.(band_str).Amplitudes=evaluateVariable(this,source.(band_str).Amplitudes);
                    specs.(band_str).Constrained=strcmpi(source.(band_str).Constrained,'true');
                    if specs.(band_str).Constrained
                        specs.(band_str).Ripple=evaluateVariable(this,source.(band_str).Ripple);
                    end
                end
            case 'b,f,a,r'
                specs.NumberOfBands=this.NumberOfBands+1;
                for indx=1:specs.NumberOfBands
                    band_str=sprintf('Band%d',indx);
                    specs.(band_str).Frequencies=thisgetnum(this,source,band_str,'Frequencies');
                    specs.(band_str).Amplitudes=evaluateVariable(this,source.(band_str).Amplitudes);
                    specs.(band_str).Ripple=evaluateVariable(this,source.(band_str).Ripple);
                end
            case 'nb,na,f,a'
                specs.DenominatorOrder=evaluateVariable(this,this.DenominatorOrder);
                specs.Band1.Frequencies=thisgetnum(this,source,'Band1','Frequencies');
                specs.Band1.Amplitudes=evaluateVariable(this,source.Band1.Amplitudes);
            case 'nb,na,b,f,a'
                specs.DenominatorOrder=evaluateVariable(this,this.DenominatorOrder);
                specs.NumberOfBands=this.NumberOfBands+1;
                for indx=1:specs.NumberOfBands
                    band_str=sprintf('Band%d',indx);
                    specs.(band_str).Frequencies=thisgetnum(this,source,band_str,'Frequencies');
                    specs.(band_str).Amplitudes=evaluateVariable(this,source.(band_str).Amplitudes);
                end
            case 'n,f,h'
                specs.Band1.Frequencies=thisgetnum(this,source,'Band1','Frequencies');
                specs.Band1.FreqResp=getFreqResp(this,source,1);
            case 'n,b,f,h'
                specs.NumberOfBands=this.NumberOfBands+1;
                for indx=1:specs.NumberOfBands
                    band_str=sprintf('Band%d',indx);
                    specs.(band_str).Frequencies=thisgetnum(this,source,band_str,'Frequencies');
                    specs.(band_str).FreqResp=getFreqResp(this,source,indx);
                end
            case 'nb,na,f,h'
                specs.DenominatorOrder=evaluateVariable(this,this.DenominatorOrder);
                specs.NumberOfBands=this.NumberOfBands+1;
                specs.Band1.Frequencies=thisgetnum(this,source,'Band1','Frequencies');
                specs.Band1.FreqResp=getFreqResp(this,source,1);
            case 'nb,na,b,f,h'
                specs.DenominatorOrder=evaluateVariable(this,this.DenominatorOrder);
                specs.NumberOfBands=this.NumberOfBands+1;
                for indx=1:specs.NumberOfBands
                    band_str=sprintf('Band%d',indx);
                    specs.(band_str).Frequencies=thisgetnum(this,source,band_str,'Frequencies');
                    specs.(band_str).FreqResp=getFreqResp(this,source,indx);
                end
            case 'n,f,gd'
                specs.Band1.Frequencies=thisgetnum(this,source,'Band1','Frequencies');
                specs.Band1.GroupDelay=evaluateVariable(this,source.Band1.GroupDelay);
            case 'n,b,f,gd'
                specs.NumberOfBands=this.NumberOfBands+1;
                for indx=1:specs.NumberOfBands
                    band_str=sprintf('Band%d',indx);
                    specs.(band_str).Frequencies=thisgetnum(this,source,band_str,'Frequencies');
                    specs.(band_str).GroupDelay=evaluateVariable(this,source.(band_str).GroupDelay);
                end
            otherwise
                disp(sprintf('Finish %s',spec));%#ok<DSPS>
            end
        end


        function state=getState(this)




            state=get(this);
            state=rmfield(state,{'Path','ActiveTab','FixedPoint'});

            for indx=1:10
                bandProp=sprintf('Band%d',indx);
                if isempty(this.(bandProp))
                    break
                else
                    state.(bandProp)=get(this.(bandProp));
                end
            end


        end


        function numberofbands=get_numberofbands(this,~)




            numberofbands=this.privNumberOfBands;


        end


        function responsetype=get_responsetype(this,~)




            responsetype=this.ResponseType;


        end


        function flag=isconstrained(this,source)



            if nargin>1
                thisSource=source;
            else
                thisSource=this;
            end

            flag=false;
            for idx=1:(thisSource.NumberOfBands)+1
                bStr=sprintf('Band%d',idx);
                if~isempty(thisSource.(bStr))&&strcmpi(thisSource.(bStr).Constrained,'true')
                    flag=true;
                    return;
                end
            end
        end

        function b=setGUI(this,Hd)



            b=true;

            hfdesign=getfdesign(Hd);
            if~(strncmp(get(hfdesign,'Response'),'Arbitrary Magnitude',19)||...
                strcmp(get(hfdesign,'Response'),'Arbitrary Group Delay'))
                b=false;
                return;
            end

            switch lower(hfdesign.Specification)
            case 'n,f,a'

                set(this.Band1,...
                'Frequencies',mat2str(hfdesign.Frequencies),...
                'Amplitudes',mat2str(hfdesign.Amplitudes));

            case 'f,a,r'

                set(this.Band1,...
                'Frequencies',mat2str(hfdesign.Frequencies),...
                'Amplitudes',mat2str(hfdesign.Amplitudes),...
                'Ripple',mat2str(hfdesign.Ripple));

            case{'n,b,f,a','nb,na,b,f,a'}

                set(this,'NumberOfBands',hfdesign.NBands-1);

                for indx=1:hfdesign.NBands
                    set(this.(sprintf('Band%d',indx)),...
                    'Frequencies',mat2str(hfdesign.(sprintf('B%dFrequencies',indx))),...
                    'Amplitudes',mat2str(hfdesign.(sprintf('B%dAmplitudes',indx))));
                end

            case{'b,f,a,r'}

                set(this,'NumberOfBands',hfdesign.NBands-1);

                for indx=1:hfdesign.NBands
                    set(this.(sprintf('Band%d',indx)),...
                    'Frequencies',mat2str(hfdesign.(sprintf('B%dFrequencies',indx))),...
                    'Amplitudes',mat2str(hfdesign.(sprintf('B%dAmplitudes',indx))),...
                    'Ripple',mat2str(hfdesign.(sprintf('B%dRipple',indx))));
                end

            case{'n,b,f,a,c'}

                set(this,'NumberOfBands',hfdesign.NBands-1);

                for indx=1:hfdesign.NBands
                    set(this.(sprintf('Band%d',indx)),...
                    'Frequencies',mat2str(hfdesign.(sprintf('B%dFrequencies',indx))),...
                    'Amplitudes',mat2str(hfdesign.(sprintf('B%dAmplitudes',indx))),...
                    'Constrained',mat2str(hfdesign.(sprintf('B%dConstrained',indx))));
                    if hfdesign.(sprintf('B%dConstrained',indx))
                        set(this.(sprintf('Band%d',indx)),...
                        'Ripple',mat2str(hfdesign.(sprintf('B%dRipple',indx))));
                    end
                end

            case 'nb,na,f,a'

                set(this.Band1,...
                'Frequencies',mat2str(hfdesign.Frequencies),...
                'Amplitudes',mat2str(hfdesign.Amplitudes));

            case 'n,f,h'
                set(this,'ResponseType','Frequency Response');
                set(this.Band1,...
                'Frequencies',num2str(hfdesign.Frequencies),...
                'Amplitudes',num2str(hfdesign.FreqResponse));
            case 'n,b,f,h'
                set(this,'ResponseType','Frequency Response',...
                'NumberOfBands',hfdesign.NBands-1);

                for indx=1:hfdesign.NBands
                    set(this.(sprintf('Band%d',indx)),...
                    'Frequencies',mat2str(hfdesign.(sprintf('B%dFrequencies',indx))),...
                    'Amplitudes',mat2str(hfdesign.(sprintf('B%dFreqResponse',indx))));
                end

            case 'n,f,gd'

                set(this.Band1,...
                'Frequencies',mat2str(hfdesign.Frequencies),...
                'GroupDelay',mat2str(hfdesign.GroupDelay));
            case{'n,b,f,gd'}

                set(this,'NumberOfBands',hfdesign.NBands-1);

                for indx=1:hfdesign.NBands
                    set(this.(sprintf('Band%d',indx)),...
                    'Frequencies',mat2str(hfdesign.(sprintf('B%dFrequencies',indx))),...
                    'GroupDelay',mat2str(hfdesign.(sprintf('B%dGroupDelay',indx))));
                end

            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:ArbMagDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function frequnits=set_frequencyunits(this,frequnits)



            updateMethod(this);


        end


        function set_impulseresponse(this,~)



            impulseresponse=get(this,'ImpulseResponse');


            if strcmpi(impulseresponse,'iir')
                if~strcmpi(this.FilterType,'single-rate')&&...
                    ~allowsMultirate(this)
                    set(this,'FilterType','single-rate')
                end
            else


                if strcmpi(this.ResponseType,'group delay')
                    set(this,'ResponseType','Amplitudes');
                end
            end

            updateMethod(this);


        end


        function inputsamplerate=set_inputsamplerate(this,inputsamplerate)




            updateMethod(this);


        end


        function numberofbands=set_numberofbands(this,numberofbands)




            oldNBands=this.NumberOfBands;
            this.privNumberOfBands=numberofbands;


            for indx=oldNBands+1:numberofbands
                bandProp=sprintf('Band%d',indx+1);
                if isempty(this.(bandProp))
                    this.(bandProp)=FilterDesignDialog.ArbMagBand;
                end
            end

            updateMethod(this);


        end


        function[success,msg]=setupFDesign(this,varargin)



            success=true;
            msg='';

            hd=this.FDesign;



            if strcmpi(this.ResponseType,'amplitudes')
                if~isa(hd,'fdesign.arbmag')
                    hd=fdesign.arbmag;
                    set(this,'FDesign',hd);
                end
            elseif strcmpi(this.ResponseType,'group delay')
                if~isa(hd,'fdesign.arbgrpdelay')
                    hd=fdesign.arbgrpdelay;
                    set(this,'FDesign',hd);
                end
            else
                if~isa(hd,'fdesign.arbmagnphase')
                    hd=fdesign.arbmagnphase;
                    set(this,'FDesign',hd);
                end
            end

            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            spec=getSpecification(this,source);



            setSpecsSafely(this,hd,spec);

            if isprop(hd,'NBands')
                set(hd,'NBands',(source.NumberOfBands)+1);
            end



            try
                specs=getSpecs(this,source);

                if strncmpi(specs.FrequencyUnits,'normalized',10)
                    normalizefreq(hd);
                else
                    normalizefreq(hd,false,specs.InputSampleRate);
                end

                switch spec
                case 'N,F,A'
                    setspecs(hd,specs.Order,specs.Band1.Frequencies,specs.Band1.Amplitudes);
                case 'F,A,R'
                    setspecs(hd,specs.Band1.Frequencies,specs.Band1.Amplitudes,specs.Band1.Ripple);
                case 'Nb,Na,F,A'
                    setspecs(hd,specs.Order,specs.DenominatorOrder,...
                    specs.Band1.Frequencies,specs.Band1.Amplitudes);
                case 'N,B,F,A'

                    inputs=cell(1,2+2*specs.NumberOfBands);
                    inputs{1}=specs.Order;
                    inputs{2}=specs.NumberOfBands;
                    for indx=1:specs.NumberOfBands
                        band_str=sprintf('Band%d',indx);
                        inputs{2*indx+1}=specs.(band_str).Frequencies;
                        inputs{2*indx+2}=specs.(band_str).Amplitudes;
                    end
                    setspecs(hd,inputs{:});
                case 'B,F,A,R'

                    inputs=cell(1,1+3*specs.NumberOfBands);
                    inputs{1}=specs.NumberOfBands;
                    for indx=1:specs.NumberOfBands
                        band_str=sprintf('Band%d',indx);
                        inputs{3*indx-1}=specs.(band_str).Frequencies;
                        inputs{3*indx}=specs.(band_str).Amplitudes;
                        inputs{3*indx+1}=specs.(band_str).Ripple;
                    end
                    setspecs(hd,inputs{:});

                case 'N,B,F,A,C'

                    inputs=cell(1,2+3*specs.NumberOfBands);
                    inputs{1}=specs.Order;
                    inputs{2}=specs.NumberOfBands;
                    for indx=1:specs.NumberOfBands
                        band_str=sprintf('Band%d',indx);
                        inputs{3*indx}=specs.(band_str).Frequencies;
                        inputs{3*indx+1}=specs.(band_str).Amplitudes;
                        inputs{3*indx+2}=specs.(band_str).Constrained;
                    end



                    for idx=1:hd.NBands
                        constrainedStr=sprintf('B%dConstrained',idx);
                        hd.(constrainedStr)=false;
                    end
                    setspecs(hd,inputs{:});


                    for indx=1:specs.NumberOfBands
                        constrained_str=sprintf('B%dConstrained',indx);
                        if hd.(constrained_str)
                            band_str=sprintf('Band%d',indx);
                            ripple_str=sprintf('B%dRipple',indx);
                            hd.(ripple_str)=specs.(band_str).Ripple;
                        end
                    end

                case 'Nb,Na,B,F,A'

                    inputs=cell(1,3+2*specs.NumberOfBands);
                    inputs{1}=specs.Order;
                    inputs{2}=specs.DenominatorOrder;
                    inputs{3}=specs.NumberOfBands;
                    for indx=1:specs.NumberOfBands
                        band_str=sprintf('Band%d',indx);
                        inputs{2*indx+2}=specs.(band_str).Frequencies;
                        inputs{2*indx+3}=specs.(band_str).Amplitudes;
                    end
                    setspecs(hd,inputs{:});
                case 'N,F,H'
                    inputs={specs.Order,specs.Band1.Frequencies,specs.Band1.FreqResp};
                    setspecs(hd,inputs{:});
                case 'Nb,Na,F,H'
                    inputs={specs.Order,specs.DenominatorOrder,...
                    specs.Band1.Frequencies,specs.Band1.FreqResp};
                    setspecs(hd,inputs{:});
                case 'N,B,F,H'

                    inputs=cell(1,2+2*specs.NumberOfBands);

                    inputs{1}=specs.Order;
                    inputs{2}=specs.NumberOfBands;
                    for indx=1:specs.NumberOfBands
                        inputs{2*indx+1}=specs.(sprintf('Band%d',indx)).Frequencies;
                        inputs{2*indx+2}=specs.(sprintf('Band%d',indx)).FreqResp;
                    end
                    setspecs(hd,inputs{:});

                case 'Nb,Na,B,F,H'

                    inputs=cell(1,3+2*specs.NumberOfBands);
                    inputs{1}=specs.Order;
                    inputs{2}=specs.DenominatorOrder;
                    inputs{3}=specs.NumberOfBands;

                    for indx=1:specs.NumberOfBands
                        inputs{2*indx+2}=specs.(sprintf('Band%d',indx)).Frequencies;
                        inputs{2*indx+3}=specs.(sprintf('Band%d',indx)).FreqResp;
                    end
                    setspecs(hd,inputs{:});
                case 'N,F,Gd'
                    setspecs(hd,specs.Order,specs.Band1.Frequencies,specs.Band1.GroupDelay);
                case 'N,B,F,Gd'

                    inputs=cell(1,2+2*specs.NumberOfBands);
                    inputs{1}=specs.Order;
                    inputs{2}=specs.NumberOfBands;
                    for indx=1:specs.NumberOfBands
                        band_str=sprintf('Band%d',indx);
                        inputs{2*indx+1}=specs.(band_str).Frequencies;
                        inputs{2*indx+2}=specs.(band_str).GroupDelay;
                    end
                    setspecs(hd,inputs{:});

                otherwise
                    disp(sprintf('Finish %s',spec));%#ok<DSPS>
                end
            catch e
                success=false;
                msg=cleanerrormsg(e.message);



                if strcmpi(hd.Specification,'n,b,f,a,c')&&strcmp(msg,'Edit boxes cannot be empty.')
                    for idx=1:source.NumberOfBands+1
                        constrainedStr=sprintf('B%dConstrained',idx);
                        bandStr=sprintf('Band%d',idx);
                        hd.(constrainedStr)=strcmpi(source.(bandStr).Constrained,'true');
                    end
                end
            end


        end


        function thisloadobj(this,s)



            set(this,...
            'SpecifyDenominator',s.SpecifyDenominator,...
            'DenominatorOrder',s.DenominatorOrder,...
            'NumberOfBands',s.NumberOfBands,...
            'ResponseType',s.ResponseType);

            indx=1;
            bandprop=sprintf('Band%d',indx);



            if~isfield(s.Band1,'GroupDelay')||isempty(s.Band1.GroupDelay)
                s.Band1.GroupDelay=this.Band1.GroupDelay;
            end
            if~isfield(s.Band1,'Constrained')||isempty(s.Band1.Constrained)
                s.Band1.Constrained=this.Band1.Constrained;
            end
            if~isfield(s.Band1,'Ripple')||isempty(s.Band1.Ripple)
                s.Band1.Ripple=this.Band1.Ripple;
            end

            while~isempty(s.(bandprop))


                if~isstruct(s.(bandprop))
                    s.(bandprop)=get(s.(bandprop));
                end
                set(this.(bandprop),s.(bandprop));
                indx=indx+1;
                bandprop=sprintf('Band%d',indx);
            end



            updateMethod(this);


        end


        function s=thissaveobj(this,s)



            s.SpecifyDenominator=get(this,'SpecifyDenominator');
            s.DenominatorOrder=get(this,'DenominatorOrder');
            s.NumberOfBands=get(this,'NumberOfBands');
            s.ResponseType=get(this,'ResponseType');

            for indx=1:10
                bandprop=sprintf('Band%d',indx);
                s.(bandprop)=get(get(this,bandprop));
            end


        end


        function set_specifydenominator(this,~)

            if~isfir(this)&&this.SpecifyDenominator&&...
                strcmpi(this.ResponseType,'group delay')


                this.ResponseType='Amplitudes';
            end

            updateMethod(this);
        end


        function set_responsetype(this,~)

            updateMethod(this);
        end

    end

    methods(Hidden)
        function headerFrame=getHeaderFrame(this)

            if isDSTMode(this)
                [irtype_lbl,irtype]=getWidgetSchema(this,'ImpulseResponse',...
                FilterDesignDialog.message('impresp'),'combobox',1,1);
                irtype.Entries=FilterDesignDialog.message(lower({'FIR','IIR'}));
                irtype.DialogRefresh=true;
            end



            addOrderModeFlag=isfir(this)&&isDSTMode(this);
            orderWidgets=getOrderWidgetsWithNum(this,2,addOrderModeFlag);

            if isDSTMode(this)&&~isfir(this)
                dorder_chkbox.Name=FilterDesignDialog.message('DenOrder');
                dorder_chkbox.Type='checkbox';
                dorder_chkbox.Source=this;
                dorder_chkbox.Mode=true;
                dorder_chkbox.DialogRefresh=true;
                dorder_chkbox.RowSpan=[3,3]-(~addOrderModeFlag);
                dorder_chkbox.ColSpan=[3,3];
                dorder_chkbox.Enabled=true;
                dorder_chkbox.Tag='SpecifyDenominator';
                dorder_chkbox.ObjectProperty='SpecifyDenominator';

                dorder.Type='edit';
                dorder.Source=this;
                dorder.Mode=true;
                dorder.DialogRefresh=true;
                dorder.RowSpan=[3,3]-(~addOrderModeFlag);
                dorder.ColSpan=[4,4];
                dorder.Tag='DenominatorOrder';
                dorder.ObjectProperty='DenominatorOrder';

                if~this.SpecifyDenominator
                    dorder.Enabled=false;
                end

                dOrderWidgets={dorder_chkbox,dorder};
            else
                dOrderWidgets={};
            end

            if isDSTMode(this)
                ftype_widgets=getFilterTypeWidgets(this,4);
            end

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');
            if isDSTMode(this)
                headerFrame.Items={irtype_lbl,irtype,orderWidgets{:},...
                dOrderWidgets{:},ftype_widgets{:}};%#ok<*CCAT>
                headerFrame.LayoutGrid=[5,4];
                headerFrame.ColStretch=[0,1,0,1];
            else
                headerFrame.Items=orderWidgets;
                headerFrame.LayoutGrid=[2,4];
                headerFrame.ColStretch=[0,1,0,1];
            end
            headerFrame.Tag='FilterSpecsGroup';
        end


        function filtresp=getFilterRespFrame(this)

            [nbands_lbl,nbands]=getWidgetSchema(this,'NumberOfBands',FilterDesignDialog.message('NumBands'),...
            'combobox',1,1);
            nbands.Entries={'1','2','3','4','5','6','7','8','9','10'};
            nbands.DialogRefresh=true;




            if~this.isfir&&...
                (strcmpi(this.ResponseType,'magnitudes and phases')||...
                strcmpi(this.ResponseType,'frequency response'))&&...
                this.NumberOfBands>0

                this.ResponseType='Amplitudes';
            end

            [response_lbl,response]=getWidgetSchema(this,'ResponseType',FilterDesignDialog.message('RespType'),...
            'combobox',2,1);
            response.DialogRefresh=true;
            respType=this.ResponseTypeSet;

            if~isDSTMode(this)
                respType(2:end)=[];
            else
                if this.isfir

                    idx=strcmpi('group delay',respType);
                    respType(idx)=[];
                    if isminorder(this)

                        idx=strcmpi('amplitudes',respType);
                        respType(~idx)=[];

                        this.ResponseType='Amplitudes';
                    end
                else
                    if this.NumberOfBands>0


                        idx=strcmpi('magnitudes and phases',respType);
                        idx=idx|strcmpi('frequency response',respType);
                        respType(idx)=[];
                    end
                    if this.SpecifyDenominator

                        idx=strcmpi('group delay',respType);
                        respType(idx)=[];
                    end
                end
            end


            response=rmfield(response,'ObjectProperty');
            response.ObjectMethod='selectComboboxEntry';
            response.MethodArgs={'%dialog','%value','ResponseType',respType};
            response.ArgDataTypes={'handle','mxArray','string','mxArray'};

            indx=find(strcmp(respType,this.ResponseType));
            if~isempty(indx)
                response.Value=indx-1;
            end

            respType=cellfun(@(x)x(1:4),respType,'UniformOutput',0);
            response.Entries=FilterDesignDialog.message(lower(respType));

            items={nbands_lbl,nbands,response_lbl,response};

            items=getFrequencyUnitsWidgets(this,3,items);
            items{end-3}.Tunable=false;
            items{end-2}.Tunable=false;
            items{end-1}.Tunable=false;
            items{end}.Tunable=false;
            items{end}.DialogRefresh=true;

            spacer.Type='text';
            spacer.Name=' ';
            spacer.RowSpan=[4,4];
            spacer.ColSpan=[1,4];

            band_label.Type='text';
            band_label.Name=FilterDesignDialog.message('BandProps');
            band_label.RowSpan=[5,5];
            band_label.ColSpan=[1,4];

            band_table=getBandTable(this);
            band_table.RowSpan=[6,6];
            band_table.ColSpan=[1,4];

            items={items{:},spacer,band_label,band_table};

            filtresp.Type='group';
            filtresp.Name=FilterDesignDialog.message('respspecs');
            filtresp.Items=items;
            filtresp.LayoutGrid=[6,4];
            filtresp.ColStretch=[0,0,0,4];
            filtresp.Tag='FilterSpecsGroup';
        end


        function band_table=getBandTable(this)

            nBands=this.NumberOfBands+1;
            switch lower(this.responseType)
            case 'amplitudes'
                if isminorder(this)
                    colHeaders={FilterDesignDialog.message('Frequencies'),...
                    FilterDesignDialog.message('Amplitudes'),...
                    FilterDesignDialog.message('Ripple')};
                elseif nBands>1
                    colHeaders={FilterDesignDialog.message('Frequencies'),...
                    FilterDesignDialog.message('Amplitudes')};
                    if isDSTMode(this)&&isfir(this)
                        colHeaders=[colHeaders...
                        ,{FilterDesignDialog.message('Constraint'),...
                        FilterDesignDialog.message('Ripple')}];
                    end
                else
                    colHeaders={FilterDesignDialog.message('Frequencies'),...
                    FilterDesignDialog.message('Amplitudes')};
                end
            case 'magnitudes and phases'
                colHeaders={FilterDesignDialog.message('Frequencies'),...
                FilterDesignDialog.message('Magnitudes'),...
                FilterDesignDialog.message('Phases')};
            case 'frequency response'
                colHeaders={FilterDesignDialog.message('Frequencies'),...
                FilterDesignDialog.message('FrequencyResponse')};
            case 'group delay'
                colHeaders={FilterDesignDialog.message('Frequencies'),...
                FilterDesignDialog.message('GroupDelay')};
            end
            nCols=length(colHeaders);

            rowHeaders=cell(1,nBands);
            for indx=1:nBands
                rowHeaders{indx}=sprintf('%d',indx);
            end

            band_table.Type='table';
            band_table.Tag='BandTable';
            band_table.Size=[nBands,nCols];
            band_table.ColHeader=colHeaders;
            band_table.RowHeader=rowHeaders;
            band_table.Grid=true;
            band_table.RowHeaderWidth=2;
            band_table.ColumnCharacterWidth=repmat(36/nCols,1,nCols);
            band_table.ValueChangedCallback=...
            @(hdlg,row,col,value)onValueChanged(hdlg,this,row,col,value);
            band_table.Editable=true;
            band_table.Tunable=false;
            data=cell(nBands,nCols);
            for indx=1:nBands
                data(indx,:)=getTableRowSchema(this.(sprintf('Band%d',indx)),...
                this,indx,isminorder(this),nBands);
            end

            band_table.Data=data;
        end


        function fresp=getFreqResp(this,source,indx)



            band_str=sprintf('Band%d',indx);
            if strcmpi(source.ResponseType,'Frequency response')
                fresp=evaluateVariable(this,source.(band_str).FreqResp);
            else
                mag=evaluateVariable(this,source.(band_str).Magnitudes);
                phase=evaluateVariable(this,source.(band_str).Phases);
                if length(mag)~=length(phase)
                    error(message('FilterDesignLib:FilterDesignDialog:ArbMagDesign:getSpecs:vectorMismatch'));
                end
                fresp=mag.*cos(phase)+mag.*sin(phase)*1i;
            end
        end


        function value=thisgetnum(this,source,varargin)

            value=source;
            for indx=1:length(varargin)
                value=value.(varargin{indx});
            end

            [value,errMsg]=evaluateVariable(this,value);

            funits=source.FrequencyUnits;
            if~strncmpi(funits,'normalized',10)&&isempty(errMsg)
                value=convertfrequnits(value,funits,'Hz');
            end
        end

    end

end



function onValueChanged(hdlg,this,row,col,value)

    prop=sprintf('Band%d',row+1);

    hBand=get(this,prop);

    switch col
    case 0
        set(hBand,'Frequencies',value);
        updateMethod(this);
    case 1
        switch this.ResponseType
        case 'Amplitudes'
            set(hBand,'Amplitudes',value);
        case 'Magnitudes and phases'
            set(hBand,'Magnitudes',value);
        case 'Frequency response'
            set(hBand,'FreqResp',value);
        case 'Group delay'
            set(hBand,'GroupDelay',value);
        end
    case 2
        switch this.ResponseType
        case 'Amplitudes'
            if isminorder(this)
                set(hBand,'Ripple',value);
            else
                if value
                    inputValue='true';
                else
                    inputValue='false';
                end
                set(hBand,'Constrained',inputValue);




                updateMethod(this);
                refresh(hdlg);
            end
        case 'Magnitudes and phases'
            set(hBand,'Phases',value);
        end
    case 3
        set(hBand,'Ripple',value);
    end
end


function b=isFirstBand(source)




    try
        fvalues=evaluatevars(source.Band1.Frequencies);
        if~strncmpi(source.FrequencyUnits,'normalized',10)
            fvalues=fvalues/(evaluatevars(source.InputSampleRate)/2);
        end
    catch %#ok<CTCH>
        fvalues=[0,1];
    end

    if any(fvalues(1)==[-1,0])&&fvalues(end)==1
        b=false;
    else
        b=true;
    end
end
