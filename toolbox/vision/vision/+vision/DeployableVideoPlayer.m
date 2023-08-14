classdef DeployableVideoPlayer<matlab.system.SFunSystem






























































%#function mvipwvo2
%#function cvstToVideoDisplayPanel

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)








        Location=[];




        Name='Deployable Video Player';




        Size='True size (1:1)';







        CustomSize=[300,410];





        InputColorFormat='RGB';
    end

    properties(Dependent,Hidden,Nontunable,Transient)
        WindowCaption;
        WindowLocation;
        WindowSize;
        CustomWindowSize;
    end

    properties(Constant,Hidden)
        SizeSet=matlab.system.StringSet({...
        'Full-screen','True size (1:1)','Custom'});
        InputColorFormatSet=matlab.system.StringSet({'RGB','YCbCr 4:2:2'});
    end

    properties(Hidden,Nontunable)

        VideoSize=[];
        figureID='';



        FrameRate=30;
        CoderTarget='';
    end

    methods
        function obj=DeployableVideoPlayer(varargin)
            import matlab.internal.lang.capability.Capability;
            Capability.require(Capability.LocalClient);

            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipwvo2');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);

            setVarSizeAllowedStatus(obj,false);
            cvstToVideoDisplayPanel('objectLoading');
        end

        function set.Location(obj,value)
            coder.internal.errorIf(~isempty(value)&&...
            (~isnumeric(value)||length(value)~=2||...
            ~all(floor(value)==value)),...
            'vision:DeployableVideoPlayer:invalidLocation');
            obj.Location=value;
        end

        function set.Name(obj,value)
            validateattributes(value,{'char'},{'nonempty'},'','Name');
            obj.Name=value;
        end


        function set.WindowCaption(obj,value)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'WindowCaption','Name'));

            obj.Name=value;
        end

        function value=get.WindowCaption(obj)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'WindowCaption','Name'));

            value=obj.Name;
        end

        function set.WindowLocation(obj,value)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'WindowLocation','Location'));

            obj.Location=value;
        end

        function value=get.WindowLocation(obj)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'WindowLocation','Location'));

            value=obj.Location;
        end

        function set.WindowSize(obj,value)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'WindowSize','Size'));

            obj.Size=value;
        end

        function value=get.WindowSize(obj)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'WindowSize','Size'));

            value=obj.Size;
        end

        function set.CustomWindowSize(obj,value)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'CustomWindowSize','CustomSize'));

            obj.CustomSize=value;
        end

        function value=get.CustomWindowSize(obj)
            warning(message('MATLAB:system:throwObsoletePropertyWarningNewName',...
            class(obj),'CustomWindowSize','CustomSize'));

            value=obj.CustomSize;
        end

        function value=isOpen(obj)
            if(isempty(obj.figureID))
                value=false;
            else
                value=cvstToVideoDisplayPanel('objectPlayerOpen',obj.figureID);
            end
        end

        function delete(obj)
            if(~isempty(obj.figureID))
                cvstToVideoDisplayPanel('objectDeleting',obj.figureID);
            end
            delete@matlab.system.SFunSystem(obj);
        end
    end

    methods(Hidden)
        function setParameters(obj)
            isFullscreen=double(strcmp(obj.Size,'Full-screen'));
            isCustomSize=double(strcmp(obj.Size,'Custom'));
            isTrueSize=double(strcmp(obj.Size,'True size (1:1)'));
            InputColorFormatIdx=getIndex(obj.InputColorFormatSet,obj.InputColorFormat);
            if isempty(obj.Location)
                loc=obj.getDefaultLocation();
            else
                loc=obj.Location;
            end
            if isSizesOnlyCall(obj)
                pos=loc;
                actualVideoSize=obj.CustomSize;
            else

                obj.VideoSize=obj.getInputSize(1);






                if(isTrueSize||isFullscreen)
                    actualVideoSize=fliplr(obj.VideoSize(1:2));
                else
                    actualVideoSize=obj.CustomSize;
                end


                oldUnits=get(0,'Units');
                set(0,'Units','pixels');
                screenSize=floor(get(0,'ScreenSize'));
                set(0,'Units',oldUnits);



















                if(isequal(loc,obj.getDefaultLocation()))
                    pos=loc;
                else
                    pos(1)=loc(1);
                    winH=actualVideoSize(2);
                    pos(2)=screenSize(4)-loc(2)-winH;
                end
            end

            [NORMAL_SIZE_WIN,FULL_SCREEN_WIN,TRUE_SIZE_WIN]=deal(1,2,3);
            if(isFullscreen)
                windowSizeMode=FULL_SCREEN_WIN;
            else
                if(isCustomSize)
                    windowSizeMode=NORMAL_SIZE_WIN;
                else
                    windowSizeMode=TRUE_SIZE_WIN;
                end
            end

            coderTargetID=obj.getCoderTargetID(obj.CoderTarget);
            obj.compSetParameters({3,...
            'On-screen video monitor',...
            1,...
            obj.Name,...
            windowSizeMode,...
            pos(1),...
            pos(2),...
            actualVideoSize(1),...
            actualVideoSize(2),...
            1,...
            1,...
            coderTargetID,...
InputColorFormatIdx...
            });
        end

        function location=getDefaultLocation(~)


            location=([536805376,536805376]);
        end

        function idOut=getFigureID(obj)
            idOut=obj.figureID;
        end

    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'Location'...
            ,'Name'...
            ,'Size'...
            ,'CustomSize'...
            ,'InputColorFormat'...
            };
        end
        function setFigureID(obj,id)
            obj.figureID=id;
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~strcmp(obj.Size,'Custom')
                props{end+1}='CustomSize';
            end
            flag=ismember(prop,props);
        end
    end

    methods(Sealed,Hidden)
        function close(obj)




            warning(message('MATLAB:system:throwObsoleteMethodWarningNewName',...
            class(obj),'close','release'));
            release(obj);
        end
    end

    methods(Access=protected)
        function s=saveObjectImpl(obj)
            props=vision.DeployableVideoPlayer.getDisplayPropertiesImpl;
            for ii=1:length(props)
                s.(props{ii})=obj.(props{ii});
            end
        end

        function c=cloneImpl(obj)
            c=vision.DeployableVideoPlayer;
            props=vision.DeployableVideoPlayer.getDisplayPropertiesImpl;
            for ii=1:length(props)
                c.(props{ii})=obj.(props{ii});
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionsinks/To Video Display';
        end

        function flag=getCoderTargetID(coderTarget)
            switch lower(coderTarget)
            case 'matlab'
                flag=1;
            case 'mex'
                flag=2;
            case 'sfun'
                flag=3;
            case 'rtw'
                flag=4;
            case 'hdl'
                flag=5;
            case 'custom'
                flag=6;
            otherwise
                flag=0;
            end
        end
    end
end
