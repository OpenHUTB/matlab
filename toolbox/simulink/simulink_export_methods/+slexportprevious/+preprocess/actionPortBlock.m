function actionPortBlock(obj)




    if isReleaseOrEarlier(obj.ver,'R2019a')



        obj.appendRule('<Block<BlockType|ActionPort><ActionPortLabel:remove>>');
    end

