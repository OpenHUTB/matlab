classdef ProjectFile
































    properties(Dependent,GetAccess=public,SetAccess=private)

Path
    end

    properties(Dependent=true,GetAccess=public,SetAccess=public)

Labels
    end

    properties(Dependent=true,GetAccess=public,SetAccess=private)


Revision


SourceControlStatus
    end

    properties(GetAccess=private,SetAccess=immutable,Hidden)
mProjectFile
    end

    methods(Access=public,Hidden=true)
        function obj=ProjectFile(mProjectFile)



            obj.mProjectFile=mProjectFile;
        end
    end

    methods(Access=public)

        function label=findLabel(obj,varargin)




















            narginchk(2,3);

            validateattributes(obj,{'slproject.ProjectFile'},{},'','file');

            varargin=obj.replaceLabelDefinitions(varargin);

            mProjectFiles=arrayfun(@(x)x.mProjectFile,obj);

            mLabel=mProjectFiles.findLabel(varargin{:});

            if isempty(mLabel)
                label=slproject.Label.empty(1,0);
            else
                label=arrayfun(@(x)slproject.Label(x),mLabel);
            end
        end

        function label=addLabel(obj,varargin)

























            narginchk(2,4);

            validateattributes(obj,{'slproject.ProjectFile'},{'size',[1,1]},'','file');

            varargin=obj.replaceLabelDefinitions(varargin);

            mLabel=obj.mProjectFile.addLabel(varargin{:});

            label=slproject.Label(mLabel);
        end

        function removeLabel(obj,varargin)






















            narginchk(2,3);

            validateattributes(obj,{'slproject.ProjectFile'},{'size',[1,1]},'','file');
            varargin=obj.replaceLabelDefinitions(varargin);
            obj.mProjectFile.removeLabel(varargin{:});
        end

    end

    methods

        function path=get.Path(obj)
            path=char(obj.mProjectFile.Path);
        end


        function labels=get.Labels(obj)









            converter=@(x)slproject.Label(x);
            mLabels=obj.mProjectFile.Labels;
            if isempty(mLabels)
                labels=slproject.Label.empty(1,0);
                return;
            end
            labels=matlab.internal.project.util.transformArray(mLabels,converter);
        end

        function obj=set.Labels(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'Labels',...
            'slproject.ProjectFile',...
            'addLabel',...
            'slproject.ProjectFile');
        end

        function sourceControlStatus=get.SourceControlStatus(obj)










            sourceControlStatus=obj.mProjectFile.SourceControlStatus();
        end

        function stringRepresentation=get.Revision(obj)








            stringRepresentation=char(obj.mProjectFile.Revision);
        end
    end

    methods(Access=private)
        function args=replaceLabelDefinitions(obj,args)
            if isa(obj(1).mProjectFile,'matlab.internal.project.api.ProjectFile')...
                &&(isa(args{1},'slproject.LabelDefinition')||isa(args{1},'matlab.project.LabelDefinition'))
                if isempty(args{1})
                    args{1}=matlab.internal.project.api.LabelDefinition.empty(1,0);
                else
                    args{1}=matlab.internal.project.api.LabelDefinition(args{1}.CategoryName,args{1}.Name);
                end
            elseif isa(args{1},'slproject.LabelDefinition')
                if isempty(args{1})
                    args{1}=matlab.project.LabelDefinition.empty(1,0);
                else
                    args{1}=matlab.project.LabelDefinition(args{1}.CategoryName,args{1}.Name);
                end
            end
        end
    end

end
