function[indexPairs,matchMetric]=imMatchFeatures(varargin)




















































































    [features1,features2,metric,match_thresh,method,maxRatioThreshold,...
    isPrenormalized,uniqueMatches]=parseInputs(varargin{:});


    assert(size(features1,2)==size(features2,2));


    features1=features1';
    features2=features2';
    [index_pairs_internal,match_metric_internal]=...
    images.internal.app.registration.model.imAlgMatchFeatures(features1,features2,...
    metric,match_thresh,method,maxRatioThreshold,...
    isPrenormalized,uniqueMatches);
    indexPairs=index_pairs_internal';
    matchMetric=match_metric_internal';




    function[features1,features2,metric,match_thresh,method,...
        maxRatioThreshold,isPrenormalized,uniqueMatches]...
        =parseInputs(varargin)

        defaults=struct(...
        'Metric','ssd',...
        'MatchThreshold',1.0,...
        'Method','exhaustive',...
        'MaxRatio',0.6,...
        'Prenormalized',false,...
        'Unique',false);


        parser=inputParser;
        parser.addRequired('features1',@checkFeatures);
        parser.addRequired('features2',@checkFeatures);
        parser.addParameter('MatchThreshold',defaults.MatchThreshold,...
        @checkMatchThreshold);
        parser.addParameter('Method',defaults.Method);
        parser.addParameter('MaxRatio',defaults.MaxRatio,...
        @checkMaxRatioThreshold);
        parser.addParameter('Metric',defaults.Metric);
        parser.addParameter('Prenormalized',defaults.Prenormalized,...
        @checkPrenormalized);
        parser.addParameter('Unique',defaults.Unique,...
        @checkUniqueMatches);


        parser.parse(varargin{:});

        metric=checkMetric(parser.Results.Metric);
        method=checkMatchMethod(parser.Results.Method);
        match_thresh=parser.Results.MatchThreshold;
        maxRatioThreshold=parser.Results.MaxRatio;
        isPrenormalized=logical(parser.Results.Prenormalized);
        uniqueMatches=logical(parser.Results.Unique);

        f1=parser.Results.features1;
        f2=parser.Results.features2;

        features1=f1;
        features2=f2;

        metric=lower(metric);


        function checkFeatures(features)
            validateattributes(features,{'logical','int8','uint8','int16',...
            'uint16','int32','uint32','single','double'},...
            {'2d','nonsparse','real'},'imMatchFeatures','FEATURES');


            function matchedValue=checkMetric(value)
                list={'ssd','normxcorr','sad','hamming'};
                validateattributes(value,{'char'},{'nonempty'},'imMatchFeatures',...
                'Metric');

                matchedValue=validatestring(value,list,'imMatchFeatures','Metric');


                function matchedValue=checkMatchMethod(value)

                    list={'exhaustive'};
                    validateattributes(value,{'char'},{'nonempty'},'imMatchFeatures',...
                    'Method');
                    matchedValue=validatestring(value,list,'imMatchFeatures','Method');


                    function checkMatchThreshold(threshold)
                        validateattributes(threshold,{'numeric'},{'nonempty','nonnan',...
                        'finite','nonsparse','real','positive','scalar','<=',100},...
                        'imMatchFeatures','MatchThreshold');


                        function checkMaxRatioThreshold(threshold)
                            validateattributes(threshold,{'numeric'},{'nonempty','nonnan',...
                            'finite','nonsparse','real','positive','scalar','<=',1.0},...
                            'imMatchFeatures','MaxRatioThreshold');


                            function checkPrenormalized(isPrenormalized)
                                validateattributes(isPrenormalized,{'logical','numeric'},...
                                {'nonempty','scalar','real','nonnan','nonsparse'},...
                                'imMatchFeatures','Prenormalized');


                                function checkUniqueMatches(uniqueMatches)
                                    validateattributes(uniqueMatches,{'logical','numeric'},...
                                    {'nonempty','scalar','real','nonnan','nonsparse'},...
                                    'imMatchFeatures','Unique');