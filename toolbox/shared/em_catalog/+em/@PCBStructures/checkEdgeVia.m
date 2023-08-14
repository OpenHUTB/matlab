function[isEdgeVia,tf]=checkEdgeVia(obj)
    isEdgeVia=false;
    if isequal(size(obj.modifiedViaLocations,2),4)
        if isempty(obj.BoardShape.ShapeVertices)
            isEdgeVia=false;
            tf=bool(zeros(1,numel(obj.modifieViaLocation(:,1))));
        else

            [~,tf]=inpolygon(obj.modifiedViaLocations(:,1),obj.modifiedViaLocations(:,2),obj.BoardShape.ShapeVertices(:,1),obj.BoardShape.ShapeVertices(:,2));
            if all(tf)
                isEdgeVia=true;
            else



                TR1=triangulation(obj.BoardShape.InternalPolyShape);
                e1=freeBoundary(TR1);
                for i=1:size(obj.ViaLocations,1)
                    v=obj.ViaLocations(i,:);
                    tf(i)=false;
                    [~,index1]=em.MeshGeometry.findEdgeThroughPoint(TR1.Points,e1,v(1:2));
                    if~isempty(index1)
                        tf(i)=true;
                    else
                        TR2=triangulation(obj.Layers{v(3)}.InternalPolyShape);
                        TR3=triangulation(obj.Layers{v(4)}.InternalPolyShape);
                        e2=freeBoundary(TR2);
                        e3=freeBoundary(TR3);
                        [~,index2]=em.MeshGeometry.findEdgeThroughPoint(TR2.Points,e2,v(1:2));
                        [~,index3]=em.MeshGeometry.findEdgeThroughPoint(TR3.Points,e3,v(1:2));
                        if~isempty(index2)||~isempty(index3)
                            tf(i)=true;
                        end
                    end
                    if all(tf)
                        isEdgeVia=true;
                    end
                end
            end
        end

    end