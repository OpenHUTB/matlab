function varargout=getFIRSerialPartition(this,varargin)





    if nargin~=1&&nargin~=3&&nargin~=5
        error(message('HDLShared:hdlfilter:needpvpairs'));
    end

    fl=this.getfilterlengths;
    if nargin==1
        remargs=nargin;
        fl=fl.czero_len;
    elseif nargin>1

        indices_cs=strcmpi(varargin,'coefficientsource');
        poscs=1:length(indices_cs);
        poscs=poscs(indices_cs);
        if~isempty(poscs)
            if strcmpi(varargin{poscs+1},'processorinterface')||...
                strcmpi(varargin{poscs+1},'processor interface')
                fl=fl.coeff_len;

                varargin(poscs)=[];
                varargin(poscs)=[];
                remargs=nargin-2;
            elseif strcmpi(varargin{poscs+1},'internal')
                fl=fl.czero_len;
                varargin(poscs)=[];
                varargin(poscs)=[];
                remargs=nargin-2;
            else
                error(message('HDLShared:hdlfilter:invalidCoeffSource'));
            end
        else
            remargs=nargin;
            fl=fl.czero_len;
        end
    end
    if remargs==1
        spmatrix=getSerialPartMatrix(this,fl);
        if nargout
            [splist,fflist,mullist]=convspmatrix2lists(spmatrix);
            varargout={splist,fflist,mullist};
        else

            displaySerialPartition(this,spmatrix);
        end
    elseif remargs>1

        inputprop=lower(varargin{1});
        propidx=strmatch(inputprop,{'foldingfactor','multipliers','serialpartition'});
        if~isempty(propidx)
            switch propidx
            case 1
                clkMult=varargin{2};
                if clkMult>fl
                    if clkMult~=inf
                        warning(message('HDLShared:hdlfilter:highFoldingFactor',num2str(fl)));
                    end
                    clkMult=fl;
                end
                serialpart=getSerialPartForFoldingFactor(this,fl,clkMult);
            case 2
                mult=varargin{2};
                clkMult=max(ceil(fl/mult),1);
                serialpart=getSerialPartForFoldingFactor(this,fl,clkMult);
                if mult>length(serialpart)&&mult~=inf
                    warning(message('HDLShared:hdlfilter:highmultiplier',num2str(clkMult),num2str(length(serialpart))));
                end
            case 3
                sp=varargin{2};
                if sum(sp)~=fl&&any(sp~=-1)
                    error(message('HDLShared:hdlfilter:invalidserialPart',num2str(fl)));
                else
                    if sp==-1
                        clkMult=1;
                        serialpart=-1;
                    else
                        clkMult=max(sp);
                        serialpart=sort(sp,'descend');
                    end
                end
            otherwise
                error(message('HDLShared:hdlfilter:wrongargs3'))
            end
        else
            error(message('HDLShared:hdlfilter:wrongargs3'));
        end
        if serialpart==-1
            mults=fl;
        else
            mults=length(serialpart);
        end
        if nargout
            varargout={serialpart,clkMult,mults};
        else
            clkMultStr=sprintf('%4d',clkMult);
            multsStr=sprintf('%4d',mults);
            fprintf(1,getString(message('HDLShared:hdlfilter:codegenmessage:firserial',...
            this.convSerialPart2String(serialpart),clkMultStr,multsStr)));

        end
    end


    function[splist,fflist,mullist]=convspmatrix2lists(spmatrix)

        splist=spmatrix(:,3);
        fflist=spmatrix(:,1);
        muls=zeros(1,size(spmatrix,1));

        for n=1:size(spmatrix,1)
            muls(n)=str2double(spmatrix{n,2});
        end

        muls=unique(muls);
        mullist=cell(numel(muls),1);

        for n=1:numel(muls)
            mullist(n)={num2str(muls(n))};
        end






