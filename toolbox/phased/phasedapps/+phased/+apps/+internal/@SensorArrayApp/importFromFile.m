function data=importFromFile(obj)








    if~isempty(obj.MatFilePath)
        MatFilePath=obj.MatFilePath;
    else
        MatFilePath='';
    end

    libraryFiles=getString(message('phased:apps:arrayapp:libraryFile'));
    allFiles=getString(message('phased:apps:arrayapp:allFile'));
    selectFileTitle=getString(message('phased:apps:arrayapp:selectFile'));


    [matfile,pathname]=uigetfile(...
    {'*.mat',[libraryFiles,' (*.mat)'];...
    '*.*',[allFiles,' (*.*)']},selectFileTitle,MatFilePath);



    wasCanceled=isequal(matfile,0)||isequal(pathname,0);
    if wasCanceled
        data=[];
        return;
    end


    [~,obj.DefaultSessionName,~]=fileparts([pathname,matfile]);

    try

        temp=load([pathname,matfile],'-mat');
    catch

        data=[];
        errorCall(obj);
        return;
    end


    if isValidFile(temp)
        variables=fieldnames(temp);



        if numel(variables)>1

            str=[getString(message('phased:apps:arrayapp:importfile',obj.DefaultSessionName)),':'];
            data=phased.apps.internal.importDialog(str,temp);
        else
            for i=1:numel(variables)
                data=temp.(variables{i});
            end
        end

        obj.MatFilePath=[pathname,matfile];
    else

        data=[];
        errorCall(obj);
    end
end

function errorCall(obj)
    if strcmp(obj.Container,'ToolGroup')
        h=errordlg(...
        getString(message('phased:apps:arrayapp:invaliddata')),...
        getString(message('phased:apps:arrayapp:errordlg')),'modal');
        uiwait(h);
    else
        uialert(obj.ToolGroup,...
        getString(message('phased:apps:arrayapp:invaliddata')),...
        getString(message('phased:apps:arrayapp:errordlg')));
    end
end

function flag=isValidFile(data)





    variables=fieldnames(data);
    flag_all=zeros(1,numel(variables));

    for i=1:numel(variables)
        val=data.(variables{i});
        flag_all(i)=phased.apps.internal.SensorArrayApp.isValidSensorArray(val);
    end
    flag=any(flag_all);
end