



classdef(Abstract)Dialog<handle

    properties(Access=protected)

Title


        Size(1,2)double=[360,120];


        MainFigure matlab.ui.Figure
    end

    methods



        function this=Dialog(title,size)
            this.Title=title;
            this.Size=size;

            this.createMainFigure();
        end




        function open(this)
            this.MainFigure.Visible='on';
        end




        function close(this)
            delete(this.MainFigure);
        end




        function wait(this)
            if~isempty(this.MainFigure)
                uiwait(this.MainFigure);
            end
        end
    end




    methods(Access=private)
        function createMainFigure(this)

            this.MainFigure=uifigure(...
            'Name',this.Title,...
            'Position',[100,100,this.Size],...
            'IntegerHandle','off',...
            'NumberTitle','off',...
            'MenuBar','none',...
            'WindowStyle','modal',...
            'Visible','off',...
            'Resize','off');

            movegui(this.MainFigure,'center');
        end
    end




    methods(Static,Hidden)

        function[screenWidth,screenHeight]=getScreenDim()


            screenSize=get(0,'ScreenSize');
            screenWidth=screenSize(3);
            screenHeight=screenSize(4);
        end
    end
end
