function this=intdelay(varargin)





    this=hdl.intdelay;
    this.init(varargin{:});

    if isempty(this.nDelays)
        this.nDelays=4;
    end

    tmp=[];

    if this.nDelays~=1
        for ii=1:length(this.outputs)
            vector=hdlsignalvector(this.outputs(ii));
            sltype=hdlsignalsltype(this.outputs(ii));
            cplx=hdlsignaliscomplex(this.outputs(ii));
            newvhdltype=hdlvectorblockdatatype(cplx,[this.nDelays,0],...
            hdlblockdatatype(sltype),...
            sltype);
            if(vector==0)

                [tempnames,ptr]=hdlnewsignal('int_delay_pipe',...
                'block',-1,cplx,...
                [this.nDelays,0],newvhdltype,sltype);
                tmp=[tmp,ptr];
            else

                vectsize=max(vector(:));
                ptrs=[];
                for k=1:vectsize,
                    [tempnames,ptr]=hdlnewsignal('int_delay_pipe',...
                    'block',-1,cplx,...
                    [this.nDelays,0],newvhdltype,sltype);
                    ptrs=[ptrs,ptr];
                end
                tmp=[tmp,ptrs];
            end
        end

        this.tmpsignal=this.outputs;
        this.outputs=tmp;

    end

    if length(this.outputs)>length(this.resetvalues)
        this.resetvalues=repmat(this.resetvalues,1,length(this.outputs)*this.nDelays);
    end

    if hdlissignalvector(this.inputs)
        this.resetvalues=fliplr(reshape(this.resetvalues,length(this.outputs),this.nDelays));

    end
