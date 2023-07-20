classdef FileTypeFactory<handle




    properties

CustomReaderList
PluggableNameSpaces
        InvalidNameSpacePlugins={}

    end


    methods(Static)


        function aFactory=getInstance()

            persistent instance;
            mlock;


            if isempty(instance)
                instance=Simulink.io.FileTypeFactory();
                instance.updateFactoryRegistry();
            else



                if any(~cellfun(@isvalid,instance.CustomReaderList))
                    instance.updateFactoryRegistry();
                end
            end

            aFactory=instance;
        end
    end


    methods(Access='protected')


        function aFactory=FileTypeFactory()

        end
    end


    methods


        function supportedReaders=getSupportedReaders(aFactory,fileName)

            if isStringScalar(fileName)
                fileName=char(fileName);
            end

            if~ischar(fileName)
                DAStudio.error('sl_web_widgets:customfiles:fileNameNotChar');
            end

            NUM_TYPES=length(aFactory.CustomReaderList);
            supportedReaders=cell(1,NUM_TYPES);

            for kType=1:NUM_TYPES

                try
                    IS_THIS_PLUGIN=feval([aFactory.CustomReaderList{kType}.Name,'.isFileSupported'],fileName);

                catch ME_

                    IS_THIS_PLUGIN=false;
                end

                if IS_THIS_PLUGIN

                    supportedReaders{kType}=aFactory.CustomReaderList{kType}.Name;
                end

            end
            supportedReaders(cellfun(@isempty,supportedReaders))=[];
        end


        function updateFactoryRegistry(aFactory)


            aFactory.InvalidNameSpacePlugins={};
            kInvalid=1;



            aFactory.PluggableNameSpaces=internal.findSubClasses('Simulink.io',...
            'Simulink.io.PluggableNamespace');

            aFactory.CustomReaderList={};
            for kNameSpace=1:length(aFactory.PluggableNameSpaces)

                namespacePlugin=feval(aFactory.PluggableNameSpaces{kNameSpace}.Name);

                try


                    tempList=internal.findSubClasses(namespacePlugin.Namespace,...
                    'Simulink.io.FileType');
                    aFactory.CustomReaderList=vertcat(aFactory.CustomReaderList,tempList);
                catch ME

                    aFactory.InvalidNameSpacePlugins{kInvalid,1}=aFactory.PluggableNameSpaces{kNameSpace}.Name;
                    aFactory.InvalidNameSpacePlugins{kInvalid,2}=ME.message;
                    kInvalid=kInvalid+1;
                end


            end


        end


        function aReader=createReader(~,fileName,readerName)

            if isStringScalar(fileName)
                fileName=char(fileName);
            end

            if~ischar(fileName)
                DAStudio.error('sl_web_widgets:customfiles:fileNameNotChar');
            end

            if isStringScalar(readerName)
                readerName=char(readerName);
            end

            if~ischar(readerName)
                DAStudio.error('sl_web_widgets:customfiles:readerNotChar');
            end

            try
                aReader=feval(readerName,fileName);
            catch ME_create
                DAStudio.error('sl_web_widgets:customfiles:createReaderFailure',readerName,fileName);
            end
        end
    end

end
