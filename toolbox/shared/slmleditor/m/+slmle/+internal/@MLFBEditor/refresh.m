function refresh(obj,uid)




    data=[];
    if nargin>2
        data.uid=uid;
    end

    if Stateflow.Utils.isInDiagram(obj.objectId)
        [bool,text]=getTextIfAlreadyOpened(obj);
        if bool
            data.text=text;
        else
            data.text=slmle.internal.object2Data(obj.objectId,'getScript');
        end
        obj.fText=data.text;
        obj.publish('refresh',data);
    end



    function[bool,text]=getTextIfAlreadyOpened(obj)



        bool=false;
        text=[];
        m=slmle.internal.slmlemgr.getInstance;

        if m.MLFBEditorMap.isKey(obj.objectId)
            list=m.MLFBEditorMap(obj.objectId);
            for i=1:length(list)
                ed=list{i};
                if isvalid(ed.ed)&&ed.blkH==obj.blkH&&ed.eid~=obj.eid
                    bool=true;
                    text=ed.Text;
                    return;
                end
            end
        end
