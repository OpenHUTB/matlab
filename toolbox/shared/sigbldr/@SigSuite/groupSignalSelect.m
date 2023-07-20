










function varargout=groupSignalSelect(this,varargin)
    if(nargin==3)
        grpList=varargin{1};
        sigList=varargin{2};

        newGrpCnt=length(grpList);
        doesmatch=SigSuite.sigPerGroupNumberCheck(newGrpCnt,sigList);
        if(~doesmatch)
            DAStudio.error('Sigbldr:sigsuite:GroupAppendIncorrectNumberofSignalsInGroups');
        end
        allGrpCnt=this.NumGroups;
        allSigCnt=this.Groups(1).NumSignals;
        list=1:allGrpCnt;
        tobeRemoved=list(~ismember(list,grpList));
        if~isempty(tobeRemoved)
            this.groupRemove(tobeRemoved);
        end
        grpCnt=length(grpList);
        for i=1:grpCnt
            list=1:allSigCnt;
            if iscell(sigList)
                tobeRemoved=list(~ismember(list,sigList{i}));
            else
                tobeRemoved=list(~ismember(list,sigList));
            end
            if~isempty(tobeRemoved)
                this.Groups(i).signalRemove(tobeRemoved);
            end
        end
        sigCnt=this.Groups(1).NumSignals;
        SigSuite.groupSignalNamesUpdate(this);
        sigNames={this.Groups(1).Signals.Name};
        sigNames=sprintf('   %s\n',sigNames{:});
        grpNames={this.Groups.Name};
        grpNames=sprintf('   %s\n',grpNames{:});

        message=DAStudio.message('Sigbldr:sigsuite:ReplaceExistingData',...
        grpCnt,grpNames,sigCnt,sigNames);
        varargout{1}=this;
        varargout{2}=message;

    end
end

