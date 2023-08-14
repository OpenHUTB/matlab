















classdef(ConstructOnLoad=true)SigSuite<handle



    properties
        Name='';
        Groups=SigSuiteGroup.empty;
        ActiveGroup=1;
        UserData=[];
    end




    properties(Dependent=true)
NumGroups
    end

    methods



        function this=SigSuite(varargin)

            mlock;

            if nargin==0
                this.Name='';
                if isempty(this.ActiveGroup)&&(this.NumGroups>0)
                    this.ActiveGroup=1;
                end
            elseif nargin==1
                if(isa(varargin{1},'struct'))

                    tmpStruct=varargin{1};
                    numGroups=numel(tmpStruct.dataSet);
                    this.Groups(1:numGroups)=SigSuiteGroup(tmpStruct);

                    if isfield(tmpStruct,'dataSetIdx')
                        this.ActiveGroup=tmpStruct.dataSetIdx;
                    elseif isfield(tmpStruct,'current')
                        this.ActiveGroup=tmpStruct.current.dataSetIdx;
                    end
                    this.groupTRangeSet({tmpStruct.dataSet.timeRange});
                else
                    this(1,varargin{1}).Name='';
                end
            elseif(nargin>=2)&&(nargin<=4)
                sigNames=[];grpNames=[];




                if(~iscell(varargin{1})&&(~isnumeric(varargin{1})||isscalar(varargin{1})))||iscellstr(varargin{1})
                    DAStudio.error('Sigbldr:sigsuite:VectorOrCellTimeData','TIME');
                end
                time=varargin{1};


                if(~iscell(varargin{2})&&(~isnumeric(varargin{2})||isscalar(varargin{2})))||iscellstr(varargin{2})
                    DAStudio.error('Sigbldr:sigsuite:VectorOrCellTimeData','DATA');
                end
                data=varargin{2};

                if(nargin>=3)
                    if~isempty(varargin{3})&&~iscell(varargin{3})&&...
                        ~ischar(varargin{3})
                        DAStudio.error('Sigbldr:sigsuite:StringOrCellSigGroupNames','SIGNAMES');
                    end
                    sigNames=varargin{3};



                    if iscellstr(sigNames)


                        [uniqueValues,uniqueIDX]=unique(sigNames);


                        if length(uniqueValues)~=length(sigNames)

                            uniqueIDX=sort(uniqueIDX');%#ok<TRSRT>


                            nonUniqueIDX=setdiff(1:length(sigNames),uniqueIDX);


                            for kIndex=1:length(nonUniqueIDX)

                                newStr=uniqueify_str_with_number(sigNames{nonUniqueIDX(kIndex)},0,sigNames{uniqueIDX});


                                sigNames{nonUniqueIDX(kIndex)}=newStr;
                                uniqueIDX=[uniqueIDX,nonUniqueIDX(kIndex)];%#ok<AGROW>
                            end


                            varargin{3}=sigNames;
                        end
                    end
                end

                if(nargin==4)
                    if~iscell(varargin{4})&&~ischar(varargin{4})&&...
                        ~isempty(varargin{4})
                        DAStudio.error('Sigbldr:sigsuite:StringOrCellSigGroupNames','GROUPNAMES');
                    end
                    grpNames=varargin{4};
                end





                SigSuite.timeDataConsistencyCheck(time,data);


                SigSuite.sigNameGrpNameConsistencyCheck(data,sigNames,grpNames);

                [time,data,sigNames,grpNames]=SigSuite.canonicalMake(time,data,sigNames,grpNames);


                [~,grpCnt]=size(time);

                if isempty(grpNames)
                    allGrpNames=cell(1,grpCnt);
                    for i=1:grpCnt
                        allGrpNames{i}=['Group ',num2str(i)];
                    end
                else
                    allGrpNames=cell(1,grpCnt);
                    allGrpNames{1}=grpNames{1};

                    for i=2:grpCnt
                        allGrpNames{i}=uniqueify_str_with_number(grpNames{i},0,allGrpNames{1:i-1});
                    end
                end

                this.Groups(1:grpCnt)=SigSuiteGroup(time,data,sigNames,allGrpNames);

                this.ActiveGroup=1;
                this.Name='Signal Builder';

            end

            for i=length(this):-1:1
                if isempty(this(i).ActiveGroup)&&(this(i).NumGroups>0)
                    this(i).ActiveGroup=1;
                end
            end
        end
    end

    methods






        function newobj=copyObj(this)

            newobj=SigSuite;
            f=fieldnames(this);

            f=f(~(strcmp(f,'NumGroups')));
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
        end
    end

    methods







        function set.Name(this,name)
            [row,col]=size(name);
            if~isempty(name)&&~iscell(name)&&~ischar(name)
                DAStudio.error('Sigbldr:sigsuite:IncorrectName');
            end

            if ischar(name)&&(row>1)
                DAStudio.error('Sigbldr:sigsuite:IncorrectName');
            end

            if iscell(name)&&(row>1||col>1)
                DAStudio.error('Sigbldr:sigsuite:IncorrectName');
            end

            this.Name=name;
        end



        function set.ActiveGroup(this,index)
            curGrpCnt=this.NumGroups;%#ok<MCSUP>
            if(isempty(index)||~isnumeric(index)||length(index)>1||...
                floor(index)~=index||index<0||...
                (index==0&&curGrpCnt>0))
                DAStudio.error('Sigbldr:sigsuite:NonScalarGroupIndex');
            end
            if(curGrpCnt~=0)

                if(index>curGrpCnt)
                    blockName=this.Name;%#ok<MCSUP>
                    DAStudio.error('Sigbldr:sigsuite:IncorrectGroupIndex',...
                    index,blockName,curGrpCnt);
                end
            end
            this.ActiveGroup=index;
        end



















        function numgroups=get.NumGroups(this)
            numgroups=length(this.Groups);
        end
    end

    methods



        varargout=groupAppend(this,varargin);




        groupMove(this,index1,index2,varargin);




        allGrpNames=groupNamesUpdate(this,newGrpNames);




        groupRemove(this,tobeDeleted);




        groupRename(this,groupIdx,newNames);




        groupReorder(this,neworder,varargin);




        groupTRangeSet(this,TRange,varargin);

    end

    methods(Hidden=true)



        function ds=group2Dataset(this,grpIdx)


            if(~ischar(grpIdx)&&~isnumeric(grpIdx))||isempty(grpIdx)
                DAStudio.error('Sigbldr:sigsuite:StringOrNumericSignalGroup','GROUP');
            end

            grpCnt=length(grpIdx);

            nargoutchk(0,grpCnt);


            ds=Simulink.SimulationData.Dataset();

            for gidx=grpCnt:-1:1
                m=grpIdx(gidx);
                group=this.Groups(m);
                numSig=group.NumSignals;

                tempDs=Simulink.SimulationData.Dataset();
                tempDs.Name=group.Name;
                for sidx=1:numSig

                    ts=timeseries((group.Signals(sidx).YData)',group.Signals(sidx).XData,'Name',group.Signals(sidx).Name);

                    tsName=group.Signals(sidx).Name;


                    tempDs=tempDs.addElement(ts,tsName);
                end
                ds(gidx)=tempDs;
            end

        end

    end

    methods



        [time,data,sigNames,grpNames]=groupSignalGet(this,signal,group);




        [time,data,sigNames,grpNames]=groupSignalGetAll(this);




        varargout=groupSignalAppend(this,varargin);




        varargout=groupSignalSelect(this,varargin);




        groupSignalSet(this,sigIdx,grpIdx,time,data);




        groupSignalRemove(this,removeSignals);




        groupSignalRename(this,varargin);

    end

    methods(Access='private',Hidden=true)



        function[signalIdx,groupIdx]=groupSignalIndexCheck(this,signal,group,SorG)
            groupIdx=[];
            signalIdx=[];

            if((SorG=='S')|(strcmp(SorG,'SG')==1))%#ok<OR2>
                sigCnt=this.Groups(this.ActiveGroup).NumSignals;

                if isempty(signal)
                    signalIdx=1:sigCnt;
                elseif ischar(signal)
                    allNames={this.Groups(this.ActiveGroup).Signals.Name};
                    signalIdx=find(strcmp(signal,allNames));

                    if isempty(signalIdx)
                        DAStudio.error('Sigbldr:sigsuite:InvalidSignalName',signal);
                    end

                    if length(signalIdx)>1
                        DAStudio.error('Sigbldr:sigsuite:NonUniqueSignalName',signal);
                    end
                else
                    if islogical(signal)
                        signalIdx=find(signal);
                    else
                        signalIdx=signal;
                    end

                    if any(signalIdx<1)
                        DAStudio.error('Sigbldr:sigsuite:NonScalarSignalIndex');
                    end

                    if any(signalIdx>sigCnt)
                        badIndex=find(signalIdx>sigCnt);
                        DAStudio.error('Sigbldr:sigsuite:IncorrectSignalIndex',...
                        signalIdx(badIndex(1)),sigCnt);
                    end
                end

            end

            if((SorG=='G')|(strcmp(SorG,'SG')==1))%#ok<OR2>

                grpCnt=this.NumGroups;

                if isempty(group)
                    groupIdx=1:grpCnt;
                elseif ischar(group)
                    allNames={this.Groups.Name};
                    groupIdx=find(strcmp(group,allNames));

                    if isempty(groupIdx)
                        DAStudio.error('Sigbldr:sigsuite:InvalidGroupName',group);
                    end
                    if length(groupIdx)>1
                        DAStudio.error('Sigbldr:sigsuite:NonUniqueGroupName',group);
                    end
                else
                    if islogical(group)
                        groupIdx=find(group);
                    else
                        groupIdx=group;
                    end
                    if any(groupIdx<1)
                        DAStudio.error('Sigbldr:sigsuite:NonScalarGroupIndex');
                    end
                    if any(groupIdx>grpCnt)
                        blockName=this.Name;
                        badIndex=find(groupIdx>grpCnt);
                        DAStudio.error('Sigbldr:sigsuite:IncorrectGroupIndex',...
                        groupIdx(badIndex(1)),blockName,grpCnt);
                    end
                end
            end
        end

    end



    methods(Static=true)



        groupSignalNamesUpdate(thisobj);




        timeDataConsistencyCheck(time,data);




        sigNameGrpNameConsistencyCheck(data,sigNames,grpNames);




        [time,data,sigNames,grpNames]=canonicalMake(time,data,sigNames,grpNames)




        [doesmatch]=sigPerGroupNumberCheck(grpCnt,sigList);

    end

    methods
        function groupCopy(this,index,varargin)


            this.Groups(end+1)=this.Groups(index).copyObj;
        end
    end

end
