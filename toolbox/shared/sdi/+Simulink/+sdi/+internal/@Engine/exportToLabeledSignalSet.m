function data=exportToLabeledSignalSet(this,varInfo)


    saUtil=Simulink.sdi.Instance.getSetSAUtils();
    if isempty(saUtil)
        data=[];
        return;
    end

    [memberData,timeMode,timeData,mNames]=getChildLSSData(this,varInfo);

    inputs={};


    inputs{end+1}=memberData;


    mlss_filename=Simulink.sdi.Instance.getSetSAUtils().getStorageLSSFilename();
    if exist(mlss_filename,'file')==2
        m=matfile(mlss_filename);
        lssKey=saUtil.getKeyLabeledSignalSet(this,varInfo.signalID);
        if isprop(m,lssKey)
            inputs{end+1}=copy(m.(lssKey));
        end
    end


    if~isempty(timeMode)&&~isempty(timeData)
        inputs{end+1}=timeMode;
        if strcmp(timeMode,'TimeValues')
            if~iscell(timeData)

                inputs{end+1}=timeData;
            else
                isCellOfCell=all(cellfun(@iscell,timeData));





                if isCellOfCell
                    timeData=cellfun(@(x)x{1},timeData,'UniformOutput',false);
                end

                numPoints=cellfun(@numel,timeData);
                if numel(unique(numPoints))==1



                    equalTimeFlag=saUtil.verifyEqualTimeValues(this,varInfo.signalID);
                    if equalTimeFlag
                        inputs{end+1}=timeData{1};
                    else
                        inputs{end+1}=timeData;
                    end
                else
                    inputs{end+1}=timeData;
                end
            end
        else
            if iscell(timeData)
                isCellOfCell=all(cellfun(@iscell,timeData));





                if isCellOfCell
                    timeData=cellfun(@(x)x{1},timeData,'UniformOutput',false);
                end
                matrixTimeData=cell2mat(timeData);
                if numel(unique(matrixTimeData))==1
                    inputs{end+1}=matrixTimeData(1);
                else
                    inputs{end+1}=matrixTimeData;
                end
            else
                inputs{end+1}=timeData;
            end
        end
    end


    if~isempty(mNames)
        inputs{end+1}='MemberNames';
        inputs{end+1}=string(mNames);
    end

    data=labeledSignalSet(inputs{:});

end

function[childData,timeMode,timeData,mNames]=getChildLSSData(this,varInfo)

    saUtil=Simulink.sdi.Instance.getSetSAUtils();
    if~isempty(varInfo.Children)
        if all([varInfo.Children.isTT])

            childData=exportToTimetable(this,varInfo);
            timeMode={};
            timeData={};
            mNames={};
        elseif all([varInfo.Children.isMatrix])



            for child_idx=1:length(varInfo.Children)
                dataValues=this.getSignalObject(varInfo.Children(child_idx).signalID).Values;
                data(:,child_idx)=dataValues.Data;%#ok<AGROW>
            end
            childData=data;



            childTmMode=saUtil.getTmModeLabeledSignalSet(this,varInfo.Children(child_idx).signalID);
            switch childTmMode
            case 'fs'
                timeMode='SampleRate';
                timeData=this.getSignalTmSampleRate(varInfo.Children(child_idx).signalID);
            case 'ts'
                timeMode='SampleTime';
                timeData=this.getSignalTmSampleTime(varInfo.Children(child_idx).signalID);
            case 'tv'
                timeMode='TimeValues';
                timeData=seconds(dataValues.Time);
            otherwise
                timeMode={};
                timeData={};
            end

            mNames={};
        else

            childData=cell(1,length(varInfo.Children));
            timeData=cell(1,length(varInfo.Children));
            mNames=cell(1,length(varInfo.Children));
            for child_idx=1:length(varInfo.Children)
                [childData{child_idx},timeMode,timeData{child_idx},~]=getChildLSSData(this,varInfo.Children(child_idx));
                mNames{child_idx}=Simulink.sdi.internal.signalanalyzer.Utilities.convertToValidMemberName(this.getSignalName(varInfo.Children(child_idx).signalID));
            end
        end
    else

        dataValues=this.getSignalObject(varInfo.signalID).Values;
        childData=dataValues.Data;
        childTmMode=saUtil.getTmModeLabeledSignalSet(this,varInfo.signalID);
        switch childTmMode
        case 'fs'
            timeMode='SampleRate';
            timeData=this.getSignalTmSampleRate(varInfo.signalID);
        case 'ts'
            timeMode='SampleTime';
            timeData=this.getSignalTmSampleTime(varInfo.signalID);
        case 'tv'
            timeMode='TimeValues';
            timeData=seconds(dataValues.Time);
        otherwise
            timeMode={};
            timeData={};
        end
        mNames={};
    end

end

