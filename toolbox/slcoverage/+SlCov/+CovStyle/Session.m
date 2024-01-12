classdef Session<handle
    properties
        modelH=[];
        overlay=[];
        sfTextOverlay=[];
    end


    methods
        function this=Session(modelH)
            this.modelH=modelH;
        end


        function revertAllHighlighting(this)
            if~isempty(this.overlay)
                this.overlay.hide();
                delete(this.overlay);
                this.overlay=[];
            end
            if~isempty(this.sfTextOverlay)
                delete(this.sfTextOverlay);
                this.sfTextOverlay=[];
            end
        end


        function revertBlockHighlighting(this,blockH)
            if~isempty(this.overlay)
                this.overlay.removeBlock(blockH);
            end

        end


        function applyHighlighting(this,covResults,append)
            if(nargin<3)
                append=false;
            end

            if isfield(covResults,'modelH')
                if isempty(this.overlay)
                    this.overlay=SlCov.CovStyle.Overlay(this.modelH,covResults);
                else
                    this.overlay.update(covResults,append);
                    this.overlay.show();
                end
            end

            if strcmpi(cv('Feature','SlCov_SFTextHighlight'),'on')&&isfield(covResults,'SFCoverage')
                if isempty(this.sfTextOverlay)
                    this.sfTextOverlay=SlCov.CovStyle.SFTextOverlay(this.modelH,covResults.SFCoverage);
                else
                    this.sfTextOverlay.update(covResults.SFCoverage,append);
                end
            end
        end
    end
end

