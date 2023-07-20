















classdef(ConstructOnLoad=true)SigSuiteGroup<handle

    properties
        Name='';
        Signals=SigSuiteSignal.empty;
        ActiveSignal=[];
        RequirementInfo='';
        UserData=[];
    end

    properties(Dependent=true)
NumSignals
    end
    properties(Hidden=true)
        TimeRange=[0,10];
    end
    methods



        function this=SigSuiteGroup(varargin)

            mlock;
            if nargin==0
                this.Name='';
            elseif nargin==1
                if(isnumeric(varargin{1}))

                    this(1,varargin{1}).Name='';
                elseif(isa(varargin{1},'struct'))
                    tmpStruct=varargin{1};
                    newGrpCnt=numel(tmpStruct.dataSet);
                    newSigCnt=numel(tmpStruct.channels);

                    this(1,newGrpCnt).Name='';
                    for m=1:newGrpCnt
                        this(m).Name=tmpStruct.dataSet(m).name;
                        this(m).Signals(1:newSigCnt)=SigSuiteSignal(m,tmpStruct);
                    end
                else

                    if(~isa(varargin{1},'SigSuiteGroup'))
                        ME=MException('SigSuiteGroup:SigSuiteGroup:invalidGroup',...
                        '''Groups'' should be a "SigSuiteGroup" object.');
                        throw(ME);
                    end
                end
            elseif nargin>=2&&nargin<=4
                sigNames_=[];grpNames_=[];
                [sigCnt_,grpCnt_]=size(varargin{1});

                if sigCnt_>this.getMaxSupportedSignals

                    newExc=MException('sigbldr_blk:sigbuilder_block:tooManySignals',...
                    getString(message('sigbldr_blk:sigbuilder_block:TooManySignals')));


                    throw(newExc);
                end


                this(1,grpCnt_).Name='';

                time_=varargin{1};
                data_=varargin{2};

                if(nargin>=3)
                    sigNames_=varargin{3};
                end
                if(nargin==4)
                    grpNames_=varargin{4};
                end





                if isempty(grpNames_)
                    grpNames_=cell(1,grpCnt_);
                    for i=1:grpCnt_
                        grpNames_{i}=['Group ',num2str(i)];
                    end
                end

                if isempty(sigNames_)
                    allSigNames_=cell(1,sigCnt_);
                    for i=1:sigCnt_
                        allSigNames_{i}=['Signal ',num2str(i)];
                    end
                else

                    allSigNames_=cell(1,sigCnt_);
                    allSigNames_{1}=sigNames_{1};

                    for i=2:sigCnt_
                        allSigNames_{i}=uniqueify_str_with_number(sigNames_{i},0,allSigNames_{1:i-1});
                    end
                end


                for m=1:grpCnt_
                    timeVec=time_{1,m};
                    this(m).TimeRange=[timeVec(1),timeVec(end)];
                    this(m).Name=grpNames_{m};
                    this(m).Signals(1:sigCnt_)=SigSuiteSignal(data_(:,m),time_(:,m),allSigNames_);
                end
            end
        end
    end

    methods



        function newobj=copyObj(this)

            newobj=SigSuiteGroup;
            f=fieldnames(this);

            f=f(~(strcmp(f,'NumSignals')));
            for pnum=1:numel(f)
                prop=f{pnum};


                if isa(this.(f{pnum}),['SigSuite',f{pnum}(1:end-1)])&&...
                    ~isempty(this.(f{pnum}))&&...
                    ismethod(this.(f{pnum})(1),'copyObj')


                    for m=1:numel(this.(f{pnum}))
                        newobj.(prop)(m)=this.(f{pnum})(m).copyObj;
                    end


                else
                    newobj.(prop)=this.(prop);
                end
            end
            newobj.TimeRange=this.TimeRange;
        end
    end

    methods






        function numsignals=get.NumSignals(this)
            numsignals=length(this.Signals);
        end







    end

    methods



        function signalAdd(this,varargin)


            doUniqueify=1;
            if nargin==1
                this.Signals(end+1)=SigSuiteSignal;
            elseif nargin==2


                this.Signals(end+1:end+varargin{1})=SigSuiteSignal(varargin{1});
            elseif nargin==3
                if(isa(varargin{1},'SigSuiteSignal'))
                    newSignals=varargin{1};
                    doUniqueify=varargin{2};
                    newSigCnt=length(newSignals);
                    curSigCnt=this.NumSignals;
                    if(doUniqueify)
                        this.signalUniqueifyNames(newSignals)
                    end




                    newSignals=this.signalTimeDataUpdate(newSignals);
                    this.Signals(curSigCnt+1:curSigCnt+newSigCnt)=newSignals;
                else
                    this.Signals(end+1)=SigSuiteSignal;
                    newSignal=this.Signals(end);
                    newSignal.XData=varargin{1};
                    newSignal.YData=double(varargin{2});
                end
            elseif nargin>=4




                sigNames_=varargin{3};
                if nargin>4
                    doUniqueify=varargin{4};
                end

                [newSigCnt,~]=size(varargin{1});
                curSigCnt=this.NumSignals;

                time=varargin{1};
                data=varargin{2};

                if iscell(time)&&length(time)>this.getMaxSupportedSignals

                    newExc=MException('sigbldr_blk:sigbuilder_block:tooManySignals',...
                    getString(message('sigbldr_blk:sigbuilder_block:TooManySignals')));


                    throw(newExc);
                end


                [newtime,newdata]=this.signalTimeDataUpdate(time,data);

                if iscell(sigNames_)

                    replaceIdx=cellfun('isempty',sigNames_);
                    for i=find(replaceIdx)
                        sigNames_{i}=['Signal ',num2str(i)];
                    end
                end

                if(doUniqueify)
                    if~isempty(sigNames_)
                        if~iscell(sigNames_)
                            sigNames_={sigNames_};
                        end
                    else
                        sigNames_=cell(1,newSigCnt);
                        for i=1:newSigCnt
                            sigNames_{i}=['Signal ',num2str(i)];
                        end
                    end

                    allSigNames_=cell(1,curSigCnt);
                    for n=1:curSigCnt
                        allSigNames_{n}=this.Signals(n).Name;
                    end

                    allSigNames_=[allSigNames_,sigNames_];
                    for i=1:newSigCnt
                        allSigNames_{curSigCnt+i}=uniqueify_str_with_number(sigNames_{i},0,allSigNames_{1:(curSigCnt+i-1)});
                    end
                    this.Signals(curSigCnt+1:curSigCnt+newSigCnt)=SigSuiteSignal(newdata,newtime,allSigNames_(curSigCnt+1:end));
                else
                    this.Signals(curSigCnt+1:curSigCnt+newSigCnt)=SigSuiteSignal(newdata,newtime,sigNames_(curSigCnt+1:end));
                end
            end
        end



        function signalRemove(this,index,varargin)
            this.Signals(index)=[];
        end



        function signalRename(this,varargin)
            if nargin<4
                check=1;
            else
                check=varargin{3};
            end

            signalIdx=varargin{1};
            newNames=varargin{2};
            sigCnt=length(signalIdx);

            if check==1
                allSigNames={this.Signals.Name};
                for sidx=1:sigCnt
                    n=signalIdx(sidx);
                    allSigNames{n}=uniqueify_str_with_number(newNames{sidx},n,allSigNames{:});
                    this.Signals(n).Name=allSigNames{n};
                end
            else
                for sidx=1:sigCnt
                    n=signalIdx(sidx);
                    this.Signals(n).Name=newNames{sidx};
                end

            end


        end



        function signalReorder(this,neworder,varargin)

            this.Signals=this.Signals(neworder);
        end



        function[varargout]=signalTimeDataUpdate(this,varargin)

            if nargin==2
                if(isa(varargin{1},'SigSuiteSignal'))
                    newSignals=varargin{1};
                    newSigCnt=length(newSignals);
                    for j=1:newSigCnt
                        curTime=newSignals(j).XData;
                        curData=newSignals(j).YData;
                        minTime=min(this.TimeRange(1),curTime(1));
                        maxTime=max(this.TimeRange(2),curTime(end));




                        [newtime,newdata]=update_time_data(curTime(1),curTime(end),...
                        minTime,...
                        maxTime,...
                        curTime,curData);

                        newSignals(j).XData=newtime;
                        newSignals(j).YData=double(newdata);
                    end
                    varargout{1}=newSignals;
                end
            elseif nargin>=3
                oldtime=varargin{1};
                olddata=varargin{2};
                [sigCnt,~]=size(olddata);
                newtime=cell(sigCnt,1);
                newdata=cell(sigCnt,1);
                for i=1:sigCnt
                    curTime=oldtime{i};
                    curData=olddata{i};
                    if(curTime(1)<0)
                        minTime=min(this.TimeRange(1));
                    else
                        minTime=min(this.TimeRange(1),curTime(1));
                    end
                    maxTime=max(this.TimeRange(2),curTime(end));




                    [newtime{i},newdata{i}]=update_time_data(curTime(1),curTime(end),...
                    minTime,...
                    maxTime,...
                    curTime,curData);
                    newdata{i}=double(newdata{i});
                end
                varargout{1}=newtime;
                varargout{2}=newdata;

            end
        end



        function signalUniqueifyNames(this,newSignals)
            allSigNames={this.Signals.Name};
            newSigNames={newSignals.Name};
            allSigNames=[allSigNames,newSigNames];
            curSigCnt=this.NumSignals;
            newSigCnt=length(newSignals);
            for i=1:newSigCnt
                allSigNames{curSigCnt+i}=uniqueify_str_with_number(newSigNames{i},0,allSigNames{1:(curSigCnt+i-1)});
                newSignals(i).Name=allSigNames{curSigCnt+i};
            end

        end
    end

    methods



        function status=validate(this)
            status=true;
            grpCnt=length(this);
            sigCnt=length(this(1).Signals);
            for i=2:grpCnt
                if(sigCnt~=length(this(i).Signals))
                    status=false;
                    return
                end
            end
        end

        function maxNumOfSignals=getMaxSupportedSignals(~)



            maxNumOfSignals=32757;

        end








    end

    methods




        function moveSignal(this,index1,index2,varargin)

            if index1>index2

                b=index2:this.NumSignals;



                c=b(b~=index1);


                this.Signals=[this.Signals(1:index2-1),this.Signals(index1),this.Signals(c)];

            elseif index2>index1

                b=1:index2;



                c=b(1:index2~=index1);


                this.Signals=[this.Signals(c),this.Signals(index1),this.Signals(index2+1:end)];

            else

            end
        end

        function copySignal(this,index,varargin)
            this.Signals(end+1)=this.Signals(index).copyObj;
        end
    end
end
