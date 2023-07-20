function f=pickRefiningPolygon(w,metalLayer,locn)


    fx1=antenna.Shape.refiningpolygon(w,locn,'x1','Square');
    fx2=antenna.Shape.refiningpolygon(w,locn,'x2','Square');
    fy1=antenna.Shape.refiningpolygon(w,locn,'y1','Square');
    fy2=antenna.Shape.refiningpolygon(w,locn,'y2','Square');
    ftest={fx1,fx2,fy1,fy2};


    ftest{1}=antenna.Polygon('Name','x1Square','Vertices',ftest{1}.ShapeVertices);
    ftest{2}=antenna.Polygon('Name','x2Square','Vertices',ftest{2}.ShapeVertices);
    ftest{3}=antenna.Polygon('Name','y1Square','Vertices',ftest{3}.ShapeVertices);
    ftest{4}=antenna.Polygon('Name','y2Square','Vertices',ftest{4}.ShapeVertices);



    testpoly=antenna.Circle('Radius',2*max(w),'Center',locn);


    tf=contains(metalLayer,testpoly.ShapeVertices(:,1),testpoly.ShapeVertices(:,2));

    if all(tf)

        f=ftest{3};

    else
        tol=sqrt(eps);

        for i=1:4
            tf1_temp(:,i)=contains(metalLayer,ftest{i}.ShapeVertices(:,1),ftest{i}.ShapeVertices(:,2));
            if any(tf1_temp(:,i))&&~all(tf1_temp(:,i))

                [isFixed,fixedVertices]=em.internal.fixVertices(ftest{i}.ShapeVertices,metalLayer.ShapeVertices,tol);
                if isFixed
                    ftest{i}.Vertices=fixedVertices;

                    tf1_temp(:,i)=contains(metalLayer,ftest{i}.ShapeVertices(:,1),ftest{i}.ShapeVertices(:,2));
                end
            end
        end

        test_Tf=all(tf1_temp,1);

        if any(test_Tf)
            poly_choice=ftest(test_Tf);
            f=poly_choice{1};

        else



            ctr=1;
            for i=1:4
                try
                    tempe=intersect(metalLayer,ftest{i});
                    tempe_s{ctr}=tempe;
                    tf2_temp{ctr}=contains(metalLayer,tempe.ShapeVertices(:,1),tempe.ShapeVertices(:,2));
                    if any(tf2_temp{ctr})&&~all(tf2_temp{ctr})

                        [isFixed,fixedVertices]=em.internal.fixVertices(tempe.ShapeVertices,metalLayer.ShapeVertices,tol);
                        if isFixed
                            tempe.Vertices=fixedVertices;

                            tf2_temp{ctr}=contains(metalLayer,tempe.ShapeVertices(:,1),tempe.ShapeVertices(:,2));
                        end
                    end
                    ctr=ctr+1;
                catch ME
                    continue;
                end
            end
            test_Tf=cellfun(@(x)all(x),tf2_temp);
            if any(test_Tf)
                poly_choice=tempe_s(test_Tf);
                f=poly_choice{1};
            else
                error(message('antenna:antennaerrors:ImproperFeedCreation'));

            end

        end

    end
end