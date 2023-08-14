classdef Parameter<Simulink.Parameter




    methods

        function setupCoderInfo(h)

            useLocalCustomStorageClasses(h,'mpt');


            h.CoderInfo.StorageClass='Custom';
            h.CoderInfo.CustomStorageClass='Global';
        end


        function h=Parameter(varargin)



            h@Simulink.Parameter(varargin{:});
            if nargin==0
                h.Value=0;
            end

        end

    end

end


