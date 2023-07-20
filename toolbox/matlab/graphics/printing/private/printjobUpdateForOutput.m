function pj=printjobUpdateForOutput(pj)









    fig=pj.Handles{1};




    if any(strcmp(pj.Driver,{'epsc2','psc2'}))
        pj.Driver=strrep(pj.Driver,'c2','2c');
    end


    if pj.FillPage
        LocalFillPage(pj)
    elseif pj.BestFit
        LocalBestFitPage(pj);
    end


    if isfield(pj.temp,'testDPIadjustment')&&pj.temp.testDPIadjustment







        outputSize=get(fig,'PaperPosition');
        paperSize=get(fig,'PaperSize');
    else



        if strcmpi(get(fig,'PaperUnits'),'normalized')


            set(fig,'PaperUnits','inches');
            paperSize=get(fig,'PaperSize');
            outputSize=get(fig,'PaperPosition');
            set(fig,'PaperUnits','normalized');
        else




            pSize=hgconvertunits(fig,[0,0,get(fig,'PaperSize')],...
            get(fig,'PaperUnits'),'inches',groot);
            paperSize=pSize(3:4);
            outputSize=hgconvertunits(fig,get(fig,'PaperPosition'),...
            get(fig,'PaperUnits'),'inches',groot);
        end
    end


    pj.temp.InchesOutputPosition=outputSize;




    pj.PixelOutputPosition=round(outputSize*pj.ScreenDPI);

    if any(pj.PixelOutputPosition(3:4)<1)
        error(message('MATLAB:print:InvalidOutputSize'));
    end



    poSize=pj.PixelOutputPosition(3:4);
    scSize=pj.temp.ScreenSizeInPixels;

    widthAdjustment=1;
    heightAdjustment=1;
    if poSize(1)>scSize(1)

        aspectHtoW=poSize(2)/poSize(1);


        pj.PixelOutputPosition(3)=scSize(1);
        pj.PixelOutputPosition(4)=pj.PixelOutputPosition(3)*aspectHtoW;
        widthAdjustment=poSize(1)/scSize(1);


        poSize=pj.PixelOutputPosition(3:4);
    end
    if poSize(2)>scSize(2)

        aspectWtoH=poSize(1)/poSize(2);


        pj.PixelOutputPosition(4)=scSize(2);
        pj.PixelOutputPosition(3)=pj.PixelOutputPosition(4)*aspectWtoH;
        heightAdjustment=poSize(2)/scSize(2);
    end


    pj.temp.dpiAdjustment=widthAdjustment*heightAdjustment;


    pixPos=pj.PixelOutputPosition;


    pixPos=matlab.ui.internal.PositionUtils.getPixelRectangleInPlatformPixels(pixPos,...
    fig);

    pj.Desired_Width=pixPos(3);
    pj.Desired_Height=pixPos(4);

    pj.Orientation=get(fig,'PaperOrientation');


    pj.PaperPosition_X=outputSize(1);
    pj.PaperPosition_Y=outputSize(2);
    pj.PaperPosition_Width=outputSize(3);
    pj.PaperPosition_Height=outputSize(4);

    pj.PaperSize_Width=paperSize(1);
    pj.PaperSize_Height=paperSize(2);

    pj.PaperType=get(fig,'PaperType');

end



function LocalFillPage(pj)

    margin=.25;
    fig=pj.Handles{1};
    oldPPUnits=fig.PaperUnits;
    fig.PaperUnits='inches';
    fig.PaperPosition(1)=margin;
    fig.PaperPosition(2)=margin;
    fig.PaperPosition(3)=fig.PaperSize(1)-2*margin;
    fig.PaperPosition(4)=fig.PaperSize(2)-2*margin;
    if isfield(pj.temp,'PaperPositionModeAuto')
        pj.temp.PaperPositionModeAuto=false;
    end
    fig.PaperUnits=oldPPUnits;
end

function LocalBestFitPage(pj)

    margin=.25;
    fig=pj.Handles{1};

    oldPPUnits=fig.PaperUnits;
    fig.PaperUnits='inches';


    figWidth=fig.Position(3);
    figHeight=fig.Position(4);
    paperWidth=fig.PaperSize(1);
    paperHeight=fig.PaperSize(2);

    if figWidth>figHeight


        aspect=figHeight/figWidth;
        desiredWidth=paperWidth-(2*margin);

        desiredHeight=desiredWidth*aspect;
        if desiredHeight>paperHeight

            desiredWidth=desiredWidth*((paperHeight-margin)/desiredHeight);
            desiredHeight=desiredWidth*aspect;
        end
    else


        aspect=figWidth/figHeight;

        desiredHeight=paperHeight-(2*margin);

        desiredWidth=desiredHeight*aspect;
        if desiredWidth>paperWidth

            desiredHeight=desiredHeight*((paperWidth-margin)/desiredWidth);
            desiredWidth=desiredHeight*aspect;
        end
    end


    xmargin=(paperWidth-desiredWidth)/2;
    ymargin=(paperHeight-desiredHeight)/2;
    fig.PaperPosition=[xmargin,ymargin,desiredWidth,desiredHeight];

    if isfield(pj.temp,'PaperPositionModeAuto')
        pj.temp.PaperPositionModeAuto=false;
    end
    fig.PaperUnits=oldPPUnits;
end
