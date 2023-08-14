function varargout=getFIRSerialPartition(this,varargin)





    if nargin<1||nargin>3||nargin==2
        error(message('HDLShared:hdlfilter:needpvpairs'));
    end

    fl=this.getfilterlengths;

    if nargin==1
        spmatrix=getSerialPartMatrix(this);
        if nargout
            splist=0;
            [fflist,mullist,ilatlist]=convspmatrix2lists(spmatrix);
            varargout={fflist,mullist,ilatlist};
        else

            displaySerialPartition(this,spmatrix);
        end
    elseif nargin>1
        inputprop=lower(varargin{1});
        propidx=strmatch(inputprop,{'foldingfactor','multipliers'});
        if~isempty(propidx)
            switch propidx
            case 1
                clkMult=varargin{2};
                if(clkMult==1)
                    [mults,FF,ini_lat]=getSerialPartForFoldingFactor(this,'FoldingFactor',clkMult);
                else
                    [mults,FF,ini_lat]=getSerialPartForFoldingFactor(this,'FoldingFactor',clkMult);

                end
            case 2
                mult=varargin{2};
                [mults,clkMult,ini_lat]=getSerialPartForFoldingFactor(this,'multipliers',mult);
            otherwise
                error(message('HDLShared:hdlfilter:wrongargssos'))
            end
        else
            error(message('HDLShared:hdlfilter:wrongargssos'));
        end
        if nargout
            varargout={clkMult,mults,ini_lat};
        else
            varargout={clkMult,mults,ini_lat};
            fftitle=getString(message('HDLShared:hdlfilter:codegenmessage:foldingfactor'));
            multtitle=getString(message('HDLShared:hdlfilter:codegenmessage:multipliers'));

            fprintf(1,'%s:%4d, %s:%4d\n',fftitle,clkMult,multtitle,mults);


        end
    end


    function[fflist,mullist,ilatlist]=convspmatrix2lists(spmatrix)

        fflist=spmatrix(:,1);
        mullist=spmatrix(:,2);
        ilatlist=spmatrix(:,3);


