function signalID=addSignal(this,varargin)
    if nargin==2

        signalID=this.sigRepository.createSignal;
        inp.Data=varargin{1}.Data;
        inp.Time=varargin{1}.Time;
        lenData=length(inp.Data);
        inp.Data=reshape(inp.Data,lenData,1);
        inp.Time=reshape(inp.Time,lenData,1);
        if lenData>0
            this.sigRepository.setSignalDataValues(signalID,inp);
        end
    else
        signalID=this.sigRepository.add(this,varargin{:});
    end
end