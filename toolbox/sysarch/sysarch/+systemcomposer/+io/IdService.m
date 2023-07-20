classdef IdService<handle



    properties(SetAccess=private)
        mapsContainer;
    end
    methods(Access=public)

        function obj=IdService()

            obj.mapsContainer=containers.Map('keytype','char','valuetype','any');
        end
    end










    methods(Access=public)
        function id=getID(this,mapName,key,appendChar)


            if(nargin<4)
                appendChar='';
            end
            if~ismember(mapName,this.mapsContainer.keys)
                this.mapsContainer(mapName)=containers.Map('keytype','char','valuetype','any');
            end
            map=this.mapsContainer(mapName);
            if~ismember(key,map.keys)
                no=numel(map.keys);
                id=append(appendChar,num2str(no+1));
                map(char(key))=id;
            else
                id=map(char(key));
            end
            this.mapsContainer(mapName)=map;
        end
    end
end

