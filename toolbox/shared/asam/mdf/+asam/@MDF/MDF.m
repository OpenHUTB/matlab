classdef MDF<matlab.mixin.SetGet&matlab.mixin.CustomDisplay












    properties(SetAccess=public,GetAccess=public)


        Conversion(1,1)asam.mdf.Conversion='Numeric'
    end

    properties(SetAccess=private,GetAccess=public)

Name

Path

Author

Department

Project

Subject

Comment

Version

        DataSize=0;

InitialTimestamp

ProgramIdentifier

Creator


Attachment

ChannelNames


ChannelGroup
    end

    properties(Transient,SetAccess=private,GetAccess=private)



MEXFileHandle


VersionNumber
Handle
    end

    methods

        function obj=MDF(file,varargin)



            if ismac()
                error(message('asam_mdf:MDF:PlatformNotSupported'));
            end


            file=convertStringsToChars(file);


            p=inputParser;
            p.addRequired('file',@(x)validateattributes(x,{'char'},{'nonempty','row'}));
            p.addParameter('MathWorksMDFInternalControl','BlockControlledAccess');
            p.parse(file,varargin{:});


            if string(p.Results.MathWorksMDFInternalControl)~="AllowControlledAccess"
                asam.mdf.FileInterface.licenseCheck();
            end


            [fileName,fileFullPath]=asam.mdf.FileInterface.validateMDFFilePath(file);



            obj.Handle=asam.mdf.FileInterface.Open(char(fileFullPath));



            [creatorDetailsStruct,fileDetailsStruct,attachmentDetailsStruct,chanGrpDetailsStruct]=asam.mdf.FileInterface.Parse(obj.Handle);


            obj.Name=fileName;
            obj.Path=fileFullPath;


            obj.Creator=creatorDetailsStruct;


            obj.Author=fileDetailsStruct.Author;
            obj.Department=fileDetailsStruct.Department;
            obj.Project=fileDetailsStruct.Project;
            obj.Subject=fileDetailsStruct.Subject;
            obj.Comment=fileDetailsStruct.Comment;
            obj.Version=fileDetailsStruct.Version;
            obj.VersionNumber=fileDetailsStruct.VersionNumber;
            obj.ProgramIdentifier=fileDetailsStruct.ProgramIdentifier;
            obj.InitialTimestamp=fileDetailsStruct.InitialTimestamp;


            obj.Attachment=attachmentDetailsStruct;


            obj.ChannelGroup=chanGrpDetailsStruct;


            obj.DataSize=sum([obj.ChannelGroup.DataSize]);


            for ii=1:numel(obj.ChannelGroup)
                obj.ChannelNames{ii}={obj.ChannelGroup(ii).Channel.Name}';
            end


            obj.ChannelNames=obj.ChannelNames';
            obj.ChannelGroup=obj.ChannelGroup';
        end

        function delete(obj)






            if~isempty(obj.Handle)
                asam.mdf.FileInterface.Close(obj.Handle);
            end
        end

        function saveAttachment(obj,name,varargin)


















            try


                narginchk(2,3);


                [name,varargin{:}]=convertStringsToChars(name,varargin{:});


                validateattributes(name,{'char'},{'nonempty','row'},'saveAttachment','NAME');


                if nargin==3

                    destination=varargin{1};
                    validateattributes(destination,{'char'},{'nonempty','row'},'saveAttachment','DESTINATION');
                else

                    destination=name;
                end


                index=find(strcmpi(name,{obj.Attachment.Name}));


                if isempty(index)
                    error(message('asam_mdf:MDF:AttachmentNotFound'));
                end




                asam.mdf.FileInterface.SaveAttachment(obj.Handle,index,destination);

            catch ME

                throwAsCaller(ME);
            end
        end

        function out=struct(obj)



            out.Name=obj.Name;
            out.Path=obj.Path;
            out.Author=obj.Author;
            out.Department=obj.Department;
            out.Project=obj.Project;
            out.Subject=obj.Subject;
            out.Comment=obj.Comment;
            out.Version=obj.Version;
            out.DataSize=obj.DataSize;
            out.InitialTimestamp=obj.InitialTimestamp;
            out.ProgramIdentifier=obj.ProgramIdentifier;
            out.Creator=obj.Creator;
            out.Attachment=obj.Attachment;
            out.ChannelNames=obj.ChannelNames;
            out.ChannelGroup=obj.ChannelGroup;
        end


        [out,varargout]=read(obj,chGroupIndex,chName,varargin)
        out=channelList(obj,varargin)
    end

    methods(Hidden)

        function write(obj,varargin)%#ok<INUSD>




            try
                error(message('asam_mdf:MDF:ObjectBasedMethodNotSupported','mdfWrite'));
            catch ME

                throwAsCaller(ME);
            end
        end

        function addAttachment(obj,varargin)%#ok<INUSD> 





            try
                error(message('asam_mdf:MDF:ObjectBasedMethodNotSupported','mdfAddAttachment'));
            catch ME

                throwAsCaller(ME);
            end
        end

        function removeAttachment(obj,varargin)%#ok<INUSD> 





            try
                error(message('asam_mdf:MDF:ObjectBasedMethodNotSupported','mdfRemoveAttachment'));
            catch ME

                throwAsCaller(ME);
            end
        end
    end

    methods(Access=protected)

        function group=getPropertyGroups(obj)%#ok<MANU>



            title1=sprintf('File Details');
            plist1={'Name','Path','Author','Department','Project',...
            'Subject','Comment','Version','DataSize','InitialTimestamp'};
            title2=sprintf('Creator Details');
            plist2={'ProgramIdentifier','Creator'};
            title3=sprintf('File Contents');
            plist3={'Attachment','ChannelNames','ChannelGroup'};
            title4=sprintf('Options');
            plist4={'Conversion'};


            group(1)=matlab.mixin.util.PropertyGroup(plist1,title1);
            group(2)=matlab.mixin.util.PropertyGroup(plist2,title2);
            group(3)=matlab.mixin.util.PropertyGroup(plist3,title3);
            group(4)=matlab.mixin.util.PropertyGroup(plist4,title4);
        end

    end

    methods(Access=private)

        function out=isMDF4Version(obj)





            if obj.VersionNumber>=4.00
                out=true;
            else
                out=false;
            end
        end
    end

    methods(Static,Hidden)

        function newObj=loadobj(obj)







            try
                newObj=asam.MDF(obj.Path);

            catch err %#ok<NASGU>



                newObj=asam.MDF.empty();
            end
        end

    end

    methods(Static,Hidden,Access=public)

        function fullFilePath=findFullFilePath(file)








            fullFilePath=which(file);
            if~strcmp(fullFilePath,'')

                return;
            end


            [status,info]=fileattrib(file);
            if status

                fullFilePath=info.Name;
            end
        end
    end

end
