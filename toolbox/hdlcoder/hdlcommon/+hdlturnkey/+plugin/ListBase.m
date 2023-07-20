


classdef(Abstract)ListBase<handle


    properties(Access=protected)

        PluginObjList=containers.Map();
    end

    methods

        function obj=ListBase()

        end

        function initList(obj)

            obj.PluginObjList=containers.Map();
        end

        function nameList=getNameList(obj)

            nameList=obj.PluginObjList.keys;
        end

        function isEmpty=isListEmpty(obj)

            isEmpty=obj.PluginObjList.isempty;
        end

        function[isIn,hP]=isInList(obj,pname)


            if obj.PluginObjList.isKey(pname)
                isIn=true;
                hP=obj.PluginObjList(pname);
            else
                isIn=false;
                hP=[];
            end
        end

        function setPluginObject(obj,pname,hP)


            if obj.PluginObjList.isKey(pname)
                obj.PluginObjList(pname)=hP;
            else
                obj.insertPluginObject(pname,hP);
            end

        end

    end

    methods(Access=protected)

        function insertPluginObject(obj,pname,hP)


            if~obj.PluginObjList.isKey(pname)
                obj.PluginObjList(pname)=hP;
            else
                hPDup=obj.PluginObjList(pname);
                error(message('hdlcommon:workflow:DuplicateBoardName',pname,hPDup.PluginPath,hP.PluginPath));
            end

        end

    end

end



