classdef(StrictDefaults)CICInterpolator<matlab.System


















































































































%#codegen




    properties(Nontunable)



        InterpolationSource='Property';




        InterpolationFactor=2;




        MaxInterpolationFactor=2;




        DifferentialDelay=1;




        NumSections=2;




        NumCycles=1;





        OutputWordLength=16;













        OutputDataType='Full precision';





        GainCorrection(1,1)logical=false;




        ResetInputPort(1,1)logical=false;




        HDLGlobalReset(1,1)logical=false;
    end

    properties(Constant,Hidden)
        InterpolationSourceSet=matlab.system.StringSet({...
        'Property','Input port'});
        OutputDataTypeSet=matlab.system.StringSet({...
        'Full precision','Same word length as input','Minimum section word lengths'});
    end

    properties(Nontunable,Access=private)
        shiftlength;
        invecsize;
        int1wl;
        int1fl;
        int2wl;
        int2fl;
        int3wl;
        int3fl;
        int4wl;
        int4fl;
        int5wl;
        int5fl;
        int6wl;
        int6fl;
        dswl;
        dsfl;
        com1wl;
        com1fl;
        com2wl;
        com2fl;
        com3wl;
        com3fl;
        com4wl;
        com4fl;
        com5wl;
        com5fl;
        com6wl;
        com6fl;
        outvecsize;
        outvecsize1;
        residuevect;
        intoffvect;
    end

    properties(Access=private)

        dataIntReg;


        dataUsReg;
        validUsReg;
        count;
        upsampleMax;
        usMaxreg;
        changeinR;


        dataComReg;
        dataComRegReg;
        validComReg;
        subtmp;
        cValidbuf;


        gainOuta;
        gainOuta1;
        gDT;
        gainShift;
        fineMult;
        gainOut;
        gainValid;


        userDefinedOut;
        inDisp;


        gainDatareg;
        fgainDatareg;
        gainOutareg1;
        gainOutareg2;
        gainOutareg3;
        gainOutareg4;
        gainOutareg5;
        validOuti1;
        validOuti2;
        validOuti3;
        validOuti4;
        validOuti5;
        validOuti6;
        validOuti7;
        validOuti8;
        validOuti9;
        gainValidTmp;
        gainOutTmp;
        dataInireg;
        validInreg;
        resetreg;
        gainOutatmp;
        gainOutatmp1;
        gainOutatmp2;
        previnterpFactor;
        countVect;
        stateInt;
        readyReg;
        state1;
        count1;
        dataOutiprev;
        dataOutIntN1;
        dataOutIntN2;
        dataOutIntN3;
        dataOutIntN4;
        dataOutIntN5;
        dataOutIntN6;
        addOutRegN1;
        addOutRegN2;
        addOutRegN3;
        addOutRegN4;
        addOutRegN5;
        addOutRegN6;
        part1RegN1;
        part1RegN2;
        part1RegN3;
        part1RegN4;
        part1RegN5;
        part1RegN6;
        residue;
        countds;
        delayBalance1RV;
        delayBalance1IV;
        delayBalance2V;
        delayBalanceNRV;
        delayBalanceNIV;
        delayBalanceNV;
        validInreg1;
        vectorSize;
        dataOutComreg1;
        dataOutComreg2;
        dataOutComreg3;
        dataOutComreg4;
        dataOutComreg5;
        dataOutComreg6;
        dataOutCom1reg1;
        dataOutCom2reg2;
        dataOutCom3reg3;
        dataOutCom4reg4;
        dataOutCom5reg5;
        dataOutCom6reg6;
        dataOutcreg1;
        dataOutcreg2;
        dataOutcreg3;
        dataOutcreg4;
        dataOutcreg5;
        dataOutcreg6;
        validOutcreg1;
        validOutcreg2;
        validOutcreg3;
        validOutcreg4;
        validOutcreg5;
        validOutcreg6;
        validOutusreg;
        stagevecsize;
        buffstate;
        buffreg;
        buffcount;
        pInitialize(1,1)logical=true;
    end




    methods

        function obj=CICInterpolator(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:});
        end

        function set.InterpolationFactor(obj,value)
            if strcmpi(obj.InterpolationSource,'Property')%#ok
                validateattributes(value,{'double'},{'positive','integer',...
                'scalar','<=',2048,'>=',1},'CICInterpolator','InterpolationFactor');
            end
            obj.InterpolationFactor=value;
        end

        function set.MaxInterpolationFactor(obj,value)
            if~strcmpi(obj.InterpolationSource,'Property')%#ok
                validateattributes(value,{'double'},{'positive','integer',...
                'scalar','<=',2048,'>=',1},'CICInterpolator','MaxInterpolationFactor');
            end
            obj.MaxInterpolationFactor=value;
        end

        function set.DifferentialDelay(obj,value)
            validateattributes(value,{'double'},{'positive','integer',...
            'scalar'},'CICInterpolator','DifferentialDelay');
            if(~((value==1)||(value==2)))
                coder.internal.error('dsphdl:CICInterpolator:InvalidDiffData');
            end
            obj.DifferentialDelay=value;
        end

        function set.NumSections(obj,value)
            validateattributes(value,{'double'},{'positive','integer',...
            'scalar','<=',6},'CICInterpolator','NumSections');
            obj.NumSections=value;
        end

        function set.NumCycles(obj,value)




            validateattributes(value,...
            {'numeric'},...
            {'scalar','positive'},...
            'CICInterpolator','NumCycles');
            if~isinf(value)
                validateattributes(value,...
                {'numeric'},...
                {'integer'},...
                'CICInterpolator','NumCycles');
            end
            obj.NumCycles=value;
        end

        function set.OutputWordLength(obj,value)
            if strcmp(obj.OutputDataType,'Minimum section word lengths')%#ok
                validateattributes(value,{'double'},{'positive','integer',...
                'scalar','<=',104,'>=',2},'CICInterpolator','OutputWordLength');
            end
            obj.OutputWordLength=value;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            text=sprintf(['Interpolate signal using cascaded integrator-comb (CIC) filter.\n\n',...
            'The CIC interpolator implementation is optimized for HDL code generation.\n']);
            header=matlab.system.display.Header(...
            'Title','CIC Interpolator',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl
            algorithmParameters=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'InterpolationSource',...
            'InterpolationFactor','MaxInterpolationFactor','DifferentialDelay',...
            'NumSections','NumCycles','GainCorrection'});

            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'TitleSource','Auto',...
            'Sections',algorithmParameters);
            dtGroup=matlab.system.display.SectionGroup(...
            'Title','Data Types',...
            'PropertyList',{'OutputDataType','OutputWordLength'});
            rstPort=matlab.system.display.Section(...
            'Title','Initialize data path registers',...
            'PropertyList',{'ResetInputPort','HDLGlobalReset'});

            ctrlGroup=matlab.system.display.SectionGroup(...
            'Title','Control Ports',...
            'Sections',rstPort);

            groups=[mainGroup,dtGroup,ctrlGroup];

        end

        function isVisible=showSimulateUsingImpl




            isVisible=false;
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)


            obj.pInitialize=true;
            if strcmpi(obj.InterpolationSource,'Property')
                R=obj.InterpolationFactor;
            else
                R=obj.MaxInterpolationFactor;
            end
            obj.invecsize=length(varargin{1});
            if((obj.NumCycles<obj.InterpolationFactor)||obj.invecsize>1)&&strcmpi(obj.InterpolationSource,'Property')
                obj.outvecsize=(R*obj.invecsize);
                obj.outvecsize1=(R*obj.invecsize)/obj.NumCycles;
            else
                obj.outvecsize=R;
                obj.outvecsize1=R;
            end

            obj.stagevecsize=obj.InterpolationFactor/obj.NumCycles;
            [stageDT,obj.gainShift,obj.shiftlength,obj.gDT,obj.fineMult,obj.userDefinedOut]...
            =determineDataTypes(obj,varargin{1});


            initializeVariables(obj,stageDT,varargin{1});
            obj.residuevect=rem(obj.NumSections,obj.outvecsize);
            if obj.invecsize==1
                if obj.NumSections>=R
                    obj.intoffvect=floor(obj.NumSections/obj.outvecsize)+obj.NumSections-(1+floor(obj.NumSections/R)*2);
                else
                    obj.intoffvect=floor(obj.NumSections/obj.outvecsize)+obj.NumSections-1;
                end
            else
                if obj.NumSections>=obj.outvecsize
                    if R==1&&(obj.NumSections==6||obj.NumSections==5||obj.NumSections==4)
                        obj.intoffvect=obj.NumSections-3;
                    elseif R==2&&obj.NumSections==6
                        obj.intoffvect=3+floor(obj.NumSections/obj.outvecsize)+obj.NumSections-(1+floor(obj.NumSections/R)*2);
                    else
                        obj.intoffvect=1+floor(obj.NumSections/obj.outvecsize)+obj.NumSections-(1+floor(obj.NumSections/R)*2);
                    end
                else
                    obj.intoffvect=floor(obj.NumSections/obj.outvecsize)+obj.NumSections-1;
                end
            end
            obj.countVect=fi(0,0,4,0,hdlfimath);
            obj.stateInt=false;
            obj.countds=fi(0,0,11,0,hdlfimath);
            obj.delayBalance1RV=dsp.Delay('Length',((obj.NumSections*obj.outvecsize)+2+obj.NumSections)*(obj.outvecsize));
            obj.delayBalance1IV=dsp.Delay('Length',((obj.NumSections*obj.outvecsize)+2+obj.NumSections)*(obj.outvecsize));
            obj.delayBalance2V=dsp.Delay('Length',((obj.NumSections*obj.outvecsize)+2+obj.NumSections));
            obj.delayBalanceNRV=dsp.Delay('Length',((obj.InterpolationFactor+1)*obj.NumSections+2)*(obj.outvecsize1));
            obj.delayBalanceNIV=dsp.Delay('Length',((obj.InterpolationFactor+1)*obj.NumSections+2)*(obj.outvecsize1));
            obj.delayBalanceNV=dsp.Delay('Length',((obj.InterpolationFactor+1)*obj.NumSections+2));
        end

        function varargout=outputImpl(obj,varargin)
            if~strcmpi(obj.InterpolationSource,'Property')||(obj.NumCycles>=obj.InterpolationFactor)&&isscalar(varargin{1})
                if obj.resetreg
                    varargout{1}=cast(0,'like',obj.gainOut);
                    varargout{2}=false;
                elseif(obj.gainValid)
                    varargout{1}=obj.gainOut;
                    varargout{2}=obj.gainValid;
                else
                    varargout{1}=cast(0,'like',obj.gainOut);
                    varargout{2}=false;
                end
            else
                if obj.resetreg
                    varargout{1}=cast(zeros(obj.outvecsize1,1),'like',obj.gainOut);
                    varargout{2}=false;
                elseif(obj.gainValid)
                    varargout{1}=obj.gainOut;
                    varargout{2}=obj.gainValid;
                else
                    varargout{1}=cast(zeros(obj.outvecsize1,1),'like',obj.gainOut);
                    varargout{2}=false;
                end
            end

            if obj.resetreg&&~(obj.NumCycles==1||obj.InterpolationFactor==1...
                ||obj.MaxInterpolationFactor==1)
                varargout{3}=false;
            else
                varargout{3}=obj.readyReg;
            end
        end

        function updateImpl(obj,varargin)

            dataIn=varargin{1};
            validIn=varargin{2};
            if~strcmpi(obj.InterpolationSource,'Property')
                upsampleIn=varargin{3};
            end
            if obj.ResetInputPort
                if~strcmpi(obj.InterpolationSource,'Property')
                    reset=varargin{4};
                else
                    reset=varargin{3};
                end
            else
                reset=false;
            end


            if(~strcmpi(obj.InterpolationSource,'Property'))
                if obj.changeinR
                    resetImpl(obj);
                end
                obj.upsampleMax=obj.usMaxreg;
                upsampleIn=fi(upsampleIn,0,12,0);

                if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                    if varargin{3}<1&&validIn
                        if(obj.previnterpFactor~=varargin{3})
                            coder.internal.warning('dsphdl:CICInterpolator:interpFactorLessThanMinValue',double(varargin{3}));
                        end
                        obj.previnterpFactor=varargin{3};
                        upsampleIn=fi(1,0,12,0);
                    elseif varargin{3}>obj.MaxInterpolationFactor&&validIn
                        if(obj.previnterpFactor~=varargin{3})
                            coder.internal.warning('dsphdl:CICInterpolator:interpFactorGreaterThanMaxValue',double(varargin{3}),double(obj.MaxInterpolationFactor));
                        end
                        obj.previnterpFactor=varargin{3};
                        upsampleIn=fi(obj.MaxInterpolationFactor,0,12,0);
                    end
                end
                obj.changeinR=(upsampleIn~=obj.upsampleMax)&&validIn;
                if obj.changeinR
                    obj.usMaxreg=variableUpsample(obj,upsampleIn);
                end
            else
                obj.upsampleMax=fi(obj.InterpolationFactor,0,12,0);
            end
            if(~strcmpi(obj.InterpolationSource,'Property'))

                [dIn,dInVld]=readyLogic(obj,dataIn,validIn,reset);


                [dataOutc,validOutc]=combSection(obj,dIn,dInVld,reset);


                [dataOutus,validOutus]=upSampleSection(obj,dataOutc,validOutc,reset);


                [dataOuti,validOuti]=integratorSection(obj,dataOutus,validOutus,reset);


                [gainOuttmp,gainValidtmp]=gainCorrection(obj,dataOuti,validOuti,reset);
            else

                [dIn,dInVld]=readyLogic(obj,dataIn,validIn,reset);

                if(obj.NumCycles<obj.InterpolationFactor)||(obj.InterpolationFactor==1)

                    [dataOutc,validOutc]=combSection(obj,dataIn,validIn,reset);
                else

                    [dataOutc,validOutc]=combSection(obj,dIn,dInVld,reset);
                end


                [dataOutus,validOutus]=upSampleSection(obj,dataOutc,validOutc,reset);


                [dataOutitmp,validOutitmp]=integratorSection(obj,dataOutus,validOutus,reset);


                if obj.invecsize>1
                    [dataOuti,validOuti]=paddingSection(obj,dataOutitmp,validOutitmp,reset);
                else
                    if(obj.NumCycles>=obj.InterpolationFactor)||(obj.NumCycles==1)
                        dataOuti=dataOutitmp;
                        validOuti=validOutitmp;
                    else
                        [dataOuti,validOuti]=bufferSection(obj,dataOutitmp,validOutitmp,reset);
                    end
                end


                [gainOuttmp,gainValidtmp]=gainCorrection(obj,dataOuti,validOuti,reset);
            end
            obj.resetreg=reset;
            if isscalar(gainOuttmp)
                obj.gainOut(:)=obj.gainOutTmp;
                obj.gainValid=obj.gainValidTmp;
                obj.gainOutTmp(:)=gainOuttmp;
                obj.gainValidTmp=gainValidtmp;
            else
                if(obj.NumCycles<obj.InterpolationFactor)&&(obj.NumCycles~=1)
                    if isreal(gainOuttmp)
                        obj.gainOut(:)=obj.delayBalanceNRV(real(gainOuttmp(:)));
                    else
                        obj.gainOut(:)=complex(obj.delayBalanceNRV(real(gainOuttmp(:))),...
                        obj.delayBalanceNIV(imag(gainOuttmp(:))));
                    end
                    obj.gainValid(:)=obj.delayBalanceNV(gainValidtmp);
                else
                    if isreal(gainOuttmp)
                        obj.gainOut(:)=obj.delayBalance1RV(real(gainOuttmp(:)));
                    else
                        obj.gainOut(:)=complex(obj.delayBalance1RV(real(gainOuttmp(:))),...
                        obj.delayBalance1IV(imag(gainOuttmp(:))));
                    end
                    obj.gainValid(:)=obj.delayBalance2V(gainValidtmp);
                end
            end
        end

        function Upsamplecount=variableUpsample(obj,upsampleIn)
            maxInterp=fi(obj.MaxInterpolationFactor,0,12,0);
            if upsampleIn<=maxInterp
                if upsampleIn<2
                    Upsamplecount=fi(2,0,12,0);
                else
                    Upsamplecount=upsampleIn;
                end
            else
                Upsamplecount=maxInterp;
            end
        end

        function[dIn,dInVld]=readyLogic(obj,dataIn,validIn,reset)
            if(~strcmpi(obj.InterpolationSource,'Property'))
                R=obj.upsampleMax;
            else
                R=obj.InterpolationFactor;
            end
            if R==2
                finalValue=fi(0,0,12,0);
            else
                if obj.NumCycles<obj.InterpolationFactor&&obj.NumCycles~=1
                    finalValue=fi(obj.NumCycles-1,0,12,0);
                else
                    finalValue=fi(R-1,0,12,0);
                end
            end

            switch obj.state1
            case fi(0,0,3,0)
                dIn=dataIn;
                dInVld=validIn;
                obj.state1=fi(0,0,3,0);
                obj.readyReg=true;
                if validIn
                    obj.state1=fi(1,0,3,0);
                    obj.readyReg=false;
                end
            case fi(1,0,3,0)
                if obj.count1(:)>=finalValue
                    obj.readyReg=true;
                    obj.state1=fi(0,0,3,0);
                    dIn=dataIn;
                    dInVld=false;
                else
                    dIn=cast(0,'like',dataIn);
                    dInVld=false;
                end
            otherwise
                dIn=cast(0,'like',dataIn);
                dInVld=false;
                obj.state1=fi(0,0,3,0);
                obj.readyReg=true;
            end

            if validIn||(obj.count1(:)>0)
                if obj.count1(:)==finalValue
                    obj.count1(:)=0;
                else
                    obj.count1(:)=obj.count1+1;
                end
            end
            if reset||obj.changeinR
                dIn=cast(0,'like',dataIn);
                dInVld=false;
                obj.readyReg=false;
                if reset
                    obj.state1=fi(1,0,3,0);
                    obj.count1(:)=finalValue;
                end
            end
            if(obj.NumCycles==1||obj.InterpolationFactor==1)...
                &&strcmpi(obj.InterpolationSource,'Property')
                obj.readyReg=true;
            elseif obj.MaxInterpolationFactor==1&&~strcmpi(obj.InterpolationSource,'Property')
                obj.readyReg=true;
                dInVld=validIn;
            end
        end

        function[dataOutc,validOutc]=combSection(obj,dIn,dInVld,reset)
            if isscalar(dIn)
                N=obj.NumSections;
                validOutc=obj.cValidbuf(N);


                validComb=[dInVld,obj.cValidbuf(1:end-1)];
                if(reset)
                    obj.cValidbuf(:)=0;
                else
                    obj.cValidbuf=validComb;
                end

                tmp=obj.subtmp;
                dataOutc=tmp{N}(:);

                if(obj.DifferentialDelay==1)

                    for i=2:N
                        if(reset)
                            obj.subtmp{i}(:)=0;
                        else
                            obj.subtmp{i}(:)=-obj.dataComReg{i}(:)+tmp{i-1}(:);
                        end
                    end

                    if(reset)
                        obj.subtmp{1}(:)=0;
                    else
                        obj.subtmp{1}(:)=-obj.dataComReg{1}(:)+dIn;
                    end

                else

                    if(reset)
                        obj.subtmp{1}(:)=0;
                    else
                        obj.subtmp{1}(:)=-obj.dataComRegReg{1}(:)+dIn;
                    end

                    for i=2:N
                        if(reset)
                            obj.subtmp{i}(:)=0;
                        else
                            obj.subtmp{i}(:)=-obj.dataComRegReg{i}(:)+tmp{i-1}(:);
                        end
                    end
                    for i=1:N
                        if reset
                            obj.dataComRegReg{i}(:)=0;
                        else
                            if(validComb(i))
                                obj.dataComRegReg{i}(:)=obj.dataComReg{i}(:);
                            end
                        end
                    end
                end
                if(reset)
                    obj.dataComReg{1}(:)=0;
                    for i=2:N
                        obj.dataComReg{i}(:)=0;
                    end
                else
                    if(validComb(1))
                        obj.dataComReg{1}(:)=dIn;
                    end
                    for i=2:N
                        if(validComb(i))
                            obj.dataComReg{i}(:)=tmp{i-1}(:);
                        end
                    end
                end
            else
                if obj.DifferentialDelay==1
                    if reset
                        obj.dataOutcreg6(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg6);
                    else
                        obj.dataOutcreg6(:)=obj.dataOutcreg5(:)-[obj.dataOutComreg6;
                        obj.dataOutcreg5(1:end-1)];
                    end
                    if reset
                        obj.dataOutComreg6(:)=cast(0,'like',obj.dataOutComreg6);
                    elseif obj.validOutcreg5
                        obj.dataOutComreg6(:)=obj.dataOutcreg5(end);
                    end
                    if reset
                        obj.validOutcreg6=false;
                    else
                        obj.validOutcreg6=obj.validOutcreg5;
                    end
                    if reset
                        obj.dataOutcreg5(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg5);
                    else
                        obj.dataOutcreg5(:)=obj.dataOutcreg4(:)-[obj.dataOutComreg5;
                        obj.dataOutcreg4(1:end-1)];
                    end
                    if reset
                        obj.dataOutComreg5(:)=cast(0,'like',obj.dataOutComreg5);
                    elseif obj.validOutcreg4
                        obj.dataOutComreg5(:)=obj.dataOutcreg4(end);
                    end
                    if reset
                        obj.validOutcreg5=false;
                    else
                        obj.validOutcreg5=obj.validOutcreg4;
                    end
                    if reset
                        obj.dataOutcreg4(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg4);
                    else
                        obj.dataOutcreg4(:)=obj.dataOutcreg3(:)-[obj.dataOutComreg4;
                        obj.dataOutcreg3(1:end-1)];
                    end
                    if reset
                        obj.dataOutComreg4(:)=cast(0,'like',obj.dataOutComreg4);
                    elseif obj.validOutcreg3
                        obj.dataOutComreg4(:)=obj.dataOutcreg3(end);
                    end
                    if reset
                        obj.validOutcreg4=false;
                    else
                        obj.validOutcreg4=obj.validOutcreg3;
                    end
                    if reset
                        obj.dataOutcreg3(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg3);
                    else
                        obj.dataOutcreg3(:)=obj.dataOutcreg2(:)-[obj.dataOutComreg3;
                        obj.dataOutcreg2(1:end-1)];
                    end
                    if reset
                        obj.dataOutComreg3(:)=cast(0,'like',obj.dataOutComreg3);
                    elseif obj.validOutcreg2
                        obj.dataOutComreg3(:)=obj.dataOutcreg2(end);
                    end
                    if reset
                        obj.validOutcreg3=false;
                    else
                        obj.validOutcreg3=obj.validOutcreg2;
                    end
                    if reset
                        obj.dataOutcreg2(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg2);
                    else
                        obj.dataOutcreg2(:)=obj.dataOutcreg1(:)-[obj.dataOutComreg2;
                        obj.dataOutcreg1(1:end-1)];
                    end
                    if reset
                        obj.dataOutComreg2(:)=cast(0,'like',obj.dataOutComreg2);
                    elseif obj.validOutcreg1
                        obj.dataOutComreg2(:)=obj.dataOutcreg1(end);
                    end
                    if reset
                        obj.validOutcreg2=false;
                    else
                        obj.validOutcreg2=obj.validOutcreg1;
                    end
                    if reset
                        obj.dataOutcreg1(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg1);
                    else
                        obj.dataOutcreg1(:)=dIn(:)-[obj.dataOutComreg1;
                        dIn(1:end-1)];
                    end
                    if reset
                        obj.dataOutComreg1(:)=cast(0,'like',obj.dataOutComreg1);
                    elseif dInVld
                        obj.dataOutComreg1(:)=dIn(end);
                    end
                    if reset
                        obj.validOutcreg1=false;
                    else
                        obj.validOutcreg1=dInVld;
                    end

                else
                    if reset
                        obj.dataOutcreg6(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg6);
                    else
                        obj.dataOutcreg6(:)=obj.dataOutcreg5(:)-[obj.dataOutCom6reg6;obj.dataOutComreg6;
                        obj.dataOutcreg5(1:end-2)];
                    end
                    if reset
                        obj.dataOutComreg6(:)=cast(0,'like',obj.dataOutComreg6);
                        obj.dataOutCom6reg6(:)=cast(0,'like',obj.dataOutCom6reg6);
                    elseif obj.validOutcreg5
                        obj.dataOutComreg6(:)=obj.dataOutcreg5(end);
                        obj.dataOutCom6reg6(:)=obj.dataOutcreg5(end-1);
                    end
                    if reset
                        obj.validOutcreg6=false;
                    else
                        obj.validOutcreg6=obj.validOutcreg5;
                    end
                    if reset
                        obj.dataOutcreg5(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg5);
                    else
                        obj.dataOutcreg5(:)=obj.dataOutcreg4(:)-[obj.dataOutCom5reg5;obj.dataOutComreg5;
                        obj.dataOutcreg4(1:end-2)];
                    end
                    if reset
                        obj.dataOutComreg5(:)=cast(0,'like',obj.dataOutComreg5);
                        obj.dataOutCom5reg5(:)=cast(0,'like',obj.dataOutCom5reg5);
                    elseif obj.validOutcreg4
                        obj.dataOutComreg5(:)=obj.dataOutcreg4(end);
                        obj.dataOutCom5reg5(:)=obj.dataOutcreg4(end-1);
                    end
                    if reset
                        obj.validOutcreg5=false;
                    else
                        obj.validOutcreg5=obj.validOutcreg4;
                    end
                    if reset
                        obj.dataOutcreg4(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg4);
                    else
                        obj.dataOutcreg4(:)=obj.dataOutcreg3(:)-[obj.dataOutCom4reg4;obj.dataOutComreg4;
                        obj.dataOutcreg3(1:end-2)];
                    end
                    if reset
                        obj.dataOutComreg4(:)=cast(0,'like',obj.dataOutComreg4);
                        obj.dataOutCom4reg4(:)=cast(0,'like',obj.dataOutCom4reg4);
                    elseif obj.validOutcreg3
                        obj.dataOutComreg4(:)=obj.dataOutcreg3(end);
                        obj.dataOutCom4reg4(:)=obj.dataOutcreg3(end-1);
                    end
                    if reset
                        obj.validOutcreg4=false;
                    else
                        obj.validOutcreg4=obj.validOutcreg3;
                    end
                    if reset
                        obj.dataOutcreg3(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg3);
                    else
                        obj.dataOutcreg3(:)=obj.dataOutcreg2(:)-[obj.dataOutCom3reg3;obj.dataOutComreg3;
                        obj.dataOutcreg2(1:end-2)];
                    end
                    if reset
                        obj.dataOutComreg3(:)=cast(0,'like',obj.dataOutComreg3);
                        obj.dataOutCom3reg3(:)=cast(0,'like',obj.dataOutCom3reg3);
                    elseif obj.validOutcreg2
                        obj.dataOutComreg3(:)=obj.dataOutcreg2(end);
                        obj.dataOutCom3reg3(:)=obj.dataOutcreg2(end-1);
                    end
                    if reset
                        obj.validOutcreg3=false;
                    else
                        obj.validOutcreg3=obj.validOutcreg2;
                    end
                    if reset
                        obj.dataOutcreg2(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg2);
                    else
                        obj.dataOutcreg2(:)=obj.dataOutcreg1(:)-[obj.dataOutCom2reg2;obj.dataOutComreg2;
                        obj.dataOutcreg1(1:end-2)];
                    end
                    if reset
                        obj.dataOutComreg2(:)=cast(0,'like',obj.dataOutComreg2);
                        obj.dataOutCom2reg2(:)=cast(0,'like',obj.dataOutCom2reg2);
                    elseif obj.validOutcreg1
                        obj.dataOutComreg2(:)=obj.dataOutcreg1(end);
                        obj.dataOutCom2reg2(:)=obj.dataOutcreg1(end-1);
                    end
                    if reset
                        obj.validOutcreg2=false;
                    else
                        obj.validOutcreg2=obj.validOutcreg1;
                    end
                    if reset
                        obj.dataOutcreg1(:)=cast(zeros(obj.invecsize,1),'like',obj.dataOutcreg1);
                    else
                        obj.dataOutcreg1(:)=dIn(:)-[obj.dataOutCom1reg1;obj.dataOutComreg1;
                        dIn(1:end-2)];
                    end
                    if reset
                        obj.dataOutComreg1(:)=cast(0,'like',obj.dataOutComreg1);
                        obj.dataOutCom1reg1(:)=cast(0,'like',obj.dataOutCom1reg1);
                    elseif dInVld
                        obj.dataOutComreg1(:)=dIn(end);
                        obj.dataOutCom1reg1(:)=dIn(end-1);
                    end
                    if reset
                        obj.validOutcreg1=false;
                    else
                        obj.validOutcreg1=dInVld;
                    end
                end

                switch obj.NumSections
                case 1
                    dataOutc=obj.dataOutcreg1;
                    validOutc=obj.validOutcreg1;
                case 2
                    dataOutc=obj.dataOutcreg2;
                    validOutc=obj.validOutcreg2;
                case 3
                    dataOutc=obj.dataOutcreg3;
                    validOutc=obj.validOutcreg3;
                case 4
                    dataOutc=obj.dataOutcreg4;
                    validOutc=obj.validOutcreg4;
                case 5
                    dataOutc=obj.dataOutcreg5;
                    validOutc=obj.validOutcreg5;
                case 6
                    dataOutc=obj.dataOutcreg6;
                    validOutc=obj.validOutcreg6;
                end
            end
        end

        function[dataOutus,validOutus]=upSampleSection(obj,dataOutc,validOutc,reset)
            if~strcmpi(obj.InterpolationSource,'Property')||(obj.NumCycles>=obj.InterpolationFactor)
                if obj.InterpolationFactor==1||obj.MaxInterpolationFactor==1
                    if reset
                        dataOutus=cast(zeros(size(dataOutc)),'like',dataOutc);
                        validOutus=false;
                    else
                        dataOutus=dataOutc;
                        validOutus=validOutc;
                    end
                else
                    dataOutus=obj.dataUsReg(:);
                    validOutus=obj.validUsReg;

                    if reset
                        obj.dataUsReg(:)=0;
                    elseif validOutc
                        obj.dataUsReg(:)=dataOutc;
                    elseif obj.validUsReg
                        obj.dataUsReg(:)=0;
                    end
                    if reset
                        obj.validUsReg=false;
                    elseif validOutc
                        obj.validUsReg=true;
                    elseif obj.count==((obj.upsampleMax-fi(1,0,2,0)))
                        obj.validUsReg=false;
                    end

                    if(reset)
                        obj.count(:)=0;
                    else
                        if validOutc
                            obj.count(:)=0;


                        elseif validOutus
                            if(obj.count<((obj.upsampleMax-fi(1,0,2,0))))
                                obj.count(:)=obj.count+fi(1,0,1,0);
                            else
                                obj.count(:)=0;
                            end
                        end
                    end
                end
            elseif isscalar(dataOutc)
                dataOutus=obj.dataUsReg(:);
                validOutus=obj.validUsReg;
                if reset
                    obj.dataUsReg(:)=0;
                elseif validOutc
                    obj.dataUsReg(obj.residuevect+1)=dataOutc;
                else
                    obj.dataUsReg(:)=0;
                end
                if reset
                    obj.validUsReg=false;
                elseif validOutc
                    obj.validUsReg=true;
                else
                    obj.validUsReg=false;
                end
            else
                dataOutus=obj.dataUsReg(:);
                validOutus=obj.validUsReg;
                if reset
                    obj.dataUsReg(:)=0;
                elseif validOutc
                    obj.dataUsReg(1:obj.InterpolationFactor:end)=dataOutc;
                else
                    obj.dataUsReg(:)=0;
                end
                if reset
                    obj.validUsReg=false;
                elseif validOutc
                    obj.validUsReg=true;
                else
                    obj.validUsReg=false;
                end
            end
        end

        function[dataOuti,validOuti]=bufferSection(obj,dataOutitmp,validOutitmp,reset)
            dataOuti=obj.buffreg((1:obj.stagevecsize)+obj.buffcount);
            validOuti=obj.buffstate;

            if reset
                obj.buffreg(:)=zeros(obj.outvecsize,1);
            elseif validOutitmp
                obj.buffreg(:)=dataOutitmp;
            end

            if validOutitmp&&~reset
                obj.buffstate=true;
                obj.buffcount(:)=fi(0,0,6,0,hdlfimath);
            elseif obj.buffcount(:)==fi((obj.InterpolationFactor-obj.stagevecsize),0,6,0,hdlfimath)||reset
                obj.buffstate=false;
                obj.buffcount(:)=fi(0,0,6,0,hdlfimath);
            elseif obj.buffstate
                obj.buffcount(:)=obj.buffcount+obj.stagevecsize;
            end
        end

        function[dataOuti,validOuti]=paddingSection(obj,dataOutitmp,validOutitmp,reset)
            if reset
                dataOuti=cast(zeros(obj.outvecsize,1),'like',dataOutitmp);
                validOuti=false;
            else
                if obj.outvecsize==2&&obj.NumSections==2
                    dataOuti=dataOutitmp;
                    validOuti=validOutitmp;
                elseif obj.outvecsize==2&&(obj.NumSections==5||obj.NumSections==6)
                    dataOuti=[obj.dataOutiprev(end-((obj.NumSections-2)-obj.outvecsize)+1:end)
                    dataOutitmp(1:end-(obj.NumSections-2-obj.outvecsize))];
                    validOuti=validOutitmp;
                elseif obj.outvecsize<=obj.NumSections
                    dataOuti=[obj.dataOutiprev(end-(obj.NumSections-obj.outvecsize)+1:end)
                    dataOutitmp(1:end-(obj.NumSections-obj.outvecsize))];
                    validOuti=validOutitmp&&obj.validInreg1;
                else
                    dataOuti=[obj.dataOutiprev(end-obj.NumSections+1:end)
                    dataOutitmp(1:end-obj.NumSections)];
                    validOuti=validOutitmp;
                end
            end
            if reset
                obj.dataOutiprev(:)=zeros(obj.outvecsize,1);
                obj.validInreg1=false;
            elseif validOutitmp
                obj.dataOutiprev(:)=dataOutitmp;
                obj.validInreg1=validOutitmp;
            end
        end

        function[dataOuti,validOuti]=integratorSection(obj,dataOutus,validOutus,reset)
            if isscalar(dataOutus)
                N=obj.NumSections;
                dataOuti=obj.dataIntReg{N}(:);
                validOuti=validOutus;
                for i=N-1:-1:1
                    if(reset)
                        obj.dataIntReg{i+1}(:)=0;
                    elseif(validOutus)
                        obj.dataIntReg{i+1}(:)=obj.dataIntReg{i+1}(:)+obj.dataIntReg{i}(:);
                    end
                end

                if(reset)
                    obj.dataIntReg{1}(:)=0;
                else
                    if(validOutus)
                        obj.dataIntReg{1}(:)=obj.dataIntReg{1}(:)+dataOutus;
                    end
                end
            else
                [dataOuti]=intSectVect(obj,dataOutus,validOutus,reset);
                validOuti=obj.stateInt&&obj.validOutusreg;
                obj.validOutusreg=validOutus;

                if reset
                    obj.stateInt=false;
                elseif obj.countVect==fi(obj.intoffvect,0,4,0)&&validOutus
                    obj.stateInt=true;
                end

                if reset
                    obj.countVect(:)=fi(0,0,4,0,hdlfimath);
                elseif validOutus
                    obj.countVect(:)=obj.countVect(:)+fi(1,0,4,0,hdlfimath);
                end
            end
        end

        function[dataOuti]=intSectVect(obj,dataOutus,validOutus,reset)
            switch obj.NumSections
            case 1
                [dataOut]=cicIntSectN1(obj,dataOutus,validOutus,reset);
            case 2
                [dataOut1]=cicIntSectN1(obj,dataOutus,validOutus,reset);
                [dataOut]=cicIntSectN2(obj,dataOut1,validOutus,reset);
            case 3
                [dataOut1]=cicIntSectN1(obj,dataOutus,validOutus,reset);
                [dataOut2]=cicIntSectN2(obj,dataOut1,validOutus,reset);
                [dataOut]=cicIntSectN3(obj,dataOut2,validOutus,reset);
            case 4
                [dataOut1]=cicIntSectN1(obj,dataOutus,validOutus,reset);
                [dataOut2]=cicIntSectN2(obj,dataOut1,validOutus,reset);
                [dataOut3]=cicIntSectN3(obj,dataOut2,validOutus,reset);
                [dataOut]=cicIntSectN4(obj,dataOut3,validOutus,reset);
            case 5
                [dataOut1]=cicIntSectN1(obj,dataOutus,validOutus,reset);
                [dataOut2]=cicIntSectN2(obj,dataOut1,validOutus,reset);
                [dataOut3]=cicIntSectN3(obj,dataOut2,validOutus,reset);
                [dataOut4]=cicIntSectN4(obj,dataOut3,validOutus,reset);
                [dataOut]=cicIntSectN5(obj,dataOut4,validOutus,reset);
            case 6
                [dataOut1]=cicIntSectN1(obj,dataOutus,validOutus,reset);
                [dataOut2]=cicIntSectN2(obj,dataOut1,validOutus,reset);
                [dataOut3]=cicIntSectN3(obj,dataOut2,validOutus,reset);
                [dataOut4]=cicIntSectN4(obj,dataOut3,validOutus,reset);
                [dataOut5]=cicIntSectN5(obj,dataOut4,validOutus,reset);
                [dataOut]=cicIntSectN6(obj,dataOut5,validOutus,reset);
            end
            dataOuti=dataOut;
        end

        function[idataOut]=cicIntSectN1(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN1(:);
            for i=1:length(idataIn)
                if reset
                    obj.addOutRegN1=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int1wl,obj.int1fl,hdlfimath);
                elseif ivalidIn
                    obj.addOutRegN1(i,1)=obj.addOutRegN1(i,1)+idataIn(i);
                end
            end
            if reset
                obj.addOutRegN1=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int1wl,obj.int1fl,hdlfimath);
                obj.part1RegN1=fi(zeros(obj.outvecsize,1),1,obj.int1wl,obj.int1fl,hdlfimath);
            elseif(ivalidIn)
                for part=2:length(idataIn)
                    partRegbuff=obj.part1RegN1(part);
                    for i=1:length(idataIn)
                        if i<part
                            obj.addOutRegN1(i,part)=obj.addOutRegN1(i,part-1)+partRegbuff;
                        else
                            if part==2
                                obj.addOutRegN1(i,part)=obj.addOutRegN1(1,part-1)+obj.addOutRegN1(part,1);
                            else
                                obj.addOutRegN1(i,part)=obj.addOutRegN1(i,part-1)+obj.addOutRegN1(part,1);
                            end
                        end
                    end
                    obj.part1RegN1(part)=obj.addOutRegN1(part,1);
                end
            end

            for i=1:length(idataIn)
                part=length(idataIn);
                if reset
                    obj.dataOutIntN1=fi(zeros(obj.outvecsize,1),1,obj.int1wl,obj.int1fl,hdlfimath);
                else
                    obj.dataOutIntN1(i)=obj.addOutRegN1(i,part);
                end
            end
        end

        function[idataOut]=cicIntSectN2(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN2(:);
            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN2=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int2wl,obj.int2fl,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN2(i,1)=obj.addOutRegN2(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN2=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int2wl,obj.int2fl,hdlfimath);
                obj.part1RegN2=fi(zeros(obj.outvecsize,1),1,obj.int2wl,obj.int2fl,hdlfimath);
            elseif(ivalidIn)
                for part=2:length(idataIn)
                    partRegbuff=obj.part1RegN2(part);
                    for i=1:length(idataIn)
                        if i<part
                            obj.addOutRegN2(i,part)=obj.addOutRegN2(i,part-1)+partRegbuff;
                        else
                            if part==2
                                obj.addOutRegN2(i,part)=obj.addOutRegN2(1,part-1)+obj.addOutRegN2(part,1);
                            else
                                obj.addOutRegN2(i,part)=obj.addOutRegN2(i,part-1)+obj.addOutRegN2(part,1);
                            end
                        end
                    end
                    obj.part1RegN2(part)=obj.addOutRegN2(part,1);
                end
            end

            for i=1:length(idataIn)
                part=length(idataIn);
                if reset
                    obj.dataOutIntN2=fi(zeros(obj.outvecsize,1),1,obj.int2wl,obj.int2fl,hdlfimath);
                else
                    obj.dataOutIntN2(i)=obj.addOutRegN2(i,part);
                end
            end
        end

        function[idataOut]=cicIntSectN3(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN3(:);

            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN3=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int3wl,obj.int3fl,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN3(i,1)=obj.addOutRegN3(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN3=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int3wl,obj.int3fl,hdlfimath);
                obj.part1RegN3=fi(zeros(obj.outvecsize,1),1,obj.int3wl,obj.int3fl,hdlfimath);
            elseif(ivalidIn)
                for part=2:length(idataIn)
                    partRegbuff=obj.part1RegN3(part);
                    for i=1:length(idataIn)
                        if i<part
                            obj.addOutRegN3(i,part)=obj.addOutRegN3(i,part-1)+partRegbuff;
                        else
                            if part==2
                                obj.addOutRegN3(i,part)=obj.addOutRegN3(1,part-1)+obj.addOutRegN3(part,1);
                            else
                                obj.addOutRegN3(i,part)=obj.addOutRegN3(i,part-1)+obj.addOutRegN3(part,1);
                            end
                        end
                    end
                    obj.part1RegN3(part)=obj.addOutRegN3(part,1);
                end
            end

            for i=1:length(idataIn)
                part=length(idataIn);
                if reset
                    obj.dataOutIntN3=fi(zeros(obj.outvecsize,1),1,obj.int3wl,obj.int3fl,hdlfimath);
                else
                    obj.dataOutIntN3(i)=obj.addOutRegN3(i,part);
                end
            end
        end

        function[idataOut]=cicIntSectN4(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN4(:);
            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN4=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int4wl,obj.int4fl,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN4(i,1)=obj.addOutRegN4(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN4=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int4wl,obj.int4fl,hdlfimath);
                obj.part1RegN4=fi(zeros(obj.outvecsize,1),1,obj.int4wl,obj.int4fl,hdlfimath);
            elseif(ivalidIn)
                for part=2:length(idataIn)
                    partRegbuff=obj.part1RegN4(part);
                    for i=1:length(idataIn)
                        if i<part
                            obj.addOutRegN4(i,part)=obj.addOutRegN4(i,part-1)+partRegbuff;
                        else
                            if part==2
                                obj.addOutRegN4(i,part)=obj.addOutRegN4(1,part-1)+obj.addOutRegN4(part,1);
                            else
                                obj.addOutRegN4(i,part)=obj.addOutRegN4(i,part-1)+obj.addOutRegN4(part,1);
                            end
                        end
                    end
                    obj.part1RegN4(part)=obj.addOutRegN4(part,1);
                end
            end
            for i=1:length(idataIn)
                part=length(idataIn);
                if reset
                    obj.dataOutIntN4=fi(zeros(obj.outvecsize,1),1,obj.int4wl,obj.int4fl,hdlfimath);
                else
                    obj.dataOutIntN4(i)=obj.addOutRegN4(i,part);
                end
            end
        end

        function[idataOut]=cicIntSectN5(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN5(:);
            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN5=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int5wl,obj.int5fl,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN5(i,1)=obj.addOutRegN5(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN5=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int5wl,obj.int5fl,hdlfimath);
                obj.part1RegN5=fi(zeros(obj.outvecsize,1),1,obj.int5wl,obj.int5fl,hdlfimath);
            elseif(ivalidIn)
                for part=2:length(idataIn)
                    partRegbuff=obj.part1RegN5(part);
                    for i=1:length(idataIn)
                        if i<part
                            obj.addOutRegN5(i,part)=obj.addOutRegN5(i,part-1)+partRegbuff;
                        else
                            if part==2
                                obj.addOutRegN5(i,part)=obj.addOutRegN5(1,part-1)+obj.addOutRegN5(part,1);
                            else
                                obj.addOutRegN5(i,part)=obj.addOutRegN5(i,part-1)+obj.addOutRegN5(part,1);
                            end
                        end
                    end
                    obj.part1RegN5(part)=obj.addOutRegN5(part,1);
                end
            end
            for i=1:length(idataIn)
                part=length(idataIn);
                if reset
                    obj.dataOutIntN5=fi(zeros(obj.outvecsize,1),1,obj.int5wl,obj.int5fl,hdlfimath);
                else
                    obj.dataOutIntN5(i)=obj.addOutRegN5(i,part);
                end
            end
        end

        function[idataOut]=cicIntSectN6(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN6(:);
            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN6=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int6wl,obj.int6fl,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN6(i,1)=obj.addOutRegN6(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN6=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int6wl,obj.int6fl,hdlfimath);
                obj.part1RegN6=fi(zeros(obj.outvecsize,1),1,obj.int6wl,obj.int6fl,hdlfimath);
            elseif(ivalidIn)
                for part=2:length(idataIn)
                    partRegbuff=obj.part1RegN6(part);
                    for i=1:length(idataIn)
                        if i<part
                            obj.addOutRegN6(i,part)=obj.addOutRegN6(i,part-1)+partRegbuff;
                        else
                            if part==2
                                obj.addOutRegN6(i,part)=obj.addOutRegN6(1,part-1)+obj.addOutRegN6(part,1);
                            else
                                obj.addOutRegN6(i,part)=obj.addOutRegN6(i,part-1)+obj.addOutRegN6(part,1);
                            end
                        end
                    end
                    obj.part1RegN6(part)=obj.addOutRegN6(part,1);
                end
            end
            for i=1:length(idataIn)
                part=length(idataIn);
                if reset
                    obj.dataOutIntN6=fi(zeros(obj.outvecsize,1),1,obj.int6wl,obj.int6fl,hdlfimath);
                else
                    obj.dataOutIntN6(i)=obj.addOutRegN6(i,part);
                end
            end
        end

        function[stageDT,gainShift,shiftlength,gDT,fineMult,userDefinedOut]=determineDataTypes(obj,varargin)
            N=obj.NumSections;
            M=obj.DifferentialDelay;
            if strcmpi(obj.InterpolationSource,'Property')
                R=obj.InterpolationFactor;
            else
                R=obj.MaxInterpolationFactor;
            end
            [dataInWordlength,dataInFractionlength]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
            G=(R*M)^(N)/R;
            maxGrowth=ceil(dataInWordlength+log2(G));

            stageDT=coder.const(obj.setStageMaxLength(obj,N,M,R,dataInWordlength,...
            dataInFractionlength));

            switch obj.OutputDataType
            case 'Full precision'
                userDefinedOut=fi(0,1,maxGrowth,dataInFractionlength,hdlfimath);
            case 'Same word length as input'
                if obj.GainCorrection
                    userDefinedOut=fi(0,1,dataInWordlength,dataInFractionlength);
                else
                    userDefinedOut=fi(0,1,dataInWordlength,...
                    dataInFractionlength-(maxGrowth-dataInWordlength));
                end
            case 'Minimum section word lengths'
                if obj.GainCorrection
                    userDefinedOut=fi(0,1,obj.OutputWordLength,...
                    (dataInFractionlength+obj.OutputWordLength-dataInWordlength));
                else
                    fractionL=dataInFractionlength-(ceil(dataInWordlength+log2(G))-obj.OutputWordLength);
                    userDefinedOut=fi(0,1,obj.OutputWordLength,fractionL,hdlfimath);
                end
            end
            [gainShift,shiftlength,gDT]=coder.const(@obj.gainCalculationsfixdt,N,M,R,~strcmpi(obj.InterpolationSource,'Property'),stageDT);
            fineMult=coder.const(obj.fineGainCalculationsfixdt(N,M,R,~strcmpi(obj.InterpolationSource,'Property')));
        end

        function initializeVariables(obj,pruned,varargin)



            N=obj.NumSections;
            if strcmpi(obj.InterpolationSource,'Property')
                R=obj.InterpolationFactor;
            else
                R=obj.MaxInterpolationFactor;
            end
            obj.dataIntReg=cell(1,7);
            obj.dataComReg=cell(1,7);
            obj.dataComRegReg=cell(1,7);
            obj.subtmp=cell(1,7);
            obj.validUsReg=false(1,1);
            obj.validComReg=false(1,N);
            obj.cValidbuf=false(1,N);
            obj.validOuti1=false;
            obj.validOuti2=false;
            obj.validOuti3=false;
            obj.validOuti4=false;
            obj.validOuti5=false;
            obj.validOuti6=false;
            obj.validOuti7=false;
            obj.validOuti8=false;
            obj.validOuti9=false;

            obj.validOutcreg1=false;
            obj.validOutcreg2=false;
            obj.validOutcreg3=false;
            obj.validOutcreg4=false;
            obj.validOutcreg5=false;

            obj.gainValidTmp=false;
            obj.changeinR=false;
            obj.resetreg=false;
            obj.validInreg=false;
            obj.validInreg1=false;
            if obj.invecsize==1
                val=0;
            else
                val=zeros(obj.invecsize,1);
            end
            obj.dataInireg=cast(val,'like',(varargin{1}));
            pruned={pruned{:},pruned{:},pruned{:}};

            obj.int1wl=pruned{N+1}.WordLength;
            obj.int1fl=pruned{N+1}.FractionLength;
            obj.int2wl=pruned{N+2}.WordLength;
            obj.int2fl=pruned{N+2}.FractionLength;
            obj.int3wl=pruned{N+3}.WordLength;
            obj.int3fl=pruned{N+3}.FractionLength;
            obj.int4wl=pruned{N+4}.WordLength;
            obj.int4fl=pruned{N+4}.FractionLength;
            obj.int5wl=pruned{N+5}.WordLength;
            obj.int5fl=pruned{N+5}.FractionLength;
            obj.int6wl=pruned{N+6}.WordLength;
            obj.int6fl=pruned{N+6}.FractionLength;

            obj.dswl=pruned{N+1}.WordLength;
            obj.dsfl=pruned{N+1}.FractionLength;

            obj.com1wl=pruned{1}.WordLength;
            obj.com1fl=pruned{1}.FractionLength;
            obj.com2wl=pruned{2}.WordLength;
            obj.com2fl=pruned{2}.FractionLength;
            obj.com3wl=pruned{3}.WordLength;
            obj.com3fl=pruned{3}.FractionLength;
            obj.com4wl=pruned{4}.WordLength;
            obj.com4fl=pruned{4}.FractionLength;
            obj.com5wl=pruned{5}.WordLength;
            obj.com5fl=pruned{5}.FractionLength;
            obj.com6wl=pruned{6}.WordLength;
            obj.com6fl=pruned{6}.FractionLength;
            if obj.NumSections==1
                outWL=pruned{N+1}.WordLength;
                outFL=pruned{N+1}.FractionLength;
            elseif obj.NumSections==2
                outWL=pruned{N+2}.WordLength;
                outFL=pruned{N+2}.FractionLength;
            elseif obj.NumSections==3
                outWL=pruned{N+3}.WordLength;
                outFL=pruned{N+3}.FractionLength;
            elseif obj.NumSections==4
                outWL=pruned{N+4}.WordLength;
                outFL=pruned{N+4}.FractionLength;
            elseif obj.NumSections==5
                outWL=pruned{N+5}.WordLength;
                outFL=pruned{N+5}.FractionLength;
            else
                outWL=pruned{N+6}.WordLength;
                outFL=pruned{N+6}.FractionLength;
            end

            if((obj.NumCycles<obj.InterpolationFactor)||obj.invecsize>1)&&strcmpi(obj.InterpolationSource,'Property')
                val1=zeros((R*obj.invecsize)/obj.NumCycles,1);
                val2=zeros((R*obj.invecsize),1);
            else
                val1=0;
                val2=0;
            end


            if isreal(varargin{1})

                obj.dataIntReg{1}=cast(0,'like',(pruned{N+1}));
                obj.dataIntReg{2}=cast(0,'like',(pruned{N+2}));
                obj.dataIntReg{3}=cast(0,'like',(pruned{N+3}));
                obj.dataIntReg{4}=cast(0,'like',(pruned{N+4}));
                obj.dataIntReg{5}=cast(0,'like',(pruned{N+5}));
                obj.dataIntReg{6}=cast(0,'like',(pruned{N+6}));
                obj.dataIntReg{7}=cast(0,'like',(pruned{N+6}));

                obj.dataUsReg=cast(val2,'like',(pruned{N+1}));

                obj.dataComReg{1}=cast(0,'like',(pruned{1}));
                obj.dataComReg{2}=cast(0,'like',(pruned{2}));
                obj.dataComReg{3}=cast(0,'like',(pruned{3}));
                obj.dataComReg{4}=cast(0,'like',(pruned{4}));
                obj.dataComReg{5}=cast(0,'like',(pruned{5}));
                obj.dataComReg{6}=cast(0,'like',(pruned{6}));
                obj.dataComReg{7}=cast(0,'like',(pruned{6}));

                obj.dataComRegReg{1}=cast(0,'like',(pruned{1}));
                obj.dataComRegReg{2}=cast(0,'like',(pruned{2}));
                obj.dataComRegReg{3}=cast(0,'like',(pruned{3}));
                obj.dataComRegReg{4}=cast(0,'like',(pruned{4}));
                obj.dataComRegReg{5}=cast(0,'like',(pruned{5}));
                obj.dataComRegReg{6}=cast(0,'like',(pruned{6}));
                obj.dataComRegReg{7}=cast(0,'like',(pruned{6}));

                obj.subtmp{1}=cast(0,'like',(pruned{1}));
                obj.subtmp{2}=cast(0,'like',(pruned{2}));
                obj.subtmp{3}=cast(0,'like',(pruned{3}));
                obj.subtmp{4}=cast(0,'like',(pruned{4}));
                obj.subtmp{5}=cast(0,'like',(pruned{5}));
                obj.subtmp{6}=cast(0,'like',(pruned{6}));
                obj.subtmp{7}=cast(0,'like',(pruned{6}));

                obj.gainOuta1=fi(0,1,pruned{(N*2)+1}.WordLength,pruned{(N*2)+1}.FractionLength);

                if obj.GainCorrection
                    obj.gainOuta=fi(val1,obj.gDT);
                    obj.gainOutatmp=fi(val1,obj.gDT);
                    obj.gainOutatmp1=fi(val1,obj.gDT);
                    obj.gainOutatmp2=fi(val1,obj.gDT);
                    obj.gainOutareg1=fi(val1,obj.gDT);
                    obj.gainOutareg2=fi(val1,obj.gDT);
                    obj.gainOutareg3=fi(val1,obj.gDT);
                    obj.gainOutareg4=fi(val1,obj.gDT);
                    obj.gainOutareg5=fi(val1,obj.gDT);
                else
                    obj.gainOuta=cast(val1,'like',pruned{(N*2)+1});
                    obj.gainOutatmp=cast(val1,'like',pruned{(N*2)+1});
                    obj.gainOutareg1=cast(val1,'like',pruned{(N*2)+1});
                    obj.gainOutareg2=cast(val1,'like',pruned{(N*2)+1});
                    obj.gainOutareg3=cast(val1,'like',pruned{(N*2)+1});
                    obj.gainOutareg4=cast(val1,'like',pruned{(N*2)+1});
                    obj.gainOutareg5=cast(val1,'like',pruned{(N*2)+1});
                end
                if~strcmpi(obj.InterpolationSource,'Property')||(obj.NumCycles==obj.InterpolationFactor)&&isscalar(varargin{1})
                    obj.gainDatareg=fi([0,0],obj.gDT);
                else
                    obj.gainDatareg=fi(zeros(obj.outvecsize1,2),obj.gDT);
                end
                obj.fgainDatareg=fi([0,0],1,23,21);

                if~strcmp(obj.OutputDataType,'Full precision')
                    obj.gainOut=cast(val1,'like',obj.userDefinedOut);
                    obj.gainOutTmp=cast(val1,'like',obj.userDefinedOut);
                else
                    obj.gainOut=cast(val1,'like',obj.gainOuta);
                    obj.gainOutTmp=cast(val1,'like',obj.gainOuta);
                end
                if obj.invecsize~=1
                    obj.dataOutComreg1=fi(0,1,obj.com1wl,obj.com1fl,hdlfimath);
                    obj.dataOutComreg2=fi(0,1,obj.com2wl,obj.com2fl,hdlfimath);
                    obj.dataOutComreg3=fi(0,1,obj.com3wl,obj.com3fl,hdlfimath);
                    obj.dataOutComreg4=fi(0,1,obj.com4wl,obj.com4fl,hdlfimath);
                    obj.dataOutComreg5=fi(0,1,obj.com5wl,obj.com5fl,hdlfimath);
                    obj.dataOutComreg6=fi(0,1,obj.com6wl,obj.com6fl,hdlfimath);
                    obj.dataOutCom1reg1=fi(0,1,obj.com1wl,obj.com1fl,hdlfimath);
                    obj.dataOutCom2reg2=fi(0,1,obj.com2wl,obj.com2fl,hdlfimath);
                    obj.dataOutCom3reg3=fi(0,1,obj.com3wl,obj.com3fl,hdlfimath);
                    obj.dataOutCom4reg4=fi(0,1,obj.com4wl,obj.com4fl,hdlfimath);
                    obj.dataOutCom5reg5=fi(0,1,obj.com5wl,obj.com5fl,hdlfimath);
                    obj.dataOutCom6reg6=fi(0,1,obj.com6wl,obj.com6fl,hdlfimath);
                    obj.dataOutcreg1=fi(val,1,obj.com1wl,obj.com1fl,hdlfimath);
                    obj.dataOutcreg2=fi(val,1,obj.com2wl,obj.com2fl,hdlfimath);
                    obj.dataOutcreg3=fi(val,1,obj.com3wl,obj.com3fl,hdlfimath);
                    obj.dataOutcreg4=fi(val,1,obj.com4wl,obj.com4fl,hdlfimath);
                    obj.dataOutcreg5=fi(val,1,obj.com5wl,obj.com5fl,hdlfimath);
                    obj.dataOutcreg6=fi(val,1,obj.com6wl,obj.com6fl,hdlfimath);
                end
                obj.dataOutiprev=fi(zeros(obj.outvecsize,1),1,outWL,outFL,hdlfimath);
                obj.dataOutIntN1=fi(zeros(obj.outvecsize,1),1,obj.int1wl,obj.int1fl,hdlfimath);
                obj.dataOutIntN2=fi(zeros(obj.outvecsize,1),1,obj.int2wl,obj.int2fl,hdlfimath);
                obj.dataOutIntN3=fi(zeros(obj.outvecsize,1),1,obj.int3wl,obj.int3fl,hdlfimath);
                obj.dataOutIntN4=fi(zeros(obj.outvecsize,1),1,obj.int4wl,obj.int4fl,hdlfimath);
                obj.dataOutIntN5=fi(zeros(obj.outvecsize,1),1,obj.int5wl,obj.int5fl,hdlfimath);
                obj.dataOutIntN6=fi(zeros(obj.outvecsize,1),1,obj.int6wl,obj.int6fl,hdlfimath);
                obj.addOutRegN1=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int1wl,obj.int1fl,hdlfimath);
                obj.addOutRegN2=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int2wl,obj.int2fl,hdlfimath);
                obj.addOutRegN3=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int3wl,obj.int3fl,hdlfimath);
                obj.addOutRegN4=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int4wl,obj.int4fl,hdlfimath);
                obj.addOutRegN5=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int5wl,obj.int5fl,hdlfimath);
                obj.addOutRegN6=fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int6wl,obj.int6fl,hdlfimath);
                obj.part1RegN1=fi(zeros(obj.outvecsize,1),1,obj.int1wl,obj.int1fl,hdlfimath);
                obj.part1RegN2=fi(zeros(obj.outvecsize,1),1,obj.int2wl,obj.int2fl,hdlfimath);
                obj.part1RegN3=fi(zeros(obj.outvecsize,1),1,obj.int3wl,obj.int3fl,hdlfimath);
                obj.part1RegN4=fi(zeros(obj.outvecsize,1),1,obj.int4wl,obj.int4fl,hdlfimath);
                obj.part1RegN5=fi(zeros(obj.outvecsize,1),1,obj.int5wl,obj.int5fl,hdlfimath);
                obj.part1RegN6=fi(zeros(obj.outvecsize,1),1,obj.int6wl,obj.int6fl,hdlfimath);
                obj.buffreg=fi(zeros(obj.outvecsize,1),1,outWL,outFL,hdlfimath);
            else
                obj.dataIntReg{1}=complex(cast(0,'like',(pruned{N+1})));
                obj.dataIntReg{2}=complex(cast(0,'like',(pruned{N+2})));
                obj.dataIntReg{3}=complex(cast(0,'like',(pruned{N+3})));
                obj.dataIntReg{4}=complex(cast(0,'like',(pruned{N+4})));
                obj.dataIntReg{5}=complex(cast(0,'like',(pruned{N+5})));
                obj.dataIntReg{6}=complex(cast(0,'like',(pruned{N+6})));
                obj.dataIntReg{7}=complex(cast(0,'like',(pruned{N+6})));

                obj.dataUsReg=complex(cast(val2,'like',(pruned{N})));

                obj.dataComReg{1}=complex(cast(0,'like',(pruned{1})));
                obj.dataComReg{2}=complex(cast(0,'like',(pruned{2})));
                obj.dataComReg{3}=complex(cast(0,'like',(pruned{3})));
                obj.dataComReg{4}=complex(cast(0,'like',(pruned{4})));
                obj.dataComReg{5}=complex(cast(0,'like',(pruned{5})));
                obj.dataComReg{6}=complex(cast(0,'like',(pruned{6})));
                obj.dataComReg{7}=complex(cast(0,'like',(pruned{6})));

                obj.dataComRegReg{1}=complex(cast(0,'like',(pruned{1})));
                obj.dataComRegReg{2}=complex(cast(0,'like',(pruned{2})));
                obj.dataComRegReg{3}=complex(cast(0,'like',(pruned{3})));
                obj.dataComRegReg{4}=complex(cast(0,'like',(pruned{4})));
                obj.dataComRegReg{5}=complex(cast(0,'like',(pruned{5})));
                obj.dataComRegReg{6}=complex(cast(0,'like',(pruned{6})));
                obj.dataComRegReg{7}=complex(cast(0,'like',(pruned{6})));

                obj.subtmp{1}=complex(cast(0,'like',(pruned{1})));
                obj.subtmp{2}=complex(cast(0,'like',(pruned{2})));
                obj.subtmp{3}=complex(cast(0,'like',(pruned{3})));
                obj.subtmp{4}=complex(cast(0,'like',(pruned{4})));
                obj.subtmp{5}=complex(cast(0,'like',(pruned{5})));
                obj.subtmp{6}=complex(cast(0,'like',(pruned{6})));
                obj.subtmp{7}=complex(cast(0,'like',(pruned{6})));

                obj.gainOuta1=complex(fi(0,1,pruned{(N*2)+1}.WordLength,pruned{(N*2)+1}.FractionLength));

                if obj.GainCorrection
                    obj.gainOuta=complex(fi(val1,obj.gDT));
                    obj.gainOutatmp=complex(fi(val1,obj.gDT));
                    obj.gainOutatmp1=complex(fi(val1,obj.gDT));
                    obj.gainOutatmp2=complex(fi(val1,obj.gDT));
                    obj.gainOutareg1=complex(fi(val1,obj.gDT));
                    obj.gainOutareg2=complex(fi(val1,obj.gDT));
                    obj.gainOutareg3=complex(fi(val1,obj.gDT));
                    obj.gainOutareg4=complex(fi(val1,obj.gDT));
                    obj.gainOutareg5=complex(fi(val1,obj.gDT));
                else
                    obj.gainOuta=complex(cast(val1,'like',pruned{(N*2)+1}));
                    obj.gainOutatmp=complex(cast(val1,'like',pruned{(N*2)+1}));
                    obj.gainOutareg1=complex(cast(val1,'like',pruned{(N*2)+1}));
                    obj.gainOutareg2=complex(cast(val1,'like',pruned{(N*2)+1}));
                    obj.gainOutareg3=complex(cast(val1,'like',pruned{(N*2)+1}));
                    obj.gainOutareg4=complex(cast(val1,'like',pruned{(N*2)+1}));
                    obj.gainOutareg5=complex(cast(val1,'like',pruned{(N*2)+1}));
                end
                if~strcmpi(obj.InterpolationSource,'Property')||(obj.NumCycles==obj.InterpolationFactor)&&isscalar(varargin{1})
                    obj.gainDatareg=complex(fi([0,0],obj.gDT));
                else
                    obj.gainDatareg=complex(fi(zeros(obj.outvecsize1,2),obj.gDT));
                end

                obj.fgainDatareg=complex(fi([0,0],1,23,21));

                if~strcmp(obj.OutputDataType,'Full precision')
                    obj.gainOut=cast(complex(val1),'like',obj.userDefinedOut);
                    obj.gainOutTmp=cast(complex(val1),'like',obj.userDefinedOut);
                else
                    obj.gainOut=cast(complex(val1),'like',obj.gainOuta);
                    obj.gainOutTmp=cast(complex(val1),'like',obj.gainOuta);
                end
                if obj.invecsize~=1
                    obj.dataOutComreg1=complex(fi(0,1,obj.com1wl,obj.com1fl,hdlfimath));
                    obj.dataOutComreg2=complex(fi(0,1,obj.com2wl,obj.com2fl,hdlfimath));
                    obj.dataOutComreg3=complex(fi(0,1,obj.com3wl,obj.com3fl,hdlfimath));
                    obj.dataOutComreg4=complex(fi(0,1,obj.com4wl,obj.com4fl,hdlfimath));
                    obj.dataOutComreg5=complex(fi(0,1,obj.com5wl,obj.com5fl,hdlfimath));
                    obj.dataOutComreg6=complex(fi(0,1,obj.com6wl,obj.com6fl,hdlfimath));
                    obj.dataOutCom1reg1=complex(fi(0,1,obj.com1wl,obj.com1fl,hdlfimath));
                    obj.dataOutCom2reg2=complex(fi(0,1,obj.com2wl,obj.com2fl,hdlfimath));
                    obj.dataOutCom3reg3=complex(fi(0,1,obj.com3wl,obj.com3fl,hdlfimath));
                    obj.dataOutCom4reg4=complex(fi(0,1,obj.com4wl,obj.com4fl,hdlfimath));
                    obj.dataOutCom5reg5=complex(fi(0,1,obj.com5wl,obj.com5fl,hdlfimath));
                    obj.dataOutCom6reg6=complex(fi(0,1,obj.com6wl,obj.com6fl,hdlfimath));
                    obj.dataOutcreg1=complex(fi(val,1,obj.com1wl,obj.com1fl,hdlfimath));
                    obj.dataOutcreg2=complex(fi(val,1,obj.com2wl,obj.com2fl,hdlfimath));
                    obj.dataOutcreg3=complex(fi(val,1,obj.com3wl,obj.com3fl,hdlfimath));
                    obj.dataOutcreg4=complex(fi(val,1,obj.com4wl,obj.com4fl,hdlfimath));
                    obj.dataOutcreg5=complex(fi(val,1,obj.com5wl,obj.com5fl,hdlfimath));
                    obj.dataOutcreg6=complex(fi(val,1,obj.com6wl,obj.com6fl,hdlfimath));
                end
                obj.dataOutiprev=complex(fi(zeros(obj.outvecsize,1),1,outWL,outFL,hdlfimath));
                obj.dataOutIntN1=complex(fi(zeros(obj.outvecsize,1),1,obj.int1wl,obj.int1fl,hdlfimath));
                obj.dataOutIntN2=complex(fi(zeros(obj.outvecsize,1),1,obj.int2wl,obj.int2fl,hdlfimath));
                obj.dataOutIntN3=complex(fi(zeros(obj.outvecsize,1),1,obj.int3wl,obj.int3fl,hdlfimath));
                obj.dataOutIntN4=complex(fi(zeros(obj.outvecsize,1),1,obj.int4wl,obj.int4fl,hdlfimath));
                obj.dataOutIntN5=complex(fi(zeros(obj.outvecsize,1),1,obj.int5wl,obj.int5fl,hdlfimath));
                obj.dataOutIntN6=complex(fi(zeros(obj.outvecsize,1),1,obj.int6wl,obj.int6fl,hdlfimath));
                obj.addOutRegN1=complex(fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int1wl,obj.int1fl,hdlfimath));
                obj.addOutRegN2=complex(fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int2wl,obj.int2fl,hdlfimath));
                obj.addOutRegN3=complex(fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int3wl,obj.int3fl,hdlfimath));
                obj.addOutRegN4=complex(fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int4wl,obj.int4fl,hdlfimath));
                obj.addOutRegN5=complex(fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int5wl,obj.int5fl,hdlfimath));
                obj.addOutRegN6=complex(fi(zeros(obj.outvecsize,obj.outvecsize),1,obj.int6wl,obj.int6fl,hdlfimath));
                obj.part1RegN1=complex(fi(zeros(obj.outvecsize,1),1,obj.int1wl,obj.int1fl,hdlfimath));
                obj.part1RegN2=complex(fi(zeros(obj.outvecsize,1),1,obj.int2wl,obj.int2fl,hdlfimath));
                obj.part1RegN3=complex(fi(zeros(obj.outvecsize,1),1,obj.int3wl,obj.int3fl,hdlfimath));
                obj.part1RegN4=complex(fi(zeros(obj.outvecsize,1),1,obj.int4wl,obj.int4fl,hdlfimath));
                obj.part1RegN5=complex(fi(zeros(obj.outvecsize,1),1,obj.int5wl,obj.int5fl,hdlfimath));
                obj.part1RegN6=complex(fi(zeros(obj.outvecsize,1),1,obj.int6wl,obj.int6fl,hdlfimath));
                obj.buffreg=complex(fi(zeros(obj.outvecsize,1),1,outWL,outFL,hdlfimath));
            end
            obj.gainValid=false;
            obj.count=fi(0,0,ceil(log2(R+1))+1,0,hdlfimath);
            obj.upsampleMax=fi(1,0,12,0);
            obj.usMaxreg=fi(1,0,12,0);
            obj.previnterpFactor=fi(1,0,12,0);
            obj.validOutusreg=false;
            obj.state1=fi(0,0,3,0);
            obj.readyReg=true;
            obj.count1=fi(0,0,max(1,ceil(log2(R))),0,'OverflowAction','Wrap');
            obj.buffstate=false;
            obj.buffcount=fi(0,0,ceil(log2(R))+1,0,hdlfimath);
        end

        function[gainout,validout]=gainCorrection(obj,dataOuti,validOuti,reset)
            if~strcmpi(obj.InterpolationSource,'Property')||...
                (isscalar(dataOuti)&&~((obj.NumCycles==1&&obj.InterpolationFactor~=1)...
                ||obj.NumCycles<obj.InterpolationFactor))
                if obj.GainCorrection
                    if strcmpi(obj.InterpolationSource,'Property')
                        if obj.gDT.WordLength+obj.shiftlength>=128
                            bShiftWL=128;
                        else
                            bShiftWL=obj.gDT.WordLength+obj.shiftlength;
                        end

                        bShift=cast(dataOuti,'like',obj.gainOuta1);
                        bRightShift=bitshift(fi(bShift,1,bShiftWL,...
                        obj.gDT.FractionLength),-obj.shiftlength);
                        coarseG=fi(bRightShift,1,obj.gDT.WordLength,obj.gDT.FractionLength,...
                        'RoundingMethod','Nearest','OverflowAction','Saturate');
                        fineGtmp=fi(obj.fineMult,1,23,21);
                        if reset
                            coarseGtmp=obj.gainDatareg(2);
                            obj.gainDatareg(2)=fi(0,obj.gDT);
                            obj.gainDatareg(1)=fi(0,obj.gDT);

                            fineG=obj.fgainDatareg(2);
                            obj.fgainDatareg(2)=fi(0,1,23,21);
                            obj.fgainDatareg(1)=fi(0,1,23,21);
                        else
                            coarseGtmp=obj.gainDatareg(2);
                            obj.gainDatareg(2)=obj.gainDatareg(1);
                            obj.gainDatareg(1)=coarseG;

                            fineG=obj.fgainDatareg(2);
                            obj.fgainDatareg(2)=obj.fgainDatareg(1);
                            obj.fgainDatareg(1)=fineGtmp;
                        end
                        obj.gainOuta(:)=obj.gainOutareg1;
                        obj.gainOutareg1(:)=obj.gainOutareg2;
                        obj.gainOutareg2(:)=obj.gainOutareg3;
                        obj.gainOutareg3(:)=obj.gainOutareg4;
                        obj.gainOutareg4(:)=obj.gainOutareg5;
                        if(fineG==fi(1,1,23,21))
                            obj.gainOutareg5=cast(coarseGtmp,'like',coarseG);
                        else
                            obj.gainOutareg5=cast(coarseGtmp*fineG,'like',coarseG);
                        end
                    else
                        x=obj.gainShift{obj.upsampleMax};
                        bShift=cast(bitsll(dataOuti,x),'like',obj.gainOuta1);
                        coarseG=reinterpretcast(bShift,obj.gDT);
                        fineGtmp=fi(obj.fineMult{obj.upsampleMax},1,23,21);
                        if reset
                            coarseGtmp=obj.gainDatareg(2);
                            obj.gainDatareg(2)=fi(0,obj.gDT);
                            obj.gainDatareg(1)=fi(0,obj.gDT);
                            fineG=obj.fgainDatareg(2);
                            obj.fgainDatareg(2)=fi(0,1,23,21);
                            obj.fgainDatareg(1)=fi(0,1,23,21);
                        else
                            coarseGtmp=obj.gainDatareg(2);
                            obj.gainDatareg(2)=obj.gainDatareg(1);
                            obj.gainDatareg(1)=coarseG;
                            fineG=obj.fgainDatareg(2);
                            obj.fgainDatareg(2)=obj.fgainDatareg(1);
                            obj.fgainDatareg(1)=fineGtmp;
                        end
                        obj.gainOuta(:)=obj.gainOutareg1;
                        obj.gainOutareg1(:)=obj.gainOutareg2;
                        obj.gainOutareg2(:)=obj.gainOutareg3;
                        obj.gainOutareg3(:)=obj.gainOutareg4;
                        obj.gainOutareg4(:)=obj.gainOutareg5;
                        obj.gainOutareg5=cast(coarseGtmp*fineG,'like',coarseG);
                    end
                else
                    obj.gainOuta(:)=cast(dataOuti,'like',obj.gainOuta);
                end
            else
                if obj.GainCorrection
                    if obj.gDT.WordLength+obj.shiftlength>=128
                        bShiftWL=128;
                    else
                        bShiftWL=obj.gDT.WordLength+obj.shiftlength;
                    end

                    bShift=cast(dataOuti,'like',obj.gainOuta1);
                    bRightShift=bitshift(fi(bShift,1,bShiftWL,...
                    obj.gDT.FractionLength),-obj.shiftlength);
                    coarseG=fi(bRightShift,1,obj.gDT.WordLength,obj.gDT.FractionLength,...
                    'RoundingMethod','Nearest','OverflowAction','Saturate');
                    fineGtmp=fi(obj.fineMult,1,23,21);
                    if reset
                        coarseGtmp=obj.gainDatareg(:,2);
                        obj.gainDatareg(:,2)=fi(zeros(obj.outvecsize1,1),obj.gDT);
                        obj.gainDatareg(:,1)=fi(zeros(obj.outvecsize1,1),obj.gDT);

                        fineG=obj.fgainDatareg(2);
                        obj.fgainDatareg(2)=fi(0,1,23,21);
                        obj.fgainDatareg(1)=fi(0,1,23,21);
                    else
                        coarseGtmp=obj.gainDatareg(:,2);
                        obj.gainDatareg(:,2)=obj.gainDatareg(:,1);
                        obj.gainDatareg(:,1)=coarseG;

                        fineG=obj.fgainDatareg(2);
                        obj.fgainDatareg(2)=obj.fgainDatareg(1);
                        obj.fgainDatareg(1)=fineGtmp;
                    end
                    obj.gainOuta(:)=obj.gainOutareg1;
                    obj.gainOutareg1(:)=obj.gainOutareg2;
                    obj.gainOutareg2(:)=obj.gainOutareg3;
                    obj.gainOutareg3(:)=obj.gainOutareg4;
                    obj.gainOutareg4(:)=obj.gainOutareg5;
                    if(fineG==fi(1,1,23,21))
                        obj.gainOutareg5=cast(coarseGtmp,'like',coarseG);
                    else
                        obj.gainOutareg5=cast(coarseGtmp*fineG,'like',coarseG);
                    end
                else
                    obj.gainOuta(:)=cast(dataOuti,'like',obj.gainOuta);
                end
            end
            if obj.GainCorrection
                obj.gainOutatmp(:)=obj.gainOutatmp1;
                obj.gainOutatmp1(:)=obj.gainOutatmp2;
                obj.gainOutatmp2(:)=obj.gainOuta;
            else
                obj.gainOutatmp(:)=obj.gainOuta;
            end

            if~strcmp(obj.OutputDataType,'Full precision')
                gainout=cast(obj.gainOutatmp,'like',obj.userDefinedOut);
            else
                gainout=obj.gainOutatmp;
            end

            if reset
                validout=false;
                obj.validOuti9=false;
                obj.validOuti8=false;
                obj.validOuti7=false;
                obj.validOuti6=false;
                obj.validOuti5=false;
                obj.validOuti4=false;
                obj.validOuti3=false;
                obj.validOuti2=false;
                obj.validOuti1=false;
            else
                if obj.GainCorrection
                    validout=obj.validOuti9;
                    obj.validOuti9=obj.validOuti8;
                    obj.validOuti8=obj.validOuti7;
                    obj.validOuti7=obj.validOuti6;
                    obj.validOuti6=obj.validOuti5;
                    obj.validOuti5=obj.validOuti4;
                    obj.validOuti4=obj.validOuti3;
                    obj.validOuti3=obj.validOuti2;
                    obj.validOuti2=obj.validOuti1;
                    obj.validOuti1=validOuti;
                else
                    validout=validOuti;
                end
            end
        end

        function resetImpl(obj)
            N=obj.NumSections;
            obj.count(:)=0;
            obj.validUsReg=false(1,1);
            obj.validComReg=false(1,N);
            for i=1:N+1
                obj.dataIntReg{i}(:)=0;
            end
            obj.dataUsReg(:)=0;
            for i=1:N+1
                obj.dataComReg{i}(:)=0;
                obj.dataComRegReg{i}(:)=0;
            end
            for i=1:N+1
                obj.subtmp{i}(:)=0;
            end
            obj.gainOut(:)=0;

            obj.gainOutTmp(:)=0;
            obj.gainValidTmp=false;
            obj.gainValid=false;
            obj.cValidbuf=false(1,N);
            obj.stateInt=false;
            obj.gainOuta(:)=0;
            obj.gainOutatmp(:)=0;
            obj.gainOutatmp1(:)=0;
            obj.gainOutatmp2(:)=0;
            obj.gainOutareg1(:)=0;
            obj.gainOutareg2(:)=0;
            obj.gainOutareg3(:)=0;
            obj.gainOutareg4(:)=0;
            obj.gainOutareg5(:)=0;
            obj.gainDatareg(:)=0;
            obj.fgainDatareg=fi([0,0],1,23,21);
            obj.validOuti1=false;
            obj.validOuti2=false;
            obj.validOuti3=false;
            obj.validOuti4=false;
            obj.validOuti5=false;
            obj.validOuti6=false;
            obj.validOuti7=false;
            obj.validOuti8=false;
            obj.validOuti9=false;
            obj.validOutcreg1=false;
            obj.validOutcreg2=false;
            obj.validOutcreg3=false;
            obj.validOutcreg4=false;
            obj.validOutcreg5=false;
            obj.changeinR=false;

            if strcmpi(obj.InterpolationSource,'Property')
                R=obj.InterpolationFactor;
                if obj.pInitialize
                    obj.state1=fi(0,0,3,0);
                    obj.count1=fi(0,0,max(1,ceil(log2(R))),0,'OverflowAction','Wrap');
                else
                    obj.state1=fi(1,0,3,0);
                    obj.count1=fi(R-1,0,max(1,ceil(log2(R))),0,'OverflowAction','Wrap');
                end
            else
                R=obj.MaxInterpolationFactor;
                if isequal(R,2)
                    obj.state1=fi(0,0,3,0);
                    obj.count1=fi(0,0,max(1,ceil(log2(R))),0,'OverflowAction','Wrap');
                else
                    obj.state1=fi(1,0,3,0);
                    obj.count1=fi(double(obj.usMaxreg)-1,0,max(1,ceil(log2(R))),0,'OverflowAction','Wrap');
                end
            end
            if obj.invecsize==1
                val=0;
            else
                val=zeros(obj.invecsize,1);
            end
            obj.countVect=fi(0,0,4,0,hdlfimath);
            if obj.invecsize~=1
                obj.dataOutComreg1=fi(0,1,obj.com1wl,obj.com1fl,hdlfimath);
                obj.dataOutComreg2=fi(0,1,obj.com2wl,obj.com2fl,hdlfimath);
                obj.dataOutComreg3=fi(0,1,obj.com3wl,obj.com3fl,hdlfimath);
                obj.dataOutComreg4=fi(0,1,obj.com4wl,obj.com4fl,hdlfimath);
                obj.dataOutComreg5=fi(0,1,obj.com5wl,obj.com5fl,hdlfimath);
                obj.dataOutComreg6=fi(0,1,obj.com6wl,obj.com6fl,hdlfimath);
                obj.dataOutCom1reg1=fi(0,1,obj.com1wl,obj.com1fl,hdlfimath);
                obj.dataOutCom2reg2=fi(0,1,obj.com2wl,obj.com2fl,hdlfimath);
                obj.dataOutCom3reg3=fi(0,1,obj.com3wl,obj.com3fl,hdlfimath);
                obj.dataOutCom4reg4=fi(0,1,obj.com4wl,obj.com4fl,hdlfimath);
                obj.dataOutCom5reg5=fi(0,1,obj.com5wl,obj.com5fl,hdlfimath);
                obj.dataOutCom6reg6=fi(0,1,obj.com6wl,obj.com6fl,hdlfimath);
                obj.dataOutcreg1=fi(val,1,obj.com1wl,obj.com1fl,hdlfimath);
                obj.dataOutcreg2=fi(val,1,obj.com2wl,obj.com2fl,hdlfimath);
                obj.dataOutcreg3=fi(val,1,obj.com3wl,obj.com3fl,hdlfimath);
                obj.dataOutcreg4=fi(val,1,obj.com4wl,obj.com4fl,hdlfimath);
                obj.dataOutcreg5=fi(val,1,obj.com5wl,obj.com5fl,hdlfimath);
                obj.dataOutcreg6=fi(val,1,obj.com6wl,obj.com6fl,hdlfimath);
            end
            obj.dataOutiprev(:)=0;
            obj.dataOutIntN1(:)=0;
            obj.dataOutIntN2(:)=0;
            obj.dataOutIntN3(:)=0;
            obj.dataOutIntN4(:)=0;
            obj.dataOutIntN5(:)=0;
            obj.dataOutIntN6(:)=0;
            obj.addOutRegN1(:)=0;
            obj.addOutRegN2(:)=0;
            obj.addOutRegN3(:)=0;
            obj.addOutRegN4(:)=0;
            obj.addOutRegN5(:)=0;
            obj.addOutRegN6(:)=0;
            obj.part1RegN1(:)=0;
            obj.part1RegN2(:)=0;
            obj.part1RegN3(:)=0;
            obj.part1RegN4(:)=0;
            obj.part1RegN5(:)=0;
            obj.part1RegN6(:)=0;
            reset(obj.delayBalance1RV);
            reset(obj.delayBalance1IV);
            reset(obj.delayBalance2V);
            reset(obj.delayBalanceNRV);
            reset(obj.delayBalanceNIV);
            reset(obj.delayBalanceNV);
            obj.buffstate=false;
            obj.buffcount=fi(0,0,ceil(log2(R))+1,0,hdlfimath);
            obj.buffreg(:)=0;
            if obj.pInitialize
                obj.readyReg=true;
                obj.pInitialize=false;
            else
                obj.readyReg=false;
            end
        end

        function flag=getExecutionSemanticsImpl(obj)
            if obj.ResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end
    end

    methods(Access=public)
        function latency=getLatency(obj,varargin)
            if nargin==2
                if isempty(varargin{1})
                    inputlen=1;
                else
                    inputlen=(varargin{1});
                end
            else
                inputlen=obj.vectorSize;
                if isempty(inputlen)
                    inputlen=1;
                end
            end

            if obj.NumCycles==1&&strcmpi(obj.InterpolationSource,'Property')
                commonlatency=2+(obj.InterpolationFactor~=1)+(obj.NumSections*(inputlen*obj.InterpolationFactor))+3*obj.NumSections+9*obj.GainCorrection;
                cornerflag=(obj.InterpolationFactor==2&&(obj.NumSections==4||obj.NumSections==5||obj.NumSections==6))...
                ||(obj.InterpolationFactor==3&&obj.NumSections==6);
                cornerflag1=(obj.InterpolationFactor==2&&obj.NumSections==6);
                if obj.InterpolationFactor==1
                    if inputlen==1
                        latency=2+obj.NumSections+9*obj.GainCorrection;
                    elseif inputlen==2
                        latency=commonlatency-((obj.NumSections>1)+(obj.NumSections>4));
                    else
                        latency=commonlatency-(obj.NumSections>(inputlen-1));
                    end
                elseif obj.InterpolationFactor>obj.NumSections
                    latency=commonlatency+(inputlen==1);
                else
                    if inputlen==1&&cornerflag
                        latency=commonlatency-(1+floor(obj.NumSections/(3*obj.InterpolationFactor)));
                    elseif(inputlen==2&&cornerflag)||(inputlen==3&&cornerflag1)
                        latency=commonlatency-1;
                    else
                        latency=commonlatency;
                    end
                end
            elseif obj.NumCycles<obj.InterpolationFactor&&strcmpi(obj.InterpolationSource,'Property')
                latency=3+obj.NumSections+((obj.InterpolationFactor+1)*obj.NumSections+2)+1+...
                (obj.NumSections-1)*(obj.NumCycles)+9*obj.GainCorrection;
            else
                if(~strcmpi(obj.InterpolationSource,'Property'))
                    latency=3-3*(obj.MaxInterpolationFactor==1)+obj.NumSections+9*obj.GainCorrection+...
                    2*obj.MaxInterpolationFactor;
                elseif obj.NumCycles>obj.InterpolationFactor&&obj.InterpolationFactor==1
                    latency=2+obj.NumSections+9*obj.GainCorrection;
                else
                    latency=3+obj.NumSections+9*obj.GainCorrection;
                end
            end
        end
    end

    methods(Static,Hidden)
        function fixpt_dataTypes=setStageMaxLength(obj,N,M,R,dataInWordlength,input_fr)

            L=(N*2)+1;
            fixpt_dataTypes=cell(1,L);
            for i=0:1:2*N-1
                if i<N
                    G=2^(i+1);
                else
                    G=2^(2*N-1-i)*(R*M)^(1+i-N)/R;
                end
                if M==1&&i==N-1
                    fixpt_dataTypes{N}=fi(0,1,dataInWordlength+(N-1),input_fr,hdlfimath);
                else
                    fixpt_dataTypes{i+1}=fi(0,1,ceil(dataInWordlength+log2(G)),input_fr,hdlfimath);
                end
            end
            if~strcmp(obj.OutputDataType,'Minimum section word lengths')
                fixpt_dataTypes{(N*2)+1}=fi(0,1,ceil(dataInWordlength+log2(G)),input_fr,hdlfimath);
            else
                fractOut=input_fr-(ceil(dataInWordlength+log2(G))-obj.OutputWordLength);
                fixpt_dataTypes{(N*2)+1}=fi(0,1,obj.OutputWordLength,fractOut,hdlfimath);
            end
        end

        function[gainShift,shiftlength,gDT]=gainCalculationsfixdt(N,M,R,VariableUpsample,pruned)
            Gmax=floor(log2(((R*M)^N)/R));
            if VariableUpsample
                gainShift=cell(1,R);
                for i=1:R
                    G=((i*M)^N)/i;
                    shiftlength=floor(log2(G));
                    tmp=Gmax-shiftlength;
                    gainShift{i}=cast(tmp,'uint8');
                end
            else
                G=((R*M)^N)/R;
                shiftlength=floor(log2(G));
                tmp=Gmax-shiftlength;
                gainShift=cast(tmp,'uint8');
            end
            gDT=numerictype(1,pruned{(N*2)+1}.WordLength,pruned{(N*2)+1}.FractionLength+Gmax);
        end

        function fineGain=fineGainCalculationsfixdt(N,M,R,VariableUpsample)
            if VariableUpsample
                fineGain=cell(1,R);
                for i=1:R
                    G=((i*M)^N)/i;
                    fineG=G*2^-(floor(log2(G)));
                    fineGain{i}=fi(1/fineG,1,23,21);
                end
            else
                G=((R*M)^N)/R;
                fineG=G*2^-(floor(log2(G)));
                fineGain=fi(1/fineG,1,23,21);
            end
        end
    end

    methods(Access=protected)
        function validatePropertiesImpl(obj)
            if(strcmpi(obj.InterpolationSource,'Property'))&&(obj.InterpolationFactor>64)&&(obj.NumCycles==1)
                coder.internal.error('dsphdl:CICInterpolator:InvalidDataConfig');
            end
            if~((obj.NumCycles>=obj.InterpolationFactor)||(obj.NumCycles==1)...
                ||(mod(obj.InterpolationFactor,obj.NumCycles)==0))
                coder.internal.error('dsphdl:CICInterpolator:InvalidNumCyclesValue');
            end
        end

        function validateInputsImpl(obj,varargin)
            if isempty(coder.target)||~eml_ambiguous_types
                if~(strcmpi(obj.InterpolationSource,'Property'))
                    validateattributes(varargin{1},{'embedded.fi','int8',...
                    'int16','int32'},{},'CICInterpolator','data');
                    if~isscalar(varargin{1})
                        coder.internal.error('dsphdl:CICInterpolator:DataInVectorErr');
                    end
                else
                    validateattributes(varargin{1},{'embedded.fi','int8',...
                    'int16','int32'},{},'CICInterpolator','data');
                    if(~isvector(varargin{1}))||(~(iscolumn(varargin{1})))
                        coder.internal.error('dsphdl:CICInterpolator:InvalidVectorSize');
                    end
                    if~((obj.NumCycles>=obj.InterpolationFactor)||(obj.NumCycles==1)...
                        ||(mod(obj.InterpolationFactor,obj.NumCycles)==0))
                        coder.internal.error('dsphdl:CICInterpolator:InvalidNumCyclesValue');
                    end
                    if(obj.InterpolationFactor*size(varargin{1},1))>64&&(obj.NumCycles==1)
                        coder.internal.error('dsphdl:CICInterpolator:InvalidDataConfig');
                    end
                    if(~isscalar(varargin{1})&&~(obj.NumCycles==1))
                        coder.internal.error('dsphdl:CICInterpolator:InvalidNumCyclesConfig');
                    end
                end

                [inpWL,~,S]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                errCond=(inpWL>32||S==0);
                if(errCond)
                    coder.internal.error('dsphdl:CICInterpolator:InvalidDataTypeDataIn');
                end
                validateattributes(varargin{2},{'logical'},...
                {'scalar'},'CICInterpolator','valid');
                if(~strcmpi(obj.InterpolationSource,'Property'))
                    if~isscalar(varargin{3})||isstruct(varargin{3})
                        coder.internal.error('dsphdl:CICInterpolator:interpFactorVectorErr');
                    end
                    [inpWL,inpFL,S]=dsphdlshared.hdlgetwordsizefromdata(varargin{3});
                    if(~((inpWL==12)&&(inpFL==0)&&(S==0)))
                        coder.internal.error('dsphdl:CICInterpolator:InvalidDataType');
                    end
                end
                if(obj.ResetInputPort)
                    if(~strcmpi(obj.InterpolationSource,'Property'))
                        validateattributes(varargin{4},{'logical'},...
                        {'scalar'},'CICInterpolator','reset');
                    else
                        validateattributes(varargin{3},{'logical'},...
                        {'scalar'},'CICInterpolator','reset');
                    end
                end
                obj.inDisp=~isempty(varargin{1});
                obj.vectorSize=length(varargin{1});
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~strcmpi(obj.OutputDataType,'Minimum section word lengths')
                props=[props,{'OutputWordLength'}];
            end
            if strcmpi(obj.InterpolationSource,'Property')
                props=[props,{'MaxInterpolationFactor'}];
            end
            if strcmpi(obj.InterpolationSource,'Input port')
                props=[props,{'InterpolationFactor','NumCycles'}];
            end
            flag=ismember(prop,props);
        end

        function varargout=getOutputDataTypeImpl(obj)
            N=obj.NumSections;
            dt1=propagatedInputDataType(obj,1);
            if(~isempty(dt1))
                if ischar(dt1)
                    inputDT=eval([dt1,'(0)']);
                else
                    inputDT=fi(0,dt1);
                end
                if~isfloat(inputDT)
                    [stageDT,~,~,g,~,udO]=determineDataTypes(obj,inputDT);
                    if strcmp(obj.OutputDataType,'Full precision')
                        if obj.GainCorrection
                            dataTypes=fi(0,g);
                        else
                            dataTypes=stageDT{(N*2)+1};
                        end
                    else
                        dataTypes=udO;
                    end
                    if isfi(dataTypes)
                        varargout{1}=dataTypes.numerictype();
                    else
                        varargout{1}=class(dataTypes);
                    end
                else
                    varargout{1}=propagatedInputDataType(obj,1);
                end
            else
                varargout{1}=[];
            end
            varargout{2}='logical';
            varargout{3}='logical';
        end

        function varargout=isOutputFixedSizeImpl(~)
            varargout{1}=true;
            varargout{2}=true;
            varargout{3}=true;
        end

        function varargout=getOutputSizeImpl(obj)
            size=propagatedInputSize(obj,1);
            if~strcmpi(obj.InterpolationSource,'Property')||((obj.NumCycles>=obj.InterpolationFactor)&&strcmpi(obj.InterpolationSource,'Property')&&obj.NumCycles~=1)
                varargout{1}=[1,1];
            else
                varargout{1}=[(obj.InterpolationFactor*size(1))/obj.NumCycles,1];
            end
            varargout{2}=1;
            varargout{3}=1;
        end

        function varargout=isOutputComplexImpl(obj,varargin)
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
            varargout{3}=false;
        end

        function num=getNumInputsImpl(obj)
            num=2+~strcmpi(obj.InterpolationSource,'Property')+obj.ResetInputPort;
        end

        function num=getNumOutputsImpl(~)
            num=2;
            num=num+1;
        end

        function varargout=getOutputNamesImpl(~)
            varargout{1}='data';
            varargout{2}='valid';
            varargout{3}='ready';
        end

        function varargout=getInputNamesImpl(obj)
            varargout{1}='data';
            varargout{2}='valid';
            if~strcmpi(obj.InterpolationSource,'Property')
                varargout{3}='R';
            end
            if obj.ResetInputPort
                if~strcmpi(obj.InterpolationSource,'Property')
                    varargout{4}='reset';
                else
                    varargout{3}='reset';
                end
            end
        end

        function icon=getIconImpl(obj)
            if~strcmpi(obj.InterpolationSource,'Property')
                interpstr='';
            else
                interpstr=sprintf('x[n/%i]\n',obj.InterpolationFactor);
            end
            if isempty(obj.inDisp)||isempty(obj.vectorSize)
                icon=sprintf('%sCIC Interpolator\nLatency = --',interpstr);
            else
                icon=sprintf('%sCIC Interpolator\nLatency = %d',interpstr,...
                getLatency(obj,obj.vectorSize));
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataIntReg=obj.dataIntReg;
                s.dataUsReg=obj.dataUsReg;
                s.validUsReg=obj.validUsReg;
                s.dataComReg=obj.dataComReg;
                s.dataComRegReg=obj.dataComRegReg;
                s.validComReg=obj.validComReg;
                s.cValidbuf=obj.cValidbuf;
                s.subtmp=obj.subtmp;
                s.count=obj.count;
                s.changeinR=obj.changeinR;
                s.gainOuta=obj.gainOuta;
                s.gainOuta1=obj.gainOuta1;
                s.gainShift=obj.gainShift;
                s.gainOut=obj.gainOut;
                s.gainValid=obj.gainValid;
                s.gDT=obj.gDT;
                s.fineMult=obj.fineMult;
                s.userDefinedOut=obj.userDefinedOut;
                s.inDisp=obj.inDisp;
                s.gainDatareg=obj.gainDatareg;
                s.fgainDatareg=obj.fgainDatareg;
                s.validOuti1=obj.validOuti1;
                s.validOuti2=obj.validOuti2;
                s.validOuti3=obj.validOuti3;
                s.validOuti4=obj.validOuti4;
                s.validOuti5=obj.validOuti5;
                s.validOuti6=obj.validOuti6;
                s.validOuti7=obj.validOuti7;
                s.validOuti8=obj.validOuti8;
                s.validOuti9=obj.validOuti9;
                s.gainValidTmp=obj.gainValidTmp;
                s.gainOutTmp=obj.gainOutTmp;
                s.dataInireg=obj.dataInireg;
                s.validInreg=obj.validInreg;
                s.resetreg=obj.resetreg;
                s.gainOutareg1=obj.gainOutareg1;
                s.gainOutareg2=obj.gainOutareg2;
                s.gainOutareg3=obj.gainOutareg3;
                s.gainOutareg4=obj.gainOutareg4;
                s.gainOutareg5=obj.gainOutareg5;
                s.gainOutatmp=obj.gainOutatmp;
                s.gainOutatmp1=obj.gainOutatmp1;
                s.gainOutatmp2=obj.gainOutatmp2;
                s.shiftlength=obj.shiftlength;
                s.previnterpFactor=obj.previnterpFactor;
                s.upsampleMax=obj.upsampleMax;
                s.usMaxreg=obj.usMaxreg;
                s.readyReg=obj.readyReg;
                s.state1=obj.state1;
                s.count1=obj.count1;
                s.int1wl=obj.int1wl;
                s.int2wl=obj.int2wl;
                s.int3wl=obj.int3wl;
                s.int4wl=obj.int4wl;
                s.int5wl=obj.int5wl;
                s.int6wl=obj.int6wl;
                s.int1fl=obj.int1fl;
                s.int2fl=obj.int2fl;
                s.int3fl=obj.int3fl;
                s.int4fl=obj.int4fl;
                s.int5fl=obj.int5fl;
                s.int6fl=obj.int6fl;
                s.dswl=obj.dswl;
                s.dsfl=obj.dsfl;
                s.countVect=obj.countVect;
                s.stateInt=obj.stateInt;
                s.dataOutIntN1=obj.dataOutIntN1;
                s.dataOutIntN2=obj.dataOutIntN2;
                s.dataOutIntN3=obj.dataOutIntN3;
                s.dataOutIntN4=obj.dataOutIntN4;
                s.dataOutIntN5=obj.dataOutIntN5;
                s.dataOutIntN6=obj.dataOutIntN6;
                s.addOutRegN1=obj.addOutRegN1;
                s.addOutRegN2=obj.addOutRegN2;
                s.addOutRegN3=obj.addOutRegN3;
                s.addOutRegN4=obj.addOutRegN4;
                s.addOutRegN5=obj.addOutRegN5;
                s.addOutRegN6=obj.addOutRegN6;
                s.part1RegN1=obj.part1RegN1;
                s.part1RegN2=obj.part1RegN2;
                s.part1RegN3=obj.part1RegN3;
                s.part1RegN4=obj.part1RegN4;
                s.part1RegN5=obj.part1RegN5;
                s.part1RegN6=obj.part1RegN6;
                s.residue=obj.residue;
                s.countds=obj.countds;
                s.delayBalance1RV=obj.delayBalance1RV;
                s.delayBalance1IV=obj.delayBalance1IV;
                s.delayBalance2V=obj.delayBalance2V;
                s.delayBalanceNRV=obj.delayBalanceNRV;
                s.delayBalanceNIV=obj.delayBalanceNIV;
                s.delayBalanceNV=obj.delayBalanceNV;
                s.com1wl=obj.com1wl;
                s.com1fl=obj.com1fl;
                s.com2wl=obj.com2wl;
                s.com2fl=obj.com2fl;
                s.com3wl=obj.com3wl;
                s.com3fl=obj.com3fl;
                s.com4wl=obj.com4wl;
                s.com4fl=obj.com4fl;
                s.com5wl=obj.com5wl;
                s.com5fl=obj.com5fl;
                s.com6wl=obj.com6wl;
                s.com6fl=obj.com6fl;
                s.invecsize=obj.invecsize;
                s.outvecsize=obj.outvecsize;
                s.residuevect=obj.residuevect;
                s.intoffvect=obj.intoffvect;
                s.dataOutcreg6=obj.dataOutcreg6;
                s.dataOutcreg5=obj.dataOutcreg5;
                s.dataOutcreg4=obj.dataOutcreg4;
                s.dataOutcreg3=obj.dataOutcreg3;
                s.dataOutcreg2=obj.dataOutcreg2;
                s.dataOutcreg1=obj.dataOutcreg1;
                s.validOutcreg6=obj.validOutcreg6;
                s.validOutcreg5=obj.validOutcreg5;
                s.validOutcreg4=obj.validOutcreg4;
                s.validOutcreg3=obj.validOutcreg3;
                s.validOutcreg2=obj.validOutcreg2;
                s.validOutcreg1=obj.validOutcreg1;
                s.dataOutiprev=obj.dataOutiprev;
                s.buffstate=obj.buffstate;
                s.buffreg=obj.buffreg;
                s.buffcount=obj.buffcount;
                s.stagevecsize=obj.stagevecsize;
                s.outvecsize1=obj.outvecsize1;
                s.pInitialize=obj.pInitialize;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for i=1:numel(fn)
                obj.(fn{i})=s.(fn{i});
            end
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

    end
end