classdef(StrictDefaults)ConvolutionalEncoder<comm.gpu.internal.GPUBase












































































    properties(Nontunable)







        TrellisStructure=poly2trellis(7,[171,133]);






















        TerminationMethod='Continuous';



        ResetInputPort(1,1)logical=false;



        DelayedResetAction(1,1)logical=false;



        InitialStateInputPort(1,1)logical=false;



        FinalStateOutputPort(1,1)logical=false;








        PuncturePatternSource='None';







        PuncturePattern=[1;1;0;1;0;1];







        NumFrames(1,1){mustBePositive,mustBeInteger}=1;
    end

    properties(Constant,Hidden)
        TerminationMethodSet=comm.CommonSets.getSet('TerminationMethod');
        PuncturePatternSourceSet=comm.CommonSets.getSet('NoneOrProperty');
    end

    properties(Access=private)
gCoeffB
gCoeffA
mDT
sz
numTermZeros
pN
contModeBuff
contModeBuffSize
isPunc
logicalPuncturePattern
pModalNumFrames
    end

    methods
        function obj=ConvolutionalEncoder(varargin)
            setProperties(obj,nargin,varargin{:},'TrellisStructure');
        end
    end

    methods(Access=protected)
        function out=stepImpl(obj,x)
            gDin=moveInputsToGPU(obj,x);






            gDout=gpuArray.zeros(obj.pN,obj.sz(1),'single');
            if(any((x~=1)&(x~=0)))
                error(message('comm:system:ConvolutionalEncoder:NonBinaryInput'));
            end
            gDout(1,:)=cast(gDin,'single');
            gDout=reshape(gDout,[],obj.pModalNumFrames);

            switch(obj.TerminationMethod)
            case 'Terminated'
                gDout=[gDout;gpuArray.zeros(obj.numTermZeros,obj.pModalNumFrames,'single')];
            case 'Continuous'
                gDout=[obj.contModeBuff;gDout];
                obj.contModeBuff=gDout(end-obj.contModeBuffSize+1:end,:);
                obj.contModeBuffSize=numel(obj.contModeBuff);
            case 'Truncated'

            end


            gDout=filter(obj.gCoeffB,obj.gCoeffA,gDout);
            gDout=mod(gDout,2);
            if(strcmpi(obj.TerminationMethod,'Continuous'))

                gDout(1:obj.contModeBuffSize,:)=[];

            end


            if(obj.isPunc)
                gDout=reshape(gDout,numel(obj.logicalPuncturePattern),[],obj.pModalNumFrames);
                outpunc=gDout(obj.logicalPuncturePattern,:,:);
            else
                outpunc=gDout;
            end


            outpunc=reshape(outpunc,[],1);
            outpunc=cast(outpunc,obj.mDT);
            out=obj.moveOutputsIfNeeded(outpunc);
        end

        function resetImpl(obj)
            obj.contModeBuff=gpuArray.zeros(obj.numTermZeros,obj.pModalNumFrames,'single');
        end

        function setupImpl(obj,in)
            detectGPUInputs(obj,in);
            mDT=underlyingType(in);
            sz=size(in);




            if~iscolumn(in)||isempty(in)
                matlab.system.internal.error(...
                'MATLAB:system:inputMustBeColVector','X');
            end

            if strcmpi('obj.TerminationMethod','Continuous')
                frmSize=sz(1);
            else
                frmSize=sz(1)/obj.NumFrames;
            end
            obj.pModalNumFrames=getInternalNumFrames(obj);

            if(frmSize~=ceil(frmSize))
                error(message('comm:system:ConvolutionalEncoder:BadNumFrames'));
            end

            if(frmSize<log2(obj.TrellisStructure.numStates))
                error(message('comm:system:ConvolutionalEncoder:BadInputLength'));
            end


            if~(obj.isRealBuiltinFloat(in)||obj.islogical(in))
                error(message('comm:system:ConvolutionalEncoder:BadInputType'));
            end

            obj.isPunc=getInternalPunctureFlag(obj);
            obj.pN=log2(obj.TrellisStructure.numOutputSymbols);
            if(obj.isPunc)
                if(mod(frmSize*obj.pN,numel(obj.PuncturePattern))~=0)
                    error(message('comm:system:ConvolutionalEncoder:BadInputLengthPuncturing'));
                end
            end


            obj.gCoeffA=gpuArray(cast(1,'single'));
            genPoly=trellis2logicalpoly(obj.TrellisStructure);
            obj.gCoeffB=gpuArray(cast(genPoly(:),'single'));
            obj.mDT=mDT;
            obj.sz=sz;
            obj.numTermZeros=getNumTerminationBits(obj);
            obj.contModeBuffSize=obj.numTermZeros;
            obj.logicalPuncturePattern=logical(obj.PuncturePattern);
        end

        function flag=isInactivePropertyImpl(obj,prop)
            switch(obj.TerminationMethod)
            case 'Continuous'
                props={'InitialStateInputPort','NumFrames'};
                if strcmp(obj.PuncturePatternSource,'None')
                    props=[props,{'PuncturePattern'}];
                end
                if~obj.ResetInputPort
                    props=[props,{'DelayedResetAction'}];
                end
            case 'Truncated'
                props={'ResetInputPort','DelayedResetAction'};
                if strcmp(obj.PuncturePatternSource,'None')
                    props=[props,{'PuncturePattern'}];
                end
            case 'Terminated'
                props={'ResetInputPort',...
                'DelayedResetAction',...
                'FinalStateOutputPort',...
                'InitialStateInputPort',...
                'PuncturePatternSource',...
                'PuncturePattern'};
            end
            flag=ismember(prop,props);
        end
    end

    methods(Access=private)
        function punctf=getInternalPunctureFlag(obj)
            punctf=(strcmpi(obj.PuncturePatternSource,'Property')&&...
            ~strcmpi(obj.TerminationMethod,'Terminated'));
        end

        function num=getNumTerminationBits(obj)
            t=obj.TrellisStructure;
            num=log2(t.numOutputSymbols)*log2(t.numStates);
        end

        function nf=getInternalNumFrames(obj)
            if strcmpi('obj.TerminationMethod','Continuous')
                nf=1;
            else
                nf=obj.NumFrames;
            end
        end
    end





    methods(Access=protected)
        function varargout=getOutputSizeImpl(obj)
            n=log2(obj.TrellisStructure.numOutputSymbols);
            sz=propagatedInputSize(obj,1);%#ok<*PROP>
            nf=getInternalNumFrames(obj);
            if strcmpi(obj.TerminationMethod,'Terminated')
                frameSize=sz(1)/obj.NumFrames;
                unPuncSize=(n*(frameSize)+getNumTerminationBits(obj))*nf;
            else
                unPuncSize=n*sz(1);
            end


            if getInternalPunctureFlag(obj)
                numOnes=sum(obj.PuncturePattern);
                numZeros=numel(obj.PuncturePattern)-numOnes;
                puncPatternUnits=unPuncSize/numel(obj.PuncturePattern);
                unPuncSize=unPuncSize-puncPatternUnits*numZeros;
            end

            varargout{1}=[unPuncSize,1];
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=propagatedInputDataType(obj,1);
        end

        function varargout=isOutputComplexImpl(obj)%#ok
            varargout{1}=false;
        end

        function varargout=isOutputFixedSizeImpl(obj)%#ok
            varargout{1}=true;
        end

    end

    methods


        function set.TrellisStructure(obj,T)

            if~isfeedforward(T)
                error(message('comm:system:ConvolutionalEncoder:BadTrellis'));
            end
            obj.TrellisStructure=T;

        end
        function set.PuncturePattern(obj,pp)
            [~,c]=size(pp);
            badpp=false;

            if((c~=1)||isscalar(pp))
                badpp=true;
            end


            if~all(ismember(pp,[0,1]))
                badpp=true;
            end
            if(badpp)
                error(message('comm:system:ConvolutionalEncoder:BadPuncturePattern'));
            end

            obj.PuncturePattern=pp;

        end
        function set.DelayedResetAction(obj,v)
            if(v)
                error(message('comm:system:ConvolutionalEncoder:BadDelayedResetProp'));
            end
        end
        function set.ResetInputPort(obj,v)
            if(v)
                error(message('comm:system:ConvolutionalEncoder:BadResetInputPort'));
            end
        end
        function set.InitialStateInputPort(obj,v)
            if(v)
                error(message('comm:system:ConvolutionalEncoder:BadInitialStateInputPort'));
            end
        end
        function set.FinalStateOutputPort(obj,v)
            if(v)
                error(message('comm:system:ConvolutionalEncoder:BadFinalStateOutputPort'));
            end
        end
        function set.NumFrames(obj,v)
            validateattributes(v,{'numeric'},...
            {'positive','integer'},'','NumFrames');
            obj.NumFrames=v;
        end

    end

    methods(Static,Hidden)

        function b=generatesCode
            b=false;
        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            num=1;
        end

        function flag=isInputSizeMutableImpl(obj,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end

    end
end


function tf=isfeedforward(T)

    if~(istrellis(T))
        tf=false;
        return;
    end
    k=log2(T.numInputSymbols);
    nS=T.numStates;
    nextS=T.nextStates;




    if(k==1)



        reqnextS=[floor(([1:nS]-1)/2);floor(([1:nS]-1)/2)+nS/2]';%#ok
        cs=(reqnextS==nextS);
        tf=logical(sum(sum(cs(:,:)))==nS*2);

    else
        tf=false;
    end





end

function poly=trellis2logicalpoly(t)










    cLen=log2(t.numStates)+1;












    polyIdx=([2^(cLen-1),2.^(cLen-2:-1:0)]+1);

    poly=logical([dec2bin(oct2dec(t.outputs(polyIdx)))]'-'0');
end
