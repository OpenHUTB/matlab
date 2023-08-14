function parser=getSharedParamParser(filename,axVisibilityDefault)




    if nargin<2
        axVisibilityDefault='off';
    end


    defaults=struct('MarkerSize',6,'BackgroundColor',[0,0,0],'VerticalAxis','Z',...
    'VerticalAxisDir','Up','ColorSource','auto','AxesVisibility',axVisibilityDefault,...
    'Projection','perspective','ViewPlane','auto');

    try
        pointclouds.internal.pc.shs(filename);
    catch ME
        throwAsCaller(ME)
    end


    parser=inputParser;
    parser.CaseSensitive=false;
    parser.FunctionName=filename;

    parser.addParameter('MarkerSize',defaults.MarkerSize,...
    @(x)pointclouds.internal.pcui.validateMarkerSize(filename,x));

    parser.addParameter('VerticalAxis',defaults.VerticalAxis,...
    @(x)pointclouds.internal.pcui.validateVerticalAxis(filename,x));

    parser.addParameter('VerticalAxisDir',defaults.VerticalAxisDir,...
    @(x)pointclouds.internal.pcui.validateVerticalAxisDir(filename,x));

    parser.addParameter('BackgroundColor',defaults.BackgroundColor,...
    @(x)pointclouds.internal.pcui.validateBackgroundColor(filename,x));

    parser.addParameter('ViewPlane',defaults.ViewPlane,...
    @(x)pointclouds.internal.pcui.validateViewPlane(filename,x));

    parser.addParameter('AxesVisibility',defaults.AxesVisibility,...
    @(x)pointclouds.internal.pcui.validateAxesVisibility(filename,x));

    parser.addParameter('Projection',defaults.Projection,...
    @(x)pointclouds.internal.pcui.validateProjection(filename,x));

    parser.addParameter('ColorSource',defaults.ColorSource,...
    @(x)pointclouds.internal.pcui.validateColorSource(filename,x));






