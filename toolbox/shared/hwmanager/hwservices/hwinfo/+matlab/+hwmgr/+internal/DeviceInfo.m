classdef(Abstract)DeviceInfo<handle&dynamicprops&matlab.mixin.SetGet














    properties(SetAccess=protected)


Type
    end

    properties


        BaseDir='';
    end

    properties

        Name='';
    end

    properties(Access=protected,Constant)
        IsEmptyValueOk=true;
    end


    methods(Static)

        function out=getInstance(type)



            validType={'ethernet','serial','custom'};
            validateattributes(type,{'char','string'},{'nonempty'});
            switch lower(type)
            case validType{1}
                out=matlab.hwmgr.internal.EthernetDevice();
            case validType{2}
                out=matlab.hwmgr.internal.SerialDevice();
            case validType{3}
                out=matlab.hwmgr.internal.CustomDevice();
            otherwise
                error(message('hwservices:hwinfo:UnknownDeviceType',...
                type,strjoin(validType,',')));
            end
        end
    end


    methods(Access=protected)

        function obj=DeviceInfo(varargin)


        end
    end


    methods
        function set.Name(obj,name)
            obj.validateStrsAndCharInputs(name);
            obj.Name=name;
        end

        function set.BaseDir(obj,folder)
            obj.validateStrsAndCharInputs(folder);
            obj.BaseDir=folder;
        end
    end


    methods

        function out=serialize(obj)



            try
                out=jsonencode(obj);
            catch ex
                error(message('hwservices:hwinfo:JsonEncodeError',ex.message))
            end
        end

        function out=getDeviceInfoFile(obj)




            out='';
            if~isempty(obj.BaseDir)
                out=obj.getDeviceInfoFileForBaseDir(obj.BaseDir);
            end
        end
    end

    methods(Static)

        function out=encrypt(in)
            validateattributes(in,{'char','string'},{'nonempty'});
            in=convertStringsToChars(in);
            out=matlab.hwmgr.internal.utils.AESEncrypt(in);
        end

        function out=decrypt(in)
            validateattributes(in,{'char','string'},{'nonempty'});
            in=convertStringsToChars(in);
            out=matlab.hwmgr.internal.utils.AESDecrypt(in);
        end

        function out=getObjFromFilename(filename)



            hwInfoData=fileread(filename);
            out={};
            try
                decryptedData=matlab.hwmgr.internal.DeviceInfo.decrypt(hwInfoData);
                out=matlab.hwmgr.internal.DeviceInfo.deserialize(decryptedData);
            catch
                warning(message('hwservices:hwinfo:InconsistentDevInfo'))
            end
        end

        function out=deserialize(in)


            try
                devInfoStruct=jsondecode(in);
            catch ex
                error(message('hwservices:hwinfo:JsonDecodeError',ex.message))
            end


            out=matlab.hwmgr.internal.DeviceInfo.reconstructFromStruct(devInfoStruct);

        end

        function out=getDeviceInfoFileForBaseDir(basedir)







            baseFolder=matlab.hwmgr.internal.utils.getDevInfoDir;
            subFolders=strsplit(...
            basedir,filesep);
            [~,idx]=find(ismember(subFolders,'toolbox'));
            if isempty(idx)


                idx=2;
            end
            subFolderToCreate=strjoin(subFolders(idx:end),filesep);

            foldername=fullfile(baseFolder,subFolderToCreate);
            out=fullfile(foldername,'hwInfo.json');

        end

    end

    methods(Static,Access=protected)
        function validateStrsAndCharInputs(value)
            validateattributes(value,{'char','string'},{});
        end
    end

    methods(Static,Access=private)

        function out=reconstructFromStruct(in)

            validateattributes(in,{'struct'},{'nonempty'});
            out=matlab.hwmgr.internal.DeviceInfo.getInstance(in.Type);
            baseProperties=properties(out);
            for fn=fieldnames(in)'
                if~ismember(baseProperties,fn{1})
                    addprop(out,fn{1});
                end
                if~isequal(fn{1},'Type')
                    try
                        out.(fn{1})=in.(fn{1});
                    catch
                        warning(message('hwservices:hwinfo:UnableToSetProp',fn{1}));
                    end
                end
            end
        end
    end
end


