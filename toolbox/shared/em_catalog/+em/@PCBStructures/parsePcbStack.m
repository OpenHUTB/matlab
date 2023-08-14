function parsePcbStack(obj,varargin)

    isObjectInput=false;
    if~isempty(varargin)
        if isscalar(varargin)
            if cellfun(@(x)isa(x,'em.Antenna'),varargin)||...
                any(cell2mat(cellfun(@(x)strcmpi(class(x),{'linearArray','rectangularArray','circularArray'}),varargin,'UniformOutput',false)))
                tempAnt=varargin{:};
                varargin={};
                isObjectInput=true;

            else
                tempAnt=varargin{:};
                excludeClass={'conformalArray','installedAntenna','platform',...
                'customArrayMesh','dielectric','customAntennaStl'};

                if isa(tempAnt,'customArrayGeometry')
                    varargin={};
                    isObjectInput=true;
                elseif any(strcmpi(class(tempAnt),excludeClass))
                    error(message('antenna:antennaerrors:PcbStackConversionNotSupported','object'));
                end
            end
        end
    end

    [p,g]=em.PCBStructures.createDefaultLayers();
    parserObj=inputParser;
    addParameter(parserObj,'Name','MyPCB');
    addParameter(parserObj,'Revision','v1.0');
    addParameter(parserObj,'BoardShape',g);
    addParameter(parserObj,'BoardThickness',1e-2);
    addParameter(parserObj,'Connector','SMA');
    addParameter(parserObj,'Layers',[{p,g}]);
    addParameter(parserObj,'FeedLocations',[-0.0187,0,1,2]);
    addParameter(parserObj,'FeedDiameter',1e-3);
    addParameter(parserObj,'ViaLocations',[]);
    addParameter(parserObj,'ViaDiameter',[]);
    addParameter(parserObj,'FeedViaModel','strip');
    addParameter(parserObj,'Substrate',dielectric('Name','mydiel','EpsilonR',1,'Thickness',1e-2));
    addParameter(parserObj,'FeedVoltage',1);
    addParameter(parserObj,'FeedPhase',0);
    addParameter(parserObj,'Tilt',0);
    addParameter(parserObj,'TiltAxis',[1,0,0]);
    addParameter(parserObj,'Load',lumpedElement);
    addParameter(parserObj,'Conductor',metal('PEC'));
    parse(parserObj,varargin{:});
    obj.Name=parserObj.Results.Name;
    obj.Revision=parserObj.Results.Revision;
    obj.BoardShape=parserObj.Results.BoardShape;
    obj.BoardThickness=parserObj.Results.BoardThickness;

    obj.Layers=parserObj.Results.Layers;
    obj.FeedLocations=parserObj.Results.FeedLocations;
    obj.FeedDiameter=parserObj.Results.FeedDiameter;
    obj.ViaLocations=parserObj.Results.ViaLocations;
    obj.ViaDiameter=parserObj.Results.ViaDiameter;

    obj.FeedViaModel=parserObj.Results.FeedViaModel;
    obj.FeedVoltage=parserObj.Results.FeedVoltage;
    obj.FeedPhase=parserObj.Results.FeedPhase;
    obj.Tilt=parserObj.Results.Tilt;
    obj.TiltAxis=parserObj.Results.TiltAxis;
    if isa(obj,'pcbStack')
        obj.Load=parserObj.Results.Load;
        obj.Conductor=parserObj.Results.Conductor;
    end
    obj.IsRefiningPolygon=true;
    if isObjectInput
        convertToPcbStack(obj,tempAnt);
    end
end