function out=getSignal(this,varargin)
    sigID=[];

    if(length(varargin)==1)||...
        ((length(varargin)==2)&&strcmp(varargin(2),'metadata'))
        sigID=varargin{1};
    elseif(length(varargin)==2)
        sigID=this.getSignalIDByIndex(varargin{:});
    end

    if ischar(varargin{1})
        sigID=this.sigRepository.getSignalIDByDataSource(varargin{1});
    end
    out=this.sigRepository.safeTransaction(...
    @this.getSignalUsingSLDD,sigID);


    if~isfield(out,'DataValues')
        out.DataValues=this.getSignalDataValues(int32(out.DataID));
    end
end