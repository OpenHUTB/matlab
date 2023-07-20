classdef ComponentView<handle&matlab.mixin.Heterogeneous




    properties(Access=public)
Parent


Component



        ComponentImage matlab.ui.control.Image
        ComponentText matlab.ui.control.Label



        OverallLayout matlab.ui.container.GridLayout
    end

    properties(Access=public,Constant)
        IMAGE_SIZE_PIXELS=120
        EXT_IMAGE_SIZE_PIXELS=150
        IMAGE_PATH=fullfile(matlabroot,'toolbox','rf','rf','+rf',...
        '+internal','+apps','+matchnet','Resources')
    end

    properties(Access=protected,Constant)
        ImageFile='07_custom@2x.png'
    end





    methods(Access=public)
        function this=ComponentView(parent,component)

            this.Parent=parent;
            this.Component=component;
        end

        function initialize(this)
            this.initializeLayout();
            this.setImage()
        end

        function uiobjectOut=getEditableControls(this,parent)%#ok<INUSL>
            uiobjectOut=uipanel(parent,'Title','Generic Component');
        end
    end








    methods(Access=protected)
        function initializeLayout(this)
            if isempty(this.Component)
                this.OverallLayout=uigridlayout(this.Parent,...
                'RowHeight',this.IMAGE_SIZE_PIXELS,...
                'ColumnWidth',2*this.IMAGE_SIZE_PIXELS,...
                'BackgroundColor','w');
            else
                this.OverallLayout=uigridlayout(this.Parent,...
                'RowHeight',this.EXT_IMAGE_SIZE_PIXELS,...
                'ColumnWidth',this.IMAGE_SIZE_PIXELS,...
                'ColumnSpacing',0,'Padding',[0,10,0,10],...
                'BackgroundColor','w');
            end
        end

        function setImage(this)
            this.ComponentImage=uiimage(this.OverallLayout,...
            'ImageSource',fullfile(this.IMAGE_PATH,this.ImageFile));
        end
    end
end
