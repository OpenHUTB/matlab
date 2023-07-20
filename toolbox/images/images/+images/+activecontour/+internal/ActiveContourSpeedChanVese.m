





classdef ActiveContourSpeedChanVese<images.activecontour.internal.ActiveContourSpeed

    properties

smoothfactor
foregroundweight
backgroundweight
balloonweight

    end

    properties(Access='private')

inMean
outMean
inArea
outArea
sizePhi
isColor

    end

    methods

        function obj=ActiveContourSpeedChanVese(smoothfactor,balloonweight,foregroundweight,backgroundweight)

            obj.smoothfactor=smoothfactor;
            obj.balloonweight=balloonweight;
            obj.foregroundweight=foregroundweight;
            obj.backgroundweight=backgroundweight;

        end

        function obj=initalizeSpeed(obj,I,phi)

            obj.sizePhi=size(phi,3);
            obj.isColor=size(I,3)~=size(phi,3);
            sz=size(I);
            phisz=size(phi);

            if~isequal(sz(1),phisz(1))||~isequal(sz(2),phisz(2))
                error(message('images:activecontour:differentMatrixSize','I','PHI'))
            end

            if obj.isColor
                numChannels=size(I,3);
            else
                numChannels=1;
            end

            [obj.inArea,obj.outArea,obj.inMean,obj.outMean]=...
            images.internal.builtins.chanVeseInitializeSpeed(...
            I,phi,sz,numChannels);

        end

        function F=calculateSpeed(obj,I,phi,pixIdx)

            if isempty(pixIdx)
                F=pixIdx;
                return;
            end

            import images.activecontour.internal.*;

            if obj.isColor
                sz=size(I);
                I=reshape(I,[sz(1)*sz(2),sz(3)]);
                I_idx=I(pixIdx,:);
                F=((obj.foregroundweight*((I_idx-obj.inMean').^2))/sz(3))-...
                ((obj.backgroundweight*((I_idx-obj.outMean').^2))/sz(3));
                F=sum(F,2);
            else
                I_idx=I(pixIdx);
                F=(obj.foregroundweight*((I_idx-obj.inMean).^2))-...
                (obj.backgroundweight*((I_idx-obj.outMean).^2));

            end

            F=F/max(abs(F));
            curvature=calculateCurvature(phi,pixIdx);
            curvature=curvature/max(abs(curvature));

            F=F+(obj.smoothfactor)*curvature+obj.balloonweight;





            F=F/(1+obj.smoothfactor+abs(obj.balloonweight));

        end

        function obj=updateSpeed(obj,I,idxLin2out,idxLout2in)

            if obj.isColor
                sz=size(I);
                I=reshape(I,[sz(1)*sz(2),sz(3)]);
                I_Lin2out=I(idxLin2out,:);
                I_Lout2in=I(idxLout2in,:);
            else
                I_Lin2out=I(idxLin2out);
                I_Lout2in=I(idxLout2in);
            end


            sumPnts=sum(I_Lin2out);
            tempSum=(obj.inMean*obj.inArea)-sumPnts;
            obj.inArea=obj.inArea-length(I_Lin2out);
            obj.inMean=tempSum/obj.inArea;
            tempSum=(obj.outMean*obj.outArea)+sumPnts;
            obj.outArea=obj.outArea+length(I_Lin2out);
            obj.outMean=tempSum/obj.outArea;


            sumPnts=sum(I_Lout2in);
            tempSum=(obj.outMean*obj.outArea)-sumPnts;
            obj.outArea=obj.outArea-length(I_Lout2in);
            obj.outMean=tempSum/obj.outArea;
            tempSum=(obj.inMean*obj.inArea)+sumPnts;
            obj.inArea=obj.inArea+length(I_Lout2in);
            obj.inMean=tempSum/obj.inArea;

        end



        function obj=set.smoothfactor(obj,smoothfactorValue)
            validateattributes(smoothfactorValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'nonnegative','scalar','nonnan','finite'});
            obj.smoothfactor=double(smoothfactorValue);
        end

        function obj=set.balloonweight(obj,balloonweightValue)
            validateattributes(balloonweightValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'scalar','nonnan','finite'});
            obj.balloonweight=double(balloonweightValue);
        end

        function obj=set.foregroundweight(obj,foregroundweightValue)
            validateattributes(foregroundweightValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'nonnegative','scalar','nonnan','finite'});
            obj.foregroundweight=double(foregroundweightValue);
        end

        function obj=set.backgroundweight(obj,backgroundweightValue)
            validateattributes(backgroundweightValue,{'uint8','int8','uint16',...
            'int16','uint32','int32','single','double'},{'real',...
            'nonnegative','scalar','nonnan','finite'});
            obj.backgroundweight=double(backgroundweightValue);
        end

    end

end



