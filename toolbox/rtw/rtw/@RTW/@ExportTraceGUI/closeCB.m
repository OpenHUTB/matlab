function closeCB(source,dialog,closeAction)





    switch lower(closeAction)

    case{'cancel','close'}


        source.delete;
    otherwise


    end
end


