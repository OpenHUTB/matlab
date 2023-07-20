





classdef ActiveContourSpeedEdgeBased<images.activecontour.internal.ActiveContourSpeed

    properties

balloonC
advectionC
smoothfactor



sigma
lambda
edgeExponent
    end

    properties(Access='private')

gI
grad_gI

    end

    methods

        function obj=ActiveContourSpeedEdgeBased(smoothfactor,balloonC,...
            advectionC,sigma,lambda,edgeExponent)

            obj.smoothfactor=smoothfactor;
            obj.balloonC=balloonC;
            obj.advectionC=advectionC;
            obj.sigma=sigma;
            obj.lambda=lambda;
            obj.edgeExponent=edgeExponent;


        end

        function obj=initalizeSpeed(obj,I,phi)

            if isinteger(I)
                I=single(I);
            end


            filtRadius=ceil(obj.sigma*2);
            filtSize=2*filtRadius+1;
            if ismatrix(I)
                I=imgaussfilt(I,obj.sigma,'Padding','replicate','FilterSize',filtSize);
                I=imgradient(I);
            elseif ndims(I)==3&&size(phi,3)>1
                I=imgaussfilt3(I,obj.sigma);
                I=imgradient3(I);
            else
                assert(false,'''Edge'' method not supported for color or multi-channel images.');
            end
            obj.gI=1./(1+(I/obj.lambda).^obj.edgeExponent);

            obj.grad_gI=getImageDirectionalGradient(obj.gI);

        end

        function F=calculateSpeed(obj,I,phi,pixIdx)

            if isempty(pixIdx)
                F=pixIdx;
                return;
            end
            if~isequal(size(I,1),size(phi,1))||~isequal(size(I,2),size(phi,2))
                error(message('images:activecontour:differentMatrixSize',...
                'I','PHI'))
            end
            if~isequal(size(obj.gI),size(phi))
                error(message('images:activecontour:inconsistentStateEdgeBased',...
                'PHI',mfilename('class'),'initializeSpeed',mfilename('class')))
            end

            import images.activecontour.internal.*;

            numPix=numel(pixIdx);
            numDims=ndims(phi);

            edgePotential=obj.gI(pixIdx);
            [curvature,delPhi]=calculateCurvature(phi,pixIdx);
            magDelPhi=sqrt(sum(delPhi.^2,2));
            idx2normalize=magDelPhi>1e-12;
            if any(idx2normalize)
                delPhi(idx2normalize,:)=bsxfun(@rdivide,delPhi(idx2normalize,:),...
                magDelPhi(idx2normalize));
            end
            delPhi(~idx2normalize,:)=0;


            delG=zeros(numPix,numDims);
            for jj=1:numDims
                delG(:,jj)=obj.grad_gI(pixIdx+(jj-1)*numel(phi));
            end

            F=edgePotential.*bsxfun(@plus,obj.smoothfactor*curvature,obj.balloonC)...
            -bsxfun(@times,dot(delG,delPhi,2),obj.advectionC);

            F=F/max(abs(F));

        end



        function obj=set.smoothfactor(obj,smoothfactorValue)
            validateattributes(smoothfactorValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'nonnegative','scalar','nonnan','finite'});
            obj.smoothfactor=double(smoothfactorValue);
        end

        function obj=set.advectionC(obj,advectionCValue)
            validateattributes(advectionCValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'nonnegative','scalar','nonnan','finite'});
            obj.advectionC=double(advectionCValue);
        end

        function obj=set.balloonC(obj,balloonCValue)
            validateattributes(balloonCValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'scalar','nonnan','finite'});
            obj.balloonC=double(balloonCValue);
        end

        function obj=set.lambda(obj,lambdaValue)
            validateattributes(lambdaValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'nonnegative','scalar','nonnan','finite'});
            obj.lambda=double(lambdaValue);
        end

        function obj=set.edgeExponent(obj,edgeExponentValue)
            validateattributes(edgeExponentValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'nonnegative','scalar','nonnan','finite'});
            obj.edgeExponent=double(edgeExponentValue);
        end

        function obj=set.sigma(obj,sigmaValue)
            validateattributes(sigmaValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'nonnegative','scalar','nonnan','finite'});
            obj.sigma=double(sigmaValue);
        end

    end

end


function gI=getImageDirectionalGradient(I)








    if ndims(I)==2 %#ok<ISMAT>
        [gX,gY]=gradient(I);
        gI=cat(3,gX,gY);
    elseif ndims(I)==3
        [gX,gY,gZ]=gradient(I);
        gI=cat(4,gX,gY,gZ);
    else
        iptassert(false,message('images:activecontour:mustBe2D','A'));
    end

end

