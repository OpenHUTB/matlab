



classdef(Abstract)OkCanceDialog<lidar.internal.lidarViewer.view.dialog.helper.Dialog

    properties(Access=protected)

        OkButton matlab.ui.control.Button


        CancelButton matlab.ui.control.Button
    end

    properties(Access=protected)

        ButtonSize(1,2)int32=[80,30]

        OkButtonPos(1,4)int32

        CancelButtonPos(1,4)int32
    end

    methods



        function this=OkCanceDialog(title,size)

            this=this@lidar.internal.lidarViewer.view.dialog.helper.Dialog(title,size);

            this.calculatePosition();

            this.createOkButton();
            this.createCancelButton();
        end
    end




    methods(Access=private)

        function calculatePosition(this)

            mainFigDim=this.MainFigure.Position(3:4);

            margin=mainFigDim(2)/10;


            this.OkButtonPos=[mainFigDim(1)/2-margin/2-this.ButtonSize(1),margin,this.ButtonSize];


            this.CancelButtonPos=[mainFigDim(1)/2+margin/2...
            ,margin,this.ButtonSize];
        end


        function createOkButton(this)

            this.OkButton=uibutton(this.MainFigure,...
            'Text',getString(message('MATLAB:uistring:popupdialogs:OK')),...
            'Position',this.OkButtonPos,...
            'ButtonPushedFcn',@(~,~)this.okClicked,...
            'Tag','okBttn');
        end


        function createCancelButton(this)

            this.CancelButton=uibutton(this.MainFigure,...
            'Text',getString(message('MATLAB:uistring:popupdialogs:Cancel')),...
            'Position',this.CancelButtonPos,...
            'ButtonPushedFcn',@(~,~)this.cancelClicked(),...
            'Tag','cancelBttn');
        end
    end




    methods(Access=protected)
        function okClicked(this)
            this.close();
        end


        function cancelClicked(this)
            this.close();
        end
    end
end