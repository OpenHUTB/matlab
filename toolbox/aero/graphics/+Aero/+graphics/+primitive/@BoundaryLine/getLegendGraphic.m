function graphic=getLegendGraphic(hObj)



    graphic=matlab.graphics.primitive.world.Group;


    line=copyobj(hObj.LineHandle,graphic);
    line.VertexData=single(...
    [0.2,1;
    0.7,0.7;
    0,0;...
    ]);
    line.StripData=uint32([1,3]);



    hatch=copyobj(hObj.HatchHandle,graphic);
    hatchVData=single(hObj.calculateHatchVertexData([0.2,1;0.7,0.7;0,0],0.4,0.6,250));

    hatch.VertexData=hatchVData;
    hatch.StripData=uint32(1:2:size(hatchVData,2)+1);

    marker=copyobj(hObj.MarkerHandle,graphic);
    marker.VertexData=hatchVData;

    marker.Size=4;
