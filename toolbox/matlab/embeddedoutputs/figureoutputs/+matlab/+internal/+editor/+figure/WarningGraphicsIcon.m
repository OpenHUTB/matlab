classdef WarningGraphicsIcon<handle




    properties(Access=private)
        Text matlab.graphics.primitive.Text
        Transform matlab.graphics.primitive.Transform
        Figure matlab.ui.Figure
ResizeListener
VisibilityListener
TextCamera
IconCamera
    end

    properties(Hidden)
WarningText
    end

    methods
        function this=WarningGraphicsIcon(hFig,msg)
            this.Figure=hFig;


            this.TextCamera=this.setupCamera();


            this.setupTextBox(msg);


            this.IconCamera=this.setupIconCamera();


            this.setupTexturedQuad();

            if~matlab.internal.editor.FigureManager.useEmbeddedFigures
                this.ResizeListener=event.listener(this.Figure,'SizeChanged',...
                @(hSrc,event)this.resizeCallback());
            else
                this.VisibilityListener=event.proplistener(this.Figure,findprop(this.Figure,'Visible'),'PostSet',...
                @(hSrc,event)this.figureVisibilityChanged());
            end
        end
    end


    methods(Access=private)


        function RGBA=getRGBA(this)%#ok<MANU>
            dims=size(matlab.internal.editor.figure.WarningGraphicsIcon.R);
            RGBA=zeros([4,dims(1),dims(2)],'uint8');
            RGBA(1,:,:)=flipud(matlab.internal.editor.figure.WarningGraphicsIcon.R);
            RGBA(2,:,:)=flipud(matlab.internal.editor.figure.WarningGraphicsIcon.G);
            RGBA(3,:,:)=flipud(matlab.internal.editor.figure.WarningGraphicsIcon.B);
            RGBA(4,:,:)=flipud(matlab.internal.editor.figure.WarningGraphicsIcon.A);
        end




        function hCam=setupIconCamera(this)

            hCam=this.setupCamera();

            scale=matlab.ui.internal.PositionUtils.getDevicePixelScreenSize()./get(groot,'ScreenSize');
            PixelScale=scale(3);

            [n,m]=size(matlab.internal.editor.figure.WarningGraphicsIcon.R);
            hCam.XLim=[0,n];
            hCam.YLim=[0,m];


            hCam.Viewport.Position(3)=PixelScale*n/this.Figure.Position(3);
            hCam.Viewport.Position(4)=PixelScale*m/this.Figure.Position(4);


            hCam.Viewport.Position(2)=this.Text.NodeParent.Viewport.Position(2)-hCam.Viewport.Position(4);
        end



        function hCam=setupCamera(this)

            hCam=matlab.graphics.axis.camera.Camera2D;
            hCam.Parent=this.Figure.getCanvas;
            hCam.Internal=1;

            hCam.Viewport.Position(1)=0.125;
            hCam.Viewport.Position(2)=0.9;

        end


        function setupTexturedQuad(this)

            hQuad=matlab.graphics.primitive.world.Quadrilateral;

            hQuad.VertexData=single([0.5000,14.5000,14.5000,0.5000
            0.5000,0.5000,15.5000,15.5000
            0,0,0,0]);

            hQuad.ColorData=single([0,0,1,1;0,1,1,0]);
            hQuad.ColorType='texturemapped';
            hQuad.ColorBinding='interpolated';

            tex=matlab.graphics.primitive.world.Texture;
            tex.ColorType='truecoloralpha';


            tex.CData=this.getRGBA();
            hQuad.Texture=tex;

            this.Transform=hgtransform('Parent',this.IconCamera);
            hQuad.Parent=this.Transform;
            this.resizeIcon();
        end

        function setupTextBox(this,msg)

            this.Text=matlab.graphics.primitive.Text('Interpreter','none');
            msg=strcat(['Warning: ',msg]);


            msg=strrep(msg,'\','\\');
            this.Text.String=regexprep(msg,'<.*?>','');
            this.Text.String=strtrim(this.Text.String);
            this.Text.String=strcat({blanks(6)},this.Text.String);

            this.Text.Units='normalized';

            this.Text.Position(1)=0;
            this.Text.Position(2)=0;
            this.Text.BackgroundColor=[255,246,229]/255;
            this.Text.EdgeColor=[255,170,0]/255;
            this.Text.Color=[64,64,64]/255;
            this.Text.Parent=this.TextCamera;
            this.TextCamera.Viewport.Position(3)=this.Text.Extent(3);
            this.TextCamera.Viewport.Position(4)=this.Text.Extent(4);


            this.Text.Position(2)=-this.Text.Extent(4)/2;

            this.resizeTextBox();

            this.WarningText=this.Text.String;
        end


        function resizeIcon(this)
            scale=localGetScaleFactor(this.Figure);
            scale=max(min(scale,1),0);
            this.Transform.Matrix=makehgtform('scale',scale)*makehgtform('translate',[2.5,-2.5,0]);
        end


        function resizeTextBox(this)




            scale=localGetScaleFactor(this.Figure);
            newFontSize=ceil(this.Text.FontSize*scale);
            this.Text.FontSize=max(min(newFontSize,get(0,'defaultTextFontSize')),get(0,'defaultTextFontSize')/2);
        end

        function figureVisibilityChanged(this)

            if strcmpi(this.Figure.Visible,'off')
                delete(this.TextCamera);
                delete(this.IconCamera);
                delete(this);
            end
        end

        function resizeCallback(this)
            this.resizeTextBox();
            this.resizeIcon();
        end
    end



    properties(Constant,Access=private)


        R=[0,0,0,0,0,255,255,255,255,0,0,0,0,0
        0,0,0,0,255,255,255,255,255,255,0,0,0,0
        0,0,0,0,255,255,255,255,255,255,0,0,0,0
        0,0,0,255,255,255,255,255,255,255,255,0,0,0
        0,0,0,255,255,255,255,255,255,255,255,0,0,0
        0,0,255,255,255,255,255,255,255,255,255,255,0,0
        0,0,255,255,255,255,255,255,255,255,255,255,0,0
        0,255,255,255,255,255,255,255,255,255,255,255,255,0
        0,255,255,255,255,255,255,255,255,255,255,255,255,0
        255,255,255,255,255,255,255,255,255,255,255,255,255,255
        255,255,255,255,255,255,255,255,255,255,255,255,255,255
        255,255,255,255,255,255,255,255,255,255,255,255,255,255
        255,255,255,255,255,255,255,255,255,255,255,255,255,255
        255,255,255,255,255,255,255,255,255,255,255,255,255,255
        255,255,255,255,255,255,255,255,255,255,255,255,255,255];

        G=[0,0,0,0,0,163,161,161,162,0,0,0,0,0
        0,0,0,0,158,161,161,161,161,162,0,0,0,0
        0,0,0,0,160,161,161,161,161,161,0,0,0,0
        0,0,0,161,161,161,255,255,161,161,158,0,0,0
        0,0,0,161,161,161,255,255,161,161,160,0,0,0
        0,0,163,161,161,161,255,255,161,161,161,165,0,0
        0,0,161,161,161,161,255,255,161,161,161,160,0,0
        0,157,161,161,161,161,255,255,161,161,161,161,166,0
        0,161,161,161,161,161,255,255,161,161,161,161,161,0
        156,161,161,161,161,161,161,161,161,161,161,161,161,146
        162,161,161,161,161,161,161,161,161,161,161,161,161,161
        160,161,161,161,161,161,255,255,161,161,161,161,161,160
        161,161,161,161,161,161,255,255,161,161,161,161,161,161
        161,161,161,161,161,161,161,161,161,161,161,161,161,160
        159,162,161,161,161,161,161,161,161,161,161,160,161,170];

        B=[0,0,0,0,0,0,0,0,0,0,0,0,0,0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0
        0,0,0,0,0,0,255,255,0,0,0,0,0,0
        0,0,0,0,0,0,255,255,0,0,0,0,0,0
        0,0,0,0,0,0,255,255,0,0,0,0,0,0
        0,0,0,0,0,0,255,255,0,0,0,0,0,0
        0,0,0,0,0,0,255,255,0,0,0,0,0,0
        0,0,0,0,0,0,255,255,0,0,0,0,0,0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0
        0,0,0,0,0,0,255,255,0,0,0,0,0,0
        0,0,0,0,0,0,255,255,0,0,0,0,0,0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0];


        A=[0,0,0,0,0,58,208,218,71,0,0,0,0,0
        0,0,0,0,29,239,255,255,242,30,0,0,0,0
        0,0,0,0,159,255,255,255,255,162,0,0,0,0
        0,0,0,38,252,255,255,255,255,251,34,0,0,0
        0,0,0,162,255,255,255,255,255,255,156,0,0,0
        0,0,36,252,255,255,255,255,255,255,250,31,0,0
        0,0,146,255,255,255,255,255,255,255,255,143,0,0
        0,26,248,255,255,255,255,255,255,255,255,246,20,0
        0,135,255,255,255,255,255,255,255,255,255,255,122,0
        18,242,255,255,255,255,255,255,255,255,255,255,230,7
        112,255,255,255,255,255,255,255,255,255,255,255,255,100
        194,255,255,255,255,255,255,255,255,255,255,255,255,194
        226,255,255,255,255,255,255,255,255,255,255,255,255,227
        165,255,255,255,255,255,255,255,255,255,255,255,255,159
        8,99,154,170,170,170,170,170,170,170,168,143,87,6];

    end
end


function scale=localGetScaleFactor(hFig)
    defaultFigurePos=get(0,'defaultFigurePosition');
    scale=hFig.Position(3)*hFig.Position(4)/(defaultFigurePos(3)*defaultFigurePos(4));
end



