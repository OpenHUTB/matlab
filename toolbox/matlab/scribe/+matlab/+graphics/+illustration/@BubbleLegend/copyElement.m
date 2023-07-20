function hCopy=copyElement(hSrc)




    hCopy=copyElement@matlab.graphics.illustration.internal.AbstractLegend(hSrc);



    hCopy.BubbleContainer_I=matlab.graphics.primitive.Marker;

    set(hCopy.BubbleContainer,'Description_I','BubbleLegend BubbleContainer');

    set(hCopy.BubbleContainer,'Internal',true);

    hCopy.Axle=matlab.graphics.primitive.world.LineStrip;

    set(hCopy.Axle,'Description_I','BubbleLegend Axle');

    set(hCopy.Axle,'Internal',true);

    hCopy.Bubbles=matlab.graphics.primitive.world.Marker;

    set(hCopy.Bubbles,'Description_I','BubbleLegend Bubbles');

    set(hCopy.Bubbles,'Internal',true);

    hCopy.LabelBig=matlab.graphics.primitive.world.Text;

    set(hCopy.LabelBig,'Description_I','BubbleLegend LabelBig');

    set(hCopy.LabelBig,'Internal',true);

    hCopy.LabelMedium=matlab.graphics.primitive.world.Text;

    set(hCopy.LabelMedium,'Description_I','BubbleLegend LabelMedium');

    set(hCopy.LabelMedium,'Internal',true);

    hCopy.LabelSmall=matlab.graphics.primitive.world.Text;

    set(hCopy.LabelSmall,'Description_I','BubbleLegend LabelSmall');

    set(hCopy.LabelSmall,'Internal',true);


    hCopy.doSetup;


end
