

classdef VolumeViewer<handle

    properties

viewerView
viewerModel
viewerController

    end

    properties(Hidden)
Source1Name
Source2Name
    end

    methods

        function self=VolumeViewer(varargin)
            if nargin==0

                self.setupApp();
            else
                arg1=matlab.images.internal.stringToChar(varargin{1});
                if ischar(arg1)

                    validatestring(arg1,{'close'},mfilename);
                    self.deleteAllTools();
                    return;
                end

                [V,source1Name,L,source2Name,scaleFactors,volumeType,numVolumes]=parseInputs(varargin{:});


                if numVolumes==1&&islogical(V)&&~iptgetpref('VolumeViewerUseHardware')
                    error(message('images:volumeViewerToolgroup:hardwareRequired'));
                end


                self.setupApp();

                switch numVolumes
                case 1
                    if strcmp(volumeType,'labels')&&~isempty(scaleFactors)
                        self.viewerView.displayScaleFactorsWarningDlg(getString(message('images:volumeViewerToolgroup:scaleFactorsLabeledVolume')));
                    end
                    self.viewerModel.loadDataFromWorkspace(V,volumeType,source1Name,scaleFactors);
                case 2
                    self.viewerModel.loadNewMixedVolumeData(V,L,source1Name,source2Name,scaleFactors);
                end
            end
        end

        function setupApp(self)
            images.internal.app.volviewToolgroup.checkOpenGLDrivers();

            self.viewerModel=images.internal.app.volviewToolgroup.Model();
            self.viewerView=images.internal.app.volviewToolgroup.View();

            self.viewerController=images.internal.app.volviewToolgroup.Controller(self.viewerModel,self.viewerView);

            imageslib.internal.apputil.manageToolInstances('add','volumeViewerToolgroup',self.viewerView);



            addlistener(self.viewerView.ToolGroup,'GroupAction',@(src,event)closeCallback(self,event));



            self.viewerView.ToolGroup.approveClose();
        end

        function closeCallback(self,event)
            ET=event.EventData.EventType;
            if strcmp(ET,'CLOSING')
                delete(self.viewerView);
                delete(self);
            end
        end

    end

    methods(Static)
        function deleteAllTools(~)
            imageslib.internal.apputil.manageToolInstances('deleteAll','volumeViewerToolgroup');
        end
    end

end


function[V,source1Name,L,source2Name,scaleFactors,volType,numVolumes]=parseInputs(varargin)

    L=[];
    source2Name="";
    scaleFactors=[];
    volType='volume';
    numVolumes=0;
    nvPairStart=3;

    narginchk(1,7);
    varargin=matlab.images.internal.stringToChar(varargin);

    V=varargin{1};
    source1Name=varargin{2};
    numVolumes=numVolumes+1;

    if nargin>2
        arg3=varargin{3};




        if images.internal.app.volviewToolgroup.isVolume(arg3)
            L=arg3;
            source2Name=varargin{4};
            validateVolume(V);
            validateLabeledVolume(L);
            if~isequal(size(V),size(L))
                error(getString(message('images:volumeViewerToolgroup:volumeSizesNotEqual')));
            end
            numVolumes=numVolumes+1;
            nvPairStart=5;
        elseif~ischar(arg3)
            validateattributes(arg3,{'double'},{'size',[4,4]},mfilename,'REF');
            scaleFactors=arg3;
            nvPairStart=4;
        end

        charStart=find(cellfun('isclass',varargin,'char'),1,'first');
        charStart=max(charStart,nvPairStart);

        paramStrings={'VolumeType','ScaleFactors'};
        for k=charStart:2:nargin
            param=lower(varargin{k});
            inputStr=validatestring(param,paramStrings,mfilename,'PARAM',k);
            valueIdx=k+1;
            if valueIdx>nargin
                error(message('images:volumeViewerToolgroup:missingParameterValue',inputStr));
            end

            switch inputStr
            case 'VolumeType'
                volType=varargin{valueIdx};
                volType=lower(volType);
                validOptions={'volume','labels'};
                validatestring(volType,validOptions,mfilename,'VolumeType',valueIdx);

            case 'ScaleFactors'
                argval=varargin{valueIdx};
                validateattributes(argval,{'numeric'},...
                {'size',[1,3],'real','finite','nonempty','nonsparse','positive'},...
                mfilename,'ScaleFactors');
                scaleFactors=eye(4);
                scaleFactors(1,1)=argval(1);
                scaleFactors(2,2)=argval(2);
                scaleFactors(3,3)=argval(3);

            end
        end
    end

    if numVolumes==1&&iscategorical(V)
        volType='labels';
    end

    if strcmp(volType,'volume')
        validateVolume(V);
    else
        validateLabeledVolume(V);
    end

end

function validateVolume(V)

    supportedImageClasses={'int8','uint8','int16','uint16','int32','uint32','single','double','logical'};
    supportedImageAttributes={'real','nonsparse','nonempty'};
    validateattributes(V,supportedImageClasses,supportedImageAttributes,mfilename,'V');

    if~images.internal.app.volviewToolgroup.isVolume(V)
        error(message('images:volumeViewerToolgroup:requireVolumeData'));
    end
end

function validateLabeledVolume(L)

    if iscategorical(L)
        supportedImageAttributes={'real','nonsparse','nonempty'};
    else
        supportedImageAttributes={'real','nonsparse','nonempty','integer','nonnegative'};
    end
    supportedImageClasses={'int8','uint8','int16','uint16','int32','uint32','single','double','categorical'};
    validateattributes(L,supportedImageClasses,supportedImageAttributes,mfilename,'L');

    if~images.internal.app.volviewToolgroup.isVolume(L)
        error(message('images:volumeViewerToolgroup:requireVolumeData'));
    end
end