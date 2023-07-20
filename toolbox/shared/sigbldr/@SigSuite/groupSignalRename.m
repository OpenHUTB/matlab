









function groupSignalRename(this,varargin)
    signalIdx=varargin{1};
    newNames=varargin{2};
    if nargin<4
        check=1;
    else
        check=varargin{3};
    end
    start=1;

    if check==1
        start=2;
        this.Groups(1).signalRename(signalIdx,newNames,1);
        newNames={this.Groups(1).Signals(signalIdx).Name};
    end

    curGrpCnt=this.NumGroups;
    for m=start:curGrpCnt
        this.Groups(m).signalRename(signalIdx,newNames,0);
    end
end