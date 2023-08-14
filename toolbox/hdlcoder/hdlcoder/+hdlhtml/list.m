

classdef list<handle
    properties(SetAccess=private,GetAccess=private)
mList
    end

    methods


        function this=list
            this.mList=ModelAdvisor.List;
        end


        function createEntry(this,item)
            this.mList.addItem(item);
        end


        function html=getHTML(this)
            html=this.mList.emitHTML;
        end


        function list=getData(this)
            list=this.mList;
        end

    end
end