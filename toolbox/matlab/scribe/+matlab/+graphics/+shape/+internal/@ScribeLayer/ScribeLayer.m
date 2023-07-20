classdef(ConstructOnLoad=false,Sealed)ScribeLayer<matlab.graphics.primitive.world.Group









    properties
        Pane=matlab.graphics.shape.internal.AnnotationPane.empty;



        AddedListener;
        RemovedListener;
        RemovedOrDeletedListener;



    end
    methods
        function hObj=ScribeLayer(name,pane)
            hObj.Description=name;
            if~strcmp(name,'middle')


                if isempty(pane)

                    hObj.Pane=matlab.graphics.shape.internal.AnnotationPane;






                    hObj.Pane.Serializable='off';
                else
                    hObj.Pane=pane;
                end
                addNode(hObj,hObj.Pane);
            else



                hObj.AddedListener=hObj.addlistener('ChildAdded',@(src,event)hObj.childAdded(src,event));
                hObj.RemovedListener=hObj.addlistener('ChildRemoved',@(src,event)hObj.childRemoved(src,event));



                hObj.RemovedOrDeletedListener=hObj.addlistener('ObjectChildRemoved',@(src,event)hObj.childRemovedOrDeleted(src,event));



            end
        end

        function checkValidity(hObj)
            if strcmp('middle',hObj.Description)
                return;
            end
            if isempty(hObj.Pane)||~isvalid(hObj.Pane)
                delete(hObj.Pane);
                hObj.Pane=matlab.graphics.shape.internal.AnnotationPane;
                addNode(hObj,hObj.Pane);
            else
                if isempty(hgGetTrueChildren(hObj))
                    addNode(hObj,hObj.Pane);
                end
            end
        end




        function canvas=findCanvas(hObj)
            canvas=hObj.NodeParent;
        end














        function childAdded(hObj,src,data)
            canvas=hObj.findCanvas();
            if(isobject(canvas))
                if class(data.ChildNode)=="matlab.graphics.axis.Axes"
                    canvas.notify('LegacyChildAdded',matlab.graphics.eventdata.ChildEventData(canvas,data.ChildNode));
                elseif class(data.ChildNode)=="matlab.graphics.shape.internal.AxesLayoutManager"
                    canvas.notify('LegacyChildAdded',matlab.graphics.eventdata.ChildEventData(canvas,data.ChildNode.Axes));
                end
                childAdded=true;
                canvas.childAddedOrRemoved(data.ChildNode,childAdded);
            end
        end



        function childRemoved(hObj,src,data)%#ok<INUSL>
            canvas=hObj.findCanvas();
            if(isobject(canvas))
                if class(data.ChildNode)=="matlab.graphics.axis.Axes"
                    canvas.notify('LegacyChildRemoved',matlab.graphics.eventdata.ChildEventData(canvas,data.ChildNode));
                elseif class(data.ChildNode)=="matlab.graphics.shape.internal.AxesLayoutManager"
                    canvas.notify('LegacyChildRemoved',matlab.graphics.eventdata.ChildEventData(canvas,data.ChildNode.Axes));
                end
            end
        end

        function childRemovedOrDeleted(hObj,src,data)%#ok<INUSL>
            canvas=hObj.findCanvas();
            if(isobject(canvas))
                childRemoved=true;
                childAdded=~childRemoved;
                canvas.childAddedOrRemoved(data.Child,childAdded);
            end
        end

        function delete(hObj)
            delete(hObj.AddedListener);
            delete(hObj.RemovedListener);
            delete(hObj.RemovedOrDeletedListener);
        end



    end
end

