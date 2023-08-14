function updateAntennaPatterns(simObj)





    for idx=1:simObj.NumTransmitters
        if simObj.Transmitters(idx).AntennaType==1
            an=simObj.Transmitters(idx).Antenna;
            f=simObj.Transmitters(idx).Frequency;
            r=simObj.Transmitters(idx).AntennaPatternResolution;
            [az,el]=getAzElMesh(r);
            g=pattern(an,f,az,el);
            [azMesh,elMesh]=meshgrid(az,el);
            simObj.Transmitters(idx).AntennaPattern=struct('Azimuth',azMesh,'Elevation',elMesh,'Gain',g);
            simObj.Transmitters(idx).AntennaPatternFrequency=f;
        end
    end


    s=matlabshared.satellitescenario.internal.Simulator.antennaPatternStruct;
    for idx=1:simObj.NumReceivers
        if simObj.Receivers(idx).AntennaType==1
            simObj.Receivers(idx).AntennaPattern=s;
            simObj.Receivers(idx).AntennaPatternFrequency=zeros(1,0);
        end
    end


    for idx=1:simObj.NumLinks
        for idx2=1:numel(simObj.Links(idx).Sequence)-1
            if simObj.Links(idx).NodeType(idx2)==5&&simObj.Links(idx).NodeType(idx2+1)==6
                ind=simObj.SimIDMemo(simObj.Links(idx).Sequence(idx2));
                f=simObj.Transmitters(ind).Frequency;
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

