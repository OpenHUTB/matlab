classdef Part<handle




    properties
        PartName(1,:)char=''
        InformationStruct(1,1)struct=struct()
        FileList(1,:)ssm.sl_agent_metadata.internal.part.FileProperty=...
        ssm.sl_agent_metadata.internal.part.FileProperty.empty
        SubPartList(1,:)cell
    end

    methods(Abstract)


        populateFileList(obj)


        populateInformation(obj)
    end

    methods(Access=public)

        function obj=Part(partName)
            obj.PartName=partName;
        end

        function obj=addSubPart(obj,aPart)
            if isempty(aPart)||~isa(aPart,'ssm.sl_agent_metadata.internal.part.Part')
                return
            end

            obj.SubPartList{end+1}=aPart;
        end

        function obj=populateAllInformation(obj)



            obj.clearInformation();
            obj.populateInformation();

            for idx=1:numel(obj.SubPartList)
                aSubPart=obj.SubPartList{idx};
                subPartName=aSubPart.PartName;


                if isempty(subPartName);continue;end


                aSubPart.clearInformation();
                aSubPart.populateAllInformation();


                if isfield(obj.InformationStruct,subPartName)
                    obj.InformationStruct.(subPartName)=...
                    obj.mergeStruct(obj.InformationStruct.(subPartName),aSubPart.InformationStruct);
                else
                    obj.InformationStruct.(subPartName)=aSubPart.InformationStruct;
                end
            end

        end

        function obj=populateAllFileList(obj)



            obj.clearFileList();
            obj.populateFileList();


            for idx=1:numel(obj.SubPartList)
                aSubPart=obj.SubPartList{idx};
                subPartName=aSubPart.PartName;


                if isempty(subPartName);continue;end


                aSubPart.clearFileList();
                aSubPart.populateAllFileList();
                subFileList=aSubPart.FileList;


                for idy=1:numel(subFileList)
                    subfileInfo=subFileList(idy);


                    subfileInfo.DstFolder=fullfile(aSubPart.PartName,subfileInfo.DstFolder);
                    obj.FileList(end+1)=subfileInfo;
                end
            end
        end
    end

    methods(Access=protected)
        function obj=addPartUsingFullFilePath(obj,filepath,tgtDir)



            if isempty(filepath)||(exist(filepath,'file')~=2);return;end


            [~,~,extFile]=fileparts(filepath);
            fullfilepath=filepath;
            if~isempty(extFile)
                fullfilepath=which(filepath);
            end

            [filepath,name,ext]=fileparts(fullfilepath);

            fileProperty=ssm.sl_agent_metadata.internal.part.FileProperty;
            fileProperty.FileName=[name,ext];
            fileProperty.SrcFolder=filepath;
            fileProperty.DstFolder=tgtDir;

            obj.FileList(end+1)=fileProperty;
        end

        function obj=addPartUsingFilePattern(obj,patternName,tgtDir)



            patternDir=dir(patternName);
            for idx=1:numel(patternDir)

                fDir=patternDir(idx);


                if fDir.isdir;continue;end


                fInfo=ssm.sl_agent_metadata.internal.part.FileProperty;
                fInfo.FileName=fDir.name;
                fInfo.SrcFolder=fDir.folder;
                fInfo.DstFolder=tgtDir;

                obj.FileList(end+1)=fInfo;
            end
        end

        function obj=clearInformation(obj)
            obj.InformationStruct=struct();
        end

        function obj=clearFileList(obj)
            obj.FileList=ssm.sl_agent_metadata.internal.part.FileProperty.empty;
        end

        function obj=clearSubPartList(obj)
            obj.SubPartList={};
        end
    end

    methods(Access=private,Static)
        function sta=mergeStruct(sta,stb)


            if~isstruct(sta)||~isstruct(stb)
                return
            end

            fdb=fields(stb);
            for idx=1:length(fdb)
                fnameStb=fdb{idx};
                valueStb=stb.(fnameStb);

                if isfield(sta,fnameStb)


                    if isstruct(sta.(fnameStb))&&isstruct(valueStb)

                        stMerge=ssm.sl_agent_metadata.internal.part.Part.mergeStruct(sta.(fnameStb),valueStb);
                        sta.(fnameStb)=stMerge;

                    else

                        valueSta=sta.(fnameStb);


                        if ischar(valueSta);valueSta={valueSta};end
                        if ischar(valueStb);valueStb={valueStb};end

                        vmerge={valueSta,valueStb};
                        sta.(fnameStb)=[vmerge{:}];
                    end

                else

                    sta.(fnameStb)=valueStb;
                end
            end
        end
    end
end


