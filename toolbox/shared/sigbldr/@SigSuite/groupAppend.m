










function varargout=groupAppend(this,varargin)
    if nargin==1
        if isempty(varargin)
            this.Groups(end+1)=SigSuiteGroup;
        else
            this.Groups(end+1)=SigSuiteGroup(varargin);
        end
    elseif nargin==2
        if isa(varargin{1},'SigSuiteGroup')

            newgroup=varargin{1};
            curGrpCnt=this.NumGroups;

            allGrpNames=cell(1,curGrpCnt);
            for i=1:curGrpCnt
                allGrpNames{i}=this.Groups(i).Name;
            end


            oldName=newgroup.Name;
            newName=uniqueify_str_with_number(oldName,0,allGrpNames{:});

            this.Groups(end+1)=newgroup.copyObj;
            this.Groups(end).Name=newName;
        elseif isa(varargin{1},'SigSuite')




            newsbobj=varargin{1};
            curGrpCnt=this.NumGroups;
            newGrpCnt=newsbobj.NumGroups;
            newGrpNames={newsbobj.Groups.Name};
            newSigNames={newsbobj.Groups(1).Signals.Name};


            allGrpNames=groupNamesUpdate(this,newGrpNames);
            afterGrpNames=allGrpNames(curGrpCnt+1:end);
            afterGrpNames=sprintf('   %s\n',afterGrpNames{:});

            for i=1:newGrpCnt

                newsbobj.Groups(i).Name=allGrpNames{curGrpCnt+i};
            end

            this.Groups(curGrpCnt+1:curGrpCnt+newGrpCnt)=newsbobj.Groups;

            beforeSigNames={this.Groups(1).Signals.Name};
            beforeSigNames=sprintf('   %s\n',beforeSigNames{:});

            SigSuite.groupSignalNamesUpdate(this);
            afterSigNames={this.Groups(1).Signals.Name};
            afterSigNames=sprintf('   %s\n',afterSigNames{:});

            newSigNames=sprintf('   %s\n',newSigNames{:});
            newGrpNames=sprintf('   %s\n',newGrpNames{:});

            curSigCnt=this.Groups(1).NumSignals;
            message=DAStudio.message('Sigbldr:sigsuite:GroupAppendValid',...
            newGrpCnt,curSigCnt,newGrpNames,afterGrpNames,newSigNames,beforeSigNames,afterSigNames);
            varargout{1}=this;
            varargout{2}=message;
        elseif isnumeric(varargin{1})
            this.Groups(end+1:end+varargin{1})=SigSuiteGroup(varargin{1});
        end
    elseif(nargin>=3&&nargin<=5)
        if(nargin==4&&isa(varargin{1},'SigSuite'))



            newsbobj=varargin{1};
            grpList=varargin{2};
            sigList=varargin{3};
            groupAppendValidate(this,grpList,sigList);

            allGrpCnt=newsbobj.NumGroups;
            allSigCnt=newsbobj.Groups(1).NumSignals;
            list=1:allGrpCnt;
            tobeRemoved=list(~ismember(list,grpList));
            if~isempty(tobeRemoved)
                newsbobj.groupRemove(tobeRemoved);
            end
            grpCnt=length(grpList);
            for i=1:grpCnt
                list=1:allSigCnt;
                tobeRemoved=list(~ismember(list,sigList{i}));
                if~isempty(tobeRemoved)
                    newsbobj.Groups(i).signalRemove(tobeRemoved);
                end
            end
            SigSuite.groupSignalNamesUpdate(newsbobj);
            [~,message]=groupAppend(this,newsbobj);
            varargout{1}=this;
            varargout{2}=message;

        else
            sigNames=[];grpNames=[];

            if~iscell(varargin{1})&&(~isnumeric(varargin{1})||isscalar(varargin{1}))
                DAStudio.error('Sigbldr:sigsuite:VectorOrCellTimeData','TIME');
            end
            time=varargin{1};


            if~iscell(varargin{2})&&(~isnumeric(varargin{2})||isscalar(varargin{2}))
                DAStudio.error('Sigbldr:sigsuite:VectorOrCellTimeData','DATA');
            end
            data=varargin{2};

            if(nargin>=4)
                sigNames=varargin{3};
            end

            if(nargin==5)
                grpNames=varargin{4};
            end




            SigSuite.timeDataConsistencyCheck(time,data);


            SigSuite.sigNameGrpNameConsistencyCheck(data,sigNames,grpNames);

            [time,data,sigNames,grpNames]=SigSuite.canonicalMake(time,data,sigNames,grpNames);



            curGrpCnt=this.NumGroups;
            curSigCnt=this.Groups(this.ActiveGroup).NumSignals;

            [rows,cols]=size(time);

            if(curSigCnt==1)
                if(rows>1&&cols>1)
                    DAStudio.error('Sigbldr:sigsuite:GroupAppendOldNewGroupSignalSizeMismatch',...
                    curSigCnt,rows);
                else

                    newGrpCnt=length(time);
                    time=time(:)';
                    data=data(:)';
                end
            else
                newGrpCnt=cols;
                if(rows~=curSigCnt)
                    DAStudio.error('Sigbldr:sigsuite:GroupAppendOldNewGroupSignalSizeMismatch',...
                    curSigCnt,rows);
                end
            end


            if isempty(grpNames)
                for i=1:newGrpCnt
                    grpNames{i}=['Group ',num2str(curGrpCnt+i)];
                end
            else
                if length(grpNames)~=newGrpCnt
                    DAStudio.error('Sigbldr:sigsuite:GroupDataMismatch',...
                    length(grpNames),newGrpCnt);
                end
            end

            allGrpNames=this.groupNamesUpdate(grpNames);
            afterGrpNames=allGrpNames(curGrpCnt+1:end);
            afterGrpNames=sprintf(' | %s',afterGrpNames{:});

            beforeSigNames={this.Groups(1).Signals.Name};

            if iscell(sigNames)

                replaceIdx=cellfun('isempty',sigNames);
                if any(replaceIdx)
                    sigNames{replaceIdx}=beforeSigNames{replaceIdx};
                end
            end

            if isempty(sigNames)
                this.Groups(end+1:end+newGrpCnt)=SigSuiteGroup(time,data,beforeSigNames,allGrpNames(curGrpCnt+1:end));
            else
                this.Groups(end+1:end+newGrpCnt)=SigSuiteGroup(time,data,sigNames,allGrpNames(curGrpCnt+1:end));
            end





            beforeSigNames=sprintf('   %s\n',beforeSigNames{:});
            SigSuite.groupSignalNamesUpdate(this);
            afterSigNames={this.Groups(1).Signals.Name};
            afterSigNames=sprintf('   %s\n',afterSigNames{:});
            if~isempty(sigNames)
                sigNames=sprintf('   %s\n',sigNames{:});
            else
                sigNames=sprintf('%s','No Signal name(s) provided.');
            end
            grpNames=sprintf('   %s\n',grpNames{:});

            message=DAStudio.message('Sigbldr:sigsuite:GroupAppendValid',...
            newGrpCnt,curSigCnt,grpNames,afterGrpNames,sigNames,beforeSigNames,afterSigNames);
            varargout{1}=this;
            varargout{2}=message;
        end
    end
end

