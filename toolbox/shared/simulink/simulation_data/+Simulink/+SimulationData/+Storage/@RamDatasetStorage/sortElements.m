function this=sortElements(this)

    this.Elements=loc_sortElements(this.Elements);
end




function elements=loc_sortElements(elements)





    function result=loc_FirstLessThanOrEqualToSecond(element1,element2)

        blockPath1=element1.BlockPath;
        blockPath2=element2.BlockPath;


        if(blockPath1.getLength()<blockPath2.getLength())
            result=true;
            return;
        elseif(blockPath1.getLength()>blockPath2.getLength())
            result=false;
            return;
        end




        for i=1:blockPath1.getLength()
            pathPart1=blockPath1.getBlock(i);
            pathPart2=blockPath2.getBlock(i);
            if(isequal(pathPart1,pathPart2))
                continue;
            else
                temp={pathPart1,pathPart2};
                temp=sort(temp);
                if(isequal(temp{1},pathPart1))
                    result=true;
                else
                    result=false;
                end
                return;
            end
        end


        class1=class(element1);
        class2=class(element2);
        if(~isequal(class1,class2))
            temp={class1,class2};
            temp=sort(temp);
            if(isequal(temp{1},class1))
                result=true;
                return;
            else
                result=false;
                return;
            end
        end


        elementName1=element1.Name;
        elementName2=element2.Name;
        if(~isequal(elementName1,elementName2))
            temp={elementName1,elementName2};
            temp=sort(temp);
            if(isequal(temp{1},elementName1))
                result=true;
                return;
            else
                result=false;
                return;
            end
        end


        port1=element1.PortIndex;
        port2=element2.PortIndex;
        result=(port1<=port2);
    end



    function swapElements=loc_swapElements(swapElements,a,b)
        temp=swapElements{a};
        swapElements{a}=swapElements{b};
        swapElements{b}=temp;
    end








    function[partitionElements,storeIndex]=loc_quicksortPartition(partitionElements,left,right)
        pivotIndex=randi([left,right]);
        pivotValue=partitionElements{pivotIndex};


        partitionElements=loc_swapElements(partitionElements,pivotIndex,right);

        storeIndex=left;
        for i=left:(right-1)
            if(loc_FirstLessThanOrEqualToSecond(partitionElements{i},pivotValue))
                partitionElements=loc_swapElements(partitionElements,i,storeIndex);
                storeIndex=storeIndex+1;
            end
        end


        partitionElements=loc_swapElements(partitionElements,storeIndex,right);
    end





    function[sortedElements]=loc_quicksort(sortedElements,left,right)
        if(right>left)
            [sortedElements,pivotIndex]=loc_quicksortPartition(sortedElements,left,right);
            sortedElements=loc_quicksort(sortedElements,left,pivotIndex-1);
            sortedElements=loc_quicksort(sortedElements,pivotIndex+1,right);
        end
    end


    elements=loc_quicksort(elements,1,length(elements));
end
