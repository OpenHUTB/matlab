function updateAntennaPattern(tx)






    simObj=tx.Simulator;



    simID=getIdxInSimulatorStruct(tx);


    f=simObj.Transmitters(simID).Frequency;


    antennaType=simObj.Transmitters(simID).AntennaType;

    if antennaType==1
        if isempty(find(simObj.Transmitters(simID).AntennaPatternFrequency==f,1))



            an=simObj.Transmitters(simID).Antenna;
            r=simObj.Transmitters(simID).AntennaPatternResolution;
            [az,el]=getAzElMesh(r);
            g=pattern(an,f,az,el);
            [azMesh,elMesh]=meshgrid(az,el);
            s=struct('Azimuth',azMesh,'Elevation',elMesh,'Gain',g);
            simObj.Transmitters(simID).AntennaPattern=[simObj.Transmitters(simID).AntennaPattern,s];
            simObj.Transmitters(simID).AntennaPatternFrequency=[simObj.Transmitters(simID).AntennaPatternFrequency,f];
        end
    end



    for idx=1:simObj.NumLinks
        for idx2=1:numel(simObj.Links(idx).Sequence)-1
            if simObj.Links(idx).Sequence(idx2)==simObj.Transmitters(simID).ID&&simObj.Links(idx).NodeType(idx2+1)==6

                ind=simObj.SimIDMemo(simObj.Links(idx).Sequence(idx2+1));

                if simObj.Receivers(ind).AntennaType==1&&isempty(find(simObj.Receivers(ind).AntennaPatternFrequency==f,1))
                    an=simObj.Receivers(ind).Antenna;
                    r=simObj.Receivers(ind).AntennaPatternResolution;
                    [az,el]=getAzElMesh(r);
                    g=pattern(an,f,az,el);
                    [azMesh,elMesh]=meshgrid(az,el);
                    s=struct('Azimuth',azMesh,'Elevation',elMesh,'Gain',g);
                    simObj.Receivers(ind).AntennaPattern=[simObj.Receivers(ind).AntennaPattern,s];
                    simObj.Receivers(ind).AntennaPatternFrequency=[simObj.Receivers(ind).AntennaPatternFrequency,f];
                end
            end
        end
    end
end

function[az,el]=getAzElMesh(r)


    az=-180:r:180;
    if az(end)~=180
        az(end+1)=180;
    end
    el=-90:r:90;
    if el(end)~=90
        el(end+1)=90;
    end
end
