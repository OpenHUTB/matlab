function sendFilesToBaseWorkspace(javaFileCollection,variable)





    filepaths=cell(javaFileCollection.size,1);
    iterator=javaFileCollection.iterator;
    counter=1;
    while(iterator.hasNext)
        filepath=char(iterator.next.getPath);
        filepaths{counter}=filepath;
        counter=counter+1;
    end

    assignin('base',char(variable),filepaths);

end

