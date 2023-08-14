function[czmlFile,czmlFileID]=writeCZML(viewer)




    scenario=viewer.Scenario;


    times=scenario.Simulator.TimeHistory;
    times.TimeZone="";


    czmlFile={tempname};
    czmlFileID=czmlFile;
    count=1;


    [filePath,fileName]=fileparts(czmlFile);




    w=globe.animation.internal.CZMLWriter(fileName,filePath,...
    times(1),times(end));





    scenarioGraphics=scenario.ScenarioGraphics;
    numGraphics=numel(scenarioGraphics);
    for idx=1:numGraphics
        if idx~=1&&mod(idx,500)==0

            write(w);


            czmlFile{count}=fullfile(w.FilePath,[w.FileName,'.czml']);


            czmlFileID{count}=['satelliteScenarioAnimation',num2str(count)];


            [filePath,fileName]=fileparts(tempname);


            w=globe.animation.internal.CZMLWriter(fileName,filePath,...
            times(1),times(end));
            count=count+1;
        end

        obj=scenarioGraphics{idx};



        initiallyVisible=viewer.getGraphicVisibility(obj.getGraphicID);
        if~viewer.ShowDetails||initiallyVisible





            addCZMLGraphic(obj,w,times,initiallyVisible);
        end
    end


    write(w);


    czmlFile{count}=fullfile(w.FilePath,[w.FileName,'.czml']);


    for idx=1:numel(viewer.CZMLFile)
        if isfile(viewer.CZMLFile{idx})
            delete(viewer.CZMLFile{idx});
        end
    end


    czmlFileID{count}=['satelliteScenarioAnimation',num2str(count)];
    viewer.CZMLFile=czmlFile;
    viewer.CZMLFileID=czmlFileID;
end


