function func=createStandardStringStrategy()







    func=@localStandardUpdateStrategy;

end


function localStandardUpdateStrategy(hObj,hCursor,hTipHandle)

    try


        setStringFromCursor(hCursor,hTipHandle);
    catch



        DelayedUpdateListener=addlistener(hObj,'MarkedClean',@(s,e)nDelayedUpdateString());


    end

    function nDelayedUpdateString()

        delete(DelayedUpdateListener);

        if isvalid(hTipHandle)&&isvalid(hCursor)
            try
                setStringFromCursor(hCursor,hTipHandle)
            catch E



                str=E.message;
                hTipHandle.String=strtrim(str);
            end
        end
    end
end


function setStringFromCursor(hCursor,hTipHandle)

    hDescriptors=hCursor.getDataDescriptors;




    hTipHandle.setFormattedTextString(hDescriptors);
end