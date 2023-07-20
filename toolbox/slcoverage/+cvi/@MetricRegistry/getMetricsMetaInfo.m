










function metricData=getMetricsMetaInfo

    data=cvi.MetricRegistry.getMetricDescrTable;
    metricData=[];
    allUiMetricNames=cvi.MetricRegistry.getAllSettingsMetricNames();
    for idx=1:numel(allUiMetricNames)
        cfn=allUiMetricNames{idx};
        st=[];
        st.dialogLabel=data.(cfn){1};
        st.cvtestFieldName=data.(cfn){3};
        st.accessCommand=data.(cfn){6};
        st.metricSetting=data.(cfn){2};
        st.gridRow=data.(cfn){7};
        st.gridColumn=data.(cfn){8};
        if isempty(metricData)
            metricData=st;
        else
            metricData(end+1)=st;%#ok<AGROW>
        end
    end

