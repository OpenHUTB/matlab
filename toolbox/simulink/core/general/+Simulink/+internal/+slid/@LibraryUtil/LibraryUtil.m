classdef LibraryUtil<handle





    methods(Static)


        function rst=clearVariable(libraryName,varNames)
            Simulink.internal.slid.LibraryUtil.checkIsLibraryLoaded(libraryName);
            varNames=Simulink.internal.slid.LibraryUtil.checkVariableNames(varNames);

            libDict=Simulink.internal.slid.LibraryUtil.getIntrinsicDictAndModel(libraryName);
            varNum=length(varNames);
            rst=zeros(1,varNum);

            for ii=1:varNum
                varName=varNames{ii};
                rst(ii)=Simulink.internal.slid.LibraryUtil.clearSlidObject(libDict,varName);
            end
        end




        function rst=importFromBaseWorkspace(libraryName,varNames)
            Simulink.internal.slid.LibraryUtil.checkIsLibraryLoaded(libraryName);

            varNames=Simulink.internal.slid.LibraryUtil.checkVariableNames(varNames);
            slObjMap=Simulink.internal.slid.LibraryUtil.getSlObjectsFromBaseWorkspace(varNames);

            [libDict,mf0Mdl]=Simulink.internal.slid.LibraryUtil.getIntrinsicDictAndModel(libraryName);
            varNum=length(varNames);
            rst=zeros(1,varNum);

            for ii=1:varNum
                varName=varNames{ii};
                rst(ii)=Simulink.internal.slid.LibraryUtil.importSingleSlObject(libDict,mf0Mdl,varName,slObjMap);
            end
        end





        function rst=importSlObjects(libraryName,slObjCell)
            Simulink.internal.slid.LibraryUtil.checkIsLibraryLoaded(libraryName);

            slObjMap=Simulink.internal.slid.LibraryUtil.createObjMap(slObjCell);

            [libDict,mf0Mdl]=Simulink.internal.slid.LibraryUtil.getIntrinsicDictAndModel(libraryName);
            [objNum,~]=size(slObjCell);
            rst=zeros(1,objNum);

            for ii=1:objNum
                rst(ii)=Simulink.internal.slid.LibraryUtil.importSingleSlObject(libDict,mf0Mdl,slObjCell{ii,1},slObjMap);
            end
        end



        function rst=hasVariable(libraryName,varName)
            Simulink.internal.slid.LibraryUtil.checkIsLibraryLoaded(libraryName);
            Simulink.internal.slid.LibraryUtil.checkVariableName(varName);

            libDict=Simulink.internal.slid.LibraryUtil.getIntrinsicDictAndModel(libraryName);
            rst=~isempty(libDict.ValueType.getByKey(varName));
        end




        function rst=getVariable(libraryName,varName)
            Simulink.internal.slid.LibraryUtil.checkIsLibraryLoaded(libraryName);
            Simulink.internal.slid.LibraryUtil.checkVariableName(varName);
            rst=[];
        end
    end

    methods(Static,Access=private)



        function[libDict,mf0Mdl]=getIntrinsicDictAndModel(libName)
            libDict=get_param(libName,'DictionarySystem');
            mf0Mdl=mf.zero.getModel(libDict);
        end



        function rst=clearSlidObject(libDict,name)
            slidObj=libDict.ValueType.getByKey(name);
            if isempty(slidObj)
                rst=true;
                return;
            end

            rst=true;
            libDict.Interface.Type.remove(slidObj);
            libDict.ValueType.remove(slidObj);
            slidObj.destroy;
        end


        function rst=importSingleSlObject(libDict,mf0Mdl,name,slObjMap)
            rst=false;
            slidObj=Simulink.internal.slid.LibraryUtil.convertSlObjectToSlidObject(mf0Mdl,name,slObjMap);


            if~isempty(slidObj)
                Simulink.internal.slid.LibraryUtil.clearSlidObject(libDict,name);

                libDict.ValueType.add(slidObj);
                libDict.Interface.Type.add(slidObj);
                rst=true;
            end
        end



        slidObj=convertSlObjectToSlidObject(mf0Mdl,name,object);
    end

    methods(Static,Access=private)


        function checkIsLibraryLoaded(libName)
            if~bdIsLoaded(libName)
                DAStudio.error('slid:messages:LibraryNotLoaded',libName);
            end

            if~bdIsLibrary(libName)
                DAStudio.error('slid:messages:NotALibrary',libName);
            end
        end


        function varNames=checkVariableNames(varNames)
            if ischar(varNames)
                varNames={varNames};
            elseif isstring(varNames)
                varNames=varNames.cellstr;
            end

            assert(iscell(varNames),'Variable names must be in a cell');
            [row,~]=size(varNames);
            assert(row==1,'Variable names must be in a 1*N cell');

            for ii=1:length(varNames)
                varNames{ii}=Simulink.internal.slid.LibraryUtil.checkVariableName(varNames{ii});
            end
        end


        function name=checkVariableName(name)
            if~isvarname(name)
                DAStudio.error('Simulink:Data:WksInvalidVariableName',name);
            end

            if isstring(name)
                name=name.char;
            end
        end


        function objMap=createObjMap(objectCell)
            objMap=containers.Map;

            assert(iscell(objectCell),'Simulink objects must be in a cell');
            [row,col]=size(objectCell);
            assert(col==2);

            for ii=1:row
                varName=objectCell{ii,1};
                slObj=objectCell{ii,2};


                try
                    varName=Simulink.internal.slid.LibraryUtil.checkVariableName(varName);
                catch ME
                    remove(objMap,keys(objMap));
                    throw(ME);
                end


                if isKey(objMap,varName)&&~isequal(slObj,objMap(varName))
                    remove(objMap,keys(objMap));
                    DAStudio.error('slid:messages:InconsistSimulinkObject',varName);
                end

                objMap(varName)=slObj;
            end
        end



        function slObjMap=getSlObjectsFromBaseWorkspace(varNames)
            assert(iscell(varNames));
            slObjMap=containers.Map;

            for ii=1:length(varNames)
                varName=varNames{ii};
                if Simulink.internal.slid.LibraryUtil.needToGetSlObjectFromBWS(varName,slObjMap)
                    slObj=evalin('base',varName);
                    slObjMap(varName)=slObj;
                end
            end
        end



        function rst=needToGetSlObjectFromBWS(varName,objMap)
            isVarInMap=isKey(objMap,varName);
            if isVarInMap
                rst=false;
                return;
            end

            isVarInBWS=(evalin('base',['exist(''',varName,''')'])==1);
            if~isVarInBWS
                rst=false;
                Simulink.internal.slid.LibraryUtil.throwWarning('SLDD:sldd:VarNotInBWS',varName);
                return;
            end

            rst=true;
        end


        function throwWarning(msgID,varargin)
            msg=message(msgID,varargin{:});
            warning(msgID,msg.getString);
        end

    end
end
