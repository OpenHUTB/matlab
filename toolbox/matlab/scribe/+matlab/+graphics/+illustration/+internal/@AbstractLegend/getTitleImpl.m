function title=getTitleImpl(hObj,storedValue)




    if isscalar(storedValue)&&isvalid(storedValue)

        title=storedValue;
    else




        title=matlab.graphics.illustration.legend.Text;
        hObj.Title_I=title;


        title.Description_I='Legend Title';
        title.Internal=true;


        title.HorizontalAlignment='center';


        hObj.DecorationContainer.addNode(title);


        addlistener(title,'MarkedDirty',@(~,~)hObj.MarkDirty('all'));
        addlistener(title,'ObjectBeingDestroyed',@(~,~)hObj.MarkDirty('all'));


        hObj.MarkDirty('all');
    end

end
