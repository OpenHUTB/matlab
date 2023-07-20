classdef OpenIFSpur<rf.openif.OpenIFFreqRange


%#ok<*AGROW>
    properties
SourceMixer
Midx
Nidx
    end

    properties(SetAccess=private)
LORange
    end

    properties(Dependent,SetAccess=private)
MN
    end

    methods
        function thisObj=OpenIFSpur(SpurFreq1,SpurFreq2,dB,...
            LOFreq1,LOFreq2,whichMixer,...
            newM,newN)
            thisObj=thisObj@rf.openif.OpenIFFreqRange(SpurFreq1,SpurFreq2,dB);
            thisObj.LORange=[LOFreq1,LOFreq2];
            thisObj.SourceMixer=whichMixer;
            thisObj.Midx=newM;
            thisObj.Nidx=newN;
        end
    end

    methods
        function theMNpair=get.MN(theObj)
            theMNpair=[theObj.Midx,theObj.Nidx];
        end
    end

    methods
        function theObj=set.LORange(theObj,newLORange)
            if~theObj.validateFreqRange(newLORange)

                error(message('rf:openif:openifspur:setlorange:InvalidLORange'))
            end

            theObj.LORange=[min(newLORange),max(newLORange)];
        end

        function theObj=set.SourceMixer(theObj,newMixer)
            if~isa(newMixer,'rf.openif.OpenIFMixer')

                error(message('rf:openif:openifspur:setsourcemixer:NotAMixerObj'))
            end
            theObj.SourceMixer=newMixer;
        end

        function theObj=set.Nidx(theObj,newNidx)
            if~(isnumeric(newNidx)&&isreal(newNidx)&&...
                isscalar(newNidx)&&(newNidx>=0)&&...
                (newNidx==round(newNidx)))

                error(message('rf:openif:openifspur:setnidx:InvalidN'))
            end
            theObj.Nidx=newNidx;
        end

        function theObj=set.Midx(theObj,newMidx)
            if~(isnumeric(newMidx)&&isreal(newMidx)&&...
                isscalar(newMidx)&&(newMidx==round(newMidx)))

                error(message('rf:openif:openifspur:setmidx:InvalidM'))
            end
            theObj.Midx=newMidx;
        end
    end

    methods
        function varargout=getData(theObj)

            K=length(theObj);
            allfreqs=zeros(K,2);
            alldBs=zeros(K,1);
            allMixers=[];
            allLOfreqs=zeros(K,2);
            allMN=zeros(K,2);

            for nn=1:K
                allfreqs(nn,:)=theObj(nn).FreqRange;
                alldBs(nn)=theObj(nn).dBLevel;
                allLOfreqs(nn,:)=theObj(nn).LORange;
                allMN(nn,:)=theObj(nn).MN;
                allMixers=[allMixers;theObj(nn).SourceMixer];
            end

            varargout{1}=allfreqs;
            if nargout>1
                varargout{2}=alldBs;
                if nargout>2
                    varargout{3}=allMixers;
                    if nargout>3
                        varargout{4}=allLOfreqs;
                        if nargout>4
                            varargout{5}=allMN;
                        end
                    end
                end
            end

        end

    end

end