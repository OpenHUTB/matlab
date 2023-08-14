


classdef SmartStyle<ModelAdvisor.Report.CheckStyleFactory
    methods
        function obj=SmartStyle
            obj.Name=getString(message('ModelAdvisor:engine:RecommendedAction'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            elementsObj=CheckObj.ResultDetails;
            fts=local_sortObjs(elementsObj,'RecommendedAction');
            fts=ModelAdvisor.Report.Utils.removeTrailingSubbar(fts);
            html=fts;
        end

    end
end

function fts=local_sortObjs(elementsObj,sortMethod)
    fts=[];





    cfgIndex=[elementsObj.Type]==ModelAdvisor.ResultDetailType.ConfigurationParameter;
    if iscolumn(cfgIndex)
        cfgIndex=cfgIndex';
    end


    blkIndex=[elementsObj.Type]==ModelAdvisor.ResultDetailType.BlockParameter;
    if iscolumn(blkIndex)
        blkIndex=blkIndex';
    end

    grpIndex=[elementsObj.Type]==ModelAdvisor.ResultDetailType.Group;
    if iscolumn(grpIndex)
        grpIndex=grpIndex';
    end

    customIndex=[elementsObj.Type]==ModelAdvisor.ResultDetailType.Custom;
    if iscolumn(customIndex)
        customIndex=customIndex';
    end

    expIndex=arrayfun(@(x)(x.Type==ModelAdvisor.ResultDetailType.SID||x.Type==ModelAdvisor.ResultDetailType.Mfile)&&(~isempty(x.DetailedInfo)&&~isempty(x.DetailedInfo.Expression)),elementsObj);
    if iscolumn(expIndex)
        expIndex=expIndex';
    end

    tableIndex=strcmp({elementsObj.Format},'Table');
    TableObjs=elementsObj(tableIndex);


    CfgParamObjs=elementsObj(cfgIndex);
    BlkParamObjs=elementsObj(blkIndex);
    expObjs=elementsObj(expIndex);
    GrpObjs=elementsObj(grpIndex);
    customObjs=elementsObj(customIndex);


    OtherObjs=elementsObj(~(cfgIndex|blkIndex|reshape(expIndex,1,[])|grpIndex|tableIndex|customIndex));

    if~isempty(TableObjs)
        fts=[fts,ModelAdvisor.Report.Utils.sortObjs(TableObjs,'Subsystem',false)];
    end

    if~isempty(CfgParamObjs)
        fts=[fts,ModelAdvisor.Report.ConfigurationParameterStyle.sort(CfgParamObjs,sortMethod)];
    end

    if~isempty(BlkParamObjs)
        fts=[fts,ModelAdvisor.Report.BlockParameterStyle.sort(BlkParamObjs,sortMethod)];
    end

    if~isempty(GrpObjs)
        fts=[fts,ModelAdvisor.Report.GroupStyle.sort(GrpObjs,sortMethod)];
    end


    if~isempty(customObjs)
        fts=[fts,ModelAdvisor.Report.TableStyle.sort(customObjs,sortMethod)];
    end

    if~isempty(expObjs)
        fts=[fts,ModelAdvisor.Report.ExpressionStyle.sort(expObjs,sortMethod)];
    end

    if~isempty(OtherObjs)
        fts=[fts,ModelAdvisor.Report.Utils.sortObjs(OtherObjs,'RecommendedAction',false)];
    end

    fts=ModelAdvisor.Report.Utils.removeTrailingSubbar(fts);

end
