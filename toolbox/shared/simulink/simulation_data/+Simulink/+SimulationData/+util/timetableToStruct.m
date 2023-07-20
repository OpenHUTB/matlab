function st=timetableToStruct(tt)






    if~isa(tt.Properties.RowTimes,'duration')
        st.Data=[];
        st.NumSampleDims=[];
        st.SampleDims=[];
        st.NumVars=[];
        st.Time=[];
        st.IsDuration=false;
        return;
    end

    st.IsDuration=true;
    varNames=tt.Properties.VariableNames{1};
    if ischar(tt.(varNames))

        tt.(varNames)=string(tt.(varNames));
    end
    ttSize=size(tt.(varNames));
    iswide=isstruct(tt.Properties.UserData)&&...
    isfield(tt.Properties.UserData,'AppData')&&...
    isfield(tt.Properties.UserData.AppData,'IsSimulinkWideSignal')&&...
    isequal(tt.Properties.UserData.AppData.IsSimulinkWideSignal,true);


    if isequal(numel(ttSize),2)&&isequal(ttSize(2),1)

        st.Data=tt.(varNames);
        st.NumSampleDims=1;
        st.SampleDims=1;
    elseif iswide

        st.Data=tt.(varNames);
        st.NumSampleDims=1;
        st.SampleDims=ttSize(2);
    elseif isequal(numel(ttSize),2)&&...
        isequal(numel(tt.Properties.RowTimes),1)&&...
        isa(tt.(varNames),'string')




        st.Data=tt.(varNames);
        st.NumSampleDims=1;
        st.SampleDims=ttSize;
    elseif isequal(numel(ttSize),2)

        st.Data=reshape(tt.(varNames).',[ttSize(2),1,ttSize(1)]);
        st.NumSampleDims=2;
        st.SampleDims=[ttSize(2),1];
    else

        assert(numel(ttSize)>2)
        st.Data=permute(tt.(varNames),[2:numel(ttSize),1]);
        st.NumSampleDims=numel(ttSize)-1;
        st.SampleDims=ttSize(2:end);
    end

    st.Time=seconds(tt.Properties.RowTimes);
    st.NumSampleDims=uint32(st.NumSampleDims);
    st.SampleDims=uint32(st.SampleDims);
    st.NumVars=uint32(numel(tt.Properties.VariableNames));
end
