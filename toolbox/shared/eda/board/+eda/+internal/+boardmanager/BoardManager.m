


classdef BoardManager<handle

    properties(Access=private)
        PreInstalledList;

        UserInstalledList;

        CustomList;

        BoardObjList;

        DialogHandle;
    end

    methods(Access=private)
        function obj=BoardManager
            obj.reset;
        end

        function loadSupportPackage(obj,customFile)
            [customfolder,customname,~]=fileparts(customFile);


            currentFolder=pwd;
            cd(customfolder);
            try
                boardObjList=feval(customname,'getboard');
                cd(currentFolder);


                for m=1:length(boardObjList)
                    boardObj=boardObjList(m);
                    if~obj.PreInstalledList.isKey(boardObj.BoardName)

                        obj.PreInstalledList(boardObj.BoardName)='';
                        obj.BoardObjList(boardObj.BoardName)=boardObj;
                    else


                        existBoardObj=obj.BoardObjList(boardObj.BoardName);

                        existInterfList=existBoardObj.FPGA.getInterfaceList;
                        newInterfList=boardObj.FPGA.getInterfaceList;
                        addInterfList=setdiff(newInterfList,existInterfList);

                        for n=1:numel(addInterfList)
                            interface=boardObj.FPGA.getInterface(addInterfList{n});
                            existBoardObj.FPGA.setInterface(interface);
                        end
                    end
                end
            catch ME
                warning(message('EDALink:boardmanager:LoadCustomFileFailed',customFile,ME.message));
                cd(currentFolder);
            end

        end

        function list=getPref(obj)
            tmp=getpref('FPGA','Board');

            valid=true;
            if~isa(tmp,'containers.Map')
                valid=false;
            elseif~strcmpi(tmp.KeyType,'char')
                valid=false;
            end

            if~valid
                warning(message('EDALink:boardmanager:InvalidPref'));
                list=containers.Map;
                setpref('FPGA','Board',list);
                return;
            end




            boardNames=tmp.keys;
            for m=1:numel(boardNames)
                if obj.PreInstalledList.isKey(boardNames{m})
                    warning(message('EDALink:boardmanager:DupBoard2',...
                    boardNames{m}));
                    tmp.remove(boardNames{m});
                    setpref('FPGA','Board',tmp);
                end
            end

            list=tmp;
        end

        function loadUserInstalledBoards(obj)
            basePath=fullfile(matlabroot,'toolbox','shared','eda','board','boardfiles');
            if~exist(basePath,'dir')
                return;
            end
            dirs=dir(basePath);
            for m=1:length(dirs)
                if~dirs(m).isdir
                    boardFile=fullfile(basePath,dirs(m).name);
                    try
                        boardObj=eda.internal.boardmanager.ReadFPGAFile(boardFile);

                        obj.PreInstalledList(boardObj.BoardName)=boardFile;
                        obj.UserInstalledList(boardObj.BoardName)=boardFile;
                        obj.BoardObjList(boardObj.BoardName)=boardObj;
                    catch ME
                        warning(message('EDALink:boardmanager:CorruptFile',boardFile,ME.message));
                    end
                end
            end
        end
    end
    methods(Static)
        function singleObj=getInstance(reset)
            mlock;
            persistent localObj
            if nargin==1&&strcmpi(reset,'reset')
                localObj=[];
                singleObj=[];
                return;
            elseif isempty(localObj)
                localObj=eda.internal.boardmanager.BoardManager;
            end
            singleObj=localObj;
        end
    end
    methods
        function reset(obj)

            obj.PreInstalledList=containers.Map;
            obj.UserInstalledList=containers.Map;
            obj.CustomList=containers.Map;
            obj.BoardObjList=containers.Map;


            customizationFiles=l_searchFileByName('hdlcoder_turnkey_customization');
            for m=1:numel(customizationFiles)
                loadSupportPackage(obj,customizationFiles{m});
            end


            customizationFiles=l_searchFileByName('hdlverifier_fil_customization');
            for m=1:numel(customizationFiles)
                loadSupportPackage(obj,customizationFiles{m});
            end

            loadUserInstalledBoards(obj);

            if~ispref('FPGA','Board')
                setpref('FPGA','Board',obj.CustomList);
            else
                obj.CustomList=getPref(obj);
            end

            obj.DialogHandle=[];


            customBoardNames=getCustomBoardNames(obj);
            for m=1:numel(customBoardNames)
                loadBoardObj(obj,customBoardNames{m});
            end

        end

        function filBoardObj=getFILBoardObj(obj,BoardName)
            boardObj=obj.getBoardObj(BoardName);
            if boardObj.isFILCompatible
                if~isempty(boardObj.FILBoardClass);
                    filBoardObj=eval(boardObj.FILBoardClass);
                else
                    filBoardObj=eda.internal.boardmanager.convertToFilObject(boardObj);
                end
            else
                filBoardObj=[];
            end
        end


        function hDlg=launchGUI(obj,varargin)
            if isa(obj.DialogHandle,'DAStudio.Dialog');
                warning(message('EDALink:boardmanager:GUIExist'));
                hDlg=[];
            else
                hBoardMgr=boardmanagergui.FPGABoardManager;
                hDlg=DAStudio.Dialog(hBoardMgr);
                obj.DialogHandle=hDlg;

                if nargin==2
                    hBoardMgr.ParentDlg=varargin{1};
                end
            end
        end


        function h=getDialogHandle(obj)
            h=obj.DialogHandle;
        end


        function refreshGUI(obj)
            if isa(obj.DialogHandle,'DAStudio.Dialog')
                obj.DialogHandle.refresh;
            end
        end
        function r=getPreInstalledBoardNames(obj)
            r=obj.PreInstalledList.keys;
        end
        function r=getCustomBoardNames(obj)
            r=obj.CustomList.keys;
        end
        function r=isPreInstalled(obj,name)
            r=obj.PreInstalledList.isKey(name);
        end
        function r=isBoardEditable(obj,name)
            r=false;
            try
                if~isCustom(obj,name)
                    r=false;
                else
                    boardFile=getBoardFile(obj,name);
                    [success,attr]=fileattrib(boardFile);
                    if success
                        r=attr.UserWrite;
                    end
                end
            catch ME %#ok<NASGU>



            end
        end
        function r=isCustom(obj,name)
            r=obj.CustomList.isKey(name);
        end
        function r=getAllBoardNames(obj)
            n1=obj.PreInstalledList.keys;
            n2=obj.CustomList.keys;
            r=union(n1,n2,'sorted');
        end
        function r=getCustomBoardFiles(obj)
            r=obj.CustomList.values;
        end
        function r=getAllBoardFiles(obj)
            v1=getCustomBoardFiles(obj);
            v2=obj.PreInstalledList.values;
            r=union(v1,v2,'sorted');
        end
        function r=getBoardFile(obj,boardName)
            if obj.CustomList.isKey(boardName)
                r=obj.CustomList(boardName);
            elseif obj.PreInstalledList.isKey(boardName)
                r=obj.PreInstalledList(boardName);
            else
                error(message('EDALink:boardmanager:BoardNotExist',boardName));
            end
        end

        function r=isBoard(obj,name)
            r=obj.PreInstalledList.isKey(name)||obj.CustomList.isKey(name);
        end

        function removeBoard(obj,boardName)
            if obj.CustomList.isKey(boardName)
                obj.CustomList.remove(boardName);
                obj.BoardObjList.remove(boardName);
                setpref('FPGA','Board',obj.CustomList);
            elseif obj.PreInstalledList.isKey(boardName)
                error(message('EDALink:boardmanager:RemoveFactoryBoard'));
            else
                error(message('EDALink:boardmanager:BoardNotExist',boardName));
            end
        end

        function[r,boardName]=isBoardFile(obj,filename)
            r=false;
            boardName='';
            allfiles=obj.getCustomBoardFiles;
            if any(strcmp(filename,allfiles))
                keys=obj.CustomList.keys;
                for m=1:numel(keys)
                    tmp=obj.CustomList(keys{m});
                    if strcmp(tmp,filename)
                        boardName=keys{m};
                        r=true;
                        return;
                    end
                end
            end

            allfiles=obj.PreInstalledList.values;
            if any(strcmp(filename,allfiles))
                keys=obj.PreInstalledList.keys;
                for m=1:numel(keys)
                    if strcmp(obj.PreInstalledList(keys{m}),filename)
                        boardName=keys{m};
                    end
                    r=true;
                    return;
                end
            end
        end

        function validateNewBoardFile(obj,file)
            [r,existBoardName]=isBoardFile(obj,file);
            if r
                error(message('EDALink:boardmanager:BoardFileConflict',file,existBoardName));
            end


            [fid,msg]=fopen(file,'w');
            if fid>=0
                fclose(fid);
            else
                error(message('EDALink:boardmanager:WriteFileFailed',file,msg));
            end
        end

        function validateNewBoardName(obj,name)
            if obj.isBoard(name)
                error(message('EDALink:boardmanager:BoardNameConflict',name));
            end
        end

        function saveBoard(obj,boardObj,oldBoardName,oldBoardFile)
            if~isempty(oldBoardName)


                if~strcmp(oldBoardName,boardObj.BoardName)
                    obj.validateNewBoardName(boardObj.BoardName);
                end


                if~strcmp(oldBoardFile,boardObj.BoardFile)
                    obj.validateNewBoardFile(boardObj.BoardFile);
                end

            else


                obj.validateNewBoardName(boardObj.BoardName);
                obj.validateNewBoardName(boardObj.BoardName);
            end

            eda.internal.boardmanager.SaveFPGAFile(boardObj);

            if~isempty(oldBoardName)
                obj.removeBoard(oldBoardName);
            end

            obj.CustomList(boardObj.BoardName)=boardObj.BoardFile;

            obj.BoardObjList(boardObj.BoardName)=boardObj;
            setpref('FPGA','Board',obj.CustomList);

        end

        function boardNames=addBoardByFileName(obj,filename)

            if~iscell(filename)
                filename={filename};
            end
            boardNames=cell(1,numel(filename));
            for m=1:numel(filename)
                try
                    boardObj=eda.internal.boardmanager.ReadFPGAFile(filename{m});
                    obj.validateNewBoardName(boardObj.BoardName);
                    obj.CustomList(boardObj.BoardName)=filename{m};
                    obj.BoardObjList(boardObj.BoardName)=boardObj;
                    boardNames{m}=boardObj.BoardName;
                catch ME

                    if ispref('FPGA','Board')
                        obj.CustomList=getpref('FPGA','Board');
                    else
                        obj.CustomList=containers.Map;
                    end
                    error(message('EDALink:boardmanager:AddBoardFileFailed',filename{m},ME.message));
                end
            end
            setpref('FPGA','Board',obj.CustomList);
        end

        function loadBoardObj(obj,boardName)
            try
                boardFile=obj.getBoardFile(boardName);
                boardObj=eda.internal.boardmanager.ReadFPGAFile(boardFile);
                obj.BoardObjList(boardName)=boardObj;
            catch ME
                obj.removeBoard(boardName);
                warning('EDALink:boardmanager:CorruptBoardFile',...
                'Board configuration file "%s" registered with board "%s" is invalid: %s. Removed this board from the list.',...
                boardFile,boardName,ME.message);
            end
        end

        function boardObj=addBoardObj(obj,boardName,boardObj)
            obj.BoardObjList(boardName)=boardObj;
        end

        function removeBoardObj(obj,boardName)
            obj.BoardObjList.remove(boardName);
        end

        function boardObj=getBoardObj(obj,boardName)
            if obj.BoardObjList.isKey(boardName)
                boardObj=obj.BoardObjList(boardName);
            else
                boardFile=obj.getBoardFile(boardName);
                try
                    boardObj=eda.internal.boardmanager.ReadFPGAFile(boardFile);
                    obj.BoardObjList(boardName)=boardObj;
                catch ME
                    obj.removeBoard(boardName);
                    error(message('EDALink:boardmanager:LoadBoardObjError',...
                    boardFile,boardName,ME.message));
                end
            end
        end

        function boardList=getFILBoardNamesByVendor(obj,Vendor)
            allNames=getAllBoardNames(obj);
            boardList=cell(1,0);
            for m=1:numel(allNames)
                name=allNames{m};
                boardObj=getBoardObj(obj,name);
                if boardObj.isFILCompatible
                    if strcmpi(boardObj.FPGA.Vendor,Vendor)||strcmpi(Vendor,'All')
                        boardList=[boardList,{name}];%#ok<AGROW>
                    end
                end
            end
        end

        function boardList=getTurnkeyBoardNames(obj)
            allNames=getAllBoardNames(obj);
            boardList=cell(1,0);
            for m=1:numel(allNames)
                boardObj=getBoardObj(obj,allNames{m});
                if boardObj.isTurnkeyCompatible
                    boardList=[boardList,{boardObj.BoardName}];%#ok<AGROW>
                end
            end
        end

        function tkBoardObj=getTurnkeyBoardObj(obj,name)
            boardObj=getBoardObj(obj,name);
            if boardObj.isTurnkeyCompatible
                tkBoardObj=eda.internal.boardmanager.convertToTurnkeyObject(boardObj);
            else
                tkBoardObj=[];
            end
        end

        function tkBoardObjs=getCustomTurnkeyBoardObjs(obj)
            allNames=getAllBoardNames(obj);
            tkBoardObjs=[];
            for m=1:numel(allNames)
                name=allNames{m};
                boardObj=getBoardObj(obj,name);
                if boardObj.isTurnkeyCompatible&&isempty(boardObj.TurnkeyBoardClass)
                    tmp=eda.internal.boardmanager.convertToTurnkeyObject(boardObj);
                    tkBoardObjs=[tkBoardObjs,tmp];%#ok<AGROW>
                end
            end
        end
    end
end

function allFiles=l_searchFileByName(fileName)

    allFiles=which(fileName,'-ALL');


    for ii=1:length(allFiles)
        [folder,name,~]=fileparts(allFiles{ii});
        allFiles{ii}=fullfile(folder,name);
    end
    allFiles=unique(allFiles);
end




