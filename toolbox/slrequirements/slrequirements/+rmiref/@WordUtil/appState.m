function varargout=appState(method,varargin)




    switch method

    case 'get'
        varargout{1}=reqmgt('findProc','WINWORD.EXE');
        if varargout{1}
            hWord=rmiref.WordUtil.getApplication(true);
            hDocs=hWord.Documents;
            count=hDocs.Count;
            docs=cell(1,count);
            for i=1:count
                thisDoc=hDocs.Item(i);
                docs{i}=thisDoc.FullName;
            end
            varargout{2}=docs;
        else
            varargout{2}={};
        end

    case 'restore'
        if varargin{1}
            docs=varargin{2};
            hWord=rmiref.WordUtil.getApplication(true);
            hDocs=hWord.Documents;
            count=hDocs.Count;
            for i=count:-1:1
                thisDoc=hDocs.Item(i);
                thisDocPath=thisDoc.FullName;
                if~any(strcmp(thisDocPath,docs))
                    thisDoc.Close();
                end
            end
        elseif reqmgt('findProc','WINWORD.EXE')
            hWord=rmiref.WordUtil.getApplication(true);

            hWord.Quit(0);
        end

    otherwise
        error(message('Slvnv:rmi:informer:UnsupportedMethod',method,'rmiref.WordUtil.appState()'));
    end
end