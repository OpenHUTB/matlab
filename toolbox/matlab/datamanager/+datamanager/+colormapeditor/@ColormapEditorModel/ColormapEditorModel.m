classdef ColormapEditorModel<handle





    properties(Access={?datamanager.colormapeditor.ColormapEditor,?tColormapEditor})
ColormapData
        Colorspace string{mustBeMember(Colorspace,["RGB","HSV"])}
IsColormapReversed
ColorLimits
ColormapName
ColormapSize
    end

    properties(Access=?datamanager.colormapeditor.ColormapEditor,Constant)
        StandardColormaps={'Parula','Turbo','HSV','Hot','Cool','Spring','Summer','Autumn','Winter','Gray','Bone','Copper','Pink','Jet','Lines','Colorcube','Prism','Flag','White'}
    end

    methods(Access={?datamanager.colormapeditor.ColormapEditor,?tColormapEditor})
        function this=ColormapEditorModel()
            this.Colorspace='RGB';
            this.IsColormapReversed='off';
            this.ColorLimits=[0,1];
            this.ColormapData=parula;
            this.ColormapName='Parula';
            this.ColormapSize=256;
        end

        function[cName,cData,cSize,cSpace,cLimits,isInverse]=getModelData(this)
            cName=this.ColormapName;
            cData=this.ColormapData;
            cSize=this.ColormapSize;
            cLimits=this.ColorLimits;
            isInverse=this.IsColormapReversed;
            cSpace=this.Colorspace;
        end

        function updateModel(this,cmapName,cmapData,cmapSize,cspace,cLims,isReversed)
            this.ColormapData=cmapData;
            this.Colorspace=cspace;
            this.IsColormapReversed=isReversed;
            this.ColorLimits=cLims;
            this.ColormapName=cmapName;
            this.ColormapSize=cmapSize;
        end

        function cSize=getColormapSize(this)
            cSize=length(this.ColormapData);
        end

        function updateColormapData(this,cmapData)
            this.ColormapData=cmapData;
        end

        function updateColorspace(this,cspace)
            this.Colorspace=cspace;
        end

        function updateIsReversed(this,isReversed)
            this.IsColormapReversed=isReversed;
        end

        function updateColorLimits(this,cLims)
            this.ColorLimits=cLims;
        end

        function updateColormap(this,cmapName,cmapData)
            this.ColormapData=cmapData;
            this.ColormapName=cmapName;
        end
    end
end
