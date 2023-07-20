function sceneRectInView(obj)




    if isR2019aOrEarlier(obj.ver)

        obj.appendRule('<SceneRectInView:remove>');
    end

end
