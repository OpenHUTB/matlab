classdef(Abstract)DialogFigure<handle






    properties(GetAccess=public,SetAccess=protected)

        FigureHandle matlab.ui.Figure


        Size(1,2)double=[360,120];


        Title char='';

    end

    properties(Hidden)

        Location(1,2)double=[100,100];

    end

    properties(Access=protected)

        ButtonSize(1,2)double=[60,20];
        ButtonSpace(1,1)double=10;

    end

    methods(Abstract,Access=protected)

        keyPress(self,evt);

    end

    methods




        function self=DialogFigure(loc,dlgTitle)

            self.Location=loc;
            self.Title=dlgTitle;

        end




        function create(self)

            loc=imageslib.internal.app.utilities.ScreenUtilities.getModalDialogLocation(...
            self.Location,self.Size);

            self.FigureHandle=figure(...
            'Name',self.Title,...
            'Position',[loc,self.Size],...
            'Resize','off',...
            'Visible','off');

            addlistener(self.FigureHandle,'WindowKeyPress',@(src,evt)keyPress(self,evt));

            try %#ok<TRYNC>
                set(self.FigureHandle,'WindowStyle','modal');
            end

            movegui(self.FigureHandle,'onscreen');

        end




        function close(self)

            if ishandle(self.FigureHandle)
                close(self.FigureHandle);
            end

        end




        function wait(self)

            set(self.FigureHandle,'Visible','on');

            uiwait(self.FigureHandle);


        end

    end

end
