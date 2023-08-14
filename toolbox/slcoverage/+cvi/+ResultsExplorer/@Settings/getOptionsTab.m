function panel=getOptionsTab(obj,~)

    options=obj.resultsExplorer.getOptions;

    panel.Items={cumulativeOptionsPanel(obj,options),htmlOptionsPanel(obj,getHtmlOptionsName(options))};
    panel.LayoutGrid=[5,1];
    panel.RowStretch=[0,0,0,0,1];
    panel.Type='panel';





end

function panel=htmlOptionsPanel(obj,htmlOptions)

    panel.Type='group';
    panel.Items={};
    allFieldNames=fields(htmlOptions.value);
    for idx=1:numel(allFieldNames)
        fieldName=allFieldNames{idx};

        chb.Name=htmlOptions.text.(fieldName);
        chb.Type='checkbox';
        chb.Source=obj;
        chb.Value=htmlOptions.value.(fieldName);
        chb.MatlabMethod='optionsChangeCallback';
        chb.MatlabArgs={obj,'%value',fieldName};
        chb.Tag=fieldName;

        if isempty(panel.Items)
            panel.Items={chb};
        else
            panel.Items{end+1}=chb;
        end
    end
    panel.RowSpan=[4,4];
    panel.ColSpan=[1,1];
    panel.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:HtmlOptions'));

end



function panel=cumulativeOptionsPanel(obj,options)

    chb.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:EnableCumData'));
    chb.Type='checkbox';
    chb.Value=options.enableCumulative;
    chb.Tag='enableCumulative';
    chb.MatlabMethod='optionsChangeCallback';
    chb.MatlabArgs={obj,'%value','enableCumulative'};

    chb1.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:ShowProgressReport'));
    chb1.Type='checkbox';
    chb1.Value=options.covCumulativeReport;
    chb1.Tag='cumulativeReport';
    chb1.MatlabMethod='optionsChangeCallback';
    chb1.MatlabArgs={obj,'%value','covCumulativeReport'};

    panel.Items={chb,chb1};
    panel.RowSpan=[3,3];
    panel.ColSpan=[1,1];
    panel.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:CumulativeMode'));
    panel.Type='group';

end



function htmlOptions=getHtmlOptionsName(options)
    htmlOptions=[];
    optionTable=cvi.ReportUtils.getOptionsTable;
    [m,~]=size(optionTable);
    for idx=1:m
        fieldName=optionTable{idx,2};
        text=optionTable{idx,1};
        htmlOptions.value.(fieldName)=options.(fieldName);
        htmlOptions.text.(fieldName)=text;
    end
end

