classdef(StrictDefaults)CICDecimator<matlab.System














































































































%#codegen




    properties(Nontunable)



        DecimationSource='Property';




        DecimationFactor=2;




        MaxDecimationFactor=2;




        DifferentialDelay=1;




        NumSections=2;





        OutputWordLength=16;













        OutputDataType='Full precision';





        GainCorrection(1,1)logical=false;




        ResetInputPort(1,1)logical=false;




        HDLGlobalReset(1,1)logical=false;
    end

    properties(Constant,Hidden)
        DecimationSourceSet=matlab.system.StringSet({...
        'Property','Input port'});
        OutputDataTypeSet=matlab.system.StringSet({...
        'Full precision','Same word length as input','Minimum section word lengths'});
    end

    properties(Nontunable,Access=private)
        shiftLength=0;
        vecSize=2;
        int1WL=16;
        int1FL=8;
        int2WL=16;
        int2FL=8;
        int3WL=16;
        int3FL=8;
        int4WL=16;
        int4FL=8;
        int5WL=16;
        int5FL=8;
        int6WL=16;
        int6FL=8;
        dsWL=16;
        dsFL=8;
        com1WL=16;
        com1FL=8;
        com2WL=16;
        com2FL=8;
        com3WL=16;
        com3FL=8;
        com4WL=16;
        com4FL=8;
        com5WL=16;
        com5FL=8;
        com6WL=16;
        com6FL=8;
        intOff=0;
        vectorcountds=0;
        numOfCombInp;
        index;
        residueNT;
        index1;
        index2;
    end

    properties(Access=private)

        dataIntReg;


        dataDsReg;
        validDsReg;
        count;
        downsampleMax;
        dsMaxreg;
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
        vectorSize;


        gainDatareg;
        fgainDatareg;
        gainOutareg1;
        gainOutareg2;
        gainOutareg3;
        gainOutareg4;
        gainOutareg5;
        validOutc1;
        validOutc2;
        validOutc3;
        validOutc4;
        validOutc5;
        validOutc6;
        validOutc7;
        validOutc8;
        validOutc9;
        gainValidTmp;
        gainOutTmp;
        dataInireg;
        validInreg;
        resetreg;
        gainOutatmp;
        gainOutatmp1;
        gainOutatmp2;
        prevdecimFactor;
        countVect;
        stateInt;
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
        delayBalance1R;
        delayBalance1I;
        delayBalance2;
        delayBalance1RV;
        delayBalance1IV;
        delayBalance2V;
        state;
        blkLatency;
        countVec;
        validInreg1;
        dataOuttmp1;
        dataOuttmp2;
        dataOutDS;
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
    end




    methods

        function obj=CICDecimator(varargin)
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

        function set.DecimationFactor(obj,value)
            if strcmpi(obj.DecimationSource,'Property')%#ok
                validateattributes(value,{'double'},{'positive','integer',...
                'scalar','<=',2048,'>=',1},'CICDecimator','DecimationFactor');
            end
            obj.DecimationFactor=value;
        end

        function set.MaxDecimationFactor(obj,value)
            if~strcmpi(obj.DecimationSource,'Property')%#ok
                validateattributes(value,{'double'},{'positive','integer',...
                'scalar','<=',2048,'>=',1},'CICDecimator','MaxDecimationFactor');
            end
            obj.MaxDecimationFactor=value;
        end

        function set.DifferentialDelay(obj,value)
            validateattributes(value,{'double'},{'positive','integer',...
            'scalar'},'CICDecimator','DifferentialDelay');
            if(~((value==1)||(value==2)))
                coder.internal.error('dsphdl:CICDecimator:InvalidDiffData');
            end
            obj.DifferentialDelay=value;
        end

        function set.NumSections(obj,value)
            validateattributes(value,{'double'},{'positive','integer',...
            'scalar','<=',6},'CICDecimator','NumSections');
            obj.NumSections=value;
        end

        function set.OutputWordLength(obj,value)
            if strcmpi(obj.DecimationSource,'Property')&&strcmp(obj.OutputDataType,'Minimum section word lengths')%#ok
                validateattributes(value,{'double'},{'positive','integer',...
                'scalar','<=',104,'>=',2},'CICDecimator','OutputWordLength');
            end
            obj.OutputWordLength=value;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            text=sprintf(['Decimate signal using cascaded integrator-comb (CIC) filter.\n\n',...
            'The CIC decimation implementation is optimized for HDL code generation.\n']);
            header=matlab.system.display.Header(...
            'Title','CIC Decimator ',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl
            algorithmParameters=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'DecimationSource','DecimationFactor',...
            'MaxDecimationFactor','DifferentialDelay','NumSections','GainCorrection'});

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


            if strcmpi(obj.DecimationSource,'Property')
                R=obj.DecimationFactor;
            else
                R=obj.MaxDecimationFactor;
            end
            obj.numOfCombInp=length(varargin{1})/R;
            [stageDT,obj.gainShift,obj.shiftLength,obj.gDT,obj.fineMult,obj.userDefinedOut]...
            =determineDataTypes(obj,varargin{1});


            initializeVariables(obj,stageDT,varargin{1});

            obj.intOff=fi(floor((obj.vecSize-1)*obj.NumSections/obj.vecSize),0,4,0,hdlfimath);
            obj.residue=fi((obj.vecSize-1)*obj.NumSections-double(obj.intOff)*obj.vecSize,0,7,0,hdlfimath);
            obj.residueNT=double(fi((obj.vecSize-1)*obj.NumSections-double(obj.intOff)*obj.vecSize,0,7,0,hdlfimath));
            obj.countVect=fi(0,0,4,0,hdlfimath);
            obj.stateInt=false;
            obj.countds=fi(0,0,11,0,hdlfimath);
            obj.vectorcountds=fi((R/obj.vecSize)-1,0,11,0,hdlfimath);
            obj.delayBalance1R=dsp.Delay((obj.vecSize+1)*obj.NumSections+2);
            obj.delayBalance1I=dsp.Delay((obj.vecSize+1)*obj.NumSections+2);
            obj.delayBalance2=dsp.Delay((obj.vecSize+1)*obj.NumSections+2);
            obj.delayBalance1RV=dsp.Delay('Length',((obj.vecSize+1)*obj.NumSections+2)*(obj.numOfCombInp));
            obj.delayBalance1IV=dsp.Delay('Length',((obj.vecSize+1)*obj.NumSections+2)*(obj.numOfCombInp));
            obj.delayBalance2V=dsp.Delay((obj.vecSize+1)*obj.NumSections+2);
            obj.state=false;
            obj.blkLatency=fi(floor((obj.vecSize-1)*(obj.NumSections/obj.vecSize))+1+obj.NumSections+9*obj.GainCorrection+(2+(obj.vecSize+1)*obj.NumSections),0,9,0,hdlfimath);
            obj.countVec=fi(0,0,9,0,hdlfimath);
            tmp=((obj.residueNT+1):obj.DecimationFactor:(obj.residueNT+obj.DecimationFactor*obj.numOfCombInp));
            obj.index=coder.const(tmp);
            selectFlag=coder.const(any(obj.index>obj.vecSize));
            if selectFlag
                obj.index1=coder.const(obj.index(obj.index<=obj.vecSize));
                obj.index2=coder.const(obj.index(obj.index>obj.vecSize)-obj.vecSize);
            else
                obj.index1=coder.const(obj.index);
            end
        end

        function[dataOut,validOut]=outputImpl(obj,varargin)
            if obj.vecSize>obj.DecimationFactor
                if obj.resetreg
                    dataOut=cast(zeros(obj.numOfCombInp,1),'like',obj.gainOut);
                    validOut=false;
                elseif(obj.gainValid)
                    dataOut=obj.gainOut;
                    validOut=obj.gainValid;
                else
                    dataOut=cast(zeros(obj.numOfCombInp,1),'like',obj.gainOut);
                    validOut=false;
                end
            else
                if obj.resetreg
                    dataOut=cast(0,'like',obj.gainOut);
                    validOut=false;
                elseif(obj.gainValid)
                    dataOut=obj.gainOut;
                    validOut=obj.gainValid;
                else
                    dataOut=cast(0,'like',obj.gainOut);
                    validOut=false;
                end
            end
        end

        function updateImpl(obj,varargin)

            dataIn=varargin{1};
            validIn=varargin{2};
            if~strcmpi(obj.DecimationSource,'Property')
                downsampleIn=varargin{3};
            end
            if obj.ResetInputPort
                if~strcmpi(obj.DecimationSource,'Property')
                    reset=varargin{4};
                else
                    reset=varargin{3};
                end
            else
                reset=false;
            end


            if(~strcmpi(obj.DecimationSource,'Property'))
                if obj.changeinR
                    resetImpl(obj);
                end
                obj.downsampleMax=obj.dsMaxreg;
                downsampleIn=fi(downsampleIn,0,12,0);

                if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                    if varargin{3}<1&&validIn
                        if(obj.prevdecimFactor~=varargin{3})
                            coder.internal.warning('dsphdl:CICDecimator:decimFactorLessThanMinValue',double(varargin{3}));
                        end
                        obj.prevdecimFactor=varargin{3};
                        downsampleIn=fi(1,0,12,0);
                    elseif varargin{3}>obj.MaxDecimationFactor&&validIn
                        if(obj.prevdecimFactor~=varargin{3})
                            coder.internal.warning('dsphdl:CICDecimator:decimFactorGreaterThanMaxValue',double(varargin{3}),double(obj.MaxDecimationFactor));
                        end
                        obj.prevdecimFactor=varargin{3};
                        downsampleIn=fi(obj.MaxDecimationFactor,0,12,0);
                    end
                end
                obj.changeinR=(downsampleIn~=obj.downsampleMax)&&validIn;
                if obj.changeinR
                    obj.dsMaxreg=variableDownsample(obj,downsampleIn);
                end
            else
                obj.downsampleMax(:)=obj.DecimationFactor;
            end

            if(~strcmpi(obj.DecimationSource,'Property'))

                [dataOuti,~]=integratorSection(obj,obj.dataInireg,obj.validInreg,obj.resetreg);


                [dataOutds,validOutds]=downSampleSection(obj,dataOuti,obj.validInreg,obj.resetreg);


                [dataOutc,validOutc]=combSection(obj,dataOutds,validOutds,obj.resetreg);


                [gainOuttmp,gainValidtmp]=gainCorrection(obj,dataOutc,validOutc,obj.resetreg);

            else

                [dataOuti,validOuti]=integratorSection(obj,dataIn,validIn,reset);


                [dataOutds,validOutds]=downSampleSection(obj,dataOuti,validOuti,reset);


                [dataOutc,validOutc]=combSection(obj,dataOutds,validOutds,reset);


                [gainOuttmp,gainValidtmp]=gainCorrection(obj,dataOutc,validOutc,reset);
            end

            if obj.vecSize==1
                obj.dataInireg=dataIn;
                obj.validInreg=validIn;
            end
            obj.resetreg=reset;

            if reset
                obj.state=true;
            elseif obj.countVec==obj.blkLatency-1
                obj.state=false;
            end

            if reset
                obj.countVec(:)=0;
            elseif obj.state
                obj.countVec(:)=obj.countVec(:)+1;
            end

            if isscalar(gainOuttmp)
                if obj.vecSize==1
                    obj.gainOut=obj.gainOutTmp;
                    obj.gainValid=obj.gainValidTmp;
                    obj.gainOutTmp=gainOuttmp;
                    obj.gainValidTmp=gainValidtmp;
                else
                    if isreal(gainOuttmp)
                        gtmp=obj.delayBalance1R(real(gainOuttmp));
                        if~obj.state
                            obj.gainOut(:)=gtmp;
                        else
                            obj.gainOut(:)=cast(0,'like',obj.gainOutTmp);
                        end
                    else
                        gtmp=complex(obj.delayBalance1R(real(gainOuttmp)),...
                        obj.delayBalance1I(imag(gainOuttmp)));
                        if~obj.state
                            obj.gainOut(:)=gtmp;
                        else
                            obj.gainOut(:)=complex(cast(0,'like',obj.gainOutTmp));
                        end
                    end
                    gval=obj.delayBalance2(gainValidtmp);
                    if~obj.state
                        obj.gainValid(:)=gval;
                    else
                        obj.gainValid(:)=false;
                    end
                end
            else
                if isreal(gainOuttmp)
                    gtmp=obj.delayBalance1RV(real(gainOuttmp(:)));
                    if~obj.state
                        obj.gainOut(:)=gtmp;
                    else
                        obj.gainOut(:)=cast(0,'like',obj.gainOutTmp);
                    end
                else
                    gtmp=complex(obj.delayBalance1RV(real(gainOuttmp(:))),...
                    obj.delayBalance1IV(imag(gainOuttmp(:))));
                    if~obj.state
                        obj.gainOut(:)=gtmp;
                    else
                        obj.gainOut(:)=complex(cast(0,'like',obj.gainOutTmp));
                    end
                end
                gval=obj.delayBalance2V(gainValidtmp);
                if~obj.state
                    obj.gainValid(:)=gval;
                else
                    obj.gainValid(:)=false;
                end
            end
        end

        function Downsamplecount=variableDownsample(obj,downsampleIn)
            maxDecim=fi(obj.MaxDecimationFactor,0,12,0);
            if downsampleIn<=maxDecim
                if downsampleIn<1
                    Downsamplecount=fi(1,0,12,0);
                else
                    Downsamplecount=downsampleIn;
                end
            else
                Downsamplecount=maxDecim;
            end
        end

        function[dataOuti,validOuti]=integratorSection(obj,dataIni,validIn,reset)
            if isscalar(dataIni)
                N=obj.NumSections;
                dataOuti=obj.dataIntReg{N}(:);
                validOuti=validIn;
                for i=N-1:-1:1
                    if(reset)
                        obj.dataIntReg{i+1}(:)=0;
                    elseif(validIn)
                        obj.dataIntReg{i+1}(:)=obj.dataIntReg{i+1}(:)+obj.dataIntReg{i}(:);
                    end
                end

                if(reset)
                    obj.dataIntReg{1}(:)=0;
                else
                    if(validIn)
                        obj.dataIntReg{1}(:)=obj.dataIntReg{1}(:)+dataIni;
                    end
                end
            else
                [dataOuti]=intSectVect(obj,dataIni,validIn,reset);

                if reset
                    obj.stateInt=false;
                elseif obj.countVect==obj.intOff&&validIn
                    obj.stateInt=true;
                end
                validOuti=obj.stateInt&&validIn;
                if reset
                    obj.countVect(:)=fi(0,0,4,0,hdlfimath);
                elseif validIn
                    obj.countVect(:)=obj.countVect(:)+fi(1,0,4,0,hdlfimath);
                end

            end
        end

        function[dataOuti]=intSectVect(obj,dataIni,validIn,reset)
            switch obj.NumSections
            case 1
                [dataOut]=cicIntSectN1(obj,dataIni,validIn,reset);
            case 2
                [dataOut1]=cicIntSectN1(obj,dataIni,validIn,reset);
                [dataOut]=cicIntSectN2(obj,dataOut1,validIn,reset);
            case 3
                [dataOut1]=cicIntSectN1(obj,dataIni,validIn,reset);
                [dataOut2]=cicIntSectN2(obj,dataOut1,validIn,reset);
                [dataOut]=cicIntSectN3(obj,dataOut2,validIn,reset);
            case 4
                [dataOut1]=cicIntSectN1(obj,dataIni,validIn,reset);
                [dataOut2]=cicIntSectN2(obj,dataOut1,validIn,reset);
                [dataOut3]=cicIntSectN3(obj,dataOut2,validIn,reset);
                [dataOut]=cicIntSectN4(obj,dataOut3,validIn,reset);
            case 5
                [dataOut1]=cicIntSectN1(obj,dataIni,validIn,reset);
                [dataOut2]=cicIntSectN2(obj,dataOut1,validIn,reset);
                [dataOut3]=cicIntSectN3(obj,dataOut2,validIn,reset);
                [dataOut4]=cicIntSectN4(obj,dataOut3,validIn,reset);
                [dataOut]=cicIntSectN5(obj,dataOut4,validIn,reset);
            case 6
                [dataOut1]=cicIntSectN1(obj,dataIni,validIn,reset);
                [dataOut2]=cicIntSectN2(obj,dataOut1,validIn,reset);
                [dataOut3]=cicIntSectN3(obj,dataOut2,validIn,reset);
                [dataOut4]=cicIntSectN4(obj,dataOut3,validIn,reset);
                [dataOut5]=cicIntSectN5(obj,dataOut4,validIn,reset);
                [dataOut]=cicIntSectN6(obj,dataOut5,validIn,reset);
            end
            dataOuti=dataOut;
        end

        function[idataOut]=cicIntSectN1(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN1(:);
            for i=1:length(idataIn)
                if reset
                    obj.addOutRegN1=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int1WL,obj.int1FL,hdlfimath);
                elseif ivalidIn
                    obj.addOutRegN1(i,1)=obj.addOutRegN1(i,1)+idataIn(i);
                end
            end
            if reset
                obj.addOutRegN1=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int1WL,obj.int1FL,hdlfimath);
                obj.part1RegN1=fi(zeros(obj.vecSize,1),1,obj.int1WL,obj.int1FL,hdlfimath);
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
                    obj.dataOutIntN1=fi(zeros(obj.vecSize,1),1,obj.int1WL,obj.int1FL,hdlfimath);
                else
                    obj.dataOutIntN1(i)=obj.addOutRegN1(i,part);
                end
            end

        end

        function[idataOut]=cicIntSectN2(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN2(:);
            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN2=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int2WL,obj.int2FL,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN2(i,1)=obj.addOutRegN2(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN2=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int2WL,obj.int2FL,hdlfimath);
                obj.part1RegN2=fi(zeros(obj.vecSize,1),1,obj.int2WL,obj.int2FL,hdlfimath);
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
                    obj.dataOutIntN2=fi(zeros(obj.vecSize,1),1,obj.int2WL,obj.int2FL,hdlfimath);
                else
                    obj.dataOutIntN2(i)=obj.addOutRegN2(i,part);
                end
            end
        end

        function[idataOut]=cicIntSectN3(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN3(:);

            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN3=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int3WL,obj.int3FL,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN3(i,1)=obj.addOutRegN3(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN3=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int3WL,obj.int3FL,hdlfimath);
                obj.part1RegN3=fi(zeros(obj.vecSize,1),1,obj.int3WL,obj.int3FL,hdlfimath);
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
                    obj.dataOutIntN3=fi(zeros(obj.vecSize,1),1,obj.int3WL,obj.int3FL,hdlfimath);
                else
                    obj.dataOutIntN3(i)=obj.addOutRegN3(i,part);
                end
            end
        end

        function[idataOut]=cicIntSectN4(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN4(:);
            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN4=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int4WL,obj.int4FL,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN4(i,1)=obj.addOutRegN4(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN4=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int4WL,obj.int4FL,hdlfimath);
                obj.part1RegN4=fi(zeros(obj.vecSize,1),1,obj.int4WL,obj.int4FL,hdlfimath);
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
                    obj.dataOutIntN4=fi(zeros(obj.vecSize,1),1,obj.int4WL,obj.int4FL,hdlfimath);
                else
                    obj.dataOutIntN4(i)=obj.addOutRegN4(i,part);
                end
            end
        end

        function[idataOut]=cicIntSectN5(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN5(:);
            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN5=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int5WL,obj.int5FL,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN5(i,1)=obj.addOutRegN5(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN5=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int5WL,obj.int5FL,hdlfimath);
                obj.part1RegN5=fi(zeros(obj.vecSize,1),1,obj.int5WL,obj.int5FL,hdlfimath);
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
                    obj.dataOutIntN5=fi(zeros(obj.vecSize,1),1,obj.int5WL,obj.int5FL,hdlfimath);
                else
                    obj.dataOutIntN5(i)=obj.addOutRegN5(i,part);
                end
            end
        end

        function[idataOut]=cicIntSectN6(obj,idataIn,ivalidIn,reset)
            idataOut=obj.dataOutIntN6(:);
            for i=1:length(idataIn)
                if(reset)
                    obj.addOutRegN6=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int6WL,obj.int6FL,hdlfimath);
                elseif(ivalidIn)
                    obj.addOutRegN6(i,1)=obj.addOutRegN6(i,1)+idataIn(i);
                end
            end

            if(reset)
                obj.addOutRegN6=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int6WL,obj.int6FL,hdlfimath);
                obj.part1RegN6=fi(zeros(obj.vecSize,1),1,obj.int6WL,obj.int6FL,hdlfimath);
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
                    obj.dataOutIntN6=fi(zeros(obj.vecSize,1),1,obj.int6WL,obj.int6FL,hdlfimath);
                else
                    obj.dataOutIntN6(i)=obj.addOutRegN6(i,part);
                end
            end
        end

        function[dataOutds,validOutds]=downSampleSection(obj,dataOuti,validOuti,reset)
            if isscalar(dataOuti)
                if obj.DecimationFactor==1||obj.MaxDecimationFactor==1
                    if reset
                        dataOutds=cast(0,'like',dataOuti);
                        validOutds=false;
                    else
                        dataOutds=dataOuti;
                        validOutds=validOuti;
                    end
                else
                    dataOutds=obj.dataDsReg(:);
                    validOutds=obj.validDsReg;
                    if(reset)
                        obj.dataDsReg(:)=0;
                        obj.validDsReg=false;
                    else
                        if(validOuti)&&(obj.count(:)==0)
                            obj.dataDsReg(:)=dataOuti;
                            obj.validDsReg=true;
                        else
                            obj.dataDsReg(:)=obj.dataDsReg(:);
                            obj.validDsReg=false;
                        end
                    end

                    if(reset)
                        obj.count(:)=0;
                    else
                        if validOuti
                            if(obj.count<(obj.downsampleMax-fi(1,0,1,0)))
                                obj.count(:)=obj.count+fi(1,0,1,0);
                            else
                                obj.count(:)=0;
                            end
                        end
                    end
                end

            elseif obj.DecimationFactor>=obj.vecSize
                if reset
                    validOutds=false;
                    dataOutds=cast(0,'like',dataOuti);
                else
                    dataOutds=dataOuti(obj.residue+1);
                    validOutds=obj.countds(:)==0&&validOuti;
                end

                if reset||(obj.countds(:)==obj.vectorcountds&&validOuti)
                    obj.countds(:)=0;
                elseif validOuti
                    obj.countds(:)=obj.countds(:)+1;
                end
            else
                if reset
                    validOutds=false;
                    dataOutds=cast(zeros(obj.numOfCombInp,1),'like',dataOuti);
                else
                    dataOutds=[obj.dataOuttmp1(obj.index1)
                    dataOuti(obj.index2)];

                    validOutds=obj.validInreg1&validOuti;
                end

                if reset
                    obj.dataOuttmp1(:)=fi(zeros(obj.vecSize,1),1,obj.dsWL,obj.dsFL,hdlfimath);
                    obj.validInreg1=false;
                elseif validOuti
                    obj.dataOuttmp1(:)=dataOuti;
                    obj.validInreg1=validOuti;
                end
            end
        end

        function[dataOutc,validOutc]=combSection(obj,dataOutds,validOutds,reset)
            if isscalar(dataOutds)
                N=obj.NumSections;
                validOutc=obj.cValidbuf(N);


                validComb=[validOutds,obj.cValidbuf(1:end-1)];
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
                        obj.subtmp{1}(:)=-obj.dataComReg{1}(:)+dataOutds;
                    end

                else

                    if(reset)
                        obj.subtmp{1}(:)=0;
                    else
                        obj.subtmp{1}(:)=-obj.dataComRegReg{1}(:)+dataOutds;
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
                        obj.dataComReg{1}(:)=dataOutds;
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
                        obj.dataOutcreg6(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg6);
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
                        obj.dataOutcreg5(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg5);
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
                        obj.dataOutcreg4(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg4);
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
                        obj.dataOutcreg3(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg3);
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
                        obj.dataOutcreg2(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg2);
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
                        obj.dataOutcreg1(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg1);
                    else
                        obj.dataOutcreg1(:)=dataOutds(:)-[obj.dataOutComreg1;
                        dataOutds(1:end-1)];
                    end
                    if reset
                        obj.dataOutComreg1(:)=cast(0,'like',obj.dataOutComreg1);
                    elseif validOutds
                        obj.dataOutComreg1(:)=dataOutds(end);
                    end
                    if reset
                        obj.validOutcreg1=false;
                    else
                        obj.validOutcreg1=validOutds;
                    end

                else
                    if reset
                        obj.dataOutcreg6(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg6);
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
                        obj.dataOutcreg5(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg5);
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
                        obj.dataOutcreg4(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg4);
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
                        obj.dataOutcreg3(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg3);
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
                        obj.dataOutcreg2(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg2);
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
                        obj.dataOutcreg1(:)=cast(zeros(obj.numOfCombInp,1),'like',obj.dataOutcreg1);
                    else
                        obj.dataOutcreg1(:)=dataOutds(:)-[obj.dataOutCom1reg1;obj.dataOutComreg1;
                        dataOutds(1:end-2)];
                    end
                    if reset
                        obj.dataOutComreg1(:)=cast(0,'like',obj.dataOutComreg1);
                        obj.dataOutCom1reg1(:)=cast(0,'like',obj.dataOutCom1reg1);
                    elseif validOutds
                        obj.dataOutComreg1(:)=dataOutds(end);
                        obj.dataOutCom1reg1(:)=dataOutds(end-1);
                    end
                    if reset
                        obj.validOutcreg1=false;
                    else
                        obj.validOutcreg1=validOutds;
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

        function[stageDT,gainShift,shiftLength,gDT,fineMult,userDefinedOut]=determineDataTypes(obj,varargin)
            coder.extrinsic('dsphdl.CICDecimator.pruningCalculation');
            N=obj.NumSections;
            M=obj.DifferentialDelay;
            if strcmpi(obj.DecimationSource,'Property')
                R=obj.DecimationFactor;
            else
                R=obj.MaxDecimationFactor;
            end
            [dataInWordlength,dataInFractionlength]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
            maxGrowth=dataInWordlength+ceil(N*log2(R*M));
            if strcmpi(obj.DecimationSource,'Property')
                if strcmp(obj.OutputDataType,'Minimum section word lengths')
                    [wordLengths,fractionLengths]=coder.const(@dsphdl.CICDecimator.pruningCalculation,obj.NumSections,obj.DifferentialDelay,obj.DecimationFactor,...
                    dataInWordlength,dataInFractionlength,obj.OutputWordLength);
                    stageDT=coder.const(obj.setStageWordLengths(obj,N,wordLengths,fractionLengths,maxGrowth,...
                    dataInFractionlength));
                else
                    stageDT=coder.const(obj.setStageMaxLength(N,maxGrowth,...
                    dataInFractionlength));
                end
            else
                stageDT=coder.const(obj.setStageMaxLength(N,maxGrowth,...
                dataInFractionlength));
            end
            switch obj.OutputDataType
            case 'Full precision'
                userDefinedOut=fi(0,1,maxGrowth,hdlfimath);
            case 'Same word length as input'
                if~obj.GainCorrection
                    userDefinedOut=fi(0,1,dataInWordlength,...
                    dataInFractionlength-(maxGrowth-dataInWordlength));
                else
                    userDefinedOut=fi(0,1,dataInWordlength,dataInFractionlength);
                end
            case 'Minimum section word lengths'
                userDefinedOut=fi(0,1,obj.OutputWordLength,hdlfimath);
                if(obj.OutputWordLength<7)
                    coder.internal.warning('dsphdl:CICDecimator:InvalidDataTypeOutWL');
                end
            end
            [gainShift,shiftLength,gDT]=coder.const(@obj.gainCalculationsfixdt,N,M,R,~strcmpi(obj.DecimationSource,'Property'),stageDT);
            fineMult=coder.const(obj.fineGainCalculationsfixdt(N,M,R,~strcmpi(obj.DecimationSource,'Property')));
        end

        function initializeVariables(obj,pruned,varargin)



            N=obj.NumSections;
            if strcmpi(obj.DecimationSource,'Property')
                R=obj.DecimationFactor;
            else
                R=obj.MaxDecimationFactor;
            end
            obj.dataIntReg=cell(1,7);
            obj.dataComReg=cell(1,7);
            obj.dataComRegReg=cell(1,7);
            obj.subtmp=cell(1,7);
            obj.validDsReg=false(1,1);
            obj.validComReg=false(1,N);
            obj.cValidbuf=false(1,N);
            obj.validOutc1=false;
            obj.validOutc2=false;
            obj.validOutc3=false;
            obj.validOutc4=false;
            obj.validOutc5=false;
            obj.validOutc6=false;
            obj.validOutc7=false;
            obj.validOutc8=false;
            obj.validOutc9=false;

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
            obj.dataInireg=cast(0,'like',(varargin{1}));
            pruned={pruned{:},pruned{:},pruned{:}};

            obj.vecSize=length(varargin{1});
            obj.int1WL=pruned{1}.WordLength;
            obj.int1FL=pruned{1}.FractionLength;
            obj.int2WL=pruned{2}.WordLength;
            obj.int2FL=pruned{2}.FractionLength;
            obj.int3WL=pruned{3}.WordLength;
            obj.int3FL=pruned{3}.FractionLength;
            obj.int4WL=pruned{4}.WordLength;
            obj.int4FL=pruned{4}.FractionLength;
            obj.int5WL=pruned{5}.WordLength;
            obj.int5FL=pruned{5}.FractionLength;
            obj.int6WL=pruned{6}.WordLength;
            obj.int6FL=pruned{6}.FractionLength;

            obj.dsWL=pruned{N}.WordLength;
            obj.dsFL=pruned{N}.FractionLength;

            obj.com1WL=pruned{N+1}.WordLength;
            obj.com1FL=pruned{N+1}.FractionLength;
            obj.com2WL=pruned{N+2}.WordLength;
            obj.com2FL=pruned{N+2}.FractionLength;
            obj.com3WL=pruned{N+3}.WordLength;
            obj.com3FL=pruned{N+3}.FractionLength;
            obj.com4WL=pruned{N+4}.WordLength;
            obj.com4FL=pruned{N+4}.FractionLength;
            obj.com5WL=pruned{N+5}.WordLength;
            obj.com5FL=pruned{N+5}.FractionLength;
            obj.com6WL=pruned{N+6}.WordLength;
            obj.com6FL=pruned{N+6}.FractionLength;

            if obj.vecSize<=obj.DecimationFactor
                val=0;
            else
                val=zeros(obj.numOfCombInp,1);
            end


            if isreal(varargin{1})

                obj.dataIntReg{1}=cast(0,'like',(pruned{1}));
                obj.dataIntReg{2}=cast(0,'like',(pruned{2}));
                obj.dataIntReg{3}=cast(0,'like',(pruned{3}));
                obj.dataIntReg{4}=cast(0,'like',(pruned{4}));
                obj.dataIntReg{5}=cast(0,'like',(pruned{5}));
                obj.dataIntReg{6}=cast(0,'like',(pruned{6}));
                obj.dataIntReg{7}=cast(0,'like',(pruned{6}));

                obj.dataDsReg=cast(0,'like',(pruned{N+1}));

                obj.dataComReg{1}=cast(0,'like',(pruned{N+1}));
                obj.dataComReg{2}=cast(0,'like',(pruned{N+2}));
                obj.dataComReg{3}=cast(0,'like',(pruned{N+3}));
                obj.dataComReg{4}=cast(0,'like',(pruned{N+4}));
                obj.dataComReg{5}=cast(0,'like',(pruned{N+5}));
                obj.dataComReg{6}=cast(0,'like',(pruned{N+6}));
                obj.dataComReg{7}=cast(0,'like',(pruned{N+6}));

                obj.dataComRegReg{1}=cast(0,'like',(pruned{N+1}));
                obj.dataComRegReg{2}=cast(0,'like',(pruned{N+2}));
                obj.dataComRegReg{3}=cast(0,'like',(pruned{N+3}));
                obj.dataComRegReg{4}=cast(0,'like',(pruned{N+4}));
                obj.dataComRegReg{5}=cast(0,'like',(pruned{N+5}));
                obj.dataComRegReg{6}=cast(0,'like',(pruned{N+6}));
                obj.dataComRegReg{7}=cast(0,'like',(pruned{N+6}));

                obj.subtmp{1}=cast(0,'like',(pruned{N+1}));
                obj.subtmp{2}=cast(0,'like',(pruned{N+2}));
                obj.subtmp{3}=cast(0,'like',(pruned{N+3}));
                obj.subtmp{4}=cast(0,'like',(pruned{N+4}));
                obj.subtmp{5}=cast(0,'like',(pruned{N+5}));
                obj.subtmp{6}=cast(0,'like',(pruned{N+6}));
                obj.subtmp{7}=cast(0,'like',(pruned{N+6}));

                obj.gainOuta1=fi(0,1,pruned{(N*2)+1}.WordLength,pruned{(N*2)+1}.FractionLength);

                if obj.GainCorrection
                    obj.gainOuta=fi(val,obj.gDT);
                    obj.gainOutatmp=fi(val,obj.gDT);
                    obj.gainOutatmp1=fi(val,obj.gDT);
                    obj.gainOutatmp2=fi(val,obj.gDT);
                    obj.gainOutareg1=fi(val,obj.gDT);
                    obj.gainOutareg2=fi(val,obj.gDT);
                    obj.gainOutareg3=fi(val,obj.gDT);
                    obj.gainOutareg4=fi(val,obj.gDT);
                    obj.gainOutareg5=fi(val,obj.gDT);
                else
                    obj.gainOuta=cast(val,'like',pruned{(N*2)+1});
                    obj.gainOutatmp=cast(val,'like',pruned{(N*2)+1});
                    obj.gainOutatmp1=cast(val,'like',pruned{(N*2)+1});
                    obj.gainOutatmp2=cast(val,'like',pruned{(N*2)+1});
                    obj.gainOutareg1=cast(val,'like',pruned{(N*2)+1});
                    obj.gainOutareg2=cast(val,'like',pruned{(N*2)+1});
                    obj.gainOutareg3=cast(val,'like',pruned{(N*2)+1});
                    obj.gainOutareg4=cast(val,'like',pruned{(N*2)+1});
                    obj.gainOutareg5=cast(val,'like',pruned{(N*2)+1});
                end

                if obj.vecSize<=obj.DecimationFactor
                    obj.gainDatareg=fi([0,0],obj.gDT);
                else
                    obj.gainDatareg=fi(zeros(obj.numOfCombInp,2),obj.gDT);
                end
                if strcmp(obj.OutputDataType,'Same word length as input')
                    obj.gainOut=cast(val,'like',obj.userDefinedOut);
                    obj.gainOutTmp=cast(val,'like',obj.userDefinedOut);
                else
                    obj.gainOut=cast(val,'like',obj.gainOuta);
                    obj.gainOutTmp=cast(val,'like',obj.gainOuta);
                end
                obj.fgainDatareg=fi([0,0],1,23,21);
                obj.dataOutIntN1=fi(zeros(obj.vecSize,1),1,obj.int1WL,obj.int1FL,hdlfimath);
                obj.dataOutIntN2=fi(zeros(obj.vecSize,1),1,obj.int2WL,obj.int2FL,hdlfimath);
                obj.dataOutIntN3=fi(zeros(obj.vecSize,1),1,obj.int3WL,obj.int3FL,hdlfimath);
                obj.dataOutIntN4=fi(zeros(obj.vecSize,1),1,obj.int4WL,obj.int4FL,hdlfimath);
                obj.dataOutIntN5=fi(zeros(obj.vecSize,1),1,obj.int5WL,obj.int5FL,hdlfimath);
                obj.dataOutIntN6=fi(zeros(obj.vecSize,1),1,obj.int6WL,obj.int6FL,hdlfimath);
                obj.addOutRegN1=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int1WL,obj.int1FL,hdlfimath);
                obj.addOutRegN2=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int2WL,obj.int2FL,hdlfimath);
                obj.addOutRegN3=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int3WL,obj.int3FL,hdlfimath);
                obj.addOutRegN4=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int4WL,obj.int4FL,hdlfimath);
                obj.addOutRegN5=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int5WL,obj.int5FL,hdlfimath);
                obj.addOutRegN6=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int6WL,obj.int6FL,hdlfimath);
                obj.part1RegN1=fi(zeros(obj.vecSize,1),1,obj.int1WL,obj.int1FL,hdlfimath);
                obj.part1RegN2=fi(zeros(obj.vecSize,1),1,obj.int2WL,obj.int2FL,hdlfimath);
                obj.part1RegN3=fi(zeros(obj.vecSize,1),1,obj.int3WL,obj.int3FL,hdlfimath);
                obj.part1RegN4=fi(zeros(obj.vecSize,1),1,obj.int4WL,obj.int4FL,hdlfimath);
                obj.part1RegN5=fi(zeros(obj.vecSize,1),1,obj.int5WL,obj.int5FL,hdlfimath);
                obj.part1RegN6=fi(zeros(obj.vecSize,1),1,obj.int6WL,obj.int6FL,hdlfimath);
                obj.dataOuttmp1=fi(zeros(obj.vecSize,1),1,obj.dsWL,obj.dsFL,hdlfimath);
                obj.dataOuttmp2=fi(zeros(obj.vecSize,1),1,obj.dsWL,obj.dsFL,hdlfimath);
                if obj.vecSize>obj.DecimationFactor
                    obj.dataOutDS=fi(val,1,obj.dsWL,obj.dsFL,hdlfimath);
                    obj.dataOutComreg1=fi(0,1,obj.dsWL,obj.dsFL,hdlfimath);
                    obj.dataOutComreg2=fi(0,1,obj.com1WL,obj.com1FL,hdlfimath);
                    obj.dataOutComreg3=fi(0,1,obj.com2WL,obj.com2FL,hdlfimath);
                    obj.dataOutComreg4=fi(0,1,obj.com3WL,obj.com3FL,hdlfimath);
                    obj.dataOutComreg5=fi(0,1,obj.com4WL,obj.com4FL,hdlfimath);
                    obj.dataOutComreg6=fi(0,1,obj.com5WL,obj.com5FL,hdlfimath);
                    obj.dataOutCom1reg1=fi(0,1,obj.dsWL,obj.dsFL,hdlfimath);
                    obj.dataOutCom2reg2=fi(0,1,obj.com1WL,obj.com1FL,hdlfimath);
                    obj.dataOutCom3reg3=fi(0,1,obj.com2WL,obj.com2FL,hdlfimath);
                    obj.dataOutCom4reg4=fi(0,1,obj.com3WL,obj.com3FL,hdlfimath);
                    obj.dataOutCom5reg5=fi(0,1,obj.com4WL,obj.com4FL,hdlfimath);
                    obj.dataOutCom6reg6=fi(0,1,obj.com5WL,obj.com5FL,hdlfimath);
                    obj.dataOutcreg1=fi(val,1,obj.com1WL,obj.com1FL,hdlfimath);
                    obj.dataOutcreg2=fi(val,1,obj.com2WL,obj.com2FL,hdlfimath);
                    obj.dataOutcreg3=fi(val,1,obj.com3WL,obj.com3FL,hdlfimath);
                    obj.dataOutcreg4=fi(val,1,obj.com4WL,obj.com4FL,hdlfimath);
                    obj.dataOutcreg5=fi(val,1,obj.com5WL,obj.com5FL,hdlfimath);
                    obj.dataOutcreg6=fi(val,1,obj.com6WL,obj.com6FL,hdlfimath);
                end
            else
                obj.dataIntReg{1}=complex(cast(0,'like',(pruned{1})));
                obj.dataIntReg{2}=complex(cast(0,'like',(pruned{2})));
                obj.dataIntReg{3}=complex(cast(0,'like',(pruned{3})));
                obj.dataIntReg{4}=complex(cast(0,'like',(pruned{4})));
                obj.dataIntReg{5}=complex(cast(0,'like',(pruned{5})));
                obj.dataIntReg{6}=complex(cast(0,'like',(pruned{6})));
                obj.dataIntReg{7}=complex(cast(0,'like',(pruned{6})));

                obj.dataDsReg=complex(cast(0,'like',(pruned{N})));

                obj.dataComReg{1}=complex(cast(0,'like',(pruned{N+1})));
                obj.dataComReg{2}=complex(cast(0,'like',(pruned{N+2})));
                obj.dataComReg{3}=complex(cast(0,'like',(pruned{N+3})));
                obj.dataComReg{4}=complex(cast(0,'like',(pruned{N+4})));
                obj.dataComReg{5}=complex(cast(0,'like',(pruned{N+5})));
                obj.dataComReg{6}=complex(cast(0,'like',(pruned{N+6})));
                obj.dataComReg{7}=complex(cast(0,'like',(pruned{N+6})));

                obj.dataComRegReg{1}=complex(cast(0,'like',(pruned{N+1})));
                obj.dataComRegReg{2}=complex(cast(0,'like',(pruned{N+2})));
                obj.dataComRegReg{3}=complex(cast(0,'like',(pruned{N+3})));
                obj.dataComRegReg{4}=complex(cast(0,'like',(pruned{N+4})));
                obj.dataComRegReg{5}=complex(cast(0,'like',(pruned{N+5})));
                obj.dataComRegReg{6}=complex(cast(0,'like',(pruned{N+6})));
                obj.dataComRegReg{7}=complex(cast(0,'like',(pruned{N+6})));

                obj.subtmp{1}=complex(cast(0,'like',(pruned{N+1})));
                obj.subtmp{2}=complex(cast(0,'like',(pruned{N+2})));
                obj.subtmp{3}=complex(cast(0,'like',(pruned{N+3})));
                obj.subtmp{4}=complex(cast(0,'like',(pruned{N+4})));
                obj.subtmp{5}=complex(cast(0,'like',(pruned{N+5})));
                obj.subtmp{6}=complex(cast(0,'like',(pruned{N+6})));
                obj.subtmp{7}=complex(cast(0,'like',(pruned{N+6})));

                obj.gainOuta1=complex(fi(0,1,pruned{(N*2)+1}.WordLength,pruned{(N*2)+1}.FractionLength));

                if obj.GainCorrection
                    obj.gainOuta=complex(fi(val,obj.gDT));
                    obj.gainOutatmp=complex(fi(val,obj.gDT));
                    obj.gainOutatmp1=complex(fi(val,obj.gDT));
                    obj.gainOutatmp2=complex(fi(val,obj.gDT));
                    obj.gainOutareg1=complex(fi(val,obj.gDT));
                    obj.gainOutareg2=complex(fi(val,obj.gDT));
                    obj.gainOutareg3=complex(fi(val,obj.gDT));
                    obj.gainOutareg4=complex(fi(val,obj.gDT));
                    obj.gainOutareg5=complex(fi(val,obj.gDT));
                else
                    obj.gainOuta=complex(cast(val,'like',pruned{(N*2)+1}));
                    obj.gainOutatmp=complex(cast(val,'like',pruned{(N*2)+1}));
                    obj.gainOutatmp1=complex(cast(val,'like',pruned{(N*2)+1}));
                    obj.gainOutatmp2=complex(cast(val,'like',pruned{(N*2)+1}));
                    obj.gainOutareg1=complex(cast(val,'like',pruned{(N*2)+1}));
                    obj.gainOutareg2=complex(cast(val,'like',pruned{(N*2)+1}));
                    obj.gainOutareg3=complex(cast(val,'like',pruned{(N*2)+1}));
                    obj.gainOutareg4=complex(cast(val,'like',pruned{(N*2)+1}));
                    obj.gainOutareg5=complex(cast(val,'like',pruned{(N*2)+1}));
                end

                if obj.vecSize<=obj.DecimationFactor
                    obj.gainDatareg=complex(fi([0,0],obj.gDT));
                else
                    obj.gainDatareg=complex(fi(zeros(obj.numOfCombInp,2),obj.gDT));
                end

                obj.fgainDatareg=complex(fi([0,0],1,23,21));

                if strcmp(obj.OutputDataType,'Same word length as input')
                    obj.gainOut=cast(complex(val),'like',obj.userDefinedOut);
                    obj.gainOutTmp=cast(complex(val),'like',obj.userDefinedOut);
                else
                    obj.gainOut=cast(complex(val),'like',obj.gainOuta);
                    obj.gainOutTmp=cast(complex(val),'like',obj.gainOuta);
                end

                obj.dataOutIntN1=complex(fi(zeros(obj.vecSize,1),1,obj.int1WL,obj.int1FL,hdlfimath));
                obj.dataOutIntN2=complex(fi(zeros(obj.vecSize,1),1,obj.int2WL,obj.int2FL,hdlfimath));
                obj.dataOutIntN3=complex(fi(zeros(obj.vecSize,1),1,obj.int3WL,obj.int3FL,hdlfimath));
                obj.dataOutIntN4=complex(fi(zeros(obj.vecSize,1),1,obj.int4WL,obj.int4FL,hdlfimath));
                obj.dataOutIntN5=complex(fi(zeros(obj.vecSize,1),1,obj.int5WL,obj.int5FL,hdlfimath));
                obj.dataOutIntN6=complex(fi(zeros(obj.vecSize,1),1,obj.int6WL,obj.int6FL,hdlfimath));
                obj.addOutRegN1=complex(fi(zeros(obj.vecSize,obj.vecSize),1,obj.int1WL,obj.int1FL,hdlfimath));
                obj.addOutRegN2=complex(fi(zeros(obj.vecSize,obj.vecSize),1,obj.int2WL,obj.int2FL,hdlfimath));
                obj.addOutRegN3=complex(fi(zeros(obj.vecSize,obj.vecSize),1,obj.int3WL,obj.int3FL,hdlfimath));
                obj.addOutRegN4=complex(fi(zeros(obj.vecSize,obj.vecSize),1,obj.int4WL,obj.int4FL,hdlfimath));
                obj.addOutRegN5=complex(fi(zeros(obj.vecSize,obj.vecSize),1,obj.int5WL,obj.int5FL,hdlfimath));
                obj.addOutRegN6=complex(fi(zeros(obj.vecSize,obj.vecSize),1,obj.int6WL,obj.int6FL,hdlfimath));
                obj.part1RegN1=complex(fi(zeros(obj.vecSize,1),1,obj.int1WL,obj.int1FL,hdlfimath));
                obj.part1RegN2=complex(fi(zeros(obj.vecSize,1),1,obj.int2WL,obj.int2FL,hdlfimath));
                obj.part1RegN3=complex(fi(zeros(obj.vecSize,1),1,obj.int3WL,obj.int3FL,hdlfimath));
                obj.part1RegN4=complex(fi(zeros(obj.vecSize,1),1,obj.int4WL,obj.int4FL,hdlfimath));
                obj.part1RegN5=complex(fi(zeros(obj.vecSize,1),1,obj.int5WL,obj.int5FL,hdlfimath));
                obj.part1RegN6=complex(fi(zeros(obj.vecSize,1),1,obj.int6WL,obj.int6FL,hdlfimath));
                obj.dataOuttmp1=complex(fi(zeros(obj.vecSize,1),1,obj.dsWL,obj.dsFL,hdlfimath));
                obj.dataOuttmp2=complex(fi(zeros(obj.vecSize,1),1,obj.dsWL,obj.dsFL,hdlfimath));
                if obj.vecSize>obj.DecimationFactor
                    obj.dataOutDS=complex(fi(val,1,obj.dsWL,obj.dsFL,hdlfimath));
                    obj.dataOutComreg1=complex(fi(0,1,obj.dsWL,obj.dsFL,hdlfimath));
                    obj.dataOutComreg2=complex(fi(0,1,obj.com1WL,obj.com1FL,hdlfimath));
                    obj.dataOutComreg3=complex(fi(0,1,obj.com2WL,obj.com2FL,hdlfimath));
                    obj.dataOutComreg4=complex(fi(0,1,obj.com3WL,obj.com3FL,hdlfimath));
                    obj.dataOutComreg5=complex(fi(0,1,obj.com4WL,obj.com4FL,hdlfimath));
                    obj.dataOutComreg6=complex(fi(0,1,obj.com5WL,obj.com5FL,hdlfimath));
                    obj.dataOutCom1reg1=complex(fi(0,1,obj.dsWL,obj.dsFL,hdlfimath));
                    obj.dataOutCom2reg2=complex(fi(0,1,obj.com1WL,obj.com1FL,hdlfimath));
                    obj.dataOutCom3reg3=complex(fi(0,1,obj.com2WL,obj.com2FL,hdlfimath));
                    obj.dataOutCom4reg4=complex(fi(0,1,obj.com3WL,obj.com3FL,hdlfimath));
                    obj.dataOutCom5reg5=complex(fi(0,1,obj.com4WL,obj.com4FL,hdlfimath));
                    obj.dataOutCom6reg6=complex(fi(0,1,obj.com5WL,obj.com5FL,hdlfimath));
                    obj.dataOutcreg1=complex(fi(val,1,obj.com1WL,obj.com1FL,hdlfimath));
                    obj.dataOutcreg2=complex(fi(val,1,obj.com2WL,obj.com2FL,hdlfimath));
                    obj.dataOutcreg3=complex(fi(val,1,obj.com3WL,obj.com3FL,hdlfimath));
                    obj.dataOutcreg4=complex(fi(val,1,obj.com4WL,obj.com4FL,hdlfimath));
                    obj.dataOutcreg5=complex(fi(val,1,obj.com5WL,obj.com5FL,hdlfimath));
                    obj.dataOutcreg6=complex(fi(val,1,obj.com6WL,obj.com6FL,hdlfimath));
                end
            end
            obj.gainValid=false;
            obj.count=fi(0,0,ceil(log2(R+1))+1,0,hdlfimath);
            obj.downsampleMax=fi(1,0,12,0);
            obj.dsMaxreg=fi(1,0,12,0);
            obj.prevdecimFactor=fi(1,0,12,0);
        end

        function[gainout,validout]=gainCorrection(obj,dataOutc,validOutc,reset)
            if isscalar(dataOutc)
                if obj.GainCorrection
                    if strcmpi(obj.DecimationSource,'Property')
                        if obj.gDT.WordLength+obj.shiftLength>=128
                            bShiftWL=128;
                        else
                            bShiftWL=obj.gDT.WordLength+obj.shiftLength;
                        end

                        bShift=cast(dataOutc,'like',obj.gainOuta1);
                        bRightShift=bitshift(fi(bShift,1,bShiftWL,...
                        obj.gDT.FractionLength),-obj.shiftLength);
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
                        obj.gainOuta=obj.gainOutareg1;
                        obj.gainOutareg1=obj.gainOutareg2;
                        obj.gainOutareg2=obj.gainOutareg3;
                        obj.gainOutareg3=obj.gainOutareg4;
                        obj.gainOutareg4=obj.gainOutareg5;
                        if(fineG==fi(1,1,23,21))
                            obj.gainOutareg5=cast(coarseGtmp,'like',coarseG);
                        else
                            obj.gainOutareg5=cast(coarseGtmp*fineG,'like',coarseG);
                        end
                    else
                        x=obj.gainShift{obj.downsampleMax};
                        bShift=cast(bitsll(dataOutc,x),'like',obj.gainOuta1);
                        coarseG=reinterpretcast(bShift,obj.gDT);
                        fineGtmp=fi(obj.fineMult{obj.downsampleMax},1,23,21);
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
                        obj.gainOuta=obj.gainOutareg1;
                        obj.gainOutareg1=obj.gainOutareg2;
                        obj.gainOutareg2=obj.gainOutareg3;
                        obj.gainOutareg3=obj.gainOutareg4;
                        obj.gainOutareg4=obj.gainOutareg5;
                        obj.gainOutareg5=cast(coarseGtmp*fineG,'like',coarseG);
                    end
                else
                    obj.gainOuta=cast(dataOutc,'like',obj.gainOuta);
                end

            else
                if obj.GainCorrection
                    if obj.gDT.WordLength+obj.shiftLength>=128
                        bShiftWL=128;
                    else
                        bShiftWL=obj.gDT.WordLength+obj.shiftLength;
                    end

                    bShift=cast(dataOutc,'like',obj.gainOuta1);
                    bRightShift=bitshift(fi(bShift,1,bShiftWL,...
                    obj.gDT.FractionLength),-obj.shiftLength);
                    coarseG=fi(bRightShift,1,obj.gDT.WordLength,obj.gDT.FractionLength,...
                    'RoundingMethod','Nearest','OverflowAction','Saturate');
                    fineGtmp=fi(obj.fineMult,1,23,21);
                    if reset
                        coarseGtmp=obj.gainDatareg(:,2);
                        obj.gainDatareg(:,2)=fi(zeros(obj.numOfCombInp,1),obj.gDT);
                        obj.gainDatareg(:,1)=fi(zeros(obj.numOfCombInp,1),obj.gDT);

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
                    obj.gainOuta=obj.gainOutareg1;
                    obj.gainOutareg1=obj.gainOutareg2;
                    obj.gainOutareg2=obj.gainOutareg3;
                    obj.gainOutareg3=obj.gainOutareg4;
                    obj.gainOutareg4=obj.gainOutareg5;
                    if(fineG==fi(1,1,23,21))
                        obj.gainOutareg5=cast(coarseGtmp,'like',coarseG);
                    else
                        obj.gainOutareg5=cast(coarseGtmp*fineG,'like',coarseG);
                    end

                else
                    obj.gainOuta(:)=cast(dataOutc,'like',obj.gainOuta);
                end

            end
            if obj.GainCorrection
                obj.gainOutatmp(:)=obj.gainOutatmp1;
                obj.gainOutatmp1(:)=obj.gainOutatmp2;
                obj.gainOutatmp2(:)=obj.gainOuta;
            else
                obj.gainOutatmp(:)=obj.gainOuta;
            end

            if strcmp(obj.OutputDataType,'Same word length as input')
                gainout=cast(obj.gainOutatmp,'like',obj.userDefinedOut);
            else
                gainout=obj.gainOutatmp;
            end

            if reset
                validout=false;
                obj.validOutc9=false;
                obj.validOutc8=false;
                obj.validOutc7=false;
                obj.validOutc6=false;
                obj.validOutc5=false;
                obj.validOutc4=false;
                obj.validOutc3=false;
                obj.validOutc2=false;
                obj.validOutc1=false;
            else
                if obj.GainCorrection
                    validout=obj.validOutc9;
                    obj.validOutc9=obj.validOutc8;
                    obj.validOutc8=obj.validOutc7;
                    obj.validOutc7=obj.validOutc6;
                    obj.validOutc6=obj.validOutc5;
                    obj.validOutc5=obj.validOutc4;
                    obj.validOutc4=obj.validOutc3;
                    obj.validOutc3=obj.validOutc2;
                    obj.validOutc2=obj.validOutc1;
                    obj.validOutc1=validOutc;
                else
                    validout=validOutc;
                end
            end
        end

        function resetImpl(obj)
            N=obj.NumSections;
            obj.count(:)=0;
            obj.validDsReg=false(1,1);
            obj.validComReg=false(1,N);
            for i=1:N+1
                obj.dataIntReg{i}(:)=0;
            end
            obj.dataDsReg(:)=0;
            for i=1:N+1
                obj.dataComReg{i}(:)=0;
                obj.dataComRegReg{i}(:)=0;
            end
            for i=1:N+1
                obj.subtmp{i}(:)=0;
            end
            obj.gainOuta(:)=0;
            obj.gainOuta1(:)=0;
            obj.fgainDatareg=fi([0,0],1,23,21);
            if obj.vecSize<=obj.DecimationFactor
                val=0;
                obj.gainDatareg=fi([0,0],obj.gDT);
            else
                val=zeros(obj.numOfCombInp,1);
                obj.gainDatareg=fi(zeros(obj.numOfCombInp,2),obj.gDT);
            end
            if strcmp(obj.OutputDataType,'Same word length as input')
                obj.gainOut=cast(val,'like',obj.userDefinedOut);
                obj.gainOutTmp=cast(val,'like',obj.userDefinedOut);
            else
                obj.gainOut=cast(val,'like',obj.gainOuta);
                obj.gainOutTmp=cast(val,'like',obj.gainOuta);
            end
            if obj.GainCorrection
                obj.gainOuta=fi(val,obj.gDT);
                obj.gainOutatmp=fi(val,obj.gDT);
                obj.gainOutatmp1=fi(val,obj.gDT);
                obj.gainOutatmp2=fi(val,obj.gDT);
                obj.gainOutareg1=fi(val,obj.gDT);
                obj.gainOutareg2=fi(val,obj.gDT);
                obj.gainOutareg3=fi(val,obj.gDT);
                obj.gainOutareg4=fi(val,obj.gDT);
                obj.gainOutareg5=fi(val,obj.gDT);
            else
                obj.gainOuta(:)=0;
                obj.gainOutatmp(:)=0;
                obj.gainOutatmp1(:)=0;
                obj.gainOutatmp2(:)=0;
                obj.gainOutareg1(:)=0;
                obj.gainOutareg2(:)=0;
                obj.gainOutareg3(:)=0;
                obj.gainOutareg4(:)=0;
                obj.gainOutareg5(:)=0;
            end

            obj.gainValidTmp=false;
            obj.gainValid=false;
            obj.cValidbuf=false(1,N);
            obj.validOutc1=false;
            obj.validOutc2=false;
            obj.validOutc3=false;
            obj.validOutc4=false;
            obj.validOutc5=false;
            obj.validOutc6=false;
            obj.validOutc7=false;
            obj.validOutc8=false;
            obj.validOutc9=false;
            obj.changeinR=false;
            obj.validInreg1=false;
            obj.dataOutIntN1=fi(zeros(obj.vecSize,1),1,obj.int1WL,obj.int1FL,hdlfimath);
            obj.dataOutIntN2=fi(zeros(obj.vecSize,1),1,obj.int2WL,obj.int2FL,hdlfimath);
            obj.dataOutIntN3=fi(zeros(obj.vecSize,1),1,obj.int3WL,obj.int3FL,hdlfimath);
            obj.dataOutIntN4=fi(zeros(obj.vecSize,1),1,obj.int4WL,obj.int4FL,hdlfimath);
            obj.dataOutIntN5=fi(zeros(obj.vecSize,1),1,obj.int5WL,obj.int5FL,hdlfimath);
            obj.dataOutIntN6=fi(zeros(obj.vecSize,1),1,obj.int6WL,obj.int6FL,hdlfimath);
            obj.addOutRegN1=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int1WL,obj.int1FL,hdlfimath);
            obj.addOutRegN2=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int2WL,obj.int2FL,hdlfimath);
            obj.addOutRegN3=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int3WL,obj.int3FL,hdlfimath);
            obj.addOutRegN4=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int4WL,obj.int4FL,hdlfimath);
            obj.addOutRegN5=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int5WL,obj.int5FL,hdlfimath);
            obj.addOutRegN6=fi(zeros(obj.vecSize,obj.vecSize),1,obj.int6WL,obj.int6FL,hdlfimath);
            obj.part1RegN1=fi(zeros(obj.vecSize,1),1,obj.int1WL,obj.int1FL,hdlfimath);
            obj.part1RegN2=fi(zeros(obj.vecSize,1),1,obj.int2WL,obj.int2FL,hdlfimath);
            obj.part1RegN3=fi(zeros(obj.vecSize,1),1,obj.int3WL,obj.int3FL,hdlfimath);
            obj.part1RegN4=fi(zeros(obj.vecSize,1),1,obj.int4WL,obj.int4FL,hdlfimath);
            obj.part1RegN5=fi(zeros(obj.vecSize,1),1,obj.int5WL,obj.int5FL,hdlfimath);
            obj.part1RegN6=fi(zeros(obj.vecSize,1),1,obj.int6WL,obj.int6FL,hdlfimath);
            obj.intOff=fi(floor((obj.vecSize-1)*obj.NumSections/obj.vecSize),0,4,0,hdlfimath);
            obj.residue=fi((obj.vecSize-1)*obj.NumSections-double(obj.intOff)*obj.vecSize,0,7,0,hdlfimath);
            obj.countVect=fi(0,0,4,0,hdlfimath);
            obj.stateInt=false;
            obj.countds=fi(0,0,11,0,hdlfimath);
            if strcmpi(obj.DecimationSource,'Property')
                R=obj.DecimationFactor;
            else
                R=obj.MaxDecimationFactor;
            end
            obj.vectorcountds=fi((R/obj.vecSize)-1,0,11,0,hdlfimath);
            reset(obj.delayBalance1R);
            reset(obj.delayBalance1I);
            reset(obj.delayBalance2);
            reset(obj.delayBalance1RV);
            reset(obj.delayBalance1IV);
            reset(obj.delayBalance2V);
            obj.state=false;
            obj.blkLatency=fi(floor((obj.vecSize-1)*(obj.NumSections/obj.vecSize))+1+obj.NumSections+9*obj.GainCorrection+(2+(obj.vecSize+1)*obj.NumSections),0,9,0,hdlfimath);
            obj.countVec=fi(0,0,9,0,hdlfimath);
            obj.validOutcreg1=false;
            obj.validOutcreg2=false;
            obj.validOutcreg3=false;
            obj.validOutcreg4=false;
            obj.validOutcreg5=false;
            obj.dataOuttmp1=fi(zeros(obj.vecSize,1),1,obj.dsWL,obj.dsFL,hdlfimath);
            obj.dataOuttmp2=fi(zeros(obj.vecSize,1),1,obj.dsWL,obj.dsFL,hdlfimath);
            if obj.vecSize>obj.DecimationFactor
                obj.dataOutDS=fi(val,1,obj.dsWL,obj.dsFL,hdlfimath);
                obj.dataOutComreg1=fi(0,1,obj.dsWL,obj.dsFL,hdlfimath);
                obj.dataOutComreg2=fi(0,1,obj.com1WL,obj.com1FL,hdlfimath);
                obj.dataOutComreg3=fi(0,1,obj.com2WL,obj.com2FL,hdlfimath);
                obj.dataOutComreg4=fi(0,1,obj.com3WL,obj.com3FL,hdlfimath);
                obj.dataOutComreg5=fi(0,1,obj.com4WL,obj.com4FL,hdlfimath);
                obj.dataOutComreg6=fi(0,1,obj.com5WL,obj.com5FL,hdlfimath);
                obj.dataOutCom1reg1=fi(0,1,obj.dsWL,obj.dsFL,hdlfimath);
                obj.dataOutCom2reg2=fi(0,1,obj.com1WL,obj.com1FL,hdlfimath);
                obj.dataOutCom3reg3=fi(0,1,obj.com2WL,obj.com2FL,hdlfimath);
                obj.dataOutCom4reg4=fi(0,1,obj.com3WL,obj.com3FL,hdlfimath);
                obj.dataOutCom5reg5=fi(0,1,obj.com4WL,obj.com4FL,hdlfimath);
                obj.dataOutCom6reg6=fi(0,1,obj.com5WL,obj.com5FL,hdlfimath);
                obj.dataOutcreg1=fi(val,1,obj.com1WL,obj.com1FL,hdlfimath);
                obj.dataOutcreg2=fi(val,1,obj.com2WL,obj.com2FL,hdlfimath);
                obj.dataOutcreg3=fi(val,1,obj.com3WL,obj.com3FL,hdlfimath);
                obj.dataOutcreg4=fi(val,1,obj.com4WL,obj.com4FL,hdlfimath);
                obj.dataOutcreg5=fi(val,1,obj.com5WL,obj.com5FL,hdlfimath);
                obj.dataOutcreg6=fi(val,1,obj.com6WL,obj.com6FL,hdlfimath);
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
                    len=1;
                else
                    len=(varargin{1});
                end
            else
                len=obj.vectorSize;
                if isempty(len)
                    len=1;
                end
            end
            if(~strcmpi(obj.DecimationSource,'Property'))
                latency=2+(obj.MaxDecimationFactor~=1)+~strcmpi(obj.DecimationSource,'Property')+obj.NumSections+9*obj.GainCorrection;
            else
                if len==1
                    latency=2+(obj.DecimationFactor~=1)+obj.NumSections+9*obj.GainCorrection;
                else
                    latency=floor((len-1)*(obj.NumSections/len))+1+obj.NumSections+9*obj.GainCorrection+(2+(len+1)*obj.NumSections);
                end
            end
        end
    end

    methods(Static,Hidden)
        function fixpt_dataTypes=setStageWordLengths(obj,N,wl,fl,Bmax,input_fr)
            L=(N*2);
            fixpt_dataTypes=cell(1,L+1);
            for i=1:L
                fixpt_dataTypes{i}=fi(0,1,wl{i},fl{i},hdlfimath);
            end
            fractOut=input_fr-(Bmax-obj.OutputWordLength);
            fixpt_dataTypes{(N*2)+1}=fi(0,1,obj.OutputWordLength,fractOut,hdlfimath);
        end

        function fixpt_dataTypes=setStageMaxLength(N,maxGrowth,input_fr)
            L=(N*2)+1;
            fixpt_dataTypes=cell(1,L);
            for i=1:L
                fixpt_dataTypes{i}=fi(0,1,maxGrowth,input_fr,hdlfimath);
            end
        end

        function[wordLengths,fractionLengths]=pruningCalculation(N,M,R,Bin,inFL,Bout)




            numSections=N;
            decimFactor=R;
            differentialDelay=M;
            inWL=Bin;
            outWL=Bout;

            if(N==6&&((R>=675&&M==1)||(R>=338&&M==2)))
                coder.internal.warning('dsphdl:CICDecimator:LargeCoefficient');
                warning('off','MATLAB:nchoosek:LargeCoefficient')
            end
            bgrowth=ceil(numSections*log2(decimFactor*differentialDelay));
            baccum=inWL+bgrowth;
            b2Np1=baccum-outWL;

            bj=dsphdl.CICDecimator.b2discard(b2Np1,numSections,decimFactor,differentialDelay);
            sectionWL=cell(1,2*numSections);
            sectionFL=cell(1,2*numSections);
            for i=1:2*numSections
                sectionWL{i}=baccum-bj(i);
                sectionFL{i}=floor(inFL-bj(i));
            end
            wordLengths=sectionWL;
            fractionLengths=sectionFL;
            warning('on','MATLAB:nchoosek:LargeCoefficient')
        end

        function bj=b2discard(b2Np1,numSections,decimFactor,differentialDelay)
            bj=zeros(1,2*numSections);
            E2Np1=2^b2Np1;
            sigmasq2Np1=E2Np1^2/12;
            for j=0:1:2*numSections-1
                Fsqj=dsphdl.CICDecimator.getSqSumImpulse(numSections,decimFactor,differentialDelay,j);
                bj(j+1)=floor(0.5*log2((sigmasq2Np1/Fsqj*6.0/numSections)));
                if bj(j+1)<0
                    bj(j+1)=0;
                end
            end
        end

        function Fsqj=getSqSumImpulse(N,R,D,j)
            if j<N
                Fsqj=0;
                lengthK=(R*D-1)*N+j;
                for idx=0:1:lengthK
                    upperLidx=floor(idx/(R*D));
                    if upperLidx==0
                        hi=nchoosek(N-j-1+idx,idx);
                    else
                        hi=0;
                        for l=0:1:upperLidx
                            hi=hi+(-1)^l*nchoosek(N,l)*...
                            nchoosek(N-j-1+idx-(R*D*l),idx-(R*D*l));
                        end
                    end
                    Fsqj=Fsqj+hi*hi;
                end
            else
                comb_idx=j+1;
                lengthK=2*N+1-comb_idx;
                Fsqj=0;
                for idx=0:1:lengthK
                    hc=(-1)^idx*nchoosek(2*N+1-comb_idx,idx);
                    Fsqj=Fsqj+hc*hc;
                end
            end
        end

        function[gainShift,shiftLength,gDT]=gainCalculationsfixdt(N,M,R,VariableDownsample,pruned)
            Gmax=floor(log2((R*M)^N));
            if VariableDownsample
                gainShift=cell(1,R);
                for i=1:R
                    G=(i*M)^N;
                    shiftLength=floor(log2(G));
                    tmp=Gmax-shiftLength;
                    gainShift{i}=cast(tmp,'uint8');
                end
            else
                G=(R*M)^N;
                shiftLength=floor(log2(G));
                tmp=Gmax-shiftLength;
                gainShift=cast(tmp,'uint8');
            end
            gDT=numerictype(1,pruned{(N*2)+1}.WordLength,pruned{(N*2)+1}.FractionLength+Gmax);
        end

        function fineGain=fineGainCalculationsfixdt(N,M,R,VariableDownsample)
            if VariableDownsample
                fineGain=cell(1,R);
                for i=1:R
                    G=(i*M)^N;
                    fineG=G*2^-(floor(log2(G)));
                    fineGain{i}=fi(1/fineG,1,23,21);
                end
            else
                G=(R*M)^N;
                fineG=G*2^-(floor(log2(G)));
                fineGain=fi(1/fineG,1,23,21);
            end
        end
    end

    methods(Access=protected)
        function validatePropertiesImpl(obj)
            if(~strcmpi(obj.DecimationSource,'Property')&&strcmpi(obj.OutputDataType,'Minimum section word lengths'))
                coder.internal.error('dsphdl:CICDecimator:InvalidDataTypeConfig');
            end
        end
        function validateInputsImpl(obj,varargin)
            if isempty(coder.target)||~eml_ambiguous_types
                if(~strcmpi(obj.DecimationSource,'Property'))
                    validateattributes(varargin{1},{'embedded.fi','int8',...
                    'int16','int32'},{},'CICDecimator','data');
                    if~isscalar(varargin{1})
                        coder.internal.error('dsphdl:CICDecimator:DataInVectorErr');
                    end
                else
                    validateattributes(varargin{1},{'embedded.fi','int8',...
                    'int16','int32'},{},'CICDecimator','data');
                    if(~isvector(varargin{1}))||(~(iscolumn(varargin{1})))
                        coder.internal.error('dsphdl:CICDecimator:InvalidVectorSize');
                    end
                    vecLen=size(varargin{1},1);
                    if vecLen>1
                        if vecLen>64||vecLen<1
                            coder.internal.error('dsphdl:CICDecimator:InvalidVectorSize');
                        elseif~isequal(mod(obj.DecimationFactor,vecLen),0)&&~isequal(mod(vecLen,obj.DecimationFactor),0)
                            coder.internal.error('dsphdl:CICDecimator:InvalidVectorSize');
                        end
                    end
                end

                [inpWL,~,S]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                errCond=(inpWL>32||S==0);
                if(errCond)
                    coder.internal.error('dsphdl:CICDecimator:InvalidDataTypeDataIn');
                end
                validateattributes(varargin{2},{'logical'},...
                {'scalar'},'CICDecimator','valid');
                if(~strcmpi(obj.DecimationSource,'Property'))
                    if~isscalar(varargin{3})||isstruct(varargin{3})
                        coder.internal.error('dsphdl:CICDecimator:decimFactorVectorErr');
                    end
                    [inpWL,inpFL,S]=dsphdlshared.hdlgetwordsizefromdata(varargin{3});
                    if(~((inpWL==12)&&(inpFL==0)&&(S==0)))
                        coder.internal.error('dsphdl:CICDecimator:InvalidDataType');
                    end
                end
                if(obj.ResetInputPort)
                    if(~strcmpi(obj.DecimationSource,'Property'))
                        validateattributes(varargin{4},{'logical'},...
                        {'scalar'},'CICDecimator','reset');
                    else
                        validateattributes(varargin{3},{'logical'},...
                        {'scalar'},'CICDecimator','reset');
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
            if strcmpi(obj.DecimationSource,'Property')
                props=[props,{'MaxDecimationFactor'}];
            end
            if strcmpi(obj.DecimationSource,'Input port')
                props=[props,{'DecimationFactor'}];
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
                    if obj.GainCorrection
                        dataTypes=fi(0,g);
                    else
                        dataTypes=stageDT{(N*2)+1};
                    end
                    if strcmp(obj.OutputDataType,'Same word length as input')
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
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function varargout=isOutputFixedSizeImpl(~)
            varargout{1}=true;
            varargout{2}=true;
        end

        function varargout=getOutputSizeImpl(obj)
            inSize=propagatedInputSize(obj,1);
            if inSize<=obj.DecimationFactor
                varargout{1}=[1,1];
            else
                varargout{1}=[ceil(inSize(1)/obj.DecimationFactor),1];
            end
            varargout{2}=1;
        end

        function varargout=isOutputComplexImpl(obj,varargin)
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
        end

        function num=getNumInputsImpl(obj)
            num=2+~strcmpi(obj.DecimationSource,'Property')+obj.ResetInputPort;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function varargout=getOutputNamesImpl(~)
            varargout{1}='data';
            varargout{2}='valid';
        end

        function varargout=getInputNamesImpl(obj)
            varargout{1}='data';
            varargout{2}='valid';
            if~strcmpi(obj.DecimationSource,'Property')
                varargout{3}='R';
            end
            if obj.ResetInputPort
                if~strcmpi(obj.DecimationSource,'Property')
                    varargout{4}='reset';
                else
                    varargout{3}='reset';
                end
            end
        end

        function icon=getIconImpl(obj)
            if~strcmpi(obj.DecimationSource,'Property')
                decimstr='';
            else
                decimstr=sprintf('x[%in]\n',obj.DecimationFactor);
            end
            if isempty(obj.inDisp)||isempty(obj.vectorSize)
                icon=sprintf('%sCIC Decimator\nLatency = --',decimstr);
            else
                icon=sprintf('%sCIC Decimator\nLatency = %d',decimstr,...
                getLatency(obj,obj.vectorSize));
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataIntReg=obj.dataIntReg;
                s.dataDsReg=obj.dataDsReg;
                s.validDsReg=obj.validDsReg;
                s.dataComReg=obj.dataComReg;
                s.dataComRegReg=obj.dataComRegReg;
                s.validComReg=obj.validComReg;
                s.cValidbuf=obj.cValidbuf;
                s.subtmp=obj.subtmp;
                s.count=obj.count;
                s.downsampleMax=obj.downsampleMax;
                s.dsMaxreg=obj.dsMaxreg;
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
                s.vectorSize=obj.vectorSize;
                s.gainDatareg=obj.gainDatareg;
                s.fgainDatareg=obj.fgainDatareg;
                s.validOutc1=obj.validOutc1;
                s.validOutc2=obj.validOutc2;
                s.validOutc3=obj.validOutc3;
                s.validOutc4=obj.validOutc4;
                s.validOutc5=obj.validOutc5;
                s.validOutc6=obj.validOutc6;
                s.validOutc7=obj.validOutc7;
                s.validOutc8=obj.validOutc8;
                s.validOutc9=obj.validOutc9;
                s.gainValidTmp=obj.gainValidTmp;
                s.gainOutTmp=obj.gainOutTmp;
                s.dataInireg=obj.dataInireg;
                s.validInreg=obj.validInreg;
                s.validInreg1=obj.validInreg1;
                s.resetreg=obj.resetreg;
                s.gainOutareg1=obj.gainOutareg1;
                s.gainOutareg2=obj.gainOutareg2;
                s.gainOutareg3=obj.gainOutareg3;
                s.gainOutareg4=obj.gainOutareg4;
                s.gainOutareg5=obj.gainOutareg5;
                s.gainOutatmp=obj.gainOutatmp;
                s.gainOutatmp1=obj.gainOutatmp1;
                s.gainOutatmp2=obj.gainOutatmp2;
                s.shiftLength=obj.shiftLength;
                s.prevdecimFactor=obj.prevdecimFactor;
                s.vecSize=obj.vecSize;
                s.int1WL=obj.int1WL;
                s.int2WL=obj.int2WL;
                s.int3WL=obj.int3WL;
                s.int4WL=obj.int4WL;
                s.int5WL=obj.int5WL;
                s.int6WL=obj.int6WL;
                s.int1FL=obj.int1FL;
                s.int2FL=obj.int2FL;
                s.int3FL=obj.int3FL;
                s.int4FL=obj.int4FL;
                s.int5FL=obj.int5FL;
                s.int6FL=obj.int6FL;
                s.dsWL=obj.dsWL;
                s.dsFL=obj.dsFL;
                s.intOff=obj.intOff;
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
                s.vectorcountds=obj.vectorcountds;
                s.delayBalance1R=obj.delayBalance1R;
                s.delayBalance1I=obj.delayBalance1I;
                s.delayBalance2=obj.delayBalance2;
                s.delayBalance1RV=obj.delayBalance1RV;
                s.delayBalance1IV=obj.delayBalance1IV;
                s.delayBalance2V=obj.delayBalance2V;
                s.state=obj.state;
                s.blkLatency=obj.blkLatency;
                s.countVec=obj.countVec;
                s.com1WL=obj.com1WL;
                s.com1FL=obj.com1FL;
                s.com2WL=obj.com2WL;
                s.com2FL=obj.com2FL;
                s.com3WL=obj.com3WL;
                s.com3FL=obj.com3FL;
                s.com4WL=obj.com4WL;
                s.com4FL=obj.com4FL;
                s.com5WL=obj.com5WL;
                s.com5FL=obj.com5FL;
                s.com6WL=obj.com6WL;
                s.com6FL=obj.com6FL;
                s.numOfCombInp=obj.numOfCombInp;
                s.index=obj.index;
                s.residueNT=obj.residueNT;
                s.index1=obj.index1;
                s.index2=obj.index2;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for i=1:numel(fn)
                obj.(fn{i})=s.(fn{i});
            end
        end
    end
end