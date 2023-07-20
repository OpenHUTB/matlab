function this=dspdelay(varargin)







    this=hdl.dspdelay;
    this.init(varargin{:});

    if isempty(this.nDelays)
        this.nDelays=1;
    end



    if(max(length(this.nDelays))>1)
        this.inputs=hdlexpandvectorsignal(this.inputs);
        this.outputs=hdlexpandvectorsignal(this.outputs);
    end

    tmp=cell(max(length(this.nDelays)),1);

    for ii=1:max(length(this.nDelays))
        if(this.nDelays(ii)==0)
            tmp{ii}=[];
        else
            vector=hdlsignalvector(this.outputs(1));
            sltype=hdlsignalsltype(this.outputs(1));
            cplx=hdlsignaliscomplex(this.outputs(1));
            newvhdltype=hdlvectorblockdatatype(cplx,[this.nDelays(ii),0],...
            hdlblockdatatype(sltype),sltype);
            if(vector==0)

                [tempnames,ptr]=hdlnewsignal('int_delay_pipe',...
                'block',-1,cplx,...
                [this.nDelays(ii),0],newvhdltype,sltype);
                tmp{ii}=ptr;
            else
                vectsize=max(vector(:));
                ptrs=[];
                for k=1:vectsize,
                    [tempnames,ptr]=hdlnewsignal('int_delay_pipe',...
                    'block',-1,cplx,...
                    [this.nDelays(ii),0],...
                    newvhdltype,sltype);
                    ptrs=[ptrs,ptr];
                end
                tmp{ii}=ptrs;
            end
        end
    end



    this.tmpsignal=this.outputs;
    this.outputs=tmp;




    if isscalar(this.resetvalues)||...
        isvector(this.resetvalues)&&...
        ~iscell(this.resetvalues)


        rval=this.resetvalues;
        tmpresetvalues=cell(max(length(this.nDelays)),1);
        for ii=1:max(length(this.nDelays))
            tmpresetvalues{ii}=rval;
        end

        this.resetvalues=tmpresetvalues;
    end



    vecsize=max(hdlsignalvector(this.inputs(1)));
    for ii=1:max(length(this.nDelays))

        dlysize=this.nDelays(ii);


        resetsize=size(this.resetvalues{ii});
        if(vecsize>resetsize(1))
            expsize=ceil(vecsize/resetsize(1));
            this.resetvalues{ii}=repmat(this.resetvalues{ii},expsize,1);
        end
        if(dlysize>resetsize(2))
            expsize=ceil(dlysize/resetsize(1));
            this.resetvalues{ii}=repmat(this.resetvalues{ii},1,expsize);
        end






        this.resetvalues{ii}=fliplr(this.resetvalues{ii});
    end

