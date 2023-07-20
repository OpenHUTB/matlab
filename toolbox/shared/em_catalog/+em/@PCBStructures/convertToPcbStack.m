function convertToPcbStack(obj,ant)




    if isa(ant,'em.MicrostripAntenna')||isa(ant,'em.BackingStructure')||...
        isa(ant,'fractalSnowflake')

        if getInfGPState(ant)
            error(message('antenna:antennaerrors:InfiniteGndNotSupportedForPcbStack'));
        end
    end

    allowedClass={'customArrayGeometry','customAntennaGeometry'...
    ,'dipole','dipoleBlade','bowtieTriangular','bowtieRounded',...
    'spiralArchimedean','spiralEquiangular','patchMicrostrip',...
    'patchMicrostripCircular','patchMicrostripInsetfed',...
    'invertedLcoplanar','invertedFcoplanar','slot','vivaldi',...
    'loopCircular','loopRectangular','reflector','reflectorCircular',...
    'patchMicrostripElliptical','spiralRectangular','linearArray',...
    'rectangularArray','circularArray','fractalGasket','fractalKoch',...
    'vivaldiOffsetCavity','rfpcb.Parts'};

    if isa(ant,'em.PrintedAntenna')
        tempObj=getPrintedStack(ant);
        obj.Name=tempObj.Name;
        obj.BoardShape=tempObj.BoardShape;
        obj.BoardThickness=tempObj.BoardThickness;
        obj.Layers=tempObj.Layers;
        obj.FeedLocations=tempObj.FeedLocations;
        obj.FeedDiameter=tempObj.FeedDiameter;
        obj.FeedViaModel=tempObj.FeedViaModel;
        obj.ViaLocations=tempObj.ViaLocations;
        obj.ViaDiameter=tempObj.ViaDiameter;
        obj.FeedVoltage=tempObj.FeedVoltage;
        obj.FeedPhase=tempObj.FeedPhase;
        obj.Tilt=tempObj.Tilt;
        obj.TiltAxis=tempObj.TiltAxis;
        obj.Load=tempObj.Load;
        obj.Conductor=ant.Conductor;
    elseif isa(ant,'rfpcb.Parts')
        tempObj=convertToRFComponent(ant);
        obj.Name=tempObj.Name;
        obj.BoardShape=tempObj.BoardShape;
        obj.BoardThickness=tempObj.BoardThickness;
        obj.Layers=tempObj.Layers;
        obj.FeedLocations=tempObj.FeedLocations;
        obj.FeedDiameter=tempObj.FeedDiameter;
        obj.FeedViaModel=tempObj.FeedViaModel;
        obj.ViaLocations=tempObj.ViaLocations;
        obj.ViaDiameter=tempObj.ViaDiameter;
        obj.FeedVoltage=tempObj.FeedVoltage;
        obj.FeedPhase=tempObj.FeedPhase;
        obj.Conductor=ant.Conductor;
    elseif any(strcmpi(class(ant),allowedClass))
        createPCBStack(ant,obj);
        if isa(ant,'em.Array')&&isprop(ant.Element,'Conductor')
            obj.Conductor=ant.Element.Conductor;
        elseif isprop(ant,'Conductor')
            obj.Conductor=ant.Conductor;
        end
    else
        error(message('antenna:antennaerrors:PcbStackConversionNotSupported',class(ant)));
    end
end
