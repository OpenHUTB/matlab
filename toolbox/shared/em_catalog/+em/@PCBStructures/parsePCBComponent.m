function parsePCBComponent(obj,varargin)

    isPCBObjectInput=false;
    isShapeObjectInput=false;
    if~isempty(varargin)
        if isscalar(varargin)
            if isa(varargin{:},'rfpcb.PCBComponent')||isa(varargin{:},'rfpcb.PCBSubComponent')||isa(varargin{:},'rfpcb.PCBVias')
                rObj=getPrintedStack(varargin{:});
                varargin={};
                isPCBObjectInput=true;
            elseif get(varargin{:},'IsRFPCBPart')
                tempPcb=varargin{:};
                varargin={};
                isShapeObjectInput=true;
            end
        end
    end

    [m,d,g]=em.PCBStructures.createPCBDefaultLayers();
    parserObj=inputParser;
    addParameter(parserObj,'Name','MyPCB');
    addParameter(parserObj,'Revision','v1.0');
    addParameter(parserObj,'BoardShape',g);
    addParameter(parserObj,'BoardThickness',1.6e-3);
    addParameter(parserObj,'Connector','SMA');
    addParameter(parserObj,'Layers',[{m,d,g}]);
    addParameter(parserObj,'FeedLocations',[-m.Length/2,0,1,3;m.Length/2,0,1,3]);
    addParameter(parserObj,'FeedDiameter',m.Width/2);
    addParameter(parserObj,'ViaLocations',[]);
    addParameter(parserObj,'ViaDiameter',[]);
    addParameter(parserObj,'FeedViaModel','strip');
    addParameter(parserObj,'Substrate',d);


    addParameter(parserObj,'Tilt',0);
    addParameter(parserObj,'TiltAxis',[0,0,1]);
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


    obj.Tilt=parserObj.Results.Tilt;
    obj.TiltAxis=parserObj.Results.TiltAxis;
    obj.Load=parserObj.Results.Load;
    obj.Conductor=parserObj.Results.Conductor;
    obj.IsRefiningPolygon=true;
    if isShapeObjectInput
        convertToPCBComponent(tempPcb,obj)
    elseif isPCBObjectInput
        obj.Name=rObj.Name;
        obj.Revision=rObj.Revision;
        obj.BoardShape=rObj.BoardShape;
        obj.BoardThickness=rObj.BoardThickness;
        obj.Layers=rObj.Layers;
        obj.FeedLocations=rObj.FeedLocations;
        obj.FeedDiameter=rObj.FeedDiameter;
        obj.ViaLocations=rObj.ViaLocations;
        obj.ViaDiameter=rObj.ViaDiameter;
        obj.FeedViaModel=rObj.FeedViaModel;
        obj.Tilt=rObj.Tilt;
        obj.TiltAxis=rObj.TiltAxis;
        obj.Load=rObj.Load;
        obj.Conductor=rObj.Conductor;
    end
end