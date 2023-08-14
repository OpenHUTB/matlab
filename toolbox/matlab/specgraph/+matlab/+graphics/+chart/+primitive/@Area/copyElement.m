function hCopy=copyElement(hSrc)



    hCopy=copyElement@matlab.graphics.primitive.Data(hSrc);


    if hCopy.NumPeers>1
        addlistener(hCopy,{'XData','YData','XDataMode','BaseValue'},'PostSet',@(~,~)hCopy.markSeriesDirty);
    end

end
