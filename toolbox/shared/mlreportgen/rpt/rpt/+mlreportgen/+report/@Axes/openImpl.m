function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2Cxo8yUARVPCeGaq6+KIuhrE7f8aypJxBKK8ldZbo5vKuIXfRCIfKiVID88'...
        ,'kqTyVPDZC+McMMMe/0Ltv5Yo+1YGVZWa0oMXRKpn7LOvyU1yewVK1rq8jWPj'...
        ,'sTu7FNoknNwk+9TSKy2jhOHPC9P4fYigu922DYA2hPETadLEzkAgn0JrTpLR'...
        ,'yfGuVHrpEfIVQ3nUPfgPXgx8EH3rQWUs24X3Bpzb2YP6orLY5S77ZtNSUZzd'...
        ,'y5+V1xxXoIv7IJlwoTDCSqOoqvA9zNtqiWajdDra92e0MTgyYCj+aNU/BgM='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end