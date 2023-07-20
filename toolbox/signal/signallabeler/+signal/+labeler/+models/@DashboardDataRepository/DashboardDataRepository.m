classdef DashboardDataRepository<handle




    properties(Hidden)
IsAllMembersSelected
SelectedMemberIDs
ContinuousTimeDistributionBins
    end

    properties(Access=private)
LabelerModel
    end

    properties(Constant,Access='private')
        pPlotParameterList=[...
        "plotVariant",...
        "countLowerThreshold",...
        "numXBins",...
        "minXHardValue",...
        "maxXHardValue",...
        "numYBins",...
        "minYHardValue",...
        "maxYHardValue",...
        "showOutliers"];

        pValidPlotTypeList=[...
        "progress",...
        "valueDistribution",...
        "timeDistribution",...
        "memberCountPerNumInstances"];
    end

    methods(Static)
        function ret=getModel()

            persistent modelObj;
            mlock;
            if isempty(modelObj)||~isvalid(modelObj)
                labelerModelObj=signal.labeler.models.LabelDataRepository.getModel();
                modelObj=signal.labeler.models.DashboardDataRepository(labelerModelObj);
            end


            ret=modelObj;
        end
    end



    methods(Access=protected)
        function this=DashboardDataRepository(labelerModelObj)

            this.LabelerModel=labelerModelObj;
            this.resetModel();
        end
    end

    methods
        function resetModel(this)
            this.IsAllMembersSelected=true;
            this.SelectedMemberIDs=[];
            this.ContinuousTimeDistributionBins=true;
            this.deleteAllPlots();
        end

        function labelerModel=getLabelerModel(this)
            labelerModel=this.LabelerModel;
        end

        function setAppName(this,AppName)
            this.getLabelerModel.setAppName(AppName);
        end

        function memberIDs=getMemberIDs(this)
            if this.IsAllMembersSelected
                lblMdl=getLabelerModel(this);
                memberIDs=getMemberIDs(lblMdl);
            else
                memberIDs=this.SelectedMemberIDs;
            end
        end




        function outData=getLabelDefinitionsDataForDropDown(this)

            lblMdl=getLabelerModel(this);

            lblDefIDs=lblMdl.getAllParentLabelDefinitionIDs();
            N=numel(lblDefIDs);
            outData=[];
            for idx=1:N
                lblDef=lblMdl.getLabelDefFromLabelDefID(lblDefIDs(idx));
                if~lblDef.isFeature
                    outData=[outData;struct(...
                    'labelDefinitionID',lblDefIDs(idx),...
                    'LabelName',string(lblDef.labelDefinitionName),...
                    'LabelType',string(lblDef.labelType),...
                    'LabelDataType',string(lblDef.labelDataType),...
                    'Description',string(lblDef.description))];
                end
            end
        end



        function[plotID,p]=addPlot(this,lblDefID,plotType,plotParams)



            validatestring(plotType,this.pValidPlotTypeList);
            plotDataForMF0=createDahsboardPlotStruct(this,lblDefID,plotType);

            lblMdl=getLabelerModel(this);
            lblMdl.Mf0LabelDataRepository.createIntoDashboardPlots(plotDataForMF0);
            plotID=plotDataForMF0.plotID;

            if nargin<4
                plotParams=plotDataForMF0;
            end

            if nargout==1
                updatePlot(this,plotID,plotParams,true);
            else
                p=updatePlot(this,plotID,plotParams,true);
            end
        end

        function p=updatePlot(this,plotID,plotParams,forceUpdate)








            if nargin<4
                forceUpdate=false;
            end
            dPlotObj=getDashboardPlotFromPlotID(this,plotID);

            changeFlag=false;
            if isempty(plotParams)
                forceUpdate=true;
            else
                changeFlag=updatePlotParams(this,dPlotObj,plotParams);
            end

            p=[];
            if nargout>0&&(changeFlag||forceUpdate)
                switch dPlotObj.plotType
                case "progress"
                    p=computeProgress(this,plotID);
                case "valueDistribution"
                    p=computeLabelValueDistribution(this,plotID);
                case "timeDistribution"
                    p=computeLabelTimeDistribution(this,plotID);
                case "memberCountPerNumInstances"
                    p=computeNumMembersPerNumInstances(this,plotID);
                end
            end
        end

        function deletePlot(this,plotID)
            dPlotObj=getDashboardPlotFromPlotID(this,plotID);
            dPlotObj.destroy();
        end

        function[s,labelDefID,listOfActivePlotNamesForLabelDefID]=getPlotParams(this,plotID)
            dPlotObj=getDashboardPlotFromPlotID(this,plotID);
            if isvalid(dPlotObj)
                s=getPlotParamsStruct(this,dPlotObj);
                labelDefID=string(dPlotObj.labelDefinitionID);
                listOfActivePlotNamesForLabelDefID=getActivePlotTypesForLabelDefinitionID(this,labelDefID);
            else
                s=struct.empty;
                labelDefID=string.empty;
                listOfActivePlotNamesForLabelDefID=string.empty;
            end
        end

        function plots=getActivePlotTypesForLabelDefinitionID(this,lblDefID)
            plotIDs=getAllDahsboardPlotIDsForLabelDefinitionID(this,lblDefID);
            plots=[];
            for idx=1:numel(plotIDs)
                plotObj=getDashboardPlotFromPlotID(this,plotIDs(idx));
                plots=[plots;string(plotObj.plotType)];%#ok<AGROW>
            end

            plots=sort(plots);
        end

        function plotIDs=deletePlotsForLabelDefinitionID(this,lblDefID)

            plotIDs=getAllDahsboardPlotIDsForLabelDefinitionID(this,lblDefID);
            for idx=1:numel(plotIDs)
                plotObj=getDashboardPlotFromPlotID(this,plotIDs(idx));
                plotObj.destroy();
            end
        end

        function plotIDs=deleteAllPlots(this)

            plotIDs=getAllDashboardPlotIDs(this);
            for idx=1:numel(plotIDs)
                plotObj=getDashboardPlotFromPlotID(this,plotIDs(idx));
                plotObj.destroy();
            end
        end




        function p=computeProgress(this,plotID)

            dashboardPlotObj=getDashboardPlotFromPlotID(this,plotID);
            memberIDs=getMemberIDs(this);
            labelDefID=dashboardPlotObj.labelDefinitionID;

            lblMdl=getLabelerModel(this);

            lblDef=getLabelDefFromLabelDefID(lblMdl,labelDefID);

            if lblDef.labelType=="attribute"

                if this.IsAllMembersSelected
                    unlabeledCount=signallabelereng.datamodel.getUnlabeledMemberCountForAttrAllMembers(...
                    lblMdl.Mf0DataModel,labelDefID);
                else
                    unlabeledCount=signallabelereng.datamodel.getUnlabeledMemberCountForAttrSomeMembers(...
                    lblMdl.Mf0DataModel,labelDefID,string(memberIDs));
                end
                labeledCount=numel(memberIDs)-unlabeledCount;
                p.Labeled=labeledCount;
                p.Unlabeled=unlabeledCount;
            else


                labeledCount=signallabelereng.datamodel.getLabeledMemberCountForROIPoint(...
                lblMdl.Mf0DataModel,labelDefID,string(memberIDs),dashboardPlotObj.countLowerThreshold);
                unlabeledCount=numel(memberIDs)-labeledCount;
                p.Labeled=labeledCount;
                p.Unlabeled=unlabeledCount;
            end
        end

        function p=computeLabelValueDistribution(this,plotID)



            dashboardPlotObj=getDashboardPlotFromPlotID(this,plotID);

            memberIDs=getMemberIDs(this);
            labelDefID=dashboardPlotObj.labelDefinitionID;
            lblMdl=getLabelerModel(this);
            lblDef=getLabelDefFromLabelDefID(lblMdl,labelDefID);

            if lblDef.labelDataType=="numeric"

                numBins=dashboardPlotObj.numXBins;
                minValue=dashboardPlotObj.minXHardValue;
                maxValue=dashboardPlotObj.maxXHardValue;
                if this.IsAllMembersSelected
                    [binCounts,binEdges]=signallabelereng.datamodel.getNumLabelValueDistributionAllMembers(...
                    lblMdl.Mf0DataModel,labelDefID,numBins,minValue,maxValue);
                else
                    [binCounts,binEdges]=signallabelereng.datamodel.getNumLabelValueDistributionSomeMembers(...
                    lblMdl.Mf0DataModel,labelDefID,string(memberIDs),numBins,minValue,maxValue);
                end

                p.BinCounts=binCounts;
                p.BinEdges=binEdges;
            else

                if this.IsAllMembersSelected
                    [countPerCategory,foundCats]=signallabelereng.datamodel.getCatLabelValueDistributionAllMembers(...
                    lblMdl.Mf0DataModel,labelDefID);
                else
                    [countPerCategory,foundCats]=signallabelereng.datamodel.getCatLabelValueDistributionSomeMembers(...
                    lblMdl.Mf0DataModel,labelDefID,string(memberIDs));
                end
                foundCats=formatToString(this,foundCats);


                cats=getAprioriCats(this,lblDef);
                if~isempty(cats)








                    countPerAllCategories=zeros(numel(cats),1);
                    [~,idx1,idx2]=intersect(cats,foundCats,'stable');
                    countPerAllCategories(idx1)=countPerCategory(idx2);
                    countPerAllCategories(end+1)=countPerCategory(end);
                    p.Counts=countPerAllCategories;
                    p.Cats=[cats;""];
                else
                    p.Counts=countPerCategory;
                    p.Cats=[foundCats;""];
                end
            end
        end

        function p=computeLabelTimeDistribution(this,plotID)





            memberIDs=getMemberIDs(this);
            dashboardPlotObj=getDashboardPlotFromPlotID(this,plotID);
            labelDefID=dashboardPlotObj.labelDefinitionID;
            lblMdl=getLabelerModel(this);
            lblDef=getLabelDefFromLabelDefID(lblMdl,labelDefID);

            lblDataType=lblDef.labelDataType;
            isLblDataTypeDiscrete=lblDataType~="numeric";

            if isLblDataTypeDiscrete

                if this.IsAllMembersSelected
                    [meanValues,stdValues,minValues,maxValues,med,q25,q75,foundCats,outlierCounts,...
                    outlierValues]=signallabelereng.datamodel.getCatLabelTimeDistributionAllMembers(...
                    lblMdl.Mf0DataModel,labelDefID,lblDef.labelType);

                else
                    [meanValues,stdValues,minValues,maxValues,med,q25,q75,foundCats]=...
                    signallabelereng.datamodel.getCatLabelTimeDistributionSomeMembers(...
                    lblMdl.Mf0DataModel,labelDefID,string(memberIDs),lblDef.labelType);
                end
                foundCats=formatToString(this,foundCats);




                catsWithoutInstances=string.empty(0,1);
                cats=getAprioriCats(this,lblDef);
                if~isempty(cats)
                    catsWithoutInstances=setdiff(cats,foundCats);
                end



                outliers=cell(numel(outlierCounts),1);
                outlierSum=cumsum(outlierCounts);
                for i=1:numel(outlierSum)
                    if(i==1)
                        outliers{i}=outlierValues(1:outlierSum(i));
                    else
                        if(outlierSum(i-1)~=0)
                            outliers{i}=outlierValues((outlierSum(i-1)+1):outlierSum(i));
                        else
                            outliers{i}=outlierValues(1:outlierSum(i));
                        end
                    end
                end

                p.Mean=meanValues;
                p.STD=stdValues;
                p.Min=minValues;
                p.Max=maxValues;
                p.Cats=foundCats;
                p.Med=med;
                p.Q25=q25;
                p.Q75=q75;
                p.CatsWithoutInstances=catsWithoutInstances;
                p.Outliers=outliers;
            else




                numBins=dashboardPlotObj.numXBins;
                minValue=dashboardPlotObj.minXHardValue;
                maxValue=dashboardPlotObj.maxXHardValue;

                if this.IsAllMembersSelected
                    [binCounts,binEdges]=...
                    signallabelereng.datamodel.getNumLabelTimeDistributionAllMembers(...
                    lblMdl.Mf0DataModel,labelDefID,lblDef.labelType,...
                    numBins,minValue,maxValue,this.ContinuousTimeDistributionBins);

                else
                    [binCounts,binEdges]=...
                    signallabelereng.datamodel.getNumLabelTimeDistributionSomeMembers(...
                    lblMdl.Mf0DataModel,labelDefID,string(memberIDs),lblDef.labelType,...
                    numBins,minValue,maxValue,this.ContinuousTimeDistributionBins);
                end

                p.BinCounts=binCounts;
                p.BinEdges=binEdges;
            end
        end

        function p=computeNumMembersPerNumInstances(this,plotID)






            memberIDs=getMemberIDs(this);
            dashboardPlotObj=getDashboardPlotFromPlotID(this,plotID);
            labelDefID=dashboardPlotObj.labelDefinitionID;
            lblMdl=getLabelerModel(this);
            lblDef=getLabelDefFromLabelDefID(lblMdl,labelDefID);

            lblDataType=lblDef.labelDataType;
            isLblDataTypeDiscrete=lblDataType~="numeric";

            numXBins=dashboardPlotObj.numXBins;
            minXValue=dashboardPlotObj.minXHardValue;
            maxXValue=dashboardPlotObj.maxXHardValue;

            if isLblDataTypeDiscrete




                cats=getAprioriCats(this,lblDef);






                [memberCountsPerCat,binEdges,foundCats]=...
                signallabelereng.datamodel.getCatLabelNumMembersPerNumInstances(...
                lblMdl.Mf0DataModel,labelDefID,string(memberIDs),cats,numXBins,minXValue,maxXValue);









                p.FoundCats=formatToString(this,foundCats);
                p.BinXEdges=binEdges;
                if isempty(memberCountsPerCat)
                    p.MemberCounts=memberCountsPerCat;
                else
                    p.MemberCounts=reshape(memberCountsPerCat(:),numel(binEdges)-1,numel(p.FoundCats));
                end
            else
                numYBins=dashboardPlotObj.numYBins;
                minYValue=dashboardPlotObj.minYHardValue;
                maxYValue=dashboardPlotObj.maxYHardValue;

                if this.IsAllMembersSelected
                    [memberCounts,binXEdges,binYEdges]=...
                    signallabelereng.datamodel.getNumLabelNumMembersPerNumInstancesAllMembers(...
                    lblMdl.Mf0DataModel,labelDefID,string(memberIDs),numXBins,minXValue,maxXValue,...
                    numYBins,minYValue,maxYValue);
                else
                    [memberCounts,binXEdges,binYEdges]=...
                    signallabelereng.datamodel.getNumLabelNumMembersPerNumInstancesSomeMembers(...
                    lblMdl.Mf0DataModel,labelDefID,string(memberIDs),numXBins,minXValue,maxXValue,...
                    numYBins,minYValue,maxYValue);
                end

                p.BinXEdges=binXEdges;
                p.BinYEdges=binYEdges;
                if isempty(memberCounts)
                    p.MemberCounts=memberCounts;
                else
                    p.MemberCounts=reshape(memberCounts(:),numel(binXEdges)-1,numel(binYEdges)-1);
                end
            end
        end



        function s=createDahsboardPlotStruct(~,lblDefID,plotType)
            s=struct(...
            'plotID',string(lblDefID)+"_"+string(plotType),...
            'labelDefinitionID',lblDefID,...
            'plotType',plotType,...
            'plotVariant',"",...
            'countLowerThreshold',1,...
            'numXBins',-1,...
            'minXHardValue',-inf,...
            'maxXHardValue',inf,...
            'numYBins',-1,...
            'minYHardValue',-inf,...
            'maxYHardValue',inf,...
            'showOutliers',1);
        end

        function changeFlag=updatePlotParams(this,dashboardPlotObj,plotParams)
            changeFlag=false;
            fn=string(fieldnames(plotParams));
            for idx=1:numel(fn)
                if~ismember(fn(idx),this.pPlotParameterList)
                    continue;
                end


                if plotParams.(fn(idx))~=dashboardPlotObj.(fn(idx))
                    changeFlag=true;

                    if(strcmp(plotParams.(fn(idx)),'inf'))
                        dashboardPlotObj.(fn(idx))=inf;
                    elseif(strcmp(plotParams.(fn(idx)),'-inf'))
                        dashboardPlotObj.(fn(idx))=-inf;
                    else
                        dashboardPlotObj.(fn(idx))=plotParams.(fn(idx));
                    end
                end
            end
        end

        function createDashboardPlotMf0Model(this,plotDataForMF0)
            lblMdl=getLabelerModel(this);
            lblMdl.Mf0LabelDataRepository.createIntoLabelInstances(plotDataForMF0);
        end

        function dPlotObj=getDashboardPlotFromPlotID(this,plotID)
            lblMdl=getLabelerModel(this);
            dPlotObj=lblMdl.Mf0LabelDataRepository.dashboardPlots.getByKey(plotID);
        end

        function plotIDs=getAllDahsboardPlotIDsForLabelDefinitionID(this,labelDefID)
            lblMdl=getLabelerModel(this);
            plotIDs=signallabelereng.datamodel.getAllDahsboardPlotIDsForLabelDefinitionID(lblMdl.Mf0DataModel,labelDefID);
            plotIDs=formatToString(this,plotIDs);
        end

        function plotIDs=getAllDashboardPlotIDs(this)
            lblMdl=getLabelerModel(this);
            labelDefIDs=lblMdl.getAllParentLabelDefinitionIDs();
            plotIDs=[];
            for idx=1:numel(labelDefIDs)
                newPlotIDs=getAllDahsboardPlotIDsForLabelDefinitionID(this,labelDefIDs(idx));
                plotIDs=[plotIDs;newPlotIDs];%#ok<AGROW>
            end
        end

        function s=getPlotParamsStruct(this,plotObj)
            s=struct;
            fn=this.pPlotParameterList;

            for idx=1:numel(fn)
                s.(fn(idx))=plotObj.(fn(idx));
            end
        end

        function labelDefID=getLabelDefinitionForPlotID(this,plotID)
            dPlotObj=getDashboardPlotFromPlotID(this,plotID);
            labelDefID=formatToString(this,dPlotObj.labelDefinitionID);
        end

        function s=formatToString(~,input)
            if isempty(input)
                s=string.empty(0,1);
            else
                s=deblank(string(input));
            end
        end

        function cats=getAprioriCats(~,lblDef)


            cats=string.empty;
            if lblDef.labelDataType=="categorical"||lblDef.labelDataType=="logical"
                if lblDef.labelDataType=="categorical"
                    cats=string(lblDef.categories);
                    cats=cats(:);
                else
                    cats=["false","true"]';
                end
            end
        end
    end
end