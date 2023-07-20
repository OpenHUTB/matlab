function generateDataTipLiveCode(hTip,interactionType)



    ax=ancestor(hTip,'matlab.graphics.axis.AbstractAxes');
    matlab.graphics.interaction.generateLiveCode(ax,interactionType);
end

