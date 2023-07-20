classdef CategoryDefinition<handle&matlab.mixin.SetGet


    methods(Static)

        function const=NONE
            const='None';
        end
        function const=MIXED_FORMAT
            const='Format';
        end
        function const=COLOR
            const='Color';
        end
        function const=LINESTYLE
            const='Line Style';
        end
        function const=TRANSPARENCY
            const='Transparency';
        end
        function const=GRID
            const='Grid';
        end
        function const=HORIZONTAL
            const='Horizontal';
        end
        function const=VERTICAL
            const='Vertical';
        end

        function const=DEFAULT_NUM_BINS
            const=4;
        end

        function const=MAX_NUM_VARIABLE_CATEGORIES
            const=5;
        end
    end

    properties(Access=public)
        categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable.empty;
        style=[];
        binSettings=SimBiology.internal.plotting.categorization.BinSettings.empty;
        isCategorical=true;
        numBins=[];
    end

    properties(Access=private)

        groupBinSettingsByPlotArgument=[];


        areLabelsMatched=[];
    end


    methods(Access=public)
        function obj=CategoryDefinition(input)
            if nargin>0
                if isempty(input)
                    obj=SimBiology.internal.plotting.categorization.CategoryDefinition.empty;
                elseif isstruct(input)
                    numObj=numel(input);
                    if~isfield(input,'style')
                        [input.style]=SimBiology.internal.plotting.categorization.CategoryDefinition.NONE;
                    end
                    if~isfield(input,'binSettings')
                        [input.binSettings]=[];
                    end
                    if~isfield(input,'isCategorical')
                        [input.isCategorical]=true;
                    end
                    if~isfield(input,'numBins')
                        numBins=cell(numObj,1);
                        for i=1:numObj
                            if input(i).isCategorical
                                numBins{i}=[];
                            else
                                numBins{i}=obj.DEFAULT_NUM_BINS;
                            end
                        end
                        [input.numBins]=deal(numBins{:});
                    end

                    obj=arrayfun(@(~)SimBiology.internal.plotting.categorization.CategoryDefinition(),transpose(1:numObj));
                    arrayfun(@(category,in)set(category,'categoryVariable',SimBiology.internal.plotting.categorization.CategoryVariable(in.categoryVariable),...
                    'style',in.style,...
                    'binSettings',SimBiology.internal.plotting.categorization.BinSettings(in.binSettings),...
                    'isCategorical',in.isCategorical,...
                    'numBins',in.numBins),...
                    obj,input);
                else
                    obj.categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(input);
                end
            end
        end
    end


    methods(Access=public)

        function info=getStruct(obj)
            info=arrayfun(@(c)struct('categoryVariable',c.categoryVariable.getStruct(),...
            'style',c.style,...
            'binSettings',c.binSettings.getStruct(),...
            'isCategorical',c.isCategorical,...
            'numBins',c.numBins),obj);
        end

        function flag=isEqual(obj,comparisonObj)
            flag=arrayfun(@(catVar)isEqualHelper(catVar),obj);
            function singleFlag=isEqualHelper(catDef)

                if isa(comparisonObj,'SimBiology.internal.plotting.categorization.CategoryDefinition')
                    singleFlag=catDef.categoryVariable.isEqual(comparisonObj.categoryVariable);

                else
                    singleFlag=catDef.categoryVariable.isEqual(comparisonObj);
                end
            end
        end

        function name=getDisplayName(obj,plotDefinition)

            name=obj.categoryVariable.getDisplayName(plotDefinition);
        end

        function category=getCategoryForVariable(obj,categoryVariable)
            idx=obj.isEqual(categoryVariable);
            category=obj(idx);
        end

        function flag=isResponse(obj)
            flag=arrayfun(@(c)c.categoryVariable.isResponse(),obj);
        end

        function flag=isResponseSet(obj)
            flag=arrayfun(@(c)c.categoryVariable.isResponseSet(),obj);
        end

        function flag=isGroup(obj)
            flag=arrayfun(@(c)c.categoryVariable.isGroup(),obj);
        end

        function flag=isParam(obj)
            flag=arrayfun(@(c)c.categoryVariable.isParam(),obj);
        end

        function flag=isCovariate(obj)
            flag=arrayfun(@(c)c.categoryVariable.isCovariate(),obj);
        end

        function flag=isVariable(obj)
            flag=arrayfun(@(c)c.categoryVariable.isVariable(),obj);
        end

        function flag=isContinuousCovariate(obj)
            flag=arrayfun(@(c)c.categoryVariable.isContinuousCovariate(),obj);
        end

        function flag=isLayout(obj)
            flag=strcmp(obj.style,obj.GRID)||strcmp(obj.style,obj.HORIZONTAL)||strcmp(obj.style,obj.VERTICAL);
        end

        function flag=isFormat(obj)
            flag=strcmp(obj.style,obj.COLOR)||strcmp(obj.style,obj.LINESTYLE)||strcmp(obj.style,obj.TRANSPARENCY)||strcmp(obj.style,obj.MIXED_FORMAT);
        end

        function flag=isGrid(obj)
            flag=obj.isStyle(obj.GRID);
        end

        function flag=isHorizontal(obj)
            flag=obj.isStyle(obj.HORIZONTAL);
        end

        function flag=isVertical(obj)
            flag=obj.isStyle(obj.VERTICAL);
        end

        function flag=isColor(obj)
            flag=obj.isStyle(obj.COLOR);
        end

        function flag=isLinestyle(obj)
            flag=obj.isStyle(obj.LINESTYLE);
        end

        function flag=isTransparency(obj)
            flag=obj.isStyle(obj.TRANSPARENCY);
        end

        function flag=isMixedFormat(obj)
            flag=obj.isStyle(obj.MIXED_FORMAT);
        end

        function flag=isStyle(obj,style)
            flag=arrayfun(@(o)strcmp(o.style,style),obj);
        end

        function flag=hasStyleOtherThanNone(obj)
            flag=arrayfun(@(o)(~isempty(o.style)&&~o.isStyle(obj.NONE)),obj);
        end
    end


    methods(Access=public)
        function numBins=getNumberOfBins(obj)
            numBins=numel(obj.binSettings);
        end

        function numBins=getNumberOfVisibleBins(obj)
            numBins=sum(arrayfun(@(bin)bin.show,obj.binSettings));
        end

        function category=getLayoutCategories(obj)
            idx=arrayfun(@(category)category.isLayout(category),obj);
            category=obj(idx);
        end

        function category=getFormatCategories(obj)
            idx=arrayfun(@(category)category.isFormat(category),obj);
            category=obj(idx);
        end

        function category=getResponseCategory(obj)
            category=obj.getCategoryOfType(SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE);
        end

        function category=getResponseSetCategory(obj)
            category=obj.getCategoryOfType(SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE_SET);
        end

        function category=getGroupCategory(obj)
            category=obj.getCategoryOfType(SimBiology.internal.plotting.categorization.CategoryVariable.GROUP);
        end

        function categories=getVariableCategories(obj)
            idx=obj.isVariable;
            categories=obj(idx);
        end

        function category=getCategoryWithStyle(obj,style)
            idx=findCategoryIdxByStyle(obj,style);
            category=obj(idx);
        end

        function category=getCategoryOfType(obj,type)
            idx=findCategoryIdxByType(obj,type);
            category=obj(idx);
        end

        function labels=getDisplayLabels(obj,plotDefinition,onlyVisibleBins)

            binsToUse=selectBins(obj,onlyVisibleBins);
            labels=binsToUse.getDisplayNames(plotDefinition,obj);
        end

        function labels=getResponseXLabels(obj,plotDefinition,onlyVisibleBins)

            binsToUse=selectBins(obj,onlyVisibleBins);
            labels=binsToUse.getResponseXLabels(plotDefinition,obj);
        end

        function labels=getResponseYLabels(obj,plotDefinition,onlyVisibleBins)

            binsToUse=selectBins(obj,onlyVisibleBins);
            labels=binsToUse.getResponseYLabels(plotDefinition,obj);
        end

        function[xlabels,ylabels]=getResponseLabelsFromResponseSet(obj,responseCategory,plotDefinition,onlyVisibleBins)

            binsToUse=getResponseBinsInOrderOfResponseSet(obj,responseCategory,plotDefinition,onlyVisibleBins);
            xlabels=binsToUse.getResponseXLabels(plotDefinition,responseCategory);
            ylabels=binsToUse.getResponseYLabels(plotDefinition,responseCategory);
        end

        function labels=getResponseDisplayLabelsFromResponseSet(obj,responseCategory,plotDefinition,onlyVisibleBins)

            binsToUse=getResponseBinsInOrderOfResponseSet(obj,responseCategory,plotDefinition,onlyVisibleBins);
            labels=binsToUse.getDisplayNames(plotDefinition,responseCategory);
        end

        function binsToUse=getResponseBinsInOrderOfResponseSet(obj,responseCategory,plotDefinition,onlyVisibleBins)

            binsToUse=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue.empty;
            for i=1:numel(obj.binSettings)
                responseSetBin=obj.binSettings(i);
                for j=1:numel(responseSetBin.value.responseBinValues)
                    bin=responseCategory.binSettings.getBinForValue(responseSetBin.value.responseBinValues(j),plotDefinition.hasMultipleDataSources());
                    if~onlyVisibleBins||bin.show
                        binsToUse=vertcat(binsToUse,bin.value);%#ok<AGROW>
                    end
                end
            end
        end

        function updateResponseAreLabelsMatched(obj)

            plottedBins=selectBins(obj,obj.isLayout);
            responseBins=[plottedBins.value];

            obj.areLabelsMatched=struct('independentVar',false,...
            'independentVarUnits',false,...
            'dependentVar',false,...
            'dependentVarUnits',false);

            if~isempty(responseBins)
                obj.areLabelsMatched.independentVar=responseBins.allMatchInResponseProperty('independentVar');
                obj.areLabelsMatched.independentVarUnits=responseBins.allMatchInResponseProperty('independentVarUnits');
                obj.areLabelsMatched.dependentVar=responseBins.allMatchInResponseProperty('dependentVar');
                obj.areLabelsMatched.dependentVarUnits=responseBins.allMatchInResponseProperty('dependentVarUnits');
            end
        end

        function flagStruct=areResponseLabelsMatched(obj)
            if isempty(obj.areLabelsMatched)
                obj.updateResponseAreLabelsMatched();
            end
            flagStruct=obj.areLabelsMatched;
        end

        function binsToUse=selectBins(obj,onlyVisibleBins)
            if onlyVisibleBins
                binsToUse=obj.binSettings(vertcat(obj.binSettings.show));
            else
                binsToUse=obj.binSettings;
            end
        end

        function labels=getIndependentVariableLabel(obj)
            labels=getVariableLabel(obj,true);
        end

        function labels=getDependentVariableLabel(obj)
            labels=getVariableLabel(obj,false);
        end

        function label=getVariableLabel(obj,isIndependentVariable)

            if isIndependentVariable
                varProp='independentVar';
                unitsProp='independentVarUnits';
            else
                varProp='dependentVar';
                unitsProp='dependentVarUnits';
            end

            label='';
            unitsLabel='';

            plottedBins=selectBins(obj,obj.isLayout);
            responseBins=[plottedBins.value];

            if obj.areLabelsMatched.(varProp)
                label=responseBins(1).value.(varProp);
            end
            if obj.areLabelsMatched.(unitsProp)
                unitsLabel=responseBins(1).value.(unitsProp);
            end

            if isempty(label)
                label=unitsLabel;
            elseif~isempty(unitsLabel)
                label=[label,' (',unitsLabel,')'];
            end
        end
    end


    methods(Access=public)
        function obj=update(obj,plotArguments,plotDefinition)
            if isempty(plotArguments)
                obj=SimBiology.internal.plotting.categorization.CategoryDefinition.empty;
                return;
            end

            hasGroups=any(arrayfun(@(arg)(arg.getNumberOfGroups()>1),plotArguments));
            supportsGroupCategory=plotDefinition.supportsGroupCategory()&&hasGroups;
            hasMultipleDataSources=(numel(plotArguments)>1);
            hasMultipleResponses=hasMultipleDataSources||(plotArguments.getNumberOfResponses()>1);


            responseCategoryIdx=findCategoryIdxByType(obj,SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE);
            responseCategory=obj(responseCategoryIdx);
            if isempty(responseCategory)

                responseCategory=SimBiology.internal.plotting.categorization.CategoryDefinition(SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE);
                obj=[obj;responseCategory];
            end

            if isempty(responseCategory.style)
                setDefaultResponseStyle(responseCategory,obj,supportsGroupCategory,hasMultipleDataSources,hasMultipleResponses,plotDefinition);
            end


            responseSetCategoryIdx=findCategoryIdxByType(obj,SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE_SET);
            responseSetCategory=obj(responseSetCategoryIdx);
            if~isempty(responseSetCategory)&&isempty(responseSetCategory.style)
                setDefaultResponseSetStyle(responseSetCategory,obj,plotDefinition);
            end


            groupCategoryIdx=findCategoryIdxByType(obj,SimBiology.internal.plotting.categorization.CategoryVariable.GROUP);
            groupCategory=obj(groupCategoryIdx);

            if hasGroups

                [obj,categoryVariables]=updateForCategoryVariables(obj,plotArguments,plotDefinition);

                if supportsGroupCategory&&isempty(groupCategory)

                    groupCategory=SimBiology.internal.plotting.categorization.CategoryDefinition(SimBiology.internal.plotting.categorization.CategoryVariable.GROUP);
                    setDefaultGroupStyle(groupCategory,responseCategory,responseSetCategory,plotDefinition);
                    obj(end+1)=groupCategory;
                end


                variableCategoryIdx=findCategoryIdxByType(obj,SimBiology.internal.plotting.categorization.CategoryVariable.PARAM)|...
                findCategoryIdxByType(obj,SimBiology.internal.plotting.categorization.CategoryVariable.COVARIATE);
                variableCategories=obj(variableCategoryIdx);


                idx=arrayfun(@(cv)any(variableCategories.isEqual(cv)),categoryVariables);
                unusedCategoryVariables=categoryVariables(~idx);

                maxVariableCategories=obj.MAX_NUM_VARIABLE_CATEGORIES-numel(variableCategories);
                numAdditionalVariableCategories=min(maxVariableCategories,numel(unusedCategoryVariables));
                numCurrentCategories=numel(obj);
                for i=numAdditionalVariableCategories:-1:1
                    unusedCategoryVariable=unusedCategoryVariables(i);
                    isCategorical=~unusedCategoryVariable.isContinuousCovariate();%#ok<PROPLC>
                    obj(numCurrentCategories+i)=SimBiology.internal.plotting.categorization.CategoryDefinition(struct('categoryVariable',unusedCategoryVariable,...
                    'isCategorical',isCategorical));
                end
            else

                if~isempty(groupCategory)
                    obj=obj(1:find(groupCategoryIdx)-1);
                end
            end

            obj.updateBins(plotArguments,plotDefinition);
        end

        function[obj,varargout]=updateForCategoryVariables(obj,plotArguments,plotDefinition)
            categoryVariables=obj.getCategoryVariables(plotArguments,plotDefinition.excludeAssociatedGroupParameters());

            idx=true(size(obj));
            for i=1:numel(obj)
                category=obj(i);
                if category.isVariable
                    idx(i)=false;
                    for j=1:numel(categoryVariables)
                        if category.isEqual(categoryVariables(j))


                            idx(i)=true;
                            category.categoryVariable=categoryVariables(j);
                            break;
                        end
                    end
                end
            end
            obj=obj(idx);
            varargout{1}=categoryVariables;
        end
    end


    methods(Access=private)
        function idx=findCategoryIdxByType(obj,type)
            idx=arrayfun(@(category)category.categoryVariable.isOfType(type),obj);
        end

        function idx=findCategoryIdxByStyle(obj,style)
            idx=arrayfun(@(category)category.isStyle(style),obj);
        end

        function updateBins(obj,plotArguments,plotDefinition)

            responseCategory=obj.getResponseCategory();
            updateResponseCategory(responseCategory,plotArguments,plotDefinition);

            for i=1:numel(obj)
                category=obj(i);
                switch(category.categoryVariable.type)
                case SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE

                case SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE_SET
                    updateResponseSetsCategory(category,plotArguments,responseCategory);
                case SimBiology.internal.plotting.categorization.CategoryVariable.GROUP
                    updateGroupCategory(category,plotArguments,plotDefinition);
                case{SimBiology.internal.plotting.categorization.CategoryVariable.PARAM,SimBiology.internal.plotting.categorization.CategoryVariable.COVARIATE}
                    if strcmp(category.categoryVariable.subtype,SimBiology.internal.plotting.categorization.CategoryVariable.CONTINUOUS)
                        updateRangeCategory(category,plotArguments,plotDefinition);
                    else
                        updateCategoricalCategory(category,plotArguments,plotDefinition);
                    end
                end
            end
        end

        function updateResponseCategory(obj,plotArguments,plotDefinition)

            oldBins=[obj.binSettings];
            responses=obj.compileResponses(plotArguments,plotDefinition);
            numResponses=numel(responses);
            newBins=SimBiology.internal.plotting.categorization.BinSettings(numResponses);
            newBins.updateValues(responses);


            for i=1:numResponses
                response=responses(i);
                idx=arrayfun(@(bin)bin.isEqual(response),oldBins);
                matchedBin=oldBins(idx);
                if~isempty(matchedBin)
                    newBins(i)=newBins(i).copySettings(matchedBin);
                end
            end
            obj.binSettings=newBins.updateSettings();
        end

        function updateResponseSetsCategory(obj,plotArguments,responseCategory)

            obj.binSettings=obj.binSettings.updateResponseSetBins([responseCategory.binSettings.value]);
            obj.binSettings=obj.binSettings.updateSettings();
        end

        function updateGroupCategory(obj,plotArguments,plotDefinition)


            primaryPlotArguments=plotDefinition.getPrimaryPlotArguments();
            groupsByPlotArgument=arrayfun(@(plotArg)plotArg.getGroups(),primaryPlotArguments,'UniformOutput',false);
            groups=vertcat(groupsByPlotArgument{:});
            obj.updateGroupBasedCategory(groups);

            if(plotDefinition.hasMultipleDataSources)
                obj.cacheGroupBinSettingsByPlotArgument(primaryPlotArguments);
                obj.categoryVariable.name=SimBiology.internal.plotting.categorization.CategoryVariable.GROUP;
            else
                name=primaryPlotArguments.getGroupCategoryName();
                if isempty(name)
                    obj.categoryVariable.name=SimBiology.internal.plotting.categorization.CategoryVariable.GROUP;
                else
                    obj.categoryVariable.name=name;
                end
            end
        end

        function cacheGroupBinSettingsByPlotArgument(obj,primaryPlotArguments)

            obj.groupBinSettingsByPlotArgument=containers.Map;
            startIdx=0;
            for i=1:numel(primaryPlotArguments)
                numBins=primaryPlotArguments(i).getNumberOfGroups;
                nextIdx=startIdx+numBins;
                obj.groupBinSettingsByPlotArgument(primaryPlotArguments(i).dataSource.key)=obj.binSettings(startIdx+1:nextIdx);
                startIdx=nextIdx;
            end
        end

        function updateCategoricalCategory(obj,plotArguments,plotDefinition)

            plotArg=getPlotArgumentForDataSource(plotArguments,obj.categoryVariable.dataSource);
            values=plotArg.getCategoryVariableValues(obj.categoryVariable);
            values=addNotApplicableBinIfApplicable(obj,values,plotArg,plotDefinition);
            obj.updateGroupBasedCategory(values);
        end

        function updateRangeCategory(obj,plotArguments,plotDefinition)

            plotArg=getPlotArgumentForDataSource(plotArguments,obj.categoryVariable.dataSource);
            numericBinValues=plotArg.getCategoryVariableValuesForGroups(obj.categoryVariable);
            values=numericBinValues.createRangeBinValues(obj.numBins);
            numBins=numel(values);
            if numBins<obj.numBins
                if obj.hasStyleOtherThanNone()
                    warning(message('SimBiology:Plotting:NUMBER_OF_BINS_CHANGED',...
                    obj.categoryVariable.getDisplayName(plotDefinition),...
                    obj.numBins,numBins));
                end
                obj.numBins=numBins;
            end
            values=addNotApplicableBinIfApplicable(obj,values,plotArg,plotDefinition);
            obj.updateGroupBasedCategory(values);
        end

        function values=addNotApplicableBinIfApplicable(obj,values,plotArgument,plotDefinition)


            if numel(plotDefinition.getPrimaryPlotArguments())>1||...
                (plotDefinition.hasMultipleDataSources()&&~plotArgument.data.hasOneToOneGroupMatchingOnly())
                values=SimBiology.internal.plotting.categorization.binvalue.BinValue.addNABinValue(values);
            end
        end

        function updateGroupBasedCategory(obj,values)
            newNumBins=numel(values);
            oldNumBins=obj.getNumberOfBins;
            if(oldNumBins>=newNumBins)
                obj.binSettings=obj.binSettings(1:newNumBins);
            else
                newBins=SimBiology.internal.plotting.categorization.BinSettings(newNumBins-oldNumBins);
                obj.binSettings=[obj.binSettings;newBins];
            end
            obj.binSettings=obj.binSettings.updateValues(values);
            obj.binSettings=obj.binSettings.updateSettings();
        end


        function setDefaultResponseStyle(obj,allCategories,supportsGroupCategory,hasMultipleDataSources,hasMultipleResponses,plotDefinition)


            if(plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR)&&...
                (~plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE)||...
                (~supportsGroupCategory&&~hasMultipleDataSources&&hasMultipleResponses&&plotDefinition.isTimePlot())))&&...
                all(arrayfun(@(c)~c.isColor(),allCategories))
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR;
            elseif plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE)&&...
                all(arrayfun(@(c)~c.isLinestyle(),allCategories))
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE;
            else
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.NONE;
            end
        end


        function setDefaultResponseSetStyle(obj,allCategories,plotDefinition)

            if plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.VERTICAL)&&...
                all(arrayfun(@(c)(~strcmp(c.style,SimBiology.internal.plotting.categorization.CategoryDefinition.VERTICAL)&...
                ~strcmp(c.style,SimBiology.internal.plotting.categorization.CategoryDefinition.GRID)),allCategories))
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.VERTICAL;
            elseif plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR)&&...
                all(arrayfun(@(c)~strcmp(c.style,SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR),allCategories))
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR;
            elseif plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE)&&...
                all(arrayfun(@(c)~strcmp(c.style,SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE),allCategories))
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE;
            elseif plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.GRID)&&...
                all(arrayfun(@(c)~c.isLayout,allCategories))
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.GRID;
            elseif plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.HORIZONTAL)&&...
                all(arrayfun(@(c)(~strcmp(c.style,SimBiology.internal.plotting.categorization.CategoryDefinition.HORIZONTAL)&...
                ~strcmp(c.style,SimBiology.internal.plotting.categorization.CategoryDefinition.GRID)),allCategories))
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.HORIZONTAL;
            else
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.NONE;
            end
        end


        function setDefaultGroupStyle(obj,responseCategory,responseSetCategory,plotDefinition)

            responseStyle=responseCategory.style;
            if isempty(responseSetCategory)
                responseSetStyle='';
            else
                responseSetStyle=responseSetCategory.style;
            end
            if plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR)&&...
                ~strcmp(responseStyle,SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR)&&~strcmp(responseSetStyle,SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR)
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR;
            elseif plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE)&&...
                ~strcmp(responseStyle,SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE)&&~strcmp(responseSetStyle,SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE)
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE;
            elseif plotDefinition.supportsCategoryStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.GRID)&&...
                ~responseCategory.isLayout&&~isempty(responseSetCategory)&&~responseSetCategory.isLayout
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.GRID;
            else
                obj.style=SimBiology.internal.plotting.categorization.CategoryDefinition.NONE;
            end
        end
    end


    methods(Access=public)
        function binnedData=binData(obj,plotArguments,plotDefinition)



            [optimizedBinnedData,usedCategories,remainingCategories]=binDataForOptimizedCategories(obj,plotArguments,plotDefinition);


            if isempty(remainingCategories)
                binnedData=optimizedBinnedData;
            else
                binnedData=binDataForRemainingCategories(remainingCategories,optimizedBinnedData,plotDefinition,usedCategories);
            end
        end
    end


    methods(Access=private)

        function[optimizedBinnedData,usedCategories,remainingCategories]=binDataForOptimizedCategories(obj,plotArguments,plotDefinition)


            responseCategory=obj.getResponseCategory();
            responseSetCategory=obj.getResponseSetCategory();
            groupCategory=obj.getGroupCategory();
            remainingCategories=obj.getVariableCategories();

            responseBins=responseCategory.getUsedBins();
            responseSetBins=SimBiology.internal.plotting.categorization.BinSettings.empty;
            groupBins=SimBiology.internal.plotting.categorization.BinSettings.empty;

            usedCategories=responseCategory;

            if~isempty(responseSetCategory)
                responseCategoryIdx=2;
                responseSetCategoryIdx=1;
                groupCategoryIdx=3;

                responseSetBins=responseSetCategory.getUsedBins();
                usedCategories=[responseSetCategory;usedCategories];
            else
                responseCategoryIdx=1;
                responseSetCategoryIdx=0;
                groupCategoryIdx=2;
            end

            applyDefaultLineStyle=all(~usedCategories.isStyle(SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE));


            if isempty(groupCategory)
                getGroupBins=@(plotArg)(SimBiology.internal.plotting.categorization.binvalue.GroupBinValue.empty);
            else
                groupCategory.updateUsedIndexForBins();
                usedCategories=[usedCategories;groupCategory];
                allGroupBins=groupCategory.getUsedBins();
                if plotDefinition.hasMultipleDataSources
                    groupBinsByPlotArgument=groupCategory.getUsedBinsByPlotArgument();
                    getGroupBins=@(plotArg)groupBinsByPlotArgument(plotArg.matchedDataSource.key);
                else
                    getGroupBins=@(plotArg)allGroupBins;
                end
            end


            if(~isempty(responseSetCategory)&&numel(responseSetBins)==0)||...
                (~isempty(responseCategory)&&numel(responseBins)==0)||...
                (~isempty(groupCategory)&&numel(allGroupBins)==0)
                optimizedBinnedData=SimBiology.internal.plotting.categorization.CompoundBin.empty;
                return;
            end


            if plotDefinition.hasMultipleDataSources
                getPlotArgument=@(respBin)plotArguments.getPlotArgumentForDataSource(respBin.value.dataSource);
            else
                getPlotArgument=@(respBin)plotArguments;
            end


            optimizedBinnedData(numel(responseBins)*max(numel(groupBins),1),1)=SimBiology.internal.plotting.categorization.CompoundBin;
            compoundBinValues=struct('categoryVariable',num2cell(vertcat(usedCategories.categoryVariable)),'binValue',repmat({''},[numel(usedCategories),1]));
            compoundBinStyle=SimBiology.internal.plotting.categorization.CompoundBin.getDefaultBinStyle();
            count=0;
            if~isempty(responseSetCategory)
                responseBinIndex=0;
                for sb=1:numel(responseSetBins)
                    responseSetBin=responseSetBins(sb);

                    compoundBinValues(responseSetCategoryIdx).binValue=responseSetBin.value;
                    compoundBinStyleUpdatedForResponseSet=SimBiology.internal.plotting.categorization.CompoundBin.modifyBinStyleForCategoryBin(compoundBinStyle,responseSetCategory,responseSetBin,sb,false);

                    for rb=1:numel(responseSetBin.value.responseBinValues)
                        responseBin=responseBins.getBinForValue(responseSetBin.value.responseBinValues(rb),plotDefinition.hasMultipleDataSources());

                        if~isempty(responseBin)

                            responseBinIndex=responseBinIndex+1;
                            plotArgument=getPlotArgument(responseBin);
                            groupBins=getGroupBins(plotArgument);
                            [optimizedBinnedData,count]=binDataForSingleResponseBin(responseCategory,responseCategoryIdx,responseBin,responseBinIndex,groupCategory,groupCategoryIdx,groupBins,compoundBinValues,compoundBinStyleUpdatedForResponseSet,plotArgument,optimizedBinnedData,count,plotDefinition,applyDefaultLineStyle);
                        end
                    end
                end
            else
                for rb=1:numel(responseBins)
                    responseBin=responseBins(rb);
                    plotArgument=getPlotArgument(responseBin);
                    groupBins=getGroupBins(plotArgument);
                    [optimizedBinnedData,count]=binDataForSingleResponseBin(responseCategory,responseCategoryIdx,responseBin,rb,groupCategory,groupCategoryIdx,groupBins,compoundBinValues,compoundBinStyle,plotArgument,optimizedBinnedData,count,plotDefinition,applyDefaultLineStyle);
                end
            end
        end

        function[optimizedBinnedData,count]=binDataForSingleResponseBin(responseCategory,responseCategoryIdx,responseBin,responseBinIdx,groupCategory,groupCategoryIdx,groupBins,compoundBinValues,compoundBinStyle,plotArgument,optimizedBinnedData,count,plotDefinition,applyDefaultLineStyle)
            compoundBinValues(responseCategoryIdx).binValue=responseBin.value;
            compoundBinStyle=SimBiology.internal.plotting.categorization.CompoundBin.modifyBinStyleForCategoryBin(compoundBinStyle,responseCategory,responseBin,responseBinIdx,applyDefaultLineStyle,responseBin.value.isSimulation);

            dataSeries=plotArgument.getCachedData(responseBin.value);

            if~plotDefinition.supportsGroupCategory

                count=count+1;
                optimizedBinnedData(count)=SimBiology.internal.plotting.categorization.CompoundBin([dataSeries{:}],compoundBinStyle,compoundBinValues);
            elseif~isempty(groupCategory)
                for gb=1:numel(groupBins)
                    groupBin=groupBins(gb);

                    compoundBinValues(groupCategoryIdx).binValue=groupBin.value;
                    compoundBinStyleUpdatedForGroup=SimBiology.internal.plotting.categorization.CompoundBin.modifyBinStyleForCategoryBin(compoundBinStyle,groupCategory,groupBin,groupBin.usedIndex,false);

                    count=count+1;

                    optimizedBinnedData(count)=SimBiology.internal.plotting.categorization.CompoundBin(dataSeries{groupBin.value.getDataIndex()},compoundBinStyleUpdatedForGroup,compoundBinValues);
                end
            else
                count=count+1;

                optimizedBinnedData(count)=SimBiology.internal.plotting.categorization.CompoundBin(dataSeries{1},compoundBinStyle,compoundBinValues);
            end
        end

        function binnedData=binDataForRemainingCategories(obj,responseBinnedData,plotDefinition,usedCategories)
            hasOneToOneGroupMatchingOnly=plotDefinition.hasOneToOneGroupMatchingOnly();
            if hasOneToOneGroupMatchingOnly
                binnedData=binDataForRemainingCategoriesOptimized(obj,responseBinnedData,usedCategories);
            else
                binnedData=binDataForRemainingCategoriesNotOptimized(obj,responseBinnedData,usedCategories,false);
            end
        end

        function binnedData=binDataForRemainingCategoriesOptimized(obj,responseBinnedData,usedCategories)
            categoryOffset=numel(usedCategories);
            obj.updateUsedIndexForBins();
            for i=1:numel(responseBinnedData)
                for j=numel(obj):-1:1
                    matchedBin=obj(j).getBinForDataSeries(responseBinnedData(i).dataSeries(1),false);
                    if isempty(matchedBin)



                        responseBinnedData(i).dataSeries=SimBiology.internal.plotting.sbioplot.DataSeries.empty;
                    else
                        responseBinnedData(i).addBinValue(obj(j),j+categoryOffset,matchedBin,matchedBin.usedIndex);
                    end
                end
            end
            binnedData=responseBinnedData;
        end

        function updateUsedIndexForBins(obj)
            for i=1:numel(obj)
                obj(i).binSettings.updateUsedIndex(obj(i).isLayout);
            end
        end

        function bin=getBinForDataSeries(obj,singleDataSeries,useDataSource)

            binValue=singleDataSeries.getBinValueForVariable(obj.categoryVariable);
            bin=obj.binSettings.getBinForValueWithNA(binValue,useDataSource);

            if~bin.show&&obj.isLayout
                bin=SimBiology.internal.plotting.categorization.BinSettings.empty;
            end
        end

        function binnedData=binDataForRemainingCategoriesNotOptimized(obj,responseBinnedData,usedCategories,useDataSource)

            compoundBinsTemplate=createCompoundBins(obj);
            [layoutFields,formatFields]=SimBiology.internal.plotting.categorization.CompoundBin.getBinStyleFieldsToPreserve(usedCategories);


            numBinsFromProcessedCategories=numel(responseBinnedData);
            numBinsFromRemainingCategories=numel(compoundBinsTemplate);

            binnedData(numBinsFromProcessedCategories*numBinsFromRemainingCategories,1)=SimBiology.internal.plotting.categorization.CompoundBin;
            for i=1:numBinsFromProcessedCategories

                for c=numBinsFromRemainingCategories:-1:1
                    compoundBins(c)=SimBiology.internal.plotting.categorization.CompoundBin([],...
                    compoundBinsTemplate(c).style,...
                    compoundBinsTemplate(c).bins);
                end
                compoundBins.merge(responseBinnedData(i),layoutFields,formatFields);
                compoundBins.binDataSeries(responseBinnedData(i).dataSeries,useDataSource);
                binnedData((i-1)*numBinsFromRemainingCategories+1:i*numBinsFromRemainingCategories)=compoundBins;
            end
        end

        function compoundBins=createCompoundBins(obj)

            numCategories=numel(obj);
            numUsedBins=arrayfun(@(c)c.getNumberOfUsedBins,obj);
            numCompoundBins=prod(numUsedBins);
            compoundBins(numCompoundBins,1)=SimBiology.internal.plotting.categorization.CompoundBin;
            idx=transpose(1:numCompoundBins);


            previousNumTimesToRepeatEachValue=0;
            numUniqueBins=1;

            for c=numCategories:-1:1
                category=obj(c);
                categoryBins=category.getUsedBins();
                numUniqueBins=numUniqueBins*numUsedBins(c);
                numTimesToRepeatEachValue=numCompoundBins/numUniqueBins;

                binIdx=ceil(((mod(idx-1,previousNumTimesToRepeatEachValue)+1)/numTimesToRepeatEachValue));
                arrayfun(@(compoundBin,i)compoundBin.addBinValue(category,c,categoryBins(i),i),...
                compoundBins,binIdx);
                previousNumTimesToRepeatEachValue=numTimesToRepeatEachValue;
            end
        end
    end

    methods(Access=public)
        function flag=getNumberOfUsedBins(obj)
            if obj.isLayout
                flag=obj.getNumberOfVisibleBins;
            else
                flag=obj.getNumberOfBins;
            end
        end

        function bins=getBins(obj)
            bins=obj.binSettings;
        end

        function bins=getUsedBins(obj)

            if~obj.isLayout
                bins=obj.getBins();
            else
                bins=obj.getVisibleBins();
            end
        end

        function bins=getVisibleBins(obj)

            bins=obj.binSettings.selectBinsByVisibility(true);
        end

        function flag=useBin(obj,b)
            flag=~obj.isLayout||obj.binSettings(b).show;
        end

        function binsForDataSource=getBinsForDataSource(obj,dataSourceKey)
            binsForDataSource=obj.groupBinSettingsByPlotArgument(dataSourceKey);
        end

        function binsByPlotArgument=getUsedBinsByPlotArgument(obj)
            if~obj.isLayout
                binsByPlotArgument=obj.groupBinSettingsByPlotArgument;
            else
                binsByPlotArgument=containers.Map;
                keys=obj.groupBinSettingsByPlotArgument.keys;
                for i=1:numel(keys)
                    bins=obj.groupBinSettingsByPlotArgument(keys{i});
                    binsByPlotArgument(keys{i})=bins.selectBinsByVisibility(true);
                end
            end
        end
    end


    methods(Access=public)
        function clonedBinSettings=cloneAndConfigureBinSettingsForResponseSets(obj,responseSetCategory)

            numResponseSets=responseSetCategory.getNumberOfBins();

            for i=numResponseSets:-1:1
                responseSetBinSettings=responseSetCategory.binSettings(i);
                matchedResponseBinSettings=obj.getBinSettingsForResponseSetBin(responseSetBinSettings.value);
                binSettings=SimBiology.internal.plotting.categorization.BinSettings(matchedResponseBinSettings);

                switch(responseSetCategory.style)
                case SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR
                    binSettings.updateStyleProperty('color',responseSetBinSettings.color);
                case SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE
                    binSettings.updateStyleProperty('linestyle',responseSetBinSettings.linestyle);
                    binSettings.updateStyleProperty('linewidth',responseSetBinSettings.linewidth);
                    binSettings.updateStyleProperty('marker',responseSetBinSettings.marker);
                otherwise

                end


                if~obj.isColor&&~responseSetCategory.isColor
                    binSettings.updateStyleProperty('color','#000000');
                end
                if~obj.isLinestyle&&~responseSetCategory.isLinestyle
                    binSettings.updateStyleProperty('linestyle','-');
                    binSettings.updateStyleProperty('linewidth','0.5');
                    binSettings.updateStyleProperty('marker','none');
                end
                clonedBinSettings{i,1}=binSettings;
            end
        end
    end

    methods(Access=private)
        function binSettings=getBinSettingsForResponseSetBin(obj,responseSetBinValue)

            idx=arrayfun(@(b)responseSetBinValue.includesResponse(b.value,true),obj.binSettings);
            binSettings=obj.binSettings(idx);
        end
    end


    methods(Static,Access=private)
        function categoryVariables=getCategoryVariables(plotArguments,excludeAssociatedGroupParameters)
            categoryVariables=arrayfun(@(arg)arg.data.getCategoryVariables(excludeAssociatedGroupParameters),plotArguments,'UniformOutput',false);
            categoryVariables=vertcat(categoryVariables{:});
        end

        function responses=compileResponses(plotArguments,plotDefinition)
            numResponsesInPlotArg=arrayfun(@(arg)numel(arg.responses),plotArguments);
            numResponses=sum(numResponsesInPlotArg);

            responses(numResponses,1)=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue;
            numPlotArgs=numel(plotArguments);
            prevCount=0;
            for i=1:numPlotArgs
                plotArg=plotArguments(i);
                next=plotArg.getResponseBins();
                responses(prevCount+1:prevCount+numResponsesInPlotArg(i))=next;
                prevCount=prevCount+numResponsesInPlotArg(i);
            end
        end
    end
end