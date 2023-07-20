
classdef BaseReader_DMR<handle


    properties(Access=protected)

        fRepo;


        fType;


        fData;


        fDesc;
    end

    methods(Access=protected)


        function obj=BaseReader_DMR(aRepo,add,aType,aIsInitTables)
            if(nargin<1)
                DAStudio.error('Slci:slci:InvalidNumberOfArguments');
            end
            obj.fRepo=aRepo;
            obj.fType=aType;
            myTableGroupObj=obj.getTableGroupObj(add,aIsInitTables);
            obj.setDataInstance(myTableGroupObj);
            obj.setDescInstance(myTableGroupObj);
        end

    end

    methods(Abstract,Access=public)
        dObject=getObject(obj,aKey);
        dObjects=getObjects(obj,keyList);
        hasObj=hasObject(obj,aKey);
    end

    methods(Abstract,Access=public,Hidden=true)
        insertObject(obj,aKey,aObject);
        replaceObject(obj,aKey,aObject);
        keyList=getKeys(obj);
    end

    methods(Access=public,Hidden=true)

        function parsedKey=parseKey(obj,aKey)%#ok
            parsedKey=regexprep(aKey,{'/','\.','<','>'},...
            {'&#47;','&#46;','&#60;','&#62;'});
        end

        function aKey=unParseKey(obj,parsedKey)%#ok
            aKey=regexprep(parsedKey,{'&#47;','&#46;','&#60;','&#62;'},...
            {'/','\.','<','>'});
        end

    end

    methods(Access=protected)







        function[myTableGroupObj]=getTableGroupObj(obj,aResultsGroupCollection,aIsInitTables)
            if(aIsInitTables)

                myResultsGroupObj=slci.resultsRepo.ResultsGroup(obj.fRepo);
                myResultsGroupObj.type=obj.fType;


                myResultsGroupObj.tableGroupObj=slci.resultsRepo.TableGroup(obj.fRepo);
                myTableGroupObj=myResultsGroupObj.tableGroupObj;


                aResultsGroupCollection.insert(myResultsGroupObj);
            else

                myTableGroupObj=aResultsGroupCollection.getByKey(obj.fType).tableGroupObj;
            end
        end


        function setDataInstance(obj,myTableGroupObj)
            obj.fData=myTableGroupObj.dataCollection;
        end


        function setDescInstance(obj,myTableGroupObj)
            obj.fDesc=myTableGroupObj.descCollection;
        end

    end

end
