classdef ChromaResampler<matlab.system.SFunSystem

















































%#function mvipchromresamp

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)

















        Resampling='4:4:4 to 4:2:2';










        InterpolationFilter='Linear';









        AntialiasingFilterSource='Auto';







        HorizontalFilterCoefficients=[0.2,0.6,0.2];







        VerticalFilterCoefficients=[0.5,0.5];







        TransposedInput(1,1)logical=false;
    end

    properties(Constant,Hidden)
        ResamplingSet=matlab.system.StringSet({...
        '4:4:4 to 4:2:2','4:4:4 to 4:2:0 (MPEG1)',...
        '4:4:4 to 4:2:0 (MPEG2)','4:4:4 to 4:1:1',...
        '4:2:2 to 4:2:0 (MPEG1)','4:2:2 to 4:2:0 (MPEG2)',...
        '4:2:2 to 4:4:4','4:2:0 (MPEG1) to 4:4:4',...
        '4:2:0 (MPEG2) to 4:4:4','4:1:1 to 4:4:4',...
        '4:2:0 (MPEG1) to 4:2:2','4:2:0 (MPEG2) to 4:2:2'});
        InterpolationFilterSet=matlab.system.StringSet({...
        'Pixel replication',...
        'Linear'});
        AntialiasingFilterSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property',...
        'None'});
    end

    methods

        function obj=ChromaResampler(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipchromresamp');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Hidden)
        function setParameters(obj)

            ResamplingIdx=getIndex(...
            obj.ResamplingSet,obj.Resampling);
            InterpolationFilterIdx=getIndex(...
            obj.InterpolationFilterSet,obj.InterpolationFilter);
            AntialiasingFilterSourceIdx=getIndex(...
            obj.AntialiasingFilterSourceSet,obj.AntialiasingFilterSource);

            obj.compSetParameters({...
            ResamplingIdx,...
            InterpolationFilterIdx,...
            AntialiasingFilterSourceIdx,...
            obj.HorizontalFilterCoefficients,...
            obj.VerticalFilterCoefficients,...
            double(obj.TransposedInput)...
            });
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if ismember(obj.Resampling,{'4:4:4 to 4:2:2',...
                '4:4:4 to 4:2:0 (MPEG1)',...
                '4:4:4 to 4:2:0 (MPEG2)',...
                '4:4:4 to 4:1:1',...
                '4:2:2 to 4:2:0 (MPEG1)',...
                '4:2:2 to 4:2:0 (MPEG2)'})
                props{end+1}='InterpolationFilter';
                if(strcmp(obj.AntialiasingFilterSource,'Property'))
                    if ismember(obj.Resampling,{'4:4:4 to 4:2:2',...
                        '4:4:4 to 4:1:1'})
                        props{end+1}='VerticalFilterCoefficients';
                    elseif ismember(obj.Resampling,{'4:2:2 to 4:2:0 (MPEG1)',...
                        '4:2:2 to 4:2:0 (MPEG2)'})
                        props{end+1}='HorizontalFilterCoefficients';
                    end
                else
                    props=[props,{'HorizontalFilterCoefficients',...
                    'VerticalFilterCoefficients'}];
                end
            elseif ismember(obj.Resampling,{'4:2:2 to 4:4:4',...
                '4:2:0 (MPEG1) to 4:4:4',...
                '4:2:0 (MPEG2) to 4:4:4',...
                '4:1:1 to 4:4:4',...
                '4:2:0 (MPEG1) to 4:2:2',...
                '4:2:0 (MPEG2) to 4:2:2'})
                props={'AntialiasingFilterSource',...
                'HorizontalFilterCoefficients',...
                'VerticalFilterCoefficients'};
            end
            flag=ismember(prop,props);
        end

    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'Resampling'...
            ,'InterpolationFilter'...
            ,'AntialiasingFilterSource'...
            ,'HorizontalFilterCoefficients'...
            ,'VerticalFilterCoefficients'...
            ,'TransposedInput'...
            };
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
            setPortDataTypeConnection(obj,2,2);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionconversions/Chroma Resampling';
        end
    end
end

