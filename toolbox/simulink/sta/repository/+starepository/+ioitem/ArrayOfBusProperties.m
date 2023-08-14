classdef ArrayOfBusProperties<starepository.ioitem.ItemProperties






    properties
Dimension
    end
    methods
        function obj=ArrayOfBusProperties(Name)
            obj=obj@starepository.ioitem.ItemProperties(Name);


        end

        function displaypropnamevalue=getPropertyNames(obj)

            unsortedprops=fieldnames(obj);

            [~,id]=sortrows(lower(fieldnames(obj)),1);


            properties=unsortedprops(id);

            displaypropnamevalue=cell(length(properties),2);

            counter=0;

            for id=1:length(properties)








                if~isempty(obj.(properties{id}))
                    counter=counter+1;
                    displaypropnamevalue{counter,1}=getString(message(['sl_sta_repository:item:',properties{id}]));
                    displaypropnamevalue{counter,2}=obj.(properties{id});
                end

            end

            displaypropnamevalue=displaypropnamevalue(1:counter,:);
        end
    end
end



