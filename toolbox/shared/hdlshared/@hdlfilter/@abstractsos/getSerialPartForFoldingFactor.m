function varargout=getSerialPartForFoldingFactor(this,varargin)






    sos_sec=this.numSections;

    if nargin>1
        prop=varargin{1};
        val=varargin{2};
    end
    scales=this.ScaleValues;
    if scales(sos_sec+1)==1
        opscaleisunity=1;
    else
        opscaleisunity=0;
    end

    if opscaleisunity
        FF=[2*sos_sec,3*sos_sec,6*sos_sec];
    else
        FF=[2*sos_sec+1,3*sos_sec+1,6*sos_sec+1];
    end
    mults=[3,2,1];
    ini_lat=[0,0,0];
    artype=[0,0,0];

    if nargin>1
        propidx=strmatch(lower(prop),lower({'foldingfactor','multipliers'}));
        switch propidx
        case 1
            mulpos=find(FF==val);
            if isempty(mulpos)
                if val==1

                    muls=calcparallelmults(this);
                    ff=1;
                    varargout={muls,0,0};
                else
                    error(message('HDLShared:hdlfilter:wrongff',num2str(sort(FF))));
                end
            else
                mults1=mults(mulpos);
                artype1=artype(mulpos);
                varargout={mults1,val,ini_lat(mulpos)};
            end
        case 2
            FFpos=find(mults==val);
            if isempty(FFpos)
                error(message('HDLShared:hdlfilter:wrongmults',num2str(sort(mults))));
            else
                FF1=FF(FFpos);
                artype1=artype(FFpos);
                varargout={val,FF1,ini_lat(FFpos)};
            end
        otherwise
            error(message('HDLShared:hdlfilter:wrongargssos'));
        end
    else
        varargout={mults,FF,ini_lat,artype};
    end

    function mults=calcparallelmults(this)

        sosm=this.Coefficients;
        sv=this.Scalevalues;

        cf=[sv',sosm(:)'];

        mults=length(cf);
        negmult=0;

        for n=1:length(cf)
            if cf(n)==0||...
                cf(n)==1||...
                cf(n)==-1||...
                hdlispowerof2(cf(n))
                negmult=negmult+1;
            end
        end
        mults=mults-negmult;





