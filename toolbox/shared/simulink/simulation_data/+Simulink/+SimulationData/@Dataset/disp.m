function disp(this)



    if length(this)~=1
        Simulink.SimulationData.utNonScalarDisp(this);
        return;
    end

    len=this.numElements();
    hotlinks=feature('hotlinks');


    if hotlinks
        if len~=1
            dispHeading=message('SimulationData:Objects:DatasetHeading',this.Name,len);
        else
            dispHeading=message('SimulationData:Objects:DatasetHeadingSingleElement',this.Name);
        end
    else
        if len~=1
            dispHeading=message('SimulationData:Objects:DatasetHeadingNoHotlinks',this.Name,len);
        else
            dispHeading=message('SimulationData:Objects:DatasetHeadingNoHotlinksSingleElement',this.Name);
        end
    end
    fprintf([dispHeading.getString(),'\n']);

    displayElements(this);


    mObj=message('SimulationData:Objects:DatasetDispHelp');
    fprintf('\n  %s\n',mObj.getString);

    fprintf('\n');
end

