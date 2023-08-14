classdef QABEntries<handle
    properties
        Entries;
    end

    methods(Static)
        function outStructArray=sort(structArray,fieldName)
            if~isempty(structArray)
                [~,I]=sort(arrayfun(@(x)x.(fieldName),structArray));
                outStructArray=structArray(I);
            else
                outStructArray=[];
            end
        end
    end

    methods
        function addEntry(this,s,prepend)
            qabEntry=dig.QABEntry();
            qabEntry.populateEntryFromStruct(s);
            if isempty(this.Entries)
                this.Entries=qabEntry;
            elseif nargin>2&&prepend
                this.Entries=[qabEntry,this.Entries];
            else
                this.Entries=[this.Entries,qabEntry];
            end
        end

        function loadEntries(this,a)
            for i=1:numel(a)
                this.addEntry(a(i));
            end
            this.updateOrderByIndex();
        end

        function removeEntry(this,name)
            for i=1:length(this.Entries)
                if strcmp(this.Entries(i).get('Name'),name)
                    this.Entries(i)=[];
                    break;
                end
            end
        end

        function ret=getEntries(this)
            ret=this.Entries;
        end

        function bool=hasEntries(this)
            bool=~isempty(this.Entries);
        end

        function len=length(this)
            len=length(this.Entries);
        end

        function[ret,index]=getEntryByName(this,name)
            ret=[];
            index=[];
            for i=1:length(this.Entries)
                if strcmp(name,this.Entries(i).Name)
                    ret=this.Entries(i);
                    index=i;
                    break;
                end
            end
        end

        function ret=getEntryByVisibleIndex(this,index)

            entries=this.Entries;
            sz=length(entries);
            visibleIndex=0;
            ret=[];

            for ii=1:sz
                entry=entries(ii);
                if entry.Visible
                    visibleIndex=visibleIndex+1;
                    if visibleIndex==index
                        ret=entry;
                    end
                end
            end
        end

        function visibleEntries=getVisibleEntries(this)


            entries=this.Entries;
            visibleIndices=arrayfun(@(X)X.Visible,entries);
            entries=this.toCellArray();
            visibleEntries=entries(visibleIndices);
        end

        function moveEntry(this,fromIndex,toIndex)



            size=length(this.Entries);

            if fromIndex<toIndex
                s=circshift(this.Entries(fromIndex:toIndex),-1);
                this.Entries=[this.Entries(1:fromIndex-1),s,this.Entries(toIndex+1:size)];
            elseif toIndex<fromIndex
                s=circshift(this.Entries(toIndex:fromIndex),1);
                this.Entries=[this.Entries(1:toIndex-1),s,this.Entries(fromIndex+1:size)];
            else
                return;
            end

            this.updateIndexByOrder();
        end

        function entries=serialize(this)
            entries=[];
            for i=1:length(this.Entries)
                entries=[entries,this.Entries(i).toStruct()];
            end
        end

        function ret=toCellArray(this)
            sz=length(this.Entries);
            ret=cell(1,sz);
            for i=1:sz
                ret{i}=this.Entries(i).toStruct();
            end
        end

        function updateIndexByOrder(this)
            for index=1:length(this.Entries)
                this.Entries(index).updateIndex(index-1);
            end
        end

        function updateOrderByIndex(this)
            fieldName='Index';
            this.Entries=dig.QABEntries.sort(this.Entries,fieldName);
        end
    end
end