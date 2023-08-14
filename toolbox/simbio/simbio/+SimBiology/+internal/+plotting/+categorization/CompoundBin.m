classdef CompoundBin<handle&matlab.mixin.SetGet
    properties
        optimizedBins=struct('categoryVariable',{},'binValue',{});
        bins=struct('categoryVariable',{},'binValue',{});
        dataSeries=[];
        style=[];
    end

    methods(Access=public)
        function obj=CompoundBin(dataSeries,style,bins)
            if nargin>0
                if nargin==1
                    style=SimBiology.internal.plotting.categorization.CompoundBin.getDefaultBinStyle();
                elseif nargin==2
                    bins=struct('categoryVariable',{},'binValue',{});
                end
                obj.dataSeries=dataSeries;
                obj.style=style;
                obj.bins=bins;
            else
                obj.style=SimBiology.internal.plotting.categorization.CompoundBin.getDefaultBinStyle();
            end
        end

        function addBinValue(obj,category,categoryIdx,binSettings,binIdx)

            obj.bins(categoryIdx,1)=struct('categoryVariable',category.categoryVariable,'binValue',binSettings.value);
            obj.updateBinStyle(category,binSettings,binIdx);
        end

        function bins=getAllBins(obj)
            binObjects=[obj.optimizedBins;obj.bins];
            if isempty(binObjects)
                bins=struct('categoryVariableKey',{},...
                'binIndex',{});
            else
                for i=numel(binObjects):-1:1
                    bins(i)=struct('categoryVariableKey',binObjects(i).categoryVariable.key,...
                    'binIndex',binObjects(i).binValue.index);
                end
            end
        end

        function responseBinValue=getResponseBinValue(obj)
            responseBinValue=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue.empty;
            for i=1:numel(obj.optimizedBins)
                if obj.optimizedBins(i).categoryVariable.isResponse()
                    responseBinValue=obj.optimizedBins(i).binValue;
                    break;
                end
            end
            if isempty(responseBinValue)
                for i=1:numel(obj.bins)
                    if obj.bins(i).categoryVariable.isResponse()
                        responseBinValue=obj.bins(i).binValue;
                        break;
                    end
                end
            end
        end

        function binDataSeries(obj,unbinnedDataSeries,useDataSource)

            for i=1:numel(obj)
                if isempty(unbinnedDataSeries)
                    break;
                end
                idx=false(numel(unbinnedDataSeries),1);
                for j=1:numel(unbinnedDataSeries)
                    idx(j)=obj(i).isMatchDataSeries(unbinnedDataSeries(j),useDataSource);
                end
                obj(i).dataSeries=unbinnedDataSeries(idx);
                unbinnedDataSeries=unbinnedDataSeries(~idx);
            end
        end

        function flag=isMatchDataSeries(obj,singleDataSeries,useDataSource)
            flag=true;
            for i=1:numel(obj.bins)
                if~obj.bins(i).binValue.isMatchDataSeries(singleDataSeries,obj.bins(i).categoryVariable,useDataSource)
                    flag=false;
                    break;
                end
            end
        end

        function merge(obj,binToMerge,selectedLayoutFields,selectedFormatFields)
            for i=1:numel(obj)
                obj(i).optimizedBins=binToMerge.bins;
                obj(i).copySelectBinStylesSingleObj(binToMerge.style,selectedLayoutFields,selectedFormatFields);
            end
        end

        function copySelectBinStylesSingleObj(obj,binStyle,selectedLayoutFields,selectedFormatFields)
            for i=1:numel(selectedLayoutFields)
                field=selectedLayoutFields{i};
                obj.style.(field)=binStyle.(field);
            end
            for i=1:numel(selectedFormatFields)
                field=selectedFormatFields{i};
                obj.style.formats.(field)=binStyle.formats.(field);
            end

            obj.style.show=obj.style.show&&binStyle.show;
        end

        function formats=getPlotFormatOptions(obj)
            formats={'color',[obj.style.formats.color,obj.style.formats.transparency],...
            'linestyle',obj.style.formats.linespec.linestyle,...
            'linewidth',obj.style.formats.linespec.linewidth,...
            'marker',obj.style.formats.linespec.marker,...
            'visible',SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertValueToOnOff(obj.style.show);};
        end

        function color=getColor(obj)
            color=obj.style.formats.color;
        end

        function visibility=getVisibility(obj)
            visibility=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertValueToOnOff(obj.style.show);
        end
    end

    methods(Access=private)
        function updateBinStyle(obj,category,binSettings,idx)
            obj.style=obj.modifyBinStyleForCategoryBin(obj.style,category,binSettings,idx,false);
        end
    end

    methods(Static,Access=public)
        function style=getDefaultBinStyle()
            initialFormats=struct('color',SimBiology.internal.plotting.categorization.BinSettings.getDefaultColor(1),...
            'linespec',SimBiology.internal.plotting.categorization.BinSettings.getDefaultLineSpec(1,true),...
            'transparency',1);
            style=struct('formats',initialFormats,...
            'row',1,...
            'column',1,...
            'show',true);
        end

        function style=modifyBinStyleForCategoryBin(style,category,binSettings,idx,applyDefaultLineStyle,isSimulation)
            if nargin<6
                isSimulation=false;
            end

            if category.isHorizontal
                style.column=idx;
            elseif category.isVertical
                style.row=idx;
            elseif category.isGrid
                [~,numColumns]=SimBiology.internal.plotting.sbioplot.SBioPlotObject.getDefaultSubplotGridDimensions(category.getNumberOfVisibleBins);
                style.row=ceil(idx/numColumns);
                style.column=rem(idx-1,numColumns)+1;
            elseif category.isColor
                style.formats.color=binSettings.color;
            elseif category.isLinestyle
                style.formats.linespec=binSettings.linespec;
            elseif category.isTransparency
                style.formats.transparency=binSettings.transparency;
            end
            if~category.isLayout
                style.show=style.show&&binSettings.show;
            end
            if applyDefaultLineStyle
                style.formats.linespec=SimBiology.internal.plotting.categorization.BinSettings.getDefaultLineSpec(1,isSimulation);
            end
        end

        function[layoutFields,formatFields]=getBinStyleFieldsToPreserve(usedCategories)
            layoutFields={};
            formatFields={};
            for i=1:numel(usedCategories)
                category=usedCategories(i);
                if category.isHorizontal
                    layoutFields=[layoutFields,{'column'}];
                elseif category.isVertical
                    layoutFields=[layoutFields,{'row'}];
                elseif category.isGrid
                    layoutFields=[layoutFields,{'column','row'}];
                elseif category.isColor
                    formatFields=[formatFields,{'color'}];
                elseif category.isLinestyle
                    formatFields=[formatFields,{'linespec'}];
                elseif category.isTransparency
                    formatFields=[formatFields,{'transparency'}];
                end
            end
        end
    end

end