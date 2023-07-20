function out=simdatainfohandler(action,varargin)











    out={action};

    switch(action)
    case 'getDataInfoForSimData'
        out=getDataInfoForSimData(varargin{:});
    case 'usedSliders'
        out=usedSliders(varargin{:});
    end

end

function dataInfo=getDataInfoForSimData(simdata,associatedData)

    [associatedDataSources,scalarParameters]=getParameterVariableInfoForSimData(associatedData);
    sliderParameters=getSliderParameterVariableInfoForSimData(simdata);
    scalarParameters=[scalarParameters,sliderParameters];

    dataInfo=struct('associatedDataSources',associatedDataSources,...
    'scalarParameters',scalarParameters);

end

function[associatedDataSources,scalarParameters]=getParameterVariableInfoForSimData(associatedData)
    samplesVariable='samples';
    associatedDataSources=SimBiology.internal.plotting.data.DataSource.empty;
    scalarParameters=SimBiology.internal.plotting.categorization.ScalarParameter.empty;
    groupParameters=SimBiology.internal.plotting.categorization.ScalarParameter.empty;

    if~isempty(associatedData)&&isfield(associatedData,samplesVariable)

        samples=associatedData.(samplesVariable);
        samplesTable=samples.generate;
        numParams=size(samplesTable,2);
        scalarParameters(numParams,1)=SimBiology.internal.plotting.categorization.ScalarParameter;


        associatedDataSourcesMap=containers.Map;

        type=SimBiology.internal.plotting.categorization.CategoryVariable.PARAM;
        for p=1:numParams

            name=samplesTable.Properties.VariableNames{p};
            associatedDataSource=SimBiology.internal.plotting.data.DataSource.empty;
            sampleValues=samplesTable{:,p};





            paramClass=class(samplesTable{1,p});
            switch paramClass
            case 'double'
                subtype=SimBiology.internal.plotting.categorization.CategoryVariable.QUANTITY;
                values=SimBiology.internal.plotting.categorization.binvalue.NumericBinValue(sampleValues);
                binValues=SimBiology.internal.plotting.categorization.binvalue.NumericBinValue(unique(sampleValues,'stable'));
            case 'SimBiology.Variant'
                if isfield(sampleValues(1).UserData,'dataSource')&&~isempty(sampleValues(1).UserData.dataSource)
                    associatedDataSource=SimBiology.internal.plotting.data.DataSource(sampleValues(1).UserData.dataSource);
                end
                subtype=SimBiology.internal.plotting.categorization.CategoryVariable.VARIANT;
                values=SimBiology.internal.plotting.categorization.binvalue.VariantBinValue(sampleValues);
                binValues=SimBiology.internal.plotting.categorization.binvalue.VariantBinValue(unique(sampleValues,'stable'));
            case{'SimBiology.RepeatDose','SimBiology.ScheduleDose'}
                if isfield(sampleValues(1).UserData,'dataSource')&&~isempty(sampleValues(1).UserData.dataSource)
                    associatedDataSource=SimBiology.internal.plotting.data.DataSource(sampleValues(1).UserData.dataSource);
                end
                subtype=SimBiology.internal.plotting.categorization.CategoryVariable.DOSE;
                values=SimBiology.internal.plotting.categorization.binvalue.DoseBinValue(sampleValues);
                binValues=SimBiology.internal.plotting.categorization.binvalue.DoseBinValue(unique(sampleValues,'stable'));
            otherwise

                type='other';
            end

            if~isempty(associatedDataSource)&&~associatedDataSourcesMap.isKey(associatedDataSource)
                groupParameters=vertcat(groupParameters,createAssociatedGroupScalarParameter(associatedDataSource,sampleValues));
            end


            categoryVariable=struct;
            categoryVariable.name=name;
            categoryVariable.type=type;
            categoryVariable.subtype=subtype;
            categoryVariable.associatedDataSource=associatedDataSource;
            categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(categoryVariable);
            scalarParameters(p)=SimBiology.internal.plotting.categorization.ScalarParameter(categoryVariable,binValues,values);


            if~isempty(associatedDataSource)
                associatedDataSourcesMap(associatedDataSource.getName)=associatedDataSource;
            end
        end

        scalarParameters=vertcat(groupParameters,scalarParameters);


        if(associatedDataSourcesMap.Count>0)
            associatedDataSources=associatedDataSourcesMap.values;
            associatedDataSources=[associatedDataSources{:}];
        end
    end

end

function sliderParameter=getSliderParameterVariableInfoForSimData(simdata)
    numRuns=numel(simdata);
    binValues(numRuns,1)=SimBiology.internal.plotting.categorization.binvalue.VariantBinValue;
    hasSliderVariant=false;
    for i=1:numRuns
        sd=simdata(i);
        variants=sd.RunInfo.Variant;
        idx=arrayfun(@(v)strcmp(v.Name,'sliders'),variants);
        sliderVariant=variants(idx);
        if~isempty(sliderVariant)&&~isempty(sliderVariant.Content)
            hasSliderVariant=true;
            variantContent=SimBiology.internal.plotting.categorization.binvalue.VariantContent(sliderVariant.Content);
            binValues(i)=SimBiology.internal.plotting.categorization.binvalue.VariantBinValue(struct('value',sliderVariant.Name,...
            'content',variantContent,...
            'index',i,...
            'info',struct));
        else
            binValues(i).value='sliders';
            binValues(i).index=i;
        end
    end
    if hasSliderVariant
        categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(SimBiology.internal.plotting.categorization.CategoryVariable.PARAM);
        categoryVariable.name='Slider Variant';
        categoryVariable.associatedDataSource=[];

        sliderParameter=SimBiology.internal.plotting.categorization.ScalarParameter(categoryVariable,binValues,binValues);
    else
        sliderParameter=[];
    end

end

function flag=usedSliders(simDataArray)
    flag=false;
    for i=1:numel(simDataArray)
        variants=simDataArray(i).RunInfo.Variant;
        if any(arrayfun(@(v)strcmp(v.Name,'sliders'),variants))
            flag=true;
            break;
        end
    end

end

function scalarParameter=createAssociatedGroupScalarParameter(associatedDataSource,sampleValues)
    categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(SimBiology.internal.plotting.categorization.CategoryVariable.ASSOCIATED_GROUP);
    categoryVariable.associatedDataSource=associatedDataSource;

    if isa(sampleValues,'SimBiology.Object')&&isstruct(sampleValues(1).UserData)&&isfield(sampleValues(1).UserData,'group')
        values=arrayfun(@(sample)sample.UserData.group,sampleValues);
    else
        values=SimBiology.internal.plotting.categorization.binvalue.GroupBinValue(arrayfun(@(sample)sample.UserData.value,sampleValues,'UniformOutput',false));
        set(values.dataSource,SimBiology.internal.plotting.data.DataSource(sampleValues(1).UserData.dataSource));
    end



    categoricalValues=categorical(arrayfun(@(value)value.value,values,'UniformOutput',false));
    [~,idx]=unique(categoricalValues,'stable');
    scalarParameter=SimBiology.internal.plotting.categorization.ScalarParameter(categoryVariable,values(idx),values);

end
