classdef Results < handle

    properties ( SetAccess = 'private', GetAccess = 'public' )
        Clones
        ExceptionLog
    end

    properties ( SetAccess = 'private', GetAccess = 'public', Hidden = true )
        ClonesId
    end

    methods ( Access = public )
        function obj = Results( clonesData )
            arguments
                clonesData = [  ]
            end
            obj.Clones = [  ];
            obj.ExceptionLog = {  };
            obj.ClonesId = '';
            if ~isempty( clonesData )
                if isfield( clonesData, 'Clones' )
                    obj.Clones = clonesData.Clones;
                end

                if isfield( clonesData, 'ExceptionLog' )
                    obj.ExceptionLog = clonesData.ExceptionLog;
                end

                if isfield( clonesData, 'ClonesId' )
                    obj.ClonesId = clonesData.ClonesId;
                end
            end
        end
    end
end

