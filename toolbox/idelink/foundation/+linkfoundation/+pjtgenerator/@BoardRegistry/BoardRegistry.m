classdef(Sealed=true)BoardRegistry<handle




    properties(Constant=true,Hidden=false)
        EIDEXMLRepository='eide_board_registry.xml';
        TSPXMLRepository='tsp_board_registry.xml';
    end

    properties(SetAccess='private')
        tag;
        BoardMap=[];
    end

    properties(Access='public')
        RegistryRoot='';
    end

    properties(Dependent=true,SetAccess='private',GetAccess='public')
        Boards;
        BoardNames;
        BoardDisplayNames;
        DefaultBoard;
        UDRepository;
    end

    methods(Access='public')



        function disp(h)
            disp(['Tag: ',h.tag]);
        end



        function board=getBoardInfoByName(h,name)
            if(~isa(h.BoardMap,'containers.Map')||0==h.BoardMap.length())
                h.initialize();
            end
            board=[];
            if(h.BoardMap.isKey(name))
                board=h.BoardMap(name);
            end
        end



        function board=getBoardInfoByDisplayName(h,name)
            if(~isa(h.BoardMap,'containers.Map')||0==h.BoardMap.length())
                h.initialize();
            end
            board=[];
            values=h.BoardMap.values;
            for index=1:length(values)
                board=values{index};
                if(strcmpi(name,board.DisplayName))
                    break;
                else
                    board=[];
                end
            end
        end



        function ret=isRegistered(h,name)
            if(~isa(h.BoardMap,'containers.Map')||0==h.BoardMap.length())
                h.initialize();
            end
            ret=h.BoardMap.isKey(name);
        end
    end

    methods(Access='private')



        function this=BoardRegistry
        end



        function initialize(h)

            h.BoardMap=containers.Map;

            eideBoardRegistry=fullfile(h.UDRepository,linkfoundation.pjtgenerator.BoardRegistry.EIDEXMLRepository);
            h.initializeFromXML(eideBoardRegistry);

            tspBoardRegistry=fullfile(h.UDRepository,linkfoundation.pjtgenerator.BoardRegistry.TSPXMLRepository);
            h.initializeFromXML(tspBoardRegistry);
        end




        function initializeFromXML(h,file)
            try
                fileObj=linkfoundation.util.File(file);
                if(~fileObj.exists())
                    return;
                end
                parser=matlab.io.xml.dom.Parser;
                domNode=parser.parseFile(fileObj.FullPathName);
                boardRepository=domNode.getDocumentElement();
                boardRegistries=boardRepository.getElementsByTagName('BoardRegistry');
                boardRegistry=[];
                for index=0:boardRegistries.getLength-1
                    boardRegistry=boardRegistries.item(index);
                    if(~strcmpi(h.tag,boardRegistry.getAttribute('name')))
                        boardRegistry=[];
                        continue;
                    else
                        break;
                    end
                end
                if(~isjava(boardRegistry))
                    return;
                end
                boardNodes=boardRegistry.getElementsByTagName('Board');
                for index=0:boardNodes.getLength-1
                    board=linkfoundation.pjtgenerator.BoardInfo(boardNodes.item(index));
                    if(board.isPlatformSupported())
                        h.BoardMap(board.Name)=board;
                    end
                end
            catch ex %#ok<NASGU>

            end
        end
    end

    methods(Static=true)



        function singleObj=manageInstance(action,tag)
            localStaticObj=[];
            idx=0;
            for i=1:length(localStaticObj)
                if strcmp(tag,localStaticObj(i).handle.tag)
                    idx=i;
                    break;
                end
            end

            switch action
            case{'create','get'}

                if idx==0,
                    idx=length(localStaticObj)+1;
                    localStaticObj(idx).handle=linkfoundation.pjtgenerator.BoardRegistry;
                    localStaticObj(idx).handle.tag=tag;
                end

                singleObj=localStaticObj(idx).handle;

            case 'destroy'
                if idx~=0
                    delete(localStaticObj(idx).handle);
                    localStaticObj(idx)=[];
                end
                if isempty(localStaticObj)
                    clear localStaticObj;
                end
                singleObj=[];

            otherwise

                singleObj=[];
                return;
            end
        end
    end

    methods



        function list=get.BoardNames(h)
            list=h.Boards;
            for index=1:length(list)
                board=list{index};
                list{index}=board.Name;
            end
        end



        function list=get.BoardDisplayNames(h)
            list=h.Boards;
            for index=1:length(list)
                board=list{index};
                list{index}=board.DisplayName;
            end
        end



        function list=get.Boards(h)
            if(~isa(h.BoardMap,'containers.Map')||0==h.BoardMap.length())
                h.initialize();
            end
            list=h.BoardMap.values;
        end



        function board=get.DefaultBoard(h)
            list=h.Boards;
            board=list{1};
        end



        function set.RegistryRoot(h,value)
            h.RegistryRoot=value;
        end



        function value=get.RegistryRoot(h)
            value=h.RegistryRoot;
        end



        function value=get.UDRepository(h)
            value=fullfile(h.RegistryRoot,'board');
        end
    end
end
