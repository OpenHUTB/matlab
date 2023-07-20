classdef SBioCategoricalPlot<SimBiology.internal.plotting.sbioplot.SBioPlotObject




    methods(Access=public)
        function reset(obj)
            obj.setCategories(SimBiology.internal.plotting.categorization.CategoryDefinition.empty);
        end
    end

    methods(Access=protected)
        function setCategories(obj,categories)
            obj.definition.props.Categories=categories;
        end

        function plotArguments=getArgumentsToPlot(obj)


            plotArguments=obj.getPlotArguments();
        end
    end

    methods(Access=public)
        function categoryObjects=getCategories(obj)
            categoryObjects=obj.getProps().Categories;
        end

        function flag=supportsGroupCategory(obj)
            flag=true;
        end

        function flag=supportsCategoryStyle(obj,style)
            flag=true;
        end

        function flag=supportsMatchGroups(obj)
            flag=false;
        end

        function primaryPlotArguments=getPrimaryPlotArguments(obj)
            primaryPlotArguments=obj.getPlotArguments();
        end

        function flag=hasMultiplePrimaryPlotArguments(obj)
            primaryPlotArguments=obj.getPrimaryPlotArguments();%#ok<PROP>
            flag=numel(primaryPlotArguments)>1;%#ok<PROP>
        end

        function flag=hasOneToOneGroupMatchingOnly(obj)
            flag=false;
        end

        function flag=excludeAssociatedGroupParameters(obj)
            flag=true;
        end

        function flag=usesVariableCategory(obj)



            categories=obj.getCategories();
            flag=any(categories.isVariable()&categories.hasStyleOtherThanNone());
        end
    end




    methods(Abstract,Access=protected)
        plotBin(obj,compoundBin);
    end

    methods(Access=protected)
        function processAdditionalArguments(obj,definitionProps)
            if~isempty(definitionProps)
                categories=definitionProps.Categories;

                if isempty(categories)||isstruct(categories)
                    obj.setCategories(SimBiology.internal.plotting.categorization.CategoryDefinition(categories));
                end
            end


            if~obj.getPlotArguments().anyMissingData()

                obj.setCategories(obj.getCategories().updateForCategoryVariables(obj.getArgumentsToPlot(),obj));
                obj.processPlotArguments();
                obj.setCategories(obj.getCategories().update(obj.getArgumentsToPlot(),obj));
            end
        end

        function processPlotArguments(obj)

        end

        function processData(obj)
            [targetXUnits,targetYUnits]=obj.applyUnitConversion(obj.doUnitConversionX,obj.doUnitConversionY);
            obj.getArgumentsToPlot().cacheData(targetXUnits,targetYUnits,obj.getCategories(),obj);
        end

        function createPlot(obj)

            usedCategories=obj.selectCategoriesToUseForPlot(obj.getCategories());


            binnedData=usedCategories.binData(obj.getArgumentsToPlot,obj);


            for i=1:numel(binnedData)
                if~isempty(binnedData(i).dataSeries)
                    obj.plotBin(binnedData(i));
                end
            end
        end

        function[targetXUnits,targetYUnits]=applyUnitConversion(obj,convertX,convertY)
            responseCategory=obj.getCategories().getResponseCategory();
            responseBins=[responseCategory.getUsedBins().value];
            if convertX
                targetXUnits=responseBins.getTargetUnitsForDimension(true);
            else
                targetXUnits='';
            end
            if convertY
                targetYUnits=responseBins.getTargetUnitsForDimension(false);
            else
                targetYUnits='';
            end
        end

        function label(obj)
            if~obj.preserveLabels
                obj.updateLabelsForCategories;
            end
        end

        function updateLabelsForCategories(obj)
            globalLabels=struct('Title','','XLabel','','YLabel','');
            axesTitles=repmat({''},size(obj.axes));
            axesXlabels=repmat({''},size(obj.axes));
            axesYlabels=repmat({''},size(obj.axes));

            responseCategory=obj.getCategories().getResponseCategory();
            responseSetCategory=obj.getCategories().getResponseSetCategory();

            responseCategory.updateResponseAreLabelsMatched();

            gridCategory=obj.getCategories().getCategoryWithStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.GRID);
            if~isempty(gridCategory)

                if gridCategory.isCategorical&&~gridCategory.isResponse&&~gridCategory.isResponseSet&&...
                    ~strcmp(gridCategory.categoryVariable.name,SimBiology.internal.plotting.categorization.CategoryVariable.GROUP)
                    globalLabels.Title=gridCategory.getDisplayName(obj);
                end



                numEmptyAxes=numel(obj.axes)-gridCategory.getNumberOfUsedBins;
                fillerLabels=repmat({''},numEmptyAxes,1);

                if gridCategory.isResponse()
                    [axesXlabels,axesYlabels]=getResponseLabelsForGrid(obj,gridCategory,responseSetCategory,fillerLabels);
                else

                    labels=gridCategory.getDisplayLabels(obj,true);

                    axesTitles=transpose(reshape(vertcat(labels,fillerLabels),size(obj.axes')));
                end
            else
                horizontalCategory=obj.getCategories().getCategoryWithStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.HORIZONTAL);
                verticalCategory=obj.getCategories().getCategoryWithStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.VERTICAL);
                if~isempty(horizontalCategory)

                    if horizontalCategory.isCategorical&&~horizontalCategory.isResponse&&~horizontalCategory.isResponseSet&&...
                        ~strcmp(horizontalCategory.categoryVariable.name,SimBiology.internal.plotting.categorization.CategoryVariable.GROUP)
                        globalLabels.Title=horizontalCategory.getDisplayName(obj);
                    end


                    if isempty(verticalCategory)&&horizontalCategory.isResponse

                        [axesXlabels,axesYlabels]=getResponseLabelsForGrid(obj,horizontalCategory,responseSetCategory,{});
                    else
                        labels=obj.getDisplayLabels(horizontalCategory,responseSetCategory);
                        if~isempty(labels)
                            [axesTitles{1,:}]=deal(labels{:});
                        end
                    end
                end

                if~isempty(verticalCategory)

                    if verticalCategory.isCategorical&&~verticalCategory.isResponse&&~verticalCategory.isResponseSet&&...
                        ~strcmp(verticalCategory.categoryVariable.name,SimBiology.internal.plotting.categorization.CategoryVariable.GROUP)
                        globalLabels.YLabel=verticalCategory.getDisplayName(obj);
                    end


                    if isempty(horizontalCategory)&&verticalCategory.isResponse

                        [axesXlabels,axesYlabels]=getResponseLabelsForGrid(obj,verticalCategory,responseSetCategory,{});
                    else
                        labels=obj.getDisplayLabels(verticalCategory,responseSetCategory);
                        if~isempty(labels)
                            [axesYlabels{:,1}]=deal(labels{:});
                        end
                    end
                end
            end



            indVarLabel=responseCategory.getIndependentVariableLabel();
            if isempty(globalLabels.XLabel)
                globalLabels.XLabel=indVarLabel;
            elseif~isempty(indVarLabel)
                globalLabels.XLabel=horzcat(globalLabels.XLabel,newline,depVarLabel);
            end

            depVarLabel=responseCategory.getDependentVariableLabel();
            if isempty(globalLabels.YLabel)
                globalLabels.YLabel=depVarLabel;
            elseif~isempty(depVarLabel)
                globalLabels.YLabel=horzcat(depVarLabel,newline,globalLabels.YLabel);
            end


            obj.figure.setProps(globalLabels);
            obj.axes.setProperty('Title',axesTitles);
            obj.axes.setProperty('XLabel',axesXlabels);
            obj.axes.setProperty('YLabel',axesYlabels);
        end

        function labels=getDisplayLabels(obj,category,responseSetCategory)
            if isempty(responseSetCategory)||~category.isResponse
                labels=category.getDisplayLabels(obj,true);
            else
                labels=getResponseDisplayLabelsFromResponseSet(responseSetCategory,category,obj,true);
            end
        end

        function[axesXlabels,axesYlabels]=getResponseLabelsForGrid(obj,responseCategory,responseSetCategory,fillerLabels)

            if isempty(responseSetCategory)
                xLabels=responseCategory.getResponseXLabels(obj,true);
                yLabels=responseCategory.getResponseYLabels(obj,true);
            else
                [xLabels,yLabels]=getResponseLabelsFromResponseSet(responseSetCategory,responseCategory,obj,true);
            end


            if isempty(xLabels)
                axesXlabels=repmat({''},size(obj.axes));
            else

                axesXlabels=transpose(reshape(vertcat(xLabels,fillerLabels),size(obj.axes')));
            end

            if isempty(yLabels)
                axesYlabels=repmat({''},size(obj.axes));
            else

                axesYlabels=transpose(reshape(vertcat(yLabels,fillerLabels),size(obj.axes')));
            end
        end
    end

    methods(Access=public)
        function flag=qualifyByDataSource(obj)
            flag=numel(obj.getArgumentsToPlot())>1;
        end

        function flag=qualifyGroupsByDataSource(obj)
            flag=numel(obj.getPrimaryPlotArguments())>1;
        end

        function flag=showIndependentVariable(obj)
            flag=~obj.isTimePlot();
        end
    end


    methods(Access=protected)
        function flag=isObjectSupportedForDataTip(obj,h)
            flag=isa(h,'matlab.graphics.chart.primitive.Line');
        end

        function showDataTip(obj,h,dataSpaceCoordinates)
            isAdded=obj.setDataTemplateForHandle(h);
            if(isAdded)
                datatip(h,dataSpaceCoordinates.x,dataSpaceCoordinates.y,'Interpreter','none','SnapToDataVertex',false);
            end
        end

        function isAdded=setDataTemplateForHandle(obj,h)
            if isstruct(h.UserData)&&isfield(h.UserData,'CategoryBinValues')
                isAdded=true;
                bins=h.UserData.CategoryBinValues;
                count=0;

                categories=arrayfun(@(b)obj.getCategoryForCategoryVariable(b.categoryVariableKey),bins);
                responseCategoryIdx=categories.isResponse();
                responseSetCategoryIdx=categories.isResponseSet();
                groupCategoryIdx=categories.isGroup();
                covariateCategoryIdx=categories.isCovariate();


                responseCategory=categories(responseCategoryIdx);
                bin=responseCategory.binSettings(bins(responseCategoryIdx).binIndex);
                displayValue=bin.value.getDisplayNames(obj,responseCategory);
                displayValue=displayValue{1};
                count=count+1;
                dataTipRows(count)=dataTipTextRow(displayValue,@(x)[]);
                responseDataSource=bin.value.dataSource;


                responseSetCategory=categories(responseSetCategoryIdx);
                if~isempty(responseSetCategory)
                    bin=responseSetCategory.binSettings(bins(responseSetCategoryIdx).binIndex);
                    displayValue=bin.value.getDisplayNames(obj,responseSetCategory);
                    displayValue=displayValue{1};
                    count=count+1;
                    dataTipRows(count)=dataTipTextRow(displayValue,@(x)[]);
                end


                groupCategory=categories(groupCategoryIdx);
                if~isempty(groupCategory)
                    bin=groupCategory.binSettings(bins(groupCategoryIdx).binIndex);
                    for i=1:numel(bin.value.infoBins)
                        infoBin=bin.value.infoBins(i);


                        if infoBin.categoryVariable.dataSource.isEqual(responseDataSource)
                            displayName=infoBin.categoryVariable.getDisplayName(false);
                            displayValue=infoBin.binValue.getDisplayNames(obj,infoBin.categoryVariable);
                            displayValue=displayValue{1};
                            count=count+1;
                            dataTipRows(count)=dataTipTextRow([displayName,': ',displayValue],@(x)[]);
                        end
                    end
                end




                covariateCategories=categories(covariateCategoryIdx);
                covariateLineBins=bins(covariateCategoryIdx);
                for i=1:numel(covariateCategories)
                    category=covariateCategories(i);
                    if category.hasStyleOtherThanNone()
                        bin=category.binSettings(covariateLineBins(i).binIndex);
                        displayString=bin.value.getDisplayNames(obj,category);
                        displayString=displayString{1};
                        if category.isCategorical
                            displayString=[category.getDisplayName(obj),': ',displayString];%#ok<AGROW>
                        end
                        count=count+1;
                        dataTipRows(count)=dataTipTextRow(displayString,@(x)[]);
                    end
                end



                h.DataTipTemplate.DataTipRows=dataTipRows;
            else
                isAdded=false;
            end
        end
    end


    methods(Access=public)
        function setBinStyle(obj,categoryVariable,binToChange,property,value)

            category=obj.getCategoryForCategoryVariable(categoryVariable);
            category.binSettings(binToChange.index).updateStyleProperty(property,value);


            switch property
            case 'color'
                value=obj.convertHexToRGB(value);
                value=[value,category.binSettings(binToChange.index).transparency];
            case 'linewidth'
                value=str2num(value);
            end

            binToMatch=struct('categoryDefinition',category,...
            'binValues',binToChange);
            plotElementHandles=obj.getAllPlotElementHandles();
            idx=obj.doesPlotElementMatchAnyBin(plotElementHandles,binToMatch);
            arrayfun(@(plotElement)obj.setPlotElementProperty(plotElement,property,value),plotElementHandles(idx));
        end

        function setPlotElementProperty(~,plotElementHandle,property,value)
            switch(property)
            case 'color'
                if isa(plotElementHandle,'matlab.graphics.primitive.Patch')
                    set(plotElementHandle,'FaceColor',value(1:3),'EdgeColor',value(1:3));
                else
                    set(plotElementHandle,property,value);
                end
            otherwise
                set(plotElementHandle,property,value);
            end
        end
    end

    methods(Access=protected)
        function category=getCategoryForCategoryVariable(obj,categoryVariable)
            category=obj.getCategories().getCategoryForVariable(categoryVariable);
        end
    end

    methods(Access=protected)

        function setupAxes(obj)
            gridCategory=obj.getCategories().getCategoryWithStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.GRID);
            if~isempty(gridCategory)
                numSubplots=gridCategory.getNumberOfVisibleBins;
                [numTrellisRows,numTrellisCols]=obj.getDefaultSubplotGridDimensions(numSubplots);
            else
                horizontalCategory=obj.getCategories().getCategoryWithStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.HORIZONTAL);
                verticalCategory=obj.getCategories().getCategoryWithStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.VERTICAL);
                if~isempty(horizontalCategory)
                    numTrellisCols=horizontalCategory.getNumberOfVisibleBins;
                else
                    numTrellisCols=1;
                end
                if~isempty(verticalCategory)
                    numTrellisRows=verticalCategory.getNumberOfVisibleBins;
                else
                    numTrellisRows=1;
                end
            end

            obj.numTrellisCols=max(numTrellisCols,1);
            obj.numTrellisRows=max(numTrellisRows,1);

            obj.figure.props.Column=obj.numTrellisCols;
            obj.figure.props.Row=obj.numTrellisRows;

            obj.resetAxes();
        end
    end

    methods(Static,Access=protected)
        function selectedCategories=selectCategoriesToUseForPlot(categories)
            idx=arrayfun(@(category)(category.isResponse||category.isResponseSet||category.isGroup||category.hasStyleOtherThanNone()),categories);
            selectedCategories=categories(idx);
        end
    end
end