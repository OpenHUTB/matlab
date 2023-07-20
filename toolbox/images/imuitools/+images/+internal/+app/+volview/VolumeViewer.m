classdef VolumeViewer<handle





    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

        viewerView images.internal.app.volview.View
        viewerModel images.internal.app.volview.Model

    end

    properties(Access=private)

        viewerController images.internal.app.volview.Controller

    end

    properties(Hidden)
Source1Name
Source2Name
    end

    methods

        function self=VolumeViewer(varargin)


            if nargin==0

                setBusy=false;
                self.setupApp(setBusy);

            else
                arg1=matlab.images.internal.stringToChar(varargin{1});
                if ischar(arg1)

                    validatestring(arg1,{'close'},mfilename);
                    self.deleteAllTools();
                    return;
                end

                [V,source1Name,L,source2Name,scaleFactors,volumeType,numVolumes]=parseInputs(varargin{:});


                setBusy=true;
                if numVolumes==0
                    setBusy=false;
                end
                TF=self.setupApp(setBusy);

                if~TF
                    return
                end

                switch numVolumes
                case 1
                    if strcmp(volumeType,'labels')&&~isempty(scaleFactors)
                        warnMsg=getString(message('images:volumeViewer:scaleFactorsLabeledVolume'));
                        self.viewerView.displayScaleFactorsWarningDlg(warnMsg);
                    end
                    self.viewerModel.loadDataFromWorkspace(V,volumeType,source1Name,scaleFactors);
                case 2
                    self.viewerModel.loadNewMixedVolumeData(V,L,source1Name,source2Name,scaleFactors);
                end

            end

        end

    end

    methods(Access=private)

        function TF=setupApp(self,setViewBusy)

            TF=true;

            self.viewerModel=images.internal.app.volview.Model();
            self.viewerView=images.internal.app.volview.View(setViewBusy);

            if isvalid(self.viewerView)

                self.viewerView.appCloseAllowed(false);
                c1=onCleanup(@()self.viewerView.appCloseAllowed(true));

                self.viewerController=images.internal.app.volview.Controller(self.viewerModel,self.viewerView);

                imageslib.internal.apputil.manageToolInstances('add','volumeViewer',self.viewerView.App);
                addlistener(self.viewerView.App,'ObjectBeingDestroyed',@(~,~)closeCallback(self));
                setBackgroundState(self.viewerModel);

            else

                delete(self.viewerModel);
                TF=false;
            end

        end

        function closeCallback(self)

            if~isvalid(self)
                return
            end

            delete(self.viewerView);
            delete(self.viewerModel);
            delete(self);

        end

    end

    methods(Static)

        function deleteAllTools(~)
            imageslib.internal.apputil.manageToolInstances('deleteAll','volumeViewer');
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




        if images.internal.app.volview.isVolume(arg3)
            L=arg3;
            source2Name=varargin{4};
            validateVolume(V);
            validateLabeledVolume(L);
            if~isequal(size(V),size(L))
                error(getString(message('images:volumeViewer:volumeSizesNotEqual')));
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
            inputStr=validatestring(param,paramStrings,mfilename,'PARAM');
            valueIdx=k+1;
            if valueIdx>nargin
                error(message('images:volumeViewer:missingParameterValue',inputStr));
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

    if~images.internal.app.volview.isVolume(V)
        error(message('images:volumeViewer:requireVolumeData'));
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

    if~images.internal.app.volview.isVolume(L)
        error(message('images:volumeViewer:requireVolumeData'));
    end
end
