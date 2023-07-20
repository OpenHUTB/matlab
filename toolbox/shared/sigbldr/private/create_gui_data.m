function apiData=create_gui_data(SBSigSuite,visibility)






    ActiveGroup=SBSigSuite.ActiveGroup;
    sigCnt=SBSigSuite.Groups(ActiveGroup).NumSignals;
    grpCnt=SBSigSuite.NumGroups;

    if nargin<2||isempty(visibility)
        visibility=set_group_visibility(sigCnt,grpCnt);
    end

    tstart=min(SBSigSuite.Groups(1).Signals(1).XData);
    tend=max(SBSigSuite.Groups(1).Signals(1).XData);

    apiData.gridSetting='on';
    apiData.dataSetIdx=1;
    apiData.common=common_data_struct([tstart,tend]);
    apiData.channels=[];
    apiData.axes=[];

    if grpCnt>0
        apiData.dataSet=dataSet_data_struct(SBSigSuite.Groups(1).Name,[tstart,tend]);
    else
        apiData.dataSet=dataSet_data_struct([],[tstart,tend]);
        return;
    end

    dispIdx=flipud(find(visibility(:,1)));
    apiData.dataSet.activeDispIdx=dispIdx';

    if iscell(sigCnt)>getMaxSupportedSignals

        newExc=MException('sigbldr_blk:sigbuilder_block:tooManySignals',...
        getString(message('sigbldr_blk:sigbuilder_block:TooManySignals')));


        throw(newExc);
    end

    for i=1:sigCnt
        chStruct=channel_data_struct(SBSigSuite.Groups(1).Signals(i).XData,...
        SBSigSuite.Groups(1).Signals(i).YData,...
        0,...
        0,...
        SBSigSuite.Groups(1).Signals(i).Name,...
        1);

        if(i==1)
            apiData.channels=chStruct;
        else
            apiData.channels(end+1)=chStruct;
        end
    end


    for i=2:grpCnt
        tstart=min(SBSigSuite.Groups(i).Signals(1).XData);
        tend=max(SBSigSuite.Groups(i).Signals(1).XData);

        apiData.dataSet(end+1)=dataSet_data_struct(SBSigSuite.Groups(i).Name,[tstart,tend]);
        dispIdx=flipud(find(visibility(:,i)));
        apiData.dataSet(end).activeDispIdx=dispIdx';
    end

