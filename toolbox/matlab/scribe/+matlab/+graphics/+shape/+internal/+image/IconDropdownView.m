classdef IconDropdownView<matlab.graphics.shape.internal.image.IconView

    properties(Constant)
        DecorationWidth=4;

        IconHeightPadding=8;
        IconWidthPadding=16;


        IconMaxSize=64;
    end

    methods

        function icon=addDecoration(obj)
            icon=obj.Icon;


            dims=size(icon);



            width=round(obj.IconWidthPadding*(dims(1)/obj.IconMaxSize));
            height=round(obj.IconHeightPadding*(dims(2)/obj.IconMaxSize));


            icon(end+height,end+width)=0;
            icon(icon==0)=obj.MaxIndex;


            len=round(dims(1)*.25);


            for i=len:-1:0
                icon(end-i,end-(len-i):end)=obj.MinIndex;
            end
        end
    end
end

