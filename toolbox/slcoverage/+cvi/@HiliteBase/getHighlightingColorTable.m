function colorT=getHighlightingColorTable






    persistent colorTable;
    if isempty(colorTable)

        green=[226,242,218]./255;
        greenStroke=[108/255,190/255,69/255];
        red=[255/255,180/255,180/255];
        redStroke=[219/255,88/255,88/255];
        gray=[224/255,224/255,224/255];
        grayStroke=[112/255,112/255,112/255];
        fade=[205,205,205]./255;
        colorTable.slRed=red;
        colorTable.slRedStroke=redStroke;
        colorTable.slGreen=green;
        colorTable.slGreenStroke=greenStroke;
        colorTable.slGray=gray;
        colorTable.slGrayStroke=grayStroke;
        colorTable.slStrokeWidth=2.0;
        colorTable.slFade=fade;
        colorTable.slFadeText=[0.5,0.5,0.5];
        colorTable.slFadeStroke=[0.6,0.6,0.6];


        colorTable.slLightGreen=colorTable.slGreen;

        colorTable.sfRed=[0.9,0,0];
        colorTable.sfRedGlow=colorTable.slRedStroke;
        colorTable.sfGreen=[0,128,0]./255;
        colorTable.sfLightBlue=[37,116,169]./255;
        colorTable.sfGray=colorTable.slFadeStroke;
        colorTable.lightGray=colorTable.slFade;
        colorTable.sfStrokeWidth=colorTable.slStrokeWidth;
    end
    colorT=colorTable;
end
