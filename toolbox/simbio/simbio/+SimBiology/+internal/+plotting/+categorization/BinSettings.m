classdef BinSettings<matlab.mixin.SetGet


    methods(Static)
        function const=MIN_WIDTH
            const=SimBiology.internal.plotting.categorization.BinSettings.getDefaultMATLABLineWidth();
        end
        function const=MAX_WIDTH
            const=3.5;
        end
        function const=DELTA_WIDTH
            const=1.0;
        end
        function const=MIN_TRANSPARENCY
            const=0.25;
        end
        function const=DEFAULT_MARKERSIZE
            const=6;
        end
        function const=COLOR_ORDER
            const=...
            {'#0072BD',...
            '#D95319',...
            '#EDB120',...
            '#7E2F8E',...
            '#77AC30',...
            '#4DBEEE',...
            '#A2142F',...
            '#FF0000',...
            '#FF00FF',...
            '#FFFF00',...
            '#00FF00',...
            '#00FFFF',...
            '#0000FF',...
            '#000000',...
            '#FFFF11',...
            '#139FFF',...
            '#FF6929',...
            '#64D413',...
            '#B746FF',...
            '#0FFFFF',...
            '#FF13A6',...
            '#808080',...
            '#A6A6A6',...
            '#CCCCCC'};
        end
        function const=LINESTYLE_OPTIONS
            const=...
            {'-',...
            '--',...
            ':',...
            '-.'};
        end
        function const=MARKER_OPTIONS
            const=...
            {'o',...
            '+',...
            '*',...
            '.',...
            'x',...
            'square',...
            'diamond',...
            '^',...
            'v',...
            '>',...
            '<',...
            'pentagram',...
'hexagram'
            };
        end
    end

    properties(Access=public)
        value=[];
        color=[];
        linespec=[];
        transparency=[];
        show=true;
    end

    properties(SetAccess=private,GetAccess=public)

        usedIndex=[];
    end


    methods(Access=public)
        function obj=BinSettings(input)
            if nargin>0
                if isempty(input)
                    obj=SimBiology.internal.plotting.categorization.BinSettings.empty;
                elseif isstruct(input)||isa(input,'SimBiology.internal.plotting.categorization.BinSettings')
                    obj(numel(input),1)=SimBiology.internal.plotting.categorization.BinSettings();

                    values=vertcat(input.value);
                    if~isa(values,'SimBiology.internal.plotting.categorization.BinValue')
                        values=SimBiology.internal.plotting.categorization.binvalue.BinValue.createBinValues(transpose([input.value]));
                    end

                    arrayfun(@(bin,in,val)set(bin,...
                    'value',val,...
                    'color',SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertHexToRGB(in.color),...
                    'linespec',SimBiology.internal.plotting.categorization.BinSettings.formatInputLinespec(in.linespec),...
                    'transparency',in.transparency,...
                    'show',in.show),...
                    obj,input,values);

                elseif isa(input,'SimBiology.internal.plotting.categorization.binvalue.BinValue')
                    obj=arrayfun(@(~)SimBiology.internal.plotting.categorization.BinSettings(),transpose(1:numel(input)));
                    obj.updateValues(input);

                else

                    obj(input,1)=SimBiology.internal.plotting.categorization.BinSettings();
                end
            end
        end

        function bin=getStruct(obj)
            bin=arrayfun(@(b)struct('value',b.value.getStruct(),...
            'color',SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertRGBToHex(b.color),...
            'linespec',SimBiology.internal.plotting.categorization.BinSettings.formatOutputLinespec(b.linespec),...
            'transparency',b.transparency,...
            'show',b.show),obj);
        end
    end

    methods(Static,Access=private)
        function linespec=formatInputLinespec(linespec)
            if ischar(linespec.linewidth)
                linespec.linewidth=str2num(linespec.linewidth);
            end
        end

        function linespec=formatOutputLinespec(linespec)
            linespec.linewidth=num2str(linespec.linewidth);
        end
    end


    methods(Access=public)
        function flag=isEqual(obj,comparisonObj)
            if isa(comparisonObj,'SimBiology.internal.plotting.categorization.BinSettings')
                comparisonObj=comparisonObj.value;
            end
            for i=numel(obj):-1:1
                flag(i)=obj(i).value.isEqual(comparisonObj);
            end
        end
    end


    methods(Access=public)
        function obj=updateValues(obj,values)
            arrayfun(@(bin,val)set(bin,'value',val),obj,values);
        end

        function obj=updateStyleProperty(obj,property,value)
            switch property
            case 'color'
                set(obj,property,value);
            case{'linestyle','marker'}
                for i=1:numel(obj)
                    obj(i).linespec.(property)=value;
                end
            case 'linewidth'
                for i=1:numel(obj)
                    obj(i).linespec.(property)=str2num(value);
                end
            end
        end

        function obj=resetSettings(obj)
            numObj=numel(obj);
            idx=transpose(1:numel(obj));
            transparencies=SimBiology.internal.plotting.categorization.BinSettings.getDefaultTransparencies(numObj);
            arrayfun(@(bin,index,transparency)set(bin,'color',obj.getDefaultColor(index),...
            'linespec',obj.getDefaultLineSpec(index,bin.varyLineStyle),...
            'transparency',transparency),...
            obj,idx,transparencies);
            arrayfun(@(bin,index)set(bin.value,'index',index),obj,idx);
        end

        function obj=updateSettings(obj)
            numObj=numel(obj);
            transparencies=SimBiology.internal.plotting.categorization.BinSettings.getDefaultTransparencies(numObj);
            for i=1:numObj

                if isempty(obj(i).color)
                    obj(i)=configureColor(obj(i),i,obj);
                    obj(i)=configureLinespec(obj(i),i,obj);
                end

                obj(i).transparency=transparencies(i);
                obj(i).value.updateSettings(i);
            end
        end

        function labels=getDisplayNames(obj,plotDefinition,categoryDefinition)
            if isempty(obj)
                labels={};
            else
                labels=getDisplayNames(vertcat(obj.value),plotDefinition,categoryDefinition);
            end
        end

        function labels=getResponseXLabels(obj,plotDefinition,categoryDefinition)
            if isempty(obj)
                labels={};
            else
                labels=getResponseXLabels(vertcat(obj.value),plotDefinition,categoryDefinition);
            end
        end

        function labels=getResponseYLabels(obj,plotDefinition,categoryDefinition)
            if isempty(obj)
                labels={};
            else
                labels=getResponseYLabels(vertcat(obj.value),plotDefinition,categoryDefinition);
            end
        end

        function bin=getBinForValue(obj,binValue,useDataSource)
            bin=SimBiology.internal.plotting.categorization.BinSettings.empty;
            for i=1:numel(obj)
                if obj(i).value.isEqual(binValue,useDataSource)
                    bin=obj(i);
                    break;
                end
            end
        end

        function bin=getBinForValueWithNA(obj,binValue,useDataSource)
            bin=SimBiology.internal.plotting.categorization.BinSettings.empty;
            for i=1:numel(obj)
                if obj(i).value.isMatch(binValue)
                    bin=obj(i);
                    break;
                end
            end
        end

        function bins=selectBinsByVisibility(obj,isVisible)
            if isVisible
                idx=[obj.show];
            else
                idx=~[obj.show];
            end
            bins=obj(idx);
        end

        function binValues=selectBinValuesByVisibility(obj,isVisible)
            if isVisible
                idx=[obj.show];
            else
                idx=~[obj.show];
            end
            binValues=[obj(idx).value];
        end

        function updateUsedIndex(obj,filterByVisibility)
            if filterByVisibility
                idx=1;
                for i=1:numel(obj)
                    if obj(i).show
                        obj(i).usedIndex=idx;
                        idx=idx+1;
                    end
                end
            else
                for i=1:numel(obj)
                    obj(i).usedIndex=i;
                end
            end
        end

        function resetUsedIndex(obj)
            set(obj,'usedIndex',[]);
        end

        function propsStruct=getPropertiesStructForExportLegend(obj,category,plotDefinition)

            if plotDefinition.useAlternateLabelsForLegend
                displayName=obj.value.getAlternateDisplayName(plotDefinition,category);
            else
                displayName=obj.value.getDisplayNames(plotDefinition,category);
            end
            propsStruct=struct('Color',[0,0,0],...
            'Linestyle','-',...
            'Linewidth',0.5,...
            'Marker','none',...
            'DisplayName',displayName);
            if category.isColor()
                propsStruct.Color=obj.color;
            elseif category.isLinestyle()
                propsStruct.Linestyle=obj.linespec.linestyle;
                propsStruct.Linewidth=obj.linespec.linewidth;
                propsStruct.Marker=obj.linespec.marker;
            elseif category.isTransparency()
                propsStruct.Color=[propsStruct.Color,obj.transparency];
            elseif category.isMixedFormat()
                propsStruct.Color=obj.color;
                propsStruct.Linestyle=obj.linespec.linestyle;
                propsStruct.Linewidth=obj.linespec.linewidth;
                propsStruct.Marker=obj.linespec.marker;
            end
        end
    end

    methods(Access=private)

        function obj=configureColor(obj,index,allBins)
            for s=1:obj.getNumberOfDefaultColors
                color=obj.getDefaultColor(s);%#ok<*PROPLC>
                isUsed=false;
                for b=1:numel(allBins)
                    binColor=allBins(b).color;
                    if~isempty(binColor)&&all(color==binColor)
                        isUsed=true;
                        break;
                    end
                end
                if~isUsed
                    break;
                end
            end

            if isUsed
                color=obj.getDefaultColor(index);
            end
            obj.color=color;
        end


        function obj=configureLinespec(obj,index,allBins)
            numSpecs=obj.getNumberOfDefaultLineSpecs(obj.varyLineStyle);
            for s=1:numSpecs
                linespec=obj.getDefaultLineSpec(s,obj.varyLineStyle);
                isUsed=false;
                for b=1:numel(allBins)
                    binSpec=allBins(b).linespec;
                    if~isempty(binSpec)&&...
                        strcmp(linespec.linestyle,binSpec.linestyle)&&(linespec.linewidth==binSpec.linewidth)&&strcmp(linespec.marker,binSpec.marker)
                        isUsed=true;
                        break;
                    end
                end
                if~isUsed
                    break;
                end
            end

            if isUsed
                linespec=obj.getDefaultLineSpec(index,obj.varyLineStyle);
            end
            obj.linespec=linespec;
        end

        function flag=varyLineStyle(obj)
            flag=obj.value.varyLineStyle;
        end
    end


    methods(Access=public)
        function obj=setDefaultSettings(obj,indices,varyLineStyle)
            arrayfun(@(bin,index)set(bin,'color',SimBiology.internal.plotting.categorization.BinSettings.getDefaultColor(index),...
            'linespec',SimBiology.internal.plotting.categorization.BinSettings.getDefaultLineSpec(index,varyLineStyle)),...
            obj,indices);
        end

        function obj=copySettings(obj,binToCopy)
            set(obj,'color',binToCopy.color,'linespec',binToCopy.linespec,'show',binToCopy.show);
            arrayfun(@(bin)bin.value.copySettings(binToCopy.value),obj);
        end

        function obj=updateResponseSetBins(obj,responseBinValues)

            binValues=vertcat(obj.value);
            unmatchedResponseBins=binValues.updateForResponses(responseBinValues);


            idx=binValues.areResponsesEmpty();
            obj=obj(~idx);
            binValues=binValues(~idx);


            arrayfun(@(bin,value)set(bin,'value',value),obj,binValues);

            if~isempty(unmatchedResponseBins)

                newBin=SimBiology.internal.plotting.categorization.BinSettings;


                newBinValue=SimBiology.internal.plotting.categorization.binvalue.ResponseSetBinValue;
                newBinValue.value=binValues.createNewResponseSetName();
                newBinValue.responseBinValues=unmatchedResponseBins;
                newBin.value=newBinValue;

                obj=vertcat(obj,newBin);
            end
        end

    end


    methods(Static,Access=public)
        function numFormats=getNumberOfDefaultColors()
            numFormats=numel(SimBiology.internal.plotting.categorization.BinSettings.COLOR_ORDER);
        end

        function numFormats=getNumberOfDefaultLineStyles()
            numFormats=numel(SimBiology.internal.plotting.categorization.BinSettings.LINESTYLE_OPTIONS);
        end

        function numFormats=getNumberOfDefaultLineWidths()
            numFormats=((SimBiology.internal.plotting.categorization.BinSettings.MAX_WIDTH-SimBiology.internal.plotting.categorization.BinSettings.MIN_WIDTH)/SimBiology.internal.plotting.categorization.BinSettings.DELTA_WIDTH)+1;
        end

        function numFormats=getNumberOfDefaultMarkers()
            numFormats=numel(SimBiology.internal.plotting.categorization.BinSettings.MARKER_OPTIONS);
        end

        function numFormats=getNumberOfDefaultLineSpecs(varyLineStyle)
            if varyLineStyle
                numFormats=SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultLineSpecsVaryLinestyle();
            else
                numFormats=SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultLineSpecsVaryMarker();
            end
        end

        function numFormats=getNumberOfDefaultLineSpecsVaryLinestyle()
            numLineStyles=SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultLineStyles();
            numLineWidths=SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultLineWidths();
            numFormats=numLineStyles*numLineWidths;
        end

        function numFormats=getNumberOfDefaultLineSpecsVaryMarker()
            numFormats=SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultMarkers();
        end

        function linespec=getDefaultLineSpec(count,varyLineStyle)
            if varyLineStyle
                linespec=SimBiology.internal.plotting.categorization.BinSettings.getDefaultLineSpecVaryLineStyle(count);
            else
                linespec=SimBiology.internal.plotting.categorization.BinSettings.getDefaultLineSpecVaryMarker(count);
            end
        end

        function linespec=getDefaultLineSpecVaryLineStyle(count)
            linespec=struct('linestyle','',...
            'linewidth','',...
            'marker','none');
            linespec.linestyle=SimBiology.internal.plotting.categorization.BinSettings.getDefaultLineStyle(count);
            linespec.linewidth=SimBiology.internal.plotting.categorization.BinSettings.getDefaultLineWidth(count);
        end

        function linespec=getDefaultLineSpecVaryMarker(count)
            linespec=struct('linestyle',':',...
            'linewidth',SimBiology.internal.plotting.categorization.BinSettings.getDefaultMATLABLineWidth(),...
            'marker','');
            linespec.marker=SimBiology.internal.plotting.categorization.BinSettings.getDefaultMarker(count);
        end

        function format=getDefaultColor(count)
            r=rem(count-1,SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultColors())+1;
            format=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertHexToRGB(SimBiology.internal.plotting.categorization.BinSettings.COLOR_ORDER{r});
        end

        function format=getDefaultMarker(count)
            r=rem(count-1,SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultMarkers())+1;
            format=SimBiology.internal.plotting.categorization.BinSettings.MARKER_OPTIONS{r};
        end

        function format=getDefaultLineStyle(count)
            r=rem(count-1,SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultLineStyles())+1;
            format=SimBiology.internal.plotting.categorization.BinSettings.LINESTYLE_OPTIONS{r};
        end

        function format=getDefaultLineWidth(count)
            numLineStyles=SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultLineStyles();
            numLineWidths=SimBiology.internal.plotting.categorization.BinSettings.getNumberOfDefaultLineWidths();
            r=mod(floor((count-1)/numLineStyles),numLineWidths);
            format=SimBiology.internal.plotting.categorization.BinSettings.MIN_WIDTH+SimBiology.internal.plotting.categorization.BinSettings.DELTA_WIDTH*r;
        end

        function linewidth=getDefaultMATLABLineWidth()
            linewidth=get(groot,'DefaultLineLineWidth');
        end

        function formats=getDefaultTransparencies(totalNumBins)
            delta=(1-SimBiology.internal.plotting.categorization.BinSettings.MIN_TRANSPARENCY)/(totalNumBins-1);
            formats=transpose(SimBiology.internal.plotting.categorization.BinSettings.MIN_TRANSPARENCY:delta:1);
        end
    end
end
