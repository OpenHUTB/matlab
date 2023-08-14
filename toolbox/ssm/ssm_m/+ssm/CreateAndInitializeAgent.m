function instance=CreateAndInitializeAgent(inputPath,properties)
    [~,fileName,~]=fileparts(inputPath);
    instance=eval(fileName);

    for i=1:length(properties)
        val=eval(properties(i).value);
        instance.(properties(i).name)=val;
    end

end
