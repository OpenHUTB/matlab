



classdef IdObjectSet<matlab.mixin.Copyable


    properties(Dependent,SetAccess=protected)
Numel
    end


    properties(Hidden,Dependent,SetAccess=protected)

Num
    end


    properties(SetAccess=protected)
        Ids uint32
        Items legacycode.lct.util.IdObject
    end


    methods




        function idx=add(this,item)


            narginchk(2,2);
            validateattributes(item,{'legacycode.lct.util.IdObject'},...
            {'scalar','nonempty'},2);


            idx=[];
            if item.Id<1
                return
            end


            if isempty(this.findItem(item.Id))

                this.Items(item.Id)=item;


                this.Ids=sort([this.Ids,item.Id]);
            end

            idx=item.Id;
        end




        function idx=findItem(this,item)


            narginchk(2,2);
            validateattributes(item,{'legacycode.lct.util.IdObject','numeric'},...
            {'scalar','nonempty'},2);


            if isnumeric(item)
                id=item;
            else
                id=item.Id;
            end
            idx=this.Ids(this.Ids==id);
        end




        function num=get.Numel(this)
            num=numel(this.Ids);
        end




        function num=get.Num(this)
            num=this.Numel;
        end




        function forEachData(this,funHandler)
            for ii=this.Ids
                funHandler(this,ii,this.Items(ii));
            end
        end
    end


    methods(Access=protected)




        function newObj=copyElement(this)

            newObj=copyElement@matlab.mixin.Copyable(this);


            for ii=1:this.Numel
                if this.Items(ii).Id>0
                    newObj.Items(ii)=copy(this.Items(ii));
                end
            end
        end
    end
end


