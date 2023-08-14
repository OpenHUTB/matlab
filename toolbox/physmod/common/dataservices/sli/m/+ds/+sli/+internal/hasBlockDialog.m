function hasDialog=hasBlockDialog(sid)











    if Simulink.ID.isValid(sid)

        bh=Simulink.ID.getHandle(sid);



        hasDialog=~strcmp(get_param(bh,'BlockType'),'SubSystem');


        if~hasDialog&&strcmp(get_param(bh,'Mask'),'on')
            mo=get_param(bh,'MaskObject');
            hasDialog=mo.isMaskWithDialog();
        end
    else

        hasDialog=true;
    end

end
