function this=divide(varargin)





    this=hdl.divide;

    if nargin==0
        pvpairs=[];
    else
        pvpairs=varargin;
    end


    if~isempty(pvpairs)

        if mod(length(pvpairs),2)~=0
            error(message('HDLShared:directemit:oddpvpairs',mfilename));
        end

        for ii=1:2:length(pvpairs)
            switch lower(pvpairs{ii})
            case 'inputs'
                this.inputs=pvpairs{ii+1};
            case 'output'
                this.output=pvpairs{ii+1};
            case 'rounding'
                this.rounding=pvpairs{ii+1};
            case 'saturation'
                this.saturation=pvpairs{ii+1};
            case 'type'
                this.type=pvpairs{ii+1};
            otherwise
                error(message('HDLShared:directemit:unknownproperty',mfilename));
            end
        end
    end
