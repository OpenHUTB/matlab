function[varargout]=sim3dblkssharedicon(varargin)






    if nargin<2
        error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidUsage'));
    end


    action=varargin{1};
    block=varargin{2};

    sim3dblksshared(block);


    if nargin>=3
        context=varargin{3};
    end


    varargout{1}=0;


    switch action
    case 'sim3dblksconfig'
        varargout{1}=sim3dblksconfig(block,context);
    case 'sim3dblksactorget'
        varargout{1}=sim3dblksactorget(block,context);
    case 'sim3dblksactorset'
        varargout{1}=sim3dblksactorset(block,context);
    case 'sim3dblks3dbic'
        varargout{1}=sim3dblks3dbic(block,context);
    case 'sim3dblksrayget'
        varargout{1}=sim3dblksrayget(block,context);
    case 'sim3dblksrayset'
        varargout{1}=sim3dblksrayset(block,context);
    case 'sim3dblkspassrayset'
        varargout{1}=sim3dblkspassrayset(block,context);
    case 'sim3dblkscameraget'
        varargout{1}=sim3dblkscameraget(block,context);
    case 'sim3dblks3dvehterrfb'
        varargout{1}=sim3dblks3dvehterrfb(block,context);
    case 'sim3dblks3dped'
        varargout{1}=sim3dblks3dped(block,context);
    case 'sim3dblks3dveh'
        varargout{1}=sim3dblks3dveh(block,context);
    case 'sim3dblkscamerasensor'
        varargout{1}=sim3dblkscamerasensor(block,context);
    case 'sim3dblksfisheyecamsensor'
        varargout{1}=sim3dblksfisheyecamsensor(block,context);
    case 'sim3dblkslidarsensor'
        varargout{1}=sim3dblkslidarsensor(block,context);
    case 'sim3dblksprobabilisticradar'
        varargout{1}=sim3dblksprobabilisticradar(block,context);
    case 'sim3dblksmessageset'
        varargout{1}=sim3dblksmessageset(block,context);
    case 'sim3dblksmessageget'
        varargout{1}=sim3dblksmessageget(block,context);
    case 'sim3dblksprobabilisticradarconfig'
        varargout{1}=sim3dblksprobabilisticradarconfig(block,context);
    case 'sim3dblksdepthsensor'
        varargout{1}=sim3dblksdepthsensor(block,context);
    case 'sim3dblkssemanticsegmentation'
        varargout{1}=sim3dblkssemanticsegmentation(block,context);
    case 'sim3dblks3dvehterrfbVDBS'
        varargout{1}=sim3dblks3dvehterrfbVDBS(block,context);
    case 'sim3dblksvisiondetectiongenerator'
        varargout{1}=sim3dblksvisiondetectiongenerator(block,context);
    case 'sim3dblkstractor'
        varargout{1}=sim3dblkstractor(block,context);
    case 'sim3dblkstrailer'
        varargout{1}=sim3dblkstrailer(block,context);
    case 'sim3dblksdolly'
        varargout{1}=sim3dblksdolly(block,context);
    case 'sim3dblkshelpertrafficlightcontroller'
        varargout{1}=sim3dblkshelpertrafficlightcontroller(block,context);
    case 'sim3dblksaircraft'
        varargout{1}=sim3dblksaircraft(block,context);
    case 'sim3dblksraytracesensor'
        varargout{1}=sim3dblksraytracesensor(block,context);
    case 'sim3dblksmotorcycle'
        varargout{1}=sim3dblksmotorcycle(block,context);
    case 'sim3dblks3dphysvehVDBS'
        varargout{1}=sim3dblks3dphysvehVDBS(block,context);
    case 'sim3dblksstaticmeshactor'
        varargout{1}=sim3dblksstaticmeshactor(block,context);
    case 'sim3dblksultrasonicsensor'
        varargout{1}=sim3dblksultrasonicsensor(block,context);
    case 'sim3dblksultrasonicsensorarray'
        varargout{1}=sim3dblksultrasonicsensorarray(block,context);
    case 'sim3dblksterrainsensor'
        varargout{1}=sim3dblksterrainsensor(block,context);
    case 'sim3dblksgenericactor'
        varargout{1}=sim3dblksgenericactor(block,context);
    otherwise
        error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidBlock'));
    end
    if nargout==0
        clear('varargout');
    end
end
