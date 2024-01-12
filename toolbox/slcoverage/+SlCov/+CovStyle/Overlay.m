classdef Overlay<handle
    properties
        stylerName='MathWorks.CoverageHighlight';
        styler=[];

        slFadeStyle=[];
        slFullCovStyle=[];
        slMissingCovStyle=[];
        slFilteredCovStyle=[];
        slJustifiedCovStyle=[];

        slFadeStyleGroup=[];
        slFullCovStyleGroup=[];
        slMissingCovStyleGroup=[];
        slFilteredCovStyleGroup=[];
        slJustifiedCovStyleGroup=[];

        modelH=[];

        colorTable=[];

        tag='';
    end


    methods
        function this=Overlay(modelH,covResults)
            this.colorTable=cvi.Informer.getHighlightingColorTable;
            this.modelH=modelH;
            this.styler=this.getStyler();
            this.makeTag(modelH);
            this.create(covResults);
        end


        function delete(this)
            this.clearAll();
        end


        function makeTag(this,~)
            this.tag='SlCoverage_';
        end


        function create(this,covResults)
            if isempty(this.slFadeStyleGroup)
                [this.slFadeStyle,options]=this.createSlFadeStyle();
                fadeClassName=sprintf('BD_%s',this.tag);

                this.slFadeStyleGroup=SlCov.CovStyle.StyleGroup(this.styler,this.slFadeStyle,fadeClassName,covResults.Systems,options);
            else
                this.slFadeStyleGroup.show();
            end

            if isempty(this.slFullCovStyleGroup)
                this.slFullCovStyle=this.createSlFullCovStyle();
                selectorName=sprintf('%s_%s',this.tag,'FullCov');
                this.slFullCovStyleGroup=SlCov.CovStyle.StyleGroup(this.styler,this.slFullCovStyle,selectorName,covResults.FullCoverage);
            else
                this.slFullCovStyleGroup.show();
            end

            if isempty(this.slMissingCovStyleGroup)
                this.slMissingCovStyle=this.createSlMissingCovStyle();
                selectorName=sprintf('%s_%s',this.tag,'MissingCov');
                this.slMissingCovStyleGroup=SlCov.CovStyle.StyleGroup(this.styler,this.slMissingCovStyle,selectorName,covResults.PartialCoverage);
            else
                this.slMissingCovStyleGroup.show();
            end

            if isempty(this.slFilteredCovStyleGroup)
                this.slFilteredCovStyle=this.createSlFilteredCovStyle();
                selectorName=sprintf('%s_%s',this.tag,'FilteredCov');
                this.slFilteredCovStyleGroup=SlCov.CovStyle.StyleGroup(this.styler,this.slFilteredCovStyle,selectorName,covResults.FilteredCoverage);
            else
                this.slFilteredCovStyleGroup.show();
            end

            if isempty(this.slJustifiedCovStyleGroup)
                this.slJustifiedCovStyle=this.createSlJustifiedCovStyle();
                selectorName=sprintf('%s_%s',this.tag,'JustifiedCov');
                this.slJustifiedCovStyleGroup=SlCov.CovStyle.StyleGroup(this.styler,this.slJustifiedCovStyle,selectorName,covResults.JustifiedCoverage);
            else
                this.slJustifiedCovStyleGroup.show();
            end
        end


        function show(this)
            if~isempty(this.slFadeStyleGroup)
                this.slFadeStyleGroup.show();
            end
            if~isempty(this.slFullCovStyleGroup)
                this.slFullCovStyleGroup.show();
            end
            if~isempty(this.slMissingCovStyleGroup)
                this.slMissingCovStyleGroup.show();
            end
            if~isempty(this.slFilteredCovStyleGroup)
                this.slFilteredCovStyleGroup.show();
            end
            if~isempty(this.slJustifiedCovStyleGroup)
                this.slJustifiedCovStyleGroup.show();
            end
        end


        function hide(this)
            if~isempty(this.slFadeStyleGroup)
                this.slFadeStyleGroup.hide();
            end
            if~isempty(this.slFullCovStyleGroup)
                this.slFullCovStyleGroup.hide();
            end
            if~isempty(this.slMissingCovStyleGroup)
                this.slMissingCovStyleGroup.hide();
            end
            if~isempty(this.slFilteredCovStyleGroup)
                this.slFilteredCovStyleGroup.hide();
            end
            if~isempty(this.slJustifiedCovStyleGroup)
                this.slJustifiedCovStyleGroup.hide();
            end
        end


        function update(this,covResults,append)
            if(nargin<3)
                append=false;
            end

            if append
                this.slFadeStyleGroup.addItems(covResults.Systems);
                this.slFullCovStyleGroup.addItems(covResults.FullCoverage);
                this.slMissingCovStyleGroup.addItems(covResults.PartialCoverage);
                this.slFilteredCovStyleGroup.addItems(covResults.FilteredCoverage);
                this.slJustifiedCovStyleGroup.addItems(covResults.JustifiedCoverage);
            else
                this.slFadeStyleGroup.setItems(covResults.Systems);
                this.slFullCovStyleGroup.setItems(covResults.FullCoverage);
                this.slMissingCovStyleGroup.setItems(covResults.PartialCoverage);
                this.slFilteredCovStyleGroup.setItems(covResults.FilteredCoverage);
                this.slJustifiedCovStyleGroup.setItems(covResults.JustifiedCoverage);
            end
        end


        function removeBlock(this,blockH)
            this.slFullCovStyleGroup.removeItem(blockH);
            this.slMissingCovStyleGroup.removeItem(blockH);
            this.slFilteredCovStyleGroup.removeItem(blockH);
            this.slJustifiedCovStyleGroup.removeItem(blockH);
        end


        function clearAll(this)
            if~isempty(this.slFadeStyleGroup)
                this.slFadeStyleGroup.clear();
                this.slFadeStyleGroup=[];
            end
            if~isempty(this.slFullCovStyleGroup)
                this.slFullCovStyleGroup.clear();
                this.slFullCovStyleGroup=[];
            end
            if~isempty(this.slMissingCovStyleGroup)
                this.slMissingCovStyleGroup.clear();
                this.slMissingCovStyleGroup=[];
            end
            if~isempty(this.slFilteredCovStyleGroup)
                this.slFilteredCovStyleGroup.clear();
                this.slFilteredCovStyleGroup=[];
            end
            if~isempty(this.slJustifiedCovStyleGroup)
                this.slJustifiedCovStyleGroup.clear();
                this.slJustifiedCovStyleGroup=[];
            end
        end


        function styler=getStyler(this)
            styler=diagram.style.getStyler(this.stylerName);
            if isempty(styler)
                diagram.style.createStyler(this.stylerName);
                styler=diagram.style.getStyler(this.stylerName);
            end
        end


        function style=createSlFullCovStyle(this)
            style=diagram.style.Style;
            style.set('FillColor',this.colorTable.slGreen);
            style.set('FillStyle','Solid');
            style.set('StrokeColor',this.colorTable.slGreenStroke);
            style.set('StrokeWidth',this.colorTable.slStrokeWidth);
        end


        function style=createSlMissingCovStyle(this)
            style=diagram.style.Style;
            style.set('FillColor',this.colorTable.slRed);
            glowConfig=MG2.GlowEffect;
            glowConfig.Color=this.colorTable.slRedStroke;
            glowConfig.Spread=7;
            glowConfig.Gain=2;
            style.set('Glow',glowConfig);

            style.set('FillStyle','Solid');
            style.set('StrokeColor',this.colorTable.slRedStroke);
            style.set('StrokeWidth',this.colorTable.slStrokeWidth);
        end


        function style=createSlFilteredCovStyle(this)
            style=diagram.style.Style;
            style.set('FillColor',this.colorTable.slGray);
            style.set('FillStyle','Solid');
            style.set('StrokeColor',this.colorTable.slGrayStroke);
            style.set('StrokeWidth',this.colorTable.slStrokeWidth);
            style.set('StrokeStyle','DashLine');
        end


        function style=createSlJustifiedCovStyle(this)
            style=diagram.style.Style;
            style.set('FillColor',this.colorTable.slGreen);
            style.set('FillStyle','Solid');
            style.set('StrokeColor',this.colorTable.slGreenStroke);
            style.set('StrokeStyle','DashLine');
            style.set('StrokeWidth',this.colorTable.slStrokeWidth);
        end

        function[style,options]=createSlFadeStyle(this)
            style=diagram.style.Style;
            diagram.style.Style.registerProperty('GreyEverything','bool');
            style.set('GreyEverything',true);
            style.set('FillColor',this.colorTable.slFade);
            style.set('FillStyle','Solid');
            style.set('TextColor',this.colorTable.slFadeText);
            style.set('StrokeColor',this.colorTable.slFadeStroke);
            style.set('Shadow',[]);
            options.selectDescendants=true;
        end
    end
end
