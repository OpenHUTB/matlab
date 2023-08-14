function doWebReset(ax)






    axes_properties={'CameraViewAngle',...
    'CameraPosition',...
    'CameraTarget',...
    'CameraUpVector',...
    'XLim',...
    'YLim',...
    'ZLim'};


    for i=1:numel(axes_properties)
        mode=[axes_properties{i},'Mode'];
        set(ax,mode,'auto');
    end


    if isprop(ax,'InteractionContainer')&&ax.InteractionContainer.Ever3d
        view(ax,3);
    end

end

