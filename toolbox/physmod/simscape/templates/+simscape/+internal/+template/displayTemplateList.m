function displayTemplateList





    kwMap=simscape.internal.template.getTemplateKeywords;
    lDisplayList([kwMap.keys;kwMap.values],"Template keywords");

    lDisplayFilesInPackage('simscape.template');

end

function lDisplayList(list,header)

    SPACING=4;
    indent=repmat(' ',1,SPACING);
    if isempty(list)
        return;
    end

    width1=lGetLengthOfLongestString(list(1,:))+2*SPACING;
    width2=lGetLengthOfLongestString(list(2,:));
    lDisplayHeader(header,width1+width2);

    for i=1:size(list,2)
        fprintf('%-*s%s\n',width1,[indent,list{1,i}],list{2,i});
    end

end

function len=lGetLengthOfLongestString(strs)

    len=size(char(strs),2);
end

function lDisplayHeader(header,minLength)

    separator=repmat('-',1,max(minLength,length(header)));
    fprintf('%s\n%s\n%s\n',separator,header,separator);
end

function lDisplayFilesInPackage(packageName)



    package=meta.package.fromName(packageName);
    if isempty(package)
        return;
    end


    names={package.FunctionList.Name};
    names=names(cellfun(@(x)lIsSimscapeFile(x,package.Name),names));
    descriptors=cellfun(@(x)lGetDescriptor(x,package.Name),names,...
    'UniformOutput',false);
    lDisplayList([names;descriptors],['Files in package ',char(package.Name)]);


    for i=1:length(package.PackageList)
        lDisplayFilesInPackage(package.PackageList(i).Name);
    end

end

function out=lIsSimscapeFile(name,packageName)


    fullname=strcat(packageName,'.',name);
    [~,~,ext]=fileparts(which(fullname));
    out=strcmpi(ext,'.ssc');
end

function out=lGetDescriptor(name,packageName)


    out='';
    fullname=strcat(packageName,'.',name);
    try
        out=simscape.schema.loadComponentSchema(fullname).info.Descriptor;
    catch
    end

end