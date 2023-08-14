classdef MDLInfo<Simulink.loadsave.MDLInfo














    properties(GetAccess=public,SetAccess=protected)

        BlockDiagramName='';
    end

    properties(GetAccess=public,SetAccess=protected,Hidden)

        isExtractMetadata;
        isExtractInterface;
        showDebugOutput;
    end

    methods(Access=public)






        function obj=MDLInfo(mdlname,varargin)
            p=inputParser;
            addRequired(p,'mdlname',@isscalarstring);
            addParameter(p,'isExtractMetadata',true,@islogical);
            addParameter(p,'isExtractInterface',true,@islogical);
            addParameter(p,'showDebugOutput',false,@islogical);
            parse(p,mdlname,varargin{:});

            function b=isscalarstring(v)
                b=ischar(v)||(isstring(v)&&numel(v)==1);
            end

            obj=obj@Simulink.loadsave.MDLInfo(char(mdlname),...
            p.Results.isExtractInterface,...
            p.Results.isExtractMetadata,...
            p.Results.showDebugOutput);

            obj.isExtractMetadata=p.Results.isExtractMetadata;
            obj.isExtractInterface=p.Results.isExtractInterface;
            obj.showDebugOutput=p.Results.showDebugOutput;


            [~,obj.BlockDiagramName]=slfileparts(obj.FileName);

            if bdIsLoaded(obj.BlockDiagramName)&&...
                ~any(mdlname==filesep)&&~any(mdlname=='/')&&...
                ~any(mdlname=='.')



                if isempty(get_param(obj.BlockDiagramName,'FileName'))
                    DAStudio.error('Simulink:util:UnsavedBlockDiagram',obj.BlockDiagramName);
                end


                [~,shadowed,shadowFile]=slgcInternal('getBlockDiagramFileState',obj.BlockDiagramName);
                if~isempty(shadowed)
                    if strcmp(shadowed,'FILE_SHADOWED_BY_FILE')
                        MSLDiagnostic(...
                        'Simulink:Engine:MdlFileShadowedByFile',...
                        obj.BlockDiagramName,...
                        get_param(obj.BlockDiagramName,'fileName'),...
                        shadowFile).reportAsWarning;
                    end
                end
            end
        end

        function s=saveobj(obj)
            s.FileName=obj.FileName;
            s.isExtractMetadata=obj.isExtractMetadata;
            s.isExtractInterface=obj.isExtractInterface;
            s.showDebugOutput=obj.showDebugOutput;
        end
    end

    methods(Static)



        function metadata=getMetadata(mdlname)
            obj=Simulink.MDLInfo(mdlname,'isExtractInterface',false);
            metadata=obj.Metadata;
        end




        function interface=getInterface(mdlname)


            obj=Simulink.MDLInfo(mdlname,'isExtractMetadata',false);
            interface=obj.Interface;
        end




        function desc=getDescription(mdlname)


            obj=Simulink.MDLInfo(mdlname,...
            'isExtractMetadata',false,'isExtractInterface',false);
            desc=obj.Description;
        end




        function rel=getReleaseName(mdlname)


            obj=Simulink.MDLInfo(mdlname,...
            'isExtractMetadata',false,'isExtractInterface',false);
            rel=obj.ReleaseName;
        end

        function obj=loadobj(s)
            if isstruct(s)
                obj=Simulink.MDLInfo(...
                s.FileName,...
                'isExtractMetadata',s.isExtractMetadata,...
                'isExtractInterface',s.isExtractInterface,...
                'showDebugOutput',s.showDebugOutput);
            else
                obj=Simulink.MDLInfo(s);
            end
        end
    end
end
