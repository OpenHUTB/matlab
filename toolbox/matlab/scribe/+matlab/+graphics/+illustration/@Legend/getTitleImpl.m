function title=getTitleImpl(hObj,storedValue)




    if isscalar(storedValue)&&isvalid(storedValue)

        title=storedValue;
    else




        title=matlab.graphics.illustration.legend.Text;
        hObj.Title_I=title;


        title.Description_I='Legend Title';
        title.Internal=true;


        title.HorizontalAlignment='center';


        if strcmp(hObj.version,'on')
            title.Visible='off';
        end


        hObj.DecorationContainer.addNode(title);




        addlistener(title,'MarkedDirty',@(h,e)doMethod(hObj,'doMarkDirty','all'));
        addlistener(title,'ObjectBeingDestroyed',@(h,e)doMethod(hObj,'doMarkDirty','all'));


        hObj.MarkDirty('all');
    end

end
