classdef AxesInteractor<matlab.uiautomation.internal.interactors.AbstractAxesInteractor&...
    matlab.uiautomation.internal.interactors.SelctionTypeInteractorHelper




    methods

        function uipress(actor,varargin)
            import matlab.uiautomation.internal.Modifiers;
            import matlab.uiautomation.internal.Buttons;

            parser=actor.parseInputs(varargin{:});

            if ismember("Position",parser.UsingDefaults)
                pt=actor.parseCoordinatesAndGetPoint();
            else
                pt=actor.parseCoordinatesAndGetPoint(parser.Results.Position);
            end

            [axesID,container]=actor.getAxesDispatchData();

            args={'axesType','Axes','axesID',axesID,'X',pt(1),'Y',pt(2),'Z',pt(3)};

            selectionType=actor.validateSelectionType(parser.Results.SelectionType);

            switch selectionType
            case 'extend'
                modifier=Modifiers.SHIFT;
                actor.Dispatcher.dispatch(container,'uipress',args{:},'Modifier',modifier);
            case 'alt'
                button=Buttons.RIGHT;
                actor.Dispatcher.dispatch(container,'uipress',args{:},'Button',button);
            case 'open'
                actor.Dispatcher.dispatch(container,'uidoublepress',args{:});
            otherwise
                explicitlySpecified=rmfield(parser.Results,parser.UsingDefaults);
                if isfield(explicitlySpecified,'Button')
                    explicitlySpecified.Button=actor.getButton(explicitlySpecified.Button);
                end
                if isfield(explicitlySpecified,'Modifier')
                    explicitlySpecified.Modifier=actor.getModifier(explicitlySpecified.Modifier);
                end
                nameValueArgs=namedargs2cell(explicitlySpecified);
                actor.Dispatcher.dispatch(container,'uipress',args{:},nameValueArgs{:});
            end
        end

        function uidoublepress(actor,varargin)

            narginchk(1,2)

            pt=actor.parseCoordinatesAndGetPoint(varargin{:});

            [axesID,container]=actor.getAxesDispatchData();

            actor.Dispatcher.dispatch(container,'uidoublepress',...
            'axesType','Axes',...
            'axesID',axesID,...
            'X',pt(1),...
            'Y',pt(2),...
            'Z',pt(3));
        end

        function uihover(actor,varargin)

            narginchk(1,2)

            pt=actor.parseCoordinatesAndGetPoint(varargin{:});

            [axesID,container]=actor.getAxesDispatchData();

            actor.Dispatcher.dispatch(container,'uihover',...
            'axesType','Axes',...
            'axesID',axesID,...
            'X',pt(1),...
            'Y',pt(2),...
            'Z',pt(3));
        end

        function uidrag(actor,from,to,varargin)
            import matlab.uiautomation.internal.Modifiers;
            import matlab.uiautomation.internal.Buttons;

            narginchk(3,Inf);

            parser=inputParser;
            parser.addParameter("SelectionType","normal");
            parser.parse(varargin{:});

            selectionType=validatestring(...
            parser.Results.SelectionType,["normal","extend","alt"]);

            from=actor.parseCoordinatesAndGetPoint(from);
            to=actor.parseCoordinatesAndGetPoint(to);

            [axesID,container]=actor.getAxesDispatchData();

            selectionTypeArgs={};
            switch selectionType
            case "extend"
                selectionTypeArgs={'Modifier',Modifiers.SHIFT};
            case "alt"
                selectionTypeArgs={'Button',Buttons.RIGHT};
            end

            actor.Dispatcher.dispatch(container,'uidrag',...
            'axesType','Axes',...
            'axesID',axesID,...
            'X',[from(1),to(1)],...
            'Y',[from(2),to(2)],...
            'Z',[from(3),to(3)],...
            selectionTypeArgs{:});
        end

        function uiscroll(actor,varargin)

            narginchk(5,5)


            parser=inputParser;
            parser.addParameter('DeltaX',0);
            parser.addParameter('DeltaY',0);
            parser.parse(varargin{:});
            results=parser.Results;
            validateattributes(results.DeltaX,{'numeric'},{'real','scalar','nonnan','finite'});
            validateattributes(results.DeltaY,{'numeric'},{'real','scalar','nonnan','finite'});

            pt=actor.parseCoordinatesAndGetPoint();

            [axesID,container]=actor.getAxesDispatchData();

            actor.Dispatcher.dispatch(container,'uiscroll',...
            'axesType','Axes',...
            'axesID',axesID,...
            'X',pt(1),...
            'Y',pt(2),...
            'Z',pt(3),...
            'DeltaX',results.DeltaX,...
            'DeltaY',results.DeltaY,...
            'DeltaZ',0,...
            'DeltaMode',0...
            );

        end

    end

    methods(Access=private)

        function parser=parseInputs(actor,varargin)

            parser=inputParser;
            parser.addOptional("Position",missing);
            parser.addParameter("SelectionType","normal");



            parser.addParameter("Button","left");
            parser.addParameter("Modifier",[]);
            parser.parse(varargin{:});

            if actor.checkIfSelectionTypeButtonModifierUsedTogether(parser)


                error(message('MATLAB:uiautomation:Driver:AmbiguousSelectionType'));
            end
        end

    end

end
