

































function chips=FddDLDPCH(chs,data,varargin)

    if isempty(data)
        chips=[];
        return
    end
    if~isfield(chs,'TimingOffset')
        chs.TimingOffset=0;
    end
    validateUMTSParameter('TimingOffset',chs);
    if~isfield(chs,'Enable2Interleaving')
        chs.Enable2Interleaving=1;
    elseif(chs.Enable2Interleaving<0||chs.Enable2Interleaving>1)
        error('umts:error','Enable2Interleaving (%d) is invalid, must be 0 or 1.',chs.Enable2Interleaving);
    end

    ncodewords=numel(chs.SpreadingCode);
    dims=FddDLDPCHDims(chs.SlotFormat);
    ndataframepcode=dims.NDataPerFrame;
    nframes=ceil(numel(data)/(ndataframepcode*ncodewords));




    data(numel(data)+1:ndataframepcode*ncodewords*nframes)=-1;
    fdata=reshape(data,[ndataframepcode,numel(data)/ndataframepcode]);
    if(chs.Enable2Interleaving)
        idata=FddPhyChInterleaving(fdata);
    else
        idata=fdata;
    end


    idata=reshape(idata,[size(idata,1),ncodewords,nframes]);
    idata=permute(idata,[1,3,2]);
    idata=reshape(idata,[numel(idata)/ncodewords,ncodewords]);


    if(nargin==2)
        phychdata=FddDLDPCHFormat(chs.SlotFormat,idata);
    elseif(nargin==3)
        phychdata=FddDLDPCHFormat(chs.SlotFormat,idata,varargin{1});
    else
        phychdata=FddDLDPCHFormat(chs.SlotFormat,idata,varargin{1},varargin{2});
    end


    chips=FddDLChannel(phychdata,'QPSK',dims.SF,chs.SpreadingCode,chs.ScramblingCode,chs.TimingOffset*256);

    if size(data,1)<size(data,2)
        chips=transpose(chips);
    end

end
