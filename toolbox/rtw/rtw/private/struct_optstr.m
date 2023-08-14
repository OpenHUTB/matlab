function output=struct_optstr(structArray)





    output='';

    if isempty(structArray)
        return;
    end






    nameCell={};
    for i=1:length(structArray)
        nameCell{i}=structArray(i).name;
    end

    [sortedNames,indices]=sort(nameCell);

    for j=indices

        v=structArray(j).value;

        if strcmp(structArray(j).enable,'on')&&~isempty(v)

            assig=['-a',structArray(j).name,'=',num2str(v)];

            output=[output,quoteIfNeeded(assig,''''),' '];

        end
    end

    output(end)=[];


