classdef(Abstract,AllowedSubclasses=?images.ui.graphics3d.GraphicsContainer)...
    AbstractContainer<handle&matlab.mixin.SetGet&...
    matlab.mixin.CustomDisplay&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer&...
    matlab.mixin.Heterogeneous














    properties

        Tag(1,1)string
UserData

    end

    properties(Dependent,Hidden,GetAccess=public,SetAccess=protected)

        DataUpdateRequired(1,1)logical
        DownsampleLevel(1,1)double{mustBeGreaterThanOrEqual(DownsampleLevel,1),mustBeInteger,mustBeFinite}

    end

    properties(Hidden,GetAccess=public,SetAccess=protected)

        Dirty(1,1)logical=false;
        IsContainerConstructed(1,1)logical=false;
        Max3DTextureSize(1,1)double=2048;
        KeepOriginalDataCopy(1,1)logical=true;
        KeepModifiedDataCopy(1,1)logical=true;

    end

    properties(Access=protected)

        DataModified(1,1)logical=false;
        OverlayDataModified(1,1)logical=false;
        AlphaDataModified(1,1)logical=false;

        DownsampleLevel_I(1,1)double=1;

    end

    methods(Sealed)


        function varargout=set(obj,varargin)
            [varargout{1:nargout}]=set@matlab.mixin.SetGet(obj,varargin{:});
        end

        function varargout=get(obj,varargin)
            [varargout{1:nargout}]=get@matlab.mixin.SetGet(obj,varargin{:});
        end

        function varargout=eq(obj,varargin)
            [varargout{1:nargout}]=eq@matlab.mixin.SetGet(obj,varargin{:});
        end

        function varargout=ne(obj,varargin)
            [varargout{1:nargout}]=ne@matlab.mixin.SetGet(obj,varargin{:});
        end
    end

    methods(Sealed,Access=protected)

        function displayNonScalarObject(obj)


            fprintf('  %s %s array\n\n',matlab.mixin.CustomDisplay.convertDimensionsToString(obj),...
            'images.ui.graphics3d.GraphicsContainer');
        end

        function displayEmptyObject(obj)

            displayNonScalarObject(obj);
        end

    end

    methods(Access=protected)


        function applyDownsample(~)


        end

    end

    methods




        function set.DataUpdateRequired(self,TF)
            self.DataModified=TF;
            self.OverlayDataModified=TF;
            self.AlphaDataModified=TF;
        end

        function TF=get.DataUpdateRequired(self)
            TF=self.DataModified||self.OverlayDataModified||self.AlphaDataModified;
        end




        function set.DownsampleLevel(self,val)
            self.DownsampleLevel_I=val;
            applyDownsample(self);
        end

        function val=get.DownsampleLevel(self)
            val=self.DownsampleLevel_I;
        end

    end

end