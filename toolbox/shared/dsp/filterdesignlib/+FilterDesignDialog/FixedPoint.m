classdef(CaseInsensitiveProperties)FixedPoint<matlab.mixin.SetGet&matlab.mixin.Copyable&handle


















































































    properties(AbortSet,SetObservable,GetObservable,Access=protected)

        LastAppliedState=[];
    end

    properties(AbortSet,SetObservable,GetObservable)







        Structure='farrowfd';


        Arithmetic='Double precision';

        InputWordLength='16';

        InputFracLength1='15';



        CoeffMode='Same word length as input';

        CoeffSigned='on';

        CoeffWordLength='16';

        CoeffFracLength1='15';

        CoeffFracLength2='15';

        CoeffFracLength3='15';

        FDWordLength='6';


        FDMode='Specify word length';

        FDFracLength1='5';



        FilterInternals='Full precision';

        StateWordLength1='16';

        StateWordLength2='16';



        StateMode='Same as accumulator';

        StateFracLength1='15';

        StateFracLength2='15';

        MultiplicandWordLength='16';

        MultiplicandFracLength1='15';

        SectionInputWordLength='16';



        SectionInputMode='Same as input';

        SectionInputFracLength1='15';

        SectionOutputWordLength='16';



        SectionOutputMode='Same as section input';

        SectionOutputFracLength1='15';



        ProductMode='Full precision';

        ProductWordLength='32';

        ProductFracLength1='29';

        ProductFracLength2='29';



        AccumMode='Keep MSB';

        AccumWordLength='40';

        AccumFracLength1='29';

        AccumFracLength2='29';

        FDProdWordLength='39';

        FDProdFracLength1='34';

        SectionsWordLength='18';

        SectionsFracLength1='15';

        CastBeforeSum='on';


        RoundMode='Convergent';


        OverflowMode='Wrap';

        OutputWordLength='16';



        OutputMode='Avoid overflow';

        OutputFracLength1='15';

        FIRFlag(1,1)logical=true;

        SOSFlag(1,1)logical=false;

        IIRFlag(1,1)logical=false;

        FxPtRestrictions=[];

        FullPrecisionOverride(1,1)logical=true;


        CoeffSignedSysObj='autosigned';

        ProductSigned='on';


        ProductSignedSysObj='autosigned';

        AccumSigned='on';


        AccumSignedSysObj='autosigned';

        OutputSigned='on';


        OutputSignedSysObj='autosigned';



        MultiplicandMode='Same as input';

        SystemObject(1,1)logical=false;
    end

    properties(Constant,Hidden)







        StructureSet=...
        {'farrowfd','fd','dffir','dffirt','dfsymfir','dfasymfir','fftfir','df1',...
        'df2','df1t','df2t','df1sos','df2sos','df1tsos','df2tsos',...
        'firdecim','firtdecim','cicdecim','iirdecim','iirwdfdecim',...
        'firinterp','cicinterp','linearinterp','holdinterp','firsrc',...
        'fftfirinterp','iirinterp','iirwdfinterp','cascadeallpass',...
        'cascadewdfallpass'};
        StructureEntries=...
        {FilterDesignDialog.message('farrowfd'),...
        'fd',...
        FilterDesignDialog.message('dffir'),...
        FilterDesignDialog.message('dffirt'),...
        FilterDesignDialog.message('dfsymfir'),...
        FilterDesignDialog.message('dfasymfir'),...
        FilterDesignDialog.message('fftfir'),...
        FilterDesignDialog.message('df1'),...
        FilterDesignDialog.message('df2'),...
        FilterDesignDialog.message('df1t'),...
        FilterDesignDialog.message('df2t'),...
        FilterDesignDialog.message('df1sos'),...
        FilterDesignDialog.message('df2sos'),...
        FilterDesignDialog.message('df1tsos'),...
        FilterDesignDialog.message('df2tsos'),...
        FilterDesignDialog.message('firdecim'),...
        FilterDesignDialog.message('firtdecim'),...
        'cicdecim',...
        FilterDesignDialog.message('iirdecim'),...
        FilterDesignDialog.message('iirwdfdecim'),...
        FilterDesignDialog.message('firinterp'),...
        'cicinterp',...
        'linearinterp',...
        'holdinterp',...
        FilterDesignDialog.message('firsrc'),...
        FilterDesignDialog.message('fftfirinterp'),FilterDesignDialog.message('iirinterp'),...
        FilterDesignDialog.message('iirwdfinterp'),FilterDesignDialog.message('cascadeallpass'),...
        FilterDesignDialog.message('cascadewdfallpass')};


        ArithmeticSet={'Double precision','Single precision','Fixed point'};
        ArithmeticEntries={FilterDesignDialog.message('double'),...
        FilterDesignDialog.message('single'),...
        FilterDesignDialog.message('fixpt')};



        CoeffModeSet={'Same word length as input','Specify word length','Binary point scaling'};
        CoeffModeEntries={FilterDesignDialog.message('SameWordLengthAsInput'),...
        FilterDesignDialog.message('SpecifyWordLength'),...
        FilterDesignDialog.message('BinaryPointScaling')};


        FDModeSet={'Specify word length','Binary point scaling'};
        FDModeEntries={FilterDesignDialog.message('SpecifyWordLength'),...
        FilterDesignDialog.message('BinaryPointScaling')};



        FilterInternalsSet={'Full precision','Minimum word lengths','Specify word lengths',...
        'Specify precision'};
        FilterInternalsEntries={FilterDesignDialog.message('FullPrecision'),...
        FilterDesignDialog.message('MinimumWordLengths'),...
        FilterDesignDialog.message('SpecifyWordLengths'),...
        FilterDesignDialog.message('SpecifyPrecision')};



        StateModeSet={'Same as accumulator','Same as input','Specify word length',...
        'Binary point scaling'};
        StateModeEntries={FilterDesignDialog.message('SameAsAccumulator'),...
        FilterDesignDialog.message('SameAsInput'),...
        FilterDesignDialog.message('SpecifyWordLength'),...
        FilterDesignDialog.message('BinaryPointScaling')};



        SectionInputModeSet={'Same as input','Specify word length','Binary point scaling'};
        SectionInputModeEntries={FilterDesignDialog.message('SameAsInput'),...
        FilterDesignDialog.message('SpecifyWordLength'),...
        FilterDesignDialog.message('BinaryPointScaling')};



        SectionOutputModeSet={'Same as section input','Specify word length','Binary point scaling'};
        SectionOutputModeEntries={FilterDesignDialog.message('SameAsSectionInput'),...
        FilterDesignDialog.message('SpecifyWordLength'),...
        FilterDesignDialog.message('BinaryPointScaling')};



        ProductModeSet={'Full precision','Keep LSB','Keep MSB','Specify precision',...
        'Same as input','Specify word length','Same as product'};
        ProductModeEntries={FilterDesignDialog.message('FullPrecision'),...
        FilterDesignDialog.message('KeepLSB'),...
        FilterDesignDialog.message('KeepMSB'),...
        FilterDesignDialog.message('SpecifyPrecision'),...
        FilterDesignDialog.message('SameAsInput'),...
        FilterDesignDialog.message('SpecifyWordLength'),...
        FilterDesignDialog.message('SameAsProduct')};



        AccumModeSet={'Full precision','Keep LSB','Keep MSB','Specify precision','Same as input','Specify word length','Same as product'};
        AccumModeEntries={FilterDesignDialog.message('FullPrecision'),...
        FilterDesignDialog.message('KeepLSB'),...
        FilterDesignDialog.message('KeepMSB'),...
        FilterDesignDialog.message('SpecifyPrecision'),...
        FilterDesignDialog.message('SameAsInput'),...
        FilterDesignDialog.message('SpecifyWordLength'),...
        FilterDesignDialog.message('SameAsProduct')};


        RoundModeSet={'Convergent','Ceiling','Zero','Floor','Nearest','Round','Simplest'};
        RoundModeEntries={FilterDesignDialog.message('Convergent'),...
        FilterDesignDialog.message('Ceiling'),...
        FilterDesignDialog.message('Zero'),...
        FilterDesignDialog.message('Floor'),...
        FilterDesignDialog.message('Nearest'),...
        FilterDesignDialog.message('Round'),...
        FilterDesignDialog.message('Simplest')};



        OutputModeSet={'Avoid overflow','Best precision','Specify precision',...
        'Same as accumulator','Same as product','Same as input',...
        'Full precision'};
        OutputModeEntries={FilterDesignDialog.message('AvoidOverflow'),...
        FilterDesignDialog.message('BestPrecision'),...
        FilterDesignDialog.message('SpecifyPrecision'),...
        FilterDesignDialog.message('SameAsAccumulator'),...
        FilterDesignDialog.message('SameAsProduct'),...
        FilterDesignDialog.message('SameAsInput'),...
        FilterDesignDialog.message('FullPrecision')};


        CoeffSignedSysObjSet={'autosigned','signed','unsigned','specsigned'};


        ProductSignedSysObjSet={'autosigned','signed','unsigned','specsigned'};


        AccumSignedSysObjSet={'autosigned','signed','unsigned','specsigned'};


        OverflowModeSet={'Wrap','Saturate'};
        OverflowModeEntries={FilterDesignDialog.message('Wrap'),...
        FilterDesignDialog.message('Saturate')};



        MultiplicandModeSet={'Same as input','Same as output','Specify word length','Binary point scaling'};
        MultiplicandModeEntries={FilterDesignDialog.message('SameAsInput'),...
        FilterDesignDialog.message('SameAsOutput'),...
        FilterDesignDialog.message('SpecifyWordLength'),...
        FilterDesignDialog.message('BinaryPointScaling')};


        OutputSignedSysObjSet={'autosigned','signed','unsigned','specsigned'};
    end




    methods
        function set.Structure(obj,value)
            value=validatestring(value,obj.StructureSet,'','Structure');
            obj.Structure=value;
            set_structure(obj,value);
        end

        function value=get.Structure(obj)
            value=obj.Structure;
        end

        function set.Arithmetic(obj,value)


            value=validatestring(value,obj.ArithmeticSet,'','Arithmetic');
            obj.Arithmetic=value;
        end

        function value=get.Arithmetic(obj)
            value=obj.Arithmetic;
        end

        function set.InputWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','InputWordLength');
            obj.InputWordLength=value;
        end

        function set.InputFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','InputFracLength1');
            obj.InputFracLength1=value;
        end

        function set.CoeffMode(obj,value)



            value=validatestring(value,obj.CoeffModeSet,'','CoeffMode');
            obj.CoeffMode=value;
        end

        function value=getCoeffMoce(obj)
            value=obj.CoeffMode;
        end

        function set.CoeffSigned(obj,value)

            validatestring(value,{'on','off'},'','CoeffSigned');
            obj.CoeffSigned=value;
        end

        function set.CoeffWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','CoeffWordLength');
            obj.CoeffWordLength=value;
        end

        function set.CoeffFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','CoeffFracLength1');
            obj.CoeffFracLength1=value;
        end

        function set.CoeffFracLength2(obj,value)

            validateattributes(value,{'char'},{'row'},'','CoeffFracLength2');
            obj.CoeffFracLength2=value;
        end

        function set.CoeffFracLength3(obj,value)

            validateattributes(value,{'char'},{'row'},'','CoeffFracLength3');
            obj.CoeffFracLength3=value;
        end

        function set.FDWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','FDWordLength');
            obj.FDWordLength=value;
        end

        function set.FDMode(obj,value)


            value=validatestring(value,obj.FDModeSet,'','FDMode');
            obj.FDMode=value;
        end

        function set.FDFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','FDFracLength1');
            obj.FDFracLength1=value;
        end

        function set.FilterInternals(obj,value)



            value=validatestring(value,obj.FilterInternalsSet,'','FilterInternals');
            obj.FilterInternals=value;
        end

        function set.StateWordLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','StateWordLength1')
            obj.StateWordLength1=value;
        end

        function set.StateWordLength2(obj,value)

            validateattributes(value,{'char'},{'row'},'','StateWordLength2');
            obj.StateWordLength2=value;
        end

        function set.StateMode(obj,value)



            value=validatestring(value,obj.StateModeSet,'','StateMode');
            obj.StateMode=value;
        end

        function set.StateFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','StateFracLength1');
            obj.StateFracLength1=value;
        end

        function set.StateFracLength2(obj,value)

            validateattributes(value,{'char'},{'row'},'','StateFracLength2');
            obj.StateFracLength2=value;
        end

        function set.MultiplicandWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','MultiplicandWordLength');
            obj.MultiplicandWordLength=value;
        end

        function set.MultiplicandFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','MultiplicandFracLength1');
            obj.MultiplicandFracLength1=value;
        end

        function set.SectionInputWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','SectionInputWordLength');
            obj.SectionInputWordLength=value;
        end

        function set.SectionInputMode(obj,value)



            value=validatestring(value,obj.SectionInputModeSet,'','SectionInputMode');
            obj.SectionInputMode=value;
        end

        function set.SectionInputFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','SectionInputFracLength1');
            obj.SectionInputFracLength1=value;
        end

        function set.SectionOutputWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','SectionOutputWordLength');
            obj.SectionOutputWordLength=value;
        end

        function set.SectionOutputMode(obj,value)



            value=validatestring(value,obj.SectionOutputModeSet,'','SectionOutputMode');
            obj.SectionOutputMode=value;
        end

        function set.SectionOutputFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','SectionOutputFracLength1');
            obj.SectionOutputFracLength1=value;
        end

        function set.ProductMode(obj,value)



            value=validatestring(value,obj.ProductModeSet,'','ProductMode');
            obj.ProductMode=value;
        end

        function set.ProductWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','ProductWordLength');
            obj.ProductWordLength=value;
        end

        function set.ProductFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','ProductFracLength1');
            obj.ProductFracLength1=value;
        end

        function set.ProductFracLength2(obj,value)

            validateattributes(value,{'char'},{'row'},'','ProductFracLength2');
            obj.ProductFracLength2=value;
        end

        function set.AccumMode(obj,value)



            value=validatestring(value,obj.ProductModeSet,'','AccumMode');
            obj.AccumMode=value;
        end

        function set.AccumWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','AccumWordLength');
            obj.AccumWordLength=value;
        end

        function set.AccumFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','AccumFracLength1');
            obj.AccumFracLength1=value;
        end

        function set.AccumFracLength2(obj,value)

            validateattributes(value,{'char'},{'row'},'','AccumFracLength2');
            obj.AccumFracLength2=value;
        end

        function set.FDProdWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','FDProdWordLength');
            obj.FDProdWordLength=value;
        end

        function set.FDProdFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','FDProdFracLength1');
            obj.FDProdFracLength1=value;
        end

        function set.SectionsWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','SectionsWordLength');
            obj.SectionsWordLength=value;
        end

        function set.SectionsFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','SectionsFracLength1');
            obj.SectionsFracLength1=value;
        end

        function set.CastBeforeSum(obj,value)

            validatestring(value,{'on','off'},'','CastBeforeSum');
            obj.CastBeforeSum=value;
        end

        function set.RoundMode(obj,value)


            value=validatestring(value,obj.RoundModeSet,'','RoundMode');
            obj.RoundMode=value;
        end

        function set.OverflowMode(obj,value)

            value=validatestring(value,{'Wrap','Saturate'},'','OverflowMode');
            obj.OverflowMode=value;
        end

        function set.OutputWordLength(obj,value)

            validateattributes(value,{'char'},{'row'},'','OutputWordLength');
            obj.OutputWordLength=value;
        end

        function set.OutputMode(obj,value)




            value=validatestring(value,obj.OutputModeSet,'','OutputMode');
            obj.OutputMode=value;
        end

        function set.OutputFracLength1(obj,value)

            validateattributes(value,{'char'},{'row'},'','OutputFracLength1');
            obj.OutputFracLength1=value;
        end

        function set.FIRFlag(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','FIRFlag');
            value=logical(value);
            obj.FIRFlag=value;
        end

        function set.SOSFlag(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','SOSFlag');
            value=logical(value);
            obj.SOSFlag=value;
        end

        function set.IIRFlag(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','IIRFlag');
            value=logical(value);
            obj.IIRFlag=value;
        end

        function set.FullPrecisionOverride(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','FullPrecisionOverride');
            value=logical(value);
            obj.FullPrecisionOverride=value;
        end

        function set.CoeffSignedSysObj(obj,value)


            value=validatestring(value,obj.CoeffSignedSysObjSet,'','CoeffSignedSysObj');
            obj.CoeffSignedSysObj=value;
        end

        function set.ProductSigned(obj,value)

            validatestring(value,{'on','off'},'','ProductSigned');
            obj.ProductSigned=value;
        end

        function set.ProductSignedSysObj(obj,value)


            value=validatestring(value,obj.ProductSignedSysObjSet,'','ProductSignedSysObj');
            obj.ProductSignedSysObj=value;
        end

        function set.AccumSigned(obj,value)

            validatestring(value,{'on','off'},'','AccumSigned');
            obj.AccumSigned=value;
        end

        function set.AccumSignedSysObj(obj,value)


            value=validatestring(value,obj.AccumSignedSysObjSet,'','AccumSignedSysObj');
            obj.AccumSignedSysObj=value;
        end

        function set.OutputSigned(obj,value)

            validatestring(value,{'on','off'},'','OutputSigned');
            obj.OutputSigned=value;
        end

        function set.OutputSignedSysObj(obj,value)


            value=validatestring(value,obj.OutputSignedSysObjSet,'','OutputSignedSysObj');
            obj.OutputSignedSysObj=value;
        end

        function set.MultiplicandMode(obj,value)



            value=validatestring(value,obj.MultiplicandModeSet,'','MultiplicandMode');
            obj.MultiplicandMode=value;
        end

        function set.SystemObject(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','SystemObject');
            value=logical(value);
            obj.SystemObject=value;
        end

    end





    methods

        function applySettings(this,Hd)



            if isa(Hd,'dfilt.basefilter')
                applySettingsDfilt(this,Hd);
            else
                applySettingsSysObj(this,Hd);
            end


        end


        function applySettingsDfilt(this,Hd)



            if isa(Hd,'dfilt.multistage')


                for indx=1:nstages(Hd)
                    applySettings(this,Hd.Stage(indx));
                end
                return;
            end

            if~isSupportedStructure(this,Hd)
                return;
            end


            set(Hd,'Arithmetic',this.Arithmetic(1:4));



            if~strcmpi(Hd.Arithmetic,'fixed')
                return;
            end


            source=get(this,'LastAppliedState');
            if isempty(source)
                source=this;
            end


            Hd.InputWordLength=evaluatevars(source.InputWordLength);
            Hd.InputFracLength=evaluatevars(source.InputFracLength1);


            if~any(strcmpi(class(Hd),{'mfilt.cicdecim','dsp.internal.mfilt.cicinterp','dfilt.delay'}))
                Hd.CoeffWordLength=evaluatevars(source.CoeffWordLength);
                Hd.CoeffAutoScale=~strncmpi(source.CoeffMode,'binary',6);
                Hd.Signed=strcmpi(source.CoeffSigned,'on');
            end

            switch class(Hd)
            case{'mfilt.cicdecim','dsp.internal.mfilt.cicinterp'}
                Hd.FilterInternals=mapFilterInternalsDfilt(this.FilterInternals);
                switch lower(Hd.FilterInternals)
                case 'minwordlengths'
                    Hd.OutputWordLength=evaluatevars(this.OutputWordLength);
                case 'specifywordlengths'
                    swl=evaluatevars(this.SectionsWordLength);

                    if length(swl)>2*Hd.NumberOfSections
                        swl(2*Hd.NumberOfSections+1:end)=[];
                        set(this,'SectionsWordLength',mat2str(swl));
                    elseif length(swl)<2*Hd.NumberOfSections
                        swl(end+1:2*Hd.NumberOfSections)=swl(end);
                        set(this,'SectionsWordLength',mat2str(swl));
                    end

                    Hd.SectionWordLengths=evaluatevars(this.SectionsWordLength);
                    Hd.OutputWordLength=evaluatevars(this.OutputWordLength);
                case 'specifyprecision'

                    swl=evaluatevars(this.SectionsWordLength);
                    sfl=evaluatevars(this.SectionsFracLength1);

                    if length(swl)>2*Hd.NumberOfSections
                        swl(2*Hd.NumberOfSections+1:end)=[];
                        set(this,'SectionsWordLength',mat2str(swl));
                    elseif length(swl)<2*Hd.NumberOfSections
                        swl(end+1:2*Hd.NumberOfSections)=swl(end);
                        set(this,'SectionsWordLength',mat2str(swl));
                    end

                    if length(sfl)>2*Hd.NumberOfSections
                        sfl(2*Hd.NumberOfSections+1:end)=[];
                        set(this,'SectionsFracLength1',mat2str(sfl));
                    elseif length(sfl)<2*Hd.NumberOfSections
                        sfl(end+1:2*Hd.NumberOfSections)=sfl(end);
                        set(this,'SectionsFracLength1',mat2str(sfl));
                    end

                    Hd.SectionWordLengths=swl;
                    Hd.SectionFracLengths=sfl;
                    Hd.OutputWordLength=evaluatevars(this.OutputWordLength);
                    Hd.OutputFracLength=evaluatevars(this.OutputFracLength1);
                end
            case 'dfilt.scalar'


                Hd.OutputWordLength=evaluatevars(source.OutputWordLength);
                Hd.RoundMode=convertRoundModeDfilt(source);
                Hd.OverflowMode=source.OverflowMode;

                if~Hd.CoeffAutoScale
                    Hd.CoeffFracLength=evaluatevars(source.CoeffFracLength1);
                end

            case{'dfilt.dffir','dfilt.dffirt','dfilt.dfsymfir','mfilt.firdecim',...
                'dfilt.dfasymfir','mfilt.firtdecim','dsp.internal.mfilt.firinterp','mfilt.firsrc'}

                Hd.FilterInternals=source.FilterInternals(1:4);

                if~Hd.CoeffAutoScale
                    Hd.NumFracLength=evaluatevars(source.CoeffFracLength1);
                end

                if strncmpi(Hd.FilterInternals,'spec',4)
                    Hd.ProductWordLength=evaluatevars(source.ProductWordLength);
                    Hd.ProductFracLength=evaluatevars(source.ProductFracLength1);
                    Hd.AccumWordLength=evaluatevars(source.AccumWordLength);
                    Hd.AccumFracLength=evaluatevars(source.AccumFracLength1);
                    Hd.OutputWordLength=evaluatevars(source.OutputWordLength);
                    Hd.OutputFracLength=evaluatevars(source.OutputFracLength1);
                    Hd.OverflowMode=source.OverflowMode;
                    Hd.RoundMode=convertRoundModeDfilt(source);
                end
            case 'dfilt.df1sos'

                if~Hd.CoeffAutoScale
                    Hd.ScaleValueFracLength=evaluatevars(source.CoeffFracLength3);
                end

                Hd.OutputMode=strrep(source.OutputMode,' ','');
                Hd.NumStateWordLength=evaluatevars(source.StateWordLength1);
                Hd.NumStateFracLength=evaluatevars(source.StateFracLength1);
                Hd.DenStateWordLength=evaluatevars(source.StateWordLength2);
                Hd.DenStateFracLength=evaluatevars(source.StateFracLength2);

                if strcmpi(Hd.OutputMode,'SpecifyPrecision')
                    Hd.OutputFracLength=evaluatevars(source.OutputFracLength1);
                end

                setIIRcommonPropertiesDfilt(source,Hd);

            case 'dfilt.df2sos'

                if~Hd.CoeffAutoScale
                    Hd.ScaleValueFracLength=evaluatevars(source.CoeffFracLength3);
                end

                Hd.SectionInputWordLength=evaluatevars(source.SectionInputWordLength);
                Hd.SectionInputAutoScale=strcmpi(source.SectionInputMode,'specify word length');
                Hd.SectionOutputWordLength=evaluatevars(source.SectionOutputWordLength);
                Hd.SectionOutputAutoScale=strcmpi(source.SectionOutputMode,'specify word length');
                Hd.OutputMode=strrep(source.OutputMode,' ','');
                Hd.StateWordLength=evaluatevars(source.StateWordLength1);
                Hd.StateFracLength=evaluatevars(source.StateFracLength1);

                if~Hd.SectionInputAutoScale
                    Hd.SectionInputFracLength=evaluatevars(source.SectionInputFracLength1);
                end

                if~Hd.SectionOutputAutoScale
                    Hd.SectionOutputFracLength=evaluatevars(source.SectionOutputFracLength1);
                end

                if strcmpi(Hd.OutputMode,'SpecifyPrecision')
                    Hd.OutputFracLength=evaluatevars(source.OutputFracLength1);
                end

                setIIRcommonPropertiesDfilt(source,Hd);

            case 'dfilt.df1tsos'

                if~Hd.CoeffAutoScale
                    Hd.ScaleValueFracLength=evaluatevars(source.CoeffFracLength3);
                end

                Hd.SectionInputWordLength=evaluatevars(source.SectionInputWordLength);
                Hd.SectionInputAutoScale=strcmpi(source.SectionInputMode,'specify word length');
                Hd.SectionOutputWordLength=evaluatevars(source.SectionOutputWordLength);
                Hd.SectionOutputAutoScale=strcmpi(source.SectionOutputMode,'specify word length');
                Hd.MultiplicandWordLength=evaluatevars(source.MultiplicandWordLength);
                Hd.MultiplicandFracLength=evaluatevars(source.MultiplicandFracLength1);
                Hd.OutputMode=strrep(source.OutputMode,' ','');
                Hd.StateWordLength=evaluatevars(source.StateWordLength1);
                Hd.StateAutoScale=strcmpi(source.StateMode,'specify word length');

                if~Hd.SectionInputAutoScale
                    Hd.SectionInputFracLength=evaluatevars(source.SectionInputFracLength1);
                end

                if~Hd.SectionOutputAutoScale
                    Hd.SectionOutputFracLength=evaluatevars(source.SectionOutputFracLength1);
                end

                if~Hd.StateAutoScale
                    Hd.NumStateFracLength=evaluatevars(source.StateFracLength1);
                    Hd.DenStateFracLength=evaluatevars(source.StateFracLength2);
                end

                if strcmpi(Hd.OutputMode,'SpecifyPrecision')
                    Hd.OutputFracLength=evaluatevars(source.OutputFracLength1);
                end

                setIIRcommonPropertiesDfilt(source,Hd);
            case 'dfilt.df2tsos'

                if~Hd.CoeffAutoScale
                    Hd.ScaleValueFracLength=evaluatevars(source.CoeffFracLength3);
                end

                Hd.SectionInputWordLength=evaluatevars(source.SectionInputWordLength);
                Hd.SectionInputFracLength=evaluatevars(source.SectionInputFracLength1);
                Hd.SectionOutputWordLength=evaluatevars(source.SectionOutputWordLength);
                Hd.SectionOutputFracLength=evaluatevars(source.SectionOutputFracLength1);
                Hd.OutputMode=strrep(source.OutputMode,' ','');
                Hd.StateWordLength=evaluatevars(source.StateWordLength1);
                Hd.StateAutoScale=strcmpi(source.StateMode,'specify word length');

                if~Hd.StateAutoScale
                    Hd.StateFracLength=evaluatevars(source.StateFracLength1);
                end

                if strcmpi(Hd.OutputMode,'SpecifyPrecision')
                    Hd.OutputFracLength=evaluatevars(source.OutputFracLength1);
                end

                setIIRcommonPropertiesDfilt(source,Hd);
            case 'dfilt.df1'

                Hd.OutputFracLength=evaluatevars(source.OutputFracLength1);

                setIIRcommonPropertiesDfilt(source,Hd);

            case 'dfilt.df2'

                Hd.OutputMode=strrep(source.OutputMode,' ','');
                Hd.StateWordLength=evaluatevars(source.StateWordLength1);
                Hd.StateFracLength=evaluatevars(source.StateFracLength1);

                if strcmpi(Hd.OutputMode,'SpecifyPrecision')
                    Hd.OutputFracLength=evaluatevars(source.OutputFracLength1);
                end

                setIIRcommonPropertiesDfilt(source,Hd);

            case 'dfilt.df1t'

                Hd.OutputMode=strrep(source.OutputMode,' ','');
                Hd.StateWordLength=evaluatevars(source.StateWordLength1);
                Hd.MultiplicandWordLength=evaluatevars(source.MultiplicandWordLength);
                Hd.MultiplicandFracLength=evaluatevars(source.MultiplicandFracLength1);
                Hd.StateAutoScale=strcmpi(source.StateMode,'specify word length');

                if~Hd.StateAutoScale
                    Hd.NumStateFracLength=evaluatevars(source.StateFracLength1);
                    Hd.DenStateFracLength=evaluatevars(source.StateFracLength2);
                end

                setIIRcommonPropertiesDfilt(source,Hd);

            case 'dfilt.df2t'
                Hd.OutputFracLength=evaluatevars(source.OutputFracLength1);
                Hd.StateWordLength=evaluatevars(source.StateWordLength1);
                Hd.StateAutoScale=strcmpi(source.StateMode,'specify word length');

                if~Hd.StateAutoScale
                    Hd.StateFracLength=evaluatevars(source.StateFracLength1);
                end

                setIIRcommonPropertiesDfilt(source,Hd);
            case 'dfilt.delay'

            case{'farrow.fd','dfilt.farrowfd'}
                Hd.FilterInternals=source.FilterInternals(1:4);
                Hd.FDWordLength=evaluatevars(source.FDWordLength);
                Hd.FDAutoScale=~strncmpi(source.FDMode,'binary',6);

                if~Hd.CoeffAutoScale
                    Hd.CoeffFracLength=evaluatevars(source.CoeffFracLength1);
                end

                if~Hd.FDAutoScale
                    Hd.FDFracLength=evaluatevars(source.FDFracLength1);
                end

                if strncmpi(Hd.FilterInternals,'spec',4)
                    Hd.ProductWordLength=evaluatevars(source.ProductWordLength);
                    Hd.ProductFracLength=evaluatevars(source.ProductFracLength1);
                    Hd.AccumWordLength=evaluatevars(source.AccumWordLength);
                    Hd.AccumFracLength=evaluatevars(source.AccumFracLength1);
                    Hd.OutputWordLength=evaluatevars(source.OutputWordLength);
                    Hd.OutputFracLength=evaluatevars(source.OutputFracLength1);
                    Hd.MultiplicandWordLength=evaluatevars(source.MultiplicandWordLength);
                    Hd.MultiplicandFracLength=evaluatevars(source.MultiplicandFracLength1);
                    Hd.FDProdWordLength=evaluatevars(source.FDProdWordLength);
                    Hd.FDProdFracLength=evaluatevars(source.FDProdFracLength1);
                    Hd.OverflowMode=source.OverflowMode;
                    Hd.RoundMode=convertRoundModeDfilt(source);
                end
            otherwise
                fprintf('''%s'' not supported yet.\n',class(Hd));
            end
        end


        function applySettingsSysObj(this,Hd)



            if isa(Hd,'dsp.FilterCascade')


                for indx=1:getNumStages(Hd)
                    applySettingsSysObj(this,Hd.(sprintf('Stage%d',indx)));
                end
                return;
            end


            source=get(this,'LastAppliedState');
            if isempty(source)
                source=this;
            end



            if~strcmpi('fixed point',source.Arithmetic)
                return;
            end

            if source.FIRFlag


                setNumericType(source,Hd,'CoefficientsDataType','CoeffMode',...
                'CoeffWordLength','CoeffFracLength1','CoeffSignedSysObj','CoeffSigned');


                if strcmp(source.FilterInternals,'Full precision')
                    Hd.FullPrecisionOverride=true;
                    return;
                else
                    Hd.FullPrecisionOverride=false;
                end


                setNumericType(source,Hd,'ProductDataType','ProductMode',...
                'ProductWordLength','ProductFracLength1','ProductSignedSysObj',...
                'ProductSigned');



                setNumericType(source,Hd,'AccumulatorDataType','AccumMode',...
                'AccumWordLength','AccumFracLength1','AccumSignedSysObj','AccumSigned');


                setNumericType(source,Hd,'OutputDataType','OutputMode',...
                'OutputWordLength','OutputFracLength1','OutputSignedSysObj',...
                'OutputSigned');

            else

                if any(strcmpi({'cicdecim','cicinterp'},this.Structure))

                    Hd.FixedPointDataType=mapCICFilterInternals(source.FilterInternals);

                    props=getActiveProps(Hd,'fixed');

                    for idx=1:length(props)
                        switch props{idx}
                        case 'SectionWordLengths'
                            Hd.SectionWordLengths=evaluatevars(source.SectionsWordLength);
                        case 'SectionFractionLengths'
                            Hd.SectionFractionLengths=evaluatevars(source.SectionsFracLength1);
                        case 'OutputWordLength'
                            Hd.OutputWordLength=evaluatevars(source.OutputWordLength);
                        case 'OutputFractionLength'
                            Hd.OutputFractionLength=evaluatevars(source.OutputFracLength1);
                        end
                    end

                else

                    isSOS=any(strcmpi({'df1sos','df1tsos','df2sos','df2tsos'},this.Structure));


                    setNumericType(source,Hd,'NumeratorCoefficientsDataType','CoeffMode',...
                    'CoeffWordLength','CoeffFracLength1','CoeffSignedSysObj','CoeffSigned');

                    setNumericType(source,Hd,'DenominatorCoefficientsDataType','CoeffMode',...
                    'CoeffWordLength','CoeffFracLength2','CoeffSignedSysObj','CoeffSigned');

                    if isSOS
                        setNumericType(source,Hd,'ScaleValuesDataType','CoeffMode',...
                        'CoeffWordLength','CoeffFracLength3','CoeffSignedSysObj','CoeffSigned');



                        setNumericType(source,Hd,'SectionInputDataType','SectionInputMode',...
                        'SectionInputWordLength','SectionInputFracLength1','autosigned');


                        setNumericType(source,Hd,'SectionOutputDataType','SectionOutputMode',...
                        'SectionOutputWordLength','SectionOutputFracLength1','autosigned');
                    end


                    setNumericType(source,Hd,'NumeratorProductDataType','ProductMode',...
                    'ProductWordLength','ProductFracLength1','ProductSignedSysObj',...
                    'ProductSigned');

                    setNumericType(source,Hd,'DenominatorProductDataType','ProductMode',...
                    'ProductWordLength','ProductFracLength2','ProductSignedSysObj',...
                    'ProductSigned');


                    setNumericType(source,Hd,'NumeratorAccumulatorDataType','AccumMode',...
                    'AccumWordLength','AccumFracLength1','AccumSignedSysObj','AccumSigned');

                    setNumericType(source,Hd,'DenominatorAccumulatorDataType','AccumMode',...
                    'AccumWordLength','AccumFracLength2','AccumSignedSysObj','AccumSigned');


                    setNumericType(source,Hd,'OutputDataType','OutputMode',...
                    'OutputWordLength','OutputFracLength1','OutputSignedSysObj',...
                    'OutputSigned');

                    if any(strcmp({'df2sos','df2tsos','df2','df2t'},this.Structure))


                        setNumericType(source,Hd,'StateDataType','StateMode',...
                        'StateWordLength1','StateFracLength1','autosigned');
                    end

                    if strcmp('df1t',this.Structure)

                        setNumericType(source,Hd,'StateDataType','StateMode',...
                        'StateWordLength1','StateFracLength1','autosigned');


                        setNumericType(source,Hd,'MultiplicandDataType','MultiplicandMode',...
                        'MultiplicandWordLength','MultiplicandFracLength1','autosigned');
                    end

                    if strcmp('df1tsos',this.Structure)

                        setNumericType(source,Hd,'NumeratorStateDataType','StateMode',...
                        'StateWordLength1','StateFracLength1','autosigned');

                        setNumericType(source,Hd,'DenominatorStateDataType','StateMode',...
                        'StateWordLength1','StateFracLength2','autosigned');


                        setNumericType(source,Hd,'MultiplicandDataType','MultiplicandMode',...
                        'MultiplicandWordLength','MultiplicandFracLength1','autosigned');
                    end
                end
            end



            props=getActiveProps(Hd,'fixed');
            if any(strcmp(props,'RoundingMethod'))
                Hd.RoundingMethod=source.RoundMode;
            end
            if any(strcmp(props,'OverflowAction'))
                Hd.OverflowAction=source.OverflowMode;
            end
        end


        function captureState(this)




            set(this,'LastAppliedState',get(this));


        end


        function disp(this)




            disp(get(this));


        end


        function Hs=getDfiltObject(this,Hd,varargin)




            if isa(Hd,'dfilt.basefilter')
                Hs=Hd;
                return;
            end

            idx=strfind(this.Arithmetic,' ');
            arith=lower(this.Arithmetic(1:idx-1));

            if isa(Hd,'dsp.FilterCascade')



                w=warning('off','dsp:mfilt:mfilt:Obsolete');
                restoreWarn=onCleanup(@()warning(w));


                Hs=mfilt.cascade;%#ok<MCASCADE>
                Hs.removestage(1:2);


                for indx=1:getNumStages(Hd)
                    if indx==1||~strcmp(arith,'fixed')

                        mfiltStage=getDfiltObject(this,Hd.(sprintf('Stage%d',indx)));
                    else


                        IWL=Hs.Stage(indx-1).OutputWordLength;
                        IFL=Hs.Stage(indx-1).OutputFracLength;
                        mfiltStage=getDfiltObject(this,Hd.(sprintf('Stage%d',indx)),IWL,IFL);
                    end
                    Hs.addstage(mfiltStage);
                end
            else
                if~strcmp(arith,'fixed')
                    Hs=todfilt(Hd,arith);
                else
                    if nargin==2
                        IWL=str2double(this.InputWordLength);
                        IFL=str2double(this.InputFracLength1);
                    else
                        IWL=varargin{1};
                        IFL=varargin{2};
                    end

                    inputnumerictype=numerictype(1,IWL,IFL);

                    Hd_temp=clone(Hd);
                    ipval=getHdlipval(Hd_temp,inputnumerictype);
                    release(Hd_temp);
                    step(Hd_temp,ipval);
                    Hs=todfilt(Hd_temp,arith);
                end
            end
        end


        function dlg=getDialogSchema(this,~)




            items=getDialogSchemaStruct(this);

            dlg.DialogTitle='Data types';
            dlg.Items={items};


        end


        function dlg=getDialogSchemaStruct(this)



            arithlabel.Type='text';
            arithlabel.Name=FilterDesignDialog.message('arithmeticLabelName');
            arithlabel.Tag='ArithmeticLabel';
            arithlabel.RowSpan=[1,1];
            arithlabel.ColSpan=[1,1];

            arith.Type='combobox';
            arith.Tag='Arithmetic';
            arith.Source=this;
            arith.DialogRefresh=true;
            arith.RowSpan=[1,1];
            arith.ColSpan=[2,2];
            arith.Enabled=isfdtbxinstalled;

            arithModes=this.ArithmeticSet;
            arithIDs={'double','single','fixpt'};

            if~isfixptinstalled
                arithModes(end)=[];
                arithIDs(end)=[];
            end

            if~isSupportedStructure(this)


                arithIDs={'double','double','double'};
                arith.Enabled=false;
            end

            arith.Entries=FilterDesignDialog.message(arithIDs);

            defaultindx=find(strcmpi(arithModes,this.Arithmetic));
            if~isempty(defaultindx)
                arith.Value=defaultindx-1;
            end

            arith.ObjectMethod='selectComboboxEntry';
            arith.MethodArgs={'%dialog','%value','Arithmetic',arithModes};
            arith.ArgDataTypes={'handle','mxArray','string','mxArray'};


            if any(strcmpi(this.Structure,{'cicdecim','cicinterp'}))
                arith.Enabled=false;
            end

            spacer.Type='text';
            spacer.Name=' ';
            spacer.RowSpan=[2,2];
            spacer.ColSpan=[1,1];
            spacer.MaximumSize=[10,10];

            items={arithlabel,arith,spacer};

            if strcmpi(this.Arithmetic,'fixed point')

                modelabel.Type='text';
                modelabel.Name=FilterDesignDialog.message('modeLabelTxt');
                modelabel.RowSpan=[1,1];
                modelabel.ColSpan=[2,2];
                modelabel.Alignment=6;

                signlabel.Type='text';
                signlabel.Name=FilterDesignDialog.message('signLabelTxt');
                signlabel.RowSpan=[1,1];
                signlabel.ColSpan=[3,3];
                signlabel.Alignment=6;

                wordlabel.Type='text';
                wordlabel.Name=FilterDesignDialog.message('wordLabelTxt');
                wordlabel.RowSpan=[1,1];
                wordlabel.ColSpan=[4,4];
                wordlabel.Alignment=6;

                fraclabel.Type='text';
                fraclabel.Name=FilterDesignDialog.message('fracLabelTxt');
                fraclabel.RowSpan=[1,1];
                fraclabel.ColSpan=[5,5];
                fraclabel.Alignment=6;

                opts=struct('Name','InputSignalName','Tag','Input',...
                'Row',3,'Mode','BinaryPointScaling');
                [label,mode,signed,word,frac]=getFormatRow(this,opts);
                visibleFlag=true;

                label.Visible=visibleFlag;
                mode.Visible=visibleFlag;
                signed.Visible=visibleFlag;
                word.Visible=visibleFlag;
                frac.Visible=visibleFlag;

                showOperationParameters=true;
                this.FxPtRestrictions=getFxPtRestrictions(this);
                this.FIRFlag=false;
                this.SOSFlag=false;
                this.IIRFlag=false;
                switch this.Structure
                case{'dffir','dffirt','dfsymfir','dfasymfir','firdecim',...
                    'firtdecim','firinterp','firsrc'}
                    this.FIRFlag=true;
                    struct_items=getFIRItems(this,4);



                    if strcmpi(this.FilterInternals,'full precision')
                        showOperationParameters=false;
                    else
                        showOperationParameters=isShowOperationParameters(this);
                    end

                case 'df1'
                    this.IIRFlag=true;
                    struct_items=getDF1Items(this,5);
                case 'df2'
                    this.IIRFlag=true;
                    struct_items=getDF2Items(this,4);
                case 'df1t'
                    this.IIRFlag=true;
                    struct_items=getDF1TItems(this,4);
                case 'df2t'
                    this.IIRFlag=true;
                    struct_items=getDF2TItems(this,4);
                case 'df1sos'
                    this.SOSFlag=true;
                    struct_items=getDF1SOSItems(this,4);
                case 'df2sos'
                    this.SOSFlag=true;
                    struct_items=getDF2SOSItems(this,4);
                case 'df2tsos'
                    this.SOSFlag=true;
                    struct_items=getDF2TSOSItems(this,4);
                case 'df1tsos'
                    this.SOSFlag=true;
                    struct_items=getDF1TSOSItems(this,4);
                case{'cicdecim','cicinterp'}
                    struct_items=getCICItems(this,4);
                    showOperationParameters=false;
                case{'fd','farrowfd'}
                    struct_items=getFDItems(this,4);
                    if strcmpi(this.FilterInternals,'full precision')
                        showOperationParameters=false;
                    end

                otherwise
                    fprintf('%s not completed yet.',this.Structure);
                end




                dtype.Type='group';
                dtype.Name=FilterDesignDialog.message('FixedPtDType');
                dtype.Items=[{modelabel,signlabel,wordlabel,fraclabel,spacer...
                ,label,mode,signed,word,frac},struct_items];
                dtype.RowSpan=[3,3];
                dtype.ColSpan=[1,3];
                dtype.LayoutGrid=[20,5];
                dtype.RowStretch=[zeros(1,19),1];
                dtype.ColStretch=[0,0,0,1,1];

                items=[items,{dtype}];

                if showOperationParameters
                    opParams=getFixptOperationalParameters(this,4);
                    items=[items,{opParams}];
                end
            end

            dlg.Type='group';
            dlg.Items=items;
            dlg.RowStretch=[zeros(1,4),1];
            dlg.ColStretch=[0,0,1];
            dlg.LayoutGrid=[5,3];
        end


        function fpRestriction=getFxPtRestrictions(this,prop,restrictType)






            if nargin<2||isa(prop,'dsp.internal.FilterAnalysis')
                fpRestriction=struct;
                if this.SystemObject
                    if nargin>1&&isa(prop,'dsp.internal.FilterAnalysis')
                        sysObj=prop;
                    else
                        switch lower(this.Structure)
                        case{'dffir','dffirt','dfsymfir','dfasymfir'}
                            sysObj=dsp.FIRFilter;
                        case{'firdecim','firtdecim'}
                            sysObj=dsp.FIRDecimator;
                        case 'firinterp'
                            sysObj=dsp.FIRInterpolator;
                        case 'firsrc'
                            sysObj=dsp.FIRRateConverter;
                        case{'df1sos','df1tsos','df2sos','df2tsos'}
                            sysObj=dsp.BiquadFilter;
                        case{'df1','df1t','df2','df2t'}
                            sysObj=dsp.IIRFilter;
                        otherwise
                            return;
                        end
                    end
                    props=getFixedPointProperties(sysObj);
                    idx=strncmp('Custom',props,6);
                    props(~idx)=[];
                    for idx=1:length(props)
                        fpRestriction.(props{idx})=getFixedPointRestrictions(sysObj,props{idx});
                    end
                end
            else
                restrNames=fieldnames(this.FxPtRestrictions);
                idx=find(strcmp(restrNames,prop));
                if isempty(idx)
                    error(FilterDesignDialog.message('RestrictionNotFound',prop))
                end
                fpRestriction=this.FxPtRestrictions.(restrNames{idx});

                switch restrictType
                case 'signedness'
                    fpRestriction=fpRestriction{1};
                case 'scaling'
                    if length(fpRestriction)>1
                        fpRestriction=fpRestriction{2};
                    else
                        fpRestriction='SPECSCALED';
                    end
                otherwise
                    error(FilterDesignDialog.message('InvalidRestrictionType',restrictType))
                end
            end

        end


        function hBuffer=getMCodeBuffer(this,Hd,varargin)




            laState=this.LastAppliedState;
            if isempty(laState)
                laState=this;
            end

            if~isempty(varargin)
                hBuffer=varargin{1};
            else
                hBuffer=sigcodegen.mcodebuffer;
            end

            if laState.SystemObject
                if strcmpi('fixed point',laState.Arithmetic)
                    addFixedPointSysObj(laState,hBuffer,Hd,'Hd');
                end
            else

                switch lower(laState.Arithmetic)
                case 'double precision'

                case 'single precision'
                    if isa(Hd,'dfilt.multistage')
                        for indx=1:numel(Hd.Stage)
                            if isa(Hd.Stage(indx),'dfilt.multistage')
                                hBuffer.add(['set(',sprintf('Hd.Stage(%d).Stage,',indx),'''Arithmetic'', ''single'');']);
                                hBuffer.cr;
                            else
                                hBuffer.add(['set(',sprintf('Hd.Stage(%d),',indx),'''Arithmetic'', ''single'');']);
                            end
                        end
                    else
                        hBuffer.add('set(Hd, ''Arithmetic'', ''single'');');
                    end

                case 'fixed point'
                    if isa(Hd,'dfilt.multistage')
                        for indx=1:numel(Hd.Stage)
                            if isa(Hd.Stage(indx),'dfilt.multistage')
                                for k=1:numel(Hd.Stage(indx).Stage)
                                    addFixedPoint(laState,hBuffer,...
                                    sprintf('Hd.Stage(%d).Stage(%d)',indx,k),...
                                    class(Hd.Stage(indx).Stage(k)));
                                    hBuffer.cr;
                                end
                            else
                                addFixedPoint(laState,hBuffer,...
                                sprintf('Hd.Stage(%d)',indx),class(Hd.Stage(indx)));
                                hBuffer.cr;
                            end
                        end
                    else
                        addFixedPoint(laState,hBuffer,'Hd',class(Hd));
                    end
                end
            end
        end


        function b=isSupportedStructure(this,Hd)




            if nargin>1
                if ischar(Hd)
                    structure=Hd;
                else
                    structure=class(Hd);
                    structure=strsplit(structure,'.');
                    structure=structure{2};
                end
            else
                structure=get(this,'Structure');
            end



            b=any(strcmpi(structure,{'df1sos','df1','df1t','df1tsos','dffir','df2'...
            ,'dfasymfir','df2sos','latticeallpass','df2tsos','dffirt','df2t'...
            ,'dfsymfir','latticear','cicdecim','cicinterp','firdecim','firsrc'...
            ,'holdinterp','linearinterp','firinterp','firtdecim','latticemamax'...
            ,'latticemamin','latticearma','scalar','delay','fd','farrowfd'}));


        end


        function selectComboboxEntry(this,hdlg,indx,prop,options)%#ok<INUSL>




            set(this,prop,options{indx+1});


        end


        function updateSettings(this,Hd)



            if isa(Hd,'dfilt.basefilter')
                updateSettingsDfilt(this,Hd);
            else
                updateSettingsSysObj(this,Hd);
            end

        end


        function updateSettingsDfilt(this,Hd)






            hfmethod=getfmethod(Hd);
            if isempty(hfmethod)
                structure=getClassName(Hd);
            elseif strcmpi(hfmethod.DesignAlgorithm,'multistage equiripple')||...
                any(strcmpi(hfmethod.FilterStructure,{'cascadeallpass','cascadewdfallpass'}))
                structure=hfmethod.FilterStructure;
            else
                structure=getClassName(Hd);
            end
            set(this,'Structure',structure);

            if~isSupportedStructure(this)
                return;
            end

            if isa(Hd,'dfilt.multistage')


                updateSettings(this,Hd.Stage(1));
                return;
            end

            set(this,'Arithmetic',Hd.Arithmetic);

            if~strcmpi(Hd.Arithmetic,'fixed')
                return;
            end

            set(this,...
            'InputWordLength',mat2str(Hd.InputWordLength),...
            'InputFracLength1',mat2str(Hd.InputFracLength));


            if~any(strcmpi(class(Hd),{'mfilt.cicdecim','dsp.internal.mfilt.cicinterp'}))
                if Hd.Signed
                    cSigned='on';
                else
                    cSigned='off';
                end
                if Hd.CoeffAutoScale
                    cMode='Specify word length';
                else
                    cMode='Binary point scaling';
                end
                set(this,...
                'CoeffWordLength',mat2str(Hd.CoeffWordLength),...
                'CoeffSigned',cSigned,...
                'CoeffMode',cMode);
            end

            switch class(Hd)
            case{'mfilt.cicdecim','dsp.internal.mfilt.cicinterp'}

                swl=Hd.SectionWordLengths;
                if length(unique(swl))==1
                    swl=swl(1);
                end

                sfl=Hd.SectionFracLengths;
                if length(unique(sfl))==1
                    sfl=sfl(1);
                end

                set(this,'FilterInternals',mapFilterInternalsDfilt1(Hd.FilterInternals));
                switch lower(Hd.FilterInternals)
                case 'minwordlengths'
                    set(this,'OutputWordLength',mat2str(Hd.OutputWordLength));
                case 'specifywordlengths'
                    set(this,...
                    'SectionsWordLength',mat2str(swl),...
                    'OutputWordLength',mat2str(Hd.OutputWordLength));
                case 'specifyprecision'
                    set(this,...
                    'SectionsWordLength',mat2str(swl),...
                    'SectionsFracLength1',mat2str(sfl),...
                    'OutputWordLength',mat2str(Hd.OutputWordLength),...
                    'OutputFracLength1',mat2str(Hd.OutputFracLength));
                end

            case{'dfilt.dffir','dfilt.dffirt','dfilt.dfsymfir','dfilt.dfasymfir',...
                'mfilt.firdecim','dsp.internal.mfilt.firinterp','mfilt.firtdecim','mfilt.firsrc'}

                set(this,...
                'FilterInternals',mapFilterInternalsDfilt1(Hd.FilterInternals),...
                'CoeffFracLength1',mat2str(Hd.NumFracLength),...
                'ProductWordLength',mat2str(Hd.ProductWordLength),...
                'ProductFracLength1',mat2str(Hd.ProductFracLength),...
                'AccumWordLength',mat2str(Hd.AccumWordLength),...
                'AccumFracLength1',mat2str(Hd.AccumFracLength),...
                'OutputWordLength',mat2str(Hd.OutputWordLength),...
                'OutputFracLength1',mat2str(Hd.OutputFracLength),...
                'OverflowMode',Hd.OverflowMode,...
                'RoundMode',convertRoundModeDfilt1(Hd));
            case 'dfilt.df1'
                setIIRcommonPropertiesDfilt1(this,Hd);
            case 'dfilt.df2'

                set(this,...
                'OutputMode',convertOutputModeDfilt1(Hd),...
                'StateWordLength1',mat2str(Hd.StateWordLength),...
                'StateFracLength1',mat2str(Hd.StateFracLength));

                setIIRcommonPropertiesDfilt1(this,Hd);
            case 'dfilt.df1t'
                set(this,...
                'OutputMode',convertOutputModeDfilt1(Hd),...
                'MultiplicandWordLength',mat2str(Hd.MultiplicandWordLength),...
                'MultiplicandFracLength1',mat2str(Hd.MultiplicandFracLength),...
                'StateWordLength1',mat2str(Hd.StateWordLength),...
                'StateMode',convertAutoscale(Hd.StateAutoScale),...
                'StateFracLength1',mat2str(Hd.NumStateFracLength),...
                'StateFracLength2',mat2str(Hd.DenStateFracLength));

                setIIRcommonPropertiesDfilt1(this,Hd);

            case 'dfilt.df2t'
                set(this,...
                'StateWordLength1',mat2str(Hd.StateWordLength),...
                'StateFracLength1',mat2str(Hd.StateFracLength));

                setIIRcommonPropertiesDfilt1(this,Hd);

            case 'dfilt.df1sos'
                set(this,...
                'CoeffFracLength3',mat2str(Hd.ScaleValueFracLength),...
                'StateWordLength1',mat2str(Hd.NumStateWordLength),...
                'StateFracLength1',mat2str(Hd.NumStateFracLength),...
                'StateWordLength2',mat2str(Hd.DenStateWordLength),...
                'StateFracLength2',mat2str(Hd.DenStateFracLength),...
                'OutputMode',convertOutputModeDfilt1(Hd));

                setIIRcommonPropertiesDfilt1(this,Hd);

            case 'dfilt.df2sos'
                set(this,...
                'CoeffFracLength3',mat2str(Hd.ScaleValueFracLength),...
                'SectionInputWordLength',mat2str(Hd.SectionInputWordLength),...
                'SectionInputMode',convertAutoscale(Hd.SectionInputAutoScale),...
                'SectionInputFracLength1',mat2str(Hd.SectionInputFracLength),...
                'SectionOutputWordLength',mat2str(Hd.SectionOutputWordLength),...
                'SectionOutputMode',convertAutoscale(Hd.SectionOutputAutoScale),...
                'SectionOutputFracLength1',mat2str(Hd.SectionOutputFracLength),...
                'StateWordLength1',mat2str(Hd.StateWordLength),...
                'StateFracLength1',mat2str(Hd.StateFracLength),...
                'OutputMode',convertOutputModeDfilt1(Hd));

                setIIRcommonPropertiesDfilt1(this,Hd);

            case 'dfilt.df1tsos'

                set(this,...
                'CoeffFracLength3',mat2str(Hd.ScaleValueFracLength),...
                'SectionInputWordLength',mat2str(Hd.SectionInputWordLength),...
                'SectionInputMode',convertAutoscale(Hd.SectionInputAutoScale),...
                'SectionInputFracLength1',mat2str(Hd.SectionInputFracLength),...
                'SectionOutputWordLength',mat2str(Hd.SectionOutputWordLength),...
                'SectionOutputMode',convertAutoscale(Hd.SectionOutputAutoScale),...
                'SectionOutputFracLength1',mat2str(Hd.SectionOutputFracLength),...
                'StateWordLength1',mat2str(Hd.StateWordLength),...
                'StateMode',convertAutoscale(Hd.StateAutoScale),...
                'StateFracLength1',mat2str(Hd.NumStateFracLength),...
                'StateFracLength2',mat2str(Hd.DenStateFracLength),...
                'OutputMode',convertOutputModeDfilt1(Hd));

                setIIRcommonPropertiesDfilt1(this,Hd);

            case 'dfilt.df2tsos'
                set(this,...
                'CoeffFracLength3',mat2str(Hd.ScaleValueFracLength),...
                'SectionInputWordLength',mat2str(Hd.SectionInputWordLength),...
                'SectionInputFracLength1',mat2str(Hd.SectionInputFracLength),...
                'SectionOutputWordLength',mat2str(Hd.SectionOutputWordLength),...
                'SectionOutputFracLength1',mat2str(Hd.SectionOutputFracLength),...
                'StateWordLength1',mat2str(Hd.StateWordLength),...
                'StateMode',convertAutoscale(Hd.StateAutoScale),...
                'StateFracLength1',mat2str(Hd.StateFracLength),...
                'OutputMode',convertOutputModeDfilt1(Hd));

                setIIRcommonPropertiesDfilt1(this,Hd);

            case{'farrow.fd','dfilt.farrowfd'}
                set(this,...
                'CoeffFracLength1',mat2str(Hd.CoeffFracLength),...
                'FDWordLength',mat2str(Hd.FDWordLength),...
                'FDMode',convertAutoscale(Hd.FDAutoScale),...
                'FDFracLength1',mat2str(Hd.FDFracLength),...
                'FilterInternals',mapFilterInternalsDfilt1(Hd.FilterInternals),...
                'ProductWordLength',mat2str(Hd.ProductWordLength),...
                'ProductFracLength1',mat2str(Hd.ProductFracLength),...
                'AccumWordLength',mat2str(Hd.AccumWordLength),...
                'AccumFracLength1',mat2str(Hd.AccumFracLength),...
                'OutputWordLength',mat2str(Hd.OutputWordLength),...
                'OutputFracLength1',mat2str(Hd.OutputFracLength),...
                'MultiplicandWordLength',mat2str(Hd.MultiplicandWordLength),...
                'MultiplicandFracLength1',mat2str(Hd.MultiplicandFracLength),...
                'FDProdWordLength',mat2str(Hd.FDProdWordLength),...
                'FDProdFracLength1',mat2str(Hd.FDProdFracLength),...
                'OverflowMode',Hd.OverflowMode,...
                'RoundMode',convertRoundModeDfilt1(Hd));

            otherwise
                fprintf('''%s'' not supported yet.\n',class(Hd));
            end
        end


        function updateSettingsSysObj(this,Hd)



            if isa(Hd,'dsp.FilterCascade')

                updateSettingsSysObj(this,Hd.Stage1);
                return;
            end

            if isa(Hd,'dsp.CoupledAllpassFilter')

                return;
            end


            setStructure(this,Hd);


            setProperties(this,Hd)




            if isDefaultFixedPointSettings(this,Hd)&&~any(strcmpi(this.Structure,{'cicdecim','cicinterp'}))
                this.Arithmetic='Double precision';
            else
                this.Arithmetic='Fixed point';
            end
        end


        function structure=set_structure(this,structure)


            if any(strcmpi(structure,{'cicdecim','cicinterp'}))
                this.Arithmetic='fixed';
                this.FIRFlag=false;
                return
            end


            if~isSupportedStructure(this,structure)
                this.Arithmetic='double';
            end
        end

        function setPropValue(this,propName,propValue)
            if any(strcmpi(propName,{'SystemObject','FullPrecisionOverride','FIRFlag','IIRFlag'}))&&ischar(propValue)
                if strcmpi(propValue,'1')
                    propValue=true;
                else
                    propValue=false;
                end
                if all((propValue~=this.(propName)))
                    this.(propName)=propValue;
                end
            elseif any(strcmpi(propName,{'CoeffSigned','CastBeforeSum','ProductSigned','AccumSigned','OutputSigned'}))&&ischar(propValue)
                if strcmpi(propValue,'1')
                    propValue='on';
                else
                    propValue='off';
                end
                this.(propName)=propValue;


            elseif any(strcmpi(propName,{'Structure','Arithmetic','CoeffMode','FDMode','FilterInternals','StateMode','SectionInputMode',...
                'SectionOutputMode','ProductMode','AccumMode','RoundMode','OutputMode',...
                'OverflowMode','MultiplicandMode'}))
                entry_idx=find(contains(this.([propName,'Entries']),propValue));
                propValue=this.([propName,'Set']){entry_idx};%#ok<FNDSB>
                DAStudio.Protocol.setPropValue(this,propName,propValue);
            else
                DAStudio.Protocol.setPropValue(this,propName,propValue);
            end

        end

        function value=getPropValue(this,propName)
            if any(strcmpi(propName,{'CoeffSigned','CastBeforeSum','ProductSigned','AccumSigned','OutputSigned'}))
                if strcmpi(this.(propName),'on')
                    value='1';
                else
                    value='0';
                end
            elseif any(strcmpi(propName,{'Structure','Arithmetic','CoeffMode','FDMode','FilterInternals','StateMode','SectionInputMode',...
                'SectionOutputMode','ProductMode','AccumMode','RoundMode','OutputMode',...
                'OverflowMode','MultiplicandMode'}))
                value=DAStudio.Protocol.getPropValue(this,propName);
                set_idx=find(contains(this.([propName,'Set']),value));
                value=this.([propName,'Entries']){set_idx};%#ok<FNDSB>
            else
                value=DAStudio.Protocol.getPropValue(this,propName);
            end
        end

        function value=getPropDataType(~,propName)
            switch propName
            case{'SystemObject','SOSFlag','IIRFlag','FullPrecisionOverride',...
                'CoeffSigned','CastBeforeSum','FIRFlag','ProductSigned','AccumSigned',...
                'OutputSigned'}
                value='bool';
            case{'Structure','Arithmetic','InputWordLength',...
                'InputFracLength1','CoeffMode','CoeffWordLength',...
                'CoeffFracLength1','CoeffFracLength2','CoeffFracLength3',...
                'FDWordLength','FDMode','FDFracLength1','FilterInternals',...
                'StateWordLength1','StateWordLength2','StateMode',...
                'StateFracLength1','StateFracLength2','MultiplicandWordLength',...
                'MultiplicandFracLength1','SectionInputWordLength','SectionInputMode',...
                'SectionInputFracLength1','SectionOutputWordLength','SectionOutputMode',...
                'SectionOutputFracLength1','ProductMode','ProductWordLength',...
                'ProductFracLength1','ProductFracLength2','AccumMode',...
                'AccumWordLength','AccumFracLength1','AccumFracLength2',...
                'FDProdWordLength','FDProdFracLength1','SectionsWordLength',...
                'SectionsFracLength1','RoundMode','OverflowMode',...
                'OutputWordLength','OutputMode','OutputFracLength1','CoeffSignedSysObj',...
                'ProductSignedSysObj','AccumSignedSysObj',...
                'OutputSignedSysObj','MultiplicandMode'}
                value='string';
            end
        end


    end



    methods(Hidden)

        function items=getFDItems(this,startrow)

            opts.Row=startrow;


            items=getCoeffRow(this,opts);

            opts=struct('Row',opts.Row+1,'Name','FractionalDelay','Tag','FD');
            items=getAutoRow(this,opts,items);


            if strcmpi(this.FDMode,'specify word length')
                items{end-1}.Name=FilterDesignDialog.message('no');
            else
                items{end-2}.Name=FilterDesignDialog.message('no');
            end


            [fintlabel,fint]=getFilterInternals(this,opts.Row+1);

            items=[items,{fintlabel,fint}];


            if strcmpi(this.FilterInternals,'specify precision')

                opts=struct('Name','FixedPtProduct','Tag','Product','Row',fint.RowSpan(1)+1);
                items=getFormatRow(this,opts,items);

                opts=struct('Name','FixedPtAccum','Tag','Accum','Row',opts.Row+1);
                items=getFormatRow(this,opts,items);

                opts=struct('Name','Multiplicand','Tag','Multiplicand','Row',opts.Row+1);
                items=getFormatRow(this,opts,items);

                opts=struct('Name','FDProduct','Tag','FDProd','Row',opts.Row+1);
                items=getFormatRow(this,opts,items);

                opts=struct('Name','FixedPtOutput','Tag','Output','Row',opts.Row+1);
                items=getFormatRow(this,opts,items);
            end
        end


        function items=getDF1TItems(this,startrow)


            opts=struct('Row',startrow,'FracName',{{'Num.','Den.'}});
            items=getCoeffRow(this,opts);


            opts=struct('Row',opts.Row+1,'Name','Multiplicand','Tag','Multiplicand');
            if this.SystemObject
                items=getMultiplicandRow(this,opts,items);
            else
                items=getFormatRow(this,opts,items);
            end


            if this.SystemObject
                opts=struct('Row',opts.Row+1);
                items=getStateRow(this,opts,this.SystemObject,items);
            else
                opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
                items=getStateRow(this,opts,true,items);
            end


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getProductRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getAccumRow(this,opts,items);


            opts=struct('Row',opts.Row+1);
            items=getOutputRow(this,opts,items);
        end


        function items=getDF1Items(this,startrow)


            opts=struct('Row',startrow,'FracName',{{'Num.','Den.'}});
            items=getCoeffRow(this,opts);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getProductRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getAccumRow(this,opts,items);


            if this.SystemObject
                opts=struct('Row',opts.Row+1);
                items=getOutputRow(this,opts,items);
            else
                opts=struct('Row',opts.Row+1,'Name',...
                'FixedPtOutput','Tag','Output');
                items=getFormatRow(this,opts,items);
            end
        end


        function items=getDF2Items(this,startrow)


            opts=struct('Row',startrow,'FracName',{{'Num.','Den.'}});
            items=getCoeffRow(this,opts);


            opts=struct('Row',opts.Row+1);
            items=getStateRow(this,opts,this.SystemObject,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getProductRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getAccumRow(this,opts,items);


            opts=struct('Row',opts.Row+1);
            items=getOutputRow(this,opts,items);
        end


        function items=getDF2TItems(this,startrow)


            opts=struct('Row',startrow,'FracName',{{'Num.','Den.'}});
            items=getCoeffRow(this,opts);


            opts=struct('Row',opts.Row+1);
            items=getStateRow(this,opts,true,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getProductRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getAccumRow(this,opts,items);


            if this.SystemObject
                opts=struct('Row',opts.Row+1);
                items=getOutputRow(this,opts,items);
            else
                opts=struct('Row',opts.Row+1,'Name',...
                'FixedPtOutput','Tag','Output');
                items=getFormatRow(this,opts,items);
            end
        end


        function items=getDF1TSOSItems(this,startrow)


            opts=struct('Row',startrow,'FracName',{{'Num.','Den.','ScaleValue'}});
            items=getCoeffRow(this,opts);


            opts=struct('Row',opts.Row+1,'Name',...
            'SectionInput','Tag','SectionInput');
            items=getSectionRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'Name',...
            'SectionOutput','Tag','SectionOutput');
            items=getSectionRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getStateRow(this,opts,true,items);


            opts=struct('Row',opts.Row+1,'Name',...
            'Multiplicand','Tag','Multiplicand');
            items=getMultiplicandRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getProductRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getAccumRow(this,opts,items);


            opts=struct('Row',opts.Row+1);
            items=getOutputRow(this,opts,items);
        end


        function items=getDF2TSOSItems(this,startrow)


            opts=struct('Row',startrow,'FracName',{{'Num.','Den.','ScaleValue'}});
            items=getCoeffRow(this,opts);


            opts=struct('Row',opts.Row+1,'Name',...
            'SectionInput',...
            'Tag','SectionInput');
            if this.SystemObject
                items=getSectionRow(this,opts,items);
            else
                items=getFormatRow(this,opts,items);
            end


            opts=struct('Row',opts.Row+1,'Name','SectionOutput',...
            'Tag','SectionOutput');
            if this.SystemObject
                items=getSectionRow(this,opts,items);
            else
                items=getFormatRow(this,opts,items);
            end


            opts=struct('Row',opts.Row+1);
            items=getStateRow(this,opts,true,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getProductRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getAccumRow(this,opts,items);


            opts=struct('Row',opts.Row+1);
            items=getOutputRow(this,opts,items);
        end


        function items=getDF2SOSItems(this,startrow)


            opts=struct('Row',startrow,'FracName',{{'Num.','Den.','ScaleValue'}});
            items=getCoeffRow(this,opts);


            opts=struct('Row',opts.Row+1,'Name','SectionInput',...
            'Tag','SectionInput');
            items=getSectionRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'Name','SectionOutput',...
            'Tag','SectionOutput');
            items=getSectionRow(this,opts,items);


            opts=struct('Row',opts.Row+1);
            items=getStateRow(this,opts,this.SystemObject,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getProductRow(this,opts,items);


            opts=struct('Row',opts.Row+1,'FracName',{{'Num.','Den.'}});
            items=getAccumRow(this,opts,items);


            opts=struct('Row',opts.Row+1);
            items=getOutputRow(this,opts,items);
        end


        function items=getDF1SOSItems(this,startrow)


            opts=struct('Row',startrow,'FracName',{{'Num.','Den.','ScaleValue'}});
            items=getCoeffRow(this,opts);


            if this.SystemObject

                opts=struct('Row',opts.Row+1,'Name','SectionInput',...
                'Tag','SectionInput');
                items=getSectionRow(this,opts,items);


                opts=struct('Row',opts.Row+1,'Name','SectionOutput',...
                'Tag','SectionOutput');
                items=getSectionRow(this,opts,items);
            else
                opts=struct('Row',opts.Row+1,'Name',{{'NumState','DenState'}});
                items=getStateRow(this,opts,false,items);
            end


            opts=struct('Row',opts.Row+2,'FracName',{{'Num.','Den.'}});
            items=getProductRow(this,opts,items);


            opts=struct('Row',opts.Row+2,'FracName',{{'Num.','Den.'}});
            items=getAccumRow(this,opts,items);


            opts=struct('Row',opts.Row+1);
            items=getOutputRow(this,opts,items);
        end


        function items=getFIRItems(this,startrow)

            opts.Row=startrow;


            items=getCoeffRow(this,opts);


            [fintlabel,fint]=getFilterInternals(this,opts.Row+1);

            items=[items,{fintlabel,fint}];


            if strcmpi(this.FilterInternals,'specify precision')


                opts=struct('Name','FixedPtProduct',...
                'Tag','Product',...
                'Row',fint.RowSpan(1)+1);
                if~this.SystemObject
                    items=getFormatRow(this,opts,items);
                else
                    items=getProductRow(this,opts,items);
                end


                opts=struct('Name','FixedPtAccum',...
                'Tag','Accum','Row',opts.Row+1);
                if~this.SystemObject
                    items=getFormatRow(this,opts,items);
                else
                    items=getAccumRow(this,opts,items);
                end


                opts=struct('Name','FixedPtOutput',...
                'Tag','Output','Row',opts.Row+1);
                if~this.SystemObject
                    items=getFormatRow(this,opts,items);
                else
                    items=getOutputRow(this,opts,items);
                end
            end
        end


        function items=getCICItems(this,startrow)


            [fintlabel,fint]=getFilterInternals(this,startrow);

            items={fintlabel,fint};

            switch lower(this.FilterInternals)
            case 'minimum word lengths'
                opts=struct('Name','FixedPtOutput',...
                'Row',fint.RowSpan(1)+1,...
                'Tag','Output');

                [label,mode,signed,word]=getFormatRow(this,opts);
                mode.Name=FilterDesignDialog.message('SpecifyWordLength');
                items=[items,{label,mode,signed,word}];
            case 'specify word lengths'
                opts=struct('Name','FixedPtOutput',...
                'Row',fint.RowSpan(1)+1,'Tag','Output');

                [label,mode,signed,word]=getFormatRow(this,opts);
                mode.Name=FilterDesignDialog.message('SpecifyWordLength');
                items=[items,{label,mode,signed,word}];

                opts=struct('Name','Sections',...
                'Tag','Sections','Row',fint.RowSpan(1)+2);

                [label,mode,signed,word]=getFormatRow(this,opts);
                mode.Name=FilterDesignDialog.message('SpecifyWordLength');
                items=[items,{label,mode,signed,word}];

            case 'specify precision'
                opts=struct('Name','FixedPtOutput',...
                'Tag','Output','Row',fint.RowSpan(1)+1);


                [label,mode,signed,word,frac]=getFormatRow(this,opts);
                items=[items,{label,mode,signed,word,frac}];

                opts=struct('Name','Sections',...
                'Row',fint.RowSpan(1)+2,'Tag','Sections');


                [label,mode,signed,word,frac]=getFormatRow(this,opts);
                items=[items,{label,mode,signed,word,frac}];
            end
        end


        function[label,mode,signed,word,frac]=getFormatRow(this,opts,items)

            if nargin<3
                items={};
            end

            row=opts.Row;
            name=opts.Name;

            if isfield(opts,'Tag')
                tag=opts.Tag;
            else
                tag=strrep(name,' ','');
            end

            if isfield(opts,'FracName')
                fracNames=opts.FracName;
            else
                fracNames={tag};
            end

            enabState=isfdtbxinstalled;

            label.Type='text';
            label.Name=[FilterDesignDialog.message(name),' '];
            label.ColSpan=[1,1];
            label.RowSpan=[row,row];
            label.Tag=sprintf('%sLabel',tag);

            mode.Type='text';
            mode.Name=FilterDesignDialog.message('BinaryPointScaling');
            mode.ColSpan=[2,2];
            mode.RowSpan=[row,row];
            mode.Tag=sprintf('%sMode%s',tag,'_text');
            mode.Enabled=enabState;

            signed.Type='text';
            signed.Name=FilterDesignDialog.message('yes');
            signed.ColSpan=[3,3];
            signed.RowSpan=[row,row];
            signed.Alignment=6;
            signed.Tag=sprintf('%sSigned%s',tag,'_text');
            signed.Enabled=enabState;

            word.Type='edit';
            word.ObjectProperty=sprintf('%sWordLength',tag);
            word.Tag=sprintf('%sWordLength',tag);
            word.Source=this;
            word.ColSpan=[4,4];
            word.RowSpan=[row,row];
            word.Mode=true;
            word.Enabled=enabState;

            if length(fracNames)>1

                items=cell(1,2*numel(fracNames));
                for indx=1:numel(fracNames)

                    itemlabel.Type='text';

                    itemlabel.Name=sprintf('%s: ',...
                    FilterDesignDialog.message(strrep(fracNames{indx},'.','')));
                    itemlabel.ColSpan=[1,1];
                    itemlabel.RowSpan=[indx,indx];
                    itemlabel.Tag=sprintf('%sFracLengthLabel%d',tag,indx);

                    item.Type='edit';
                    item.ObjectProperty=sprintf('%sFracLength%d',tag,indx);
                    item.Tag=sprintf('%sFracLength%d',tag,indx);
                    item.Source=this;
                    item.ColSpan=[2,2];
                    item.RowSpan=[indx,indx];
                    item.Mode=true;
                    item.Enabled=enabState;

                    items{2*indx-1}=itemlabel;
                    items{2*indx}=item;
                end

                frac.Type='panel';
                frac.Items=items;
                frac.LayoutGrid=[length(fracNames),2];
                frac.Tag=sprintf('%sFracLengthPanel',tag);
            else
                frac.Type='edit';
                frac.ObjectProperty=sprintf('%sFracLength1',tag);
                frac.Tag=sprintf('%sFracLength1',tag);
                frac.Source=this;
                frac.Mode=true;
                frac.Enabled=enabState;
            end
            frac.ColSpan=[5,5];
            frac.RowSpan=[row,row];

            if nargout==1
                label=[items,{label,mode,signed,word,frac}];
            end
        end


        function fixptparam=getFixptOperationalParameters(this,row)

            enabState=isfdtbxinstalled;

            rmode.Name=FilterDesignDialog.message('FixedPtRoundMode');
            rmode.Type='combobox';
            rmode.RowSpan=[1,1];
            rmode.ColSpan=[1,1];
            rmode.Source=this;
            rmode.Tag='RoundMode';

            entries=this.RoundModeSet;
            if~this.SystemObject
                idx=strcmp(entries,'Simplest');
                entries(idx)=[];
            end
            rmode.Entries=getEntries(entries);
            rmode.ObjectMethod='selectComboboxEntry';
            rmode.MethodArgs={'%dialog','%value','RoundMode',entries};
            rmode.ArgDataTypes={'handle','mxArray','string','mxArray'};


            defaultindx=find(strcmpi(entries,this.RoundMode));
            if~isempty(defaultindx)
                rmode.Value=defaultindx-1;
            else
                this.RoundMode=entries{1};
            end

            rmode.Enabled=enabState;
            rmode.Mode=true;

            omode.Name=FilterDesignDialog.message('FixedPtOverflowMode');
            omode.Type='combobox';
            omode.ObjectProperty='OverflowMode';
            omode.RowSpan=[1,1];
            omode.ColSpan=[2,2];
            omode.Source=this;
            omode.Tag='OverflowMode';
            omode.Entries=getEntries(this.OverflowModeSet);


            defaultindx=find(strcmpi(this.OverflowModeSet,this.OverflowMode));
            if~isempty(defaultindx)
                omode.Value=defaultindx-1;
            end

            omode.Enabled=enabState;
            omode.Mode=true;

            items={rmode,omode};

            if(any(strcmpi(this.Structure,{'df1','df2','df1t','df2t','df1sos',...
                'df2sos','df2tsos','df1tsos'}))&&~strcmpi(this.AccumMode,'Full precision'))...
                &&(~this.SystemObject)
                cast.Type='checkbox';
                cast.ObjectProperty='CastBeforeSum';
                cast.RowSpan=[2,2];
                cast.ColSpan=[1,2];
                cast.Name=FilterDesignDialog.message('CastBeforeSum');
                cast.Source=this;
                cast.Tag='CastBeforeSum';
                cast.Enabled=enabState;
                cast.Mode=true;

                items=[items,{cast}];
            end

            fixptparam.Type='group';
            fixptparam.Name=FilterDesignDialog.message('FixedPtOpParams');
            fixptparam.Items=items;
            fixptparam.LayoutGrid=[2,2];
            fixptparam.RowSpan=[row,row];
            fixptparam.ColSpan=[1,3];
            fixptparam.Tag='FixedPointOperationalParameters';
        end


        function items=getCoeffRow(this,opts,items)

            if nargin<3
                items={};
            end

            opts.Name='FixedPtCoefficients';
            opts.Tag='Coeff';

            [label,mode,signed,word,frac]=getFormatRow(this,opts);
            entries=this.CoeffModeSet;

            if~this.SystemObject
                entries=entries(2:3);
                mode=getComboBoxWidget(this,mode,'CoeffMode',entries);

                signed=getSignedCheckBoxWidget(this,signed,'CoeffSigned',false);

                items=[items,{label,mode,signed,word}];
                if strcmpi(this.CoeffMode,'binary point scaling')
                    items=[items,{frac}];
                end
            else

                if this.FIRFlag
                    propName='CustomCoefficientsDataType';
                else
                    propName='CustomNumeratorCoefficientsDataType';
                end
                signRestrictions=getFxPtRestrictions(this,propName,'signedness');
                scaleRestrictions=getFxPtRestrictions(this,propName,'scaling');

                switch scaleRestrictions
                case 'SCALED'
                    idx=strcmpi(entries,'specify word length');
                    entries(idx)=[];
                case 'NOTSCALED'
                    idx=strcmpi(entries,'binary point scaling');
                    entries(idx)=[];
                end

                mode=getComboBoxWidget(this,mode,'CoeffMode',entries);

                switch signRestrictions
                case 'SPECSIGNED'
                    signed=getSignedCheckBoxWidget(this,signed,'CoeffSigned',true);
                case 'AUTOSIGNED'
                    signed.Name=FilterDesignDialog.message('auto');
                    signed.Tag='CoeffSigned_text';
                case 'UNSIGNED'
                    signed.Name=FilterDesignDialog.message('no');
                    signed.Tag='CoeffSigned_text';
                case 'SIGNED'
                    signed.Name=FilterDesignDialog.message('yes');
                    signed.Tag='CoeffSigned_text';
                end



                this.CoeffSignedSysObj=lower(signRestrictions);

                items=[items,{label,mode}];
                if~strcmpi(this.CoeffMode,'same word length as input')
                    items=[items,{word,signed}];
                end
                if strcmpi(this.CoeffMode,'binary point scaling')
                    items=[items,{frac}];
                end
            end
        end


        function items=getProductRow(this,opts,items)

            if nargin<3
                items={};
            end

            opts.Name='FixedPtProduct';
            opts.Tag='Product';

            [label,mode,signed,word,frac]=getFormatRow(this,opts);
            entries=this.ProductModeSet;

            if~this.SystemObject

                entries=entries(1:4);
                mode=getComboBoxWidget(this,mode,'ProductMode',entries);


                items=[items,{label,mode,signed}];
                if any(strcmpi(this.ProductMode,{'keep lsb','keep msb','specify precision'}))
                    items=[items,{word}];
                end


                if strcmpi(this.ProductMode,'specify precision')
                    items=[items,{frac}];
                end
            else

                if this.FIRFlag
                    propName='CustomProductDataType';
                    entries=entries([1,5,6,4]);
                else
                    propName='CustomNumeratorProductDataType';
                    if this.SOSFlag
                        entries=entries([5,6,4]);
                    else
                        entries=entries([1,5,6,4]);
                    end
                end
                signRestrictions=getFxPtRestrictions(this,propName,'signedness');
                scaleRestrictions=getFxPtRestrictions(this,propName,'scaling');

                switch scaleRestrictions
                case 'SCALED'
                    idx=strcmpi(entries,'specify word length');
                    entries(idx)=[];
                case 'NOTSCALED'
                    idx=strcmpi(entries,'specify precision');
                    entries(idx)=[];
                end


                mode=getComboBoxWidget(this,mode,'ProductMode',entries);

                switch signRestrictions
                case 'SPECSIGNED'
                    signed=getSignedCheckBoxWidget(this,signed,'ProductSigned',false);
                    if strcmpi(this.CoeffSigned,'on')&&...
                        ~strcmpi(this.CoeffMode,'same word length as input')
                        signed.Enabled=false;
                        this.ProductSigned='on';
                    else
                        signed.Enabled=true;
                    end
                case 'AUTOSIGNED'
                    signed.Name=FilterDesignDialog.message('auto');
                    signed.Tag='ProductSigned_text';
                case 'UNSIGNED'
                    signed.Name=FilterDesignDialog.message('no');
                    signed.Tag='ProductSigned_text';
                case 'SIGNED'
                    signed.Name=FilterDesignDialog.message('yes');
                    signed.Tag='ProductSigned_text';
                end



                this.ProductSignedSysObj=lower(signRestrictions);

                items=[items,{label,mode}];
                if~any(strcmpi(this.ProductMode,{'full precision','same as input'}))
                    items=[items,{signed,word}];
                end


                if strcmpi(this.ProductMode,'specify precision')
                    items=[items,{frac}];
                end
            end
        end


        function items=getSectionRow(this,opts,old_items)

            if nargin<3
                old_items={};
            end

            items=getAutoRow(this,opts);
            entries=this.([items{2}.ObjectProperty,'Set']);

            propName=[opts.Name,'Mode'];
            if~this.SystemObject
                entries=entries(2:3);
                items{2}=getComboBoxWidget(this,items{2},propName,entries);
            else
                propNameCustom=['Custom',opts.Name,'DataType'];
                scaleRestrictions=getFxPtRestrictions(this,propNameCustom,'scaling');
                switch scaleRestrictions
                case 'SCALED'
                    idx=strcmpi(entries,'specify word length');
                    entries(idx)=[];
                case 'NOTSCALED'
                    idx=strcmpi(entries,'binary point scaling');
                    entries(idx)=[];
                end
                items{2}=getComboBoxWidget(this,items{2},propName,entries);


                items{3}.Name=FilterDesignDialog.message('auto');
                if any(strcmp({'Same as section input','Same as input'},this.(propName)))
                    items=items(1:2);
                end
            end

            items=[old_items,items];
        end


        function items=getStateRow(this,opts,auto,old_items)

            if nargin<3
                old_items={};
            end

            if isfield(opts,'Name')
                name=cellstr(opts.Name);
            else
                name={'State'};
            end

            opts.Tag='State';

            for indx=1:length(name)
                opts.Name=name{indx};
                if auto
                    items=getAutoRow(this,opts);
                    entries=this.([items{2}.ObjectProperty,'Set']);

                    if~this.SystemObject
                        entries=entries(3:4);
                        items{2}=getComboBoxWidget(this,items{2},'StateMode',entries);
                    else
                        if length(name)==1
                            propName='CustomStateDataType';
                        else
                            propName='CustomNumeratorStateDataType';
                        end
                        scaleRestrictions=getFxPtRestrictions(this,propName,'scaling');
                        switch scaleRestrictions
                        case 'SCALED'
                            idx=strcmpi(entries,'specify word length');
                            entries(idx)=[];
                        case 'NOTSCALED'
                            idx=strcmpi(entries,'binary point scaling');
                            entries(idx)=[];
                        end

                        if this.IIRFlag
                            idx=strcmpi(entries,'same as accumulator');
                            entries(idx)=[];
                        end

                        items{2}=getComboBoxWidget(this,items{2},'StateMode',entries);


                        items{3}.Name=FilterDesignDialog.message('auto');
                        if any(strcmp({'Same as accumulator','Same as input'},this.StateMode))
                            items=items(1:2);
                        end
                    end

                else
                    items=getFormatRow(this,opts);
                end

                items{1}.Tag=strrep(strrep(name{indx},'.',''),' ','');

                if length(items)>3
                    items{4}.ObjectProperty=sprintf('%s%d',items{4}.ObjectProperty,indx);
                    items{4}.Tag=items{4}.ObjectProperty;
                end
                if length(items)>4
                    if~strcmpi(items{5}.Type,'panel')
                        items{5}.ObjectProperty=sprintf('%s%d',items{5}.ObjectProperty(1:end-1),indx);
                        items{5}.Tag=items{5}.ObjectProperty;
                    end
                end

                old_items=[old_items,items];%#ok<AGROW>
                opts.Row=opts.Row+1;
            end
            items=old_items;
        end


        function items=getMultiplicandRow(this,opts,items)

            if nargin<3
                items={};
            end

            [label,mode,signed,word,frac]=getFormatRow(this,opts);

            if~this.SystemObject
                items=[items,{label,mode,signed,word,frac}];
            else

                scaleRestrictions=getFxPtRestrictions(this,'CustomMultiplicandDataType','scaling');

                entries=this.MultiplicandModeSet;
                if this.IIRFlag
                    entries(2)=[];
                else
                    entries=entries(2:end);
                end

                switch scaleRestrictions
                case 'SCALED'
                    idx=strcmpi(entries,'specify word length');
                    entries(idx)=[];
                case 'NOTSCALED'
                    idx=strcmpi(entries,'binary point scaling');
                    entries(idx)=[];
                end


                mode=getComboBoxWidget(this,mode,'MultiplicandMode',entries);


                signed.Name=FilterDesignDialog.message('auto');

                items=[items,{label,mode}];
                if~any(strcmpi(this.MultiplicandMode,{'same as output'}))&&...
                    ~any(strcmpi(this.MultiplicandMode,{'same as input'}))
                    items=[items,{signed,word}];
                end


                if strcmpi(this.MultiplicandMode,'binary point scaling')
                    items=[items,{frac}];
                end
            end
        end


        function items=getAutoRow(this,opts,items)

            if nargin<3
                items={};
            end

            [label,mode,signed,word,frac]=getFormatRow(this,opts);

            if isfield(opts,'Tag')
                tag=opts.Tag;
            else
                tag=strrep(opts.Name,' ','');
            end

            mode=rmfield(mode,'Name');
            mode.Type='combobox';
            mode.Source=this;
            mode.ObjectProperty=[tag,'Mode'];
            mode.Mode=true;
            mode.DialogRefresh=true;
            mode.Entries=getEntries(this.([mode.ObjectProperty,'Set']));

            mode.Tag=[mode.Tag(1:end-4),'combobox'];


            defaultindx=find(strcmpi(this.([mode.ObjectProperty,'Set']),...
            this.(mode.ObjectProperty)));
            if~isempty(defaultindx)
                mode.Value=defaultindx-1;
            end

            items=[items,{label,mode,signed,word}];
            if strcmpi(this.(mode.ObjectProperty),'binary point scaling')
                items=[items,{frac}];
            end
        end


        function items=getAccumRow(this,opts,items)

            if nargin<3
                items={};
            end

            opts.Name='FixedPtAccum';
            opts.Tag='Accum';

            [label,mode,signed,word,frac]=getFormatRow(this,opts);
            entries=this.ProductModeSet;

            if~this.SystemObject
                entries=entries(1:4);
                mode=getComboBoxWidget(this,mode,'AccumMode',entries);


                items=[items,{label,mode,signed}];
                if any(strcmpi(this.AccumMode,{'keep lsb','keep msb','specify precision'}))
                    items=[items,{word}];
                end


                if strcmpi(this.AccumMode,'specify precision')
                    items=[items,{frac}];
                end
            else

                if this.FIRFlag
                    propName='CustomAccumulatorDataType';
                    entries=entries([1,7,5,6,4]);
                else
                    propName='CustomNumeratorAccumulatorDataType';
                    if this.SOSFlag
                        entries=entries([7,5,6,4]);
                    else
                        entries=entries([1,7,5,6,4]);
                    end
                end
                signRestrictions=getFxPtRestrictions(this,propName,'signedness');
                scaleRestrictions=getFxPtRestrictions(this,propName,'scaling');

                switch scaleRestrictions
                case 'SCALED'
                    idx=strcmpi(entries,'specify word length');
                    entries(idx)=[];
                case 'NOTSCALED'
                    idx=strcmpi(entries,'specify precision');
                    entries(idx)=[];
                end


                mode=getComboBoxWidget(this,mode,'AccumMode',entries);

                switch signRestrictions
                case 'SPECSIGNED'
                    signed=getSignedCheckBoxWidget(this,signed,'AccumSigned',false);
                    if strcmpi(this.CoeffSigned,'on')&&...
                        ~strcmpi(this.CoeffMode,'same word length as input')
                        signed.Enabled=false;
                        this.AccumSigned='on';
                    else
                        signed.Enabled=true;
                    end
                case 'AUTOSIGNED'
                    signed.Name=FilterDesignDialog.message('auto');
                    signed.Tag='AccumSigned_text';
                case 'UNSIGNED'
                    signed.Name=FilterDesignDialog.message('no');
                    signed.Tag='AccumSigned_text';
                case 'SIGNED'
                    signed.Name=FilterDesignDialog.message('yes');
                    signed.Tag='AccumSigned_text';
                end



                this.AccumSignedSysObj=lower(signRestrictions);

                items=[items,{label,mode}];
                if~any(strcmpi(this.AccumMode,{'full precision','same as input',...
                    'same as product'}))
                    items=[items,{signed,word}];
                end


                if strcmpi(this.AccumMode,'specify precision')
                    items=[items,{frac}];
                end
            end
        end


        function items=getOutputRow(this,opts,items)

            if nargin<3
                items={};
            end

            opts.Name='FixedPtOutput';
            opts.Tag='Output';

            [label,mode,signed,word,frac]=getFormatRow(this,opts);
            entries=this.OutputModeSet;

            if~this.SystemObject
                entries=entries(1:3);
                mode=getComboBoxWidget(this,mode,'OutputMode',entries);


                items=[items,{label,mode,signed,word}];
                if strcmpi(this.OutputMode,'specify precision')
                    items=[items,{frac}];
                end
            else

                if any(strcmpi(this.Structure,{'firdecim','firtdecim','firinterp','firsrc'}))

                    entries=entries([4,5,6,2,3]);
                elseif this.IIRFlag

                    entries=entries([7,6,2,3]);
                else

                    entries=entries([4,6,2,3]);
                end
                signRestrictions=getFxPtRestrictions(this,'CustomOutputDataType','signedness');
                scaleRestrictions=getFxPtRestrictions(this,'CustomOutputDataType','scaling');

                switch scaleRestrictions
                case 'SCALED'
                    idx=strcmpi(entries,'best precision');
                    entries(idx)=[];
                case 'NOTSCALED'
                    idx=strcmpi(entries,'specify precision');
                    entries(idx)=[];
                end


                mode=getComboBoxWidget(this,mode,'OutputMode',entries);

                switch signRestrictions
                case 'SPECSIGNED'
                    signed=getSignedCheckBoxWidget(this,signed,'OutputSigned',false);
                    if strcmpi(this.CoeffSigned,'on')...
                        &&~strcmpi(this.CoeffMode,'same word length as input')
                        signed.Enabled=false;
                        this.OutputSigned='on';
                    else
                        signed.Enabled=true;
                    end
                case 'AUTOSIGNED'
                    signed.Name=FilterDesignDialog.message('auto');
                    signed.Tag='OutputSigned_text';
                case 'UNSIGNED'
                    signed.Name=FilterDesignDialog.message('no');
                    signed.Tag='OutputSigned_text';
                case 'SIGNED'
                    signed.Name=FilterDesignDialog.message('yes');
                    signed.Tag='OutputSigned_text';
                end



                this.OutputSignedSysObj=lower(signRestrictions);

                items=[items,{label,mode}];
                if any(strcmpi(this.OutputMode,{'best precision','specify precision'}))
                    items=[items,{signed,word}];
                end


                if strcmpi(this.OutputMode,'specify precision')
                    items=[items,{frac}];
                end
            end
        end


        function[fintlabel,fint]=getFilterInternals(this,startrow)

            fintlabel.Type='text';
            fintlabel.Name=FilterDesignDialog.message('FilterInternals');
            fintlabel.RowSpan=[startrow,startrow];
            fintlabel.ColSpan=[1,1];
            fintlabel.Tag='FilterInternalsLabel';
            FiltInt=this.FilterInternalsSet;
            if~any(strcmpi(this.Structure,{'cicdecim','cicinterp'}))
                FiltInt(2:3)=[];

            end
            entries=getEntries(FiltInt);


            defaultindx=find(strcmpi(FiltInt,this.FilterInternals));
            if~isempty(defaultindx)
                fint.Value=defaultindx-1;
            end

            fint.Type='combobox';
            fint.Entries=entries;
            fint.Source=this;
            fint.DialogRefresh=true;
            fint.Tag='FilterInternals';
            fint.RowSpan=fintlabel.RowSpan;
            fint.ColSpan=[2,2];
            fint.Enabled=isfdtbxinstalled;
            fint.ObjectMethod='selectComboboxEntry';
            fint.MethodArgs={'%dialog','%value','FilterInternals',FiltInt};
            fint.ArgDataTypes={'handle','mxArray','string','mxArray'};
        end


        function flag=isShowOperationParameters(this)
            flag=true;
            if this.SystemObject&&this.FIRFlag
                flag=~(strcmp(this.ProductMode,'Full precision')...
                &&strcmp(this.AccumMode,'Full precision')...
                &&strcmp(this.OutputMode,'Same as accumulator'));
            end
        end


        function[signlabel,wordlabel,fraclabel]=isShowHeader(this,signlabel,wordlabel,fraclabel)

            visibleFlag=true;


            if this.SystemObject

                if any(strcmp({'cicdecim','cicinterp'},this.Structure))&&...
                    strcmp(this.FilterInternals,'Full precision')
                    visibleFlag=true;
                else
                    if this.FIRFlag
                        if~strcmp(this.CoeffMode,'Same word length as input')
                            visibleFlag=true;
                        elseif strcmp(this.FilterInternals,'Full precision')
                            visibleFlag=true;
                        else
                            visibleFlag=~(...
                            any(strcmp({'Full precision','Same as input'},this.ProductMode))...
                            &&any(strcmp({'Full precision','Same as product','Same as input'},this.AccumMode))...
                            &&any(strcmp({'Same as product','Same as accumulator','Same as input'},this.OutputMode)));
                        end
                    else
                        switch this.Structure
                        case 'df1sos'
                            visibleFlag=~(...
                            strcmp('Same word length as input',this.CoeffMode)&&...
                            strcmp('Same as input',this.SectionInputMode)&&...
                            strcmp('Same as section input',this.SectionOutputMode)&&...
                            strcmp('Same as input',this.ProductMode)&&...
                            any(strcmp({'Same as input','Same as product'},this.AccumMode))&&...
                            any(strcmp({'Same as input','Same as accumulator'},this.OutputMode)));
                        case{'df2sos','df1tsos','df2tsos'}
                            visibleFlag=(...
                            strcmp('Same word length as input',this.CoeffMode)&&...
                            strcmp('Same as input',this.SectionInputMode)&&...
                            strcmp('Same as section input',this.SectionOutputMode)&&...
                            strcmp('Same as input',this.ProductMode)&&...
                            any(strcmp({'Same as input','Same as product'},this.AccumMode))&&...
                            any(strcmp({'Same as input','Same as accumulator'},this.OutputMode))&&...
                            any(strcmp({'Same as input','Same as accumulator'},this.StateMode)));

                            if strcmp(this.Structure,'df1tsos')
                                visibleFlag=~(visibleFlag&&...
                                strcmp('Same as output',this.MultiplicandMode));
                            else
                                visibleFlag=~visibleFlag;
                            end
                        case{'df1','df1t','df2','df2t'}
                            if strcmp(this.Structure,'df1')
                                visibleFlag=~(strcmp(this.CoeffMode,'Same word length as input')...
                                &&~strcmp(this.ProductMode,'Specify precision')...
                                &&~strcmp(this.AccumMode,'Specify precision')...
                                &&~strcmp(this.OutputMode,'Specify precision'));
                            elseif strcmp(this.Structure,'df1t')
                                visibleFlag=~(strcmp(this.CoeffMode,'Same word length as input')...
                                &&~strcmp(this.ProductMode,'Specify precision')...
                                &&~strcmp(this.AccumMode,'Specify precision')...
                                &&~strcmp(this.OutputMode,'Specify precision')...
                                &&strcmp(this.StateMode,'Same as input')...
                                &&strcmp(this.MultiplicandMode,'Same as input'));
                            else
                                visibleFlag=~(strcmp(this.CoeffMode,'Same word length as input')...
                                &&~strcmp(this.ProductMode,'Specify precision')...
                                &&~strcmp(this.AccumMode,'Specify precision')...
                                &&~strcmp(this.OutputMode,'Specify precision')...
                                &&strcmp(this.StateMode,'Same as input'));
                            end
                        end
                    end
                end
            end

            signlabel.Visible=visibleFlag;
            wordlabel.Visible=visibleFlag;
            fraclabel.Visible=visibleFlag;
        end


        function mode=getComboBoxWidget(this,mode,propName,entries)

            mode.Type='combobox';
            mode.Source=this;
            mode.Mode=true;
            mode.DialogRefresh=true;
            mode.Entries=getEntries(entries);
            mode.Tag=[propName,'_combobox'];
            mode.ObjectMethod='selectComboboxEntry';
            mode.MethodArgs={'%dialog','%value',propName,entries};
            mode.ArgDataTypes={'handle','mxArray','string','mxArray'};

            if isfield(mode,'Name')
                mode=rmfield(mode,'Name');
            end

            if isfield(mode,'ObjectProperty')
                mode=rmfield(mode,'ObjectProperty');
            end


            defaultindx=find(strcmpi(entries,this.(propName)));
            if~isempty(defaultindx)
                mode.Value=defaultindx-1;
            else
                this.(propName)=entries{1};
            end
        end


        function signed=getSignedCheckBoxWidget(this,signed,propName,dlgRefreshFlag)

            signed=rmfield(signed,'Name');
            signed.Type='checkbox';
            signed.Source=this;
            signed.ObjectProperty=propName;
            signed.Tag=[propName,'_checkbox'];
            signed.DialogRefresh=dlgRefreshFlag;
            signed.Mode=true;
        end


        function setDataTypesSysObj(this,Hd,sysObjProp,modeProp,wlProp,flProp,signedMode,signedValue)







            customPropName=['Custom',sysObjProp];
            if~strcmp(Hd.(sysObjProp),'Custom')
                this.(modeProp)=Hd.(sysObjProp);
            else
                this.(wlProp)=mat2str(Hd.(customPropName).WordLength);
                if nargin==8
                    setSign(this,Hd,customPropName,signedMode,signedValue);
                end
                if isbinarypointscalingset(Hd.(customPropName))
                    if any(strcmp(this.([modeProp,'Set']),'Specify precision'))
                        this.(modeProp)='Specify precision';
                    elseif any(strcmp(this.([modeProp,'Set']),'Binary point scaling'))
                        this.(modeProp)='Binary point scaling';
                    end
                    this.(flProp)=mat2str(Hd.(customPropName).FractionLength);
                else
                    this.(modeProp)='Specify word length';
                end
            end
        end

        function setStructure(this,Hd)

            switch class(Hd)
            case 'dsp.FIRFilter'
                this.FIRFlag=true;
                switch Hd.Structure
                case 'Direct form'
                    s='dffir';
                case 'Direct form symmetric'
                    s='dfsymfir';
                case 'Direct form antisymmetric'
                    s='dfasymfir';
                case 'Direct form transposed'
                    s='dffirt';
                otherwise
                    error(FilterDesignDialog.message('StructureNotSupported'))
                end
            case 'dsp.FIRDecimator'
                this.FIRFlag=true;
                if strcmp(Hd.Structure,'Direct form')
                    s='firdecim';
                else
                    s='firtdecim';
                end
            case 'dsp.FIRInterpolator'
                this.FIRFlag=true;
                s='firinterp';
            case 'dsp.FIRRateConverter'
                this.FIRFlag=true;
                s='firsrc';
            case 'dsp.BiquadFilter'
                this.FIRFlag=false;
                switch Hd.Structure
                case 'Direct form I'
                    s='df1sos';
                case 'Direct form I transposed'
                    s='df1tsos';
                case 'Direct form II'
                    s='df2sos';
                case 'Direct form II transposed'
                    s='df2tsos';
                end
            case 'dsp.IIRFilter'
                this.FIRFlag=false;
                switch Hd.Structure
                case 'Direct form I'
                    s='df1';
                case 'Direct form I transposed'
                    s='df1t';
                case 'Direct form II'
                    s='df2';
                case 'Direct form II transposed'
                    s='df2t';
                end
            case 'dsp.CICDecimator'
                this.FIRFlag=false;
                s='cicdecim';
            case 'dsp.CICInterpolator'
                this.FIRFlag=false;
                s='cicinterp';
            case 'dsp.IIRHalfbandDecimator'
                this.FIRFlag=false;
                switch Hd.Structure
                case 'Minimum multiplier'
                    s='iirdecim';
                case 'Wave Digital Filter'
                    s='iirwdfdecim';
                end
            case 'dsp.IIRHalfbandInterpolator'
                this.FIRFlag=false;
                switch Hd.Structure
                case 'Minimum multiplier'
                    s='iirinterp';
                case 'Wave Digital Filter'
                    s='iirwdfinterp';
                end
            otherwise
                error(FilterDesignDialog.message('StructureNotSupported'))
            end

            set(this,'structure',s);
        end


        function setProperties(this,Hd)

            propNames=getActiveProps(Hd,'fixed');


            idx=strncmpi(propNames,'custom',6);
            propNames(idx)=[];
            this.FxPtRestrictions=getFxPtRestrictions(this,Hd);

            for idx=1:length(propNames)
                propName=propNames{idx};

                switch propName
                case 'FullPrecisionOverride'
                    if Hd.FullPrecisionOverride
                        this.FilterInternals='Full precision';
                    else
                        this.FilterInternals='Specify precision';
                    end

                case 'CoefficientsDataType'
                    setDataTypesSysObj(this,Hd,propName,'CoeffMode','CoeffWordLength',...
                    'CoeffFracLength1','CoeffSignedSysObj','CoeffSigned')

                case 'ProductDataType'
                    setDataTypesSysObj(this,Hd,propName,'ProductMode','ProductWordLength',...
                    'ProductFracLength1','ProductSignedSysObj','ProductSigned')

                case 'AccumulatorDataType'
                    setDataTypesSysObj(this,Hd,propName,'AccumMode','AccumWordLength',...
                    'AccumFracLength1','AccumSignedSysObj','AccumSigned');

                case 'OutputDataType'
                    setDataTypesSysObj(this,Hd,propName,'OutputMode','OutputWordLength',...
                    'OutputFracLength1','OutputSignedSysObj','OutputSigned');

                case 'NumeratorCoefficientsDataType'
                    setDataTypesSysObj(this,Hd,propName,'CoeffMode','CoeffWordLength',...
                    'CoeffFracLength1','CoeffSignedSysObj','CoeffSigned');

                case 'DenominatorCoefficientsDataType'
                    setDataTypesSysObj(this,Hd,propName,'CoeffMode','CoeffWordLength',...
                    'CoeffFracLength2','CoeffSignedSysObj','CoeffSigned');

                case 'ScaleValuesDataType'
                    setDataTypesSysObj(this,Hd,propName,'CoeffMode','CoeffWordLength',...
                    'CoeffFracLength3','CoeffSignedSysObj','CoeffSigned');

                case 'SectionInputDataType'
                    setDataTypesSysObj(this,Hd,propName,'SectionInputMode',...
                    'SectionInputWordLength','SectionInputFracLength1');

                case 'SectionOutputDataType'
                    setDataTypesSysObj(this,Hd,propName,'SectionOutputMode',...
                    'SectionOutputWordLength','SectionOutputFracLength1');

                case 'NumeratorProductDataType'
                    setDataTypesSysObj(this,Hd,propName,'ProductMode','ProductWordLength',...
                    'ProductFracLength1','ProductSignedSysObj','ProductSigned');

                case 'DenominatorProductDataType'
                    setDataTypesSysObj(this,Hd,propName,'ProductMode','ProductWordLength',...
                    'ProductFracLength2','ProductSignedSysObj','ProductSigned');

                case 'NumeratorAccumulatorDataType'
                    setDataTypesSysObj(this,Hd,propName,'AccumMode','AccumWordLength',...
                    'AccumFracLength1','AccumSignedSysObj','AccumSigned');

                case 'DenominatorAccumulatorDataType'
                    setDataTypesSysObj(this,Hd,propName,'AccumMode','AccumWordLength',...
                    'AccumFracLength2','AccumSignedSysObj','AccumSigned');

                case 'StateDataType'
                    setDataTypesSysObj(this,Hd,propName,'StateMode','StateWordLength1',...
                    'StateFracLength1');

                case 'NumeratorStateDataType'
                    setDataTypesSysObj(this,Hd,propName,'StateMode','StateWordLength1',...
                    'StateFracLength1');

                case 'DenominatorStateDataType'
                    setDataTypesSysObj(this,Hd,propName,'StateMode','StateWordLength1',...
                    'StateFracLength2');

                case 'MultiplicandDataType'
                    setDataTypesSysObj(this,Hd,propName,'MultiplicandMode',...
                    'MultiplicandWordLength','MultiplicandFracLength1');

                case 'RoundingMethod'
                    this.RoundMode=Hd.RoundingMethod;

                case 'OverflowAction'
                    this.OverflowMode=Hd.OverflowAction;

                case 'SectionWordLengths'
                    this.SectionsWordLength=mat2str(Hd.(propName));

                case 'SectionFractionLengths'
                    this.SectionsFracLength1=mat2str(Hd.(propName));

                case 'OutputWordLength'
                    this.OutputWordLength=mat2str(Hd.(propName));

                case 'OutputFractionLength'
                    this.OutputFracLength1=mat2str(Hd.(propName));

                case 'FixedPointDataType'
                    this.FilterInternals=mapCICFilterInternals1(Hd.(propName));
                end
            end
        end


        function setSign(this,Hd,sysObjProp,signModeProp,signedTypeProp)

            signRestrictions=getFxPtRestrictions(this,sysObjProp,'signedness');
            this.(signModeProp)=signRestrictions;

            switch signRestrictions
            case 'SPECSIGNED'
                if strcmp(Hd.(sysObjProp).Signedness,'Signed')
                    this.(signedTypeProp)='on';
                else
                    this.(signedTypeProp)='off';
                end
            case 'UNSIGNED'
                this.(signedTypeProp)='off';
            case 'SIGNED'
                this.(signedTypeProp)='on';
            end
        end


        function flag=isDefaultFixedPointSettings(this,Hd)

            flag=true;

            propNames=getActiveProps(Hd,'fixed');

            wId='MATLAB:system:nonRelevantProperty';
            wState=warning('QUERY',wId);
            c=onCleanup(@()restoreWarningState(this,wState));
            warning('off',wId);


            HdDefault=feval(class(Hd));

            for idx=1:length(propNames)
                prop=propNames{idx};
                if~isequal(Hd.(prop),HdDefault.(prop))
                    flag=false;
                    break;
                end
            end
        end

    end
end







function setIIRcommonPropertiesDfilt(source,Hd)

    if~Hd.CoeffAutoScale
        set(Hd,...
        'NumFracLength',evaluatevars(source.CoeffFracLength1),...
        'DenFracLength',evaluatevars(source.CoeffFracLength2));
    end

    set(Hd,...
    'OutputWordLength',evaluatevars(source.OutputWordLength),...
    'RoundMode',convertRoundModeDfilt(source),...
    'OverflowMode',source.OverflowMode,...
    'ProductMode',strrep(source.ProductMode,' ',''),...
    'AccumMode',strrep(source.AccumMode,' ',''));

    if~strcmpi(Hd.ProductMode,'FullPrecision')
        set(Hd,'ProductWordLength',evaluatevars(source.ProductWordLength));
        if strcmpi(Hd.ProductMode,'SpecifyPrecision')
            set(Hd,...
            'NumProdFracLength',evaluatevars(source.ProductFracLength1),...
            'DenProdFracLength',evaluatevars(source.ProductFracLength2));
        end
    end

    if~strcmpi(Hd.AccumMode,'FullPrecision')
        set(Hd,...
        'CastBeforeSum',strcmpi(source.CastBeforeSum,'on'),...
        'AccumWordLength',evaluatevars(source.AccumWordLength));
        if strcmpi(Hd.AccumMode,'SpecifyPrecision')
            set(Hd,...
            'NumAccumFracLength',evaluatevars(source.AccumFracLength1),...
            'DenAccumFracLength',evaluatevars(source.AccumFracLength2));
        end
    end
end

function setIIRcommonPropertiesDfilt1(this,Hd)

    if Hd.CastBeforeSum
        cbs='on';
    else
        cbs='off';
    end

    set(this,...
    'CoeffFracLength1',mat2str(Hd.NumFracLength),...
    'CoeffFracLength2',mat2str(Hd.DenFracLength),...
    'OutputWordLength',mat2str(Hd.OutputWordLength),...
    'OutputFracLength1',mat2str(Hd.OutputFracLength),...
    'RoundMode',convertRoundModeDfilt1(Hd),...
    'OverflowMode',Hd.OverflowMode,...
    'ProductMode',convertModeDfilt1(Hd,'Product'),...
    'ProductWordLength',mat2str(Hd.ProductWordLength),...
    'ProductFracLength1',mat2str(Hd.NumProdFracLength),...
    'ProductFracLength2',mat2str(Hd.DenProdFracLength),...
    'AccumMode',convertModeDfilt1(Hd,'Accum'),...
    'AccumWordLength',mat2str(Hd.AccumWordLength),...
    'AccumFracLength1',mat2str(Hd.NumAccumFracLength),...
    'AccumFracLength2',mat2str(Hd.DenAccumFracLength),...
    'CastBeforeSum',cbs);
end


function FI=mapFilterInternalsDfilt(FI)

    switch lower(FI)
    case 'minimum word lengths'
        FI='minwordlengths';
    case 'specify word lengths'
        FI='specifywordlengths';
    case 'specify precision'
        FI='specifyprecision';
    case 'full precision'
        FI='fullprecision';
    end
end

function FI=mapFilterInternalsDfilt1(FI)

    switch lower(FI)
    case 'minwordlengths'
        FI='minimum word lengths';
    case 'specifywordlengths'
        FI='specify word lengths';
    case 'specifyprecision'
        FI='specify precision';
    case 'fullprecision'
        FI='full precision';
    end
end

function rMode=convertRoundModeDfilt(source)

    rMode=source.RoundMode;

    switch lower(rMode)
    case 'ceiling'
        rMode='ceil';
    case 'zero'
        rMode='fix';
    end
end

function rMode=convertRoundModeDfilt1(Hd)

    rMode=get(Hd,'RoundMode');

    switch rMode
    case 'ceil'
        rMode='ceiling';
    case 'fix'
        rMode='zero';
    end
end

function oMode=convertOutputModeDfilt1(Hd)

    oMode=get(Hd,'OutputMode');

    switch oMode
    case 'AvoidOverflow'
        oMode='Avoid overflow';
    case 'BestPrecision'
        oMode='Best precision';
    case 'SpecifyPrecision'
        oMode='Specify precision';
    end
end

function mode=convertModeDfilt1(Hd,mode)

    mode=get(Hd,[mode,'Mode']);

    switch mode
    case 'SpecifyPrecision'
        mode='Specify precision';
    case 'KeepLSB'
        mode='Keep LSB';
    case 'KeepMSB'
        mode='Keep MSB';
    case 'FullPrecision'
        mode='Full precision';
    end
end



















function FI=mapCICFilterInternals(FI)

    switch lower(FI)
    case 'full precision'
        FI='Full precision';
    case 'minimum word lengths'
        FI='Minimum section word lengths';
    case 'specify word lengths'
        FI='Specify word lengths';
    case 'specify precision'
        FI='Specify word and fraction lengths';
    end
end


function FI=mapCICFilterInternals1(FI)

    switch lower(FI)
    case 'full precision'
        FI='Full precision';
    case 'minimum section word lengths'
        FI='Minimum word lengths';
    case 'specify word lengths'
        FI='Specify word lengths';
    case 'specify word and fraction lengths'
        FI='Specify precision';
    end
end


function setNumericType(source,Hd,sysObjProp,modeProp,wlProp,flProp,signedMode,signedValue)







    customStrings={'specify precision','specify word length',...
    'binary point scaling'};

    if any(strcmpi(customStrings,source.(modeProp)))

        Hd.(sysObjProp)='Custom';

        if nargin==7
            sgn=getSign(source,signedMode);
        else
            sgn=getSign(source,signedMode,signedValue);
        end

        if isa(Hd,'dsp.FIRFilter')&&isempty(sgn)
            sgn=true;
        end

        WL=evaluatevars(source.(wlProp));

        if strcmp(source.(modeProp),'Specify word length')
            nt=numerictype(sgn,WL);
        else
            FL=evaluatevars(source.(flProp));
            nt=numerictype(sgn,WL,FL);
        end

        Hd.(['Custom',sysObjProp])=nt;

    else
        Hd.(sysObjProp)=source.(modeProp);
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


function addFixedPoint(laState,hBuffer,variableName,classname)


    hBuffer.add('set(%s, ''Arithmetic'', ''fixed''',variableName);

    addPair(hBuffer,'InputWordLength',evaluatevars(laState.InputWordLength));
    addPair(hBuffer,'InputFracLength',evaluatevars(laState.InputFracLength1));

    classname(1:strfind(classname,'.'))=[];
    switch lower(classname)
    case 'df1'
        addCoeff(laState,hBuffer,'Num','Den');
        addProd(laState,hBuffer,'Num','Den');
        addAccum(laState,hBuffer,'Num','Den');
        addOutput(laState,hBuffer,false);
        addModes(laState,hBuffer);
    case 'df2'
        addCoeff(laState,hBuffer,'Num','Den');
        addState(laState,hBuffer,false,1);
        addProd(laState,hBuffer,'Num','Den');
        addAccum(laState,hBuffer,'Num','Den');
        addOutput(laState,hBuffer,true);
        addModes(laState,hBuffer);
    case 'df1t'
        addCoeff(laState,hBuffer,'Num','Den');
        addFormat(laState,hBuffer,'Multiplicand');
        addState(laState,hBuffer,true,1,'Num','Den');
        addProd(laState,hBuffer,'Num','Den');
        addAccum(laState,hBuffer,'Num','Den');
        addOutput(laState,hBuffer,true);
        addModes(laState,hBuffer);
    case 'df2t'
        addCoeff(laState,hBuffer,'Num','Den');
        addState(laState,hBuffer,true,1);
        addProd(laState,hBuffer,'Num','Den');
        addAccum(laState,hBuffer,'Num','Den');
        addOutput(laState,hBuffer,false);
        addModes(laState,hBuffer);
    case 'df1sos'
        addCoeff(laState,hBuffer,'Num','Den','ScaleValue');
        addState(laState,hBuffer,false,2,'Num','Den');
        addProd(laState,hBuffer,'Num','Den');
        addAccum(laState,hBuffer,'Num','Den');
        addOutput(laState,hBuffer,true);
        addModes(laState,hBuffer);
    case 'df2sos'
        addCoeff(laState,hBuffer,'Num','Den','ScaleValue');
        addFormat(laState,hBuffer,'SectionInput',true);
        addFormat(laState,hBuffer,'SectionOutput',true);
        addState(laState,hBuffer,false,1);
        addProd(laState,hBuffer,'Num','Den');
        addAccum(laState,hBuffer,'Num','Den');
        addOutput(laState,hBuffer,true);
        addModes(laState,hBuffer);
    case 'df1tsos'
        addCoeff(laState,hBuffer,'Num','Den','ScaleValue');
        addState(laState,hBuffer,true,1,'Num','Den');
        addFormat(laState,hBuffer,'SectionInput',true);
        addFormat(laState,hBuffer,'SectionOutput',true);
        addFormat(laState,hBuffer,'Multiplicand');
        addProd(laState,hBuffer,'Num','Den');
        addAccum(laState,hBuffer,'Num','Den');
        addOutput(laState,hBuffer,true);
        addModes(laState,hBuffer);
    case 'df2tsos'
        addCoeff(laState,hBuffer,'Num','Den','ScaleValue');
        addFormat(laState,hBuffer,'SectionInput');
        addFormat(laState,hBuffer,'SectionOutput');
        addState(laState,hBuffer,true,1);
        addProd(laState,hBuffer,'Num','Den');
        addAccum(laState,hBuffer,'Num','Den');
        addOutput(laState,hBuffer,true);
        addModes(laState,hBuffer);
    case{'dffir','dffirt','dfsymfir','dfasymfir','firdecim',...
        'firtdecim','firinterp','firsrc'}
        addCoeff(laState,hBuffer,'Num');
        addFilterInternals(laState,hBuffer);
        if strcmpi(laState.FilterInternals,'Specify precision')
            addFormat(laState,hBuffer,'Product');
            addFormat(laState,hBuffer,'Accum');
            addOutput(laState,hBuffer,false);
            addModes(laState,hBuffer);
        end
    case 'linearinterp'
        addCoeff(laState,hBuffer,'Num');
        addFilterInternals(laState,hBuffer);
        if strcmpi(laState.FilterInternals,'Specify precision')
            addFormat(laState,hBuffer,'Accum');
            addOutput(laState,hBuffer,false);
            addModes(laState,hBuffer);
        end
    case{'delay','holdinterp'}

    case{'fd','farrowfd','farrowsrc','farrowlinearfd'}
        if~strcmpi(classname,'farrowlinearfd')
            addCoeff(laState,hBuffer,'Coeff');
        end
        addFormat(laState,hBuffer,'FD',true);
        addFilterInternals(laState,hBuffer);
        if strcmpi(laState.FilterInternals,'Specify precision')
            addFormat(laState,hBuffer,'Product');
            addFormat(laState,hBuffer,'Accum');
            addFormat(laState,hBuffer,'Multiplicand');
            addFormat(laState,hBuffer,'FDProd');
            addOutput(laState,hBuffer,false);
            addModes(laState,hBuffer);
        end
    case{'cicdecim','cicinterp'}

        addFilterInternals(laState,hBuffer);

        switch lower(laState.FilterInternals)
        case 'full precision'

        case 'minimum word lengths'
            addPair(hBuffer,'OutputWordLength',...
            evaluatevars(laState.OutputWordLength));
        case 'specify word lengths'
            addPair(hBuffer,'SectionWordLengths',...
            evaluatevars(laState.SectionsWordLength));
            addPair(hBuffer,'OutputWordLength',...
            evaluatevars(laState.OutputWordLength));
        case 'specify precision'
            addPair(hBuffer,'SectionWordLengths',...
            evaluatevars(laState.SectionsWordLength));
            addPair(hBuffer,'SectionFracLengths',...
            evaluatevars(laState.SectionsFracLength1));
            addPair(hBuffer,'OutputWordLength',...
            evaluatevars(laState.OutputWordLength));
            addPair(hBuffer,'OutputFracLength',...
            evaluatevars(laState.OutputFracLength1));
        end
    otherwise
        error(message('FilterDesignLib:FilterDesignDialog:FixedPoint:getMCodeBuffer:FixedPtErr',laState.Structure));
    end
    hBuffer.add(');');
end


function addFixedPointSysObj(laState,hBuffer,Hd,variableName)

    if isa(Hd,'dsp.FilterCascade')

        for indx=1:getNumStages(Hd)
            addFixedPointSysObj(laState,hBuffer,Hd.(sprintf('Stage%d',indx)),sprintf('%s.Stage%d',variableName,indx))
        end
        return;
    end

    propNames=getSysObjFxPointPropsToSet(laState,Hd);

    if isempty(propNames)
        return;
    end


    hBuffer.add('set(%s',variableName);

    addAllSysObjProperties(laState,Hd,hBuffer,propNames)

    hBuffer.add(');');
    hBuffer.cr;
end


function propNames=getSysObjFxPointPropsToSet(laState,Hd)

    propNames=getActiveProps(Hd,'fixed');



    idx=strncmpi(propNames,'custom',6);
    propNames(idx)=[];


    propNames=removeDefaultSysObjProps(laState,Hd,propNames);
end


function propNames=removeDefaultSysObjProps(laState,Hd,propNames)

    wId='MATLAB:system:nonRelevantProperty';
    wState=warning('QUERY',wId);
    c=onCleanup(@()restoreWarningState(laState,wState));
    warning('off',wId);


    HdDefault=feval(class(Hd));

    removeIdx=[];
    for idx=1:length(propNames)
        prop=propNames{idx};
        if isequal(Hd.(prop),HdDefault.(prop))
            removeIdx=[removeIdx,idx];%#ok<AGROW>
        end
    end
    propNames(removeIdx)=[];
end


function[ntSign,wl,fl]=getNTSetting(~,ntObj)

    switch ntObj.Signedness
    case 'Auto'
        ntSign='[]';
    case 'Signed'
        ntSign='true';
    case 'Unsigned'
        ntSign='false';
    end

    wl=mat2str(ntObj.WordLength);

    fl=[];
    if isbinarypointscalingset(ntObj)
        fl=mat2str(ntObj.FractionLength);
    end
end


function restoreWarningState(~,wState)

    warning(wState)

end


function addFormat(laState,hBuffer,format,hasMode)

    if nargin<4
        hasMode=false;
    end

    wlStr=sprintf('%sWordLength',format);

    addPair(hBuffer,wlStr,evaluatevars(laState.(wlStr)));

    addFrac=true;
    if hasMode

        isAuto=strcmpi(laState.(sprintf('%sMode',format)),'specify word length');

        addPair(hBuffer,sprintf('%sAutoScale',format),isAuto);
        if isAuto
            addFrac=false;
        end
    end

    if addFrac
        addPair(hBuffer,sprintf('%sFracLength',format),...
        evaluatevars(laState.(sprintf('%sFracLength1',format))));
    end
end


function addState(laState,hBuffer,hasMode,numberOfStates,varargin)

    if nargin<5
        varargin={''};
    end

    if numberOfStates>1
        for indx=1:numberOfStates
            addPair(hBuffer,sprintf('%sStateWordLength',varargin{indx}),...
            evaluatevars(laState.(sprintf('StateWordLength%d',indx))));
        end
    else
        addPair(hBuffer,'StateWordLength',evaluatevars(laState.StateWordLength1));
    end

    addFrac=true;

    if hasMode
        addPair(hBuffer,'StateAutoScale',...
        strcmpi(laState.StateMode,'specify word length'));
        if~strcmpi(laState.StateMode,'binary point scaling')
            addFrac=false;
        end
    end

    if addFrac
        for indx=1:length(varargin)
            addPair(hBuffer,sprintf('%sStateFracLength',varargin{indx}),...
            evaluatevars(laState.(sprintf('StateFracLength%d',indx))));
        end
    end
end


function addOutput(laState,hBuffer,hasMode)

    addPair(hBuffer,'OutputWordLength',evaluatevars(laState.OutputWordLength));

    addFrac=true;

    if hasMode
        addPair(hBuffer,'OutputMode',strrep(laState.OutputMode,' ',''));
        if~strcmpi(laState.OutputMode,'specify precision')
            addFrac=false;
        end
    end

    if addFrac
        addPair(hBuffer,'OutputFracLength',evaluatevars(laState.OutputFracLength1));
    end
end


function addModes(laState,hBuffer)

    rmode=lower(laState.RoundMode);

    switch lower(rmode)
    case 'ceiling'
        rmode='ceil';
    case 'zero'
        rmode='fix';
    end

    addPair(hBuffer,'RoundMode',rmode);
    addPair(hBuffer,'OverflowMode',lower(laState.OverflowMode));
end


function addProd(laState,hBuffer,varargin)

    addProdAccum(laState,hBuffer,'Product','Prod',varargin{:});
end


function addAccum(laState,hBuffer,varargin)

    addProdAccum(laState,hBuffer,'Accum','Accum',varargin{:});


    if~strcmpi(laState.AccumMode,'full precision')
        addPair(hBuffer,'CastBeforeSum',strcmpi(laState.CastBeforeSum,'on'));
    end
end


function addProdAccum(laState,hBuffer,longstr,shortstr,varargin)

    modestr=sprintf('%sMode',longstr);

    addPair(hBuffer,modestr,strrep(laState.(modestr),' ',''));

    switch lower(laState.(modestr))
    case 'full precision'

    case{'keep lsb','keep msb'}
        addPair(hBuffer,sprintf('%sWordLength',longstr),...
        evaluatevars(laState.(sprintf('%sWordLength',longstr))));
    case 'specify precision'
        addPair(hBuffer,sprintf('%sWordLength',longstr),...
        evaluatevars(laState.(sprintf('%sWordLength',longstr))));
        for indx=1:length(varargin)
            addPair(hBuffer,sprintf('%s%sFracLength',varargin{indx},shortstr),...
            evaluatevars(laState.(sprintf('%sFracLength%d',longstr,indx))));
        end
    end
end


function addCoeff(laState,hBuffer,varargin)


    addPair(hBuffer,'CoeffWordLength',evaluatevars(laState.CoeffWordLength));

    if strcmpi(laState.CoeffMode,'Specify word length')


        addPair(hBuffer,'CoeffAutoScale',true);
    else


        addPair(hBuffer,'CoeffAutoScale',false);
        for indx=1:length(varargin)
            addPair(hBuffer,sprintf('%sFracLength',varargin{indx}),...
            evaluatevars(laState.(sprintf('CoeffFracLength%d',indx))));
        end
        addPair(hBuffer,'Signed',strcmpi(laState.CoeffSigned,'on'));
    end
end


function addFilterInternals(laState,hBuffer)

    fi=strrep(laState.FilterInternals,' ','');
    if strcmpi(fi,'minimumwordlengths')
        fi='minwordlengths';
    end

    addPair(hBuffer,'FilterInternals',fi);
end


function addPair(hBuffer,property,value)

    if ischar(value)
        if~strncmp(value,'numerictype(',12)
            value=['''',value,''''];
        end
    else
        value=mat2str(value);
    end

    hBuffer.add(', ...\n    ''%s'', %s',property,value);
end


function cls=getClassName(Hd)

    cls=class(Hd);
    cls=strsplit(cls,'.');
    cls=cls{end};

    switch cls
    case{'cascade','parallel'}



        for indx=1:nstages(Hd)
            cls=getClassName(Hd.Stage(indx));
            if~isempty(cls)
                return;
            end
        end

    case 'scalar'


        cls='';
    end
end


function auto=convertAutoscale(auto)

    if auto
        auto='Specify word length';
    else
        auto='Binary point scaling';
    end
end


function sgn=getSign(this,modeProp,valueProp)

    if nargin==2
        mode=modeProp;
    else
        mode=this.(modeProp);
    end

    switch mode
    case 'specsigned'
        sgn=strcmp(this.(valueProp),'on');
    case 'autosigned'
        sgn=[];
    case 'unsigned'
        sgn=false;
    case 'signed'
        sgn=true;
    end
end


function addAllSysObjProperties(this,Hd,hBuffer,propNames)



    if any(strcmp(propNames,'FullPrecisionOverride'))
        addPair(hBuffer,'FullPrecisionOverride',Hd.FullPrecisionOverride);
    end



    if any(strcmp(propNames,'FixedPointDataType'))
        addPair(hBuffer,'FixedPointDataType',Hd.FixedPointDataType);
    end

    for idx=1:length(propNames)
        propName=propNames{idx};

        switch propName
        case{'SectionWordLengths','SectionFractionLengths','OutputWordLength',...
            'OutputFractionLength'}
            addPair(hBuffer,propName,Hd.(propName));

        case{'CoefficientsDataType','ProductDataType','AccumulatorDataType',...
            'OutputDataType','NumeratorCoefficientsDataType',...
            'DenominatorCoefficientsDataType','ScaleValuesDataType',...
            'SectionInputDataType','SectionOutputDataType',...
            'NumeratorProductDataType','DenominatorProductDataType',...
            'NumeratorAccumulatorDataType','DenominatorAccumulatorDataType',...
            'StateDataType','NumeratorStateDataType',...
            'DenominatorStateDataType','MultiplicandDataType'}

            setDataTypes(this,Hd,propName,hBuffer)
        end
    end



    if any(strcmp(propNames,'RoundingMethod'))
        addPair(hBuffer,'RoundingMethod',Hd.RoundingMethod);
    end

    if any(strcmp(propNames,'OverflowAction'))
        addPair(hBuffer,'OverflowAction',Hd.OverflowAction);
    end
end




function setDataTypes(this,Hd,propName,hBuffer)



    addPair(hBuffer,propName,Hd.(propName));
    if strcmpi(Hd.(propName),'custom')
        customPropName=['Custom',propName];
        [ntSign,wl,fl]=getNTSetting(this,Hd.(customPropName));
        str=['numerictype(',ntSign,',',wl];
        if~isempty(fl)
            str=[str,',',fl];
        end
        str=[str,')'];
        addPair(hBuffer,customPropName,str);
    end
end
