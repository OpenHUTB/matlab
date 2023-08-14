function data=exportToTimetable(this,varInfo)


    [childData,childTime,childVarNames]=getChildTimetableData(this,varInfo);

    inputs={};
    inputs{end+1}=childTime;
    inputs=[inputs,childData];
    inputs{end+1}='VariableNames';
    inputs{end+1}=childVarNames;
    data=timetable(inputs{:});
end

function[childData,childTime,childVarNames]=getChildTimetableData(this,varInfo)



    if~isempty(varInfo.Children)
        if all([varInfo.Children.isMatrix])



            for child_idx=1:length(varInfo.Children)
                dataValues=this.getSignalObject(varInfo.Children(child_idx).signalID).Values;
                data(:,child_idx)=dataValues.Data;%#ok<AGROW>
                childTime=seconds(dataValues.Time);
            end
            childData={data};


            childVarNames={varInfo.colName};
        else

            childData=cell(1,length(varInfo.Children));
            childVarNames=cell(1,length(varInfo.Children));
            for child_idx=1:length(varInfo.Children)
                [childData(child_idx),childTime,childVarNames(child_idx)]=getChildTimetableData(this,varInfo.Children(child_idx));
            end
        end
    else

        dataValues=this.getSignalObject(varInfo.signalID).Values;
        childData={dataValues.Data};
        childTime=seconds(dataValues.Time);


        childVarNames={varInfo.colName};
    end
end