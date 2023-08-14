classdef(StrictDefaults)PAmemory<matlab.System



























































%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>


    properties(Nontunable)


        ModelType(1,:)char{matlab.system.mustBeMember(ModelType,...
        {'Memory polynomial','Cross-Term Memory'})}='Memory polynomial'

        CoefficientMatrix(:,:)double{mustBeNonempty,mustBeFinite}=1

        UnitDelay(1,1)double{mustBeNonempty,mustBeReal,mustBePositive,...
        mustBeFinite}=1e-6

        SamplesPerUnitDelay(1,1)double{mustBeNonempty,mustBePositive,...
        mustBeInteger}=1
    end


    properties(Access=private)

        p_extendedFrame(1,:)=0



        p_needToInitializeExtendedFrame(1,1)logical{mustBeNonnegative}=true


        pmp_Vterms(:,:)=ones(1,1)


        pmp_absPowV(:,:)=ones(1,1)

        pg_vCTMpart1(:,:)=ones(1,1)

        pg_vCTMpart2(:,:)=ones(1,1)
    end

    properties(Access=private,Nontunable)

        p_coefficientMatrixColumn(:,1)

        p_delaySize(1,1){mustBeInteger}

        p_powerSize(1,1){mustBeInteger}

        p_lengthFrame(1,1){mustBeInteger}

        p_cMatrixDim2(1,1){mustBeInteger}

        p_lengthExtendedFrame(1,1){mustBeInteger}

        p_startDelayIndex(1,1){mustBeInteger}



        p_samplesPerUnitDelay(1,1){mustBeInteger}

        pmp_powers(:,:){mustBeInteger}


        pmp_idxExframeV(:,:){mustBeInteger}

        pmp_isIdxExFrameColumn(1,1)logical{mustBeNonnegative}

        pg_coeffMatColPart2(:,1)

        pg_powers(:,:){mustBeInteger}


        pg_exframeIndex(:,:){mustBeInteger}
    end


    methods

        function obj=PAmemory(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')

                if~(builtin('license','checkout','RF_Blockset'))
                    error(message('rfblks:rfbhelp:NoLicenseAvailable'));
                end
            else

                coder.license('checkout','RF_Blockset');
            end

            setProperties(obj,nargin,varargin{:})
        end
    end


    methods(Access=protected)
        function setupImpl(obj,u)

            obj.p_needToInitializeExtendedFrame=true;
            sizeCmat=size(obj.CoefficientMatrix);
            obj.p_delaySize=(sizeCmat(1));
            if strcmp(obj.ModelType,'Memory polynomial')
                obj.p_powerSize=(sizeCmat(2));
            else
                powerSize=(sizeCmat(2)+sizeCmat(1)-1)/sizeCmat(1);
                coder.internal.errorIf(...
                (powerSize-floor(powerSize))>1e3*eps(powerSize),...
                'rf:shared:WrongNumberCols',sprintf('%g',powerSize));
                obj.p_powerSize=powerSize;
            end
            obj.p_cMatrixDim2=sizeCmat(2);

            if getExecPlatformIndex(obj)

                sts=getSampleTime(obj);
                sampleTime=sts.SampleTime;
                lengthFrame=cast(propagatedInputSize(obj,1),'like',double(1));
                obj.p_lengthFrame=lengthFrame(1);
                numSamples=obj.UnitDelay*obj.p_lengthFrame/sampleTime;
                coder.internal.errorIf(...
                (numSamples-floor(numSamples))>1e3*eps(numSamples),...
                'rf:shared:NumSamplesNotInt',sprintf('%g',numSamples));
                obj.p_samplesPerUnitDelay=numSamples;
            else
                obj.p_lengthFrame=length(u);
                obj.p_samplesPerUnitDelay=obj.SamplesPerUnitDelay;
            end

            if strcmp(obj.ModelType,'Memory polynomial')
                obj.p_coefficientMatrixColumn=reshape(...
                obj.CoefficientMatrix,obj.p_delaySize*obj.p_cMatrixDim2,1);

                if obj.p_delaySize==1
                    obj.pmp_idxExframeV=...
                    reshape((1:obj.p_lengthFrame),obj.p_lengthFrame,1);
                else
                    obj.pmp_idxExframeV=transpose(1:(obj.p_lengthFrame))+...
                    repmat(...
                    ((obj.p_delaySize-1)*obj.p_samplesPerUnitDelay:...
                    -obj.p_samplesPerUnitDelay:0),...
                    obj.p_lengthFrame,1);
                end
                obj.pmp_isIdxExFrameColumn=size(obj.pmp_idxExframeV,2)==1;
                obj.pmp_Vterms=zeros(obj.p_lengthFrame,obj.p_delaySize);
                obj.pmp_absPowV=...
                zeros(obj.p_lengthFrame,obj.p_powerSize*obj.p_delaySize);


                obj.pmp_powers=kron(0:(obj.p_powerSize-1),...
                ones(obj.p_lengthFrame,obj.p_delaySize));
            else
                if obj.p_powerSize>1
                    obj.pg_vCTMpart2=complex(zeros(obj.p_lengthFrame,...
                    (obj.p_cMatrixDim2-1)*obj.p_delaySize));
                    obj.pg_coeffMatColPart2=reshape(...
                    obj.CoefficientMatrix(...
                    1:obj.p_delaySize,2:obj.p_cMatrixDim2),...
                    obj.p_delaySize*(obj.p_cMatrixDim2-1),1);
                    obj.pg_powers=...
                    kron(1:(obj.p_powerSize-1),...
                    ones(obj.p_lengthFrame,obj.p_delaySize));
                end
                obj.pg_exframeIndex=transpose(1:(obj.p_lengthFrame))+...
                repmat(((obj.p_delaySize-1)*obj.p_samplesPerUnitDelay:...
                -obj.p_samplesPerUnitDelay:0),obj.p_lengthFrame,1);
                obj.pg_vCTMpart1=...
                complex(zeros(obj.p_lengthFrame,obj.p_delaySize));
            end

            obj.p_extendedFrame=complex(zeros(1,(obj.p_delaySize-1)*...
            obj.p_samplesPerUnitDelay+obj.p_lengthFrame),0);
            obj.p_lengthExtendedFrame=length(obj.p_extendedFrame);
            obj.p_startDelayIndex=obj.p_lengthExtendedFrame-...
            obj.p_samplesPerUnitDelay*(obj.p_delaySize-1)+1;
        end

        function y=stepImpl(obj,u)
            uCast=cast(u,'like',complex(double(0),double(0)));

            if obj.p_needToInitializeExtendedFrame==true
                obj.p_extendedFrame(1,:)=uCast(1);
                obj.p_needToInitializeExtendedFrame=false;
            end
            obj.p_extendedFrame=[obj.p_extendedFrame(...
            obj.p_startDelayIndex:obj.p_lengthExtendedFrame),transpose(uCast)];


            if strcmp(obj.ModelType,'Memory polynomial')
                if obj.pmp_isIdxExFrameColumn
                    obj.pmp_Vterms=obj.p_extendedFrame(obj.pmp_idxExframeV).';
                else
                    obj.pmp_Vterms=obj.p_extendedFrame(obj.pmp_idxExframeV);
                end
                obj.pmp_absPowV=...
                repmat(abs(obj.pmp_Vterms),1,obj.p_powerSize).^obj.pmp_powers;
                y=(repmat(obj.pmp_Vterms,1,obj.p_powerSize).*...
                obj.pmp_absPowV)*obj.p_coefficientMatrixColumn;
            else

                if size(obj.pg_exframeIndex,2)~=1
                    obj.pg_vCTMpart1(1:obj.p_lengthFrame,1:obj.p_delaySize)=...
                    obj.p_extendedFrame(obj.pg_exframeIndex);
                else
                    obj.pg_vCTMpart1(1:obj.p_lengthFrame,1)=...
                    obj.p_extendedFrame(1,obj.pg_exframeIndex).';
                end
                y=(obj.pg_vCTMpart1(1:obj.p_lengthFrame,1:obj.p_delaySize)*...
                obj.CoefficientMatrix(1:obj.p_delaySize,1));
                if obj.p_powerSize>1
                    Vabspow=repmat(...
                    abs(obj.pg_vCTMpart1),1,(obj.p_powerSize-1)).^...
                    obj.pg_powers;
                    obj.pg_vCTMpart2=kron(Vabspow,ones(1,obj.p_delaySize)).*...
                    repmat(obj.pg_vCTMpart1,...
                    1,obj.p_delaySize*(obj.p_powerSize-1));
                    y=y+obj.pg_vCTMpart2(1:obj.p_lengthFrame,...
                    1:((obj.p_cMatrixDim2-1)*obj.p_delaySize))*...
                    obj.pg_coeffMatColPart2;
                end
            end
            y=cast(y,'like',u);
        end

        function resetImpl(obj)

            obj.p_needToInitializeExtendedFrame=true;
        end

        function flag=isInactivePropertyImpl(obj,prop)


            flag=false;
            switch prop
            case 'SamplesPerUnitDelay'
                if getExecPlatformIndex(obj)
                    flag=true;
                end
            end
        end


        function s=saveObjectImpl(obj)


            s=saveObjectImpl@matlab.System(obj);

            if isLocked(obj)

                s.p_extendedFrame=obj.p_extendedFrame;
                s.p_needToInitializeExtendedFrame=...
                obj.p_needToInitializeExtendedFrame;
                s.p_coefficientMatrixColumn=obj.p_coefficientMatrixColumn;
                s.p_delaySize=obj.p_delaySize;
                s.p_powerSize=obj.p_powerSize;
                s.p_lengthFrame=obj.p_lengthFrame;
                s.p_cMatrixDim2=obj.p_cMatrixDim2;
                s.p_lengthExtendedFrame=obj.p_lengthExtendedFrame;
                s.p_startDelayIndex=obj.p_startDelayIndex;
                s.p_samplesPerUnitDelay=obj.p_samplesPerUnitDelay;
                s.pmp_Vterms=obj.pmp_Vterms;
                s.pmp_absPowV=obj.pmp_absPowV;
                s.pmp_powers=obj.pmp_powers;
                s.pmp_idxExframeV=obj.pmp_idxExframeV;
                s.pmp_isIdxExFrameColumn=obj.pmp_isIdxExFrameColumn;
                s.pg_vCTMpart1=obj.pg_vCTMpart1;
                s.pg_vCTMpart2=obj.pg_vCTMpart2;
                s.pg_coeffMatColPart2=obj.pg_coeffMatColPart2;
                s.pg_powers=obj.pg_powers;
                s.pg_exframeIndex=obj.pg_exframeIndex;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)

            if wasLocked
                obj.p_extendedFrame=s.p_extendedFrame;
                obj.p_needToInitializeExtendedFrame=...
                s.p_needToInitializeExtendedFrame;
                obj.p_coefficientMatrixColumn=s.p_coefficientMatrixColumn;
                obj.p_delaySize=s.p_delaySize;
                obj.p_powerSize=s.p_powerSize;
                obj.p_lengthFrame=s.p_lengthFrame;
                obj.p_cMatrixDim2=s.p_cMatrixDim2;
                obj.p_lengthExtendedFrame=s.p_lengthExtendedFrame;
                obj.p_startDelayIndex=s.p_startDelayIndex;
                obj.p_samplesPerUnitDelay=s.p_samplesPerUnitDelay;
                obj.pmp_Vterms=s.pmp_Vterms;
                obj.pmp_absPowV=s.pmp_absPowV;
                obj.pmp_powers=s.pmp_powers;
                obj.pmp_idxExframeV=s.pmp_idxExframeV;
                obj.pmp_isIdxExFrameColumn=s.pmp_isIdxExFrameColumn;
                obj.pg_vCTMpart1=s.pg_vCTMpart1;
                obj.pg_vCTMpart2=s.pg_vCTMpart2;
                obj.pg_coeffMatColPart2=s.pg_coeffMatColPart2;
                obj.pg_powers=s.pg_powers;
                obj.pg_exframeIndex=s.pg_exframeIndex;
            end


            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end


        function validateInputsImpl(obj,u)
            validateattributes(u,{'double','single'},...
            {'column','finite'},class(obj),'Block input');
        end

        function flag=isInputSizeMutableImpl(~,~)


            flag=false;
        end

        function out=getOutputSizeImpl(obj)

            out=propagatedInputSize(obj,1);
        end

        function out=isOutputComplexImpl(~)

            out=true;
        end

        function sts=getSampleTimeImpl(obj)

            sts=createSampleTime(obj);
        end

        function icon=getIconImpl(~)
            icon=matlab.system.display.Icon(...
            [matlabroot,'/toolbox/rf/rf/powerAmp.svg']);
        end

        function name=getInputNamesImpl(~)

            name='';
        end

        function name=getOutputNamesImpl(~)

            name='';
        end
    end


    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header(mfilename("class"),...
            'ShowSourceLink',true,...
            'Title','Power Amplifier with Memory',...
            'Text',sprintf('Narrowband power amplifier with memory.'));
        end

        function group=getPropertyGroupsImpl

            group=matlab.system.display.Section(mfilename('class'),...
            'PropertyList',{'ModelType','CoefficientMatrix','UnitDelay',...
            'SamplesPerUnitDelay'});
        end
    end

end