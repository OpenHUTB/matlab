function connectCopyToTree(hObj,hCopy,hCopyParent,hContext)


    if(~hContext.willBeCopied(hObj.Axes_I))
        error(message('MATLAB:colorbar:AxesMustBeCopied'));
    end


    connectCopyToTree@matlab.graphics.primitive.world.Group(hObj,hCopy,[],hContext);


end
