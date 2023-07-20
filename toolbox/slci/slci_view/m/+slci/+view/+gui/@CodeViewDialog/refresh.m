


function refresh(obj,editor,target)

    src=slcireview.internal.getSource(editor);

    message.publish(['/',obj.getChannel,'/',src.modelName],target);
