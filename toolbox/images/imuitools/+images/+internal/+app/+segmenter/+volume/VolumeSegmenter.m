classdef(Sealed)VolumeSegmenter<handle




    properties(Access=protected,Hidden,Transient)

        Model images.internal.app.segmenter.volume.Model
        Controller images.internal.app.segmenter.volume.Controller

    end


    properties(SetAccess=protected,GetAccess={...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.home.labeler.DataLabeler})

        View images.internal.app.segmenter.volume.View

    end


    methods




        function self=VolumeSegmenter(varargin)

            data=parseInputs(self,varargin{:});

            self.Model=images.internal.app.segmenter.volume.Model();
            self.View=images.internal.app.segmenter.volume.View(data.Show3DDisplay,data.UseWebVersion,data.ShowAutomationMetrics);

            if~isvalid(self.View)
                return;
            end

            self.Controller=images.internal.app.segmenter.volume.Controller(self.Model,self.View);

            if data.RestoreDefaultAlgorithms
                s=settings;
                s.images.VolumeSegmenter.VolumeAlgorithmList.PersonalValue="";
                s.images.VolumeSegmenter.SliceAlgorithmList.PersonalValue="";
            end

            if~isempty(data.Volume)
                loadVolumeFromWorkspace(self.Model,data.Volume);
                markSaveAsClean(self.View);
            end

            if~isempty(data.Labels)
                loadLabelsFromWorkspace(self.Model,data.Labels);
            end

            if isnumeric(data.UndoStackLength)
                setUndoStackLength(self.Model,data.UndoStackLength);
            end

        end

    end


    methods(Access=protected)


        function data=parseInputs(self,varargin)

            parser=inputParser();
            parser.addOptional('Volume',uint8.empty);
            parser.addOptional('Labels',categorical.empty);
            parser.addParameter('Show3DDisplay',logical.empty,@(x)isscalar(x));
            parser.addParameter('UseWebVersion',true,@(x)isscalar(x));
            parser.addParameter('UndoStackLength','auto',@(x)validateUndoStackLength(x));
            parser.addParameter('RestoreDefaultAlgorithms',false,@(x)isscalar(x));
            parser.addParameter('ShowAutomationMetrics',false,@(x)isscalar(x));
            parser.parse(varargin{1:end});
            data=parser.Results;

            if~displaySupported(self)
                data.Show3DDisplay=false;
            end


            data.Show3DDisplay=logical(data.Show3DDisplay);
            data.UseWebVersion=logical(data.UseWebVersion);
            data.RestoreDefaultAlgorithms=logical(data.RestoreDefaultAlgorithms);

        end


        function TF=displaySupported(~)

            if ismac
                TF=true;
            elseif isunix
                TF=false;
            elseif ispc
                data=opengl('data');

                windowsSoftwareOpenGL=strcmp(data.Version,'1.1.0')&&...
                strcmp(data.Vendor,'Microsoft Corporation')&&...
                strcmp(data.Renderer,'GDI Generic')&&...
                data.Software;

                TF=~windowsSoftwareOpenGL;
            else

                TF=false;
            end

        end

    end


end

function TF=validateUndoStackLength(n)

    if ischar(n)||isstring(n)
        TF=strcmp(n,'auto');
    else
        TF=isnumeric(n)&&isfinite(n)&&isscalar(n)&&isreal(n)&&n>0;
    end

end