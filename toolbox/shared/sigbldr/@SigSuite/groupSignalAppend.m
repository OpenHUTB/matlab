









function varargout=groupSignalAppend(this,varargin)



    if nargin==2
        if isa(varargin{1},'SigSuite')
            newsbobj=varargin{1};
            curGrpCnt=this.NumGroups;
            newGrpCnt=newsbobj.NumGroups;
            if(newGrpCnt==1)

                beforeAllSigNames={this.Groups(1).Signals.Name};
                beforeAllSigNames=sprintf('   %s\n',beforeAllSigNames{:});
                beforeSigNames={newsbobj.Groups(1).Signals.Name};
                beforeSigNames=sprintf('   %s\n',beforeSigNames{:});
                newSigCnt=newsbobj.Groups(1).NumSignals;
                for m=1:curGrpCnt
                    this.Groups(m).signalAdd(newsbobj.Groups(1).Signals,1);
                end
                afterSigNames={newsbobj.Groups(1).Signals.Name};
                afterSigNames=sprintf('   %s\n',afterSigNames{:});
                afterAllSigNames={this.Groups(1).Signals.Name};
                afterAllSigNames=sprintf('   %s\n',afterAllSigNames{:});
                message=DAStudio.message('Sigbldr:sigsuite:GroupSignalAppendValidS',...
                newSigCnt,beforeSigNames,afterSigNames,beforeAllSigNames,afterAllSigNames);
                varargout{1}=message;
            else

                for m=1:curGrpCnt
                    this.Groups(m).signalAdd(newsbobj.Groups(m).Signals,1);
                end
            end
        end
    elseif(nargin>=3&&nargin<=4)
        sigNames=[];
        if(~iscell(varargin{1})&&(~isnumeric(varargin{1})||isscalar(varargin{1})))||iscellstr(varargin{1})
            DAStudio.error('Sigbldr:sigsuite:VectorOrCellTimeData','TIME');
        end
        time=varargin{1};

        if(~iscell(varargin{2})&&(~isnumeric(varargin{2})||isscalar(varargin{2})))||iscellstr(varargin{2})
            DAStudio.error('Sigbldr:sigsuite:VectorOrCellTimeData','DATA');
        end
        data=varargin{2};
        if nargin>3

            sigNames=varargin{3};

        end

        SigSuite.timeDataConsistencyCheck(time,data);

        SigSuite.sigNameGrpNameConsistencyCheck(data,sigNames,[]);
        [time,data,sigNames]=SigSuite.canonicalMake(time,data,sigNames,[]);
        curGrpCnt=this.NumGroups;
        [newSigCnt,newGrpCnt]=size(data);

        if(curGrpCnt~=newGrpCnt)&&(newGrpCnt~=1)
            DAStudio.error('Sigbldr:sigsuite:GroupSignalAppend',newSigCnt,newGrpCnt,curGrpCnt);
        end








        this.Groups(1).signalAdd(time(:,1),data(:,1),sigNames,1);
        sigNames={this.Groups(1).Signals.Name};
        if(newGrpCnt==1)

            for m=2:curGrpCnt
                this.Groups(m).signalAdd(time,data,sigNames,0);
            end
        else

            for m=2:curGrpCnt
                this.Groups(m).signalAdd(time(:,m),data(:,m),sigNames,0);
            end
        end
    elseif(nargin==5)
        if isa(varargin{1},'SigSuite')


            newsbobj=varargin{1};
            grpList=varargin{2};
            sigList=varargin{3};
            appendType=upper(varargin{4});
            newGrpCnt=length(grpList);
            if(appendType=='S')

                curCnt=0;
                tmpgrp=SigSuiteGroup;
                for i=1:newGrpCnt
                    gidx=grpList(i);
                    sList=sigList{i};
                    sigCnt=length(sList);
                    tmpgrp.Signals(curCnt+1:curCnt+sigCnt)=newsbobj.Groups(gidx).Signals(sList);
                    curCnt=curCnt+sigCnt;
                end
                tmpobj=SigSuite;
                tmpobj.Groups=tmpgrp;
                message=groupSignalAppend(this,tmpobj);
                varargout{1}=message;
            elseif(appendType=='P')
                groupSignalAppendValidate(this,grpList,sigList);
                curGrpCnt=this.NumGroups;
                if(curGrpCnt==newGrpCnt)
                    beforeSigNames={newsbobj.Groups(end).Signals(sigList{end}).Name};
                    beforeSigNames=sprintf('   %s\n',beforeSigNames{:});
                    for i=1:newGrpCnt
                        gidx=grpList(i);
                        sList=sigList{i};
                        this.Groups(i).signalAdd(newsbobj.Groups(gidx).Signals(sList),1);
                    end

                    SigSuite.groupSignalNamesUpdate(this);
                    afterSigNames={this.Groups(1).Signals.Name};
                    afterSigNames=sprintf('   %s\n',afterSigNames{:});
                    message=DAStudio.message('Sigbldr:sigsuite:GroupSignalAppendValidP',...
                    length(sigList{1}),beforeSigNames,afterSigNames);
                    varargout{1}=message;
                elseif(newGrpCnt==1)
                    gidx=grpList(1);
                    sList=sigList{1};
                    beforeSigNames={newsbobj.Groups(gidx).Signals(sList).Name};
                    beforeSigNames=sprintf('   %s\n',beforeSigNames{:});
                    for m=1:curGrpCnt
                        this.Groups(m).signalAdd(newsbobj.Groups(gidx).Signals(sList(m)),1);
                    end

                    SigSuite.groupSignalNamesUpdate(this);
                    afterSigNames={this.Groups(1).Signals(end).Name};
                    afterSigNames=sprintf('   %s\n',afterSigNames{:});
                    message=DAStudio.message('Sigbldr:sigsuite:GroupSignalAppendValidPSingleGroup',...
                    beforeSigNames,afterSigNames);
                    varargout{1}=message;
                end
            end
        end
    end
end
