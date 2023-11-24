function updateVisualizations(pat,viewer,plotInViewer)

    if nargin<3
        plotInViewer=true;
    end

    scenario=pat.Scenario;

    patternGraphicID=pat.getGraphicID;
    if(~viewer.graphicExists(patternGraphicID))
        viewer.addGraphic(patternGraphicID,true);
    end

    addGraphicToClutterMap(pat,viewer);

    isPatternVisible=viewer.getGraphicVisibility(patternGraphicID);
    if(~isPatternVisible)&&plotInViewer
        return
    end


    size=pat.Size;
    cmap=pat.Colormap;
    resolution=pat.Resolution;
    transparency=pat.Transparency;
    trx=pat.Parent;
    fq=pat.Frequency;



    simIdx=getIdxInSimulatorStruct(trx);
    simulator=scenario.Simulator;
    if trx.Type==5
        fq=trx.Frequency;
        trxStruct=simulator.Transmitters(simIdx);
    else
        trxStruct=simulator.Receivers(simIdx);
    end

    if isa(trx.Antenna,'phased.internal.AbstractArray')
        originalTaper=trx.Antenna.Taper;
        switch trxStruct.PointingMode
        case 6
            trx.Antenna.Taper=conj(trxStruct.PhasedArrayWeights);
        case 5
            trx.Antenna.Taper=trxStruct.PhasedArrayWeightsDefault;
        otherwise
            stv=phased.SteeringVector('SensorArray',trx.Antenna);
            weights=stv(fq,trxStruct.PointingDirection);
            trx.Antenna.Taper=conj(weights);
        end
    end

    [yaw,pitch,roll]=satcom.satellitescenario.Pattern.ned2bodyframe(trx.Attitude);

    initializePatternData(pat,trx.Antenna,fq);


    if isa(trx.Antenna,'phased.internal.AbstractArray')
        trx.Antenna.Taper=originalTaper;
    end

    patternModel=satcom.satellitescenario.Pattern.createPatternModel(pat.PatternData,"Size",size,"Colormap",cmap,"Resolution",resolution);

    patternModel.YUpCoordinate=true;
    if plotInViewer
        viewer.GlobeViewer.geoModel3D(patternModel,[trx.pLatitude,trx.pLongitude,trx.pAltitude],...
        'Animation',"none",...
        'Persistent',false,...
        'Transparency',transparency,...
        'BoundingSphereRadius',size,...
        'ID',char(patternGraphicID),...
        'Rotation',[yaw,pitch,roll],...
        'ShowIn2D',true,...
        'FlashlightOn',false);
    else

        file=[tempname,'.glb'];
        writer=globe.internal.GLBFileWriter(file,patternModel.Model,'VertexColors',patternModel.VertexColors,...
        'EnableLighting',patternModel.EnableLighting,'YUpCoordinate',patternModel.YUpCoordinate,...
        'MetallicFactor',patternModel.MetallicFactor,'RoughnessFactor',patternModel.RoughnessFactor,...
        'Opacity',transparency);
        write(writer);
        patternModel.File=file;
    end


    pat.FileName=patternModel.File;
end


