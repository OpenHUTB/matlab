


classdef Dialog<handle
    properties(Access=private)
fStudio
fChannel

fUrl
fDebugUrl

        fSubscribe={}
        fListeners={}

fCurrentFile
fCurrentData
fData
fCodeLanguage
    end

    properties(Constant)
        id='SLCIManualReview'
        title='Code Inspector Manual Review'
        comp='GLUE2:DDG Component'
        tag='Tag_ManualReview'
        dockposition='bottom'
        dockoption='Tabbed'

    end

    methods

        function obj=Dialog(st)
            obj.fStudio=st;

            obj.init();
        end


        function delete(obj)

            saveData=questdlg(['Data has been updated.'...
            ,' Would you like to save the data?'],...
            'Save data','Save','Ignore','Save');
            if strcmp(saveData,'Save')
                obj.exportData();
            end

            for i=1:numel(obj.fSubscribe)
                message.unsubscribe(obj.fSubscribe{i});
            end
            obj.fSubscribe={};


            for i=1:numel(obj.fListeners)
                delete(obj.fListeners{i});
            end
            obj.fListeners={};

        end
    end

    methods



        url=getUrl(obj);


        receive(obj,msg);


        exportData(obj);


        refresh(obj);


        insertData(obj,codeline);


        reloadTable(obj,codeLanguage,file);


        anno=getAnnotationData(obj,data);


        function out=getStudio(obj)
            out=obj.fStudio;
        end


        function[source_file,file_name]=getManualReviewFile(obj)
            source_file=obj.getCurrentFile;
            file_name=obj.getJsonFile(source_file);
        end

        function out=getJsonFile(~,file_name)
            out=[file_name,'_manual_review.json'];
        end
    end

    methods


        function out=hasData(obj,codeline)
            out=isKey(obj.fCurrentData,codeline);
        end


        function populateData(obj,codeline,data)
            obj.fCurrentData(codeline)=data;
        end


        function out=getData(obj)
            out=obj.fData;
        end


        function setCurrentFile(obj,file)
            obj.fCurrentFile=file;
        end


        function out=getCurrentFile(obj)
            out=obj.fCurrentFile;
        end


        function saveCurrentData(obj)
            if~isempty(obj.getCurrentFile)
                obj.fData(obj.getCurrentFile)=obj.fCurrentData;
            end
        end


        function setCurrentData(obj,data)
            obj.fCurrentData=data;
        end


        function out=getCurrentData(obj)
            out=obj.fCurrentData;
        end


        function setCodeLanguage(obj,aCodeLanguage)
            obj.fCodeLanguage=aCodeLanguage;
        end


        function out=getCodeLanguage(obj)
            out=obj.fCodeLanguage;
        end
    end

    methods(Access=protected)

        function setUrl(obj,url)
            obj.fUrl=url;
        end


        function setDebugUrl(obj,url)
            obj.fDebugUrl=url;
        end


        function setChannel(obj,channel)
            obj.fChannel=channel;
        end


        function out=getChannel(obj)
            out=obj.fChannel;
        end


        function subscribe(obj,msg)
            obj.fSubscribe{end+1}=msg;
        end


        function addListeners(obj,listener)
            obj.fListeners{end+1}=listener;
        end

    end

    methods(Access=protected)

        init(obj);
    end

    methods(Access=private)

        sendData(obj,msgID,codeLanguage,data);
        reloadData(obj);
        updateData(obj,data);
        deleteData(obj,codeLanguage,data);
        onRowSelected(obj,codeLanguage,data);
        out=constructStructData(obj,data);


        updateCodeViewAnnotation(obj,codeLanguage,data);


        function out=constructKey(~,input)

            input=strrep(input,'.','_');
            input=strrep(input,':','_');
            input=strrep(input,'-','_');
            out=['l',input];
        end

    end

end