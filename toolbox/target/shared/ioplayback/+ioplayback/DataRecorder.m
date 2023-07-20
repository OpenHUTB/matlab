classdef DataRecorder<handle&matlab.mixin.CustomDisplay







    properties(Dependent)
HardwareName
Sources
        Recording=false
        RemainingTime=0
    end

    properties(GetAccess=protected,SetAccess=immutable)
HwObj
    end

    properties(Access=protected)
SrcObj
    end

    properties(Access=protected,Transient)
        Tstart uint64=0
        SavedDuration=0
        ChangeSrcObj=false;
    end

    methods
        function obj=DataRecorder(hwObj)
            validateattributes(hwObj,{'ioplayback.hardware.Base'},{'nonempty'},'','hardware');
            obj.HwObj=hwObj;
        end

        function ret=get.HardwareName(obj)
            ret=obj.HwObj.BoardName;
        end

        function ret=get.Sources(obj)
            ret=cell(1,numel(obj.SrcObj));
            for k=1:numel(obj.SrcObj)
                ret{k}=obj.SrcObj{k}.SourceName;
            end
        end

        function ret=get.Recording(obj)
            if obj.SavedDuration==0
                ret=false;
            else
                if(obj.SavedDuration-toc(obj.Tstart)>0)
                    ret=true;
                else
                    ret=false;
                end
            end
        end

        function ret=get.RemainingTime(obj)
            ret=obj.SavedDuration-toc(obj.Tstart);
            if ret<0
                ret=0;
            end
        end

        function addSource(obj,sourceObject,sourceName)
            if nargin==3
                sourceName=convertStringsToChars(sourceName);
            end
            validateattributes(sourceObject,{'ioplayback.System'},{'nonempty'},'','sourceObject');
            validateattributes(sourceName,{'char'},{'row','nonempty'},'','sourceName');
            if numel(sourceName)>25
                error(message('ioplayback:general:InvalidSourceName'));
            end
            newSrcObj=clone(sourceObject);
            newSrcObj.SimulationOutput='From recorded file';
            newSrcObj.SourceName=sourceName;
            verifySourceObject(obj,newSrcObj);
            if isempty(obj.SrcObj)
                obj.SrcObj={newSrcObj};
            else
                obj.SrcObj{end+1}=newSrcObj;
            end
            obj.ChangeSrcObj=true;
        end

        function removeSource(obj,sourceName)
            if nargin==2
                sourceName=convertStringsToChars(sourceName);
            end
            validateattributes(sourceName,{'char'},{'row','nonempty'},'','sourceName');
            if strcmpi(sourceName,'all')
                for k=numel(obj.SrcObj):-1:1
                    obj.SrcObj(k)=[];
                end
                obj.ChangeSrcObj=true;
            else
                sourceName=validatestring(sourceName,obj.Sources);
                for k=1:numel(obj.SrcObj)
                    if isequal(obj.SrcObj{k}.SourceName,sourceName)
                        obj.SrcObj(k)=[];
                        obj.ChangeSrcObj=true;
                        break;
                    end
                end
            end
        end

        function setup(~)

        end

        function preview(~)

            error(message('ioplayback:utils:PreviewNotImplemented'));
        end

        function closePreview(~)
        end

        function record(~)


        end

        function save(~)

        end
    end

    methods(Access=private)
        function verifySourceObject(obj,srcObj)
            for k=1:numel(obj.SrcObj)
                if isequal(obj.SrcObj{k}.SourceName,srcObj.SourceName)
                    error(message('ioplayback:utils:InvalidSourceName',srcObj.SourceName));
                end
            end
        end
    end

    methods(Access=protected)
        function displayScalarObject(obj)
            header=getHeader(obj);
            disp(header);

            fprintf('          HardwareName: ''%s''\n',obj.HardwareName);
            fprintf('               Sources: %-30s\n',ioplayback.util.cell2str(obj.Sources));
            fprintf('             Recording: %-30s\n',string(obj.Recording));
            fprintf('\n');

            fprintf('\n%s\n',getFooter(obj));
        end

        function s=getFooter(obj)
            mc=metaclass(obj);
            s=sprintf('  <a href="matlab: methods(''%s'')">Methods</a>',mc.Name);
        end
    end
end

