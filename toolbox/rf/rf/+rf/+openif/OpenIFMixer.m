classdef OpenIFMixer<matlab.mixin.Heterogeneous&handle

%#ok<*AGROW>

    properties
IMT
RFCF
RFBW
MixingType
IFBW
    end

    properties(SetAccess=private)
        SpurVector=[]
    end

    properties(Access=private)
        isSpurVectorCurrent=false
    end

    methods
        function thisObj=OpenIFMixer(newIMT,newRFCF,newRFBW,newMixType,newIFBW)

            thisObj.IMT=newIMT;
            thisObj.RFCF=newRFCF;
            thisObj.RFBW=newRFBW;
            thisObj.MixingType=newMixType;
            thisObj.IFBW=newIFBW;

            thisObj.validatemixerinputs;
        end
    end

    methods
        function set.IFBW(theObj,newIFBW)
            if~(isscalar(newIFBW)&&isnumeric(newIFBW)&&...
                isreal(newIFBW)&&(newIFBW>0))

                error(message('rf:openif:openifmixer:setifbw:InvalidIFBW'))
            end

            theObj.IFBW=newIFBW;
            theObj.makespurvectornotcurrent;
        end

        function set.MixingType(theObj,newMixingType)
            if~(ischar(newMixingType)&&isvector(newMixingType))

                error(message('rf:openif:openifmixer:setmixingtype:NotChar'))
            end

            switch lower(newMixingType)
            case{'sum','diff','low','high'}
                theObj.MixingType=lower(newMixingType);
            otherwise

                error(message('rf:openif:openifmixer:setmixingtype:InvalidMixingType'))
            end
            theObj.makespurvectornotcurrent;
        end

        function set.RFBW(theObj,newRFBW)
            if~(isscalar(newRFBW)&&isnumeric(newRFBW)&&...
                isreal(newRFBW)&&(newRFBW>0))

                error(message('rf:openif:openifmixer:setrfbw:InvalidRFBW'))
            end

            theObj.RFBW=newRFBW;
            theObj.makespurvectornotcurrent;
        end

        function set.RFCF(theObj,newRFCF)
            if~(isscalar(newRFCF)&&isnumeric(newRFCF)&&...
                isreal(newRFCF)&&(newRFCF>0))

                error(message('rf:openif:openifmixer:setrfcf:InvalidRFCF'))
            end

            theObj.RFCF=newRFCF;
            theObj.makespurvectornotcurrent;
        end

        function set.IMT(theObj,newIMT)
            if~(isnumeric(newIMT)&&(ndims(newIMT)==2)&&...
                isreal(newIMT)&&~isempty(newIMT))

                error(message('rf:openif:openifmixer:setimt:InvalidIMT'))
            end

            [R,C]=size(newIMT);

            if(min(R,C)<2)

                error(message('rf:openif:openifmixer:setimt:IMTTooSmall'))
            end

            if(newIMT(2,2)~=0)

                error(message('rf:openif:openifmixer:setimt:IMT22Not0'))
            end


            if(R<C)
                newIMT=[newIMT;99*ones(C-R,C)];
            elseif(C<R)
                newIMT=[newIMT;99*ones(R-C,R)];
            end

            theObj.IMT=newIMT;
            theObj.makespurvectornotcurrent;
        end
    end

    methods
        function thespurobj=get.SpurVector(theObj)
            if~theObj.isSpurVectorCurrent

                error(message('rf:openif:openifmixer:getspurvector:NotCurrent'))
            end
            thespurobj=theObj.SpurVector;
        end
    end

    methods

        function calcspurs(theObj,IFLoc)
            if theObj.isSpurVectorCurrent
                return
            end

            allspurs=[];

            [R,C]=size(theObj.IMT);
            tempIMT=horzcat(fliplr(theObj.IMT),theObj.IMT(:,2:end));

            for mm=1:size(tempIMT,2)
                for nn=1:R
                    if tempIMT(nn,mm)<99
                        M=mm-C;
                        N=nn-1;

                        RFmin=theObj.RFCF-0.5*theObj.RFBW;
                        RFmax=theObj.RFCF+0.5*theObj.RFBW;

                        LOmin=theObj.RFCF-0.5*(theObj.RFBW-theObj.IFBW);
                        LOmax=theObj.RFCF+0.5*(theObj.RFBW-theObj.IFBW);

                        switch theObj.MixingType
                        case{'diff','high'}
                            s=1;
                        case{'sum','low'}
                            s=-1;
                        otherwise

                            error(message('rf:openif:openifmixer:calcspurs:InvalidMixingType'))
                        end

                        spurcand={};
                        for K=-1:2:1
                            switch lower(IFLoc)
                            case 'mixerinput'
                                IFrng=(K*[RFmin,RFmin,RFmax,RFmax]-...
                                M*[LOmin,LOmax,LOmin,LOmax])/(N+M*s);
                            case 'mixeroutput'
                                IFrng=(N*[RFmin,RFmin,RFmax,RFmax]+...
                                M*[LOmin,LOmax,LOmin,LOmax])/(K-M*s);
                            otherwise

                                error(message('rf:openif:openifmixer:calcspurs:InvalidIFLocation'))
                            end
                            if all(isfinite(IFrng))
                                if any(IFrng>0)
                                    if any(IFrng<RFmin)
                                        IFrng(IFrng>RFmin)=RFmin;
                                        spurcand=[spurcand;...
                                        {[max(min(IFrng),0),max(IFrng)]}];
                                    end
                                end
                            end
                        end
                        switch length(spurcand)
                        case 1
                            allspurs=[allspurs;...
                            rf.openif.OpenIFSpur(spurcand{1}(1),...
                            spurcand{1}(2),...
                            tempIMT(nn,mm),...
                            min(RFmin+s*spurcand{1}),...
                            max(RFmax+s*spurcand{1}),...
                            theObj,M,N)];
                        case 2
                            if(max(min(spurcand{1}),min(spurcand{2}))...
                                >min(max(spurcand{1}),max(spurcand{2})))

                                allspurs=[allspurs;...
                                rf.openif.OpenIFSpur(spurcand{1}(1),...
                                spurcand{1}(2),...
                                tempIMT(nn,mm),...
                                min(RFmin+s*spurcand{1}),...
                                max(RFmax+s*spurcand{1}),...
                                theObj,M,N)];

                                allspurs=[allspurs;...
                                rf.openif.OpenIFSpur(spurcand{2}(1),...
                                spurcand{2}(2),...
                                tempIMT(nn,mm),...
                                min(RFmin+s*spurcand{2}),...
                                max(RFmax+s*spurcand{2}),...
                                theObj,M,N)];

                            else

                                spurmin=min([spurcand{1},spurcand{2}]);
                                spurmax=max([spurcand{1},spurcand{2}]);
                                allspurs=[allspurs;...
                                rf.openif.OpenIFSpur(spurmin,...
                                spurmax,...
                                tempIMT(nn,mm),...
                                min(RFmin+s*[spurmin,spurmax]),...
                                max(RFmax+s*[spurmin,spurmax]),...
                                theObj,M,N)];
                            end
                        end
                    end
                end
            end

            theObj.SpurVector=allspurs;
            theObj.isSpurVectorCurrent=true;
        end

        function makespurvectornotcurrent(theObj)
            theObj.isSpurVectorCurrent=false;
        end
    end

    methods(Access=private)
        function validatemixerinputs(theObj)
            if(theObj.RFBW>2*theObj.RFCF)

                error(message('rf:openif:openifmixer:validatemixerinputs:ImpossibleBWandCF'))
            end

            if(theObj.IFBW>theObj.RFBW)

                error(message('rf:openif:openifmixer:validatemixerinputs:IFBWvsRFBW'))
            end
        end
    end
end